part of 'konum_cubit.dart';

@immutable
abstract class KonumState {
  const KonumState();
}

class KonumInitial extends KonumState {}

class KonumLoading extends KonumState {}

class KonumLoaded extends KonumState {
  final Konum konum;

  const KonumLoaded(this.konum);
}

class KonumError extends KonumState {
  final String message;

  const KonumError(this.message);
}