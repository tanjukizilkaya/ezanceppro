import 'package:flutter/material.dart';

class DualarSayfasi extends StatefulWidget {
  const DualarSayfasi({super.key});

  @override
  State<DualarSayfasi> createState() => _DualarSayfasiState();
}

class _DualarSayfasiState extends State<DualarSayfasi> {
  final List<DuaKategori> _kategoriler = [
    DuaKategori(
      id: 'sabah_aksam',
      isim: 'Sabah-Akşam Duaları',
      icon: Icons.wb_sunny,
      renk: Colors.orange,
    ),
    DuaKategori(
      id: 'namaz',
      isim: 'Namaz Duaları',
      icon: Icons.mosque,
      renk: Colors.green,
    ),
    DuaKategori(
      id: 'gunluk',
      isim: 'Günlük Dualar',
      icon: Icons.access_time,
      renk: Colors.blue,
    ),
    DuaKategori(
      id: 'saglik',
      isim: 'Sağlık & Afiyet',
      icon: Icons.favorite,
      renk: Colors.red,
    ),
    DuaKategori(
      id: 'rizik',
      isim: 'Rızık Duaları',
      icon: Icons.attach_money,
      renk: Colors.green,
    ),
    DuaKategori(
      id: 'korunma',
      isim: 'Korunma Duaları',
      icon: Icons.security,
      renk: Colors.purple,
    ),
  ];

