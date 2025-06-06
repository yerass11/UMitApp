# UMitApp

UMitApp — это мобильное приложение для iOS, разработанное с использованием SwiftUI и UIKit, которое предоставляет пользователям удобную платформу для записи к врачам, заказа лекарств и общения с медицинскими специалистами. Приложение использует современную архитектуру MVVM и интегрировано с Django-бэкендом.

[Presentation](https://www.canva.com/design/DAGnEQDXTpQ/80rM4NEUI9AFONiRF2aWvg/edit?utm_content=DAGnEQDXTpQ&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

## 📱 Основные технологии

- **SwiftUI + UIKit** — гибридный UI-подход для лучшей совместимости и кастомизации.
- **MVVM Architecture** — модульная и масштабируемая архитектура с четким разделением ответственности.
- **Firebase** — для аутентификации, хранения данных и уведомлений.
- **Stripe iOS SDK** — интеграция безопасных платежей прямо из приложения.
- **Django Backend** — REST API для управления данными и бизнес-логикой.

## 🔧 Основной функционал

- Регистрация и вход с помощью Email, Apple ID или соцсетей
- Просмотр списка врачей и клиник
- Онлайн-запись на приём
- Заказ лекарств с возможностью оплаты через Stripe
- Просмотр истории заказов и приёмов
- Чат с врачами (Firebase/WebSocket)
- Реализация аптечной системы с использованием баллов
- Уведомления о записях и сообщениях

## 🛠 Установка

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/yourusername/UMitApp.git

## 🛠 Установка зависимостей

1. Убедитесь, что установлен **Xcode последней версии**.

2. Используйте **Swift Package Manager** для добавления:

   - [Firebase SDK](https://github.com/firebase/firebase-ios-sdk)
   - [Stripe iOS SDK](https://github.com/stripe/stripe-ios)

3. Настройте `.plist`:

4. Подключите бэкенд:

   - Уже есть deploy на Chat](https://backend-production-d019d.up.railway.app)
---

## 🧪 Тестирование

Приложение использует модульный подход с возможностью легкого написания **юнит-тестов**.  
Бизнес-логика инкапсулирована во `ViewModel`.

---

## 📦 Backend API

Бэкенд построен на **Django + Django REST Framework, Firebase**. Поддерживает:
- https://backend-production-d019d.up.railway.app
---

## 📂 Структура проекта

UMitApp/
├── App/ # Точка входа в приложение
│ ├── GoogleService-Info # Firebase конфигурация
│ └── UMitApp.swift # @main
│
├── Core/ # Общие компоненты и сервисы
│ ├── Model/ # Общие модели
│ ├── Service/ # Core-сервисы
│ ├── TabBar/ # Таббар и навигация
│ └── TextField/ # Кастомные текстфилды
│
├── Features/ # Основные фичи приложения (по модулям)
│ ├── Chat/
│ │ ├── Modules/
│ │ │ ├── Model/
│ │ │ ├── Service/
│ │ │ └── View/
│ │ └── ChatListView.swift
│ │
│ ├── Home/
│ │ ├── Modules/
│ │ │ ├── Appointment/
│ │ │ ├── Doctor/
│ │ │ ├── Document/
│ │ │ ├── Home/
│ │ │ ├── Hospital/
│ │ │ └── Reviews/
│ │ ├── SearchView.swift
│ │ └── Services/
│ │
│ ├── Pharmacy/
│ │ └── Modules/
│ │ ├── OrderHistory/
│ │ └── Pharmacy/
│ │
│ └── Profile/
│ └── Modules/
│ ├── Auth/
│ └── Profile/
│
├── ContentView.swift
└── Resources/



## 🚀 Планы на будущее

- Добавление поддержки мультиязычности
- Интеграция видеозвонков
- Расширение аптечного функционала
- Поддержка HealthKit
