import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation.dart';
import 'screens/auth/welcome_screen.dart';
import 'services/dream_service.dart';
import 'services/speech_service.dart';
import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'services/convex_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
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
    final publishableKey = dotenv.env['CLERK_PUBLISHABLE_KEY'];
    
    if (publishableKey == null || publishableKey.isEmpty) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'CLERK_PUBLISHABLE_KEY not found',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                Text('Please add your Clerk publishable key to .env file'),
              ],
            ),
          ),
        ),
      );
    }

    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: publishableKey),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConvexService()),
          ChangeNotifierProxyProvider<ConvexService, DreamService>(
            create: (context) => DreamService(
              context.read<ConvexService>(),
              null, // No longer need AuthService since Clerk handles it
            ),
            update: (context, convexService, previous) {
              return previous ?? DreamService(convexService, null);
            },
          ),
          ChangeNotifierProvider(create: (_) => SpeechService()),
          ChangeNotifierProvider(create: (_) => AIService()),
        ],
        child: MaterialApp(
          title: 'Dreamdex',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: const AuthGate(),
        ),
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
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) {
        debugPrint('ClerkAuthBuilder: User is signed in');
        debugPrint('User: ${authState.user}');
        debugPrint('Sessions: ${authState.client?.sessions?.length ?? 0}');
        
        // Set userId in ConvexService for existing authenticated users
        if (authState.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final convexService = Provider.of<ConvexService>(context, listen: false);
            final dreamService = Provider.of<DreamService>(context, listen: false);
            convexService.setUserId(authState.user!.id);
            debugPrint('Set userId in ConvexService: ${authState.user!.id}');
            
            // Refresh dreams after setting userId
            dreamService.refreshDreams();
            debugPrint('Refreshing dreams after authentication');
          });
        }
        
        return const MainNavigation();
      },
      signedOutBuilder: (context, authState) {
        debugPrint('ClerkAuthBuilder: User is signed out');
        debugPrint('Client sessions: ${authState.client?.sessions?.length ?? 0}');
        return const WelcomeScreen();
      },
    );
  }
}