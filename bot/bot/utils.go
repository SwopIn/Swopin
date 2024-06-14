package main

import "fmt"

// Contains checks if a given int64 value is present in a slice of int64
func Contains(slice []int64, num int64) bool {
	for _, v := range slice {
		if v == num {
			return true
		}
	}
	return false
}
func NotificationResult(got int, sent int, err error) string {
	return fmt.Sprintf("Got %d users to notificate, sent %d notifications successfully.\n \nAn errors occurred while sending notifications: %v", got, sent, err)
}
