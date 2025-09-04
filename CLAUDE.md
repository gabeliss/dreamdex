# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Core Flutter Commands:**
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app (add `-d chrome` for web, `-d ios` for iOS)
- `flutter run --hot` - Run with hot reload enabled
- `flutter test` - Run unit tests
- `flutter analyze` - Run static analysis/linting
- `flutter clean && flutter pub get` - Clean build and reinstall dependencies

**Backend Commands:**
- `npm install` - Install Convex backend dependencies  
- `npx convex dev` - Start Convex backend development server
- `npx convex codegen` - Generate Convex type definitions

**Common Development Tasks:**
- To test on web: `flutter run -d chrome`
- To build for release: `flutter build apk` (Android) or `flutter build ios` (iOS)
- To reset everything: `flutter clean && flutter pub get && npx convex codegen`

## Architecture Overview

**Tech Stack:**
- **Frontend**: Flutter with Dart
- **Backend**: Convex DB for real-time data sync
- **Authentication**: Clerk for user management
- **AI Services**: Google AI Studio for dream analysis and image generation
- **State Management**: Provider pattern with ChangeNotifier services

**Key Architecture Patterns:**
- **Service Layer**: Business logic separated into services (DreamService, AuthService, ConvexService, AIService, SpeechService)
- **Provider Pattern**: State management using Provider with ChangeNotifier for reactive UI updates
- **Offline-First**: Local storage with SharedPreferences, syncs to Convex when online
- **Multi-Provider Setup**: Hierarchical providers with ProxyProviders for service dependencies

**Core Services:**
- `DreamService`: Manages CRUD operations for dreams, handles offline/online sync
- `AuthService`: Handles Clerk authentication, user session management
- `ConvexService`: Real-time database operations with Convex backend
- `AIService`: Integrates with Google AI Studio for analysis and image generation
- `SpeechService`: Speech-to-text functionality for voice dream recording

**Data Flow:**
1. User actions trigger service methods
2. Services update local state and notify listeners
3. UI components rebuild automatically via Provider
4. Data syncs to Convex backend when online
5. Real-time updates propagate to all connected clients

**Key Models:**
- `Dream`: Main data model with AI analysis, image URLs, and metadata
- `DreamType`: Enum for dream categorization (Normal, Lucid, Nightmare, etc.)
- Convex schema defines backend data structure with indexing for search

**Backend Structure:**
- `convex/schema.ts`: Database schema with dreams and users tables
- `convex/dreams.ts`: CRUD functions for dream operations  
- `convex/users.ts`: User management and preferences
- Full-text search enabled on dream content and titles

**Environment Setup:**
- `.env` file required with `GOOGLE_AI_STUDIO_API_KEY`, `CONVEX_URL`, `CLERK_PUBLISHABLE_KEY`
- Font assets (Poppins family) required in `assets/fonts/`
- Permissions configured for microphone access (speech-to-text)

**Testing Strategy:**
- Unit tests in `/test` directory
- Use `flutter test` to run all tests
- Widget tests for UI components
- Service tests for business logic

## Important Notes

- Always run `flutter pub get` after pulling changes
- Backend requires `npx convex dev` to be running for full functionality
- App works offline but sync requires active Convex connection
- AI features require valid Google AI Studio API key
- Voice recording requires microphone permissions on device
- Uses hot reload for fast development iteration