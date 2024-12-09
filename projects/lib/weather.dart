// // Import necessary packages
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;

// // Entry point of the app
// void main() {
//   runApp(const PingLob());
// }

// // State class to hold the message (temperature info)
// class MsgState {
//   String msg;
//   MsgState(this.msg);
// }

// // Cubit class for state management
// class MsgCubit extends Cubit<MsgState> {
//   MsgCubit() : super(MsgState("Enter zip code"));
//   void update(String m) {
//     emit(MsgState(m));
//   }
// }

// // Main app widget
// class PingLob extends StatelessWidget {
//   const PingLob({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Ping Lob",
//       home: Scaffold(
//         appBar: AppBar(title: Text("Temperature Finder")),
//         body: Center(child: Ping1()),
//       ),
//     );
//   }
// }

// // StatefulWidget to manage TextEditingController
// class Ping1 extends StatefulWidget {
//   const Ping1({super.key});

//   @override
//   State<Ping1> createState() => _Ping1State();
// }

// class _Ping1State extends State<Ping1> {
//   final TextEditingController zipController = TextEditingController();

//   @override
//   void dispose() {
//     zipController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<MsgCubit>(
//       create: (context) => MsgCubit(),
//       child: BlocBuilder<MsgCubit, MsgState>(
//         builder: (context, state) {
//           MsgCubit mc = BlocProvider.of<MsgCubit>(context);
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: zipController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter zip code',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () async {
//                     String zipCode = zipController.text;
//                     String tempMsg = await _networkCall(zipCode);
//                     mc.update(tempMsg);
//                   },
//                   child: Text("Get Temperature"),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   state.msg,
//                   style: TextStyle(fontSize: 20),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Function to make the API call
//   Future<String> _networkCall(String zipCode) async {
//     String apiKey = 'b5adfe6a08c5460cb3332151240411';
//     final url = Uri.parse(
//         'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$zipCode');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       Map<String, dynamic> dataAsMap = jsonDecode(response.body);
//       String location = dataAsMap['location']['name'];
//       double tempF = dataAsMap['current']['temp_f'];
//       String tempMsg =
//           'Current temperature in $location is ${tempF.toStringAsFixed(1)}°F';
//       return tempMsg;
//     } else {
//       return 'Error getting weather data. Please check the zip code.';
//     }
//   }
// }
