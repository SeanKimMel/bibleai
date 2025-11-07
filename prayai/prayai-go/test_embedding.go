package main

import (
	"context"
	"fmt"
	"os"

	"github.com/google/generative-ai-go/genai"
	"github.com/joho/godotenv"
	"google.golang.org/api/option"
)

func main() {
	godotenv.Load("/workspace/prayai/.env")
	apiKey := os.Getenv("GEMINI_API_KEY")

	ctx := context.Background()
	client, _ := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	defer client.Close()

	em := client.EmbeddingModel("text-embedding-004")

	// Test 1
	res1, _ := em.EmbedContent(ctx, genai.Text("가족의 건강을 위해"))
	fmt.Printf("Test 1 (가족 건강) - First 5: %v\n", res1.Embedding.Values[0:5])

	// Test 2
	res2, _ := em.EmbedContent(ctx, genai.Text("시험에 합격하고 싶습니다"))
	fmt.Printf("Test 2 (시험 합격) - First 5: %v\n", res2.Embedding.Values[0:5])

	// Calculate similarity
	var dot, norm1, norm2 float64
	for i := 0; i < len(res1.Embedding.Values); i++ {
		dot += float64(res1.Embedding.Values[i]) * float64(res2.Embedding.Values[i])
		norm1 += float64(res1.Embedding.Values[i]) * float64(res1.Embedding.Values[i])
		norm2 += float64(res2.Embedding.Values[i]) * float64(res2.Embedding.Values[i])
	}

	similarity := dot / (sqrt(norm1) * sqrt(norm2))
	fmt.Printf("\nCosine similarity: %.4f\n", similarity)
}

func sqrt(x float64) float64 {
	if x == 0 {
		return 0
	}
	z := x
	for i := 0; i < 10; i++ {
		z -= (z*z - x) / (2 * z)
	}
	return z
}
