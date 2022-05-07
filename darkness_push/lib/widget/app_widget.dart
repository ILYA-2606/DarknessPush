import 'package:darkness_push/service/push_service.dart';
import 'package:darkness_push/widget/app_widget_state_preferences.dart';
import 'package:darkness_push/widget/app_widget_state_utils.dart';
import 'package:darkness_push/widget/button_widget.dart';
import 'package:darkness_push/widget/field_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<AppWidget> createState() => AppWidgetState();
}

class AppWidgetState extends State<AppWidget> {
  bool isSendEnabled = false;
  String? key;
  String? keyName;
  String? teamErrorText;
  String? keyErrorText;
  String? deviceErrorText;
  String? bodyErrorText;
  String? bundleErrorText;
  bool isPushSending = false;
  PushType pushType = PushType.alert;
  PushEnvironment pushEnvironment = PushEnvironment.production;
  int pushPriority = 10;
  final TextEditingController teamController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController deviceController = TextEditingController();
  final TextEditingController bundleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController collapseController = TextEditingController();

  bool get isValidInputData {
    return keyErrorText == null &&
        teamErrorText == null &&
        deviceErrorText == null &&
        bundleErrorText == null &&
        bodyErrorText == null &&
        key != null;
  }

  bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    teamController.addListener(() => updateTextController(teamController, needUppercase: true));
    keyController.addListener(() => updateTextController(keyController, needUppercase: true));
    deviceController.addListener(() => updateTextController(deviceController));
    bundleController.addListener(() => updateTextController(bundleController));
    bodyController.addListener(() => updateTextController(bodyController));
    loadPreferences();
  }

  @override
  void setState(VoidCallback fn) => super.setState(fn);

  @override
  void dispose() {
    teamController.dispose();
    keyController.dispose();
    deviceController.dispose();
    bundleController.dispose();
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
        physics: const AlwaysScrollableScrollPhysics(),
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
                      padding: EdgeInsets.only(top: isMacOS ? 12 : 6, right: 8),
                      child: ButtonWidget(
                        title: keyName ?? 'Select P8 key',
                        fontSize: 14,
                        onPressed: () => processFileSelection(),
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
                ),
                const SizedBox(height: 20),
                FieldWidget(controller: collapseController, title: 'Collapse ID'),
                const SizedBox(height: 20),
                FieldWidget(controller: bodyController, title: 'Body', errorText: bodyErrorText, maxLines: null),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Type'),
                    const SizedBox(width: 20),
                    DropdownButton(
                      value: pushType,
                      items: PushType.values
                          .map((e) => DropdownMenuItem<PushType>(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (PushType? e) => setState(() => pushType = e ?? pushType),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Environment'),
                    const SizedBox(width: 20),
                    DropdownButton(
                      value: pushEnvironment,
                      items: PushEnvironment.values
                          .map((e) => DropdownMenuItem<PushEnvironment>(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (PushEnvironment? e) => setState(() => pushEnvironment = e ?? pushEnvironment),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Priority'),
                    const SizedBox(width: 20),
                    DropdownButton(
                      value: pushPriority,
                      items: [5, 10].map((e) => DropdownMenuItem<int>(value: e, child: Text(e.toString()))).toList(),
                      onChanged: (int? e) => setState(() => pushPriority = e ?? pushPriority),
                    ),
                  ],
                ),
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
}
