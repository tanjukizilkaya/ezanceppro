import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class KibleSayfasi extends StatefulWidget {
  const KibleSayfasi({super.key});

  @override
  State<KibleSayfasi> createState() => _KibleSayfasiState();
}

class _KibleSayfasiState extends State<KibleSayfasi> {
  // Değişkenler
  double? _heading = 0.0;
  double _kibleAcisi = 0.0; // Mekke'nin Kuzey'e göre açısı
  String _durumMesaji = "Konum ve Pusula Bekleniyor...";
  bool _izinVerildi = false;
  bool _kibleHizalandi = false;
  bool _konumAliniyor = true;

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  Future<void> _baslat() async {
    // 1. İzinleri İste
    await _izinleriIste();
    
    // 2. Konumu Al ve Kıble Açısını Hesapla
    if (_izinVerildi) {
      await _konumVeKibleHesapla();
      
      // 3. Pusulayı Dinlemeye Başla (Stream)
      FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted) {
          setState(() {
            // event.heading: Telefonun Kuzey'e göre açısı
            _heading = event.heading;
            
            // Hizalama Kontrolü
            if (_heading != null) {
              _hizalamaKontrol(_heading!);
            }
          });
        }
      });
    }
  }

  Future<void> _izinleriIste() async {
    // Konum izni iste
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() {
        _izinVerildi = true;
      });
    } else {
      setState(() {
        _durumMesaji = "Konum izni reddedildi. Ayarlardan izin verin.";
        _konumAliniyor = false;
      });
      // İzin reddedilirse kullanıcıyı ayarlara yönlendirebilirsin
      // openAppSettings();
    }
  }

  Future<void> _konumVeKibleHesapla() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Kıble Açısı Hesaplama
      double kible = _calculateQibla(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _kibleAcisi = kible;
          _durumMesaji = "Telefonu masaya koyun ve çevirin";
          _konumAliniyor = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _durumMesaji = "Konum alınamadı. Lütfen GPS'i açın.";
          _konumAliniyor = false;
        });
      }
    }
  }

  // Kıble Matematik Formülü (Geodesic)
  double _calculateQibla(double lat, double lon) {
    double kabeLat = 21.4225;
    double kabeLon = 39.8262;

    double latRad = lat * (pi / 180.0);
    double lonRad = lon * (pi / 180.0);
    double kabeLatRad = kabeLat * (pi / 180.0);
    double kabeLonRad = kabeLon * (pi / 180.0);

    double y = sin(kabeLonRad - lonRad);
    double x = cos(latRad) * tan(kabeLatRad) - sin(latRad) * cos(kabeLonRad - lonRad);

    double qibla = atan2(y, x) * (180.0 / pi);
    return (qibla + 360.0) % 360.0;
  }

  void _hizalamaKontrol(double currentHeading) {
    // Telefonun baktığı yön ile Kıble açısı arasındaki fark
    double fark = (currentHeading - _kibleAcisi).abs();
    if (fark > 180) fark = 360 - fark;

    // 3 derece tolerans (Yeşil yanması için)
    bool aligned = fark < 3.5;

    if (aligned != _kibleHizalandi) {
      setState(() {
        _kibleHizalandi = aligned;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kıble Pusulası"),
        backgroundColor: _kibleHizalandi ? const Color(0xFF2E7D32) : Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _konumAliniyor 
          ? const Center(child: CircularProgressIndicator())
          : _buildCompassUI(),
    );
  }

  Widget _buildCompassUI() {
    // Pusula verisi yoksa veya izin yoksa uyarı göster
    if (_heading == null && !_konumAliniyor) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _durumMesaji,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. SABİT REHBER OKU (Telefonun Üstünü Gösterir)
          Icon(
            Icons.arrow_drop_up,
            size: 80,
            color: _kibleHizalandi ? const Color(0xFF2E7D32) : Colors.red,
          ),
          Container(
            height: 5,
            width: 40,
            color: _kibleHizalandi ? const Color(0xFF2E7D32) : Colors.red,
          ),
          const SizedBox(height: 30),

          // 2. DÖNEN PUSULA ALANI
          Stack(
            alignment: Alignment.center,
            children: [
              // Dış Çerçeve
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: _kibleHizalandi ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                    width: 5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 5,
                    )
                  ],
                ),
              ),

              // Dönen İçerik (Kuzey, Güney, Kabe İkonu)
              // Transform.rotate ile tüm tepsiyi telefonun tersine döndürüyoruz
              Transform.rotate(
                angle: -((_heading ?? 0) * (pi / 180)),
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    children: [
                      // Yön Harfleri
                      _buildDirectionText('N', Alignment.topCenter, Colors.red),
                      _buildDirectionText('S', Alignment.bottomCenter, Colors.black),
                      _buildDirectionText('E', Alignment.centerRight, Colors.black),
                      _buildDirectionText('W', Alignment.centerLeft, Colors.black),

                      // KABE SİMGESİ
                      // Pusula tepsisinin içine, hesaplanan açıyla yerleştiriyoruz
                      Transform.rotate(
                        angle: _kibleAcisi * (pi / 180),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 25), // Merkeze yapışmaması için boşluk
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Cami ikonu (Kabe)
                                Icon(
                                  Icons.mosque, 
                                  size: 45, 
                                  color: _kibleHizalandi ? const Color(0xFF2E7D32) : Colors.black87
                                ),
                                Icon(
                                  Icons.arrow_upward, 
                                  size: 20, 
                                  color: _kibleHizalandi ? const Color(0xFF2E7D32) : Colors.black87
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Merkez Nokta
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Bilgilendirme Metinleri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _kibleHizalandi 
                  ? "KIBLE BULUNDU!" 
                  : "Cami simgesi üstteki ok ile birleşene kadar telefonu çevirin.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _kibleHizalandi ? const Color(0xFF2E7D32) : Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Kıble Açısı: ${_kibleAcisi.toStringAsFixed(1)}° | Yönünüz: ${(_heading ?? 0).toStringAsFixed(1)}°",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionText(String text, Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: color
          ),
        ),
      ),
    );
  }
}