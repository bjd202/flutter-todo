import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class Modify extends StatefulWidget {
  final Map<String, dynamic> data;

  const Modify({super.key, required this.data});

  @override
  State<Modify> createState() => _ModifyState();
}

class _ModifyState extends State<Modify> {
  var logger = Logger(
    printer: PrettyPrinter()
  );

  @override
  void initState() {
    super.initState();

    _startDt = DateTime.parse(_dateFormat2(widget.data["startDt"]));
    _endDt = DateTime.parse(_dateFormat2(widget.data["endDt"]));
  }
  
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

  String _dateFormat2(data){
    String formattedDate = "${data[0]}-${data[1].toString().padLeft(2, '0')}-${data[2].toString().padLeft(2, '0')}";
    return formattedDate;
  }

  Future<void> _modifyTodo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> data = {
        "title": _title,
        "content": _content,
        "startDt": DateFormat("yyyy-MM-dd").format(_startDt!),
        "endDt": DateFormat("yyyy-MM-dd").format(_endDt!)
      };

      try {
        final response = await http.put(
          Uri.parse("http://localhost:8080/api/todo/modify/${widget.data["id"]}"),
          body: json.encode(data),
          headers: {"Content-Type": "application/json"}
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("수정되었습니다.")
            )
          );

          Navigator.pop(context, true);
        }else if(response.statusCode == 404){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("찾을 수 없는 ID")
            )
          );
        }else if(response.statusCode == 400){

        }
      } catch (e) {
        logger.e(e);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("수정을 실패했습니다.")
          )
        );
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modify"),
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
                initialValue: widget.data["title"],
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
                          // initialDate: DateTime.now(),
                          initialDate: _startDt,
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
                      // initialValue: _dateFormat2(widget.data["startDt"]!),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "종료일"),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context, 
                          // initialDate: DateTime.now(),
                          initialDate: _endDt,
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
                        text: _dateFormat(_endDt),
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
                      // initialValue: _dateFormat2(widget.data["endDt"]),
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
                initialValue: widget.data["content"],
              ),
              SizedBox(height: 16.0,),
              ElevatedButton(
                onPressed: (){
                  _modifyTodo();
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