package notifications

import (
	"context"
	"fmt"
	supa "github.com/nedpals/supabase-go"
	tele "gopkg.in/telebot.v3"
	"log"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

// sendNotifications fetches user IDs from the database and sends notifications to each user concurrently using Goroutines.
func SendPhotoNotifications(bot *tele.Bot, supabase *supa.Client, message string, url string, opts ...interface{}) (int, int, error) {

	// Fetch user IDs from the database
	userIDs, err := getUserIDsFromDB(supabase)
	var sentMessages = 0
	var gotUsers = len(userIDs)
	if err != nil {
		return gotUsers, sentMessages, fmt.Errorf("Error fetching user IDs from the database:", err)
	}
	// Create a channel to communicate errors back to the main Goroutine
	errChan := make(chan error)

	// Create an atomic flag to indicate if an error occurred
	var hasError int32 // 0 means no error, 1 means error occurred

	// Create a WaitGroup to wait for all Goroutines to finish
	var wg sync.WaitGroup
	// Iterate over user IDs and send notifications in separate Goroutines
	for _, userID := range userIDs {
		time.Sleep(40 * time.Millisecond)
		if atomic.LoadInt32(&hasError) == 1 {
			break // Stop launching new Goroutines
		}
		wg.Add(1) // Increment WaitGroup counter for each Goroutine

		go func(userID int64) {
			defer wg.Done() // Decrement WaitGroup counter when Goroutine exits
			// Send notification to user with the current userID
			err := sendPhotoNotificationToUser(bot, userID, message, url, opts...)
			if err != nil {
				if strings.Contains(err.Error(), "chat not found") {
					errChan <- err
				} else if strings.Contains(err.Error(), "blocked by the user") {
					errChan <- err
				} else if strings.Contains(err.Error(), "user is deactivated") {
					errChan <- err
				} else if strings.Contains(err.Error(), "telegram: retry after 60") {
					errChan <- err
				} else {
					//atomic.StoreInt32(&hasError, 1)
					errChan <- err // Send error to the error channel
				}

			} else {
				sentMessages++
			}
		}(userID)

	}

	// Close the error channel after all Goroutines finish
	go func() {
		wg.Wait()
		close(errChan)
	}()

	// Listen for errors from the error channel
	var errors []error
	var chatCounter = 0
	var blockedCounter = 0
	var deactivatedCounter = 0
	var tgLimitCounter = 0
	for err := range errChan {
		if strings.Contains(err.Error(), "chat not found") {
			chatCounter++
		} else if strings.Contains(err.Error(), "blocked by the user") {
			blockedCounter++
		} else if strings.Contains(err.Error(), "user is deactivated") {
			deactivatedCounter++
		} else if strings.Contains(err.Error(), "telegram: retry after 60") {
			tgLimitCounter++
		} else {
			errors = append(errors, err)
		}
	}
	errors = append(errors, fmt.Errorf("Telegram users not found - %v", chatCounter))
	errors = append(errors, fmt.Errorf("\nTelegram users who blocked bot - %v", blockedCounter))
	errors = append(errors, fmt.Errorf("\nDeactivated telegram users - %v", deactivatedCounter))
	errors = append(errors, fmt.Errorf("\nTelegram throttled, messages not send to telegram users - %v", tgLimitCounter))

	// Check if any errors occurred
	if len(errors) > 0 {
		errStr := ""
		for _, err := range errors {
			errStr += err.Error() + "\n\n"
		}
		return gotUsers, sentMessages, fmt.Errorf("\n%v\n", errStr)
	}
	return gotUsers, sentMessages, nil
}

// SendTextNotifications sendNotifications fetches user IDs from the database and sends notifications to each user concurrently using Goroutines.
func SendTextNotifications(bot *tele.Bot, supabase *supa.Client, message string, opts ...interface{}) (int, int, error) {

	// Fetch user IDs from the database
	userIDs, err := getUserIDsFromDB(supabase)
	var sentMessages int = 0
	var gotUsers = len(userIDs)
	if err != nil {
		return gotUsers, sentMessages, fmt.Errorf("Error fetching user IDs from the database:", err)
	}

	// Create a channel to communicate errors back to the main Goroutine
	errChan := make(chan error)

	// Create an atomic flag to indicate if an error occurred
	var hasError int32 // 0 means no error, 1 means error occurred

	// Create a WaitGroup to wait for all Goroutines to finish
	var wg sync.WaitGroup

	// Iterate over user IDs and send notifications in separate Goroutines
	for _, userID := range userIDs {
		time.Sleep(40 * time.Millisecond)
		if atomic.LoadInt32(&hasError) == 1 {
			break // Stop launching new Goroutines
		}
		wg.Add(1) // Increment WaitGroup counter for each Goroutine

		go func(userID int64) {
			defer wg.Done() // Decrement WaitGroup counter when Goroutine exits
			// Send notification to user with the current userID
			err := sendTextNotificationToUser(bot, userID, message, opts...)
			if err != nil {
				if strings.Contains(err.Error(), "chat not found") {
					errChan <- err
				} else if strings.Contains(err.Error(), "blocked by the user") {
					errChan <- err
				} else if strings.Contains(err.Error(), "user is deactivated") {
					errChan <- err
				} else if strings.Contains(err.Error(), "telegram: retry after 60") {
					errChan <- err
				} else {
					//atomic.StoreInt32(&hasError, 1)
					errChan <- err // Send error to the error channel
				}

			} else {
				sentMessages++
			}
		}(userID)

	}

	// Close the error channel after all Goroutines finish
	go func() {
		wg.Wait()
		close(errChan)
	}()

	// Listen for errors from the error channel
	var errors []error
	var chatCounter = 0
	var blockedCounter = 0
	var deactivatedCounter = 0
	var tgLimitCounter = 0
	for err := range errChan {
		fmt.Println(err)
		if strings.Contains(err.Error(), "chat not found") {
			chatCounter++
		} else if strings.Contains(err.Error(), "blocked by the user") {
			blockedCounter++
		} else if strings.Contains(err.Error(), "user is deactivated") {
			deactivatedCounter++
		} else if strings.Contains(err.Error(), "telegram: retry after 60") {
			tgLimitCounter++
		} else {
			errors = append(errors, err)
		}
	}
	errors = append(errors, fmt.Errorf("Telegram users not found - %v", chatCounter))
	errors = append(errors, fmt.Errorf("\nTelegram users who blocked bot - %v", blockedCounter))
	errors = append(errors, fmt.Errorf("\nDeactivated telegram users - %v", deactivatedCounter))
	errors = append(errors, fmt.Errorf("\nTelegram throttled, messages not send to telegram users - %v", tgLimitCounter))
	// Check if any errors occurred
	if len(errors) > 0 {
		errStr := ""
		for _, err := range errors {
			errStr += err.Error() + "\n\n"
		}
		return gotUsers, sentMessages, fmt.Errorf("\n%v\n", errStr)
	}
	return gotUsers, sentMessages, nil
}

// UserIDResponse Define a struct to match the structure of the response objects
type UserIDResponse struct {
	TgID int64 `json:"tg_id"`
}

// getUserIDsFromDB fetches user IDs from the database.
func getUserIDsFromDB(supabase *supa.Client) ([]int64, error) {
	ctx := context.Background()
	// Query the database to fetch tg_id values from the users table
	// Execute the query
	var resp []UserIDResponse
	err := supabase.DB.From("users_to_notify").Select("tg_id").ExecuteWithContext(ctx, &resp)
	if err != nil {
		log.Println("Error fetching user IDs from the database:", err)
		return nil, err
	}
	// Extract tg_id values from the response
	var tgIDs []int64
	for _, userID := range resp {
		tgIDs = append(tgIDs, userID.TgID)
	}

	return tgIDs, nil
}

// sendNotificationToUser sends a notification to a user identified by their Telegram ID.
func sendPhotoNotificationToUser(bot *tele.Bot, userID int64, message string, url string, opts ...interface{}) error {
	// Send the notification to the user using the Telegram bot API

	a := &tele.Photo{File: tele.FromURL(url),
		Caption: message}
	_, err := bot.Send(&tele.User{ID: userID}, a, opts...)
	return err
}
func sendTextNotificationToUser(bot *tele.Bot, userID int64, message string, opts ...interface{}) error {
	// Send the notification to the user using the Telegram bot API

	_, err := bot.Send(&tele.User{ID: userID}, message, opts...)
	return err
}
