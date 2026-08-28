class PeripheralModel {
  const PeripheralModel({required this.name});

  final String name;
}

class DetectedPeripheralModel {
  const DetectedPeripheralModel({required this.name, required this.uuid});

  final String name;
  final String uuid;
}