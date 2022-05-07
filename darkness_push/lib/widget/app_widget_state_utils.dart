import 'dart:convert';

import 'package:darkness_push/service/file_service.dart';
import 'package:darkness_push/service/push_service.dart';
import 'package:darkness_push/widget/app_widget.dart';
import 'package:darkness_push/widget/app_widget_state_preferences.dart';
import 'package:flutter/material.dart';

extension Utils on AppWidgetState {
  void updateTextController(TextEditingController controller, {bool needUppercase = false}) {
    if (needUppercase) {
      // setState(() => controller.text = controller.text.toUpperCase());
      final text = controller.text.toUpperCase();
      controller.value =
          controller.value.copyWith(text: text, selection: controller.selection, composing: TextRange.empty);
    }
    updateState();
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
    savePreferences();
    setState(() => isPushSending = true);
    final pushStatus = await PushService.sendPush(
      deviceToken: deviceController.text,
      body: bodyController.text,
      key: key ?? '',
      teamID: teamController.text,
      keyID: keyController.text,
      bundleID: bundleController.text,
      type: pushType,
      environment: pushEnvironment,
      priority: pushPriority,
      collapseID: collapseController.text,
    );
    setState(() => isPushSending = false);
    showSnackBar(pushStatus.description, isError: !pushStatus.isSuccess);
  }

  void updateState() {
    setState(() {
      keyErrorText = key == null
          ? 'P8 key must be selected'
          : keyController.text.length != 10
              ? 'Field must contains 10 symbols'
              : null;
      teamErrorText = teamController.text.length != 10 ? 'Field must contains 10 symbols' : null;
      deviceErrorText = deviceController.text.length != 64 ? 'Field must contains 64 symbols' : null;
      bundleErrorText = bundleController.text.isEmpty ? 'Field must not be empty' : null;
      try {
        final _ = json.decode(bodyController.text);
        bodyErrorText = null;
      } catch (_) {
        bodyErrorText = 'Body must be in JSON format';
      }
      isSendEnabled = isValidInputData;
    });
  }

  void showSnackBar(String text, {bool isError = true}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }
}
