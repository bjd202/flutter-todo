import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  DateTime? _startDt;
  DateTime? _endDt;

  String _dateFormat(DateTime? date) {
    if (date == null) {
      return "";
    }

    return DateFormat("yyyy-MM-dd").format(date);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: "제목"),
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
                  )
                )
              ],
            ),
            SizedBox(height: 16.0,),
            TextFormField(
              maxLines: 3,
              decoration: InputDecoration(labelText: "내용"),
            ),
            SizedBox(height: 16.0,),
            ElevatedButton(
              onPressed: (){

              }, 
              child: Text("완료")
            )
          ],
        ),
      )
    );
  }
}