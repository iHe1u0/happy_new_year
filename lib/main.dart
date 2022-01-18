import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(List<String> args) {
  runApp(
    MaterialApp(
      home: const IndexPage(),
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
    ),
  );
}

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final GlobalKey _key = GlobalKey<FormState>();
  late TextEditingController _controller_left;
  late TextEditingController _controller_top;
  late TextEditingController _controller_right;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("对联"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "预祝2022新年快乐",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            SizedBox(
              width: 360,
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controller_top,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.mood,
                          color: Colors.redAccent,
                        ),
                        labelText: "横批",
                      ),
                    ),
                    TextFormField(
                      controller: _controller_left,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.mood,
                          color: Colors.redAccent,
                        ),
                        labelText: "上联",
                      ),
                    ),
                    TextFormField(
                      controller: _controller_right,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.mood,
                          color: Colors.redAccent,
                        ),
                        labelText: "下联",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            ElevatedButton(
              child: const Text("生成"),
              onPressed: () => getDownlaodUrl(
                _controller_top.text,
                _controller_left.text,
                _controller_right.text,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller_left = TextEditingController();
    _controller_top = TextEditingController();
    _controller_right = TextEditingController();
  }

  @override
  void dispose() {
    _controller_left.dispose();
    _controller_top.dispose();
    _controller_right.dispose();

    super.dispose();
  }

  getDownlaodUrl(String _top, String _left, String _right) async {
    if (_top.isEmpty || _left.isEmpty || _right.isEmpty) {
      return;
    }
    Directory tmpDir = await getTemporaryDirectory();
    debugPrint(tmpDir.absolute.path);
    Response response;
    Dio dio = Dio();
    dio.options.baseUrl = 'http://127.0.0.1:5000';
    response = await dio.download(
        "http://127.0.0.1:5000/generate?top=$_top&left=$_left&right=$_right",
        "$tmpDir/$_top.zip");
    debugPrint(response.data);
  }
}
