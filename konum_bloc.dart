import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

part 'konum_event.dart';
part 'konum_state.dart';

class KonumBloc extends Bloc<KonumEvent, KonumState> {
  KonumBloc() : super(KonumInitial()) {
    on<KonumYukle>(_onKonumYukle);
  }

  Future<void> _onKonumYukle(
    KonumYukle event,
    Emitter<KonumState> emit,
  ) async {
    emit(KonumYukleniyor());

    try {
      // İzin kontrolü
      final permissionStatus = await Permission.location.request();
      
      if (permissionStatus.isGranted) {
        // Konumu al
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        );

        // Adres bilgisini al
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark placemark = placemarks.first;
          
          final konum = Konum(
            il: placemark.administrativeArea ?? 'Bilinmiyor',
            ilce: placemark.subAdministrativeArea ?? placemark.locality ?? 'Bilinmiyor',
            mahalle: placemark.street ?? 'Bilinmiyor',
            enlem: position.latitude,
            boylam: position.longitude,
          );

          emit(KonumYuklendi(konum));
        } else {
          emit(KonumHata('Adres bilgisi alınamadı'));
        }
      } else {
        emit(KonumHata('Konum izni verilmedi'));
      }
    } catch (e) {
      print('Konum hatası: $e');
      emit(KonumHata('Konum alınamadı: $e'));
    }
  }
}

class Konum {
  final String il;
  final String ilce;
  final String mahalle;
  final double enlem;
  final double boylam;

  Konum({
    required this.il,
    required this.ilce,
    required this.mahalle,
    required this.enlem,
    required this.boylam,
  });
}