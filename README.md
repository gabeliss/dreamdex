# 🌙 Dreamdex

A beautiful mobile app for tracking and analyzing dreams with AI-powered insights and image generation.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![AI](https://img.shields.io/badge/AI-Powered-purple?style=for-the-badge)

## ✨ Features

### 🎯 Core Features
- **Voice-to-Text Dream Recording**: Capture dreams using speech recognition
- **Dream Journal**: Organize dreams by date, type, and categories
- **AI Dream Analysis**: Automatic analysis of themes, characters, locations, and emotions
- **AI-Generated Dream Images**: Create visual representations of your dreams using Google AI Studio
- **Dream Types**: Categorize dreams (Normal, Lucid, Nightmare, Recurring, Prophetic, Healing)
- **Search & Filter**: Find specific dreams quickly
- **Favorites**: Mark and organize your most meaningful dreams
- **Statistics Dashboard**: Track your dream patterns over time

### 🎨 Design Features
- **Dreamy UI/UX**: Beautiful gradients and animations
- **Dark/Light Themes**: Comfortable viewing experience
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Design**: Works perfectly on all screen sizes
- **Keyboard-Aware**: Smart scrolling when typing

## 📱 Screenshots

*Screenshots will be added once the app is running*

## 🚀 Getting Started

### Prerequisites

Before running the app, make sure you have:

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (version 3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- A physical device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dreamdex.git
   cd dreamdex
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add Font Assets**
   
   Download the Poppins font family and add the following files to `assets/fonts/`:
   - `Poppins-Light.ttf`
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`
   
   You can download Poppins from [Google Fonts](https://fonts.google.com/specimen/Poppins).

4. **Set up Google AI Studio (for image generation)**
   
   a. Go to [Google AI Studio](https://aistudio.google.com/)
   
   b. Create a new project or use an existing one
   
   c. Get your API key from the API Keys section
   
   d. Create a `.env` file in the root directory:
   ```env
   GOOGLE_AI_STUDIO_API_KEY=your_api_key_here
   ```

5. **Configure Permissions**
   
   **For Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.MICROPHONE" />
   ```
   
   **For iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs access to microphone to record your dreams</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>This app needs access to speech recognition to convert your voice to text</string>
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

### Development Setup

For development, you might also want to:

1. **Enable Flutter Inspector**
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

2. **Run with hot reload**
   ```bash
   flutter run --hot
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

## 🏗️ Project Structure

```
dreamdex/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   └── dream.dart           # Dream and analysis models
│   ├── screens/                 # UI screens
│   │   ├── main_navigation.dart # Bottom navigation
│   │   ├── home_screen.dart     # Dreams list
│   │   ├── add_dream_screen.dart # Add new dream
│   │   ├── dream_detail_screen.dart # Dream details
│   │   └── profile_screen.dart  # User profile
│   ├── services/                # Business logic
│   │   ├── dream_service.dart   # Dream CRUD operations
│   │   ├── speech_service.dart  # Speech-to-text
│   │   └── ai_service.dart      # Google AI Studio integration
│   ├── theme/                   # App theming
│   │   ├── app_colors.dart      # Color palette
│   │   └── app_theme.dart       # Theme configuration
│   ├── widgets/                 # Reusable components
│   │   ├── dream_card.dart      # Dream list item
│   │   ├── stats_card.dart      # Statistics display
│   │   └── dream_image_widget.dart # AI image display
│   └── utils/                   # Helper utilities
├── assets/                      # Static assets
│   ├── fonts/                   # Font files
│   ├── images/                  # App images
│   └── icons/                   # App icons
├── android/                     # Android configuration
├── ios/                         # iOS configuration
├── .env                         # Environment variables
├── pubspec.yaml                 # Dependencies
└── README.md                    # This file
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory with:

```env
GOOGLE_AI_STUDIO_API_KEY=your_api_key_here
```

### API Keys Setup

1. **Google AI Studio**:
   - Visit [Google AI Studio](https://aistudio.google.com/)
   - Create/select a project
   - Generate an API key
   - Add it to your `.env` file

## 📦 Dependencies

### Core Dependencies
- `flutter`: UI framework
- `provider`: State management
- `shared_preferences`: Local storage
- `intl`: Internationalization

### AI & Speech
- `speech_to_text`: Voice recognition
- `http`: API calls
- `flutter_dotenv`: Environment variables

### UI & Animation
- `flutter_animate`: Smooth animations
- `flutter_staggered_animations`: List animations

### Permissions
- `permission_handler`: Runtime permissions

### Utilities
- `uuid`: Unique ID generation

## 🎯 Usage Guide

### Recording a Dream

1. **Open the app** and tap the "Add Dream" tab
2. **Choose dream type** from the available options
3. **Record your dream**:
   - Tap the microphone button to start voice recording
   - Speak clearly about your dream
   - Tap stop when finished
4. **Edit if needed** in the text fields
5. **Generate AI image** (optional):
   - Tap "Generate Dream Image"
   - Wait for the AI to create a visual representation
6. **Save your dream**

### Viewing Dreams

1. **Home screen** shows all your dreams
2. **Search** using the search bar
3. **Tap any dream** to view details
4. **View different tabs**:
   - Dream: Main content and details
   - Transcript: Raw voice recording text
   - Analysis: AI-generated insights (when available)

### Managing Dreams

- **Favorite**: Tap the heart icon
- **Delete**: Use the menu in dream details
- **Search**: Use the search bar on home screen
- **Filter**: View by dream type or date range

## 🔮 AI Features

### Dream Analysis
The app can analyze your dreams for:
- **Themes**: Recurring topics and concepts
- **Characters**: People appearing in dreams
- **Locations**: Places and settings
- **Emotions**: Emotional content and intensity
- **Lucidity Score**: How aware you were in the dream

### Image Generation
Using Google AI Studio's image generation:
- Automatically creates visual representations
- Based on your dream description
- Saves images locally for offline viewing
- High-quality artistic interpretations

## 🚨 Troubleshooting

### Common Issues

**1. Voice recording not working**
- Check microphone permissions
- Ensure device has a working microphone
- Try restarting the app

**2. AI image generation fails**
- Verify your Google AI Studio API key
- Check internet connection
- Ensure API quota isn't exceeded

**3. App crashes on startup**
- Run `flutter clean && flutter pub get`
- Check Flutter and Dart versions
- Verify all dependencies are properly installed

**4. Fonts not displaying correctly**
- Ensure Poppins font files are in `assets/fonts/`
- Run `flutter pub get` after adding fonts
- Clean and rebuild the app

### Performance Tips

- **Storage**: Dreams are stored locally using SharedPreferences
- **Memory**: Images are cached efficiently
- **Battery**: Voice recording automatically stops after 5 minutes
- **Network**: AI features require internet connection

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter team** for the amazing framework
- **Google AI Studio** for image generation capabilities
- **Font**: Poppins by Google Fonts
- **Icons**: Material Design Icons
- **Inspiration**: The fascinating world of dreams and AI

## 📞 Support

If you encounter any issues or have questions:

- **GitHub Issues**: [Create an issue](https://github.com/yourusername/dreamdex/issues)
- **Email**: your-email@example.com
- **Documentation**: Check this README and inline code comments

---

**Made with ❤️ and lots of ☕**

*Sweet dreams! 🌙✨*