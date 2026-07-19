String resolveImageMime(String name, String? mimeType) {
  final mime = mimeType?.toLowerCase();
  if (mime != null && mime.startsWith('image/')) {
    if (mime == 'image/jpg' || mime == 'image/pjpeg') return 'image/jpeg';
    if (mime == 'image/jpeg' || mime == 'image/png' || mime == 'image/webp') {
      return mime;
    }
  }
  final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    default:
      return 'image/jpeg';
  }
}

String ensureImageFilename(String name, String mime) {
  if (name.contains('.') && !name.endsWith('.blob')) return name;
  final ext = mime == 'image/png'
      ? 'png'
      : mime == 'image/webp'
          ? 'webp'
          : 'jpg';
  return 'image.$ext';
}
