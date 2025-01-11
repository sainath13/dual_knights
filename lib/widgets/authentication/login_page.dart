import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dual_knights/model/user_model.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  static const id = 'LoginPage';

  final ValueChanged<GameUser> onLoginSuccess;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.brown,
          scaffoldBackgroundColor: const Color(0xFF2E1D13), // Dark medieval parchment
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              fontFamily: 'DualKnights', // Medieval-style font
              fontSize: 18,
              color: Color(0xFFD5B05D), // Gold-like text color
            ),
            bodyMedium: TextStyle(
              fontFamily: 'DualKnights',
              fontSize: 16,
              color: Color(0xFFD5B05D),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4A2E15), // Dark wooden color
            titleTextStyle: TextStyle(
              fontFamily: 'DualKnights',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD5B05D),
              shadows: [
                Shadow(
                  offset: Offset(3, 3),
                  blurRadius: 6,
                  color: Colors.black, // Shadow for text
                ),
              ],
            ),
          ),
        ),
        builder: Authenticator.builder(),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Realm of Dual Knights'),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Medieval emblem or logo
               
                const Text(
                  'Welcome to the Realm!',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'DualKnights',
                    color: Color(0xFFD5B05D),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(3, 3),
                        blurRadius: 6,
                        color: Colors.black, // Shadow for medieval text
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                medievalButton('Play Game', () async {
                  final user = await Amplify.Auth.getCurrentUser();
                  final attributes = await Amplify.Auth.fetchUserAttributes();
                  String? email;
                  for (var attribute in attributes) {
                    if (attribute.userAttributeKey == AuthUserAttributeKey.email) {
                      email = attribute.value;
                      break;
                    }
                  }
                  final gameUser = GameUser(
                    userId: user.username,
                    email: email ?? '',
                  );

                  onLoginSuccess(gameUser);
                }),
                const SizedBox(height: 20),
                medievalButton('Sign Out', () async {
                  await Amplify.Auth.signOut();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method for medieval-themed buttons
  Widget medievalButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: 250,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF5E3D24), // Wooden button background
          side: const BorderSide(color: Color(0xFFD5B05D), width: 2), // Gold border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Slightly rounded
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'DualKnights',
            fontSize: 18,
            color: Color(0xFFD5B05D), // Gold text
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: Colors.black, // Shadow for text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
