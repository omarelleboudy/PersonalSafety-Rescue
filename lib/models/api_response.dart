// T is a generic type parameter, it basically changes itself to match the type of the sent data.
class APIResponse<T> {
  int status;
  T result;
  bool hasErrors;
  String messages;

  APIResponse(
      {this.status, this.result, this.messages, this.hasErrors = false});

  factory APIResponse.fromJson(Map<String, dynamic> item) {
    return APIResponse(
      status: item['status'],
      result: item['result'],
      hasErrors: item['hasErrors'],
      //messages: item['messages'].toString(),
    );
  }
}
