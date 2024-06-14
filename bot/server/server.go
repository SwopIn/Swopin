package server

import (
	"context"
	"fmt"
	"github.com/go-chi/chi/v5/middleware"
	"log"
	"net/http"
	"strconv"

	"github.com/AlexAntonik/Swopin/bot/config"
	"github.com/go-chi/chi/v5"
	supa "github.com/nedpals/supabase-go"
	tele "gopkg.in/telebot.v3"
)

// StartServer starts the server with the given configuration, Supabase client, and Telegram bot.
//
// Parameters:
// - cfg: Configuration.
// - supabase: Supabase client.
// - bot: Telegram bot.
//
// Return:
// None.
func StartServer(cfg *config.Config, supabase *supa.Client, bot *tele.Bot) {
	router := chi.NewRouter()
	router.Use(middleware.Logger)
	router.Use(middleware.Recoverer)

	setupRoutes(router, cfg, supabase, bot)

	log.Println("Starting server on :23334")
	log.Fatal(http.ListenAndServe(":23334", router))
}
func setupRoutes(router *chi.Mux, cfg *config.Config, supabase *supa.Client, bot *tele.Bot) {
	router.Post("/api/send_message", func(w http.ResponseWriter, r *http.Request) {
		telegramID := r.URL.Query().Get("tg_id")
		uuid := r.URL.Query().Get("uuid")
		message := r.URL.Query().Get("message")

		if telegramID == "" || uuid == "" {
			http.Error(w, "Missing tg_id or uuid", http.StatusBadRequest)
			return
		}

		tgID, err := strconv.ParseInt(telegramID, 10, 64)
		if err != nil {
			http.Error(w, "Invalid tg_id", http.StatusBadRequest)
			return
		}

		ctx := context.Background()
		if !validateUser(ctx, supabase, tgID, uuid) {
			http.Error(w, "Invalid user auth", http.StatusUnauthorized)
			return
		}

		if _, err := bot.Send(&tele.User{ID: tgID}, message); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "Message sent successfully")
	})
	router.Get("/api/check_group_membership", func(w http.ResponseWriter, r *http.Request) {
		telegramID := r.URL.Query().Get("tg_id")
		uuid := r.URL.Query().Get("uuid")
		groupID := r.URL.Query().Get("group_id")

		if telegramID == "" || uuid == "" || groupID == "" {
			http.Error(w, "Missing tg_id, uuid, or group_id", http.StatusBadRequest)
			return
		}
		channelID, err := strconv.ParseInt(groupID, 10, 64)
		if err != nil {
			http.Error(w, "Invalid group_id", http.StatusBadRequest)
			return
		}
		tgID, err := strconv.ParseInt(telegramID, 10, 64)
		if err != nil {
			http.Error(w, "Invalid tg_id", http.StatusBadRequest)
			return
		}

		ctx := context.Background()
		if !validateUser(ctx, supabase, tgID, uuid) {
			http.Error(w, "Invalid user auth", http.StatusUnauthorized)
			return
		}

		isMember, err := checkGroupMembership(bot, tgID, channelID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		if !isMember {
			w.WriteHeader(http.StatusOK)
			fmt.Fprintln(w, "false")
			return
		}

		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "true")
	})

	router.Get("/api/check_group_boost", func(w http.ResponseWriter, r *http.Request) {
		telegramID := r.URL.Query().Get("tg_id")
		uuid := r.URL.Query().Get("uuid")
		groupID := r.URL.Query().Get("group_id")

		if telegramID == "" || uuid == "" || groupID == "" {
			http.Error(w, "Missing tg_id, uuid, or group_id", http.StatusBadRequest)
			return
		}
		chatId, err := strconv.ParseInt(groupID, 10, 64)
		if err != nil {
			http.Error(w, "Invalid group_id", http.StatusBadRequest)
			return
		}
		tgID, err := strconv.ParseInt(telegramID, 10, 64)
		if err != nil {
			http.Error(w, "Invalid tg_id", http.StatusBadRequest)
			return
		}

		ctx := context.Background()
		if !validateUser(ctx, supabase, tgID, uuid) {
			http.Error(w, "Invalid user auth", http.StatusUnauthorized)
			return
		}

		boosts, err := checkGroupBoost(bot, tgID, chatId)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, strconv.Itoa(boosts))
	})
}

// checkGroupMembership checks if a user is a member of a given group.
func checkGroupMembership(bot *tele.Bot, tgID int64, groupID int64) (bool, error) {
	chat, err := bot.ChatByID(groupID)
	if err != nil {
		return false, err
	}

	member, err := bot.ChatMemberOf(chat, &tele.User{ID: tgID})
	if err != nil {
		return false, err
	}

	return member != nil && member.Role != tele.Left, nil
}

// checkGroupBoost checks if a user has boosted a specific group.
func checkGroupBoost(bot *tele.Bot, tgID int64, chatID int64) (int, error) {
	boosts, err := bot.UserBoosts(&tele.Chat{ID: chatID}, &tele.User{ID: tgID})

	boostsToString := ""
	for _, boost := range boosts {
		boostsToString += "Boost id:" + fmt.Sprint(boost.ID) + "\n"
		boostsToString += "Boost source:" + fmt.Sprint(boost.Source) + "\n"
		boostsToString += "Boost addUnixtime:" + fmt.Sprint(boost.AddDate()) + "\n"
		boostsToString += "Boost expirationDate:" + fmt.Sprint(boost.ExpirationDate()) + "\n\n"
	}
	log.Println(boostsToString)
	if err != nil {
		log.Println(err)
	}
	if err != nil {
		log.Println("Error fetching boost data:", err)
		return 0, err
	}

	return len(boosts), nil
}
func validateUser(ctx context.Context, supabase *supa.Client, tgID int64, uuid string) bool {
	var users []struct {
		TelegramID int    `json:"tg_id"`
		UUID       string `json:"id"`
	}

	err := supabase.DB.From("users").Select("*").Eq("tg_id",
		strconv.FormatInt(tgID, 10)).Eq("id", uuid).ExecuteWithContext(ctx, &users)
	if err != nil {
		log.Println("Error fetching user:", err)
		return false
	}

	return len(users) > 0
}
