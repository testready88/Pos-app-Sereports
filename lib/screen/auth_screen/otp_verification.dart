// // ignore_for_file: avoid_unnecessary_containers, avoid_print

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sereports/constants.dart';
// import 'package:sereports/screen/auth_screen/password_reset.dart';
// import 'package:sereports/widget/snackbar.dart';

// class OtpVerificationScreen extends StatefulWidget {
//   const OtpVerificationScreen({Key? key}) : super(key: key);

//   @override
//   _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   // Controllers for each OTP field
//   final List<TextEditingController> _controllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );

//   // Focus nodes for each OTP field
//   final List<FocusNode> _focusNodes = List.generate(
//     6,
//     (index) => FocusNode(),
//   );

//   String get _otpValue {
//     return _controllers.map((controller) => controller.text).join();
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
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
//                 'Verification',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),

//               Container(
//                 child: Image.asset(
//                   'assets/icons/otp.png',
//                   fit: BoxFit.cover,
//                   gaplessPlayback: true,
//                   height: MediaQuery.of(context).size.height * 0.3,
//                   width: MediaQuery.of(context).size.width * 0.3,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               // Enter Verification Code Text
//               const Text(
//                 'Enter Verification Code',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // OTP Input Fields
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(
//                   6,
//                   (index) => _buildOtpField(index),
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // Resend Code Option
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "If you didn't recover a code, ",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Handle resend logic
//                       print('Resending verification code');
//                     },
//                     child: const Text(
//                       'Resend',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.blue,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 30),

//               // Verify Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle verification
//                     final otp = _otpValue;

//                     print('Verifying OTP: $otp');
//                     showCustomSnackBar(
//                         context,
//                         'Your email is verified! You can now change your password',
//                         successColor);
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(
//                         builder: (context) => const PasswordResetScreen()));
//                     // } else {
//                     //   showCustomSnackBar(
//                     //       context, 'Invalid OTP! Please try again', errorColor);
//                     // }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: kButtonColor, // Royal blue color
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(radiusValue),
//                     ),
//                   ),
//                   child: const Text(
//                     'Verify',
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

//   Widget _buildOtpField(int index) {
//     return SizedBox(
//       width: 45,
//       height: 45,
//       child: TextField(
//         controller: _controllers[index],
//         focusNode: _focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         maxLength: 1,
//         decoration: InputDecoration(
//           counterText: "",
//           contentPadding: EdgeInsets.zero,
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(22.5),
//             borderSide: const BorderSide(color: Colors.black, width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(22.5),
//             borderSide: const BorderSide(color: Colors.blue, width: 1.5),
//           ),
//         ),
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//         ],
//         onChanged: (value) {
//           if (value.isNotEmpty) {
//             // Auto-advance to next field
//             if (index < 5) {
//               _focusNodes[index].unfocus();
//               FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
//             }
//           } else if (value.isEmpty && index > 0) {
//             // Auto-back to previous field on deletion
//             _focusNodes[index].unfocus();
//             FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
//           }
//         },
//       ),
//     );
//   }
// }

// class CornerPainter extends CustomPainter {
//   const CornerPainter();

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     final path = Path();
//     path.moveTo(0, size.height / 2);
//     path.lineTo(0, 0);
//     path.lineTo(size.width / 2, 0);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