  String _seciliKategori = 'sabah_aksam';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SafeArea(
        child: Column(
          children: [
            // BAŞLIK
            _buildBaslik(),
            
            // KATEGORİLER
            _buildKategoriler(),
            
            // DUALAR LİSTESİ
            Expanded(
              child: _buildDualarListesi(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaslik() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4AA).withOpacity(0.3),
            const Color(0xFF0A0E17).withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dualar ve Sureler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Günlük hayatınız için seçkin dualar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
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
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriler() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _kategoriler.length,
        itemBuilder: (context, index) {
          final kategori = _kategoriler[index];
          final isSecili = _seciliKategori == kategori.id;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _seciliKategori = kategori.id;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSecili
                    ? LinearGradient(
                        colors: [
                          kategori.renk.withOpacity(0.8),
                          kategori.renk.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF1A1F2C),
                          const Color(0xFF0A0E17),
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSecili ? kategori.renk : Colors.white.withOpacity(0.1),
                  width: isSecili ? 2 : 1,
                ),
                boxShadow: isSecili
                    ? [
                        BoxShadow(
                          color: kategori.renk.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    kategori.icon,
                    color: isSecili ? Colors.white : kategori.renk,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kategori.isim,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSecili ? Colors.white : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDualarListesi() {
    final dualar = _getKategoriDualari(_seciliKategori);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dualar.length,
      itemBuilder: (context, index) {
        final dua = dualar[index];
        return _buildDuaKarti(dua, index);
      },
    );
  }

  Widget _buildDuaKarti(Dua dua, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getKategoriRenk(_seciliKategori).withOpacity(0.1),
            const Color(0xFF1A1F2C).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getKategoriRenk(_seciliKategori).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getKategoriRenk(_seciliKategori).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: _getKategoriRenk(_seciliKategori),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          dua.isim,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          dua.aciklama,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_drop_down,
          color: _getKategoriRenk(_seciliKategori),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arapça Okunuş
                Text(
                  'Arapça:',
                  style: TextStyle(
                    color: _getKategoriRenk(_seciliKategori),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.arapca,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                
                // Okunuş
                Text(
                  'Okunuş:',
                  style: TextStyle(
                    color: _getKategoriRenk(_seciliKategori),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.okunus,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Anlamı
                Text(
                  'Anlamı:',
                  style: TextStyle(
                    color: _getKategoriRenk(_seciliKategori),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.anlami,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Fayda
                if (dua.fayda.isNotEmpty) ...[
                  Text(
                    'Faydası:',
                    style: TextStyle(
                      color: _getKategoriRenk(_seciliKategori),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dua.fayda,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Tekrar Sayısı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getKategoriRenk(_seciliKategori).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getKategoriRenk(_seciliKategori).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tekrar Sayısı:',
                        style: TextStyle(
                          color: _getKategoriRenk(_seciliKategori),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        dua.tekrarSayisi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getKategoriRenk(String kategoriId) {
    final kategori = _kategoriler.firstWhere((k) => k.id == kategoriId);
    return kategori.renk;
  }

  List<Dua> _getKategoriDualari(String kategoriId) {
    switch (kategoriId) {
      case 'sabah_aksam':
        return _sabahAksamDualari();
      case 'namaz':
        return _namazDualari();
      case 'gunluk':
        return _gunlukDualar();
      case 'saglik':
        return _saglikDualari();
      case 'rizik':
        return _rizikDualari();
      case 'korunma':
        return _korunmaDualari();
      default:
        return _sabahAksamDualari();
    }
  }

  // DUALAR VERİ TABANI
  List<Dua> _sabahAksamDualari() {
    return [
      Dua(
        isim: 'Sabah Duası',
        arapca: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
        okunus: 'Eşbehnâ ve eşbehel-mülkü lillâhi velhamdü lillâhi, lâ ilâhe illallâhu vahdehû lâ şerîke leh.',
        anlami: 'Sabaha erdik ve mülk Allah\'ındır. Hamd Allah\'adır. Allah\'tan başka ilah yoktur, O birdir ve ortağı yoktur.',
        fayda: 'Sabah okunursa gün boyu Allah\'ın koruması altında olunur.',
        tekrarSayisi: '1',
        aciklama: 'Sabah namazından sonra okunur',
      ),
      Dua(
        isim: 'Ayetel Kürsi',
        arapca: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        okunus: 'Allâhü lâ ilâhe illâ hüvel hayyül kayyûm...',
        anlami: 'Allah kendisinden başka hiçbir ilah olmayandır. O, hayydir, kayyûmdur...',
        fayda: 'Evleri, iş yerlerini ve kişiyi kötülüklerden korur.',
        tekrarSayisi: '1',
        aciklama: 'Her sabah ve akşam okunmalı',
      ),
      Dua(
        isim: 'Felak-Nas Sureleri',
        arapca: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
        okunus: 'Kul eûzü birabbil felak... Kul eûzü birabbin nâs...',
        anlami: 'De ki: Ben, ağaran sabahın Rabbine sığınırım... De ki: Ben insanların Rabbine sığınırım...',
        fayda: 'Nazar ve kötülüklerden korunmak için',
        tekrarSayisi: '3',
        aciklama: 'Sabah-akşam korunma duaları',
      ),
      Dua(
        isim: 'Hasbünallah Duası',
        arapca: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        okunus: 'Hasbünallâhü ve ni\'me\'l-vekîl',
        anlami: 'Allah bize yeter. O ne güzel vekildir.',
        fayda: 'Sıkıntı ve stres anlarında okunur',
        tekrarSayisi: '7',
        aciklama: 'Zor zamanlarda teselli verir',
      ),
    ];
  }

  List<Dua> _namazDualari() {
    return [
      Dua(
        isim: 'Sübhaneke Duası',
        arapca: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ...',
        okunus: 'Sübhânekellâhümme ve bi hamdik...',
        anlami: 'Allah\'ım! Seni tenzih ve hamdinle tesbih ederim...',
        fayda: 'Namaza başlama duası',
        tekrarSayisi: '1',
        aciklama: 'Her namazın başında',
      ),
      Dua(
        isim: 'Ettehiyyatü',
        arapca: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ...',
        okunus: 'Ettehiyyâtü lillâhi vessalevâtü vettayyibât...',
        anlami: 'Dil ile, beden ile ve mal ile yapılan bütün ibadetler Allah\'a dır...',
        fayda: 'Namazın oturuşlarında okunur',
        tekrarSayisi: '1',
        aciklama: 'Namazın temel dualarından',
      ),
      Dua(
        isim: 'Allahümme Salli ve Barik',
        arapca: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ...',
        okunus: 'Allâhümme salli alâ Muhammedin ve alâ âli Muhammed...',
        anlami: 'Allah\'ım! Muhammed\'e ve Muhammed\'in ümmetine rahmet eyle...',
        fayda: 'Peygambere salavat getirmek',
        tekrarSayisi: '1',
        aciklama: 'Namazda okunan salavatlar',
      ),
      Dua(
        isim: 'Kunut Duaları',
        arapca: 'اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ...',
        okunus: 'Allâhümme innâ nesteînüke ve nestagfirüke...',
        anlami: 'Allah\'ım! Senden yardım isteriz, günahlarımızı bağışlamanı isteriz...',
        fayda: 'Vitir namazında okunur',
        tekrarSayisi: '1',
        aciklama: 'Vitir namazı duası',
      ),
    ];
  }

  List<Dua> _gunlukDualar() {
    return [
      Dua(
        isim: 'Yemek Duası',
        arapca: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
        okunus: 'Elhamdülillâhillezî et\'amenâ ve sekânâ ve cealenâ minel müslimîn',
        anlami: 'Bizi yediren, içiren ve Müslümanlardan kılan Allah\'a hamd olsun.',
        fayda: 'Yemekten sonra şükür',
        tekrarSayisi: '1',
        aciklama: 'Yemekten sonra okunur',
      ),
      Dua(
        isim: 'Evden Çıkarken',
        arapca: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        okunus: 'Bismillâhi tevekkeltü alellâhi ve lâ havle ve lâ kuvvete illâ billâh',
        anlami: 'Allah\'ın adıyla, Allah\'a dayandım. Güç ve kuvvet sadece Allah\'tandır.',
        fayda: 'Evden çıkarken korunma',
        tekrarSayisi: '1',
        aciklama: 'Her çıkışta okunmalı',
      ),
      Dua(
        isim: 'Eve Girerken',
        arapca: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ',
        okunus: 'Allâhümme innî es\'elüke hayrel mevlici ve hayrel mahreci',
        anlami: 'Allah\'ım! Girişin hayırlısını ve çıkışın hayırlısını senden dilerim.',
        fayda: 'Eve girerken bereket',
        tekrarSayisi: '1',
        aciklama: 'Eve her girişte',
      ),
    ];
  }

  List<Dua> _saglikDualari() {
    return [
      Dua(
        isim: 'Hasta Duası',
        arapca: 'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
        okunus: 'Es\'elüllâhel azîm. Rabbel arşil azîm en yeşfîke',
        anlami: 'Ulu Arş\'ın Rabbi Yüce Allah\'tan sana şifa vermesini dilerim.',
        fayda: 'Hastalara şifa için',
        tekrarSayisi: '7',
        aciklama: 'Hasta ziyaretlerinde',
      ),
      Dua(
        isim: 'Şifa Ayetleri',
        arapca: 'وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ',
        okunus: 'Ve izâ maridtu fe hüve yeşfîn',
        anlami: 'Hastalandığım zaman bana şifa veren O\'dur.',
        fayda: 'Her türlü hastalık için',
        tekrarSayisi: '7',
        aciklama: 'Genel şifa duası',
      ),
    ];
  }

  List<Dua> _rizikDualari() {
    return [
      Dua(
        isim: 'Rızık Duası',
        arapca: 'اللَّهُمَّ ارْزُقْنَا رِزْقًا حَلَالًا طَيِّبًا وَاسِعًا',
        okunus: 'Allâhümmerzuknâ rızkan halâlen tayyiben vâsian',
        anlami: 'Allah\'ım! Bize helal, temiz ve bol rızık ver.',
        fayda: 'Rızık bereketi için',
        tekrarSayisi: '3',
        aciklama: 'Sabah namazından sonra',
      ),
    ];
  }

  List<Dua> _korunmaDualari() {
    return [
      Dua(
        isim: 'Bela ve Musibetlerden Korunma',
        arapca: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        okunus: 'Hasbiyallâhü lâ ilâhe illâ hûve aleyhi tevekkeltü ve hüve rabbül arşil azîm',
        anlami: 'Allah bana yeter. O\'ndan başka ilah yoktur. Ben sadece O\'na güvenip dayanırım.',
        fayda: 'Her türlü beladan korunma',
        tekrarSayisi: '7',
        aciklama: 'Zor zamanlarda',
      ),
    ];
  }
}

// MODELLER
class DuaKategori {
  final String id;
  final String isim;
  final IconData icon;
  final Color renk;

  DuaKategori({
    required this.id,
    required this.isim,
    required this.icon,
    required this.renk,
  });
}

class Dua {
  final String isim;
  final String arapca;
  final String okunus;
  final String anlami;
  final String fayda;
  final String tekrarSayisi;
  final String aciklama;

  Dua({
    required this.isim,
    required this.arapca,
    required this.okunus,
    required this.anlami,
    required this.fayda,
    required this.tekrarSayisi,
    required this.aciklama,
  });
}