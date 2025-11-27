import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezancep_pro/features/ana_sayfa/presentation/pages/ana_sayfa.dart';
import 'package:ezancep_pro/features/tesbih/presentation/pages/tesbih_sayfasi.dart';
import 'package:ezancep_pro/features/dualar/presentation/pages/dualar_sayfasi.dart';
import 'package:ezancep_pro/features/ayarlar/presentation/pages/ayarlar_sayfasi.dart';
import 'package:ezancep_pro/features/splash/presentation/pages/splash_screen.dart';
import 'package:ezancep_pro/features/ayetler/presentation/pages/ayetler_sayfasi.dart';
import 'package:ezancep_pro/features/kible/presentation/pages/kible_sayfasi.dart';

// EKSİK BLOC DOSYALARINI BASİT VERSİYONLARIYLA OLUŞTURALIM
class KonumBloc extends Bloc<dynamic, dynamic> {
  KonumBloc() : super(null);
}

class EzanVakitleriBloc extends Bloc<dynamic, dynamic> {
  EzanVakitleriBloc() : super(null);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<KonumBloc>(
          create: (context) => KonumBloc(),
        ),
        BlocProvider<EzanVakitleriBloc>(
          create: (context) => EzanVakitleriBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'EzanCep Pro',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0E17),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A0E17),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1F2C),
            selectedItemColor: Color(0xFF00D4AA),
            unselectedItemColor: Colors.white54,
          ),
        ),
        // SPLASH SCREEN YERİNE DOĞRUDAN ANA SAYFA
        home: const AnaSayfa(), // Bu satırı değiştirin
        routes: {
          '/ana_sayfa': (context) => const AnaSayfa(),
          '/tesbih': (context) => const TesbihSayfasi(),
          '/dualar': (context) => const DualarSayfasi(),
          '/ayarlar': (context) => const AyarlarSayfasi(),
          '/ayetler': (context) => const AyetlerSayfasi(),
          '/kible': (context) => const KibleSayfasi(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}