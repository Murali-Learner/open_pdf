extension NamingExtension on String {
  String toPascalCase() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}
