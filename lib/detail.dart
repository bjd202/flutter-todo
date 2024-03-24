import 'package:flutter/material.dart';

class Detail extends StatefulWidget {
  final Map<String, dynamic> data;

  const Detail({super.key, required this.data});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {

  String _dateFormat(data){
    String formattedDate = "${data[0]}-${data[1].toString().padLeft(2, '0')}-${data[2].toString().padLeft(2, '0')}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
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