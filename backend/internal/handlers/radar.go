package handlers

import (
	"log"
	"net/http"

	"github.com/dazaran/MatchRadar/backend/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type RadarHandler struct {
	DB *gorm.DB
}

type RadarRequest struct {
	UserID    uint    `json:"user_id"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

func (h *RadarHandler) UpdateAndSearch(c *gin.Context) {
	var req RadarRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 1. Обновляем (или создаем) пользователя. 
	// PostGIS ждет порядок (Longitude, Latitude)
	user := models.User{ID: req.UserID, Latitude: req.Latitude, Longitude: req.Longitude}
	
	// Используем Upsert (обновить если есть, создать если нет)
	result := h.DB.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "id"}},
		DoUpdates: clause.Assignments(map[string]interface{}{
			"latitude":  req.Latitude,
			"longitude": req.Longitude,
			"last_seen": gorm.Expr("NOW()"),
			"location":  gorm.Expr("ST_SetSRID(ST_MakePoint(?, ?), 4326)", req.Longitude, req.Latitude),
		}),
	}).Create(&user)

	if result.Error != nil {
		log.Println("❌ Ошибка обновления:", result.Error)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update location"})
		return
	}

	// 2. Ищем людей рядом (Элис)
	var nearbyUsers []models.User
	
	// Ищем всех в радиусе 5000 метров (5 км)
	err := h.DB.Where("id != ? AND ST_DWithin(location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, 5000)", 
		req.UserID, req.Longitude, req.Latitude).Find(&nearbyUsers).Error

	if err != nil {
		log.Println("❌ Ошибка поиска:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Search failed"})
		return
	}

	log.Printf("🔍 Радар: User %d ищет. Найдено: %d", req.UserID, len(nearbyUsers))

	if nearbyUsers == nil {
		nearbyUsers = []models.User{}
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "Radar scan complete 🛰️",
		"nearby_users": nearbyUsers,
	})
}
EOF
