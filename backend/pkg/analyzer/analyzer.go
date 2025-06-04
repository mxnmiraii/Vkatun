package analyzer

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"vkatun/config"
	"vkatun/pkg/models"
	"vkatun/pkg/utils"
)

type issueGrammar struct {
	Text       string `json:"text"`
	Suggestion string `json:"suggestion"`
	Type       string `json:"type"`
}

type Issue struct {
	Text   string `json:"text"`
	Reason string `json:"reason"`
}

type ValidationResult struct {
	IsValid bool `json:"isValid"`
}

type Recommendation struct {
	Comment string `json:"comment"`
}

func GrammarCheck(text string) ([]issueGrammar, error) {
	resp, err := requestRawFromAI(config.Grammar, text)
	if err != nil {
		return nil, err
	}
	if strings.HasPrefix(resp, "```json") || strings.HasPrefix(resp, "```") {
		resp = utils.StripMarkdownCodeBlock(resp)
	}

	var issues []issueGrammar
	if err := json.Unmarshal([]byte(resp), &issues); err != nil {
		return nil, fmt.Errorf("error parsing JSON: %v", err)
	}
	return issues, nil
}

func AboutCheck(text string) (Recommendation, error) {
	resp, err := requestRawFromAI(config.About, text)
	if err != nil {
		return Recommendation{}, err
	}
	if strings.HasPrefix(resp, "```json") || strings.HasPrefix(resp, "```") {
		resp = utils.StripMarkdownCodeBlock(resp)
	}

	var result ValidationResult
	if err := json.Unmarshal([]byte(resp), &result); err != nil {
		return Recommendation{}, fmt.Errorf("error parsing JSON: %v", err)
	}

	if !result.IsValid {
		return Recommendation{
			Comment: "Добавьте контактные данные, такие как номер телефона, электронную почту или ссылку на Telegram.",
		}, nil
	}

	return Recommendation{}, nil
}

func ExperienceCheck(text string) (Recommendation, error) {
	resp, err := requestRawFromAI(config.Experience, text)
	if err != nil {
		return Recommendation{}, err
	}
	if strings.HasPrefix(resp, "```json") || strings.HasPrefix(resp, "```") {
		resp = utils.StripMarkdownCodeBlock(resp)
	}

	var result ValidationResult
	if err := json.Unmarshal([]byte(resp), &result); err != nil {
		return Recommendation{}, fmt.Errorf("error parsing JSON: %v", err)
	}

	if !result.IsValid {
		return Recommendation{
			Comment: "Расширье описание вашего опыта. Укажите ключевые обязанности, достижения и конкретные примеры проектов.",
		}, nil
	}

	return Recommendation{}, nil
}

func SkillsCheck(text string) ([]Issue, error) {
	resp, err := requestRawFromAI(config.Skills, text)
	if err != nil {
		return nil, err
	}
	if strings.HasPrefix(resp, "```json") || strings.HasPrefix(resp, "```") {
		resp = utils.StripMarkdownCodeBlock(resp)
	}

	var rawSkills []string
	if err := json.Unmarshal([]byte(resp), &rawSkills); err != nil {
		return nil, fmt.Errorf("error parsing JSON: %v", err)
	}

	issues := make([]Issue, 0, len(rawSkills))
	for _, skill := range rawSkills {
		issues = append(issues, Issue{
			Text:   skill,
			Reason: "Указанный навык не является релевантным и может создать впечатление несоответствия вакансии.",
		})
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
		return "", fmt.Errorf("error serializing request: %v", err)
	}

	req, err := http.NewRequest("POST", config.DeepSeekURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("error creating request: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+config.DeepSeekAPIKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("error making request to DeepSeek: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("unsuccessful response from DeepSeek (%d): %s", resp.StatusCode, string(body))
	}

	var result models.DeepSeekResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return "", fmt.Errorf("error parsing response: %v", err)
	}

	if len(result.Choices) > 0 {
		content := result.Choices[0].Message.Content
		log.Printf("analysis result from LLM: %s", content)

		cleaned := utils.StripMarkdownCodeBlock(result.Choices[0].Message.Content)
		log.Printf("after formatting: %s", cleaned)
		return cleaned, nil
	}

	return "", fmt.Errorf("DeepSeek model returned no responses")
}
