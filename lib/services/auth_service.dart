import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static String verifyId = "";
  // to sent and otp to user
  static Future sentOtp({
    required String phone,
    required Function errorStep,
    required Function nextStep,
  }) async {
    await _firebaseAuth
        .verifyPhoneNumber(
      timeout: Duration(seconds: 30),
      phoneNumber: "+$phone",
      verificationCompleted: (phoneAuthCredential) async {
        return;
      },
      verificationFailed: (error) async {
        return;
      },
      codeSent: (verificationId, forceResendingToken) async {
        verifyId = verificationId;
        nextStep();
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        return;
      },
    )
        .onError((error, stackTrace) {
      errorStep();
    });
  }

  // verify the otp code and login
  static Future loginWithOtp(
      {required String otp, required String phone}) async {
    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    try {
      final user = await _firebaseAuth.signInWithCredential(cred);
      if (user.user != null) {
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setInt('lastLogin', DateTime.now().millisecondsSinceEpoch);
        // await prefs.setString('userPhone', phone); // Store the phone number
        return "Success";
      } else {
        return "Error in Otp login";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  // to logout the user
  static Future logout() async {
    // Clear SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('lastLogin');
    // await prefs.remove('userPhone');
    await _firebaseAuth.signOut();
  }

  // check whether the user is logged in or not
  static Future<bool> isLoggedIn() async {
    // final prefs = await SharedPreferences.getInstance();
    // final lastLogin = prefs.getInt('lastLogin');
    // final userPhone =
    //     prefs.getString('userPhone'); // Get the stored phone number
    // if (lastLogin == null || userPhone == null) return false;
    // final oneYearAgo =
    //     DateTime.now().subtract(Duration(days: 365)).millisecondsSinceEpoch;
    // return lastLogin >= oneYearAgo; // Check if the last login was within a year

    var user = _firebaseAuth.currentUser;
    return user != null;
  }
}
