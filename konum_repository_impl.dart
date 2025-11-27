import 'package:dartz/dartz.dart';
import 'package:ezancep_pro/core/error/failures.dart';
import 'package:ezancep_pro/features/konum/domain/entities/konum.dart';

abstract class KonumRepository {
  Future<Either<Failure, Konum>> konumuAl();
}

class KonumRepositoryImpl implements KonumRepository {
  @override
  Future<Either<Failure, Konum>> konumuAl() async {
    try {
      // Basit örnek konum
      final konum = Konum(
        enlem: 41.0082,
        boylam: 28.9784,
        sehir: 'İstanbul',
        ulke: 'Türkiye',
        guncellemeZamani: DateTime.now(),
      );
      return Right(konum);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}