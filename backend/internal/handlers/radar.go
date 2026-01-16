package handlers

import (
	"log"
	"net/http"

	"github.com/dazaran/MatchRadar/backend/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"gorm.io/gorm/clause" // 👈 Добавил этот важный импорт
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
	// PostGIS ждет порядок (Longitude, Latitude)
	user := models.User{ID: req.UserID, Latitude: req.Latitude, Longitude: req.Longitude}
	
	// Используем Upsert (обновить если есть, создать если нет)
	// Исправил gorm.Clause на clause.OnConflict
	result := h.DB.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "id"}},
		DoUpdates: clause.Assignments(map[string]interface{}{
			"latitude":  req.Latitude,
			"longitude": req.Longitude,
			"last_seen": gorm.Expr("NOW()"),
			"location":  gorm.Expr("ST_SetSRID(ST_MakePoint(?, ?), 4326)", req.Longitude, req.Latitude),
		}),
	}).Create(&
