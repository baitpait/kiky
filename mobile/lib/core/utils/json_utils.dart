int asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  throw FormatException('Expected int, got $value');
}

int? asIntOrNull(dynamic value) {
  if (value == null) return null;
  try {
    return asInt(value);
  } catch (_) {
    return null;
  }
}

String? asString(dynamic value) => value?.toString();
