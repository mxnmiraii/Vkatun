package analyzer

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"vkatun/config"
	"vkatun/pkg/models"
)

type issue struct {
	Text       string `json:"text"`
	Suggestion string `json:"suggestion"`
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

func SkillsCheck(resume models.Resume) []string {
	skills := config.Skills
	combined := resume.Skills + " " + resume.About + " " + resume.Experience

	var found []string
	for _, skill := range skills {
		if containsIgnoreCase(combined, skill) {
			found = append(found, skill)
		}
	}
	return found
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

	jsonData, _ := json.Marshal(requestBody)
	req, _ := http.NewRequest("POST", config.DeepSeekURL, bytes.NewBuffer(jsonData))
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

	var result models.DeepSeekResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return "", fmt.Errorf("ошибка парсинга ответа: %v", err)
	}

	if len(result.Choices) == 0 {
		return "", fmt.Errorf("модель не вернула выбор")
	}

	return result.Choices[0].Message.Content, nil
}

func containsIgnoreCase(text, substr string) bool {
	return bytes.Contains(bytes.ToLower([]byte(text)), bytes.ToLower([]byte(substr)))
}
