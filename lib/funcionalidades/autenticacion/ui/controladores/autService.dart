import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Instancias compartidas
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }




}
