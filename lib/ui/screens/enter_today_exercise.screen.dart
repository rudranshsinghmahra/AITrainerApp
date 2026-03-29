import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/screen_controllers/ai_trainer.notifier.dart';
import 'ai_training_plan_viewer.screen.dart';

class EnterTodayExercise extends ConsumerStatefulWidget {
  const EnterTodayExercise({super.key});

  @override
  ConsumerState<EnterTodayExercise> createState() => _EnterTodayExerciseState();
}

class _EnterTodayExerciseState extends ConsumerState<EnterTodayExercise> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;

  // FIX 1: Track the last value set BY the speech engine so we can distinguish
  // speech updates from manual user edits (backspace, typing, paste, etc.)
  String _lastSpeechValue = '';

  final List<String> _masterSuggestions = [
    "🔥 Full Body Burn", "💪 Heavy Leg Day", "🏃 Quick Cardio",
    "🧘 Mobility & Core", "🏋️ Upper Body Power", "🧨 Explosive Plyo",
    "🏠 At-Home No Equipment", "🏔️ Hiking Prep", "🥊 Boxer's Conditioning",
    "🌊 Pool Workout", "⚡ 15-Min HIIT", "🍑 Glute Focus"
  ];

  List<String> _currentSuggestions = [];

  void _generateRandomSuggestions() {
    final shuffled = List<String>.from(_masterSuggestions)..shuffle();
    setState(() => _currentSuggestions = shuffled.take(4).toList());
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _generateRandomSuggestions();

    // FIX 2: Watch for any manual edit (backspace, typing) while mic is active
    // If the text no longer matches what speech last wrote, user is editing → stop
    _inputController.addListener(() {
      if (_isListening && _inputController.text != _lastSpeechValue) {
        _stopListening();
      }
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        debugPrint('Speech error: $error');
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == SpeechToText.doneStatus || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechEnabled || _isListening) return;

    // FIX 3: Seed _lastSpeechValue with whatever is already in the field
    // so the controller listener doesn't immediately fire a false "user edit"
    _lastSpeechValue = _inputController.text;

    await _speechToText.listen(
      onResult: (result) {
        if (!mounted) return;
        final words = result.recognizedWords;
        _lastSpeechValue = words; // keep shadow in sync BEFORE updating controller

        // FIX 4: Use .value instead of .text — this preserves cursor at end
        // and prevents the "resets to position 0" bug that froze updates
        _inputController.value = TextEditingValue(
          text: words,
          selection: TextSelection.collapsed(offset: words.length),
        );
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
      cancelOnError: true,
      partialResults: true,
    );

    if (mounted) setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    if (mounted) setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateNotifier = ref.read(aiTrainerProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("Plan Workout"),
            actions: [
              IconButton(
                onPressed: _generateRandomSuggestions,
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text("What's the goal?", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _currentSuggestions.map((s) => ActionChip(
                      label: Text(s),
                      onPressed: () {
                        // FIX 5: Tapping a chip while mic is on should stop recording
                        if (_isListening) _stopListening();
                        final text = s.substring(2);
                        _lastSpeechValue = text;
                        _inputController.value = TextEditingValue(
                          text: text,
                          selection: TextSelection.collapsed(offset: text.length),
                        );
                      },
                      shape: const StadiumBorder(),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    )).toList(),
                  ),

                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _inputController,
                      maxLines: 4,
                      // FIX 6: Tapping into the field manually should stop recording
                      onTap: () { if (_isListening) _stopListening(); },
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? "Listening..."
                            : "Describe your workout...",
                        filled: true,
                        fillColor: _isListening
                            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                            : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            backgroundColor: !_speechEnabled
                                ? Colors.grey
                                : _isListening
                                ? Colors.red
                                : theme.primaryColor,
                            child: IconButton(
                              icon: Icon(
                                !_speechEnabled
                                    ? Icons.mic_off
                                    : _isListening
                                    ? Icons.stop
                                    : Icons.mic,
                                color: Colors.white,
                              ),
                              onPressed: !_speechEnabled
                                  ? null
                                  : _isListening
                                  ? _stopListening
                                  : _startListening,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // FIX 7: Stop mic if still running when user submits
                          if (_isListening) _stopListening();
                          ref.invalidate(aiTrainerProvider);
                          stateNotifier.generate(_inputController.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AiTrainingPlanViewer(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        "CREATE MY WORKOUT",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}