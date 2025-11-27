import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Diğer sayfaları import edin
import 'package:ezancep_pro/features/tesbih/presentation/pages/tesbih_sayfasi.dart';
import 'package:ezancep_pro/features/dualar/presentation/pages/dualar_sayfasi.dart';
import 'package:ezancep_pro/features/ayetler/presentation/pages/ayetler_sayfasi.dart';
import 'package:ezancep_pro/features/kible/presentation/pages/kible_sayfasi.dart';
import 'package:ezancep_pro/features/ayarlar/presentation/pages/ayarlar_sayfasi.dart';

// KONUM SERVİSİ - TAM VERSİYON
class KonumServisi {
  static const String _konumKey = 'saved_konum';
  static const String _ilceKey = 'saved_ilce';
  static const String _vakitlerKey = 'saved_vakitler';

  // Konum bilgisini kaydet
  static Future<void> konumBilgisiniKaydet(String konum, String ilce) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_konumKey, konum);
    await prefs.setString(_ilceKey, ilce);
  }

  // Kayıtlı konum bilgisini getir
  static Future<Map<String, String>?> kayitliKonumuGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final String? konum = prefs.getString(_konumKey);
    final String? ilce = prefs.getString(_ilceKey);

    if (konum != null && ilce != null) {
      return {'il': konum, 'ilce': ilce};
    }
    return null;
  }

  // Vakitleri kaydet
  static Future<void> vakitleriKaydet(List<Map<String, dynamic>> vakitler) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vakitlerKey, json.encode(vakitler));
  }

  // Kayıtlı vakitleri getir
  static Future<List<Map<String, dynamic>>?> kayitliVakitleriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final String? vakitlerJson = prefs.getString(_vakitlerKey);
    
    if (vakitlerJson != null) {
      final List<dynamic> vakitlerList = json.decode(vakitlerJson);
      return vakitlerList.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return null;
  }

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

// NAMAZ VAKİTLERİ SERVİSİ - TAM VERSİYON
class NamazVakitleriServisi {
  // Aladhan API (Ücretsiz)
  static Future<Map<String, dynamic>?> namazVakitleriniGetir(String sehir) async {
    try {
      final response = await http.get(
        Uri.parse('http://api.aladhan.com/v1/timingsByCity?city=$sehir&country=Turkey&method=2'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('API hatası: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Namaz vakitleri alınamadı: $e');
      return null;
    }
  }
}

// EZAN VAKTI MODELİ
class EzanVakti {
  final String isim;
  final String vakit;
  final bool aktif;
  final bool gecmis;
  final String kalanSure;

  EzanVakti({
    required this.isim,
    required this.vakit,
    required this.aktif,
    required this.gecmis,
    required this.kalanSure,
  });

  Map<String, dynamic> toMap() {
    return {
      'isim': isim,
      'vakit': vakit,
      'aktif': aktif,
      'gecmis': gecmis,
      'kalanSure': kalanSure,
    };
  }

  factory EzanVakti.fromMap(Map<String, dynamic> map) {
    return EzanVakti(
      isim: map['isim'],
      vakit: map['vakit'],
      aktif: map['aktif'],
      gecmis: map['gecmis'],
      kalanSure: map['kalanSure'],
    );
  }
}

// ANA SAYFA - TAM VERSİYON
class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _currentIndex = 0;
  String? _savedKonum;
  String? _savedIlce;
  List<EzanVakti>? _savedVakitler;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedKonum = await KonumServisi.kayitliKonumuGetir();
    final savedVakitler = await KonumServisi.kayitliVakitleriGetir();
    
    if (savedKonum != null) {
      setState(() {
        _savedKonum = savedKonum['il'];
        _savedIlce = savedKonum['ilce'];
      });
    }
    
    if (savedVakitler != null) {
      setState(() {
        _savedVakitler = savedVakitler.map((vakitMap) => EzanVakti.fromMap(vakitMap)).toList();
      });
    }
  }

  List<Widget> get _screens => [
    AnaSayfaIcerik(
      savedKonum: _savedKonum,
      savedIlce: _savedIlce,
      savedVakitler: _savedVakitler,
      onKonumUpdate: (String konum, String ilce, List<EzanVakti> vakitler) {
        setState(() {
          _savedKonum = konum;
          _savedIlce = ilce;
          _savedVakitler = vakitler;
        });
      },
    ),
    const DualarSayfasi(),
    const AyetlerSayfasi(),
    const TesbihSayfasi(),
    const KibleSayfasi(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Ana', 0),
          _buildNavItem(Icons.auto_stories, 'Dualar', 1),
          _buildNavItem(Icons.book, 'Ayetler', 2),
          _buildNavItem(Icons.favorite, 'Tesbih', 3),
          _buildNavItem(Icons.explore, 'Kıble', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00D4AA).withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF00D4AA) : Colors.white54,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF00D4AA) : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ANA SAYFA İÇERİĞİ - TAM VERSİYON
class AnaSayfaIcerik extends StatefulWidget {
  final String? savedKonum;
  final String? savedIlce;
  final List<EzanVakti>? savedVakitler;
  final Function(String, String, List<EzanVakti>)? onKonumUpdate;

