// features/konum/domain/services/konum_servisi.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class KonumServisi {
  // Konum izinlerini kontrol et
  static Future<bool> konumIzniVarMi() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  // Mevcut konumu al
  static Future<Position?> mevcutKonumuAl() async {
    try {
      bool izinVar = await konumIzniVarMi();
      if (!izinVar) return null;
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      print('Konum alınamadı: $e');
      return null;
    }
  }

  // Konumu il/ilçe bilgisine çevir
  static Future<Map<String, String>?> konumuAdreseCevir(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return {
          'il': placemark.administrativeArea ?? 'Bilinmeyen',
          'ilce': placemark.subAdministrativeArea ?? placemark.locality ?? 'Bilinmeyen',
        };
      }
      return null;
    } catch (e) {
      print('Adres çevrilemedi: $e');
      return null;
    }
  }
}