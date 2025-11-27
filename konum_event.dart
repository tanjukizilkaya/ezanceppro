import 'package:equatable/equatable.dart';

part of 'konum_bloc.dart';

abstract class KonumEvent extends Equatable {
  const KonumEvent();

  @override
  List<Object> get props => [];
}

class KonumYukle extends KonumEvent {}