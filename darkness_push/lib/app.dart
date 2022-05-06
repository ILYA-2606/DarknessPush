import 'dart:convert';

import 'package:darkness_push/model/constants.dart';
import 'package:darkness_push/service/file_service.dart';
import 'package:darkness_push/service/push_service.dart';
import 'package:flutter/material.dart';

enum PushState { notStarted, started, success, error }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSendButtonAvailable = false;
  String? key;
  String? keyName;
  String? teamErrorText;
  String? keyErrorText;
  String? deviceErrorText;
  String? bodyErrorText;
  String? bundleErrorText;
  PushState pushState = PushState.notStarted;
  final TextEditingController teamController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController deviceController = TextEditingController();
  final TextEditingController bundleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    teamController.text = 'N7B9Y8WYA7';
    teamController.addListener(() => updateTextController(teamController, needUppercase: true));
    keyController.text = 'ZZSVDC7MN7';
    keyController.addListener(() => updateTextController(keyController, needUppercase: true));
    deviceController.text = '8139daa3ef4de9b5f88463f6c798400cf8e4832eee3b2033a40afa1e6ac068f2';
    deviceController.addListener(() => updateTextController(deviceController));
    bundleController.text = 'ru.it4it.project112';
    bundleController.addListener(() => updateTextController(bundleController));
    bodyController.text = Constants.body;
    bodyController.addListener(() => updateTextController(bodyController));
  }

  void updateTextController(TextEditingController controller, {bool needUppercase = false}) {
    if (needUppercase) {
      final text = controller.text.toUpperCase();
      final selection = TextSelection(baseOffset: text.length, extentOffset: text.length);
      controller.value = controller.value.copyWith(text: text, selection: selection, composing: TextRange.empty);
    }
    updateState();
  }

  @override
  void dispose() {
    teamController.dispose();
    keyController.dispose();
    deviceController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: teamController,
              decoration:
                  InputDecoration(border: const OutlineInputBorder(), labelText: 'Team ID', errorText: teamErrorText),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                TextFormField(
                  controller: keyController,
                  decoration:
                      InputDecoration(border: const OutlineInputBorder(), labelText: 'Key ID', errorText: keyErrorText),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis),
                      backgroundColor: Colors.white,
                      maximumSize: const Size(200, 40),
                    ),
                    child: Text(keyName ?? 'Select P8'),
                    onPressed: () => processFileSelection(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: bundleController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Bundle ID',
                errorText: bundleErrorText,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              maxLines: null,
              controller: deviceController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Device token',
                errorText: deviceErrorText,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              minLines: 1,
              maxLines: null,
              controller: bodyController,
              decoration:
                  InputDecoration(border: const OutlineInputBorder(), labelText: 'Body', errorText: bodyErrorText),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                primary: isSendButtonAvailable ? Colors.blue : Colors.grey,
              ),
              child: const Text('Send push'),
              onPressed: () {
                sendRequest();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> processFileSelection() async {
    try {
      final file = await FileService.selectP8File();
      final keyID = file.keyID;
      setState(() {
        keyName = file.name;
        key = file.key;
        if (keyID != null) {
          keyController.text = keyID;
        }
      });
    } catch (error) {
      if (error == FileServiceError.selectedNotP8File) {
        showSnackBar('Please select P8 file');
      } else if (error == FileServiceError.selectedWrongFile) {
        showSnackBar('Selected wrong P8 file');
      }
    }
  }

  Future<void> sendRequest() async {
    updateState();
    if (!validateInputData()) return;
    final pushStatus = await PushService.sendPush(
      deviceToken: deviceController.text,
      body: bodyController.text,
      key: key ?? '',
      teamID: teamController.text,
      keyID: keyController.text,
      bundleID: bundleController.text,
    );
    setState(() => showSnackBar(pushStatus.description, isError: !pushStatus.isSuccess));
  }

  bool validateInputData() {
    return keyErrorText == null &&
        teamErrorText == null &&
        deviceErrorText == null &&
        bundleErrorText == null &&
        key != null;
  }

  void updateState() {
    setState(() {
      keyErrorText = key == null
          ? "P8 key isn't selected"
          : keyController.text.isEmpty
              ? "Field isn't entered"
              : keyController.text.length != 10
                  ? 'Field must contains 10 symbols'
                  : null;
      teamErrorText = teamController.text.isEmpty
          ? "Field isn't entered"
          : teamController.text.length != 10
              ? 'Field must contains 10 symbols'
              : null;
      deviceErrorText = deviceController.text.isEmpty ? "Field isn't entered" : null;
      bundleErrorText = bundleController.text.isEmpty ? "Field isn't entered" : null;
      if (bodyController.text.isEmpty) {
        bodyErrorText = "Field isn't entered";
      } else {
        try {
          final _ = json.decode(bodyController.text);
          bodyErrorText = null;
        } catch (_) {
          bodyErrorText = 'Body has an incorrect JSON';
        }
      }
      isSendButtonAvailable = validateInputData();
    });
  }

  void showSnackBar(String text, {bool isError = true}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text), backgroundColor: isError ? Colors.red : Colors.green));
  }
}
