package analyzer

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/ledongthuc/pdf"
	"io"
	"log"
	"net/http"
	"regexp"
	"strings"
	"vkatun/config"
	"vkatun/pkg/models"
	"vkatun/pkg/utils"
)

func ParseResumeFromPDF(data []byte) (models.ResumeInput, string, error) {
	reader := bytes.NewReader(data)
	pdfReader, err := pdf.NewReader(reader, int64(len(data)))
	if err != nil {
		return models.ResumeInput{}, "", fmt.Errorf("error reading PDF: %v", err)
	}

	content, err := pdfReader.GetPlainText()
	buf := new(bytes.Buffer)
	if _, err = io.Copy(buf, content); err != nil {
		return models.ResumeInput{}, "", fmt.Errorf("error copying text: %v", err)
	}

	fullText := buf.String()
	log.Printf("resume text before LLM: %s", fullText)

	resume, resumeStr, err := restoreTextStructure(fullText)

	return resume, resumeStr, err
}

func restoreTextStructure(text string) (models.ResumeInput, string, error) {
	cleaned := baseTextStructure(text)
	jsonResume, err := checkAndExtractResumeWithAI(cleaned)
	if err != nil {
		return models.ResumeInput{}, "", err
	}
	log.Printf("resume after parsing: %s", jsonResume)

	if strings.HasPrefix(jsonResume, "```json") || strings.HasPrefix(jsonResume, "```") {
		jsonResume = utils.StripMarkdownCodeBlock(jsonResume)
	}

	var resume models.ResumeInput
	err = json.Unmarshal([]byte(jsonResume), &resume)
	if err != nil {
		return models.ResumeInput{}, jsonResume, fmt.Errorf("error parsing JSON: %v", err)
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
		return result.Choices[0].Message.Content, nil
	}

	return "", fmt.Errorf("DeepSeek model returned no responses")
}
