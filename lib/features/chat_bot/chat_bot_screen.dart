import 'package:flutter/material.dart';
import 'package:silent_link/features/chat_bot/widget_chat_bot/chat_input.dart';
import 'package:silent_link/features/chat_bot/widget_chat_bot/message_bubble.dart';
import 'package:silent_link/features/chat_bot/widget_chat_bot/quick_buttons.dart';
import 'package:silent_link/navigation/main_navigation_screen.dart';
import '../../core/constants/app_colors.dart';
import 'chat_bot_model.dart';
import 'gemini_service.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<ChatMessage> _messages = [];

  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final GeminiService _service = GeminiService();

  bool _isLoading = false;
  bool _showCenterOptions = true;

  Future<void> _sendMessage([String? text]) async {
    final messageText = text ?? _controller.text;

    if (messageText.trim().isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _messages.insert(0, ChatMessage(text: messageText, isUser: true));

      _isLoading = true;
      _showCenterOptions = false;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _service.getResponse(messageText);

      if (!mounted) return;

      setState(() {
        _messages.insert(0, ChatMessage(text: response, isUser: false));
      });
    } catch (e) {
      debugPrint("ChatBot Error: $e");

      if (!mounted) return;

      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: "Something went wrong. Please try again.",
            isUser: false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _showCenterOptions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 60),

                /// Chat Messages
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(message: _messages[index]);
                        },
                      ),

                      /// Center Options
                      if (_showCenterOptions)
                        Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "What Can I Help With?",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 30),

                                QuickButtons(onTap: (val) => _sendMessage(val)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                /// Loading Indicator
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                /// Input Field
                ChatInput(
                  controller: _controller,
                  onSend: () => _sendMessage(),
                ),
              ],
            ),

            /// New Chat Button
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                tooltip: "New Chat",
                icon: const Icon(
                  Icons.edit_note,
                  size: 32,
                  color: Colors.black54,
                ),
                onPressed: _clearChat,
              ),
            ),

            /// Back Button
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Colors.black54,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
