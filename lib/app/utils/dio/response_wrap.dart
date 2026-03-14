class ResponseWrap<T> {
  final String message;
  final bool status;
  final T? response;

  ResponseWrap({required this.message, required this.status, this.response});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'status': status,
      'response': response,
    };
  }

  factory ResponseWrap.fromMap(Map<String, dynamic> map, {T? response}) {
    return ResponseWrap<T>(
      message: map['message'] ?? "no message",
      status: map['status'] ?? false,
      response: response,
    );
  }
}
