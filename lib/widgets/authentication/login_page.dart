import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {

  static const id = 'LoginPage';
  
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key,
    required this.onLoginSuccess,
  });

  Future<void> _printUserData() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      safePrint('====== User Information ======');
      safePrint('User ID: ${user.userId}');
      safePrint('Username: ${user.username}');

      final attributes = await Amplify.Auth.fetchUserAttributes();
      safePrint('====== User Attributes ======');
      for (final attribute in attributes) {
        safePrint('${attribute.userAttributeKey}: ${attribute.value}');
      }

      final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final session = await cognitoPlugin.fetchAuthSession();
      safePrint('====== Session Information ======');
      safePrint('Is Signed In: ${session.isSignedIn}');

      final tokens = session.userPoolTokensResult.value;
      safePrint('Access Token: ${tokens.accessToken.raw}');
      safePrint('ID Token: ${tokens.idToken.raw}');
      safePrint('Refresh Token Available: ${tokens.refreshToken != null}');

    } on AuthException catch (e) {
      safePrint('Error fetching user data: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('AWS Cognito Auth'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Successfully logged in!',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _printUserData,
                  child: const Text('Show User Data'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onLoginSuccess,
                  child: const Text('Play Game'),
                ),
                const SizedBox(height: 20),
                const SignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
