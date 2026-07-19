int asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  throw FormatException('Expected int, got $value');
}

String? asString(dynamic value) => value?.toString();
