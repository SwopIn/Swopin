package main

import (
	"context"
	"fmt"
	notifications "github.com/AlexAntonik/Swopin/bot/notification"
	"log"
	"strconv"
	"strings"
	"time"

	"github.com/AlexAntonik/Swopin/bot/config"
	supa "github.com/nedpals/supabase-go"
	tele "gopkg.in/telebot.v3"
)

// init initializes environment variables (only for local test)
//func init() {
//	envis.Init_env()
//}

// initSupabase initializes Supabase client
func initSupabase(cfg *config.Config) *supa.Client {
	supabase := supa.CreateClient(cfg.DBIP, cfg.DBAPIKey)
	return supabase
}

// initBot initializes Telegram bot
func initBot(cfg *config.Config) (*tele.Bot, error) {
	pref := tele.Settings{
		Token:  cfg.TelegramToken,
		Poller: &tele.LongPoller{Timeout: 1 * time.Second},
	}
	bot, err := tele.NewBot(pref)
	if err != nil {
		return nil, err
	}
	return bot, nil
}

// buildButtons creates and configures reply markup buttons
func buildButtons(cfg *config.Config, webApp *tele.WebApp) (*tele.ReplyMarkup, *tele.ReplyMarkup, *tele.ReplyMarkup) {
	appButtons := &tele.ReplyMarkup{ResizeKeyboard: false}
	communityButtons := &tele.ReplyMarkup{ResizeKeyboard: false}
	startButtons := &tele.ReplyMarkup{ResizeKeyboard: false}

	communityBtn := startButtons.URL(cfg.Messages.CommunityButton, cfg.CommunityURL)
	communityChatBtn := startButtons.URL(cfg.Messages.ChatButton, cfg.ChatURL)
	startApp := startButtons.WebApp(cfg.Messages.AppButton, webApp)

	appButtons.Inline(startButtons.Row(startApp))
	startButtons.Inline(startButtons.Row(communityBtn), startButtons.Row(startApp))
	communityButtons.Inline(startButtons.Row(communityBtn), startButtons.Row(communityChatBtn))

	return appButtons, communityButtons, startButtons
}

func main() {
	// Load configuration
	cfg, err := config.Init()
	if err != nil {
		log.Fatal(err)
		return
	}

	// Initialize Supabase client
	supabase := initSupabase(cfg)
	ctx := context.Background()

	// Initialize Telegram bot
	bot, err := initBot(cfg)
	if err != nil {
		log.Fatal(err)
		return
	}

	// Initialize web app URL for buttons
	webApp := tele.WebApp{URL: cfg.WebAppURL}

	// Build reply markup buttons
	appButtons, communityButtons, startButtons := buildButtons(cfg, &webApp)

	// Handle /app command
	bot.Handle("/app", func(c tele.Context) error {
		return c.Send(cfg.Messages.App, appButtons)
	})

	// Handle /community command
	bot.Handle("/community", func(c tele.Context) error {
		return c.Send(cfg.Messages.Community, communityButtons)
	})

	// Set up the "/notify" command handler
	bot.Handle("/notify", func(c tele.Context) error {
		if contains(cfg.ADMINS, c.Sender().ID) {
			if strings.Contains(c.Message().Payload, "photoURL((") {
				// Split the message into substrings based on "))" separator
				message := strings.TrimPrefix(c.Message().Payload, "photoURL((")
				parts := strings.SplitN(message, "))", 2)

				// Check if there are at least two parts
				if len(parts) >= 2 {
					// Trim the first chunk of the message after "))" separator
					url := strings.TrimSpace(parts[0])
					trimmedMessage := strings.TrimSpace(parts[1])
					notifications.SendPhotoNotifications(bot, supabase, trimmedMessage, url)
				} else {
					log.Println("No separator found in the message")
				}

			} else {
				notifications.SendTextNotifications(bot, supabase, c.Message().Payload)
			}
			// Send the notification to all users
			return c.Send("message send")
		}
		return nil
	})

	// Handle /start command
	params := make(map[string]interface{})
	bot.Handle("/start", func(c tele.Context) error {
		if strings.Contains(c.Message().Text, "invite") {
			return c.Send(cfg.Messages.Invite+
				"\nhttps://t.me/swopin_bot?start=ref_"+fmt.Sprint(c.Sender().ID), appButtons)
		}
		if strings.Contains(c.Message().Text, "ref_") {

			params["tg_user_id"] = c.Sender().ID
			params["tg_chat_id"] = c.Chat().ID
			parsedInt, err := strconv.ParseInt(strings.TrimPrefix(c.Message().Text, "/start ref_"), 10, 64)
			params["tg_referrer_id"] = parsedInt
			go func() {
				err = supabase.DB.Rpc("init_new_user", params).ExecuteWithContext(ctx, nil)
				if err != nil {
					fmt.Println(err)
				}
			}()
			return c.Send(cfg.Messages.StartPreName+c.Sender().FirstName+cfg.Messages.StartAfterName,
				startButtons)
		}
		params["tg_user_id"] = c.Sender().ID
		params["tg_chat_id"] = c.Chat().ID
		params["tg_referrer_id"] = nil
		go func() {
			err = supabase.DB.Rpc("init_new_user", params).ExecuteWithContext(ctx, nil)
			if err != nil {
				fmt.Println(err)
			}
		}()
		return c.Send(cfg.Messages.StartPreName+c.Sender().FirstName+cfg.Messages.StartAfterName,
			startButtons)
	})

	// Handle /invite command
	bot.Handle("/invite", func(c tele.Context) error {
		return c.Send(cfg.Messages.Invite+
			"\nhttps://t.me/swopin_bot?start=ref_"+fmt.Sprint(c.Sender().ID), appButtons)
	})

	// Start the bot
	bot.Start()
}