  const AnaSayfaIcerik({
    super.key,
    this.savedKonum,
    this.savedIlce,
    this.savedVakitler,
    this.onKonumUpdate,
  });

  @override
  State<AnaSayfaIcerik> createState() => _AnaSayfaIcerikState();
}

class _AnaSayfaIcerikState extends State<AnaSayfaIcerik> {
  String _konum = 'Yükleniyor...';
  String _ilce = 'Yükleniyor...';
  bool _konumYuklendi = false;
  bool _konumHatasi = false;
  List<EzanVakti> _vakitler = [];
  String _aktifVakit = 'Yükleniyor...';
  String _aktifVakitSaat = '--:--';
  bool _ilkYukleme = true;
  bool _kayitliVeriKullanildi = false;
  Timer? _vakitTimer;

  final List<Map<String, String>> _hadisListesi = [
    {
      'hadis': 'Kolaylaştırın, zorlaştırmayın; müjdeleyin, nefret ettirmeyin.',
      'kaynak': 'Buhârî, İlim 11'
    },
  ];

  @override
  void initState() {
    super.initState();
    _konumVeVakitleriYukle();
    _baslatVakitKontrolu();
  }

  @override
  void dispose() {
    _vakitTimer?.cancel();
    super.dispose();
  }

  void _baslatVakitKontrolu() {
    // Her dakika aktif vakit kontrol et
    _vakitTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _aktifVakitleriGuncelle();
      }
    });
  }

  Future<void> _konumVeVakitleriYukle() async {
    // İlk yüklemede kayıtlı konum ve vakitleri kontrol et
    if (_ilkYukleme && widget.savedKonum != null && widget.savedIlce != null && widget.savedVakitler != null) {
      setState(() {
        _konum = widget.savedKonum!;
        _ilce = widget.savedIlce!;
        _vakitler = widget.savedVakitler!;
        _konumYuklendi = true;
        _kayitliVeriKullanildi = true;
      });
      
      // Aktif vakitleri hemen güncelle
      _aktifVakitleriGuncelle();
      
      _ilkYukleme = false;
      return;
    }

    try {
      setState(() {
        _konumYuklendi = false;
        _konumHatasi = false;
        _kayitliVeriKullanildi = false;
      });

      // Konumu al
      final position = await KonumServisi.mevcutKonumuAl();
      
      if (position == null) {
        setState(() {
          _konumHatasi = true;
          _konum = 'Konum alınamadı';
          _ilce = 'İzin verilmemiş';
        });
        _vakitler = _getOrnekVakitler();
        _aktifVakitleriGuncelle();
        return;
      }

      // Konumu adrese çevir
      final adres = await KonumServisi.konumuAdreseCevir(position);
      
      if (adres != null) {
        // Konumu kaydet
        await KonumServisi.konumBilgisiniKaydet(adres['il']!, adres['ilce']!);
        
        setState(() {
          _konum = adres['il']!;
          _ilce = adres['ilce']!;
        });

        // Namaz vakitlerini getir
        await _namazVakitleriniYukle(_konum);
      } else {
        setState(() {
          _konumHatasi = true;
          _konum = 'Adres bulunamadı';
          _ilce = 'Tekrar deneyin';
        });
        _vakitler = _getOrnekVakitler();
        _aktifVakitleriGuncelle();
      }
    } catch (e) {
      setState(() {
        _konumHatasi = true;
        _konum = 'Hata oluştu';
        _ilce = 'Tekrar deneyin';
      });
      _vakitler = _getOrnekVakitler();
      _aktifVakitleriGuncelle();
    } finally {
      setState(() {
        _konumYuklendi = true;
        _ilkYukleme = false;
      });
    }
  }

  void _aktifVakitleriGuncelle() {
    if (_vakitler.isEmpty) return;

    final simdi = DateTime.now();
    final String simdikiSaat = '${simdi.hour.toString().padLeft(2, '0')}:${simdi.minute.toString().padLeft(2, '0')}';

    // Tüm vakitleri sıfırla
    List<EzanVakti> guncellenmisVakitler = _vakitler.map((vakit) {
      return EzanVakti(
        isim: vakit.isim,
        vakit: vakit.vakit,
        aktif: false,
        gecmis: _vakitGecmisMi(vakit.vakit, simdikiSaat),
        kalanSure: _kalanSureyiHesapla(vakit.vakit),
      );
    }).toList();

    // Aktif vakit bul
    EzanVakti? aktifVakit;
    for (int i = 0; i < guncellenmisVakitler.length; i++) {
      final vakit = guncellenmisVakitler[i];
      if (!vakit.gecmis && (i == 0 || guncellenmisVakitler[i - 1].gecmis)) {
        aktifVakit = vakit;
        guncellenmisVakitler[i] = EzanVakti(
          isim: vakit.isim,
          vakit: vakit.vakit,
          aktif: true,
          gecmis: false,
          kalanSure: vakit.kalanSure,
        );
        break;
      }
    }

    // Eğer hiç aktif vakit bulunamazsa (tüm vakitler geçmişse), son vakit aktif gösterilsin
    if (aktifVakit == null && guncellenmisVakitler.isNotEmpty) {
      aktifVakit = guncellenmisVakitler.last;
      guncellenmisVakitler[guncellenmisVakitler.length - 1] = EzanVakti(
        isim: aktifVakit.isim,
        vakit: aktifVakit.vakit,
        aktif: true,
        gecmis: true,
        kalanSure: '00:00',
      );
    }

    setState(() {
      _vakitler = guncellenmisVakitler;
      if (aktifVakit != null) {
        _aktifVakit = aktifVakit.isim;
        _aktifVakitSaat = aktifVakit.vakit;
      } else {
        _aktifVakit = 'Yatsı';
        _aktifVakitSaat = '--:--';
      }
    });
  }

  bool _vakitGecmisMi(String vakitSaati, String simdikiSaat) {
    final vakitDakika = _saatiDakikayaCevir(vakitSaati);
    final simdikiDakika = _saatiDakikayaCevir(simdikiSaat);
    return vakitDakika < simdikiDakika;
  }

  int _saatiDakikayaCevir(String saat) {
    final parcalar = saat.split(':');
    if (parcalar.length != 2) return 0;
    final saatInt = int.tryParse(parcalar[0]) ?? 0;
    final dakikaInt = int.tryParse(parcalar[1]) ?? 0;
    return saatInt * 60 + dakikaInt;
  }

  String _kalanSureyiHesapla(String hedefSaat) {
    final simdi = DateTime.now();
    final hedef = _saatiDateTimeCevir(hedefSaat, simdi);
    
    if (hedef.isBefore(simdi)) {
      return '00:00';
    }
    
    final fark = hedef.difference(simdi);
    final saat = fark.inHours;
    final dakika = fark.inMinutes.remainder(60);
    
    return '${saat.toString().padLeft(2, '0')}:${dakika.toString().padLeft(2, '0')}';
  }

  DateTime _saatiDateTimeCevir(String saat, DateTime bugun) {
    final parcalar = saat.split(':');
    if (parcalar.length != 2) return bugun;
    
    final saatInt = int.tryParse(parcalar[0]) ?? 0;
    final dakikaInt = int.tryParse(parcalar[1]) ?? 0;
    
    return DateTime(bugun.year, bugun.month, bugun.day, saatInt, dakikaInt);
  }

  Future<void> _namazVakitleriniYukle(String sehir) async {
    try {
      final vakitData = await NamazVakitleriServisi.namazVakitleriniGetir(sehir);
      
      List<EzanVakti> vakitler = [];
      
      if (vakitData != null && vakitData['data'] != null) {
        final timings = vakitData['data']['timings'];
        
        vakitler = [
          EzanVakti(isim: 'İmsak', vakit: timings['Fajr'], aktif: false, gecmis: false, kalanSure: '00:00'),
          EzanVakti(isim: 'Güneş', vakit: timings['Sunrise'], aktif: false, gecmis: false, kalanSure: '00:00'),
          EzanVakti(isim: 'Öğle', vakit: timings['Dhuhr'], aktif: false, gecmis: false, kalanSure: '00:00'),
          EzanVakti(isim: 'İkindi', vakit: timings['Asr'], aktif: false, gecmis: false, kalanSure: '00:00'),
          EzanVakti(isim: 'Akşam', vakit: timings['Maghrib'], aktif: false, gecmis: false, kalanSure: '00:00'),
          EzanVakti(isim: 'Yatsı', vakit: timings['Isha'], aktif: false, gecmis: false, kalanSure: '00:00'),
        ];

        // Aktif vakitleri hemen güncelle
        _aktifVakitleriGuncelle();

        // Vakitleri kaydet
        final vakitlerMap = vakitler.map((vakit) => vakit.toMap()).toList();
        await KonumServisi.vakitleriKaydet(vakitlerMap);

        // Parent widget'a bildir
        if (widget.onKonumUpdate != null) {
          widget.onKonumUpdate!(_konum, _ilce, vakitler);
        }
      } else {
        // API çalışmazsa örnek veri kullan
        vakitler = _getOrnekVakitler();
        _aktifVakitleriGuncelle();
      }
      
      setState(() {
        _vakitler = vakitler;
      });
    } catch (e) {
      print('Vakitler yüklenemedi: $e');
      setState(() {
        _vakitler = _getOrnekVakitler();
      });
      _aktifVakitleriGuncelle();
    }
  }

  List<EzanVakti> _getOrnekVakitler() {
    return [
      EzanVakti(isim: 'İmsak', vakit: '06:15', aktif: false, gecmis: false, kalanSure: '00:00'),
      EzanVakti(isim: 'Güneş', vakit: '07:45', aktif: false, gecmis: false, kalanSure: '00:00'),
      EzanVakti(isim: 'Öğle', vakit: '13:10', aktif: false, gecmis: false, kalanSure: '00:00'),
      EzanVakti(isim: 'İkindi', vakit: '16:20', aktif: false, gecmis: false, kalanSure: '00:00'),
      EzanVakti(isim: 'Akşam', vakit: '19:05', aktif: false, gecmis: false, kalanSure: '00:00'),
      EzanVakti(isim: 'Yatsı', vakit: '20:35', aktif: false, gecmis: false, kalanSure: '00:00'),
    ];
  }

  Map<String, String> _getGununHadisi() {
    return _hadisListesi[0];
  }

  Widget _buildKonumKarti() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_pin, color: Color(0xFF00D4AA), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BULUNDUĞUNUZ KONUM',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _konum,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _ilce,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                if (_kayitliVeriKullanildi)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Kayıtlı veri kullanılıyor',
                      style: TextStyle(
                        color: Colors.green.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!_konumYuklendi)
            const CircularProgressIndicator(color: Color(0xFF00D4AA), strokeWidth: 2)
          else if (_konumHatasi)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.orange),
              onPressed: _konumVeVakitleriYukle,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 6),
                  const SizedBox(width: 4),
                  Text(
                    'AKTİF',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ÜST BAR
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGununAdi(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTarih(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          final now = DateTime.now();
                          return Text(
                            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Color(0xFF00D4AA),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Courier',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // AYARLAR BUTONU
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D4AA), Color(0xFF009688)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.person, color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AyarlarSayfasi()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // KONUM KARTI
          _buildKonumKarti(),

          const SizedBox(height: 20),

          // AKTİF VAKİT
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.brightness_high, color: Color(0xFFFF9800), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ŞU ANKİ VAKİT',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _aktifVakit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AKTİF',
                        style: TextStyle(
                          color: Color(0xFFFF9800),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _aktifVakitSaat,
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // VAKİTLER BAŞLIK
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF00D4AA), size: 18),
                const SizedBox(width: 8),
                const Text(
                  'NAMAZ VAKİTLERİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Kalan Süre',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // VAKİT KUTUCUKLARI
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _vakitler.length,
                itemBuilder: (context, index) {
                  final vakit = _vakitler[index];
                  return _buildVakitKarti(vakit);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // HADİS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Color(0xFF00D4AA), size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'GÜNÜN HADİS-İ ŞERİFİ',
                      style: TextStyle(
                        color: Color(0xFF00D4AA),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getGununHadisi()['hadis']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getGununHadisi()['kaynak']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVakitKarti(EzanVakti vakit) {
    final color = _getVakitRenk(vakit.isim);
    final isAktif = vakit.aktif;
    final isGecmis = vakit.gecmis;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            vakit.isim,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vakit.vakit,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isAktif ? color.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isAktif ? 'AKTİF' : isGecmis ? 'GEÇTİ' : vakit.kalanSure,
              style: TextStyle(
                color: isAktif ? Colors.white : color,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getVakitRenk(String vakitIsmi) {
    switch (vakitIsmi) {
      case 'İmsak': return const Color(0xFF4A6572);
      case 'Güneş': return const Color(0xFFFFB74D);
      case 'Öğle': return const Color(0xFFFF9800);
      case 'İkindi': return const Color(0xFFF57C00);
      case 'Akşam': return const Color(0xFFE65100);
      case 'Yatsı': return const Color(0xFF283593);
      default: return const Color(0xFF00D4AA);
    }
  }

  String _getGununAdi() {
    final now = DateTime.now();
    final List<String> gunler = ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];
    return gunler[now.weekday];
  }

  String _getTarih() {
    final now = DateTime.now();
    return '${now.day} ${_getAyAdi(now.month)} ${now.year}';
  }

  String _getAyAdi(int ay) {
    final List<String> aylar = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return aylar[ay];
  }
}