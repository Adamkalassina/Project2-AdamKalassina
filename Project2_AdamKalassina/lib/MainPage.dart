import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senior/Courses.dart';
import 'package:http/http.dart' as http;
import 'package:senior/login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mainpage extends StatefulWidget {
  mainpage({Key? key}) : super(key: key);

  @override
  _mainpageState createState() {
    return _mainpageState();
  }
}
// Global variable to share the info between pages

class _mainpageState extends State<mainpage> {
  GlobalKey<FormState> _frmKey = GlobalKey();
  TextEditingController _controllerStudentName = TextEditingController();
  TextEditingController _controllerStudentEmail = TextEditingController();
  TextEditingController _controllerStudentPass = TextEditingController();
  bool isPasswordVisible = false;
  int classId = -1;
  List classes =[];
  /// GEt DATA
  Future GetClass() async{
    var url= "https://maarifah.000webhostapp.com/myPhpFiles/class.php";
    var res = await http.get(Uri.parse(url));

    if(res.statusCode == 200){
      var red = json.decode(res.body);
      setState(() {
        classes.addAll(red);
      });
    }
  }
  Future<void> SignUp(String classID) async {
    final url = Uri.parse("https://maarifah.000webhostapp.com/myPhpFiles/signUp.php");
    final response = await http.post(url, body: {
      'name' : _controllerStudentName.text,
      'email' : _controllerStudentEmail.text,
      'password' : _controllerStudentPass.text,
      'classId' : classId.toString(),
    },
    );
    if (response.statusCode == 200) {
      print("Data sent successfully");
      print("Response: ${response.body}");
    } else {
      print("Failed to send data. Status code: ${response.statusCode}");
    }
  }
  saveName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('storedName', _controllerStudentName.text);
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
    GetClass();
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
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (builder){
                return login();
              }));
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(mainColor), // Set the background color
            ),
            child: Text('Login',style: TextStyle(color: secondaryColor,fontWeight: FontWeight.bold),),
          ),
        ],
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
                  Text("Student Sign Up",style: TextStyle(color: mainColor,fontSize: 18,fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
                  SizedBox(
                    width: 200,
                      child: TextFormField(controller: _controllerStudentName,
                      keyboardType: TextInputType.text,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z -]+$'))],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Enter Name"
                      ),
                      validator: (String? value){
                        if(value == null || value.isEmpty){
                          return 'Please enter Name';
                        }
                        return null;
                      },
                        onChanged: (value) {
                          saveName();
                        },
                      ),
                  ),
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
                    SizedBox(height: 20,),
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
                  SizedBox(height: 15,),
                  DropdownMenu(
                    label: Text("Choose Class"),
                    width: 200,
                    dropdownMenuEntries:
                    classes.map<DropdownMenuEntry<Object>>( (e) {
                      return DropdownMenuEntry <Object> (value: e["class_id"],label:e["class_name"]);
                    }
                    ) .toList(),
                    onSelected: (c){
                      setState(() {
                        classId = int.parse(c.toString());
                      });
                    },
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: (){
                        _frmKey.currentState!.reset();
                        classId = -1;
                      }, child: Text("Clear",style: TextStyle(color: secondaryColor),),
                        style: ElevatedButton.styleFrom(
                          primary: mainColor,
                        ),),
                      SizedBox(width: 20,),
                      ElevatedButton(onPressed: (){
                        if(_frmKey.currentState!.validate() && classId != -1){
                              SignUp(classId.toString());
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: mainColor,content:Text("Sign Up Done Successfully",style: TextStyle(color: secondaryColor,fontWeight: FontWeight.bold),)));
                              Navigator.of(context).push(MaterialPageRoute(builder: (builder){
                                return courses(classId: classId.toString());
                              }));

                        }
                      }, child: Text("Sign Up",style: TextStyle(color: secondaryColor),),
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