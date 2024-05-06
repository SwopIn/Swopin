package notifications

import (
	"context"
	supa "github.com/nedpals/supabase-go"
	tele "gopkg.in/telebot.v3"
	"log"
	"sync"
)

// sendNotifications fetches user IDs from the database and sends notifications to each user concurrently using Goroutines.
func SendPhotoNotifications(bot *tele.Bot, supabase *supa.Client, message string, url string) {

	// Fetch user IDs from the database
	userIDs, err := getUserIDsFromDB(supabase)
	if err != nil {
		log.Println("Error fetching user IDs from the database:", err)
		return
	}

	// Create a channel to communicate errors back to the main Goroutine
	errChan := make(chan error)

	// Create a WaitGroup to wait for all Goroutines to finish
	var wg sync.WaitGroup

	// Iterate over user IDs and send notifications in separate Goroutines
	for _, userID := range userIDs {
		wg.Add(1) // Increment WaitGroup counter for each Goroutine

		go func(userID int64) {
			defer wg.Done() // Decrement WaitGroup counter when Goroutine exits

			// Send notification to user with the current userID
			err := sendPhotoNotificationToUser(bot, userID, message, url)
			if err != nil {
				errChan <- err // Send error to the error channel
			}
		}(userID)
	}

	// Close the error channel after all Goroutines finish
	go func() {
		wg.Wait()
		close(errChan)
	}()

	// Listen for errors from the error channel
	for err := range errChan {
		log.Println("Error sending notification:", err)
	}
}

// sendNotifications fetches user IDs from the database and sends notifications to each user concurrently using Goroutines.
func SendTextNotifications(bot *tele.Bot, supabase *supa.Client, message string) {

	// Fetch user IDs from the database
	userIDs, err := getUserIDsFromDB(supabase)
	if err != nil {
		log.Println("Error fetching user IDs from the database:", err)
		return
	}

	// Create a channel to communicate errors back to the main Goroutine
	errChan := make(chan error)

	// Create a WaitGroup to wait for all Goroutines to finish
	var wg sync.WaitGroup

	// Iterate over user IDs and send notifications in separate Goroutines
	for _, userID := range userIDs {
		wg.Add(1) // Increment WaitGroup counter for each Goroutine

		go func(userID int64) {
			defer wg.Done() // Decrement WaitGroup counter when Goroutine exits

			// Send notification to user with the current userID
			err := sendTextNotificationToUser(bot, userID, message)
			if err != nil {
				errChan <- err // Send error to the error channel
			}
		}(userID)
	}

	// Close the error channel after all Goroutines finish
	go func() {
		wg.Wait()
		close(errChan)
	}()

	// Listen for errors from the error channel
	for err := range errChan {
		log.Println("Error sending notification:", err)
	}
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
	err := supabase.DB.From("users").Select("tg_id").ExecuteWithContext(ctx, &resp)
	if err != nil {
		log.Println("Error fetching user IDs from the database:", err)
		return nil, err
	}
	println(resp[0].TgID)
	// Extract tg_id values from the response
	var tgIDs []int64
	for _, userID := range resp {
		tgIDs = append(tgIDs, userID.TgID)
	}

	return tgIDs, nil
}

// sendNotificationToUser sends a notification to a user identified by their Telegram ID.
func sendPhotoNotificationToUser(bot *tele.Bot, userID int64, message string, url string) error {
	// Send the notification to the user using the Telegram bot API

	a := &tele.Photo{File: tele.FromURL(url),
		Caption: message}
	_, err := bot.Send(&tele.User{ID: userID}, a)
	return err
}
func sendTextNotificationToUser(bot *tele.Bot, userID int64, message string) error {
	// Send the notification to the user using the Telegram bot API

	_, err := bot.Send(&tele.User{ID: userID}, message)
	return err
}
