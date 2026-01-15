package handlers

import (
	"net/http"
	"time"

	"github.com/dazaran/MatchRadar/backend/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type RadarHandler struct {
	DB *gorm.DB
}

// Запрос от клиента
type UpdateLocationRequest struct {
	UserID    uint    `json:"user_id"` // В реальном аппе берем из токена авторизации!
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

// Ответ клиенту
type RadarResponse struct {
	NearbyUsers []models.User `json:"nearby_users"`
	Message     string        `json:"message"`
}

func (h *RadarHandler) UpdateAndSearch(c *gin.Context) {
	var req UpdateLocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 1. Обновляем локацию текущего юзера
	// Мы используем Raw SQL для создания точки geography(Point, 4326)
	// 4326 - это стандарт GPS (WGS 84).
	query := `
		INSERT INTO users (id, latitude, longitude, last_seen, location)
		VALUES (?, ?, ?, ?, ST_SetSRID(ST_MakePoint(?, ?), 4326))
		ON CONFLICT (id) DO UPDATE SET
			latitude = EXCLUDED.latitude,
			longitude = EXCLUDED.longitude,
			last_seen = EXCLUDED.last_seen,
			location = EXCLUDED.location;
	`
	// Примечание: поле 'location' мы должны добавить в базу миграцией (см. ниже)
	now := time.Now()
	if err := h.DB.Exec(query, req.UserID, req.Latitude, req.Longitude, now, req.Longitude, req.Latitude).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update location"})
		return
	}

	// 2. Ищем людей рядом (Радиус: 500 метров для GPS этапа)
	// Логика: "Дай мне всех, кто в 500м, кроме меня, и кто был онлайн последние 15 минут"
	var nearbyUsers []models.User
	
	// ST_DWithin(location, ST_MakePoint(lon, lat)::geography, radius_in_meters)
	searchQuery := `
		SELECT id, name, photo_url, ble_uuid, latitude, longitude 
		FROM users 
		WHERE id != ? 
		AND last_seen > ?
		AND ST_DWithin(
			location, 
			ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, 
			500
		)
	`
	
	// Ищем тех, кто был активен последние 15 минут
	timeWindow := now.Add(-15 * time.Minute)
	
	if err := h.DB.Raw(searchQuery, req.UserID, timeWindow, req.Longitude, req.Latitude).Scan(&nearbyUsers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Radar malfunction"})
		return
	}

	c.JSON(http.StatusOK, RadarResponse{
		NearbyUsers: nearbyUsers,
		Message:     "Radar scan complete 🛰️",
	})
}