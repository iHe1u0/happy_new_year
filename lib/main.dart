import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:happy_new_year/file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
              onPressed: () => downloadFile(
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

  downloadFile(String _top, String _left, String _right) async {
    Directory? _downloadDir = await getSaveDirectory();
    if (_downloadDir == null) {
      FlutterToastr.show("请授予存储权限用来保存文件！", context);
      openAppSettings();
      return;
    }
    if (_top.isEmpty || _left.isEmpty || _right.isEmpty) {
      return;
    }
    Response response;
    Dio dio = Dio();
    // dio.options.baseUrl = 'https://2022.catcompany.cn/';
    String _saveDir = "${_downloadDir.absolute.path}/$_top.zip";
    if (await File(_saveDir).exists()) {
      await File(_saveDir).delete();
    }
    try {
      response = await dio.download(
          "http://2022.catcompany.cn/generate?top=$_top&left=$_left&right=$_right",
          _saveDir);
    } catch (e) {
      FlutterToastr.show("请求失败:\n$e", context);
      return;
    }
    if (Platform.isAndroid) {
      unzip(_saveDir);
      FlutterToastr.show("已保存在相册", context);
    } else {
      FlutterToastr.show("已保存在$_saveDir", context);
    }
  }
}
