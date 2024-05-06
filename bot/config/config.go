package config

import (
	"github.com/spf13/viper"
	"strconv"
	"strings"
)

// Config holds configuration parameters for the application.
type Config struct {
	TelegramToken string
	DBAPIKey      string  `mapstructure:"db_apikey"`
	DBIP          string  `mapstructure:"db_ip"`
	TWAIP         string  `mapstructure:"twa_ip"`
	ADMINS        []int64 `mapstructure:"admins"`

	CommunityURL string `mapstructure:"community_url"`
	ChatURL      string `mapstructure:"chat_url"`
	WebAppURL    string `mapstructure:"web_app_url"`

	Messages Messages
}

// Messages holds message templates used by the application.
type Messages struct {
	Invite          string `mapstructure:"invite"`
	StartPreName    string `mapstructure:"start_pre_name"`
	StartAfterName  string `mapstructure:"start_after_name"`
	Community       string `mapstructure:"community"`
	App             string `mapstructure:"app"`
	CommunityButton string `mapstructure:"community_button"`
	ChatButton      string `mapstructure:"chat_button"`
	AppButton       string `mapstructure:"app_button"`
}

// Init initializes the application configuration.
func Init() (*Config, error) {
	if err := setUpViper(); err != nil {
		return nil, err
	}

	var cfg Config
	if err := unmarshal(&cfg); err != nil {
		return nil, err
	}

	if err := fromEnv(&cfg); err != nil {
		return nil, err
	}

	return &cfg, nil
}

// unmarshal reads configuration data from the loaded config file and maps it to the Config struct.
func unmarshal(cfg *Config) error {
	if err := viper.Unmarshal(&cfg); err != nil {
		return err
	}

	if err := viper.UnmarshalKey("messages", &cfg.Messages); err != nil {
		return err
	}

	return nil
}

// fromEnv reads configuration values from environment variables and assigns them to the Config struct.
func fromEnv(cfg *Config) error {
	if err := viper.BindEnv("token"); err != nil {
		return err
	}
	cfg.TelegramToken = viper.GetString("token")

	if err := viper.BindEnv("db_apikey"); err != nil {
		return err
	}
	cfg.DBAPIKey = viper.GetString("db_apikey")

	if err := viper.BindEnv("db_ip"); err != nil {
		return err
	}
	cfg.DBIP = viper.GetString("db_ip")

	if err := viper.BindEnv("twa_ip"); err != nil {
		return err
	}
	cfg.TWAIP = viper.GetString("twa_ip")

	if err := viper.BindEnv("admins"); err != nil {
		return err
	}

	// Convert string to int64 slice
	cfg.ADMINS = mapStringToInt64(strings.FieldsFunc(viper.GetString("admins"), func(r rune) bool {
		return r == ','
	}))

	return nil
}

// setUpViper configures the Viper instance to read configuration from a file.
func setUpViper() error {
	viper.AddConfigPath("config")
	viper.SetConfigName("main")

	return viper.ReadInConfig()
}

// mapStringToInt64 converts a slice of strings to a slice of int64
func mapStringToInt64(strArr []string) []int64 {
	intArr := make([]int64, len(strArr))
	for i, str := range strArr {
		intArr[i], _ = strconv.ParseInt(str, 10, 64)
	}
	return intArr
}
