import 'package:bloc/bloc.dart';
import 'package:ezancep_pro/features/konum/domain/entities/konum.dart';
import 'package:ezancep_pro/features/konum/domain/usecases/konum_al.dart';
import 'package:meta/meta.dart';

part 'konum_state.dart';

class KonumCubit extends Cubit<KonumState> {
  final KonumAl konumAl;

  KonumCubit({required this.konumAl}) : super(KonumInitial());

  Future<void> konumAl() async {
    emit(KonumLoading());
    
    final result = await konumAl();
    
    result.fold(
      (failure) => emit(KonumError(failure)),
      (konum) => emit(KonumLoaded(konum)),
    );
  }

  void konumGuncelle(Konum konum) {
    emit(KonumLoaded(konum));
  }
}