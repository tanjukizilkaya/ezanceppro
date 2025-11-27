import 'package:flutter/material.dart';

class ZikirmatikSayfasi extends StatefulWidget {
  const ZikirmatikSayfasi({super.key});

  @override
  State<ZikirmatikSayfasi> createState() => _ZikirmatikSayfasiState();
}

class _ZikirmatikSayfasiState extends State<ZikirmatikSayfasi> {
  final List<Zikir> _zikirler = [
    Zikir(
      isim: 'Sübhanallah',
      arapca: 'سُبْحَانَ اللَّهِ',
      anlam: 'Allah noksanlardan uzaktır',
      hedef: 33,
      renk: Color(0xFF3498DB),
      ikon: Icons.brightness_1,
    ),
    Zikir(
      isim: 'Elhamdülillah',
      arapca: 'الْحَمْدُ لِلَّهِ',
      anlam: 'Hamd Allah\'a mahsustur',
      hedef: 33,
      renk: Color(0xFF2ECC71),
      ikon: Icons.favorite,
    ),
    Zikir(
      isim: 'Allahuekber',
      arapca: 'اللَّهُ أَكْبَرُ',
      anlam: 'Allah en büyüktür',
      hedef: 33,
      renk: Color(0xFFE74C3C),
      ikon: Icons.arrow_upward,
    ),
    Zikir(
      isim: 'Estağfirullah',
      arapca: 'أَسْتَغْفِرُ اللَّهَ',
      anlam: 'Allah\'tan bağışlanma dilerim',
      hedef: 100,
      renk: Color(0xFF9B59B6),
      ikon: Icons.psychology,
    ),
    Zikir(
      isim: 'La ilahe illallah',
      arapca: 'لَا إِلَهَ إِلَّا اللَّهُ',
      anlam: 'Allah\'tan başka ilah yoktur',
      hedef: 100,
      renk: Color(0xFFF39C12),
      ikon: Icons.brightness_high,
    ),
  ];

  int _currentZikirIndex = 0;
  int _counter = 0;
  int _totalZikir = 0;
  bool _showArapca = false;

  @override
  Widget build(BuildContext context) {
    final currentZikir = _zikirler[_currentZikirIndex];

    return Scaffold(
      backgroundColor: Color(0xFF0A0E17),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Zikir Seçimi
                    _buildZikirSecimi(currentZikir),
                    SizedBox(height: 30),
                    // Ana Zikir Göstergesi
                    Expanded(
                      child: _buildZikirGostergesi(currentZikir),
                    ),
                    SizedBox(height: 30),
                    // Kontroller ve İstatistikler
                    _buildKontrollerVeIstatistikler(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9B59B6).withOpacity(0.8),
            Color(0xFF0A0E17).withOpacity(0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: 16),
          Text(
            'Zikirmatik',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZikirSecimi(Zikir zikir) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Zikir Bilgisi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _showArapca ? zikir.arapca : zikir.isim,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: _showArapca ? 'Traditional Arabic' : null,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    zikir.anlam,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              // Dil Değiştir Butonu
              IconButton(
                onPressed: _toggleArapca,
                icon: Icon(
                  _showArapca ? Icons.translate : Icons.language,
                  color: zikir.renk,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Zikir Listesi
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _zikirler.asMap().entries.map((entry) {
                final index = entry.key;
                final zikirItem = entry.value;
                return _buildZikirSecenek(zikirItem, index);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZikirSecenek(Zikir zikir, int index) {
    final isActive = index == _currentZikirIndex;
    return GestureDetector(
      onTap: () => _changeZikir(index),
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    zikir.renk.withOpacity(0.3),
                    zikir.renk.withOpacity(0.1),
                  ],
                )
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? zikir.renk : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              zikir.ikon,
              color: isActive ? zikir.renk : Colors.white70,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              zikir.isim.substring(0, 3),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZikirGostergesi(Zikir zikir) {
    final yuzde = (_counter / zikir.hedef * 100).clamp(0, 100).toDouble();

    return GestureDetector(
      onTap: _incrementCounter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              zikir.renk.withOpacity(0.2),
              zikir.renk.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: zikir.renk.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: zikir.renk.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // İlerleme Çubuğu
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: (yuzde / 100) * 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      zikir.renk.withOpacity(0.4),
                      zikir.renk.withOpacity(0.2),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
            // İçerik
            Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Zikir Sayacı
                  Text(
                    '$_counter',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Hedef Bilgisi
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Hedef: ${zikir.hedef}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // İlerleme Yüzdesi
                  Text(
                    '%${yuzde.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: zikir.renk,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKontrollerVeIstatistikler() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Kontroller
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Sıfırla Butonu
              ElevatedButton(
                onPressed: _counter > 0 ? _resetCounter : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sıfırla',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Otomatik Artır
              ElevatedButton(
                onPressed: _startAutoIncrement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2ECC71),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Otomatik',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // İstatistikler
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIstatistik('Bugün', '$_counter'),
                _buildIstatistik('Toplam', '$_totalZikir'),
                _buildIstatistik('Zikir', '${_zikirler.length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIstatistik(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _totalZikir++;
      
      // Hedefe ulaşıldığında sıfırla
      if (_counter >= _zikirler[_currentZikirIndex].hedef) {
        _counter = 0;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _changeZikir(int index) {
    setState(() {
      _currentZikirIndex = index;
      _counter = 0;
    });
  }

  void _toggleArapca() {
    setState(() {
      _showArapca = !_showArapca;
    });
  }

  void _startAutoIncrement() {
    // Basit otomatik artış - gerçek uygulamada Timer kullanılır
    for (int i = 0; i < 10; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _incrementCounter();
        }
      });
    }
  }
}

class Zikir {
  final String isim;
  final String arapca;
  final String anlam;
  final int hedef;
  final Color renk;
  final IconData ikon;

  Zikir({
    required this.isim,
    required this.arapca,
    required this.anlam,
    required this.hedef,
    required this.renk,
    required this.ikon,
  });
}