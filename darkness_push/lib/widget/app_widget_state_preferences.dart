import 'package:darkness_push/model/constants.dart';
import 'package:darkness_push/model/utils.dart';
import 'package:darkness_push/service/push_service.dart';
import 'package:darkness_push/widget/app_widget.dart';
import 'package:darkness_push/widget/app_widget_state_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension Preferences on AppWidgetState {
  void loadPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        pushType = tryOrNull(() => PushType.values.byName(prefs.getString('pushType') ?? '')) ?? PushType.alert;
        pushEnvironment = tryOrNull(() => PushEnvironment.values.byName(prefs.getString('pushEnvironment') ?? '')) ??
            PushEnvironment.production;
        key = prefs.getString('key');
        keyName = prefs.getString('keyName');
        pushPriority = prefs.getInt('priority') ?? 10;
        if (prefs.getString('teamID') != null) teamController.text = prefs.getString('teamID') ?? '';
        if (prefs.getString('keyID') != null) keyController.text = prefs.getString('keyID') ?? '';
        if (prefs.getString('bundleID') != null) bundleController.text = prefs.getString('bundleID') ?? '';
        if (prefs.getString('deviceToken') != null) deviceController.text = prefs.getString('deviceToken') ?? '';
        if (prefs.getString('collapseID') != null) collapseController.text = prefs.getString('collapseID') ?? '';
        if (prefs.getString('body')?.isNotEmpty == true) {
          bodyController.text = prefs.getString('body') ?? Constants.body;
        } else {
          bodyController.text = Constants.body;
        }
      });
      updateState();
    });
  }

  void savePreferences() {
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString('teamID', teamController.text);
      await prefs.setString('keyID', keyController.text);
      await prefs.setString('bundleID', bundleController.text);
      await prefs.setString('collapseID', collapseController.text);
      await prefs.setString('deviceToken', deviceController.text);
      await prefs.setString('body', bodyController.text);
      await prefs.setString('pushType', pushType.name);
      await prefs.setString('pushEnvironment', pushEnvironment.name);
      await prefs.setString('key', key ?? '');
      await prefs.setString('keyName', keyName ?? '');
      await prefs.setInt('priority', pushPriority);
    });
  }
}
