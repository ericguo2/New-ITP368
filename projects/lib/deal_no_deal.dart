import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DealOrNoDealApp());
}

class DealOrNoDealApp extends StatelessWidget {
  const DealOrNoDealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deal or No Deal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DealOrNoDealHomePage(title: 'Deal or No Deal'),
    );
  }
}

class DealOrNoDealHomePage extends StatefulWidget {
  const DealOrNoDealHomePage({super.key, required this.title});

  final String title;

  @override
  State<DealOrNoDealHomePage> createState() => _DealOrNoDealHomePageState();
}

class _DealOrNoDealHomePageState extends State<DealOrNoDealHomePage> {
  final List<int> _suitcaseValues = [
    1,
    5,
    10,
    100,
    1000,
    5000,
    10000,
    100000,
    500000,
    1000000
  ];
  late List<int> _suitcases;
  late List<bool> _openedSuitcases;
  int? _playerSuitcaseIndex;
  bool _offerAvailable = false;
  double _dealerOffer = 0;
  String _message = '';
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _suitcases = List<int>.from(_suitcaseValues)..shuffle();
    _openedSuitcases = List<bool>.filled(10, false);
    _playerSuitcaseIndex = null;
    _offerAvailable = false;
    _dealerOffer = 0;
    _message = 'Pick a suitcase to hold.';
    _gameOver = false;
  }

  void _pickPlayerSuitcase(int index) {
    setState(() {
      _playerSuitcaseIndex = index;
      _message =
          'You picked suitcase ${index + 1} to hold.\nNow pick a suitcase to open.';
    });
  }

  void _openSuitcase(int index) {
    if (_openedSuitcases[index] ||
        index == _playerSuitcaseIndex ||
        _offerAvailable ||
        _gameOver) {
      return;
    }
    setState(() {
      _openedSuitcases[index] = true;
      _message =
          'You opened suitcase ${index + 1} revealing \$${_suitcases[index]}.';

      // Check the number of unopened suitcases
      int unopenedSuitcases = 0;
      for (int i = 0; i < _openedSuitcases.length; i++) {
        if (!_openedSuitcases[i] && i != _playerSuitcaseIndex) {
          unopenedSuitcases++;
        }
      }

      if (unopenedSuitcases == 0) {
        _calculateFinalOffer();
        _offerAvailable = true;
      } else {
        _calculateDealerOffer();
        _offerAvailable = true;
      }
    });
  }

  void _calculateDealerOffer() {
    List<int> remainingValues = [];
    for (int i = 0; i < _suitcases.length; i++) {
      if (!_openedSuitcases[i] && i != _playerSuitcaseIndex) {
        remainingValues.add(_suitcases[i]);
      }
    }

    double expectedValue =
        remainingValues.reduce((a, b) => a + b) / remainingValues.length;
    _dealerOffer = expectedValue * 0.9;
    _message +=
        '\nDealer offers \$${_dealerOffer.toStringAsFixed(2)}.\nDeal or No Deal?';
  }

  void _calculateFinalOffer() {
    // Final offer based on the player's suitcase value
    int playerSuitcaseValue = _suitcases[_playerSuitcaseIndex!];
    _dealerOffer = playerSuitcaseValue * 0.9;
    _message +=
        '\nFinal Offer: Dealer offers \$${_dealerOffer.toStringAsFixed(2)} for your suitcase.\nDeal or No Deal?';
  }

  void _deal() {
    if (!_offerAvailable || _gameOver) return;
    setState(() {
      _message =
          'You accepted the deal!\nYou win \$${_dealerOffer.toStringAsFixed(2)}.';
      _gameOver = true;
      _openedSuitcases[_playerSuitcaseIndex!] = true;
    });
  }

  void _noDeal() {
    if (!_offerAvailable || _gameOver) return;
    setState(() {
      _offerAvailable = false;

      // Check the number of unopened suitcases
      int unopenedSuitcases = 0;
      for (int i = 0; i < _openedSuitcases.length; i++) {
        if (!_openedSuitcases[i] && i != _playerSuitcaseIndex) {
          unopenedSuitcases++;
        }
      }

      if (unopenedSuitcases == 0) {
        // No more suitcases left, reveal player's suitcase
        _revealPlayerSuitcase();
      } else {
        _message = 'Pick another suitcase to open.';
      }
    });
  }

  void _revealPlayerSuitcase() {
    int winnings = _suitcases[_playerSuitcaseIndex!];
    setState(() {
      _message =
          'No more suitcases left.\nYour suitcase contained \$${winnings}.\nYou win \$${winnings}!';
      _gameOver = true;
      _openedSuitcases[_playerSuitcaseIndex!] = true;
    });
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent && !_gameOver) {
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        _deal();
      } else if (event.logicalKey == LogicalKeyboardKey.keyN) {
        _noDeal();
      } else if (event.logicalKey.keyLabel != null) {
        int? index = int.tryParse(event.logicalKey.keyLabel!);
        if (index != null && index >= 1 && index <= 9) {
          if (_playerSuitcaseIndex == null) {
            _pickPlayerSuitcase(index - 1);
          } else {
            _openSuitcase(index - 1);
          }
        } else if (event.logicalKey == LogicalKeyboardKey.digit0) {
          if (_playerSuitcaseIndex == null) {
            _pickPlayerSuitcase(9);
          } else {
            _openSuitcase(9);
          }
        }
      }
    }
  }

  Widget _buildSuitcase(int index) {
    bool isOpened = _openedSuitcases[index];
    bool isPlayerSuitcase = index == _playerSuitcaseIndex;
    return GestureDetector(
      onTap: () {
        if (_playerSuitcaseIndex == null) {
          _pickPlayerSuitcase(index);
        } else {
          _openSuitcase(index);
        }
      },
      child: Container(
        width: 60, // Increased suitcase size
        height: 60,
        margin: const EdgeInsets.all(4), // Adjusted margin
        decoration: BoxDecoration(
          color: isOpened
              ? Colors.grey
              : isPlayerSuitcase
                  ? Colors.blue
                  : Colors.orange,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            isOpened ? '\$${_suitcases[index]}' : '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16, // Adjusted font size
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSuitcaseGrid() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0, // Adjusted spacing
      runSpacing: 8.0,
      children: List.generate(10, _buildSuitcase),
    );
  }

  Widget _buildDealButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _offerAvailable ? _deal : null,
          child: const Text('DEAL (D)'),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _offerAvailable ? _noDeal : null,
          child: const Text('NO DEAL (N)'),
        ),
      ],
    );
  }

  Widget _buildValueTable() {
    return Wrap(
      spacing: 8.0, // Adjusted spacing
      runSpacing: 4.0,
      alignment: WrapAlignment.center,
      children: _suitcaseValues
          .map((value) => Container(
                width: 100, // Adjusted to match larger size
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _isValueRemaining(value) ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '\$$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ))
          .toList(),
    );
  }

  bool _isValueRemaining(int value) {
    for (int i = 0; i < _suitcases.length; i++) {
      if (_suitcases[i] == value &&
          !_openedSuitcases[i] &&
          i != _playerSuitcaseIndex) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16), // Adjusted padding
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 100, // Fixed height for message area
                    alignment: Alignment.center,
                    child: Text(
                      _message,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                      maxLines: 4, // Limit to 4 lines
                      overflow: TextOverflow.ellipsis, // Truncate overflow text
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSuitcaseGrid(),
                  const SizedBox(height: 20),
                  _buildDealButtons(),
                  const SizedBox(height: 20),
                  const Text('Remaining Values:'),
                  const SizedBox(height: 10),
                  _buildValueTable(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _gameOver
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _initializeGame();
                  });
                },
                tooltip: 'Restart Game',
                child: const Icon(Icons.replay),
              )
            : null,
      ),
    );
  }
}
