import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';




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
  int size = 20;
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
      final response = await http.get(Uri.parse("http://localhost:8080/api/todo/list?page=${page}&size=${size}"));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> content = data["content"];
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
    
    _isLoading = false;
  }

  Future<void> fetchTodoList() async{
    try {
      final response = await http.get(Uri.parse("http://localhost:8080/api/todo/list?page=${page}&size=${size}"));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
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
              title: Text(todoList[index]["title"]),
            );
          }
        },

      )
    );
  }
}