// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// import 'login_page.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool isToggleOn = false;
//   int _currentIndex = 0;

//   // List of pages for BottomNavigationBar
//   final List<Widget> _pages = [];

//   @override
//   void initState() {
//     super.initState();
//     _pages.addAll([
//       HomePage(
//         isToggleOn: isToggleOn,
//         toggleSwitch: _toggleSwitch,
//       ),
//       AboutPage(),
//     ]);
//   }

//   void _toggleSwitch(bool value) {
//     setState(() {
//       isToggleOn = value;
//       _pages[0] = HomePage(
//         isToggleOn: isToggleOn,
//         toggleSwitch: _toggleSwitch,
//       );
//     });
//   }

//   void _logout(BuildContext context) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           title: Text('IOT Based Grass Cutting Robot'),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.logout),
//               onPressed: () => _logout(context),
//             ),
//           ],
//         ),
//         body: _pages[_currentIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.info),
//               label: 'About Us',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   final bool isToggleOn;
//   final ValueChanged<bool> toggleSwitch;

//   HomePage({
//     required this.isToggleOn,
//     required this.toggleSwitch,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // MyGauge(
//                 //   backgroundColor: Colors.grey,
//                 //   progressColor: Colors.green,
//                 //   label: 'Temperature',
//                 //   text: '0',
//                 //   size: 150, // Adjust the size
//                 // ),
//                 MyGauge(
//                   backgroundColor: Colors.grey,
//                   progressColor: Colors.purple,
                  
//                   label: 'Humidity',
//                   text: '0',
//                   size: 150, // Adjust the size
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             // Robot operations
//             Text('Robot operations'),
//             SizedBox(height: 10),
//             // Arrow keys
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Column(
//                   children: [
//                     Stack(
//                       children: [
//                         Container(
//                           width: 100, // Adjust circle diameter as needed
//                           height: 100, // Adjust circle diameter as needed
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.grey.withOpacity(
//                                 0.3), // Adjust circle color and opacity as needed
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.arrow_upward, color: Colors.cyan),
//                           iconSize: 80,
//                           onPressed: () {
//                             // Add logic to move robot upward
//                           },
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Stack(
//                           children: [
//                             Container(
//                               width: 100, // Adjust circle diameter as needed
//                               height: 100, // Adjust circle diameter as needed
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.grey.withOpacity(
//                                     0.3), // Adjust circle color and opacity as needed
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.arrow_back, color: Colors.cyan),
//                               iconSize: 80,
//                               onPressed: () {
//                                 // Add logic to move robot left
//                               },
//                             ),
//                           ],
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             // Add logic to stop the robot
//                           },
//                           style: ButtonStyle(
//                             backgroundColor: MaterialStateProperty.all<Color>(
//                                 Colors.red), // Adjust button color as needed
//                             padding: MaterialStateProperty.all<
//                                     EdgeInsetsGeometry>(
//                                 EdgeInsets.all(40)), // Adjust padding as needed
//                             shape: MaterialStateProperty.all<OutlinedBorder>(
//                               CircleBorder(),
//                             ),
//                           ),
//                           child: Text(
//                             'Stop',
//                             style: TextStyle(
//                               color:
//                                   Colors.white, // Adjust text color as needed
//                               fontSize: 18, // Adjust text size as needed
//                               fontWeight: FontWeight
//                                   .bold, // Adjust font weight as needed
//                             ),
//                           ),
//                         ),
//                         Stack(
//                           children: [
//                             Container(
//                               width: 100, // Adjust circle diameter as needed
//                               height: 100, // Adjust circle diameter as needed
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.grey.withOpacity(
//                                     0.3), // Adjust circle color and opacity as needed
//                               ),
//                             ),
//                             IconButton(
//                               icon:
//                                   Icon(Icons.arrow_forward, color: Colors.cyan),
//                               iconSize: 80,
//                               onPressed: () {
//                                 // Add logic to move robot right
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Stack(
//                       children: [
//                         Container(
//                           width: 100, // Adjust circle diameter as needed
//                           height: 100, // Adjust circle diameter as needed
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.grey.withOpacity(
//                                 0.3), // Adjust circle color and opacity as needed
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.arrow_downward, color: Colors.cyan),
//                           iconSize: 80,
//                           onPressed: () {
//                             // Add logic to move robot downward
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             SizedBox(height: 20),
//             // Cutter Switch
//             Text('Cutter Switch'),
//             Switch(
//               value: isToggleOn,
//               onChanged: toggleSwitch,
//             ),
//             SizedBox(height: 20),
//             // Robot Data
//             Text(
//               'Robot Data',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 15,
//               ),
//             ),
//             Text(
//               'Robot Operations',
//               style: TextStyle(
//                 color: Colors.purple,
//                 fontSize: 24,
//               ),
//             ),
//             SizedBox(height: 20),
//             // Stop Text
//             Text(
//               'Stop',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AboutPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Welcome to our innovative world of IoT-based solutions! We are a forward-thinking tech company dedicated to transforming everyday tasks through cutting-edge technology. Our flagship product, the IoT-Based Grass Cutting Robot, exemplifies our commitment to improving lives by automating mundane tasks and enhancing efficiency.',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }

// class MyGauge extends StatelessWidget {
//   final Color backgroundColor;
//   final Color progressColor;
//   final String label;
//   final String text;
//   final double size;

//   const MyGauge({
//     Key? key,
//     required this.backgroundColor,
//     required this.progressColor,
//     required this.label,
//     required this.text,
//     required this.size,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Padding(
//           padding: EdgeInsets.only(bottom: 4.0),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 12, // Adjust font size
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         Container(
//           width: size,
//           height: size,
//           child: CustomPaint(
//             painter: GaugePainter(
//               backgroundColor: backgroundColor,
//               progressColor: progressColor,
//               text: text,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class GaugePainter extends CustomPainter {
//   final Color backgroundColor;
//   final Color progressColor;
//   final String text;

//   GaugePainter({
//     required this.backgroundColor,
//     required this.progressColor,
//     required this.text,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final centerX = size.width / 2;
//     final centerY = size.height / 2;
//     final radius = size.width / 2.5;

//     final strokeWidth = 8.0; // Adjust stroke width
//     final startAngle = math.pi * 5 / 6.5; // 225 degrees in radians
//     final sweepAngle = math.pi * 3 / 2; // 270 degrees in radians

//     final backgroundPaint = Paint()
//       ..color = backgroundColor
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke;

//     final progressPaint = Paint()
//       ..color = progressColor
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke;

//     final labelStyle = TextStyle(
//       color: Colors.black,
//       fontSize: 12, // Adjust font size
//       fontWeight: FontWeight.bold,
//     );

//     final TextPainter textPainter = TextPainter(
//       text: TextSpan(
//         text: text,
//         style: labelStyle,
//       ),
//       textDirection: TextDirection.ltr,
//     )..layout();

//     textPainter.paint(
//       canvas,
//       Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2),
//     );

//     // Calculate progress angle based on some logic or external data source
//     final progressAngle = (double.parse(text) / 225) *
//         math.pi *
//         3 /
//         2; // Example: Convert percentage to radians

//     canvas.drawArc(
//       Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
//       startAngle,
//       sweepAngle,
//       false,
//       backgroundPaint,
//     );

//     canvas.drawArc(
//       Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
//       startAngle,
//       progressAngle,
//       false,
//       progressPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
