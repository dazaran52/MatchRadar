package handlers

import (
	"log"
	"net/http"

	"github.com/dazaran/MatchRadar/backend/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
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

	// 1. Обновляем (или создаем) ТЕБЯ. 
	// ВАЖНО: PostGIS ждет порядок (Longitude, Latitude) !!!
	user := models.User{ID: req.UserID, Latitude: req.Latitude, Longitude: req.Longitude}
	
	// Используем Upsert (обновить если есть, создать если нет)
	result := h.DB.Clauses(gorm.Clause{
		OnConflict: gorm.Clause{
			Columns:   []gorm.Clause.Column{{Name: "id"}},
			DoUpdates: gorm.Clause.Assignments(map[string]interface{}{
				"latitude":  req.Latitude,
				"longitude": req.Longitude,
				"last_seen": gorm.Expr("NOW()"),
				"location":  gorm.Expr("ST_SetSRID(ST_MakePoint(?, ?), 4326)", req.Longitude, req.Latitude), // 👈 ТУТ БЫЛА ОШИБКА (нужен Lng, Lat)
			}),
		},
	}).Create(&user)

	if result.Error != nil {
		log.Println("❌ Ошибка обновления пользователя:", result.Error)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update location"})
		return
	}

	// 2. Ищем людей рядом (Элис)
	var nearbyUsers []models.User
	
	// Ищем всех в радиусе 5000 метров (5 км), кроме тебя самого
	// И снова ВАЖНО: ST_MakePoint(Longitude, Latitude)
	err := h.DB.Where("id != ? AND ST_DWithin(location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, 5000)", 
		req.UserID, req.Longitude, req.Latitude).Find(&nearbyUsers).Error

	if err != nil {
		log.Println("❌ Ошибка поиска:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Search failed"})
		return
	}

	// Лог для отладки
	log.Printf("🔍 Радар: Пользователь %d ищет. Найдено людей: %d", req.UserID, len(nearbyUsers))

	// Если никого нет, возвращаем пустой массив [], а не null
	if nearbyUsers == nil {
		nearbyUsers = []models.User{}
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "Radar scan complete 🛰️",
		"nearby_users": nearbyUsers,
	})
}
