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

      // idToken이 없으면 에러
      if (googleAuth.idToken == null) {
        throw Exception(
            'Google 인증 토큰을 가져올 수 없습니다. Firebase Console에서 OAuth 클라이언트 ID를 확인해주세요.');
      }

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
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 에러 처리
      String errorMessage = '로그인 중 오류가 발생했습니다.';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = '이 이메일은 다른 로그인 방법으로 이미 등록되어 있습니다.';
          break;
        case 'invalid-credential':
          errorMessage = '유효하지 않은 인증 정보입니다.';
          break;
        case 'operation-not-allowed':
          errorMessage = '이 로그인 방법이 허용되지 않습니다.';
          break;
        case 'user-disabled':
          errorMessage = '이 계정은 비활성화되었습니다.';
          break;
        case 'user-not-found':
          errorMessage = '사용자를 찾을 수 없습니다.';
          break;
        case 'wrong-password':
          errorMessage = '잘못된 비밀번호입니다.';
          break;
        default:
          errorMessage = '로그인 중 오류가 발생했습니다: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // PlatformException 처리 (Google Sign-In 에러)
      final errorString = e.toString();
      if (errorString.contains('ApiException: 10')) {
        throw Exception(
            'Google 로그인 설정 오류입니다.\n\n해결 방법:\n1. Firebase Console에서 OAuth 클라이언트 ID가 설정되어 있는지 확인하세요.\n2. SHA-1 지문이 Firebase Console에 등록되어 있는지 확인하세요.\n3. google-services.json 파일이 최신인지 확인하세요.');
      } else if (errorString.contains('sign_in_failed')) {
        throw Exception(
            'Google 로그인에 실패했습니다.\n\n해결 방법:\n1. Firebase Console → Authentication → Sign-in method에서 Google이 활성화되어 있는지 확인하세요.\n2. SHA-1 지문을 Firebase Console에 추가하세요.\n3. 앱을 다시 빌드하고 실행하세요.');
      }
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
