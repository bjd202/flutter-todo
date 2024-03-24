import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:todo/create.dart';
import 'package:todo/detail.dart';





class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>{
  var logger = Logger(
    printer: PrettyPrinter()
  );

  List<dynamic> todoList = [];
  int page = 0;
  int size = 10;
  bool last = false;
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    _scrollController.addListener(_scrollListener);

    fetchTodoList();
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // 리스트의 끝에 도달하여 스크롤이 더 이상 없을 때
      if (!_isLoading) {
        // 로딩 중이 아닌 경우에만 새 항목 추가
        setState(() {
          _isLoading = true;
          _addMoreItems();
        });
      }
    }
  }

  Future<void> _addMoreItems () async{
    // List<String> newItems = List.generate(10, (index) => "Item ${items.length+index+1}");
    // items.addAll(newItems);
    try {
      page += 1;
      size = 10;
      final response = await http.get(
        Uri.parse("http://localhost:8080/api/todo/list?page=${page}&size=${size}"),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> content = data["content"];
        last = data["last"];
        int totalPages = data["totalPages"];

        if (last) {
          page = totalPages - 1;
        }

        setState(() {
          // todoList = data.map((item) => item["title"]).toList();
          todoList.addAll(content);
        });

      } else {
        throw Exception("todo list 불러오기 실패");
      }
    } catch (e) {
      logger.e(e);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchTodoList() async{
    try {
      page = 0;
      size = 10;
      final response = await http.get(Uri.parse("http://localhost:8080/api/todo/list?page=${page}&size=${size}"));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> content = data["content"];
        setState(() {
          // todoList = data.map((item) => item["content"]).toList();
          todoList = content;
        });
      } else {
        throw Exception("todo list 불러오기 실패");
      }
    } catch (e) {
      logger.e(e.toString());
    }
    
  }

  String dateFormatter(data){
    String formattedDate = "${data[0]}년 ${data[1].toString().padLeft(2, '0')}월 ${data[2].toString().padLeft(2, '0')}일";
    return formattedDate;
  }

  Color subtitleTextColor(startDt, endDt){
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMdd').format(now);

    String sDt = "${startDt[0]}${startDt[1].toString().padLeft(2, '0')}${startDt[2].toString().padLeft(2, '0')}";
    String eDt = "${endDt[0]}${endDt[1].toString().padLeft(2, '0')}${endDt[2].toString().padLeft(2, '0')}";
    
    int result1 = formattedDate.compareTo(sDt);
    int result2 = formattedDate.compareTo(eDt);

    if (result1 >= 0 && result2 <= 0) {
      return Colors.green.shade200;
    }else{
      return Colors.red.shade200;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: todoList.length + 1,
        itemBuilder: (context, index) {
          if (index == todoList.length) {
            return _isLoading ? const CircularProgressIndicator() : Container();
          } else {
            return ListTile(
              // key: todoList[index]["id"],
              title: Text(todoList[index]["title"]),
              subtitle: Text(
                "${dateFormatter(todoList[index]["startDt"])} ~ ${dateFormatter(todoList[index]["endDt"])}",
                style: TextStyle(
                  color: subtitleTextColor(todoList[index]["startDt"], todoList[index]["endDt"])
                ),
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Detail(data: todoList[index],))
                );

                if (result != null && result) {
                  fetchTodoList();
                }
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => Create(),)
          );

          if (result != null && result) {
            fetchTodoList();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}