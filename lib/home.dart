import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 200,
                width: 200,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 50),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('Main Thread'),
                onPressed: () async {
                  final stopwatch = Stopwatch()..start();
                  double result = await doHeavyComputation();
                  stopwatch.stop();
                  final executionTimeInSeconds =
                      stopwatch.elapsedMilliseconds / 1000;
                  var snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                        "Result is: ${result.toString()}. ($executionTimeInSeconds s)"),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('Isolate'),
                onPressed: () async {
                  final stopwatch = Stopwatch()..start();

                  double result = await Isolate.run(() => doHeavyComputation());

                  stopwatch.stop();
                  final executionTimeInSeconds =
                      stopwatch.elapsedMilliseconds / 1000;

                  var snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                        "Result is: ${result.toString()}. ($executionTimeInSeconds s)"),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<double> doHeavyComputation() async {
  double result = 0.0;

  for (int i = 0; i < 1000000000; i++) {
    result += i;
  }
  return result;
}
