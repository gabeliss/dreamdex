import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation.dart';
import 'screens/auth/welcome_screen.dart';
import 'services/dream_service.dart';
import 'services/speech_service.dart';
import 'services/ai_service.dart';
import 'services/convex_service.dart';
import 'services/subscription_service.dart';
import 'services/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Load environment variables based on build mode
  await dotenv.load(fileName: kReleaseMode ? ".env" : ".env.local");
  
  // Initialize RevenueCat
  final revenueCatApiKey = dotenv.env['REVENUECAT_API_KEY'];
  if (revenueCatApiKey != null && revenueCatApiKey.isNotEmpty) {
    try {
      await SubscriptionService.initialize(
        apiKey: revenueCatApiKey,
        enableDebugLogs: false, // Set to false in production
      );
      debugPrint("RevenueCat initialized successfully");
    } catch (e) {
      debugPrint("RevenueCat initialization failed: $e");
    }
  } else {
    debugPrint("RevenueCat API key not found in .env file");
  }
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const DreamdexApp());
}

class DreamdexApp extends StatelessWidget {
  const DreamdexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
          ChangeNotifierProvider(create: (_) => ConvexService()),
          ChangeNotifierProvider(create: (_) => SubscriptionService()),
          ChangeNotifierProxyProvider2<ConvexService, FirebaseAuthService, DreamService>(
            create: (context) => DreamService(
              context.read<ConvexService>(),
              context.read<FirebaseAuthService>(),
            ),
            update: (context, convexService, authService, previous) {
              return previous ?? DreamService(convexService, authService);
            },
          ),
          ChangeNotifierProvider(create: (_) => SpeechService()),
          ChangeNotifierProxyProvider<ConvexService, AIService>(
            create: (context) => AIService(context.read<ConvexService>()),
            update: (context, convexService, previous) {
              return previous ?? AIService(convexService);
            },
          ),
        ],
        child: MaterialApp(
          title: 'Dreamdex',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: const AuthGate(),
        ),
      );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    // Force rebuild by adding a listener to the same service the login screen uses
    return Consumer<FirebaseAuthService>(
      builder: (context, authService, child) {
        debugPrint('AuthGate Consumer: Using authService instance: ${authService.hashCode}');
        if (!authService.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        debugPrint('=== AUTHGATE BUILD ===');
        debugPrint('AuthService initialized: ${authService.isInitialized}');
        debugPrint('AuthService authenticated: ${authService.isAuthenticated}');
        debugPrint('Current user: ${authService.currentUser?.email}');
        
        if (authService.isAuthenticated) {
          final user = authService.currentUser!;
          debugPrint('=== AUTHGATE EVALUATION ===');
          debugPrint('Firebase Auth: User is signed in');
          debugPrint('User: ${user.email}');
          debugPrint('User ID: ${user.uid}');
          debugPrint('Email verified: ${user.emailVerified}');
          
          // Require email verification
          if (!user.emailVerified) {
            debugPrint('AuthGate: Email not verified, showing welcome screen');
            return const WelcomeScreen();
          }
          
          debugPrint('AuthGate: User verified, showing MainNavigation');
          
          // CRITICAL: Set userId IMMEDIATELY to prevent security issues
          final convexService = Provider.of<ConvexService>(context, listen: false);
          final dreamService = Provider.of<DreamService>(context, listen: false);
          final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
          
          // Set userId synchronously before UI loads
          convexService.setUserId(user.uid);
          debugPrint('Set userId in ConvexService: ${user.uid}');
          
          // Set up other services asynchronously
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Initialize and set user in subscription service
            subscriptionService.initializeService().then((_) {
              subscriptionService.setUserId(user.uid);
              debugPrint('Initialized subscription service for user: ${user.uid}');
            });
            
            // Sync user to Convex backend
            convexService.upsertUser(
              authId: user.uid, // Using Firebase UID as identifier
              email: user.email ?? '',
              firstName: user.displayName?.split(' ').first,
              lastName: user.displayName?.split(' ').skip(1).join(' '),
              profileImageUrl: user.photoURL,
            );
            
            // Refresh dreams after setting userId
            dreamService.refreshDreams();
            debugPrint('Refreshing dreams after authentication');
          });
          
          return const MainNavigation();
        } else {
          debugPrint('Firebase Auth: User is signed out');
          return const WelcomeScreen();
        }
      },
    );
  }
}