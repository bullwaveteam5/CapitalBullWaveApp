import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/services/ai_voice_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/premium_background.dart';
import '../../../../core/widgets/ai_orb_widgets.dart';
import '../../../authentication/presentation/provider/auth_provider.dart';
import '../provider/stock_features_provider.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  static const _prefAutoSend = 'ai_auto_send';
  static const _prefAutoMic = 'ai_auto_mic';
  static const _prefVoiceReply = 'ai_voice_reply';

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _voice = AiVoiceService.instance;

  bool _voiceReplyEnabled = true;
  bool _autoSendEnabled = true;
  bool _autoMicEnabled = true;
  bool _voiceReady = false;
  String? _voiceErrorMsg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<StockFeaturesProvider>().loadAiChat();
      await _loadVoicePrefs();
      await _refreshVoice();
      if (_autoMicEnabled && mounted) {
        await _startMicIfIdle();
      }
    });
  }

  Future<void> _loadVoicePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _autoSendEnabled = prefs.getBool(_prefAutoSend) ?? true;
      _autoMicEnabled = prefs.getBool(_prefAutoMic) ?? true;
      _voiceReplyEnabled = prefs.getBool(_prefVoiceReply) ?? true;
    });
  }

  Future<void> _saveVoicePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _refreshVoice() async {
    await _voice.initialize();
    if (!mounted) return;
    setState(() {
      _voiceReady = true;
      _voiceErrorMsg = null;
      if (!_voice.ttsAvailable) _voiceReplyEnabled = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _voice.stopListening();
    _voice.stopSpeaking();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _onSpeechResult(String text, bool isFinal) {
    if (!mounted) return;
    if (text == 'Listening… tap Stop when done') {
      setState(() => _controller.text = '');
      return;
    }
    setState(() => _controller.text = text);
    if (isFinal && _autoSendEnabled && text.trim().isNotEmpty && !text.startsWith('Listening')) {
      _send(text);
    }
  }

  Future<void> _send(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    final features = context.read<StockFeaturesProvider>();
    if (features.isAiLoading) return;

    await _voice.stopListening();
    _controller.clear();
    if (mounted) setState(() {});

    await features.sendAiMessage(query);
    if (!mounted) return;

    _scrollToBottom();

    if (_voiceReplyEnabled && _voice.ttsAvailable && features.aiError == null) {
      final last = features.aiMessages.isNotEmpty ? features.aiMessages.last : null;
      if (last != null && last.role == 'assistant') {
        try {
          setState(() => _voiceErrorMsg = null);
          await _voice.speak(last.content);
        } on ApiException catch (e) {
          setState(() => _voiceErrorMsg = e.message);
        } catch (_) {
          setState(() => _voiceErrorMsg = 'Could not play AI voice.');
        }
      }
    }

    if (_autoMicEnabled && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await _startMicIfIdle();
    }
  }

  Future<void> _startMicIfIdle() async {
    final features = context.read<StockFeaturesProvider>();
    if (features.isAiLoading || _voice.isListening || _voice.isSpeaking) return;

    final started = await _voice.startListening(
      onResult: _onSpeechResult,
      preferDeviceStt: _autoSendEnabled,
    );
    if (!mounted || !started) return;
    setState(() {});
  }

  Future<void> _toggleMic() async {
    if (_voice.isListening) {
      try {
        await _voice.stopListening(onResult: _onSpeechResult);
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
          );
        }
      }
      if (mounted) setState(() {});
      return;
    }
    await _startMicIfIdle();
  }

  Future<void> _speakBubble(String text) async {
    try {
      setState(() => _voiceErrorMsg = null);
      await _voice.speak(text);
    } on ApiException catch (e) {
      setState(() => _voiceErrorMsg = e.message);
    } catch (_) {
      setState(() => _voiceErrorMsg = 'Could not play voice.');
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firstName = auth.user?.displayName.split(' ').first ?? 'Investor';
    final isListening = _voice.isListening;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PremiumMeshBackground(
            glowPrimary: Color(0xFF7C3AED),
            glowSecondary: Color(0xFFEC4899),
          ),
          const PremiumFilmGrain(),
          SafeArea(
            child: Column(
              children: [
                _ChatHeader(
                  voiceReplyEnabled: _voiceReplyEnabled,
                  ttsAvailable: _voiceReady && _voice.ttsAvailable,
                  onToggleVoice: () async {
                    final next = !_voiceReplyEnabled;
                    setState(() => _voiceReplyEnabled = next);
                    await _saveVoicePref(_prefVoiceReply, next);
                  },
                  onClear: () => context.read<StockFeaturesProvider>().clearAiChat(),
                ),
                if (isListening)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      _controller.text.isNotEmpty
                          ? _controller.text
                          : 'Listening…',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                Expanded(
                  child: Consumer<StockFeaturesProvider>(
                    builder: (context, features, _) {
                      _scrollToBottom();

                      if (features.aiMessages.isEmpty && !features.isAiLoading) {
                        return _GreetingPanel(
                          greeting: '${_greeting()}, $firstName',
                          isListening: isListening,
                          onTalk: _toggleMic,
                          onPortfolio: () => _send('Summarize my portfolio holdings and P&L'),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        itemCount: features.aiMessages.length + (features.isAiLoading ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (features.isAiLoading && i == features.aiMessages.length) {
                            return AiGlassBubble(
                              isUser: false,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.brandCyan.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Thinking…',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final m = features.aiMessages[i];
                          final isUser = m.role == 'user';

                          return AiGlassBubble(
                            isUser: isUser,
                            child: Text(
                              m.content,
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: isUser ? 0.95 : 0.88),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            trailing: !isUser && _voice.ttsAvailable
                                ? IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    tooltip: 'Listen',
                                    icon: Icon(
                                      _voice.isSpeaking
                                          ? Icons.stop_circle_outlined
                                          : Icons.volume_up_rounded,
                                      size: 18,
                                      color: AppColors.brandCyan,
                                    ),
                                    onPressed: _voice.isSpeaking
                                        ? () => _voice.stopSpeaking()
                                        : () => _speakBubble(m.content),
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
                if (isListening)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AiListeningOrb(size: 100, active: true),
                  ),
                Consumer<StockFeaturesProvider>(
                  builder: (context, features, _) {
                    final err = features.aiError ?? _voiceErrorMsg;
                    if (err != null) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Text(
                          err,
                          style: GoogleFonts.inter(color: AppColors.red, fontSize: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Consumer<StockFeaturesProvider>(
                  builder: (context, features, _) {
                    if (features.aiSuggestions.isEmpty) return const SizedBox.shrink();
                    return SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: features.aiSuggestions.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => AiSuggestionPill(
                          label: features.aiSuggestions[i],
                          onTap: features.isAiLoading
                              ? null
                              : () => _send(features.aiSuggestions[i]),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _ChatInputBar(
                  controller: _controller,
                  isListening: isListening,
                  isLoading: context.watch<StockFeaturesProvider>().isAiLoading,
                  autoSend: _autoSendEnabled,
                  autoMic: _autoMicEnabled,
                  onToggleMic: _toggleMic,
                  onSend: () => _send(_controller.text),
                  onToggleAutoSend: (v) async {
                    setState(() => _autoSendEnabled = v);
                    await _saveVoicePref(_prefAutoSend, v);
                  },
                  onToggleAutoMic: (v) async {
                    setState(() => _autoMicEnabled = v);
                    await _saveVoicePref(_prefAutoMic, v);
                    if (v) {
                      await _startMicIfIdle();
                    } else {
                      await _voice.stopListening();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final bool voiceReplyEnabled;
  final bool ttsAvailable;
  final VoidCallback onToggleVoice;
  final VoidCallback onClear;

  const _ChatHeader({
    required this.voiceReplyEnabled,
    required this.ttsAvailable,
    required this.onToggleVoice,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _CircleBtn(
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AiOrbLogo(size: 22, showArc: false, animate: false),
                const SizedBox(width: 8),
                Text(
                  'AI Buddy',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (ttsAvailable)
            _CircleBtn(
              icon: voiceReplyEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              onTap: onToggleVoice,
              active: voiceReplyEnabled,
            )
          else
            const SizedBox(width: 44),
          _CircleBtn(icon: Icons.delete_outline_rounded, onTap: onClear),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: active ? AppColors.brandCyan : Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

class _GreetingPanel extends StatelessWidget {
  final String greeting;
  final bool isListening;
  final VoidCallback onTalk;
  final VoidCallback onPortfolio;

  const _GreetingPanel({
    required this.greeting,
    required this.isListening,
    required this.onTalk,
    required this.onPortfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isListening) ...[
            const AiOrbLogo(size: 52, showArc: true, animate: true),
            const SizedBox(height: 28),
          ],
          Text(
            '$greeting 👋',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How may I help\nyou today?',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 28),
          _ActionCard(
            title: 'Talk with AI',
            subtitle: 'Voice questions about markets',
            gradient: const [Color(0xFF7C3AED), Color(0xFF9333EA)],
            icon: Icons.mic_rounded,
            onTap: onTalk,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: 'Chat',
                  subtitle: 'Type a question',
                  gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
                  icon: Icons.chat_bubble_outline_rounded,
                  compact: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionCard(
                  title: 'Portfolio',
                  subtitle: 'Holdings & P&L',
                  gradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
                  icon: Icons.pie_chart_outline_rounded,
                  compact: true,
                  onTap: onPortfolio,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final bool compact;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient.map((c) => c.withValues(alpha: 0.85)).toList(),
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.north_east_rounded, color: Colors.white.withValues(alpha: 0.8)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool isLoading;
  final bool autoSend;
  final bool autoMic;
  final VoidCallback onToggleMic;
  final VoidCallback onSend;
  final ValueChanged<bool> onToggleAutoSend;
  final ValueChanged<bool> onToggleAutoMic;

  const _ChatInputBar({
    required this.controller,
    required this.isListening,
    required this.isLoading,
    required this.autoSend,
    required this.autoMic,
    required this.onToggleMic,
    required this.onSend,
    required this.onToggleAutoSend,
    required this.onToggleAutoMic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              _MiniToggle(label: 'Auto send', on: autoSend, onChanged: onToggleAutoSend),
              const SizedBox(width: 8),
              _MiniToggle(label: 'Auto mic', on: autoMic, onChanged: onToggleAutoMic),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: isLoading ? null : onToggleMic,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isListening
                              ? const LinearGradient(
                                  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                                )
                              : null,
                          color: isListening ? null : Colors.white.withValues(alpha: 0.06),
                        ),
                        child: Icon(
                          isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: isListening ? Colors.white : AppColors.brandCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: !isLoading,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: autoSend
                              ? 'Speak or type — auto sends on pause'
                              : 'Ask about stocks & portfolio…',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : onSend,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                          ),
                        ),
                        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;

  const _MiniToggle({
    required this.label,
    required this.on,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: on
              ? AppColors.brandPrimary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: on
                ? AppColors.brandPrimary.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: on ? AppColors.brandCyan : Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
