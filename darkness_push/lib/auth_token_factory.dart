import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthTokenFactory {
  static String makeAuthToken(String key, String teamID, String keyID) {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final JWT jwt = JWT(
      {'iss': teamID, 'iat': timestamp, 'exp': timestamp + 3600},
      header: {'alg': 'ES256', 'kid': keyID},
    );
    final privateKey = ECPrivateKey(key);
    final token = jwt.sign(privateKey, algorithm: JWTAlgorithm.ES256);
    return 'bearer $token';
  }
}
