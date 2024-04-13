import 'dart:convert';
import 'dart:js_util';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:todo/detail.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var logger = Logger(
    printer: PrettyPrinter()
  );

  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> todoList = [];
  int page = 0;
  int size = 10;
  bool _loading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener(){
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
    !_scrollController.position.outOfRange) {
      if (!_loading && _hasMoreData) {
        _loadData();
      }
    }
  }

  Future<void> _loadData() async {
    if (!_loading && _hasMoreData) {
      setState(() {
        _loading = true;
      });

      String keyword = _searchController.text;

      if (keyword == "" || keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("검색어를 입력해주세요.")
        )
      );
      return;
    }

      try {
        final response = await http.get(
          Uri.parse("http://localhost:8080/api/todo/search?page=${page}&size=${size}&keyword=${keyword}")
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
          List<dynamic> content = data["content"];

          if (content.isEmpty) {
            setState(() {
              _hasMoreData = false;
              _loading = false;
            });
          }else{
            todoList.addAll(content);
            page++;
            _loading = false;
          }

        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("검색을 실패했습니다.")
            )
          );
        }
      } catch (e) {
        logger.e(e);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("검색을 실패했습니다.")
          )
        );
      }
      
    }
  }

  Future<void> _searchTodo() async {
    String keyword = _searchController.text;

    if (keyword == "" || keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("검색어를 입력해주세요.")
        )
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://localhost:8080/api/todo/search?page=${page}&size=${size}&keyword=${keyword}")
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> content = data["content"];
        // last = data["last"];
        int totalPages = data["totalPages"];

        // if (last) {
        //   page = totalPages - 1;
        // }

        setState(() {
          todoList.addAll(content);
          page++;
        });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("검색을 실패했습니다.")
          )
        );
      }
    } catch (e) {
      logger.e(e);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("검색을 실패했습니다.")
        )
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: "검색"
                    ),
                    controller: _searchController,
                    onSubmitted: (value) {
                      _searchTodo();
                    },
                  ),
                ),
                SizedBox(width: 16.0,),
                IconButton(
                  onPressed: () {
                    _searchTodo();
                  }, 
                  icon: Icon(Icons.search)
                )
              ],
            ),
          ),
          SizedBox(height: 16.0,),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: todoList.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < todoList.length) {
                  return ListTile(
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
                        // fetchTodoList();
                      }
                    },
                  );
                } else if(_loading){
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
              },
            )
          ),
        ],
      ),
    );
  }
}