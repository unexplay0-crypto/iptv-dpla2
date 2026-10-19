import 'dart:async';

import 'package:video_player/video_player.dart';

import '../core/app_logger.dart';
import 'player_engine.dart';

/// Implementacao de [PlayerEngine] usando o pacote oficial video_player,
/// que no Android utiliza ExoPlayer / AndroidX Media3.
///
/// Suporta: HLS (.m3u8), MP4, MPEG-TS (via extrator TS do ExoPlayer).
/// Limitacoes: codecs dependem do dispositivo (HEVC/H.265 exige hardware);
/// streams TS nao padronizados podem falhar — nestes casos avaliar media_kit.
class VideoPlayerEngine implements PlayerEngine {
  VideoPlayerController? _controller;
  StreamController<PlayerState>? _stateController;
  String? _url;
  bool _isLive = false;
  bool _disposed = false;

  @override
  PlayerState currentState = PlayerState.initial;

  @override
  Stream<PlayerState> get stateStream {
    _stateController ??= StreamController<PlayerState>.broadcast();
    return _stateController!.stream;
  }

  VideoPlayerController? get controller => _controller;

  void _emit(PlayerState state) {
    currentState = state;
    if (_stateController != null && !_stateController!.isClosed) {
      _stateController!.add(state);
    }
  }

  @override
  Future<void> open(String url, {required bool isLive}) async {
    _url = url;
    _isLive = isLive;
    await _createAndInitialize();
  }

  Future<void> _createAndInitialize() async {
    if (_url == null) return;
    _emit(currentState.copyWith(
        isBuffering: true, hasError: false, errorMessage: null));
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(_url!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        httpHeaders: const {'User-Agent': 'IPTVStreamer/1.0'},
      );
      controller.addListener(_onControllerUpdate);
      await controller.initialize().timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          throw TimeoutException('Inicializacao do stream excedeu o tempo limite.');
        },
      );
      _controller = controller;
      final duration = _isLive ? null : controller.value.duration;
      _emit(currentState.copyWith(
        isInitialized: true,
        isBuffering: !controller.value.isPlaying,
        duration: duration,
        position: controller.value.position,
      ));
      await controller.play();
    } catch (e, st) {
      AppLogger.e('Falha ao abrir stream', e, st);
      _emit(currentState.copyWith(
        hasError: true,
        errorMessage: e.toString(),
        isBuffering: false,
      ));
    }
  }

  void _onControllerUpdate() {
    final c = _controller;
    if (c == null || _disposed) return;
    final v = c.value;
    if (v.hasError) {
      _emit(currentState.copyWith(
        hasError: true,
        errorMessage: v.errorDescription ?? 'Erro de reproducao.',
        isBuffering: false,
      ));
      return;
    }
    final duration = _isLive ? null : v.duration;
    _emit(currentState.copyWith(
      isPlaying: v.isPlaying,
      isBuffering: v.isBuffering,
      position: v.position,
      duration: duration,
      isInitialized: v.isInitialized,
    ));
  }

  @override
  Future<void> play() => _controller?.play() ?? Future.value();

  @override
  Future<void> pause() => _controller?.pause() ?? Future.value();

  @override
  Future<void> seekTo(Duration position) =>
      _controller?.seekTo(position) ?? Future.value();

  @override
  Future<void> setVolume(double volume) =>
      _controller?.setVolume(volume.clamp(0.0, 1.0)) ?? Future.value();

  @override
  Future<void> setPlaybackSpeed(double speed) =>
      _controller?.setPlaybackSpeed(speed) ?? Future.value();

  @override
  Future<void> retry() async {
    await dispose(closeStream: false);
    await _createAndInitialize();
  }

  @override
  Future<void> dispose({bool closeStream = true}) async {
    _disposed = true;
    final c = _controller;
    _controller = null;
    if (c != null) {
      c.removeListener(_onControllerUpdate);
      try {
        await c.pause();
        await c.dispose();
      } catch (e) {
        AppLogger.w('Erro ao liberar player: $e');
      }
    }
    if (closeStream) {
      await _stateController?.close();
      _stateController = null;
    } else {
      _disposed = false; // permite retry
    }
  }
}
