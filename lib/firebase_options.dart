// ARQUIVO PROVISÓRIO.
// Substitua rodando, na raiz do projeto:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// O comando sobrescreve este arquivo com as chaves reais do seu projeto Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'COLE_O_apiKey', // começa com AIza...
    appId: 'COLE_O_appId', // formato 1:123456:web:abc123
    messagingSenderId: 'COLE_O_messagingSenderId', // só números
    projectId: 'cantina-aaaee',
    authDomain: 'cantina-aaaee.firebaseapp.com',
    storageBucket: 'cantina-aaaee.firebasestorage.app',
  );
}
