import 'package:dartz/dartz.dart';
import 'package:ezancep_pro/features/konum/domain/entities/konum.dart';
import 'package:ezancep_pro/features/konum/domain/repositories/konum_repository.dart';

class KonumAl {
  final KonumRepository repository;

  KonumAl(this.repository);

  Future<Either<String, Konum>> call() async {
    return await repository.getKonum();
  }
}