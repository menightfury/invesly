import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/people/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

const List<String> scopes = <String>[PeopleServiceApi.contactsReadonlyScope];

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  late Future<void> _signInInitialized;
  GoogleSignInAccount? _currentUser;
  GoogleSignInClientAuthorization? _authorization;
  String _contactText = '';

  @override
  void initState() {
    super.initState();

    final GoogleSignIn signIn = GoogleSignIn.instance;
    _signInInitialized = signIn.initialize(
      // Add your client IDs here as necessary for your supported platforms.
    );
    signIn.authenticationEvents
        .listen((event) {
          if (!mounted) {
            return;
          }
          setState(() {
            switch (event) {
              case GoogleSignInAuthenticationEventSignIn():
                _currentUser = event.user;
              case GoogleSignInAuthenticationEventSignOut():
                _currentUser = null;
                _authorization = null;
            }
          });

          if (_currentUser != null) {
            _checkAuthorization();
          }
        })
        .onError((Object error) {
          debugPrint(error.toString());
        });

    _signInInitialized.then((void value) {
      signIn.attemptLightweightAuthentication();
    });
  }

  void _updateAuthorization(GoogleSignInClientAuthorization? authorization) {
    if (!mounted) {
      return;
    }
    setState(() {
      _authorization = authorization;
    });

    if (authorization != null) {
      unawaited(_handleGetContact(authorization));
    }
  }

  Future<void> _checkAuthorization() async {
    _updateAuthorization(await _currentUser?.authorizationClient.authorizationForScopes(scopes));
  }

  Future<void> _requestAuthorization() async {
    _updateAuthorization(
      await _currentUser?.authorizationClient.authorizeScopes(<String>[PeopleServiceApi.contactsReadonlyScope]),
    );
  }

  Future<void> _handleGetContact(GoogleSignInClientAuthorization authorization) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _contactText = 'Loading contact info...';
    });

    // #docregion CreateAPIClient
    // Retrieve an [auth.AuthClient] from a GoogleSignInClientAuthorization.
    final auth.AuthClient client = authorization.authClient(scopes: scopes);

    // Prepare a People Service authenticated client.
    final PeopleServiceApi peopleApi = PeopleServiceApi(client);
    // Retrieve a list of connected contacts' names.
    final ListConnectionsResponse response = await peopleApi.people.connections.list(
      'people/me',
      personFields: 'names',
    );
    // #enddocregion CreateAPIClient

    final String? firstNamedContactName = _pickFirstNamedContact(response.connections);

    if (mounted) {
      setState(() {
        if (firstNamedContactName != null) {
          _contactText = 'I see you know $firstNamedContactName!';
        } else {
          _contactText = 'No contacts to display.';
        }
      });
    }
  }

  String? _pickFirstNamedContact(List<Person>? connections) {
    return connections
        ?.firstWhere((Person person) => person.names != null)
        .names
        ?.firstWhere((Name name) => name.displayName != null)
        .displayName;
  }

  Future<void> _handleSignIn() async {
    try {
      await GoogleSignIn.instance.authenticate();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  // Call disconnect rather than signOut to more fully reset the example app.
  Future<void> _handleSignOut() => GoogleSignIn.instance.disconnect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign In + googleapis')),
      body: FutureBuilder<void>(
        future: _signInInitialized,
        builder: (context, snapshot) {
          final GoogleSignInAccount? user = _currentUser;
          final GoogleSignInClientAuthorization? authorization = _authorization;
          final List<Widget> children;
          if (snapshot.hasError) {
            children = <Widget>[const Text('Error initializing sign in.')];
          } else if (snapshot.connectionState == ConnectionState.done) {
            children = <Widget>[
              if (user != null) ...<Widget>[
                ListTile(
                  leading: GoogleUserCircleAvatar(identity: user),
                  title: Text(user.displayName ?? ''),
                  subtitle: Text(user.email),
                ),
                const Text('Signed in successfully.'),
                if (authorization != null) ...<Widget>[
                  Text(_contactText),
                  ElevatedButton(onPressed: () => _handleGetContact(authorization), child: const Text('REFRESH')),
                ] else ...<Widget>[
                  ElevatedButton(onPressed: _requestAuthorization, child: const Text('LOAD CONTACTS')),
                ],
                ElevatedButton(onPressed: _handleSignOut, child: const Text('SIGN OUT')),
              ] else ...<Widget>[
                const Text('You are not currently signed in.'),
                ElevatedButton(onPressed: _handleSignIn, child: const Text('SIGN IN')),
              ],
            ];
          } else {
            children = <Widget>[const CircularProgressIndicator()];
          }

          return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: children);
        },
      ),
    );
  }
}
