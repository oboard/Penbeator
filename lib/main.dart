import 'dart:async';
import 'dart:typed_data';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme defualtLightColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: Colors.blue.shade700,
    );
    ColorScheme defualtDarkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: Colors.blue.shade700,
    );
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Penbeator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme ?? defualtLightColorScheme,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme ?? defualtDarkColorScheme,
        ),
        home: const HomePage(),
      );
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool running = false;
  StreamSubscription<List<int>>? listener;

  void changeState() {
    setState(() {
      running = !running;
      if (running) {
        startMic();
      } else {
        stopMic();
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> startMic() async {
    // Init a new Stream
    Stream<Uint8List>? stream = await MicStream.microphone(sampleRate: 44100);

    // Start listening to the stream
    if (stream != null) {
      listener = stream.listen((samples) {
        final fft = FFT(samples.length);
        final freq = fft.realFft(samples.map((e) => e.toDouble()).toList());
        print(freq);
        print("freq");
      });
    }
  }

  void stopMic() {
    // Cancel the subscription
    listener?.cancel();
    print('stop');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penbeator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'running: $running',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: changeState,
        tooltip: 'change',
        child: Icon(running ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
