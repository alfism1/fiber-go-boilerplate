package validator

import (
	"regexp"
	"strings"
)

func IsValidEmail(email string) bool {
	emailRegex := regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`)
	return emailRegex.MatchString(strings.ToLower(email))
}

func IsValidPassword(password string) bool {
	return len(password) >= 6
}
