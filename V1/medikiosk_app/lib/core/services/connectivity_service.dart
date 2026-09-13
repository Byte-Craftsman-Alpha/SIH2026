import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get isOnline => _connectivity.onConnectivityChanged.map(
      (result) => result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)
  );
}
