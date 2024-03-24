import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  var logger = Logger(
    printer: PrettyPrinter()
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  DateTime? _startDt;
  DateTime? _endDt;

  String? _title;
  String? _content;

  String _dateFormat(DateTime? date) {
    if (date == null) {
      return "";
    }

    return DateFormat("yyyy-MM-dd").format(date);
  }

  Future<void> _createTodo() async{
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> data = {
        "title": _title,
        "content": _content,
        "startDt": DateFormat("yyyy-MM-dd").format(_startDt!),
        "endDt": DateFormat("yyyy-MM-dd").format(_endDt!)
      };

      try {
        final response = await http.post(
          Uri.parse("http://localhost:8080/api/todo/create"),
          body: json.encode(data),
          headers: {"Content-Type": "application/json"}
        );

        if (response.statusCode == 201) {
          // Fluttertoast.showToast(
          //   msg: "등록되었습니다.",
          //   gravity: ToastGravity.BOTTOM,
          //   backgroundColor: Colors.green,
          //   textColor: Colors.white
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("등록되었습니다.")
            )
          );

          Navigator.pop(context, true);
        }
      } catch (e) {
        // Fluttertoast.showToast(
        //   msg: "등록을 실패했습니다.",
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white
        // );

        logger.e(e);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("등록을 실패했습니다.")
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "제목"),
                onSaved: (value) {
                  _title = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "제목을 입력하세요.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "시작일"),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context, 
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000), 
                          lastDate: DateTime(2100),
                          // locale: const Locale("ko", "KR"),
                        );

                        if (picked != null) {
                          setState(() {
                            _startDt = picked;
                          });
                        }
                      },
                      controller: TextEditingController(
                        text: _dateFormat(_startDt)
                      ),
                      readOnly: true,
                      onSaved: (newValue) {
                        _startDt = DateTime.parse(newValue!);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "시작일을 입력해주세요.";
                        }
                        
                        if (_startDt!.isAfter(_endDt!)) {
                          return "시작일이 종료일보다 큽니다.";
                        }

                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "종료일"),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context, 
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000), 
                          lastDate: DateTime(2100),
                          // locale: const Locale("ko", "KR"),
                        );

                        if (picked != null) {
                          setState(() {
                            _endDt = picked;
                          });
                        }
                      },
                      controller: TextEditingController(
                        text: _dateFormat(_endDt)
                      ),
                      readOnly: true,
                      onSaved: (newValue) {
                        _endDt = DateTime.parse(newValue!);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "시작일을 입력해주세요.";
                        }
                        
                        if (_endDt!.isBefore(_startDt!)) {
                          return "종료일이 시작일보다 작습니다.";
                        }

                        return null;
                      },
                    )
                  )
                ],
              ),
              SizedBox(height: 16.0,),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(labelText: "내용"),
                onSaved: (value) {
                  _content = value;
                },
              ),
              SizedBox(height: 16.0,),
              ElevatedButton(
                onPressed: (){
                  _createTodo();
                }, 
                child: Text("완료")
              )
            ],
          ),
        )
      )
      
    );
  }
}