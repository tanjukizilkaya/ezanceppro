import 'package:flutter/foundation.dart';
import 'package:ezancep_pro/features/konum/domain/entities/konum.dart';
import 'package:ezancep_pro/features/konum/data/services/konum_servisi.dart';

class KonumProvider with ChangeNotifier {
  Konum? _mevcutKonum;
  bool _yukleniyor = false;
  String? _hataMesaji;

  Konum? get mevcutKonum => _mevcutKonum;
  bool get yukleniyor => _yukleniyor;
  String? get hataMesaji => _hataMesaji;

  // Konumu güncelle
  Future<void> konumuGuncelle() async {
    _yukleniyor = true;
    _hataMesaji = null;
    notifyListeners();

    try {
      _mevcutKonum = await KonumServisi.tamKonumuAl();
      
      if (_mevcutKonum == null) {
        _hataMesaji = 'Konum alınamadı. Lütfen izinleri kontrol edin.';
      }
    } catch (e) {
      _hataMesaji = 'Konum alınırken hata oluştu: ${e.toString()}';
    } finally {
      _yukleniyor = false;
      notifyListeners();
    }
  }

  // Manuel şehir güncelleme
  void sehirGuncelle(String yeniSehir) {
    if (_mevcutKonum != null) {
      _mevcutKonum = _mevcutKonum!.copyWith(sehir: yeniSehir);
      notifyListeners();
    }
  }
}