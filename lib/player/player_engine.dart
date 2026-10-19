import 'dart:async';

/// Estado instantaneo do player, exposto via stream para a UI.
class PlayerState {
  const PlayerState({
    this.isPlaying = false,
    this.isBuffering = false,
    this.hasError = false,
    this.errorMessage,
    this.position = Duration.zero,
    this.duration,
    this.isInitialized = false,
  });

  final bool isPlaying;
  final bool isBuffering;
  final bool hasError;
  final String? errorMessage;
  final Duration position;

  /// Nulo para transmissao ao vivo (sem seek).
  final Duration? duration;
  final bool isInitialized;

  bool get isLive => duration == null;
  bool get canSeek => duration != null && duration! > Duration.zero;

  PlayerState copyWith({
    bool? isPlaying,
    bool? isBuffering,
    bool? hasError,
    String? errorMessage,
    Duration? position,
    Duration? duration,
    bool? isInitialized,
  }) =>
      PlayerState(
        isPlaying: isPlaying ?? this.isPlaying,
        isBuffering: isBuffering ?? this.isBuffering,
        hasError: hasError ?? this.hasError,
        errorMessage: errorMessage ?? this.errorMessage,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        isInitialized: isInitialized ?? this.isInitialized,
      );

  static const initial = PlayerState();
}

/// Abstracao do motor de reproducao. Permite trocar video_player por
/// media_kit (libmpv) sem alterar a UI, caso streams problematicos de
/// MPEG-TS exijam o motor alternativo.
abstract class PlayerEngine {
  Stream<PlayerState> get stateStream;
  PlayerState get currentState;

  Future<void> open(String url, {required bool isLive});
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setVolume(double volume); // 0.0 - 1.0
  Future<void> setPlaybackSpeed(double speed);
  Future<void> dispose();

  /// Tenta novamente apos erro (recria a conexao). Limitado pela UI.
  Future<void> retry();
}
