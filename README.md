# Field Notes - Offline-First Mobile & REST Backend Solution

An enterprise-grade, offline-first mobile application and Spring Boot REST backend built for field workers to record and manage inspection notes during site visits.

---

## 🌟 System Overview & Key Features

- **Offline-First Architecture**: Field workers can create, edit, view, and delete customers, sites, and field notes with or without internet connectivity. Changes are saved immediately to local encrypted Hive storage and automatically synchronize with the cloud once network connectivity is restored.
- **Relational Integrity & Data Isolation**:
  - `User` ➜ `Customer` (1:N)
  - `Customer` ➜ `Site` (1:N)
  - `Site` ➜ `Field Note` (1:N)
  - Data isolation: Every user has isolated customers, sites, and notes.
  - Relational queries with SQL `JOIN`s retrieve joined customer and site details without duplicated data.
- **Search & Filter Capabilities**:
  - Full-text search across note title, description, site name, and customer name.
  - Filter notes by Status (`Draft`, `In Progress`, `Completed`, `Pending`) or by Site.
- **Device Hardware Integration**:
  - GPS coordinate capture with reverse-geocoded location details.
  - Camera photo capture & Gallery image selection with runtime permission handling.
- **Configurable Settings**:
  - **Default Note Status**: Customizable default status (`Draft`, `In Progress`, `Completed`, etc.) saved locally in Hive/SharedPreferences and automatically assigned to newly created notes. Remains persistent across app restarts without syncing to the backend.
  - Configurable backend server URL and manual sync triggers.

---

## 🏗️ Architecture & Technology Stack

### Mobile App (`/mobile`)
- **Framework**: Flutter (Dart 3.x)
- **State Management**: BLoC pattern (`flutter_bloc`, `equatable`)
- **Local Storage**: Hive (`hive_flutter`) for offline-first persistence
- **Networking**: HTTP client (`http`) with JWT Bearer authentication and multipart image upload
- **Device Sensors & Media**:
  - `geolocator` & `permission_handler` for GPS capture
  - `image_picker` for camera and photo gallery

### Backend (`/backend`)
- **Framework**: Java 21 + Spring Boot 3.3.4
- **Database**: MySQL 8.x (Relational schema with foreign keys and indexes)
- **Security**: Spring Security 6 with stateless JWT (JSON Web Tokens) and BCrypt password hashing
- **Persistence**: Spring Data JPA / Hibernate with JPQL relational `JOIN FETCH` queries
- **File Storage**: Local file storage service for inspection photo uploads with static resource handler (`/uploads/**`)

---

## 🗄️ Database Schema & Relationships

```
┌──────────────────┐       1:N       ┌──────────────────┐
│      users       │ ──────────────> │    customers     │
├──────────────────┤                 ├──────────────────┤
│ id (BIGINT, PK)  │                 │ id (UUID, PK)    │
│ username (UNIQ)  │                 │ user_id (FK)     │
│ email (UNIQ)     │                 │ name             │
│ password (BCrypt)│                 │ contact_info     │
│ full_name        │                 │ deleted (BIT)    │
│ created_at       │                 │ updated_at       │
│ updated_at       │                 └────────┬─────────┘
└──────────────────┘                          │
                                              │ 1:N
                                              ▼
┌──────────────────┐       1:N       ┌──────────────────┐
│   field_notes    │ <────────────── │      sites       │
├──────────────────┤                 ├──────────────────┤
│ id (UUID, PK)    │                 │ id (UUID, PK)    │
│ site_id (FK)     │                 │ customer_id (FK) │
│ title            │                 │ site_name        │
│ description (TXT)│                 │ address          │
│ latitude         │                 │ deleted (BIT)    │
│ longitude        │                 │ updated_at       │
│ location_name    │                 └──────────────────┘
│ date_time        │
│ status           │
│ photo_url        │
│ deleted (BIT)    │
│ updated_at       │
└──────────────────┘
```

---

## 🔄 Synchronization Mechanism

The synchronization protocol is bidirectional and designed for low-bandwidth, offline field work:

1. **Client-Generated UUIDs**: All entities use UUID v4 identifiers generated on the mobile device, allowing parent-child relationships (Customer ➜ Site ➜ Note) to be linked offline before ever reaching the server.
2. **Push Phase (`POST /api/sync/push`)**:
   - Gathers all local entities where `isSynced == false`.
   - Uploads any pending offline photos via `POST /api/notes/upload-photo`.
   - Sends dirty records to backend in an atomic batch.
   - Server applies changes using "last write wins" (comparing `updatedAt` timestamps) and returns the list of successfully synchronized IDs.
   - Mobile app marks local records as `isSynced = true`.
3. **Pull Phase (`GET /api/sync/pull?sinceEpoch={timestamp}`)**:
   - Server queries for all records updated after `sinceEpoch` for the authenticated user (including soft-deleted records).
   - If `sinceEpoch` is omitted (e.g. app reinstalled or fresh login), returns **all** active records for the user.
   - Mobile app merges returned records into local Hive storage and records `lastSyncTime`.

---

## 🚀 Getting Started & Running the Project

### 1. Start the Database & Backend

Run the provided launcher script:
```bash
./run-backend.sh
```
Or start each service individually:
```bash
# 1. Start MySQL database
./start-db.sh

# 2. Start Spring Boot REST API
cd backend
mvn spring-boot:run
```
The REST API will be live at `http://localhost:8080`.

### 2. Run Backend Tests

```bash
cd backend
mvn clean test
```

### 3. Run the Mobile App

Run using the helper script:
```bash
./run-app.sh
```
Or run directly via Flutter:
```bash
cd mobile

# Test on Linux desktop or Chrome
flutter run -d chrome
# or
flutter run -d linux

# Run mobile tests
flutter test
```

---

## 📡 REST API Reference

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/register` | Register new user account |
| `POST` | `/api/auth/login` | Login and receive Bearer JWT |
| `GET` | `/api/auth/me` | Get authenticated user profile |

### Customers
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/customers` | List all customers with site & note counts |
| `GET` | `/api/customers/{id}` | Get customer details by ID |
| `POST` | `/api/customers` | Create a customer |
| `PUT` | `/api/customers/{id}` | Update customer |
| `DELETE` | `/api/customers/{id}` | Soft delete customer & cascaded sites/notes |

### Sites
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/sites` | List all sites (supports `?customerId=...`) |
| `GET` | `/api/sites/{id}` | Get site details by ID |
| `POST` | `/api/sites` | Create a site under customer |
| `PUT` | `/api/sites/{id}` | Update site |
| `DELETE` | `/api/sites/{id}` | Soft delete site & cascaded notes |

### Field Notes
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/notes` | Search & filter notes (`?query=...&status=...&siteId=...`) |
| `GET` | `/api/notes/{id}` | Get note details with joined customer & site info |
| `POST` | `/api/notes` | Create a field note |
| `PUT` | `/api/notes/{id}` | Update a field note |
| `DELETE` | `/api/notes/{id}` | Soft delete field note |
| `POST` | `/api/notes/upload-photo`| Upload inspection photo (multipart) |

### Synchronization
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/sync/pull` | Pull records updated since timestamp (or all on reinstall) |
| `POST` | `/api/sync/push` | Push offline batch changes to server |

