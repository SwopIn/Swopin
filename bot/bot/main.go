package main

import (
	"context"
	"fmt"
	notifications "github.com/AlexAntonik/Swopin/bot/notification"
	"github.com/AlexAntonik/Swopin/bot/server"
	"log"
	"strconv"
	"strings"
	"time"

	"github.com/AlexAntonik/Swopin/bot/config"
	supa "github.com/nedpals/supabase-go"
	tele "gopkg.in/telebot.v3"
)

// NFTData contains NFT data
type NFTData struct {
	ID          int64               `json:"id,omitempty"`
	CreatedAt   time.Time           `json:"created_at,omitempty"`
	Name        string              `json:"name,omitempty"`
	Description string              `json:"desc,omitempty"`
	Image       string              `json:"image,omitempty"`
	Collection  string              `json:"collection,omitempty"`
	NFTAddress  string              `json:"nft_address,omitempty"`
	ColAddress  string              `json:"col_address,omitempty"`
	Price       string              `json:"price,omitempty"`
	Attributes  []map[string]string `json:"attributes,omitempty"`
}

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
	baseReplyButtons := &tele.ReplyMarkup{ResizeKeyboard: true}
	appButtons := &tele.ReplyMarkup{ResizeKeyboard: false}
	communityButtons := &tele.ReplyMarkup{ResizeKeyboard: false}
	startAppButtons := &tele.ReplyMarkup{ResizeKeyboard: false}

	communityBtn := baseReplyButtons.URL(cfg.Messages.CommunityButton, cfg.CommunityURL)
	communityChatBtn := baseReplyButtons.URL(cfg.Messages.ChatButton, cfg.ChatURL)
	startApp := baseReplyButtons.WebApp(cfg.Messages.AppButton, webApp)

	appButtons.Inline(baseReplyButtons.Row(startApp))
	startAppButtons.Inline(baseReplyButtons.Row(communityBtn), baseReplyButtons.Row(startApp))
	communityButtons.Inline(baseReplyButtons.Row(communityBtn), baseReplyButtons.Row(communityChatBtn))

	return appButtons, communityButtons, startAppButtons
}

