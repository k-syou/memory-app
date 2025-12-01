import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    hostedDomain: null,
  );

  // 현재 사용자 가져오기
  static User? get currentUser => _auth.currentUser;

  // 인증 상태 변경 스트림
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Google 로그인
  static Future<UserCredential> signInWithGoogle() async {
    try {
      // Google 로그인 진행
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google 로그인이 취소되었습니다');
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 정보 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final userCredential = await _auth.signInWithCredential(credential);

      // Firestore에 사용자 정보 저장 (처음 로그인한 경우만)
      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // 새 사용자 정보 저장
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'userId': userCredential.user!.uid,
                'email': userCredential.user!.email ?? '',
                'displayName': userCredential.user!.displayName ?? '',
                'photoUrl': userCredential.user!.photoURL,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
                'settings': {'darkMode': false, 'language': 'ko'},
              });
        } else {
          // 기존 사용자 정보 업데이트
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({
                'updatedAt': FieldValue.serverTimestamp(),
                'displayName': userCredential.user!.displayName ?? '',
                'photoUrl': userCredential.user!.photoURL,
              });
        }
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // 로그아웃
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 사용자 정보 업데이트
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();

    // Firestore도 업데이트
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null) {
      updateData['displayName'] = displayName;
    }
    if (photoUrl != null) {
      updateData['photoUrl'] = photoUrl;
    }

    await _firestore.collection('users').doc(user.uid).update(updateData);
  }

  // 사용자 정보 가져오기 (Firestore)
  static Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }
}
