import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connectivity_state.dart';

export 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity;
  final InternetConnection _internetConnection;
  
  StreamSubscription? _connectivitySubscription;

  ConnectivityCubit({
    required Connectivity connectivity,
    required InternetConnection internetConnection,
  })  : _connectivity = connectivity,
        _internetConnection = internetConnection,
        super(ConnectivityStatus.checking) {
    _init();
  }

  void _init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) async {
      final hasInternet = await _internetConnection.hasInternetAccess;
      if (hasInternet) {
        emit(ConnectivityStatus.connected);
      } else {
        emit(ConnectivityStatus.disconnected);
      }
    });
    
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final hasInternet = await _internetConnection.hasInternetAccess;
    emit(hasInternet ? ConnectivityStatus.connected : ConnectivityStatus.disconnected);
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
