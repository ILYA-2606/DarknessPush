T? tryCast<T>(dynamic object) => object is T ? object : null;

typedef GenericCallback<T> = T Function();

T? tryOrNull<T>(GenericCallback<T> callback) {
  try {
    final object = callback();
    return object;
  } catch (_) {
    return null;
  }
}
