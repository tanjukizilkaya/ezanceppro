import 'package:equatable/equatable.dart';

// part-of kullanma, normal class yap
abstract class EzanVakitleriEvent extends Equatable {
  const EzanVakitleriEvent();

  @override
  List<Object> get props => [];
}

class EzanVakitleriYukle extends EzanVakitleriEvent {
  final double enlem;
  final double boylam;

  const EzanVakitleriYukle({required this.enlem, required this.boylam});

  @override
  List<Object> get props => [enlem, boylam];
}