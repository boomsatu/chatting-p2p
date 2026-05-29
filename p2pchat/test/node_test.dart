import 'package:flutter_test/flutter_test.dart';
import 'package:p2pchat/src/rust/api/node_api.dart' as node_api;

void main() {
  group('Rust Libp2p Node FFI Tests', () {
    test('Should check node FFI bridge binding methods exist', () {
      // These verify the top-level FFI signatures exist and compile cleanly.
      // Under host unit tests (without a running native library), they will throw
      // the expected Flutter Rust Bridge uninitialized exception.
      expect(
        () => node_api.isNodeRunning(),
        throwsA(isA<StateError>()),
      );

      expect(
        () => node_api.getPeerId(),
        throwsA(isA<StateError>()),
      );

      expect(
        () => node_api.getPeerCount(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
