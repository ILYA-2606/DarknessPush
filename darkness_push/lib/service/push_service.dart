import 'dart:convert';
import 'dart:io';

import 'package:darkness_push/model/auth_token_factory.dart';
import 'package:darkness_push/model/push_status.dart';
import 'package:darkness_push/model/utils.dart';
import 'package:http2/http2.dart';

enum PushType { alert, background, location, voip, complication, fileprovider, mdm }
enum PushEnvironment { production, development }

extension Environment on PushEnvironment {
  String get host {
    switch (this) {
      case PushEnvironment.production:
        return 'api.push.apple.com';
      case PushEnvironment.development:
        return 'api.sandbox.push.apple.com';
    }
  }
}

class PushService {
  static Future<PushStatus> sendPush({
    required String deviceToken,
    required String body,
    required String key,
    required String teamID,
    required String keyID,
    required String bundleID,
    required PushType type,
    required PushEnvironment environment,
    required int priority,
    String? collapseID,
  }) async {
    try {
      final url = Uri.https(
        environment.host,
        '3/device/$deviceToken',
      );
      final transport = ClientTransportConnection.viaSocket(
        await SecureSocket.connect(url.host, url.port, supportedProtocols: ['h2']),
      );
      final bytes = utf8.encode(body);
      final stream = transport.makeRequest([
        Header.ascii(':method', 'POST'),
        Header.ascii(':path', url.path),
        Header.ascii(':scheme', url.scheme),
        Header.ascii(':authority', url.host),
        Header.ascii('apns-topic', bundleID),
        Header.ascii('apns-push-type', type.name),
        Header.ascii('authorization', AuthTokenFactory.makeAuthToken(key, teamID, keyID)),
        Header.ascii('apns-priority', priority.toString()),
        if (collapseID != null && collapseID.isNotEmpty) Header.ascii('apns-collapse-id', collapseID),
      ]);
      stream.sendData(bytes, endStream: true);
      String? statusCode;
      String? descriptionText;
      await for (final message in stream.incomingMessages) {
        if (message is HeadersStreamMessage) {
          for (final header in message.headers) {
            final name = utf8.decode(header.name);
            final value = utf8.decode(header.value);
            if (name == ':status') {
              statusCode = value;
            }
          }
        } else if (message is DataStreamMessage) {
          final description = utf8.decode(message.bytes);
          final object = json.decode(description);
          final Map<String, dynamic>? map = tryCast<Map<String, dynamic>>(object);
          print(object.runtimeType);
          if (map != null) {
            final reason = map['reason'];
            if (reason != null && reason is String) {
              descriptionText = reason;
            }
          }
          descriptionText ??= description;
        }
      }
      await transport.finish();
      if (statusCode == '200') {
        return PushStatus(isSuccess: true, description: 'Push sent');
      } else if (statusCode != null) {
        return PushStatus(isSuccess: false, description: '$statusCode: ${descriptionText ?? 'No description'}');
      } else {
        return PushStatus(isSuccess: false, description: 'No answer');
      }
    } catch (error) {
      return PushStatus(isSuccess: false, description: 'Error: $error');
    }
  }
}
