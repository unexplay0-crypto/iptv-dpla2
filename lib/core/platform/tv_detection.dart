import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Detecta se o app esta rodando em Android TV / Google TV.
///
/// No Android, o sistema reporta a feature `android.software.leanback`.
/// Como o Flutter nao expoe isso diretamente, usamos uma heuristica:
///  - ausencia de touchscreen (declarada no manifest como nao obrigatoria)
///  - DeviceInfo via platform channel seria mais preciso; por enquanto,
///    combinamos tamanho de tela (MediaQuery) com a flag abaixo.
///
/// A deteccao exata via PlatformChannel pode ser adicionada depois sem
/// alterar a interface desta classe.
class TvDetection {
  TvDetection._();

  static bool? _override;

  /// Permite forcar modo TV em testes ou forcar modo celular.
  static void setDebugOverride(bool isTv) => _override = isTv;

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Heuristica: em Android TV, o dispositivo geralmente nao tem
  /// touchscreen. Aqui retornamos falso por padrao e o layout decide
  /// principalmente com base no tamanho da tela (largura >= 960dp).
  static bool get leanbackLikely {
    if (_override != null) return _override!;
    if (!isAndroid) return false;
    // Em uma implementacao completa, lemos PackageManager.hasSystemFeature
    // via MethodChannel. Por enquanto, o fator decisivo e o tamanho de tela.
    return false;
  }
}

/// Extensao para decidir o layout com base na largura da tela.
extension LayoutBreakpoints on num {
  /// Largura minima (dp) para considerar layout de TV/tablet.
  static const double tvBreakpoint = 960;
  bool get isTvWidth => this >= tvBreakpoint;
}
