import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hurry_app_twitch_clone/providers/user_provider.dart';
import 'package:hurry_app_twitch_clone/resources/auth_methods.dart';
import 'package:hurry_app_twitch_clone/screens/home_screen.dart';
import 'package:hurry_app_twitch_clone/screens/login_screen.dart';
import 'package:hurry_app_twitch_clone/screens/onboarding_screen.dart';
import 'package:hurry_app_twitch_clone/screens/signup_screen.dart';
import 'package:hurry_app_twitch_clone/utils/colors.dart';
import 'package:hurry_app_twitch_clone/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'models/user.dart' as model;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBizS1MugnEw6op4xiqvXWC1aw6Y7Va4i4",
        authDomain: "twitch-clone-tutorial.firebaseapp.com",
        projectId: "twitch-clone-tutorial",
        storageBucket: "twitch-clone-tutorial.appspot.com",
        messagingSenderId: "238752454769",
        appId: "1:238752454769:web:c7d31e54b7fce341d563d0",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Twitch Clone Tutorial',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: backgroundColor,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: primaryColor,
          ),
        ),
      ),
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      home: FutureBuilder(
        future: AuthMethods()
            .getCurrentUser(FirebaseAuth.instance.currentUser != null
            ? FirebaseAuth.instance.currentUser!.uid
            : null)
            .then((value) {
          if (value != null) {
            Provider.of<UserProvider>(context, listen: false).setUser(
              model.User.fromMap(value),
            );
          }
          return value;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
