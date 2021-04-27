// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
//
// class UpdateValues extends StatefulWidget {
//   static const String id = 'update_values';
//   final String babyName;
//
//   UpdateValues({this.babyName});
//
//   @override
//   _UpdateValuesState createState() => _UpdateValuesState();
// }
//
// class _UpdateValuesState extends State<UpdateValues> {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//   double newWeight;
//   int newHeight;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         margin: EdgeInsets.symmetric(horizontal: 75),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Log new values',
//               style: TextStyle(fontSize: 32, color: Colors.green[200]),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             TextFormField(
//               decoration: InputDecoration(
//                 contentPadding:
//                     EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.green[400], width: 1.0),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.green[400], width: 2.0),
//                 ),
//                 hintText: 'Enter weight',
//               ),
//               onChanged: (newValue) => newWeight = double.parse(newValue),
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               autofocus: true,
//               textAlign: TextAlign.center,
//               cursorColor: Colors.green[200],
//             ),
//             SizedBox(
//               height: 8.0,
//             ),
//             TextFormField(
//               decoration: InputDecoration(
//                 contentPadding:
//                     EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.green[400], width: 1.0),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.green[400], width: 2.0),
//                 ),
//                 hintText: 'Enter height',
//               ),
//               onChanged: (newValue) => newHeight = int.parse(newValue),
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               autofocus: true,
//               textAlign: TextAlign.center,
//               cursorColor: Colors.green[200],
//             ),
//             SizedBox(height: 20),
//             MaterialButton(
//               child: Text(
//                 'Add',
//                 style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold),
//               ),
//               color: Colors.green[200],
//               onPressed: () {
//                 _firestore
//                     .collection(_auth.currentUser.uid)
//                     .doc(widget.babyName)
//                     .update({
//                   'weight': FieldValue.arrayUnion([newWeight]),
//                   'height': FieldValue.arrayUnion([newHeight]),
//                   'date': FieldValue.arrayUnion([DateTime.now()])
//                 });
//               },
//             ),
//             SizedBox(height: 30),
//             MaterialButton(
//               child: Icon(CupertinoIcons.return_icon, color: Colors.green[200]),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
