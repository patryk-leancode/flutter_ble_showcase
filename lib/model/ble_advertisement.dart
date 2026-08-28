class BleAdvertisement {
  BleAdvertisement({this.name, this.serviceUuids = const []});

  final String? name;
  final List<String> serviceUuids;
}
