import 'package:darkness_push/model/constants.dart';
import 'package:darkness_push/model/utils.dart';
import 'package:darkness_push/service/push_service.dart';
import 'package:darkness_push/widget/app_widget.dart';
import 'package:darkness_push/widget/app_widget_state_utils.dart';
import 'package:native_shared_preferences/native_shared_preferences.dart';

extension Preferences on AppWidgetState {
  void loadPreferences() {
    NativeSharedPreferences.getInstance().then((prefs) {
      setState(() {
        pushType = tryOrNull(() => PushType.values.byName(prefs.getString('pushType') ?? '')) ?? PushType.alert;
        pushEnvironment = tryOrNull(() => PushEnvironment.values.byName(prefs.getString('pushEnvironment') ?? '')) ??
            PushEnvironment.production;
        key = prefs.getString('key');
        pushPriority = prefs.getInt('priority') ?? 10;
        if (prefs.getString('teamID') != null) teamController.text = prefs.getString('teamID') ?? '';
        if (prefs.getString('keyID') != null) keyController.text = prefs.getString('keyID') ?? '';
        if (prefs.getString('bundleID') != null) bundleController.text = prefs.getString('bundleID') ?? '';
        if (prefs.getString('deviceToken') != null) deviceController.text = prefs.getString('deviceToken') ?? '';
        if (prefs.getString('collapseID') != null) collapseController.text = prefs.getString('collapseID') ?? '';
        if (prefs.getString('body')?.isNotEmpty == true) {
          bodyController.text = prefs.getString('body') ?? Constants.body;
        }
      });
      updateState();
    });
  }

  void savePreferences() {
    NativeSharedPreferences.getInstance().then((prefs) {
      prefs.setString('teamID', teamController.text);
      prefs.setString('keyID', keyController.text);
      prefs.setString('bundleID', bundleController.text);
      prefs.setString('collapseID', collapseController.text);
      prefs.setString('deviceToken', deviceController.text);
      prefs.setString('body', bodyController.text);
      prefs.setString('pushType', pushType.name);
      prefs.setString('pushEnvironment', pushEnvironment.name);
      prefs.setString('key', key);
      prefs.setInt('priority', pushPriority);
    });
  }
}
