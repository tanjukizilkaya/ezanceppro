import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ezancep_pro/features/ezan_vakitleri/domain/entities/ezan_vakti.dart';
import 'package:ezancep_pro/features/ezan_vakitleri/domain/repositories/ezan_vakitleri_repository.dart';

// Event ve State dosyalarını import et, part-of kullanma
import 'ezan_vakitleri_event.dart';
import 'ezan_vakitleri_state.dart';

class EzanVakitleriBloc extends Bloc<EzanVakitleriEvent, EzanVakitleriState> {
  final EzanVakitleriRepository repository;

  EzanVakitleriBloc({required this.repository}) : super(EzanVakitleriInitial()) {
    on<EzanVakitleriYukle>(_onEzanVakitleriYukle);
  }

  FutureOr<void> _onEzanVakitleriYukle(
    EzanVakitleriYukle event,
    Emitter<EzanVakitleriState> emit,
  ) async {
    emit(EzanVakitleriYukleniyor());
    
    final result = await repository.getEzanVakitleri(
      event.enlem,
      event.boylam,
    );

    result.fold(
      (error) => emit(EzanVakitleriHata(error)),
      (vakitler) => emit(EzanVakitleriYuklendi(vakitler)),
    );
  }
}