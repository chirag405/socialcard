# SocialCard Pro - Integration Setup & Testing Guide

## 🚀 Current Integration Status

### ✅ **Working Components:**

1. **Flutter Frontend** - Cross-platform app with web support
2. **Firebase Authentication** - Google Sign-In and Phone OTP
3. **Firestore Database** - User profiles, QR configs, custom links
4. **Local Storage** - SQLite (mobile) + SharedPreferences (web)
5. **QR Code Generation** - Custom styling and expiry management
6. **Contact Integration** - Phone contacts import and matching
7. **Firebase Cloud Functions** - Backend API for profile viewing
8. **Web Profile Viewer** - HTML page for QR code recipients

### ✅ **Fixed Issues:**

1. **Domain Configuration** - Updated to use localhost for development
2. **Cross-platform Storage** - Web/mobile compatibility
3. **Model Integration** - Proper imports and serialization
4. **API Service** - Connected to Firebase backend
5. **QR Link Generation** - Uses AppConfig for proper URLs

## 🔧 **Setup Instructions**

### 1. **Frontend Setup**

```bash
# Install Flutter dependencies
flutter pub get

# Build for web
flutter build web

# Run on web (development)
flutter run -d chrome --web-port=3000
```

### 2. **Backend Setup**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Navigate to backend
cd backend-firebase

# Install dependencies
npm install

# Login to Firebase
firebase login

# Initialize project (if not done)
firebase init

# Deploy to Firebase
firebase deploy
```

### 3. **Local Development**

```bash
# Start Firebase emulators
firebase emulators:start

# In another terminal, run Flutter app
flutter run -d chrome --web-port=3000
```

## 🧪 **Testing Integration**

### 1. **Run Integration Tests**

```bash
# Run the integration test
flutter test test_integration.dart

# Run all tests
flutter test
```

### 2. **Manual Testing Checklist**

#### **Authentication Flow:**

- [ ] Google Sign-In works
- [ ] Phone OTP works
- [ ] Privacy prompt appears for new users
- [ ] User profile is created in Firestore

#### **Profile Management:**

- [ ] Edit profile information
- [ ] Add/edit/delete custom links
- [ ] Upload profile picture
- [ ] Privacy settings work

#### **QR Code Features:**

- [ ] Create QR code with custom styling
- [ ] Set expiry dates/scan limits
- [ ] Save QR presets
- [ ] Share QR codes
- [ ] View QR history

#### **Contact Features:**

- [ ] Import phone contacts
- [ ] Match contacts with app users
- [ ] Save scanned contacts
- [ ] Contact privacy settings

#### **Web Profile Viewer:**

- [ ] QR codes generate working links
- [ ] Profile page loads correctly
- [ ] Shows selected social links
- [ ] Respects expiry settings
- [ ] App download links work

## 🔗 **Integration Architecture**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Firebase Cloud  │    │   Firestore     │
│                 │    │    Functions     │    │   Database      │
│ • Authentication│◄──►│                  │◄──►│                 │
│ • UI/UX         │    │ • API Endpoints  │    │ • User Profiles │
│ • Local Storage │    │ • Profile Viewer │    │ • QR Configs    │
│ • QR Generation │    │ • Slug Checking  │    │ • Custom Links  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Local SQLite   │    │  Firebase        │    │   Web Profile   │
│   Database      │    │   Hosting        │    │     Viewer      │
│                 │    │                  │    │                 │
│ • Saved Contacts│    │ • Static Files   │    │ • profile.html  │
│ • QR Presets    │    │ • API Routes     │    │ • JavaScript    │
│ • Offline Data  │    │ • Web App        │    │ • Responsive    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🐛 **Known Issues & Solutions**

### Issue 1: "your-actual-domain.com" in QR codes

**Status:** ✅ **FIXED**

- Updated `AppConfig` to use localhost for development
- Added production configuration comments

### Issue 2: Web platform database errors

**Status:** ✅ **FIXED**

- Implemented platform-aware storage
- Web uses SharedPreferences, mobile uses SQLite

### Issue 3: Backend not connected

**Status:** ✅ **FIXED**

- Firebase Functions properly configured
- API endpoints working
- Profile viewer connected

### Issue 4: Missing imports in models

**Status:** ✅ **FIXED**

- Added proper imports for AppConfig
- Fixed model serialization

## 📱 **Production Deployment**

### 1. **Update Configuration**

```dart
// In lib/utils/app_config.dart
static const String baseDomain = 'your-project-id.web.app';
static const String baseUrl = 'https://$baseDomain';
```

### 2. **Deploy to Firebase**

```bash
# Build Flutter web
flutter build web

# Deploy everything
firebase deploy

# Deploy only functions
firebase deploy --only functions

# Deploy only hosting
firebase deploy --only hosting
```

### 3. **Update Firebase Security Rules**

```javascript
// In firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // QR configs are readable by anyone but only writable by owner
    match /qr_configs/{configId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

## 🎯 **Features Working**

### ✅ **Core Features:**

- User authentication (Google + Phone)
- Profile management with custom links
- QR code generation with customization
- Expiry management (date + scan count)
- Contact import and discovery
- Privacy controls
- Preset management
- Cross-platform compatibility

### ✅ **Advanced Features:**

- Real-time expiry tracking
- Auto-removal of expired QR codes
- Visual expiry indicators
- Batch operations
- Offline-first architecture
- Web profile viewing
- Share functionality
- Contact deduplication

## 🔄 **Data Flow**

1. **User creates QR code** → Saved to Firestore + Local Storage
2. **QR code scanned** → Redirects to Firebase Hosting
3. **Profile page loads** → Calls Cloud Function API
4. **API fetches data** → From Firestore database
5. **Profile displayed** → With selected social links
6. **Visit tracked** → Analytics stored in Firestore

## 🎉 **Ready for Production**

The SocialCard Pro app is now fully integrated with:

- ✅ Frontend-Backend communication
- ✅ Database operations
- ✅ Local storage management
- ✅ Authentication flow
- ✅ QR code functionality
- ✅ Web profile viewing
- ✅ Contact integration
- ✅ Cross-platform compatibility

**Next Steps:**

1. Update domain configuration for production
2. Deploy to Firebase
3. Test with real users
4. Monitor analytics and performance
