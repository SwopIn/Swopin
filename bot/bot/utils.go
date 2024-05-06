package main

// contains checks if a given int64 value is present in a slice of int64
func contains(slice []int64, num int64) bool {
	for _, v := range slice {
		if v == num {
			return true
		}
	}
	return false
}
