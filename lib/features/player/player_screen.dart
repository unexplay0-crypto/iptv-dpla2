import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../core/app_logger.dart';
import '../../core/theme/app_theme.dart';
import '../../player/player_engine.dart';
import '../../player/video_player_engine.dart';

/// Tela de reproducao em tela cheia. Controles sobrepostos minimalistas,
/// navegaveis por D-pad (setas + OK) e por toque. Auto-ocultacao apos
/// inatividade. Libera recursos corretamente ao sair.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.mediaId,
    required this.title,
    required this.url,
    required this.isLive,
  });

  final String mediaId;
  final String title;
  final String url;
  final bool isLive;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final VideoPlayerEngine _engine;
  Timer? _hideTimer;
  bool _controlsVisible = true;
  bool _disposed = false;
  double _sliderValue = 0;

  static const _autoHideDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _engine = VideoPlayerEngine();
    _engine.open(widget.url, isLive: widget.isLive);
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_autoHideDelay, () {
      if (!_disposed && mounted) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHide();
  }

  void _seekRelative(Duration delta) {
    final s = _engine.currentState;
    if (!s.canSeek || s.duration == null) return;
    var target = s.position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > s.duration!) target = s.duration!;
    _engine.seekTo(target);
    _showControls();
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _scheduleHide();
  }

  Future<void> _teardown() async {
    if (_disposed) return;
    _disposed = true;
    _hideTimer?.cancel();
    await _engine.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _teardown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _teardown();
        if (mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            final key = event.logicalKey;
            if (key == LogicalKeyboardKey.select ||
                key == LogicalKeyboardKey.enter ||
                key == LogicalKeyboardKey.mediaPlayPause) {
              _togglePlayPause();
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.arrowLeft) {
              _seekRelative(const Duration(seconds: -10));
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.arrowRight) {
              _seekRelative(const Duration(seconds: 10));
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.arrowUp ||
                key == LogicalKeyboardKey.arrowDown) {
              _showControls();
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.mediaPlay) {
              _engine.play();
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.mediaPause) {
              _engine.pause();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(child: _buildVideo()),
                if (_controlsVisible) _buildOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _togglePlayPause() {
    final s = _engine.currentState;
    if (s.isPlaying) {
      _engine.pause();
    } else {
      _engine.play();
    }
    _showControls();
  }

  Widget _buildVideo() {
    return StreamBuilder<PlayerState>(
      stream: _engine.stateStream,
      initialData: PlayerState.initial,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (state.hasError) {
          return _buildError(state.errorMessage);
        }
        final c = _engine.controller;
        if (c == null || !state.isInitialized) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('Carregando transmissao...',
                    style: TextStyle(color: Colors.white70, fontSize: 18)),
              ],
            ),
          );
        }
        return AspectRatio(
          aspectRatio: c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9,
          child: VideoPlayer(c),
        );
      },
    );
  }

  Widget _buildError(String? message) {
    AppLogger.e('Erro de playback: $message');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Nao foi possivel reproduzir este conteudo.',
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'A transmissao pode estar indisponivel ou em formato nao suportado.',
              style: TextStyle(color: Colors.white60, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _FocusButton(
              label: 'Tentar novamente',
              icon: Icons.refresh,
              onPressed: () => _engine.retry(),
            ),
            const SizedBox(height: 12),
            _FocusButton(
              label: 'Voltar',
              icon: Icons.arrow_back,
              onPressed: () async {
                await _teardown();
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return StreamBuilder<PlayerState>(
      stream: _engine.stateStream,
      initialData: _engine.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        final canSeek = state.canSeek;
        if (canSeek && state.duration != null && state.duration!.inMilliseconds > 0) {
          _sliderValue = (state.position.inMilliseconds /
                  state.duration!.inMilliseconds)
              .clamp(0.0, 1.0);
        }
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildTopBar(),
              const Spacer(),
              if (state.isBuffering)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              _buildBottomControls(canSeek, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            _FocusButton(
              icon: Icons.arrow_back,
              label: 'Voltar',
              compact: true,
              onPressed: () async {
                await _teardown();
                if (mounted) Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.isLive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AuroraColors.accentMagenta,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('AO VIVO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(bool canSeek, PlayerState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canSeek)
            Row(
              children: [
                Text(_format(state.position),
                    style: const TextStyle(color: Colors.white70)),
                Expanded(
                  child: Slider(
                    value: _sliderValue,
                    activeColor: AuroraColors.accentCyan,
                    inactiveColor: Colors.white24,
                    onChanged: (v) {
                      setState(() => _sliderValue = v);
                      _showControls();
                    },
                    onChangeEnd: (v) {
                      final dur = state.duration!;
                      _engine.seekTo(Duration(
                          milliseconds: (v * dur.inMilliseconds).round()));
                    },
                  ),
                ),
                Text(_format(state.duration!),
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (canSeek)
                _FocusButton(
                    icon: Icons.replay_10,
                    label: '-10s',
                    compact: true,
                    onPressed: () =>
                        _seekRelative(const Duration(seconds: -10))),
              const SizedBox(width: 16),
              _FocusButton(
                icon: state.isPlaying ? Icons.pause : Icons.play_arrow,
                label: state.isPlaying ? 'Pausar' : 'Reproduzir',
                onPressed: _togglePlayPause,
                large: true,
              ),
              const SizedBox(width: 16),
              if (canSeek)
                _FocusButton(
                    icon: Icons.forward_10,
                    label: '+10s',
                    compact: true,
                    onPressed: () =>
                        _seekRelative(const Duration(seconds: 10))),
            ],
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

/// Botao com estado de foco destacado para TV.
class _FocusButton extends StatelessWidget {
  const _FocusButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool compact;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        final focused = Focus.of(context).hasFocus;
        final size = large ? 64.0 : (compact ? 44.0 : 52.0);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: focused ? Colors.white : Colors.white24,
                border: focused
                    ? Border.all(color: AuroraColors.accentCyan, width: 3)
                    : null,
                boxShadow: focused
                    ? [
                        BoxShadow(
                            color: AuroraColors.accentCyan.withOpacity(0.5),
                            blurRadius: 16)
                      ]
                    : null,
              ),
              child: Icon(icon,
                  size: large ? 32 : 22,
                  color: focused ? Colors.black : Colors.white),
            ),
          ),
        );
      }),
    );
  }
}
