package analyzer

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/ledongthuc/pdf"
	"io"
	"net/http"
	"regexp"
	"strings"
	"vkatun/config"
	"vkatun/pkg/models"
)

func ParseResumeFromPDF(data []byte) (models.ResumeInput, string, error) {
	reader := bytes.NewReader(data)
	pdfReader, err := pdf.NewReader(reader, int64(len(data)))
	if err != nil {
		return models.ResumeInput{}, "", fmt.Errorf("ошибка чтения PDF: %v", err)
	}

	content, err := pdfReader.GetPlainText()
	buf := new(bytes.Buffer)
	if _, err = io.Copy(buf, content); err != nil {
		return models.ResumeInput{}, "", fmt.Errorf("ошибка копирования текста: %v", err)
	}

	fullText := buf.String()

	resume, resumeStr, err := restoreTextStructure(fullText)

	return resume, resumeStr, err
}

func restoreTextStructure(text string) (models.ResumeInput, string, error) {
	cleaned := baseTextStructure(text)
	jsonResume, err := checkAndExtractResumeWithAI(cleaned)

	jsonResume = strings.TrimSpace(jsonResume)
	if strings.HasPrefix(jsonResume, "```json") || strings.HasPrefix(jsonResume, "```") {
		jsonResume = stripMarkdownCodeBlock(jsonResume)
	}

	var resume models.ResumeInput
	err = json.Unmarshal([]byte(jsonResume), &resume)
	if err != nil {
		return models.ResumeInput{}, jsonResume, fmt.Errorf("ошибка парсинга json: %v", err)
	}

	return resume, jsonResume, nil
}

func baseTextStructure(text string) string {
	text = strings.ReplaceAll(text, "\u00A0", " ")
	text = strings.ReplaceAll(text, "\u200B", " ")

	text = strings.ReplaceAll(text, "  ", " ")

	re := regexp.MustCompile(`([.!?:])([A-ZА-Я])`)
	text = re.ReplaceAllString(text, "$1\n$2")

	reWords := regexp.MustCompile(`([а-яa-z])([А-ЯA-Z])`)
	text = reWords.ReplaceAllString(text, "$1 $2")

	text = restoreLists(text)

	headers := []string{
		"Желаемая должность и зарплата",
		"Опыт работы",
		"Образование",
		"Навыки",
		"Дополнительная информация",
	}

	for _, header := range headers {
		text = strings.ReplaceAll(text, header, "\n\n"+header)
	}

	text = strings.TrimSpace(text)

	return text
}

func restoreLists(text string) string {
	listPatterns := []string{
		`(?m)^•\s*`,
		`(?m)^\d+\.\s*`,
		`(?m)^-\s*`,
	}

	for _, pattern := range listPatterns {
		re := regexp.MustCompile(pattern)
		text = re.ReplaceAllString(text, "- ")
	}

	return text
}

func checkAndExtractResumeWithAI(text string) (string, error) {
	requestBody := models.DeepSeekRequest{
		Model: config.Model,
		Messages: []models.Message{
			{
				Role:    config.RoleSystem,
				Content: config.Extract,
			},
			{
				Role:    config.RoleUser,
				Content: text,
			},
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
		return "", fmt.Errorf("ошибка парсинга ответ: %v", err)
	}

	if len(result.Choices) > 0 {
		return result.Choices[0].Message.Content, fmt.Errorf("модель DeepSeek не вернула ответ")
	}

	return "", nil
}

func stripMarkdownCodeBlock(text string) string {
	re := regexp.MustCompile("(?s)```(?:json)?(.*?)```")
	matches := re.FindStringSubmatch(text)
	if len(matches) > 1 {
		return strings.TrimSpace(matches[1])
	}
	return text
}
