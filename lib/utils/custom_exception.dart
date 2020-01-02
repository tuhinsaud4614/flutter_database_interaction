class CustomException implements Exception {
  final String msg;
  CustomException(this.msg);

  @override
  String toString() {
    return msg;
  }
}
