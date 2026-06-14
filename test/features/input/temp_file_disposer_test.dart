import 'dart:io';

import 'package:documink/features/input/temp_file_disposer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deletes an existing file', () async {
    final file = File(
      '${Directory.systemTemp.path}/disposer_'
      '${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    await file.writeAsString('sensitive');
    expect(await file.exists(), isTrue);

    await const IoTempFileDisposer().dispose(file.path);

    expect(await file.exists(), isFalse);
  });

  test('a missing path is a no-op (never throws)', () async {
    // Should complete without error even though the file does not exist.
    await const IoTempFileDisposer().dispose(
      '${Directory.systemTemp.path}/does_not_exist_${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
  });
}
