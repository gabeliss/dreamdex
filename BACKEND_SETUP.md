# 🚀 Dreamdex Backend Setup Guide

This guide will help you set up the complete backend infrastructure for Dreamdex using **Convex DB** and **Clerk Authentication**.

## 🏗️ Backend Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │────│   Clerk Auth     │────│   Convex DB     │
│                 │    │                  │    │                 │
│ • Dream UI      │    │ • User Login     │    │ • Dreams        │
│ • Voice-to-Text │    │ • Registration   │    │ • User Data     │
│ • AI Features   │    │ • Profile Mgmt   │    │ • Real-time     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

- [Node.js](https://nodejs.org/) (v18 or higher)
- [Convex CLI](https://docs.convex.dev/getting-started)
- Clerk account
- Convex account

## 🔧 Step 1: Install Convex CLI

```bash
npm install -g convex
```

## 🗄️ Step 2: Set up Convex Database

### 2.1 Initialize Convex Project
```bash
cd /Users/gabeliss/Desktop/dreamdex
npm install
npx convex dev
```

### 2.2 Create Convex Account
1. Visit [convex.dev](https://convex.dev)
2. Sign up with GitHub/Google
3. Create a new project called "dreamdex"

### 2.3 Deploy Schema and Functions
The schema and functions are already created in `/convex/`. When you run `npx convex dev`, they'll be automatically deployed.

**Database Schema:**
- **dreams** table: User dreams with AI analysis
- **users** table: User profiles and preferences

**Functions:**
- **dreams.ts**: CRUD operations for dreams
- **users.ts**: User management functions

### 2.4 Get Convex URL
After deployment, copy your Convex URL from the dashboard:
```
https://your-deployment-name.convex.cloud
```

## 👤 Step 3: Set up Clerk Authentication

### 3.1 Create Clerk Application
1. Visit [clerk.com](https://clerk.com)
2. Sign up and create a new application
3. Choose "Flutter" as your framework
4. Configure sign-in options:
   - ✅ Email/Password
   - ✅ Google OAuth (optional)
   - ✅ Phone (optional)

### 3.2 Configure Clerk Settings
1. **User Profile**: Enable first name, last name, profile image
2. **Email Settings**: Configure verification emails
3. **Social Connections**: Set up Google OAuth if desired
4. **Webhooks**: Set up user sync webhook (optional)

### 3.3 Get Clerk Keys
From your Clerk dashboard:
- **Publishable Key**: `pk_test_...`
- **Secret Key**: `sk_test_...` (for backend/webhooks only)

## ⚙️ Step 4: Configure Environment Variables

### 4.1 Update your `.env` file:
```bash
cp .env.example .env
```

### 4.2 Add your keys to `.env`:
```env
# Google AI Studio API Key
GOOGLE_AI_STUDIO_API_KEY=your_google_ai_key

# Convex Backend
CONVEX_URL=https://your-deployment-name.convex.cloud

# Clerk Authentication  
CLERK_PUBLISHABLE_KEY=pk_test_your_publishable_key
```

## 📱 Step 5: Update Flutter App

### 5.1 Install Dependencies
```bash
flutter pub get
```

### 5.2 Test Backend Integration
The Flutter app is already configured to use:
- **ConvexService**: For database operations
- **AuthService**: For user authentication
- **Offline-first sync**: Falls back to local storage when offline

## 🚀 Step 6: Run the Full Stack

### 6.1 Start Convex Backend
```bash
# In project root
npx convex dev
```

### 6.2 Start Flutter App
```bash
# In another terminal
flutter run -d chrome
# or
flutter run -d ios
```

## 🔄 Step 7: Data Migration

If you have existing local dreams, they'll automatically sync to Convex when users first sign in.

**Migration Flow:**
1. User signs in with Clerk
2. App detects local dreams
3. Uploads them to Convex
4. Switches to cloud storage
5. Local data becomes backup

## 🎯 Features Enabled

With this backend setup, your app now supports:

### 👥 **Multi-User Features**
- ✅ User registration and login
- ✅ Secure user profiles  
- ✅ Data isolation between users
- ✅ Cross-device synchronization

### 🗄️ **Cloud Storage**
- ✅ Real-time dream syncing
- ✅ Full-text search across dreams
- ✅ Advanced dream analytics
- ✅ Backup and restore

### 🔐 **Security**
- ✅ JWT-based authentication
- ✅ Role-based access control
- ✅ Data encryption in transit
- ✅ Privacy compliance ready

### 📊 **Analytics & Insights**
- ✅ User engagement tracking
- ✅ Dream pattern analysis
- ✅ AI usage statistics
- ✅ Performance metrics

## 🧪 Testing

### Test Authentication Flow
1. Open app in browser/device
2. Click "Sign Up" to create account
3. Verify email if required
4. Sign in with credentials
5. Add a test dream
6. Verify it appears in Convex dashboard

### Test Data Sync
1. Add dream on one device
2. Sign in on another device  
3. Verify dream appears
4. Test offline/online sync

## 🔧 Troubleshooting

### Common Issues

**1. Convex Connection Failed**
- Verify CONVEX_URL in .env
- Check internet connection
- Ensure Convex deployment is running

**2. Clerk Authentication Not Working**
- Verify CLERK_PUBLISHABLE_KEY
- Check Clerk app configuration
- Ensure domain is whitelisted

**3. Dreams Not Syncing**
- Check user authentication status
- Verify Convex functions deployed
- Check browser/app console for errors

**4. Offline Mode Issues**
- Local storage fallback should work
- Check SharedPreferences access
- Verify sync triggers on reconnection

## 📈 Next Steps

### Production Deployment
1. **Convex**: Upgrade to production plan
2. **Clerk**: Configure production domain
3. **Flutter**: Build release APK/IPA
4. **Monitoring**: Set up error tracking

### Advanced Features
1. **Push Notifications**: Dream reminders
2. **AI Webhooks**: Background dream analysis  
3. **Social Features**: Dream sharing
4. **Analytics**: User behavior insights

---

## 🎉 Congratulations!

You now have a fully functional backend for Dreamdex with:
- 🔐 **Secure Authentication** via Clerk
- 🗄️ **Scalable Database** via Convex  
- 🔄 **Real-time Sync** across devices
- 📱 **Offline-first** mobile experience
- 🤖 **AI-ready** infrastructure

Your dream tracking app is now ready for production! 🌙✨