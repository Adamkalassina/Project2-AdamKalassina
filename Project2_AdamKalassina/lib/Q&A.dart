import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:senior/Courses.dart';
import 'package:http/http.dart' as http;

class QA extends StatefulWidget {
  final String courseId;
  QA({required this.courseId ,Key? key}) : super(key: key);

  @override
  _QAState createState() {
    return _QAState();
  }
}

class _QAState extends State<QA> {
  List questionList = [];
  List chaptersName = [];
  String msg = "";
  Future GetQuestions(String courseId,String chapterId) async{
    var url ="https://maarifah.000webhostapp.com/myPhpFiles/getQuestions.php";
    var res = await http.post(Uri.parse(url), body: {
      'courseId': courseId,
      'chapterId' : chapterId,
    },);
    if (res.statusCode == 200) {
      print("Data sent successfully");
      print("Response: ${res.body}");
      var red = json.decode(res.body);
      setState(() {
        questionList.addAll(red);
      });
      print(red);
    } else {
      print("Failed to send data. Status code: ${res.statusCode}");
    }
  }
  Future getChaptersName(String courseId) async{
    var url ="https://maarifah.000webhostapp.com/myPhpFiles/getChapters.php";
    var res = await http.post(Uri.parse(url), body: {'data': courseId},);
    if (res.statusCode == 200) {
      print("Data sent successfully");
      print("Response: ${res.body}");
      var red = json.decode(res.body);
      setState(() {
        chaptersName.addAll(red);
      });
    } else {
      print("Failed to send data. Status code: ${res.statusCode}");
    }
  }
  ///Colors used
  Color mainColor = Color(0xFF12203B);
  Color secondaryColor = Color(0xFFFF9E00);

  @override
  void initState(){
    super.initState();
    getChaptersName(widget.courseId).then((_) {
      if (chaptersName.isNotEmpty) {
        GetQuestions(widget.courseId,chaptersName[0]["chapter_id"]);
        setState(() {
          msg = "Chapter ${chaptersName[0]["chapter_number"]}";
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    String courseName = ModalRoute.of(context)!.settings.arguments as String;
    String courseId = widget.courseId;
    return Scaffold(
      //appBar
      appBar: AppBar(title: Text("Q&A - $courseName $msg",style: TextStyle(color: secondaryColor,fontWeight: FontWeight.bold)),backgroundColor: mainColor),
      //Drawer
      drawer: Drawer(
        elevation: 5,
        child: ListView.builder(itemBuilder: (itemBuilder,position){
          return Card(
            elevation: 5,
            color : mainColor,
            child: ListTile(
              title: Text("Chapter : ${chaptersName[position]["chapter_number"]}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
              subtitle: Text(chaptersName[position]["chapter_name"],style: TextStyle(color: secondaryColor,fontWeight: FontWeight.bold,fontSize: 14),),
              onTap: (){
                questionList = [];
                GetQuestions(courseId,chaptersName[position]["chapter_id"]);
                setState(() {
                  msg = "Chapter ${chaptersName[position]["chapter_number"]}";
                  print("msg updated: $msg");
                });
                Navigator.pop(context);

              },),
          );
        },itemCount: chaptersName.length,),
      ),

      body: Container(
          child: Column(
            children: [
              Expanded(
                child:ListView.builder(itemBuilder: (itemBuilder,i){
                  return Card(
                      margin: EdgeInsets.all(15),
                      elevation: 5,
                      shadowColor: mainColor,
                      child:Column(
                          children: [
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                SizedBox(width: 15,),
                                Icon(Icons.person,color: mainColor,size: 20,),
                                SizedBox(width: 15,),
                                Text("${questionList[i]["stdQ"]}", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: mainColor)),
                              ],
                            ),
                            SizedBox(height: 15,),
                            Row(children: [SizedBox(width: 20,),Text("${questionList[i]["question_content"]}",style: TextStyle(color: mainColor,fontSize: 17),),],),
                            SizedBox(height: 5,),
                            Image.asset(
                              "${questionList[i]["question_image"].toString().replaceAll("../../../public", "assets")}",
                              width: 300, // Set the width as per your requirement
                              height: 300, // Set the height as per your requirement
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                              SizedBox(width: 15,),
                              Text("Answers", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: secondaryColor)),

                            ],),
                            SizedBox(height: 5,),
                            SizedBox(
                                child:Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: questionList[i]["answers_data"].length,
                                      itemBuilder: (BuildContext context, int j) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(width: 40,),
                                                Icon(Icons.person, color: secondaryColor, size: 20,),
                                                SizedBox(width: 15,),
                                                Text(
                                                  "${questionList[i]["answers_data"][j]["student_name"]}",
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor),
                                                ),
                                                SizedBox(height: 40,),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(width: 80,),
                                                Text(
                                                  "${questionList[i]["answers_data"][j]["answer_content"]}",
                                                  style: TextStyle(color: mainColor, fontSize: 16,),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15,),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                )
                            ),

                          ]));

                },itemCount: questionList.length,),
              ),
            ],
          )
      ),

      bottomNavigationBar: BottomAppBar(
        color: mainColor, // Customize the color of the BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_outlined,color: secondaryColor,),
              onPressed: () {
                Navigator.of(context).pop(MaterialPageRoute(builder: (builder){
                  return courses(classId: "none",);
                }));
              },
            ),
          ],
        ),
      ),
    );
  }
}
