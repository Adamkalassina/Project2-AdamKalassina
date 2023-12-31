import 'package:flutter/material.dart';
import 'package:senior/Courses.dart';
import 'package:senior/Q&A.dart';
import 'MainPage.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: "Main Page",
      home: mainpage(),
    );
  }

}
