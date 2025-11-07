package main

import (
	"context"
	"fmt"
	"os"
	"time"

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

	texts := []string{
		"가족의 건강을 위해",
		"시험에 합격하고 싶습니다",
		"hello world",
		"맛있는 음식",
	}

	for _, text := range texts {
		res, err := em.EmbedContent(ctx, genai.Text(text))
		if err != nil {
			fmt.Printf("Error for '%s': %v\n", text, err)
			continue
		}
		fmt.Printf("'%s' - First 10: %v\n", text, res.Embedding.Values[0:10])
		time.Sleep(time.Second)
	}
}
