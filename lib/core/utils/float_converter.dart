import 'dart:typed_data';

class FloatComponents {
  final String sign;
  final String exponent;
  final String mantissa;
  final String rawBinary;

  FloatComponents({
    required this.sign,
    required this.exponent,
    required this.mantissa,
    required this.rawBinary,
  });
}

class FloatConverter {
  /// Converts a standard Dart 64-bit double to a 32-bit single precision
  /// IEEE 754 string representation, broken down into its components.
  static FloatComponents getSinglePrecisionComponents(double value) {
    // 1. Write the double into a Float32List (automatically casts to 32-bit float).
    final byteData = ByteData(4);
    byteData.setFloat32(0, value, Endian.big);

    // 2. Read it back as an unsigned 32-bit integer to extract bits.
    final intBits = byteData.getUint32(0, Endian.big);

    // 3. Convert to 32-bit binary string (pad with zeros).
    final binaryString = intBits.toRadixString(2).padLeft(32, '0');

    // 4. Split into components based on IEEE 754 Single Precision rules.
    final sign = binaryString.substring(0, 1);
    final exponent = binaryString.substring(1, 9);
    final mantissa = binaryString.substring(9, 32);

    return FloatComponents(
      sign: sign,
      exponent: exponent,
      mantissa: mantissa,
      rawBinary: binaryString,
    );
  }
}
