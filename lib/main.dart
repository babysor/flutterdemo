import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:fluwx_worker/fluwx_worker.dart' as fluwxWorker;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _resultStatus = 'Not';
  var _resultName = 'Login';
  var _resultAvatar = '';

  final schema = 'wwauthb41f21ee5b95bac2000018';
  final corpId = 'wwb41f21ee5b95bac2';
  final agentId = '1000018';

  @override
  void initState() {
    super.initState();
    _initFluwx();

    //等待授权结果
    fluwxWorker.responseFromAuth.listen((data) async {
      if (data.errCode == 0) {
        var response = await http.get(Uri.parse(
            'http://192.168.2.130:6270/wxwork/user?code=${data.code}'));
        var body = jsonDecode(response.body);
        _resultStatus = '授权成功';
        // print("Code is received ${data.code}");
        _resultName = '${body['userid']}';
        _resultAvatar = '${body['avatar']}';
      } else if (data.errCode == 1) {
        _resultStatus = '授权失败';
      } else {
        _resultStatus = '用户取消';
      }
      setState(() {});
    });
  }

  _initFluwx() async {
    await fluwxWorker.register(
        schema: schema, corpId: corpId, agentId: agentId);
    var result = await fluwxWorker.isWeChatInstalled();
    print("WX is installed $result");
  }

  @override
  Widget build(BuildContext context) {
    var ava = _resultAvatar == ''
        ? Text(_resultAvatar)
        : CircleAvatar(backgroundImage: NetworkImage(_resultAvatar));
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('企业微信Login Demo'),
        ),
        body: Column(
          children: <Widget>[
            OutlinedButton(
              onPressed: () {
                fluwxWorker.sendAuth(
                    schema: schema, appId: corpId, agentId: agentId);
              },
              child: Text('发起授权'),
            ),
            const Text("响应结果;"),
            Text(_resultStatus),
            Text(_resultName),
            ava
          ],
        ),
      ),
    );
  }
}
