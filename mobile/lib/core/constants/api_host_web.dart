import 'dart:html' as html;

/// Same host as the browser tab (localhost or 127.0.0.1).
String get apiHost => html.window.location.hostname ?? 'localhost';
