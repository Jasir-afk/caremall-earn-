<!-- # 📱 Care Mall Earn+ (`care_mall_affiliate`) Documentation

> **Official Affiliate Partner Application for CareMall**  
> Empowering partners to promote products, generate trackable referral links, track sales & earnings, manage KYC compliance, and request direct bank payouts.

---

## 📋 Table of Contents

1. [Executive Summary](#-executive-summary)
2. [Application Flow Diagram](#-application-flow-diagram)
3. [Tech Stack & Dependencies](#-tech-stack--dependencies)
4. [Architecture & Directory Structure](#-architecture--directory-structure)
5. [Controller Documentation](#-controller-documentation)
6. [Core Features & Modules](#-core-features--modules)
7. [API Request & Response Examples](#-api-request--response-examples)
8. [API Endpoints Reference](#-api-endpoints-reference)
9. [Local Storage Documentation](#-local-storage-documentation)
10. [Environment Configuration](#-environment-configuration)
11. [Deep Linking Integration & Examples](#-deep-linking-integration--examples)
12. [Network Architecture & Interceptors](#-network-architecture--interceptors)
13. [Error Handling Guide](#-error-handling-guide)
14. [Design System & Theme](#-design-system--theme)
15. [Screenshots & UI Modules](#-screenshots--ui-modules)
16. [Security Notes](#-security-notes)
17. [Setup & Release Process](#-setup--release-process)
18. [Known Issues & Pending Features](#-known-issues--pending-features)

---

## 🎯 Executive Summary

**Care Mall Earn+** is a cross-platform mobile application built using Flutter. It serves as the official affiliate partner portal for CareMall, allowing creators, influencers, and marketers to:
- Generate custom referral/affiliate links for any CareMall product.
- Track real-time conversions, click analytics, and sales performance.
- Monitor tiered commission slabs (earning incentives based on monthly volume).
- Upload and manage KYC verification documents (PAN, Aadhaar, Bank Details).
- Request and track payouts directly into verified bank accounts.

---

## 🔄 Application Flow Diagram

The diagram below outlines the core lifecycle of an affiliate user inside the application:

```text
       ┌──────────────────────────────┐
       │     Splash / Init Screen     │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │   Login & OTP Verification   │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │     Dashboard & Analytics    │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │   Generate Affiliate Link    │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │     Share Link to Social     │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │   Customer Purchases Item    │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │  Commission Earned & Slab Up │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │    Payout Request & Bank     │
       │           Transfer           │
       └──────────────────────────────┘
```

---

## 🛠 Tech Stack & Dependencies

| Category | Technology / Package | Version / Description |
|---|---|---|
| **Framework** | Flutter / Dart SDK | `^3.10.7` |
| **State Management** | GetX | `^4.6.6` |
| **Local Storage** | GetStorage & SharedPreferences | `^2.1.1` & `^2.5.4` |
| **HTTP Client** | Dio & Http | `^5.8.0` & `^1.2.0` |
| **Screen Adaptation** | Flutter ScreenUtil | `^5.9.3` (Base Design: 375x812) |
| **Charts & Visuals** | FL Chart | `^0.69.0` |
| **Deep Linking** | App Links | `^7.0.0` |
| **UI Components** | Google Fonts, Flutter SVG, Cupertino Icons | `^6.3.1`, `^2.2.3`, `^1.0.8` |
| **Media & Utilities** | Image Picker, Share Plus, URL Launcher | `^1.2.1`, `^12.0.1`, `^6.3.2` |
| **App Maintenance** | In App Update, Upgrader | `^4.2.5`, `^12.5.0` |

---

## 🏗 Architecture & Directory Structure

The project follows a **Modular Architecture (MVC per module)** powered by GetX for reactive dependency injection and state management.

```
lib/
├── app/                        # Shared Application Layer
│   ├── app_buttons/            # Custom reusable buttons
│   ├── commenwidget/           # Input fields, custom snackbars, dashed border boxes
│   ├── deeplink/               # DeepLinkService (App Links listener & handler)
│   ├── services/               # UpdateService (In-app updates handler)
│   ├── theme_data/             # AppColors & typography design system
│   └── utils/                  # Network configuration & HTTP layer
│       ├── dio/                # Dio client, Interceptor, exception mapper
│       └── network/            # ApiUrls & AuthService
├── src/
│   └── modules/                # Feature Modules
│       ├── affilatelinks/      # Referral Link Generation & Stats
│       ├── auth/               # Mobile OTP Login, Register & Session
│       ├── commoncontroller/   # Cross-module shared state
│       ├── dashboard/          # Summary Dashboard Cards
│       ├── earning/            # Monthly Earnings & Commission Tiers
│       ├── home_screen/        # Main Dashboard, Navigation Drawer, Charts
│       ├── intilise_screen/    # Splash Screen & Initialization
│       ├── kyc_profile/        # KYC Uploads & Profile Verification
│       ├── orders/             # Referral Orders & Returns Tracking
│       └── payout/             # Payout History & Withdrawal Requests
└── main.dart                   # Application Entry Point
```

---

## 🎮 Controller Documentation

The application relies on specific GetX Controllers to handle state and API interactions for each feature module:

| Controller Class | Source Path | Primary Responsibilities |
|---|---|---|
| [`AuthController`](file:///d:/flutter/Affilate/lib/src/modules/auth/controller/auth_controller.dart) | `lib/src/modules/auth/controller/auth_controller.dart` | Manages mobile OTP generation (`sendOtp`), verification (`verifyOtp`), token saving, session initialization, user profile state, and account deletion. |
| [`DashboardController`](file:///d:/flutter/Affilate/lib/src/modules/home_screen/controller/homescreen_controller.dart) | `lib/src/modules/home_screen/controller/homescreen_controller.dart` | Fetches high-level summary counters, analytics chart data, performance graphs (FL Chart), and recent order widgets. |
| [`CreateLinkController`](file:///d:/flutter/Affilate/lib/src/modules/affilatelinks/controller/link_controller.dart) | `lib/src/modules/affilatelinks/controller/link_controller.dart` | Handles product catalog search, conversion of product URLs/slugs to affiliate links, link click statistics, copying to clipboard, and native social sharing. |
| [`OrderController`](file:///d:/flutter/Affilate/lib/src/modules/orders/controller/order_controller.dart) | `lib/src/modules/orders/controller/order_controller.dart` | Retrieves referral order sales history, monitors order status transitions, and calculates total returned items. |
| [`EarningController`](file:///d:/flutter/Affilate/lib/src/modules/earning/controller/earning_controller.dart) | `lib/src/modules/earning/controller/earning_controller.dart` | Calculates monthly revenue breakdowns, tracks active commission slab levels, and displays projected vs accrued earnings. |
| [`PayoutController`](file:///d:/flutter/Affilate/lib/src/modules/payout/controller/payout_controller.dart) | `lib/src/modules/payout/controller/payout_controller.dart` | Manages wallet balances, lists payout transaction history, and submits withdrawal requests to verified partner bank accounts. |
| [`KycController`](file:///d:/flutter/Affilate/lib/src/modules/kyc_profile/controller/kyc_controller.dart) | `lib/src/modules/kyc_profile/controller/kyc_controller.dart` | Handles user profile editing, multipart document uploads (Aadhaar, PAN Card, Bank Cheque image), and tracks compliance verification state. |

---

## 🧩 Core Features & Modules

### 1. 🔐 Authentication (`lib/src/modules/auth/`)
- **Mobile OTP Login**: 10-digit mobile number input sending OTP via SMS (`send-otp`).
- **OTP Verification & Registration**: Verification of 6-digit OTP code (`verify-otp`) returning Bearer JWT.
- **Session Auto-Restore**: Check for saved auth tokens during splash launch.
- **Account Management**: Option for affiliates to request permanent account deletion (`delete-account`).

### 2. 📑 KYC & Profile Management (`lib/src/modules/kyc_profile/`)
- **Profile View & Edit**: Update partner name, email address, and personal details.
- **Document Upload**: Supports uploading document images via camera/gallery multipart requests (`upload/image`).
- **KYC Verification Pipeline**: Verification status indicator (`pending`, `verified`, `rejected`) guarding payout access.

### 3. 📊 Dashboard & Performance (`lib/src/modules/home_screen/`)
- **Summary Cards**: Total Earnings, Clicks, Orders, and Active Commission Tier.
- **FL Chart Integration**: Dynamic performance curves showing click-to-conversion rates and sales history.
- **Navigation Drawer**: Central access point for all modules.

### 4. 🔗 Affiliate Links Generator (`lib/src/modules/affilatelinks/`)
- **Product Search & Custom Links**: Turn standard CareMall product URLs into trackable referral links (`/api/v1/affiliate/products`).
- **Link Analytics**: Individual link performance metrics (total clicks, orders converted, revenue generated).
- **Native Sharing**: One-tap sharing via `share_plus` to WhatsApp, Telegram, or copying to clipboard.

### 5. 📦 Orders & Returns (`lib/src/modules/orders/`)
- **Referral Sales Log**: Real-time view of customer purchases placed via affiliate referral links.
- **Return Deductions**: Dedicated breakdown of returned orders for transparent commission calculations.

### 6. 💰 Earnings & Slabs (`lib/src/modules/earning/`)
- **Commission Slabs**: Visual tier breakdown showing performance thresholds for higher commission percentages.
- **Monthly Revenue Logs**: Historical archive of commission earnings month-by-month.

### 7. 💳 Payout Management (`lib/src/modules/payout/`)
- **Payout Request**: Initiate withdrawal to bank account when minimum payout balance is met.
- **Payout Audit Log**: View transaction IDs, date requested, amount, and status (`Pending`, `Processing`, `Paid`).

---

## 📝 API Request & Response Examples

Below are representative request and response payloads for primary API endpoints:

### 1. Send Mobile OTP
`POST /api/v1/affiliate/auth/send-otp`

**Request:**
```json
{
  "mobile": "9876543210"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "OTP sent successfully to 9876543210"
}
```

---

### 2. Verify Mobile OTP
`POST /api/v1/affiliate/auth/verify-otp`

**Request:**
```json
{
  "mobile": "9876543210",
  "otp": "123456"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 102,
    "name": "John Doe",
    "mobile": "9876543210",
    "email": "john.doe@example.com",
    "kyc_status": "verified"
  }
}
```

---

### 3. Fetch Profile Details
`GET /api/v1/affiliate/profile`

**Headers:**
```text
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (Success):**
```json
{
  "status": true,
  "data": {
    "id": 102,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "mobile": "9876543210",
    "pan_number": "ABCDE1234F",
    "aadhaar_number": "123456789012",
    "bank_name": "HDFC Bank",
    "account_number": "50100123456789",
    "ifsc_code": "HDFC0001234",
    "kyc_status": "verified"
  }
}
```

---

### 4. Generate Affiliate Link
`POST /api/v1/affiliate/products`

**Request:**
```json
{
  "product_id": "prod-5542",
  "product_url": "https://caremallonline.com/product/vitamin-c-serum"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "link_id": "aff-99821",
    "product_name": "Vitamin C Serum 30ml",
    "original_url": "https://caremallonline.com/product/vitamin-c-serum",
    "affiliate_url": "https://affiliate.caremallonline.com/product/vitamin-c-serum?ref=AFF102",
    "short_code": "AFF102_SERUM",
    "created_at": "2026-08-03T10:00:00Z"
  }
}
```

---

### 5. Submit Payout Request
`POST /api/v1/affiliate/payouts`

**Request:**
```json
{
  "amount": 2500.00,
  "bank_account_id": "50100123456789"
}
```

**Response (Success):**
```json
{
  "status": true,
  "message": "Payout request submitted successfully",
  "data": {
    "transaction_id": "PAY-20260803-8821",
    "amount": 2500.00,
    "status": "Pending",
    "requested_at": "2026-08-03T11:00:00Z"
  }
}
```

---

## 🌐 API Endpoints Reference

Base Production URL: `https://affiliate.api.caremallonline.com`  
Base Staging / Testing URL: `https://test.affiliate.api.caremallonline.com`

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/affiliate/auth/send-otp` | POST | Send login OTP to mobile number |
| `/api/v1/affiliate/auth/verify-otp` | POST | Verify OTP & receive Bearer Token |
| `/api/v1/affiliate/auth/delete-account` | POST/DELETE | Request affiliate account deletion |
| `/api/v1/affiliate/profile` | GET / PUT | Fetch or update partner profile |
| `/api/v1/affiliate/kyc` | GET / POST | Fetch status or submit KYC document metadata |
| `/api/v1/affiliate/upload/image` | POST | Multipart upload for PAN/Aadhaar/Cheque images |
| `/api/v1/affiliate/dashboard/stats` | GET | Fetch high-level dashboard metrics |
| `/api/v1/affiliate/dashboard/performance` | GET | Fetch conversion & click chart performance |
| `/api/v1/affiliate/dashboard/earnings` | GET | Summary of earnings breakdown |
| `/api/v1/affiliate/dashboard/slab` | GET | Active commission tier thresholds |
| `/api/v1/affiliate/dashboard/monthly-earning` | GET | Monthly historical commission data |
| `/api/v1/affiliate/products` | GET / POST | Search catalog & create referral links |
| `/api/v1/affiliate/links` | GET | List generated affiliate links |
| `/api/v1/affiliate/links/stats` | GET | Click & conversion stats per link |
| `/api/v1/affiliate/orders` | GET | List referral sales orders |
| `/api/v1/affiliate/orders/returns` | GET | List returned referral orders |
| `/api/v1/affiliate/payouts` | GET / POST | Fetch payout history & submit requests |

---

## 💾 Local Storage Documentation

The app uses a hybrid storage strategy combining **GetStorage** (for synchronous fast access by network interceptors) and **SharedPreferences** (for persistent key-value backup):

| Storage Engine | Storage Key | Data Type | Purpose & Contents |
|---|---|---|---|
| **GetStorage** | `'token'` | `String` | Auth Bearer JWT token read directly by [`DioInterceptor`](file:///d:/flutter/Affilate/lib/app/utils/dio/dio_interceptor.dart) on every outgoing HTTP request. |
| **GetStorage** | `'user'` | `Map / String` | Cached user profile JSON structure. |
| **SharedPreferences** | `'auth_token'` | `String` | Persistent fallback storage for the session authorization token. |
| **SharedPreferences** | `'user_data'` | `String (JSON)` | Serialized partner profile information (ID, name, email, phone). |
| **SharedPreferences** | `'kyc_status'` | `String` | Current KYC compliance state (`pending`, `verified`, `rejected`). |
| **SharedPreferences** | `'app_settings'` | `Map / String` | App preferences (e.g. app theme, last update check timestamp). |

---

## ⚙️ Environment Configuration

Environment URL definitions are stored in [`lib/app/utils/network/api_urls.dart`](file:///d:/flutter/Affilate/lib/app/utils/network/api_urls.dart).

```dart
class Apiurls {
  // --- Development / Testing Base URL ---
  // static const String baseUrl = 'https://test.affiliate.api.caremallonline.com';

  // --- Production / Live Base URL ---
  static const String baseUrl = 'https://affiliate.api.caremallonline.com';
}
```

### How to Switch Environments:
1. Open [`lib/app/utils/network/api_urls.dart`](file:///d:/flutter/Affilate/lib/app/utils/network/api_urls.dart).
2. Uncomment the **Testing Base URL** line and comment out the **Production Base URL** line.
3. Perform a full app restart (`flutter run`).

---

## 🔗 Deep Linking Integration & Examples

The app utilizes the `AppLinks` package configured inside [`lib/app/deeplink/deeplink_service.dart`](file:///d:/flutter/Affilate/lib/app/deeplink/deeplink_service.dart).

### Deep Link Format:
- **Host Domain**: `affiliate.caremallonline.com`
- **URL Pattern**: `https://affiliate.caremallonline.com/product/{product-slug}`

### Example Deep Link:
```text
https://affiliate.caremallonline.com/product/vitamin-c-serum
```

### Execution Flow:
1. User clicks the link on an Android/iOS device.
2. Operating System resolves `affiliate.caremallonline.com` domain to **Care Mall Earn+**.
3. `DeepLinkService` parses the URL, extracts product slug `vitamin-c-serum`.
4. App automatically launches `GenerateLinksScreen`.
5. [`CreateLinkController`](file:///d:/flutter/Affilate/lib/src/modules/affilatelinks/controller/link_controller.dart) automatically triggers product search for `vitamin-c-serum` and populates link generation fields.

---

## 🔌 Network Architecture & Interceptors

All HTTP network communication is routed through Dio with automated logging and authorization headers via [`DioInterceptor`](file:///d:/flutter/Affilate/lib/app/utils/dio/dio_interceptor.dart):

```text
 Client Request
       │
       ▼
 ┌─────────────────────────────────────────┐
 │             DioInterceptor              │
 │  - Reads 'token' from GetStorage         │
 │  - Attaches: Authorization: Bearer <token>│
 └─────────────────────┬───────────────────┘
                       │
                       ▼
                 Backend API
                       │
                       ▼
 ┌─────────────────────────────────────────┐
 │            Response / Error             │
 │  - 200 OK: Process Data                 │
 │  - 401 Unauthorized: Auto-Logout        │
 │  - 400 Bad Request: Log & Notify User   │
 └─────────────────────────────────────────┘
```

---

## 🛡 Error Handling Guide

Standardized error parsing is performed across Dio request cycles:

| HTTP Code / Error Scenario | Description / Cause | System Behavior & User Experience |
|---|---|---|
| **400 Bad Request** | OTP Expired, invalid parameter input, or invalid mobile format | Displays user-friendly notification alert with server error message. |
| **401 Unauthorized** | Token expired or invalid session | `DioInterceptor` automatically clears session data from `GetStorage` & `SharedPreferences` and redirects user to `LoginScreen`. |
| **422 Validation Error** | KYC document validation failure or missing mandatory fields | Form highlights invalid fields and displays specific guidance (e.g., "PAN Card image required"). |
| **Network Timeout / No Internet** | Request timeout (>10s) or offline status | Snackbar notification: *"Network timeout. Please check your internet connection."* |
| **500 / 503 Server Error** | CareMall backend service temporary outage | Fallback screen / snackbar: *"Server maintenance in progress. Please try again later."* |

---

## 🎨 Design System & Theme

- **Primary Accent Color**: `#FF0000` (CareMall Brand Red)
- **Secondary Colors**:
  - Success Green: `#14AE5C` / `#22C55E`
  - Warning Yellow: `#FFAB00`
  - Neutral Dark Text: `#303030` / `#353535`
  - Neutral Light Background: `#F4F4F4`
- **Responsive Sizing**: Configured with `flutter_screenutil` (design base: 375x812 pt).

---

## 📱 Screenshots & UI Modules

The main application views comprise:
1. **Login & OTP Screen**: Modern single-field phone input with 6-digit OTP pin view.
2. **Analytics Dashboard**: Cards for earnings & FL Chart interactive conversion stats.
3. **Generate Link Screen**: Search bar, catalog list, and instant referral link builder.
4. **Earnings & Slabs Screen**: Slab status progress bar and monthly earnings history.
5. **Orders List View**: Detailed list of customer orders and return breakdowns.
6. **KYC & Document Verification**: Multipart upload inputs for PAN, Aadhaar, and Bank Cheque.
7. **Payout Screen**: Balance breakdown, withdrawal history, and payout request modal.

---

## 🔒 Security Notes

- **Bearer Token Auth**: Authorization tokens are passed in HTTPS headers rather than URI params.
- **Secure Local Storage**: Tokens and sensitive data are saved securely in app sandbox storage (`GetStorage`/`SharedPreferences`).
- **KYC & Financial Data Privacy**: PAN, Aadhaar, and Bank Details are uploaded directly over encrypted HTTPS/TLS connections.
- **Guarded API Endpoints**: Protected module routes enforce token validation before executing requests.

---

## 🚀 Setup & Release Process

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.10.7`)
- Android Studio / Xcode

### 2. Initial Setup
```bash
flutter pub get
```

### 3. Run Development Build
```bash
flutter run
```

### 4. Build Release Packages

- **Android APK (Direct Install)**:
  ```bash
  flutter build apk --release
  ```

- **Android App Bundle (Google Play Store Submission)**:
  ```bash
  flutter build appbundle --release
  ```

---

## 📌 Known Issues & Pending Features

### Known Issues
- **Deep Link Cold Launch**: Deep link processing may experience a minor delay on initial app cold start while `AppLinks` initializes.

### Pending Features
- [ ] **Push Notifications**: Firebase Cloud Messaging (FCM) for instant alerts on earned commissions and payout approvals.
- [ ] **Referral Leaderboard**: Gamified monthly leaderboard ranking top affiliates.
- [ ] **Earnings PDF Export**: Downloadable tax and commission summary PDF invoices.
- [ ] **Multi-language Support (i18n)**: Vernacular support for regional affiliate marketers.

--- -->
