// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:sereports/constants.dart';
// import 'package:sereports/screen/auth_screen/otp_verification.dart';
// import 'package:sereports/widget/snackbar.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({Key? key}) : super(key: key);

//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final TextEditingController _emailController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),

//               // Forgot Password Text
//               const Text(
//                 'Forgot Password?',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Instruction Text
//               const Text(
//                 'Enter your email address to get the password reset link',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               SizedBox(
//                 height: 50,
//                 child: TextField(
//                   controller: _emailController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     hintText: 'john@gmail.com',
//                     hintStyle: TextStyle(color: grayColorForHintText),
//                     filled: true,
//                     fillColor: Colors.white,
//                     enabledBorder: kDefaultInputBorder,
//                     focusedBorder: kDefaultFocusInputBorder,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               // Password Reset Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle password reset logic
//                     String email = _emailController.text.trim();

//                     if (email.isNotEmpty) {
//                       print('Password reset requested for: $email');

//                       showCustomSnackBar(
//                           context, 'OTP has been sent to $email', successColor);
//                     } else {
//                       showCustomSnackBar(context,
//                           'Please enter your email address', errorColor);
//                       // Show error if email is empty
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Please enter your email address'),
//                           backgroundColor: errorColor,
//                         ),
//                       );
//                     }

//                     Navigator.of(context).pushReplacement(MaterialPageRoute(
//                         builder: (context) => const OtpVerificationScreen()));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: kButtonColor, // Royal blue color
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(radiusValue),
//                     ),
//                   ),
//                   child: const Text(
//                     'Password Reset',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Example of how to navigate to this screen from your login page
// void navigateToForgotPassword(BuildContext context) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => const ForgotPasswordScreen(),
//     ),
//   );
// }
