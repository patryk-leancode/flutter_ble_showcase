import 'dart:typed_data';

const advertisedName = 'Hello, Berlin';

const counterServiceUuid = 'ac8d5f91-b303-4cb4-81d7-db8df5a827fb';

const counterReadCharacteristicUuid = '15494e36-15e4-46b9-a3ad-46a633bb81b2';

const counterWriteCharacteristicUuid = '43e595ab-d722-40e6-81c1-ff433520f069';

const counterNotifyCharacteristicUuid = '1b5a0da6-72a6-4104-85d4-8d5826dd9ae1';

Future<void> dummyRequestVeryShort() async =>
    await Future<void>.delayed(const Duration(milliseconds: 500));

Future<void> dummyRequest() async =>
    await Future<void>.delayed(const Duration(seconds: 2));

Uint8List uInt8ListFromInt(int n) {
  List<int> bytes = [];
  final sign = n >= 0 ? 0 : 1;
  n = n.abs();
  while (n > 0) {
    bytes.add(n % 256);
    n ~/= 256;
  }
  while (bytes.length < 4) {
    bytes.add(0);
  }
  bytes[3] |= (128 * sign); // 128(10) = 10000000(2)
  return Uint8List.fromList(bytes);
}

int intFromUint8List(Uint8List list) {
  final bytes = list.toList();
  int result = 0;
  int mult = 1;
  int sign = 0;
  for (int i = 0; i < bytes.length; i++) {
    final byte = i == 3 ? bytes[i] & 127 : bytes[i]; // 127(10) = 01111111(2)
    if (i == 3) {
      sign = bytes[i] >> 7;
    }
    result += byte * mult;
    mult *= 256;
  }
  if (sign == 0) {
    sign = 1;
  } else if (sign == 1) {
    sign = -1;
  }

  return result * sign;
}
