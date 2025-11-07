package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"math"
	"net/http"
	"os"
	"time"

	"github.com/google/generative-ai-go/genai"
	"github.com/joho/godotenv"
	"google.golang.org/api/option"
)

// PrayerEntry represents a single entry in the database with embedding
type PrayerEntry struct {
	Input     string    `json:"input"`
	Embedding []float32 `json:"embedding"`
	Keywords  string    `json:"keywords"`
	Prayer    string    `json:"prayer"`
	Timestamp string    `json:"timestamp"`
}

const (
	DATABASE_FILE        = "/workspace/prayai/prayai-go/database.json"
	SIMILARITY_THRESHOLD = 0.85 // 85% similarity threshold
)

// cosineSimilarity calculates the cosine similarity between two vectors
func cosineSimilarity(a, b []float32) float64 {
	if len(a) != len(b) {
		return 0.0
	}

	var dotProduct, normA, normB float64
	for i := 0; i < len(a); i++ {
		dotProduct += float64(a[i]) * float64(b[i])
		normA += float64(a[i]) * float64(a[i])
		normB += float64(b[i]) * float64(b[i])
	}

	if normA == 0 || normB == 0 {
		return 0.0
	}

	return dotProduct / (math.Sqrt(normA) * math.Sqrt(normB))
}

// loadDatabase loads the prayer database from JSON file
func loadDatabase() ([]PrayerEntry, error) {
	data, err := os.ReadFile(DATABASE_FILE)
	if err != nil {
		if os.IsNotExist(err) {
			return []PrayerEntry{}, nil
		}
		return nil, err
	}

	var database []PrayerEntry
	if err := json.Unmarshal(data, &database); err != nil {
		return nil, err
	}

	return database, nil
}

// saveDatabase saves the prayer database to JSON file
func saveDatabase(database []PrayerEntry) error {
	data, err := json.MarshalIndent(database, "", "    ")
	if err != nil {
		return err
	}

	return os.WriteFile(DATABASE_FILE, data, 0644)
}

// getEmbedding generates embedding vector for given text using Gemini API
func getEmbedding(ctx context.Context, client *genai.Client, text string) ([]float32, error) {
	em := client.EmbeddingModel("gemini-embedding-001")
	res, err := em.EmbedContent(ctx, genai.Text(text))
	if err != nil {
		return nil, err
	}

	if res == nil || res.Embedding == nil || res.Embedding.Values == nil {
		return nil, fmt.Errorf("no embedding generated")
	}

	return res.Embedding.Values, nil
}

// extractKeywords generates keywords from text using Gemini API
func extractKeywords(ctx context.Context, model *genai.GenerativeModel, text string) (string, error) {
	prompt := fmt.Sprintf("다음 텍스트를 10개 이하의 간단한 키워드로 요약해 주세요 (쉼표로 구분): %s", text)
	resp, err := model.GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		return "", err
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return "", fmt.Errorf("no response generated")
	}

	return fmt.Sprintf("%v", resp.Candidates[0].Content.Parts[0]), nil
}

// createPrayer generates a prayer based on keywords using Gemini API
func createPrayer(ctx context.Context, model *genai.GenerativeModel, keywords string) (string, error) {
	prompt := fmt.Sprintf("다음 키워드를 바탕으로 따뜻하고 진심 어린 기도문을 작성해 주세요:\n\n키워드: %s", keywords)
	resp, err := model.GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		return "", err
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return "", fmt.Errorf("no response generated")
	}

	return fmt.Sprintf("%v", resp.Candidates[0].Content.Parts[0]), nil
}

// findSimilarPrayer searches for similar prayer in database based on embedding similarity
func findSimilarPrayer(embedding []float32, database []PrayerEntry) (*PrayerEntry, float64) {
	var bestMatch *PrayerEntry
	var bestSimilarity float64 = 0.0

	for i := range database {
		similarity := cosineSimilarity(embedding, database[i].Embedding)
		log.Printf("  Comparing with entry %d: '%s' - similarity: %.4f", i, database[i].Input, similarity)
		if similarity > bestSimilarity {
			bestSimilarity = similarity
			bestMatch = &database[i]
		}
	}

	return bestMatch, bestSimilarity
}

