import 'dart:typed_data';

const advertisedName = 'BLE';

const counterServiceUuid = 'ac8d5f91-b303-4cb4-81d7-db8df5a827fb';

const counterReadCharacteristicUuid = '15494e36-15e4-46b9-a3ad-46a633bb81b2';

const counterWriteCharacteristicUuid = '43e595ab-d722-40e6-81c1-ff433520f069';

const counterNotifyCharacteristicUuid = '1b5a0da6-72a6-4104-85d4-8d5826dd9ae1';

Future<void> dummyRequestVeryShort() async =>
    await Future<void>.delayed(const Duration(milliseconds: 500));

Future<void> dummyRequest() async =>
    await Future<void>.delayed(const Duration(seconds: 2));

Uint8List uInt8ListFromInt(int n) =>
    Uint8List(4)..buffer.asByteData().setInt32(0, n, .little);

int intFromUint8List(Uint8List list) =>
    ByteData.sublistView(list).getInt32(0, .little);
