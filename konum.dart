class Konum {
  final double enlem;
  final double boylam;
  final String ulke;
  final String il;
  final String ilce;
  final String mahalle;
  final DateTime? guncellemeZamani;

  Konum({
    required this.enlem,
    required this.boylam,
    required this.ulke,
    required this.il,
    required this.ilce,
    required this.mahalle,
    this.guncellemeZamani,
  });

  Konum copyWith({
    double? enlem,
    double? boylam,
    String? ulke,
    String? il,
    String? ilce,
    String? mahalle,
    DateTime? guncellemeZamani,
  }) {
    return Konum(
      enlem: enlem ?? this.enlem,
      boylam: boylam ?? this.boylam,
      ulke: ulke ?? this.ulke,
      il: il ?? this.il,
      ilce: ilce ?? this.ilce,
      mahalle: mahalle ?? this.mahalle,
      guncellemeZamani: guncellemeZamani ?? this.guncellemeZamani,
    );
  }

  // Tam adresi döndüren yardımcı metod
  String get tamAdres {
    List<String> adresParcalari = [];
    if (mahalle.isNotEmpty && mahalle != 'Bilinmeyen') adresParcalari.add(mahalle);
    if (ilce.isNotEmpty && ilce != 'Bilinmeyen') adresParcalari.add(ilce);
    if (il.isNotEmpty && il != 'Bilinmeyen') adresParcalari.add(il);
    if (ulke.isNotEmpty && ulke != 'Bilinmeyen') adresParcalari.add(ulke);
    
    return adresParcalari.join(', ');
  }

  // Kısa adres (ilçe, il)
  String get kisaAdres {
    if (ilce.isNotEmpty && ilce != 'Bilinmeyen') {
      return '$ilce, $il';
    }
    return il;
  }

  @override
  String toString() {
    return 'Konum(il: $il, ilce: $ilce, mahalle: $mahalle, ulke: $ulke)';
  }
}