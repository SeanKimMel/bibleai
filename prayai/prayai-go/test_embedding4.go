package main

import (
	"context"
	"fmt"
	"math"
	"os"

	"github.com/google/generative-ai-go/genai"
	"github.com/joho/godotenv"
	"google.golang.org/api/option"
)

func cosineSim(a, b []float32) float64 {
	var dot, norm1, norm2 float64
	for i := 0; i < len(a) && i < len(b); i++ {
		dot += float64(a[i]) * float64(b[i])
		norm1 += float64(a[i]) * float64(a[i])
		norm2 += float64(b[i]) * float64(b[i])
	}
	return dot / (math.Sqrt(norm1) * math.Sqrt(norm2))
}

func testModel(em *genai.EmbeddingModel, modelName string, ctx context.Context) {
	fmt.Printf("\n=== Testing model: %s ===\n", modelName)

	// Test 1
	res1, err1 := em.EmbedContent(ctx, genai.Text("가족의 건강을 위해"))
	if err1 != nil {
		fmt.Printf("Error: %v\n", err1)
		return
	}
	fmt.Printf("Test 1 (가족 건강) - Dimensions: %d, First 5: %v\n", len(res1.Embedding.Values), res1.Embedding.Values[0:5])

	// Test 2
	res2, _ := em.EmbedContent(ctx, genai.Text("시험에 합격하고 싶습니다"))
	fmt.Printf("Test 2 (시험 합격) - Dimensions: %d, First 5: %v\n", len(res2.Embedding.Values), res2.Embedding.Values[0:5])

	// Test 3 - similar
	res3, _ := em.EmbedContent(ctx, genai.Text("우리 가족이 건강하기를"))
	fmt.Printf("Test 3 (유사: 가족 건강) - Dimensions: %d, First 5: %v\n", len(res3.Embedding.Values), res3.Embedding.Values[0:5])

	// Calculate similarities
	fmt.Printf("\n유사도 결과:\n")
	fmt.Printf("  '가족 건강' vs '시험 합격': %.4f\n", cosineSim(res1.Embedding.Values, res2.Embedding.Values))
	fmt.Printf("  '가족 건강' vs '우리 가족이 건강하기를': %.4f\n", cosineSim(res1.Embedding.Values, res3.Embedding.Values))
}

func main() {
	godotenv.Load("/workspace/prayai/.env")
	apiKey := os.Getenv("GEMINI_API_KEY")

	ctx := context.Background()
	client, _ := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	defer client.Close()

	// Try different model names
	models := []string{
		"gemini-embedding-001",
		"text-embedding-004",
		"embedding-001",
	}

	for _, modelName := range models {
		em := client.EmbeddingModel(modelName)
		testModel(em, modelName, ctx)
	}
}
