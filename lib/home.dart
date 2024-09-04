import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:worker_manager/worker_manager.dart';

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
              const SizedBox(height: 150),

              const SizedBox(
                height: 150,
                width: 150,
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
                    backgroundColor: Colors.blue,
                    content: Text(
                        "Result is: ${result.toString()}. ($executionTimeInSeconds s)"),
                  );

                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(snackBar);
                },
              ),
              Expanded(
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    MaterialButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      child: const Text('Compute'),
                      onPressed: () async {
                        final stopwatch = Stopwatch()..start();
                        double result = await compute(computeHeavyTask, 0);
                
                        stopwatch.stop();
                        final executionTimeInSeconds =
                            stopwatch.elapsedMilliseconds / 1000;
                        var snackBar = SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                              "Result is: ${result.toString()}. ($executionTimeInSeconds s)"),
                        );

                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      },
                    ),
                    MaterialButton(
                      color: Colors.deepPurple.shade500,
                      textColor: Colors.white,
                      child: const Text('Isolate.run()'),
                      onPressed: () async {
                        final stopwatch = Stopwatch()..start();
                
                        double result = await Isolate.run(() => doHeavyComputation());
                
                        stopwatch.stop();
                        final executionTimeInSeconds =
                            stopwatch.elapsedMilliseconds / 1000;
                
                        var snackBar = SnackBar(
                          backgroundColor: Colors.deepPurple.shade500,
                          content: Text(
                              "Result is: ${result.toString()}. ($executionTimeInSeconds s)"),
                        );

                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      },
                    ),
                    MaterialButton(
                      color: Colors.deepOrangeAccent,
                      textColor: Colors.white,
                      child: const Text('Isolate.spawn()'),
                      onPressed: () async {
                        final stopwatch = Stopwatch()..start();
                
                        final receivePort = ReceivePort();
                
                        try {
                          await Isolate.spawn(
                              doAnotherHeavyComputation, receivePort.sendPort);
                
                          // Using first to auto-close the ReceivePort after receiving the first message
                          final message = await receivePort.first;
                
                          stopwatch.stop();
                          final executionTimeInSeconds =
                              stopwatch.elapsedMilliseconds / 1000;
                
                          var snackBar = SnackBar(
                            backgroundColor: Colors.deepOrangeAccent,
                            content: Text(
                              "Result is: ${message.toString()}. ($executionTimeInSeconds s)",
                            ),
                          );

                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(snackBar);
                        } catch (error) {
                          var snackBar = SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("An error occurred: $error"),
                          );
                
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } finally {
                          receivePort.close();
                        }
                      },
                    ),
                    MaterialButton(
                      color: Colors.deepPurpleAccent,
                      textColor: Colors.white,
                      child: const Text('Work Manager'),
                      onPressed: () async {
                        final stopwatch = Stopwatch()..start();
                        workerManager.execute(()=>computeHeavyTask(1)).then((value){
                            stopwatch.stop();
                            final executionTimeInSeconds =
                            stopwatch.elapsedMilliseconds / 1000;

                            var snackBar = SnackBar(
                          backgroundColor: Colors.deepPurpleAccent,
                          content: Text(
                            "Result is: ${value.toString()}. ($executionTimeInSeconds s)",
                          ),
                        );

                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(snackBar);

                        });
                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

double computeHeavyTask(int startingPoint) {
  double result = 0.0;

  for (int i = startingPoint; i < 1000000000; i++) {
    result += i;
  }
  return result;
}

Future<double> doHeavyComputation() async {
  double result = 0.0;

  for (int i = 0; i < 1000000000; i++) {
    result += i;
  }
  return result;
}

void doAnotherHeavyComputation(SendPort sendPort) async {
  double result = 0.0;

  for (int i = 0; i < 1000000000; i++) {
    result += i;
  }
  Isolate.exit(sendPort, result);
  // sendPort.send(result);
}
