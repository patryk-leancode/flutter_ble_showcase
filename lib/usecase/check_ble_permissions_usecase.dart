import 'package:permission_handler/permission_handler.dart';

class CheckBlePermissionsUsecase {
  Future<bool> call({required List<Permission> permissions}) async {
    final allGranted = await Future.wait(
      permissions.map((p) => p.status.isGranted),
    );
    return allGranted.every((isGranted) => isGranted);
  }
}
