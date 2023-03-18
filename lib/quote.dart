// import 'package:flutter/services.dart';

class Quote {
  final String id;
  final String quote;
  final String author;

  Quote({
    required this.id,
    required this.author,
    required this.quote,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
        id: json['_id'] as String,
        author: json['author'] as String,
        quote: json['content'] as String);
  }
}
