import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockFeaturesProvider>().loadAiChat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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

  void _send(String text) {
    final query = text.trim();
    if (query.isEmpty) return;
    context.read<StockFeaturesProvider>().sendAiMessage(query);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI Stock Assistant',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear chat',
            onPressed: () => context.read<StockFeaturesProvider>().clearAiChat(),
          ),
        ],
      ),
      body: Column(
        children: [
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
                            color: context.appColors.surfaceSecondary,
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
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.82,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.green.withValues(alpha: 0.15)
                              : context.appColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(m.content),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<StockFeaturesProvider>(
            builder: (context, features, _) {
              if (features.aiError == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  features.aiError!,
                  style: const TextStyle(color: AppColors.red, fontSize: 12),
                ),
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
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !context.watch<StockFeaturesProvider>().isAiLoading,
                    decoration: const InputDecoration(hintText: 'Ask about stocks...'),
                    onSubmitted: _send,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.green),
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
