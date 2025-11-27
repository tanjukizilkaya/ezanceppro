import 'package:dartz/dartz.dart';
import 'package:ezancep_pro/core/error/failures.dart';
import 'package:ezancep_pro/features/konum/domain/entities/konum.dart';
import 'package:ezancep_pro/features/konum/domain/repositories/konum_repository.dart';

class KonumUseCases {
  final KonumRepository repository;

  KonumUseCases({required this.repository});

  Future<Either<Failure, Konum>> konumuAl() async {
    return await repository.konumuAl();
  }
}