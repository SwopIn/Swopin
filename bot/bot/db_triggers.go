package main

import (
	"context"
	"fmt"
	supa "github.com/nedpals/supabase-go"
	"strings"
)

// CallFunc launches arbitrary database rpc func with name - rpc_name.
func CallFunc(supabase *supa.Client, rpc_name string) error {
	ctx := context.Background()

	params := make(map[string]interface{})

	err := supabase.DB.Rpc(rpc_name, params).ExecuteWithContext(ctx, nil)
	if err != nil {
		return fmt.Errorf("Error calling rpc: %v", err)
	}
	return nil
}

// UpdateRef launches refresh_chart database rpc func.
func UpdateRef(supabase *supa.Client) (string, error) {
	ctx := context.Background()

	// Parameters for the data refresh request
	params := make(map[string]interface{})

	var resp []UserUpdateResponse

	// Executing the stored procedure for data refresh
	err := supabase.DB.Rpc("refresh_chart", params).ExecuteWithContext(ctx, nil)
	if err != nil {
		return "", fmt.Errorf("Error refreshing data:", err)
	}

	// Retrieving updated data from the database
	err = supabase.DB.From("top_refs").Select("tg_id", "ref_count").ExecuteWithContext(ctx, &resp)
	if err != nil {
		return "", fmt.Errorf("Error fetching user IDs from the database:", err)
	}

	// Formatting the updated data for sending
	var result strings.Builder
	for _, response := range resp {
		result.WriteString(fmt.Sprintf("TgID: %d, RefCount: %d\n", response.TgID, response.RefCount))
	}

	return "Updated data:\n\n" + result.String(), nil

}

// UserUpdateResponse Contains updated user data.
type UserUpdateResponse struct {
	TgID     int64 `json:"tg_id"`
	RefCount int64 `json:"ref_count"`
}
