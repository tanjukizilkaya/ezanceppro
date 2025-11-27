import 'package:equatable/equatable.dart';
import 'package:ezancep_pro/features/ezan_vakitleri/domain/entities/ezan_vakti.dart';

// part-of kullanma, normal class yap
abstract class EzanVakitleriState extends Equatable {
  const EzanVakitleriState();

  @override
  List<Object> get props => [];
}

class EzanVakitleriInitial extends EzanVakitleriState {}

class EzanVakitleriYukleniyor extends EzanVakitleriState {}

class EzanVakitleriYuklendi extends EzanVakitleriState {
  final List<EzanVakti> vakitler;

  const EzanVakitleriYuklendi(this.vakitler);

  @override
  List<Object> get props => [vakitler];
}

class EzanVakitleriHata extends EzanVakitleriState {
  final String message;

  const EzanVakitleriHata(this.message);

  @override
  List<Object> get props => [message];
}