// generatePrayer generates or retrieves a prayer based on user input with semantic caching
func generatePrayer(ctx context.Context, client *genai.Client, model *genai.GenerativeModel, userInput string) (string, string, bool, float64, error) {
	log.Printf("User input: %s", userInput)

	// Step 1: Generate embedding for user input
	embedding, err := getEmbedding(ctx, client, userInput)
	if err != nil {
		return "", "", false, 0, fmt.Errorf("embedding generation failed: %v", err)
	}
	log.Printf("Embedding generated: %d dimensions", len(embedding))

	// Step 2: Load database
	database, err := loadDatabase()
	if err != nil {
		return "", "", false, 0, fmt.Errorf("database load failed: %v", err)
	}
	log.Printf("Database loaded: %d entries", len(database))

	// Step 3: Search for similar prayer
	match, similarity := findSimilarPrayer(embedding, database)
	log.Printf("Best similarity: %.4f (threshold: %.2f)", similarity, SIMILARITY_THRESHOLD)

	// Step 4: Cache hit - return existing prayer
	if similarity >= SIMILARITY_THRESHOLD && match != nil {
		log.Printf("CACHE HIT! Similar input found: '%s'", match.Input)
		return match.Prayer, match.Keywords, true, similarity, nil
	}

	// Step 5: Cache miss - generate new prayer
	log.Println("CACHE MISS. Generating new prayer...")

	// Extract keywords
	keywords, err := extractKeywords(ctx, model, userInput)
	if err != nil {
		return "", "", false, 0, fmt.Errorf("keyword extraction failed: %v", err)
	}
	log.Printf("Keywords extracted: %s", keywords)

	// Generate prayer
	prayer, err := createPrayer(ctx, model, keywords)
	if err != nil {
		return "", "", false, 0, fmt.Errorf("prayer generation failed: %v", err)
	}

	// Step 6: Save to database
	newEntry := PrayerEntry{
		Input:     userInput,
		Embedding: embedding,
		Keywords:  keywords,
		Prayer:    prayer,
		Timestamp: time.Now().Format(time.RFC3339),
	}

	database = append(database, newEntry)
	if err := saveDatabase(database); err != nil {
		log.Printf("Warning: failed to save database: %v", err)
	} else {
		log.Println("New prayer saved to database")
	}

	return prayer, keywords, false, similarity, nil
}

func main() {
	// Load environment variables
	if err := godotenv.Load("/workspace/prayai/.env"); err != nil {
		log.Printf("Warning: Error loading .env file: %v", err)
	}

	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		log.Fatal("GEMINI_API_KEY is not set")
	}

	ctx := context.Background()
	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		log.Fatalf("Error creating client: %v", err)
	}
	defer client.Close()

	// Model for text generation
	model := client.GenerativeModel("gemini-2.0-flash-exp")
	model.SetTemperature(0.7) // Slightly creative for prayers

	// Setup HTTP handlers
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "/workspace/prayai/prayai-go/index.html")
	})

	http.HandleFunc("/pray", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "POST" {
			http.Redirect(w, r, "/", http.StatusSeeOther)
			return
		}

		r.ParseForm()
		userInput := r.FormValue("userInput")

		if userInput == "" {
			http.Error(w, "입력이 비어있습니다", http.StatusBadRequest)
			return
		}

		prayer, keywords, cacheHit, similarity, err := generatePrayer(ctx, client, model, userInput)
		if err != nil {
			http.Error(w, fmt.Sprintf("오류 발생: %v", err), http.StatusInternalServerError)
			return
		}

		// Prepare response HTML
		cacheStatus := "새로 생성됨"
		cacheColor := "#ff9800"
		if cacheHit {
			cacheStatus = "캐시에서 가져옴"
			cacheColor = "#4caf50"
		}

		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		html := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
<title>Pray AI - 결과</title>
<style>
body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
.status { background: %s; color: white; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
.info { background: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
.prayer { background: #e3f2fd; padding: 20px; border-radius: 5px; white-space: pre-wrap; line-height: 1.6; }
a { display: inline-block; margin-top: 20px; padding: 10px 20px; background: #2196f3; color: white; text-decoration: none; border-radius: 5px; }
</style>
</head>
<body>
<div class="status">
<strong>상태:</strong> %s | <strong>유사도:</strong> %.2f%%
</div>
<div class="info">
<strong>키워드:</strong> %s
</div>
<h2>기도문</h2>
<div class="prayer">%s</div>
<a href="/">다시 작성하기</a>
</body>
</html>
`, cacheColor, cacheStatus, similarity*100, keywords, prayer)

		fmt.Fprint(w, html)
	})

	port := ":8090"
	log.Printf("🚀 Server starting on http://localhost%s", port)
	log.Printf("📊 Similarity threshold: %.2f", SIMILARITY_THRESHOLD)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatal(err)
	}
}
