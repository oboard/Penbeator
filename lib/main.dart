import 'dart:async';
import 'dart:typed_data';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tiny_charts/tiny_charts.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

const double blockSize = 32;

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
  List<Vector2> dataPoints = [];
  List<int> beatList = [];
  int dataPointsIndex = 0;

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
    Stream<Uint8List>? stream = await MicStream.microphone(sampleRate: 10000);

    // Start listening to the stream
    if (stream != null) {
      listener = stream.listen((samples) {
        // dataPoints.clear();
        // for (int i = 0; i < samples.length; i++) {
        //   dataPoints.add(Vector2(i / 1792 * 100, samples[i] / 10));
        //   // print(samples[i]);
        // }
        // if (dataPoints.length > 200) {
        //   dataPoints.removeAt(0);
        // }
        // dataPoints.addAll(freq.map((e) => Vector2(e.x * 100, e.y * 100)));
        // print(samples);
        int beat = getBeat(samples);
        beatList.add(beat);
        setState(() {});
      });
    }
  }

  int getBeat(Uint8List samples) {
    List<int> counter =
        List<int>.generate(256, (int index) => 0, growable: true);
    int max = 0;
    int min = 1000;

    for (var e in samples) {
      if (max < e) max = e;
      if (min > e) min = e;
      counter[e]++;
    }

    double count = 0;
    for (var e in samples) {
      count += e - 128;
    }
    count = count.abs();
    print('$count');
    if (dataPoints.length < 100) {
      dataPoints.add(Vector2(dataPointsIndex.toDouble(), count));
    } else {
      dataPoints[dataPointsIndex] = Vector2(dataPointsIndex.toDouble(), count);
    }
    dataPointsIndex = (dataPointsIndex + 1) % 100;

    if (count > 200) return 0;

    if (max > 130) {
      if (count > 100) {
        return 1;
      } else {
        return 2;
      }
    } else {
      return 0;
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
            TinyLineChart.fromDataVectors(
              width: 100,
              height: 100,
              dataPoints: dataPoints,
              options: const TinyLineChartOptions(
                color: Colors.black,
                lineWidth: 1,
              ),
            ),
            Row(
              children: [
                for (int beat in (beatList.length <
                        MediaQuery.of(context).size.width ~/ blockSize)
                    ? beatList
                    : beatList.sublist(
                        beatList.length -
                            MediaQuery.of(context).size.width ~/ blockSize,
                        beatList.length))
                  () {
                    switch (beat) {
                      case 1:
                        return Container(
                          color: Colors.red,
                          width: blockSize,
                          height: blockSize,
                        );
                      case 2:
                        return Container(
                          color: Colors.blue,
                          width: blockSize,
                          height: blockSize,
                        );
                    }
                    return Container(
                      color: Colors.black,
                      width: blockSize,
                      height: blockSize,
                    );
                  }()
              ],
            )
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
