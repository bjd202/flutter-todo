
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Detail extends StatefulWidget {
  final Map<String, dynamic> data;

  const Detail({super.key, required this.data});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  var logger = Logger(
    printer: PrettyPrinter()
  );

  String _dateFormat(data){
    String formattedDate = "${data[0]}-${data[1].toString().padLeft(2, '0')}-${data[2].toString().padLeft(2, '0')}";
    return formattedDate;
  }

  Future<void> _deleteTodo() async{

    try {
      final response = await http.delete(
        Uri.parse("http://localhost:8080/api/todo/delete/${widget.data["id"]}"),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("삭제되었습니다.")
          )
        );

        Navigator.pop(context, true);
      }else{
        
      }
    } catch (e) {
      logger.e(e);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("삭제를 실패했습니다.")
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
        actions: [
          IconButton(
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1000, 50, 0, 0), // 메뉴가 표시될 위치 조정
                items: [
                  PopupMenuItem(
                    child: Text("수정"),
                    value: "edit",
                  ),
                  PopupMenuItem(
                    child: Text(
                      "삭제",
                      style: TextStyle(
                        color: Colors.red
                      ),
                    ),
                    value: "delete",
                  ),
                ],
                elevation: 8.0, // 메뉴의 고도 조정
              ).then((value) {
                if (value == "edit") {
                  // 수정 메뉴를 선택한 경우 실행할 코드
                } else if (value == "delete") {
                  // 삭제 메뉴를 선택한 경우 실행할 코드
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("삭제"),
                        content: Text("삭제하시겠습니까?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // 취소 버튼을 누른 경우
                            },
                            child: Text("아니오"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // 삭제 확인을 반환
                              _deleteTodo();
                            },
                            child: Text(
                              "예",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  ).then((value) {
                    if (value == true) {
                      // 예 버튼을 누른 경우 실행할 코드
                      
                    } else {
                      // 아니오 버튼을 누른 경우 실행할 코드
                    }
                  });
                }
              });
            }, 
            icon: Icon(Icons.more_vert)
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: "제목"),
              initialValue: widget.data["title"],
              readOnly: true,
            ),
            SizedBox(height: 16.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "시작일"),
                    initialValue: _dateFormat(widget.data["startDt"]),
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "종료일"),
                    initialValue: _dateFormat(widget.data["endDt"]),
                    readOnly: true,
                  )
                )
              ],
            ),
            SizedBox(height: 16.0,),
            TextFormField(
              maxLines: 3,
              decoration: InputDecoration(labelText: "내용"),
              initialValue: widget.data["content"],
              readOnly: true,
            ),
            SizedBox(height: 16.0,),
            // ElevatedButton(
            //   onPressed: (){
            //     _createTodo();
            //   }, 
            //   child: Text("완료")
            // )
          ],
        ),
      )
    );
  }
}