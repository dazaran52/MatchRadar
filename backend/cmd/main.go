package main

import (
	"log"
	"time"

	"github.com/dazaran/MatchRadar/backend/internal/handlers"
	"github.com/dazaran/MatchRadar/backend/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitDB() *gorm.DB {
	dsn := "host=localhost user=dazaran password=secretpassword dbname=radar_core port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("❌ DB Connection failed:", err)
	}

	db.Exec("CREATE EXTENSION IF NOT EXISTS postgis;")
	db.AutoMigrate(&models.User{})
	
	// Добавляем гео-колонку вручную
	db.Exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS location geography(Point, 4326);")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_location ON users USING GIST(location);")

	// Создаем тестового пользователя Alice, если база пуста
	var count int64
	db.Model(&models.User{}).Count(&count)
	if count == 0 {
		log.Println("⚠️ Creating Test User: Alice")
		db.Create(&models.User{
			ID: 2, Name: "Alice (Test)", 
			PhotoURL: "https://i.pravatar.cc/150?u=alice", 
			BLEUUID: "test-uuid-alice-123",
			Latitude: 50.0755, Longitude: 14.4378,
			LastSeen: time.Now().Add(time.Minute),
		})
		db.Exec("UPDATE users SET location = ST_SetSRID(ST_MakePoint(14.4378, 50.0755), 4326) WHERE id = 2")
	}

	log.Println("✅ DB Migrated and Ready")
	return db
}

func main() {
	db := InitDB()
	radarHandler := &handlers.RadarHandler{DB: db}

	r := gin.Default()

	api := r.Group("/api/v1")
	{
		api.POST("/radar", radarHandler.UpdateAndSearch)
	}

	r.Run(":8080")
}
