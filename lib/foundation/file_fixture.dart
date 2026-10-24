import 'dart:convert';
import 'dart:typed_data';

/// A diagnostic fixture, distinct from any future backup format.
abstract final class FileFixture {
  static const maxBytes = 64 * 1024;
  static const _json =
      '{"format":"momentum.foundation","version":1,"marker":"phase-one-local-fixture"}';
  static Uint8List encode() => Uint8List.fromList(utf8.encode(_json));

  static Future<void> validateStream(Stream<List<int>> stream) async {
    final buffer = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      if (buffer.length + chunk.length > maxBytes) {
        throw const FormatException('File exceeds the 64 KiB probe limit.');
      }
      buffer.add(chunk);
    }
    final json = jsonDecode(utf8.decode(buffer.takeBytes()));
    if (json is! Map<String, dynamic> ||
        json.length != 3 ||
        json['format'] != 'momentum.foundation' ||
        json['version'] != 1 ||
        json['marker'] != 'phase-one-local-fixture') {
      throw const FormatException(
        'This is not the Momentum foundation fixture.',
      );
    }
  }
}
