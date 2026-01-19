package main

import (
	"log"
	"time"

	"github.com/dazaran/Glitch/backend/internal/handlers"
	"github.com/dazaran/Glitch/backend/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitDB() *gorm.DB {
	dsn := "host=localhost user=dazaran password=secretpassword dbname=radar_core port=5433 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("❌ DB Connection failed:", err)
	}

	db.Exec("CREATE EXTENSION IF NOT EXISTS postgis;")
	db.AutoMigrate(&models.User{})
	
	db.Exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS location geography(Point, 4326);")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_location ON users USING GIST(location);")

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

// 🔥 ТОТ САМЫЙ CORS FIX
func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	}
}

func main() {
	db := InitDB()
	radarHandler := &handlers.RadarHandler{DB: db}
	authHandler := &handlers.AuthHandler{DB: db}

	r := gin.Default()
	r.Use(CORSMiddleware()) // 👈 Включаем защиту от паранойи браузера

	api := r.Group("/api/v1")
	{
		api.POST("/register", authHandler.Register)
		api.POST("/login", authHandler.Login)
		api.POST("/update-location", radarHandler.UpdateAndSearch)
		api.POST("/like", radarHandler.LikeUser)
	}

	r.Run(":8080")
}
