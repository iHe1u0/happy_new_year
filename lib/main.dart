import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:happy_new_year/file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationIcon: Image.asset("images/app_icon.png"),
                applicationName: "对联生成器",
                applicationVersion: "2022.0120",
                children: [
                  const Text("一款开源的对联生成器，开源地址："),
                  const Padding(padding: EdgeInsets.only(top: 5, bottom: 5)),
                  Linkify(
                    text: "https://github.com/catcompany/happy_new_year",
                    onOpen: _openGithub,
                  )
                ],
              );
            },
          )
        ],
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
              height: 20,
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
      FlutterToastr.show("请填写完整哟！", context);
      return;
    }
    Response response;
    Dio dio = Dio();
    String _saveDir = "${_downloadDir.absolute.path}/$_top.zip";
    if (await File(_saveDir).exists()) {
      await File(_saveDir).delete();
    }
    FlutterToastr.show("生成中...", context);
    try {
      response = await dio.download(
          "http://2022.catcompany.cn/generate?top=$_top&left=$_left&right=$_right",
          _saveDir);
    } catch (e) {
      FlutterToastr.show(
        "请求失败:\n$e",
        context,
        duration: FlutterToastr.lengthLong,
      );
      return;
    }
    if (Platform.isAndroid) {
      unzip(_saveDir);
      FlutterToastr.show(
        "已保存在相册",
        context,
        duration: FlutterToastr.lengthLong,
      );
    } else {
      FlutterToastr.show(
        "已保存在$_saveDir",
        context,
        duration: FlutterToastr.lengthLong,
      );
    }
  }

  void _openGithub(LinkableElement link) async {
    var _url = 'https://github.com/catcompany/happy_new_year';
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
}
