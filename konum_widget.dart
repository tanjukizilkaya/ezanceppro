import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezancep_pro/features/konum/presentation/bloc/konum_bloc.dart';
import 'package:ezancep_pro/features/konum/domain/entities/konum.dart';

class KonumWidget extends StatelessWidget {
  const KonumWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KonumBloc, KonumState>(
      listener: (context, state) {
        if (state is KonumHata) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              // Konum İkonu
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF3498DB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Konum Bilgisi
              Expanded(
                child: _buildContent(state, context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(KonumState state, BuildContext context) {
    if (state is KonumInitial) {
      return _buildKonumAlButton(context, 'Konumu Al');
    } else if (state is KonumYukleniyor) {
      return _buildYukleniyor();
    } else if (state is KonumYuklendi) {
      return _buildKonumBilgisi(state.konum, context);
    } else if (state is KonumHata) {
      return _buildHata(state.message, context);
    } else {
      return _buildKonumAlButton(context, 'Konumu Al');
    }
  }

  Widget _buildYukleniyor() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Konum alınıyor...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildHata(String hataMesaji, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withOpacity(0.8),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Konum Alınamadı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          hataMesaji,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        _buildKonumAlButton(context, 'Tekrar Dene'),
      ],
    );
  }

  Widget _buildKonumBilgisi(Konum konum, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İlçe ve İl bilgisi
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (konum.ilce != 'Bilinmeyen' && konum.ilce != konum.il)
                    Text(
                      konum.ilce,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Text(
                    konum.il,
                    style: TextStyle(
                      color: konum.ilce != 'Bilinmeyen' && konum.ilce != konum.il 
                          ? Colors.white70 
                          : Colors.white,
                      fontSize: konum.ilce != 'Bilinmeyen' && konum.ilce != konum.il 
                          ? 14 
                          : 18,
                      fontWeight: konum.ilce != 'Bilinmeyen' && konum.ilce != konum.il 
                          ? FontWeight.w500 
                          : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Yenileme butonu
            GestureDetector(
              onTap: () {
                context.read<KonumBloc>().add(KonumYukle());
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Detaylı adres bilgisi
        if (konum.mahalle != 'Bilinmeyen')
          Text(
            konum.mahalle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        
        const SizedBox(height: 2),
        
        // Ülke ve koordinat bilgisi
        Row(
          children: [
            Text(
              konum.ulke,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTarih(konum.guncellemeZamani!),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 2),
        
        // Koordinatlar
        Text(
          '${konum.enlem.toStringAsFixed(4)}, ${konum.boylam.toStringAsFixed(4)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildKonumAlButton(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        context.read<KonumBloc>().add(KonumYukle());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF3498DB).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3498DB).withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_searching_rounded,
              color: const Color(0xFF3498DB),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: const Color(0xFF3498DB),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTarih(DateTime tarih) {
    return '${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}';
  }
}