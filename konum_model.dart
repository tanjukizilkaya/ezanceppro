class KonumModel extends Konum {
  KonumModel({
    required double enlem,
    required double boylam,
    String? sehir,
    String? ulke,
  }) : super(
          enlem: enlem,
          boylam: boylam,
          sehir: sehir,
          ulke: ulke,
        );

  factory KonumModel.fromJson(Map<String, dynamic> json) {
    return KonumModel(
      enlem: json['enlem']?.toDouble() ?? 0.0,
      boylam: json['boylam']?.toDouble() ?? 0.0,
      sehir: json['sehir'],
      ulke: json['ulke'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enlem': enlem,
      'boylam': boylam,
      'sehir': sehir,
      'ulke': ulke,
    };
  }
}