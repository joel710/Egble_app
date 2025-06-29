# Guide de connexion Firebase à ton app Flutter (TikTok-like)

## 1. Crée ton projet Firebase
- Va sur https://console.firebase.google.com/
- Clique sur "Ajouter un projet" et suis les étapes (nom, analytics, etc).

## 2. Ajoute une app Android/iOS
- Clique sur l'icône Android ou iOS dans le dashboard Firebase.
- Suis les instructions (nom du package, SHA-1 pour Android, etc).
- Télécharge le fichier `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS) et place-le dans le bon dossier de ton projet Flutter :
  - Android : `android/app/`
  - iOS : `ios/Runner/`

## 3. Ajoute les dépendances Firebase à ton `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.6.7
  firebase_messaging: ^14.7.10
```
Puis lance :
```sh
flutter pub get
```

## 4. Configure Android
- Dans `android/build.gradle` :
  - Ajoute `classpath 'com.google.gms:google-services:4.3.15'` dans `dependencies`.
- Dans `android/app/build.gradle` :
  - Ajoute tout en bas :
    ```gradle
    apply plugin: 'com.google.gms.google-services'
    ```

## 5. Configure iOS
- Ouvre `ios/Runner.xcworkspace` dans Xcode.
- Va dans "Signing & Capabilities" et ajoute ton Team.
- Lance :
  ```sh
  cd ios
  pod install
  cd ..
  ```

## 6. Initialise Firebase dans ton app Flutter
Dans `main.dart` :
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

## 7. Teste la connexion
Dans n'importe quel widget :
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// ...
FirebaseFirestore.instance.collection('test').add({'hello': 'world'});
```
Va voir dans Firestore si le doc apparaît !

## 8. (Optionnel) Authentification
```dart
import 'package:firebase_auth/firebase_auth.dart';

// Inscription
await FirebaseAuth.instance.createUserWithEmailAndPassword(email: 'test@mail.com', password: '123456');
// Connexion
await FirebaseAuth.instance.signInWithEmailAndPassword(email: 'test@mail.com', password: '123456');
```

## 9. (Optionnel) Upload de vidéo
```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

final file = File('chemin/vers/video.mp4');
final ref = FirebaseStorage.instance.ref().child('videos/monfichier.mp4');
await ref.putFile(file);
final url = await ref.getDownloadURL();
```

## 10. (Optionnel) Règles de sécurité
Dans Firebase Console > Firestore/Storage > Règles, adapte pour protéger tes données !

---

**Voilà, tu as une base Firebase prête pour ton app TikTok-like !**
N'hésite pas à demander si tu veux des exemples pour les likes, commentaires, feed, etc. 