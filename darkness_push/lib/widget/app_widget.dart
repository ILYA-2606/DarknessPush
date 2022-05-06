import 'dart:convert';

import 'package:darkness_push/model/constants.dart';
import 'package:darkness_push/model/push_status.dart';
import 'package:darkness_push/service/file_service.dart';
import 'package:darkness_push/service/push_service.dart';
import 'package:darkness_push/widget/button_widget.dart';
import 'package:darkness_push/widget/field_widget.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  bool isSendEnabled = false;
  String? key;
  String? keyName;
  String? teamErrorText;
  String? keyErrorText;
  String? deviceErrorText;
  String? bodyErrorText;
  String? bundleErrorText;
  bool isPushSending = false;
  final TextEditingController teamController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController deviceController = TextEditingController();
  final TextEditingController bundleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  bool get isValidInputData {
    return keyErrorText == null &&
        teamErrorText == null &&
        deviceErrorText == null &&
        bundleErrorText == null &&
        key != null;
  }

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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(20),
            child: Column(
              children: <Widget>[
                FieldWidget(controller: teamController, title: 'Team ID', errorText: teamErrorText),
                const SizedBox(height: 20),
                Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    FieldWidget(controller: keyController, title: 'Key ID', errorText: keyErrorText),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 8),
                      child: SizedBox(
                        height: 50,
                        child: ConstrainedBox(
                          constraints: BoxConstraints.loose(const Size(200, 50)),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: ButtonWidget(title: keyName ?? 'Select P8', onPressed: () => processFileSelection()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FieldWidget(controller: bundleController, title: 'Bundle ID', errorText: bundleErrorText),
                const SizedBox(height: 20),
                FieldWidget(
                  controller: deviceController,
                  title: 'Device token',
                  errorText: deviceErrorText,
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                FieldWidget(controller: bodyController, title: 'Body', errorText: bodyErrorText, maxLines: null),
                const SizedBox(height: 20),
                if (!isPushSending)
                  ButtonWidget(title: 'Send push', isEnabled: isSendEnabled, onPressed: () => sendRequest())
                else
                  const CircularProgressIndicator()
              ],
            ),
          ),
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
      updateState();
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
    if (!isValidInputData) return;
    setState(() => isPushSending = true);
    final pushStatus = await PushService.sendPush(
      deviceToken: deviceController.text,
      body: bodyController.text,
      key: key ?? '',
      teamID: teamController.text,
      keyID: keyController.text,
      bundleID: bundleController.text,
    );
    setState(() => isPushSending = false);
    showSnackBar(pushStatus.description, isError: !pushStatus.isSuccess);
  }

  void updateState() {
    setState(() {
      keyErrorText = key == null
          ? "P8 key isn't selected"
          : keyController.text.length != 10
              ? 'Field must contains 10 symbols'
              : null;
      teamErrorText = teamController.text.length != 10 ? 'Field must contains 10 symbols' : null;
      deviceErrorText = deviceController.text.length != 64 ? 'Field must contains 64 symbols' : null;
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
      isSendEnabled = isValidInputData;
    });
  }

  void showSnackBar(String text, {bool isError = true}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }
}
