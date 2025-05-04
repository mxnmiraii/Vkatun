package analyzer

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"vkatun/config"
	"vkatun/pkg/models"
	"vkatun/pkg/utils"
)

type issue struct {
	Text       string `json:"text"`
	Suggestion string `json:"suggestion"`
	Type       string `json:"type"`
}

func GrammarCheck(text string) ([]issue, error) {
	grammar := config.Grammar
	return requestIssuesFromAI(grammar, text)
}

func StructureCheck(text string) ([]string, error) {
	structure := config.Structure
	resp, err := requestRawFromAI(structure, text)
	if err != nil {
		return nil, err
	}
	var out []string
	if err := json.Unmarshal([]byte(resp), &out); err != nil {
		return nil, fmt.Errorf("ошибка парсинга ответа: %v", err)
	}
	return out, nil
}

func SkillsCheck(resume models.Resume) ([]string, error) {
	skills := config.Skills
	if len(skills) == 0 {
		return nil, errors.New("конфигурация skills пуста — ни одного навыка не загружено")
	}

	combined := resume.Skills + " " + resume.About + " " + resume.Experience
	if strings.TrimSpace(combined) == "" {
		return nil, errors.New("резюме не содержит текст в секциях skills, about или experience")
	}

	var found []string
	for _, skill := range skills {
		if containsIgnoreCase(combined, skill) {
			found = append(found, skill)
		}
	}
	return found, nil
}

func requestIssuesFromAI(prompt, text string) ([]issue, error) {
	resp, err := requestRawFromAI(prompt, text)
	if err != nil {
		return nil, err
	}

	var issues []issue
	if err := json.Unmarshal([]byte(resp), &issues); err != nil {
		return nil, fmt.Errorf("ошибка парсинга JSON: %v", err)
	}
	return issues, nil
}

func requestRawFromAI(systemPrompt, userText string) (string, error) {
	requestBody := models.DeepSeekRequest{
		Model: config.Model,
		Messages: []models.Message{
			{Role: config.RoleSystem, Content: systemPrompt},
			{Role: config.RoleUser, Content: userText},
		},
	}

	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return "", fmt.Errorf("ошибка сериализации запроса: %v", err)
	}

	req, err := http.NewRequest("POST", config.DeepSeekURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("ошибка создания запроса: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+config.DeepSeekAPIKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("ошибка при запросе к DeepSeek: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("ошибка чтения ответа: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("неуспешный ответ от DeepSeek (%d): %s", resp.StatusCode, string(body))
	}

	var result models.DeepSeekResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return "", fmt.Errorf("ошибка парсинга ответа: %v", err)
	}

	if len(result.Choices) > 0 {
		content := result.Choices[0].Message.Content
		log.Printf("результат анализа от ллм: %s", content)

		cleaned := utils.StripMarkdownCodeBlock(result.Choices[0].Message.Content)
		log.Printf("после форматирования %s", cleaned)
		return cleaned, nil
	}

	return "", fmt.Errorf("модель DeepSeek не вернула ни одного ответа")
}

func containsIgnoreCase(text, substr string) bool {
	return bytes.Contains(bytes.ToLower([]byte(text)), bytes.ToLower([]byte(substr)))
}
