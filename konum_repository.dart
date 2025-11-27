import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ezancep_pro/features/konum/domain/entities/konum.dart';
import 'package:ezancep_pro/features/konum/domain/repositories/konum_repository.dart';
import 'package:ezancep_pro/features/konum/data/models/konum_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KonumRepositoryImpl implements KonumRepository {
  @override
  Future<Either<String, Konum>> getKonum() async {
    try {
      // Konum izinlerini kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left('Konum izinleri reddedildi');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left('Konum izinleri kalıcı olarak reddedildi. Lütfen ayarlardan izin verin.');
      }

      // Konumu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final konum = KonumModel(
        enlem: position.latitude,
        boylam: position.longitude,
      );

      // Şehir adını al
      final sehirResult = await getSehirAdi(position.latitude, position.longitude);
      
      return sehirResult.fold(
        (error) => Right(konum),
        (sehirAdi) => Right(konum.copyWith(sehir: sehirAdi)),
      );

    } catch (e) {
      return Left('Konum alınamadı: $e');
    }
  }

  @override
  Future<Either<String, String>> getSehirAdi(double enlem, double boylam) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$enlem&longitude=$boylam&localityLanguage=tr')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sehir = data['city'];
        final ulke = data['countryName'];
        
        if (sehir != null) {
          return Right('$sehir, $ulke');
        }
      }
      
      return Left('Şehir bilgisi alınamadı');
    } catch (e) {
      return Left('Şehir bilgisi alınamadı: $e');
    }
  }

  @override
  Future<void> kayitliKonumuKaydet(Konum konum) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('kayitli_enlem', konum.enlem);
    await prefs.setDouble('kayitli_boylam', konum.boylam);
    await prefs.setString('kayitli_sehir', konum.sehir ?? '');
    await prefs.setString('kayitli_ulke', konum.ulke ?? '');
  }

  @override
  Future<Konum?> kayitliKonumuGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final enlem = prefs.getDouble('kayitli_enlem');
    final boylam = prefs.getDouble('kayitli_boylam');
    final sehir = prefs.getString('kayitli_sehir');
    final ulke = prefs.getString('kayitli_ulke');

    if (enlem != null && boylam != null) {
      return KonumModel(
        enlem: enlem,
        boylam: boylam,
        sehir: sehir,
        ulke: ulke,
      );
    }
    
    return null;
  }
}