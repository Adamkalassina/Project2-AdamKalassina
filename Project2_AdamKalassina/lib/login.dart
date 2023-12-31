import 'dart:convert';

import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senior/Courses.dart';
import 'package:senior/MainPage.dart';
import 'package:senior/Q&A.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class login extends StatefulWidget {
  login({Key? key}) : super(key: key);

  @override
  _loginState createState() {
    return _loginState();
  }
}
// Global variable to share the info between pages

class _loginState extends State<login> {

  GlobalKey<FormState> _frmKey = GlobalKey();
  TextEditingController _controllerStudentEmail = TextEditingController();
  TextEditingController _controllerStudentPass = TextEditingController();
  bool isPasswordVisible = false;
   String classId = "-1";
   String student_name = "";

  Future<void> Login() async {
    final url = Uri.parse("https://maarifah.000webhostapp.com/myPhpFiles/login.php");
    final response = await http.post(url, body: {
      'email': _controllerStudentEmail.text,
      'password': _controllerStudentPass.text,
      },
    );
    if (response.statusCode == 200) {
      print("Data sent successfully");
      print("Response: ${response.body}");
      var red = json.decode(response.body);
      setState(() {
        classId = red["class_id"];
        student_name = red["student_name"];
      });
      print(red);
    } else {
      print("Failed to send data. Status code: ${response.statusCode}");
    }
  }
  saveName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('storedName', student_name);
    prefs.setString('storedClassId', classId.toString());
  }
  Future<void> getPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String student_name = prefs.getString('storedName') ?? "";
    String clId = prefs.getString('storedClassId') ?? "";

    // Assuming classId is defined and initialized elsewhere in your code
    if (student_name.isNotEmpty) {
      print(clId);
      // Navigate to the courses page
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return courses(classId: clId.toString());
        },
      ));
    }
  }

  Color mainColor = Color(0xFF12203B);
  Color secondaryColor = Color(0xFFFF9E00);

  @override
  void initState() {
    super.initState();
    getPage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maarifah",style: TextStyle(color: secondaryColor,fontWeight: FontWeight.bold),),
          actions: [
          ElevatedButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.remove('storedName');
            Navigator.of(context).push(MaterialPageRoute(builder: (builder){
            return mainpage();
            }));
          },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(mainColor), // Set the background color
      ),
      child: Text('Sign Up',style: TextStyle(color: secondaryColor,fontWeight: FontWeight.bold),),
    )],
        backgroundColor:mainColor,
        automaticallyImplyLeading: false,),
      body: Container(
        margin: EdgeInsets.all(30),
        child: ListView(
          children: [
            RichText(text: TextSpan(
              children: [
                TextSpan(text: "Welcome To ",style: TextStyle(color: mainColor,fontSize: 18)),
                TextSpan(text: "Ma'arifah ",style: TextStyle(color: secondaryColor,fontSize: 18,fontWeight: FontWeight.bold)),
                TextSpan(text: "app. In our mobile app you will have many specifications that will make you able to learn all the Courses. ",style: TextStyle(color: mainColor,fontSize: 18,)),
              ],
            )),
            SizedBox(height: 20,),
            Form(
                key: _frmKey,
                child: Column(
                  children: [
                    Text("Student Login",style: TextStyle(color: mainColor,fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(height: 15,),
                    //Email
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _controllerStudentEmail,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Enter Email",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid Email';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15,),
                    //Password
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _controllerStudentPass,
                        obscureText: !isPasswordVisible,
                        keyboardType: TextInputType.text,
                        decoration:  InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Enter Password",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.remove_red_eye_rounded),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: (){
                          _controllerStudentEmail.text = "";
                          _controllerStudentPass.text = "";
                        }, child: Text("Clear",style: TextStyle(color: secondaryColor),),
                          style: ElevatedButton.styleFrom(
                            primary: mainColor,
                          ),),
                        SizedBox(width: 20,),
                        ElevatedButton(onPressed: ()async{
                          if(_frmKey.currentState!.validate()){
                                 await Login();
                                 saveName();
                                  if(classId != "-1"){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: mainColor,content:Text("Login Done Successfully",style: TextStyle(color: secondaryColor,fontWeight: FontWeight.bold),)));
                                  Navigator.of(context).push(MaterialPageRoute(builder: (builder){
                                    return courses(classId: classId.toString());
                                  }));
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: mainColor,content:Text("Student Not Found",style: TextStyle(color: secondaryColor,fontWeight: FontWeight.bold),)));
                                  }
                              }}
                , child: Text("Login",style: TextStyle(color: secondaryColor),),
                          style: ElevatedButton.styleFrom(
                            primary: mainColor,
                          ),),

                      ],)
                  ],)

            ),
          ],
        ),
      ),
    );
  }
}