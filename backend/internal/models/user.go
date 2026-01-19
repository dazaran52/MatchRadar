package models

import (
	"time"
	"gorm.io/gorm"
)

type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time      `json:"-"`
	UpdatedAt time.Time      `json:"-"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	Name      string `json:"name"`
	Email     string `gorm:"uniqueIndex" json:"email"`
	Password  string `json:"-"` // Hash, don't return in JSON
	PhotoURL  string `json:"photo_url"`
	
	// Это уникальный ID, который телефон будет "кричать" через Bluetooth.
	// Мы не палим реальный ID пользователя в эфир ради безопасности.
	BLEUUID   string `gorm:"uniqueIndex" json:"ble_uuid"` 

	// Геопозиция. GORM сложно дружит с PostGIS напрямую в структурах,
	// поэтому мы будем обновлять это поле через raw SQL, 
	// но хранить структуру нам нужно.
	// В реальном проде тут используются спец. типы, но для старта опустим сложность.
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	
	// Время последнего обновления локации. 
	// Если > 15 мин, считаем пользователя офлайн.
	LastSeen  time.Time `json:"last_seen"`
}

// TableName заставляет GORM использовать имя 'users'
func (User) TableName() string {
	return "users"
}