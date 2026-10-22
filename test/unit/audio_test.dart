import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AudioPlayer and BytesSource API check', () {
    final bytes = Uint8List(100);
    final source = BytesSource(bytes);
    expect(source.bytes.length, equals(100));
  });
}