// getNFTDataFromSupabase returns NFT data from Supabase
func getNFTDataFromSupabase(queryText string, supa *supa.Client) ([]NFTData, error) {
	var nfts []NFTData

	err := supa.DB.From("nft_data").Select("*").Eq("nft_address", queryText).Execute(&nfts)

	if err != nil {
		return nil, err
	}

	return nfts, nil
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

	// Initialize api server
	go server.StartServer(cfg, supabase, bot)

	// Initialize web app URL for buttons
	webApp := tele.WebApp{URL: cfg.TWAIP}

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

	// Handle /update_ref command
	bot.Handle("/update_ref", func(c tele.Context) error {
		if Contains(cfg.ADMINS, c.Sender().ID) {
			updatedRefs, err := UpdateRef(supabase)
			if err != nil {
				return c.Send(err.Error())
			}
			return c.Send(updatedRefs)
		}
		return nil
	})

	// Handle /func command
	bot.Handle("/func", func(c tele.Context) error {
		if Contains(cfg.ADMINS, c.Sender().ID) {
			err := CallFunc(supabase, c.Message().Payload)
			if err != nil {
				return c.Send(err.Error())
			}
			return c.Send(fmt.Sprintf("%v - called", c.Message().Payload))
		}
		return nil
	})

	// Set up the "/notify_prev" command handler
	bot.Handle("/notify_prev", func(c tele.Context) error {
		if Contains(cfg.ADMINS, c.Sender().ID) {
			var app *tele.ReplyMarkup = nil
			var url string = ""
			var message string
			var serviceMessage string
			if strings.Contains(c.Message().Payload, "||") {
				parts := strings.SplitN(c.Message().Payload, "||", 2)
				if len(parts) >= 2 {
					serviceMessage = strings.TrimSpace(parts[0])
					message = strings.TrimSpace(parts[1])
					if strings.Contains(serviceMessage, "-button_app") {
						app = appButtons
					}
					if strings.Contains(serviceMessage, "photoURL(") {
						parts := strings.SplitN(serviceMessage, "photoURL(", 2)
						if len(parts) >= 2 {
							parts := strings.SplitN(strings.TrimSpace(parts[1]), ")", 2)
							if len(parts) >= 2 {
								url = strings.TrimSpace(parts[0])
							}
						}
					}
					switch {
					case url != "" && app != nil:
						return c.Send(&tele.Photo{File: tele.FromURL(url),
							Caption: message}, app)
					case url != "":
						return c.Send(&tele.Photo{File: tele.FromURL(url),
							Caption: message})
					case app != nil:
						return c.Send(message, app)
					default:
						return c.Send(message)
					}
				}
			} else {
				return c.Send(c.Message().Payload)
			}

		}
		return nil
	})
	bot.Handle(tele.OnWriteAccessAllowed, func(c tele.Context) error {
		return c.Send(cfg.Messages.StartPreName+c.Sender().FirstName+cfg.Messages.StartAfterName,
			startButtons)
	})
	//Handle channel posts for adding buttons
	bot.Handle(tele.OnChannelPost, func(c tele.Context) error {
		baseReplyButtons := &tele.ReplyMarkup{ResizeKeyboard: true}
		replyButtons := &tele.ReplyMarkup{ResizeKeyboard: false}

		var messageText string

		// Check if the message contains a photo with a caption or just text
		if c.Message().Photo != nil {
			messageText = c.Message().Caption
		} else {
			messageText = c.Message().Text
		}

		// Check for the presence of "||" in the message
		if !strings.Contains(messageText, "||") {
			return nil // Skip the handler if "||" is not found
		}

		// Split the message text into lines
		messageLines := strings.Split(messageText, "\n")

		// New message text without button parameters
		var newTextLines []string

		// Slice to store buttons
		var buttons []tele.Row

		// Iterate over lines and create buttons
		for _, line := range messageLines {
			parts := strings.SplitN(line, "||", 2)
			if len(parts) == 2 {
				btnText := strings.TrimSpace(parts[0])
				btnURL := strings.TrimSpace(parts[1])
				button := baseReplyButtons.URL(btnText, btnURL)
				buttons = append(buttons, baseReplyButtons.Row(button))
			} else {
				newTextLines = append(newTextLines, line)
			}
		}

		// Join the lines into new message text
		newText := strings.Join(newTextLines, "\n")

		// Set all buttons
		replyButtons.Inline(buttons...)

		// Edit the message, adding buttons and updating the text
		if c.Message().Photo != nil {
			// If the message contains a photo, edit it with the new text and buttons
			_, err := bot.Edit(c.Message(), &tele.Photo{Caption: newText, File: c.Message().Photo.File}, replyButtons)
			if err != nil {
				log.Println(err)
			}
		} else {
			// If the message is only text, edit the text and add buttons
			_, err := bot.Edit(c.Message(), newText, c.Message(), replyButtons)
			if err != nil {
				log.Println(err)
			}
		}

		return nil
	})

	// Set up the "/notify" command handler
	bot.Handle("/notify", func(c tele.Context) error {
		if Contains(cfg.ADMINS, c.Sender().ID) {
			var app *tele.ReplyMarkup = nil
			var url = ""
			var message string
			var serviceMessage string
			if strings.Contains(c.Message().Payload, "||") {
				parts := strings.SplitN(c.Message().Payload, "||", 2)
				if len(parts) >= 2 {
					serviceMessage = strings.TrimSpace(parts[0])
					message = strings.TrimSpace(parts[1])
					if strings.Contains(serviceMessage, "-button_app") {
						app = appButtons
					}
					if strings.Contains(serviceMessage, "photoURL(") {
						parts := strings.SplitN(serviceMessage, "photoURL(", 2)
						if len(parts) >= 2 {
							parts := strings.SplitN(strings.TrimSpace(parts[1]), ")", 2)
							if len(parts) >= 2 {
								url = strings.TrimSpace(parts[0])
							}
						}
					}
					switch {
					case url != "" && app != nil:
						gotUsers, sentMessages, err := notifications.SendPhotoNotifications(bot, supabase, message, url, app)
						return c.Send(NotificationResult(gotUsers, sentMessages, err))

					case url != "":
						gotUsers, sentMessages, err := notifications.SendPhotoNotifications(bot, supabase, message, url)
						return c.Send(NotificationResult(gotUsers, sentMessages, err))
					case app != nil:
						gotUsers, sentMessages, err := notifications.SendTextNotifications(bot, supabase, message, app)
						return c.Send(NotificationResult(gotUsers, sentMessages, err))
					default:
						gotUsers, sentMessages, err := notifications.SendTextNotifications(bot, supabase, message)
						return c.Send(NotificationResult(gotUsers, sentMessages, err))
					}
				}
			} else {
				gotUsers, sentMessages, err := notifications.SendTextNotifications(bot, supabase, c.Message().Payload)
				return c.Send(NotificationResult(gotUsers, sentMessages, err))
			}
		}
		return nil
	})

	// Handle /start command
	bot.Handle("/start", func(c tele.Context) error {
		params := make(map[string]interface{})
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

	// Handle /beta command
	bot.Handle("/beta", func(c tele.Context) error {
		// Получаем Telegram ID пользователя
		//tgID := c.Sender().ID
		//
		//type BTester struct {
		//	TelegramID int64 `json:"tg_id"`
		//}
		//
		// Записываем user_id в таблицу b_testers
		//tester := BTester{TelegramID: tgID}
		//err = supabase.DB.From("b_testers").Insert(tester).ExecuteWithContext(ctx, nil)
		//if err != nil {
		//	log.Println("Error inserting into b_testers:", err)
		//	if strings.Contains(err.Error(), "duplicate key value violates unique constraint \"b_testers_pkey\"") {
		//		supabase.DB.From("b_testers").Delete().Eq("tg_id", strconv.FormatInt(tgID, 10)).ExecuteWithContext(ctx, nil)
		//		return c.Send("You have already been added to the beta testers. Removing you from the testers list.")
		//	}
		//	return c.Send("An error occurred while adding you to the beta testers.")
		//}
		//
		//return c.Send(&tele.Photo{
		//	File:    tele.FromURL("https://framerusercontent.com/images/Csc0qjXRWqlnkKQ34jtyO3bardw.jpeg"),
		//	Caption: "You have been successfully added to the beta testers!",
		//})
		return c.Send("Sorry, but this beta access is now closed. Please contact @swopin_staff for more information.")
	})

	bot.Handle(tele.OnQuery, func(c tele.Context) error {
		queryButtons := &tele.ReplyMarkup{ResizeKeyboard: true}
		queryBtn := queryButtons.URL("Buy NFT in SwopIn", cfg.TwaLink+"?startapp="+c.Query().Text)
		queryButtons.Inline(queryButtons.Row(queryBtn))

		// Get NFT data from Supabase
		nftData, err := getNFTDataFromSupabase(c.Query().Text, supabase)
		if err != nil {
			log.Println(err)
		}
		results := make(tele.Results, len(nftData))
		log.Println(nftData)
		if len(nftData) != 0 {
			results = make(tele.Results, len(nftData))
			for i, nft := range nftData {
				nftTitle := ""
				if nft.Collection != "" {
					nftTitle = "<strong>Collection:</strong>  " + nft.Collection + "\n" + "<strong>NFT:</strong> " + nft.Name + "\n"
				} else {
					nftTitle = "<strong>NFT:</strong>  " + nft.Name + "\n"
				}
				responseText := nftTitle + "<strong>Price: </strong> <u>" + nft.Price + " TON</u>\n"
				if len(nft.Attributes) > 0 {
					responseText += "<strong>Attributes:</strong> \n"
					for _, attr := range nft.Attributes {
						responseText += "<b>" + attr["trait_type"] + ": " + "</b>" + attr["value"] + "\n"
					}
				}
				result := &tele.PhotoResult{
					URL:      nft.Image,
					Caption:  responseText,
					ThumbURL: nft.Image,
					Width:    256,
					Height:   256,
				}

				log.Println("Attrs:" + strconv.Itoa(len(nft.Attributes)))
				results[i] = result
				// needed to set a unique string ID for each result
				results[i].SetResultID(strconv.Itoa(i))
				results[i].SetReplyMarkup(queryButtons)
				results[i].SetParseMode("HTML")
			}
		}
		log.Println("Results:" + strconv.Itoa(len(results)))
		return c.Answer(&tele.QueryResponse{
			Results:   results,
			CacheTime: 60, // 1 minute
		})
	})

	// Start the bot
	bot.Start()
}
