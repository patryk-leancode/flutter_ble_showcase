import 'dart:typed_data';

enum CupSize {
  small('Small'),
  medium('Medium'),
  large('Large');

  const CupSize(this.label);

  final String label;
}

enum BrewStatus {
  idle('Idle'),
  brewing('Brewing'),
  ready('Ready');

  const BrewStatus(this.label);

  final String label;
}

class BrewProgress {
  const BrewProgress({required this.status, required this.progress});

  factory BrewProgress.fromBytes(Uint8List bytes) =>
      BrewProgress(status: BrewStatus.values[bytes[0]], progress: bytes[1]);

  static const idle = BrewProgress(status: .idle, progress: 0);

  final BrewStatus status;
  final int progress; // 0–100

  Uint8List toBytes() => Uint8List.fromList([status.index, progress]);
}
