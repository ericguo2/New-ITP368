import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

TextStyle ts = const TextStyle(fontSize: 30);

class CounterState {
  int count;
  CounterState(this.count);
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(0));

  void inc() {
    emit(CounterState(state.count + 1));
  }
}

void main() {
  runApp(RoutesDemo());
}

class RoutesDemo extends StatelessWidget {
  RoutesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    String title = "Routes Demo";
    return MaterialApp(
      title: title,
      home: TopBloc(title: title),
    );
  }
}

class TopBloc extends StatelessWidget {
  final String title;
  TopBloc({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (context) => CounterCubit(),
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) => Route1(title: title),
      ),
    );
  }
}

// Route 1 (Page 1)
class Route1 extends StatelessWidget {
  final String title;
  Route1({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    CounterCubit cc = BlocProvider.of<CounterCubit>(context);
    return Scaffold(
      appBar: AppBar(title: Text(title, style: ts)),
      body: Column(
        children: [
          Text("Page 1", style: ts),
          Text("${cc.state.count}", style: ts),
          ElevatedButton(
            onPressed: () {
              cc.inc();
            },
            child: Text("Add 1", style: ts),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Route2(title: title, cc: cc),
                ),
              );
            },
            child: Text("Go to Page 2", style: ts),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Route3(title: title, cc: cc),
                ),
              );
            },
            child: Text("Go to Page 3", style: ts),
          ),
        ],
      ),
    );
  }
}

// Route 2 (Page 2)
class Route2 extends StatelessWidget {
  final String title;
  final CounterCubit cc;
  Route2({required this.title, required this.cc, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>.value(
      value: cc,
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(title, style: ts)),
            body: Column(
              children: [
                Text("Page 2", style: ts),
                Text("${cc.state.count}", style: ts),
                ElevatedButton(
                  onPressed: () {
                    cc.inc();
                  },
                  child: Text("Add 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to Page 1
                  },
                  child: Text("Go Back to Page 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Route3(title: title, cc: cc),
                      ),
                    );
                  },
                  child: Text("Go to Page 3", style: ts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Route 3 (Page 3)
class Route3 extends StatelessWidget {
  final String title;
  final CounterCubit cc;
  Route3({required this.title, required this.cc, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>.value(
      value: cc,
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(title, style: ts)),
            body: Column(
              children: [
                Text("Page 3", style: ts),
                Text("${cc.state.count}", style: ts),
                ElevatedButton(
                  onPressed: () {
                    cc.inc();
                  },
                  child: Text("Add 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Route2(title: title, cc: cc),
                      ),
                    );
                  },
                  child: Text("Go to Page 2", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to Page 1
                  },
                  child: Text("Go Back to Page 1", style: ts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
