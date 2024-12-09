import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures plugin services are initialized
  runApp(const MyApp());
}

/// Represents each sound slot with recording status and file path.
class SoundSlot {
  bool isRecording;
  String? filePath;

  SoundSlot({this.isRecording = false, this.filePath});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soundboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Soundboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialize five sound slots.
  final List<SoundSlot> _soundSlots = List.generate(5, (_) => SoundSlot());

  // Record instance for handling audio recording.
  final Record _record = Record();

  // List of audio players corresponding to each sound slot.
  final List<AudioPlayer> _audioPlayers = List.generate(5, (_) => AudioPlayer());

  @override
  void dispose() {
    _record.dispose();
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  /// Generates a file path for storing recordings.
  Future<String> _getFilePath(int index) async {
    if (kIsWeb) {
      // On Web, 'record' returns a blob URL, so we don't need a file path.
      // Returning a unique identifier for each slot.
      return 'sound_$index';
    } else {
      // For Desktop, store recordings in the application's documents directory.
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/sound_$index.m4a';
    }
  }

  /// Starts recording audio for a specific slot.
  Future<void> _startRecording(int index) async {
    final filePath = await _getFilePath(index);
    try {
      await _record.start(
        path: kIsWeb ? null : filePath, // On Web, path is not required.
        encoder: AudioEncoder.aacLc, // High-quality AAC encoding.
        bitRate: 128000,
        samplingRate: 44100,
      );
      setState(() {
        _soundSlots[index].isRecording = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  /// Stops recording audio for a specific slot.
  Future<void> _stopRecording(int index) async {
    try {
      final path = await _record.stop();
      setState(() {
        _soundSlots[index].isRecording = false;
        _soundSlots[index].filePath = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }

  /// Plays the recorded audio for a specific slot.
  Future<void> _playSound(int index) async {
    final path = _soundSlots[index].filePath;
    if (path != null) {
      try {
        if (kIsWeb) {
          // On Web, play from the blob URL returned by 'record'.
          await _audioPlayers[index].setUrl(path);
          await _audioPlayers[index].play();
        } else {
          // On Desktop, play from the saved file path.
          if (File(path).existsSync()) {
            await _audioPlayers[index].setFilePath(path);
            await _audioPlayers[index].play();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No recording found for this slot')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing sound: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recording found for this slot')),
      );
    }
  }

  /// Builds the UI for each sound slot.
  Widget _buildSoundSlot(int index) {
    final slot = _soundSlots[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Sound Slot ${index + 1}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start/Stop Recording Button
                slot.isRecording
                    ? ElevatedButton.icon(
                        onPressed: () => _stopRecording(index),
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _startRecording(index),
                        icon: const Icon(Icons.fiber_manual_record),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                const SizedBox(width: 20),
                // Play Button
                ElevatedButton.icon(
                  onPressed: slot.filePath != null ? () => _playSound(index) : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the entire UI with all sound slots.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _soundSlots.length,
        itemBuilder: (context, index) {
          return _buildSoundSlot(index);
        },
      ),
    );
  }
}
