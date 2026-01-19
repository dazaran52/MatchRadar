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
	dsn := "postgresql://neondb_owner:npg_xm9Q4kjOBXGR@ep-holy-violet-agv7k5cl-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
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
		log.Println("⚠️ Seeding Test Users...")
		users := []models.User{
			{ID: 2, Name: "Alice (Cyber)", Email: "alice@test.com", PhotoURL: "https://ui-avatars.com/api/?name=Alice&background=FF003C&color=fff", Latitude: 50.0755, Longitude: 14.4378},
			{ID: 3, Name: "Bob (Runner)", Email: "bob@test.com", PhotoURL: "https://ui-avatars.com/api/?name=Bob&background=00F0FF&color=fff", Latitude: 50.0760, Longitude: 14.4380},
			{ID: 4, Name: "V (Legend)", Email: "v@test.com", PhotoURL: "https://ui-avatars.com/api/?name=V&background=8E2DE2&color=fff", Latitude: 50.0750, Longitude: 14.4370},
			{ID: 5, Name: "Judy", Email: "judy@test.com", PhotoURL: "https://ui-avatars.com/api/?name=Judy&background=FF0099&color=fff", Latitude: 50.0758, Longitude: 14.4375},
			{ID: 6, Name: "Panam", Email: "panam@test.com", PhotoURL: "https://ui-avatars.com/api/?name=Panam&background=F5AF19&color=fff", Latitude: 50.0752, Longitude: 14.4382},
			{ID: 7, Name: "David", Email: "david@test.com", PhotoURL: "https://ui-avatars.com/api/?name=David&background=FFFF00&color=000", Latitude: 50.0757, Longitude: 14.4372},
			{ID: 8, Name: "Lucy", Email: "lucy@test.com", PhotoURL: "https://ui-avatars.com/api/?name=Lucy&background=F12711&color=fff", Latitude: 50.0753, Longitude: 14.4379},
			{ID: 9, Name: "Rebecca", Email: "rebecca@test.com", PhotoURL: "https://ui-avatars.com/api/?name=Rebecca&background=00C9FF&color=fff", Latitude: 50.0759, Longitude: 14.4374},
			{ID: 10, Name: "Maine", Email: "maine@test.com", PhotoURL: "https://ui-avatars.com/api/?name=Maine&background=92FE9D&color=000", Latitude: 50.0756, Longitude: 14.4381},
		}

		for _, u := range users {
			u.LastSeen = time.Now()
			u.BLEUUID = "uuid-" + u.Name
			db.Create(&u)
			// PostGIS Update
			db.Exec("UPDATE users SET location = ST_SetSRID(ST_MakePoint(?, ?), 4326) WHERE id = ?", u.Longitude, u.Latitude, u.ID)
		}
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
