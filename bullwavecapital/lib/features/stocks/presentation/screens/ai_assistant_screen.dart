import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';



import '../../../../core/api/api_exception.dart';

import '../../../../core/services/ai_voice_service.dart';

import '../../../../core/theme/app_theme_extension.dart';

import '../../../../core/theme/colors.dart';

import '../../../../core/widgets/custom_app_bar.dart';

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

    if (isFinal &&

        _autoSendEnabled &&

        text.trim().isNotEmpty &&

        !text.startsWith('Listening')) {

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

          setState(() {

            _voiceErrorMsg = null;

          });

          await _voice.speak(last.content);

        } on ApiException catch (e) {

          setState(() {

            _voiceErrorMsg = e.message;

          });

        } catch (_) {

          setState(() {

            _voiceErrorMsg = 'Could not play AI voice.';

          });

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

    if (!mounted) return;

    if (!started) return;

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

      setState(() {

        _voiceErrorMsg = null;

      });

      await _voice.speak(text);

    } on ApiException catch (e) {

      setState(() {

        _voiceErrorMsg = e.message;

      });

    } catch (_) {

      setState(() {

        _voiceErrorMsg = 'Could not play voice.';

      });

    }

  }



  @override

  Widget build(BuildContext context) {

    final colors = context.appColors;



    return Scaffold(

      appBar: CustomAppBar(

        title: 'AI Stock Assistant',

        actions: [

          if (_voiceReady && _voice.ttsAvailable)

            IconButton(

              tooltip: _voiceReplyEnabled ? 'Voice replies on' : 'Voice replies off',

              onPressed: () async {

                final next = !_voiceReplyEnabled;

                setState(() => _voiceReplyEnabled = next);

                await _saveVoicePref(_prefVoiceReply, next);

              },

              icon: Icon(

                _voiceReplyEnabled ? Icons.record_voice_over_rounded : Icons.volume_off_rounded,

                color: _voiceReplyEnabled ? AppColors.brandPink : colors.textMuted,

              ),

            ),

          IconButton(

            icon: const Icon(Icons.delete_outline_rounded),

            tooltip: 'Clear chat',

            onPressed: () => context.read<StockFeaturesProvider>().clearAiChat(),

          ),

        ],

      ),

      body: Column(

        children: [

          if (_voice.isListening)

            Container(

              width: double.infinity,

              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),

              color: AppColors.brandPink.withValues(alpha: 0.12),

              child: Row(

                children: [

                  Icon(Icons.mic_rounded, color: AppColors.brandPink, size: 20),

                  const SizedBox(width: 8),

                  Expanded(

                    child: Text(

                      _autoSendEnabled

                          ? 'Listening… speak, message sends automatically'

                          : 'Listening… tap Stop, then send',

                      style: TextStyle(

                        color: AppColors.brandPrimary,

                        fontWeight: FontWeight.w700,

                        fontSize: 13,

                      ),

                    ),

                  ),

                  TextButton(onPressed: _toggleMic, child: const Text('Stop')),

                ],

              ),

            ),

          if (_voiceReady && _voice.ttsAvailable)

            Padding(

              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),

              child: Align(

                alignment: Alignment.centerLeft,

                child: Text(

                  'Voice: ${_voice.voiceId.isNotEmpty ? _voice.voiceId : 'shimmer'} · warm female tone',

                  style: TextStyle(color: colors.textMuted, fontSize: 11),

                ),

              ),

            ),

          if (!_voice.ttsAvailable && _voiceReady)

            Padding(

              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),

              child: Text(

                _voice.statusMessage ??

                    'Voice: add OPENAI_API_KEY in backend/.env and restart Django.',

                style: TextStyle(color: colors.textMuted, fontSize: 11),

              ),

            ),

          Padding(

            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),

            child: Row(

              children: [

                _VoiceOptionChip(

                  label: 'Auto send',

                  icon: Icons.send_rounded,

                  enabled: _autoSendEnabled,

                  onChanged: (v) async {

                    setState(() => _autoSendEnabled = v);

                    await _saveVoicePref(_prefAutoSend, v);

                  },

                ),

                const SizedBox(width: 8),

                _VoiceOptionChip(

                  label: 'Auto mic',

                  icon: Icons.mic_rounded,

                  enabled: _autoMicEnabled,

                  onChanged: (v) async {

                    setState(() => _autoMicEnabled = v);

                    await _saveVoicePref(_prefAutoMic, v);

                    if (v) await _startMicIfIdle();

                    if (!v) await _voice.stopListening();

                  },

                ),

              ],

            ),

          ),

          Expanded(

            child: Consumer<StockFeaturesProvider>(

              builder: (context, features, _) {

                _scrollToBottom();

                return ListView.builder(

                  controller: _scrollController,

                  padding: const EdgeInsets.all(16),

                  itemCount: features.aiMessages.length + (features.isAiLoading ? 1 : 0),

                  itemBuilder: (_, i) {

                    if (features.isAiLoading && i == features.aiMessages.length) {

                      return Align(

                        alignment: Alignment.centerLeft,

                        child: Container(

                          margin: const EdgeInsets.only(bottom: 10),

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(

                            color: colors.surfaceSecondary,

                            borderRadius: BorderRadius.circular(16),

                          ),

                          child: const Row(

                            mainAxisSize: MainAxisSize.min,

                            children: [

                              SizedBox(

                                width: 18,

                                height: 18,

                                child: CircularProgressIndicator(strokeWidth: 2),

                              ),

                              SizedBox(width: 10),

                              Text('Thinking...'),

                            ],

                          ),

                        ),

                      );

                    }



                    final m = features.aiMessages[i];

                    final isUser = m.role == 'user';

                    return Align(

                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,

                      child: Container(

                        margin: const EdgeInsets.only(bottom: 10),

                        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),

                        constraints: BoxConstraints(

                          maxWidth: MediaQuery.of(context).size.width * 0.82,

                        ),

                        decoration: BoxDecoration(

                          color: isUser

                              ? AppColors.brandPrimary.withValues(alpha: 0.12)

                              : colors.surfaceSecondary,

                          borderRadius: BorderRadius.circular(16),

                        ),

                        child: Row(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Expanded(child: Text(m.content)),

                            if (!isUser && _voice.ttsAvailable)

                              IconButton(

                                visualDensity: VisualDensity.compact,

                                padding: EdgeInsets.zero,

                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),

                                tooltip: 'Listen',

                                icon: Icon(

                                  _voice.isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_rounded,

                                  size: 20,

                                  color: AppColors.brandPink,

                                ),

                                onPressed: _voice.isSpeaking

                                    ? () => _voice.stopSpeaking()

                                    : () => _speakBubble(m.content),

                              ),

                          ],

                        ),

                      ),

                    );

                  },

                );

              },

            ),

          ),

          Consumer<StockFeaturesProvider>(

            builder: (context, features, _) {

              final err = features.aiError ?? _voiceErrorMsg;

              if (err == null) return const SizedBox.shrink();

              return Padding(

                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

                child: Text(err, style: const TextStyle(color: AppColors.red, fontSize: 12)),

              );

            },

          ),

          Consumer<StockFeaturesProvider>(

            builder: (context, features, _) => SingleChildScrollView(

              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(

                children: features.aiSuggestions.map((s) {

                  return Padding(

                    padding: const EdgeInsets.only(right: 8, bottom: 8),

                    child: ActionChip(

                      label: Text(s, style: const TextStyle(fontSize: 12)),

                      onPressed: features.isAiLoading ? null : () => _send(s),

                    ),

                  );

                }).toList(),

              ),

            ),

          ),

          Padding(

            padding: const EdgeInsets.all(16),

            child: Row(

              children: [

                IconButton(

                  tooltip: _voice.isListening ? 'Stop listening' : 'Voice input',

                  onPressed: context.watch<StockFeaturesProvider>().isAiLoading ? null : _toggleMic,

                  icon: Icon(

                    _voice.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,

                    color: _voice.isListening ? AppColors.red : AppColors.brandPink,

                    size: 28,

                  ),

                ),

                Expanded(

                  child: TextField(

                    controller: _controller,

                    enabled: !context.watch<StockFeaturesProvider>().isAiLoading,

                    decoration: InputDecoration(

                      hintText: _autoSendEnabled

                          ? 'Speak or type — auto sends when you pause'

                          : 'Ask about stocks… or tap mic',

                    ),

                    onSubmitted: _send,

                  ),

                ),

                IconButton(

                  icon: const Icon(Icons.send_rounded, color: AppColors.brandPink),

                  onPressed: context.watch<StockFeaturesProvider>().isAiLoading

                      ? null

                      : () => _send(_controller.text),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



class _VoiceOptionChip extends StatelessWidget {

  final String label;

  final IconData icon;

  final bool enabled;

  final ValueChanged<bool> onChanged;



  const _VoiceOptionChip({

    required this.label,

    required this.icon,

    required this.enabled,

    required this.onChanged,

  });



  @override

  Widget build(BuildContext context) {

    final colors = context.appColors;

    return FilterChip(

      label: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(icon, size: 14, color: enabled ? AppColors.brandPink : colors.textMuted),

          const SizedBox(width: 4),

          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),

        ],

      ),

      selected: enabled,

      onSelected: onChanged,

      selectedColor: AppColors.brandPink.withValues(alpha: 0.15),

      checkmarkColor: AppColors.brandPink,

      showCheckmark: true,

    );

  }

}


