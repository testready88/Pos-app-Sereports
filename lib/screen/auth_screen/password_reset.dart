// // ignore_for_file: avoid_unnecessary_containers

// import 'package:flutter/material.dart';
// import 'package:sereports/constants.dart';
// import 'package:sereports/widget/snackbar.dart';

// class PasswordResetScreen extends StatefulWidget {
//   const PasswordResetScreen({super.key});

//   @override
//   State<PasswordResetScreen> createState() => _PasswordResetScreenState();
// }

// class _PasswordResetScreenState extends State<PasswordResetScreen> {
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _passwordConfirmController =
//       TextEditingController();

//   @override
//   void dispose() {
//     _passwordConfirmController.dispose();
//     _passwordController.dispose();
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
//             children: [
//               const SizedBox(height: 20),

//               // Verification Title
//               const Text(
//                 'New Password',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),

//               Container(
//                 child: Image.asset(
//                   'assets/icons/passowrdreset.png',
//                   fit: BoxFit.cover,
//                   gaplessPlayback: true,
//                   height: MediaQuery.of(context).size.height * 0.3,
//                   width: MediaQuery.of(context).size.width * 0.3,
//                 ),
//               ),

//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 50,
//                 child: TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     hintText: 'New Password',
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
//               const SizedBox(height: 15),
//               SizedBox(
//                 height: 50,
//                 child: TextField(
//                   controller: _passwordConfirmController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     hintText: 'Confirm Password',
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

//               // Verify Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     showCustomSnackBar(
//                         context,
//                         'Password reset successful! Please log in again',
//                         successColor);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: kButtonColor, // Royal blue color
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(radiusValue),
//                     ),
//                   ),
//                   child: const Text(
//                     'Send',
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
