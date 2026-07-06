import 'package:flutter_test/flutter_test.dart';
import 'package:invesly/common/extensions/num_extension.dart';

void main() {
  group('EMDoubleExtension', () {
    test('toPrecisionDouble rounds correctly', () {
      expect(1.23456.toPrecisionDouble(2), 1.23);
      expect(1.235.toPrecisionDouble(2), 1.24);
      expect((-1.235).toPrecisionDouble(2), -1.24);
      expect(double.infinity.toPrecisionDouble(2), double.infinity);
      expect(double.nan.toPrecisionDouble(2).isNaN, isTrue);
    });

    test('toPrecisionString removes trailing zeros', () {
      expect(1.2300.toPrecisionString(4), '1.23');
      expect(1.2000.toPrecisionString(4), '1.2');
      expect(1.0000.toPrecisionString(4), '1');
      expect(0.0.toPrecisionString(4), '0');
      expect((-0.0).toPrecisionString(4), '-0');
    });

    test('toCompact returns compact notation', () {
      expect(1200.toCompact(), anyOf('1.2K', '1K'));
      expect(1000000.toCompact(), anyOf('1M', '1.0M', '1.00M'));
      expect(double.infinity.toCompact(), '');
      expect(double.nan.toCompact(), '');
    });

    test('formatAsBytes returns human-readable byte units', () {
      expect(0.formatAsBytes(2), '0 B');
      expect(1024.formatAsBytes(2), '1.00 KB');
      expect(1536.formatAsBytes(2), '1.50 KB');
      expect(1048576.formatAsBytes(2), '1.00 MB');
    });
  });
}
