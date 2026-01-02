import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';

class MemoryMatchGame extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(bool) onGameComplete;
  final String? nextGameId; // Added to know what game comes next

  const MemoryMatchGame({
    super.key,
    required this.config,
    required this.onGameComplete,
    this.nextGameId,
  });

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> with TickerProviderStateMixin {
  List<MemoryCard> _cards = [];
  MemoryCard? _firstCard;
  MemoryCard? _secondCard;
  int _matchesFound = 0;
  int _moves = 0;
  int _timeLeft = 60;
  bool _gameOver = false;
  bool _gameWon = false;
  Timer? _timer;
  final Random _random = Random();
  bool _canFlip = true;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.config['timeLimit'] ?? 90;
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 0) {
        timer.cancel();
        _endGame(false);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _initializeGame() {
    _cards.clear();
    List<dynamic> pairs = widget.config['pairs'] ?? [];

    // Create card pairs
    for (var pair in pairs) {
      String suspect = pair['suspect'];
      String alibi = pair['alibi'];

      _cards.add(MemoryCard(
        id: 's_$suspect',
        type: 'suspect',
        matchId: suspect,
        suspectName: suspect,
        imagePath: AppImages.getMemoryCardImageByType('suspect', suspect),
      ));

      _cards.add(MemoryCard(
        id: 'a_$suspect',
        type: 'alibi',
        matchId: suspect,
        suspectName: suspect,
        alibiText: alibi,
        imagePath: AppImages.getMemoryCardImageByType('alibi', suspect),
      ));
    }

    // Shuffle cards
    _cards.shuffle(_random);
  }

  void _onCardTap(int index) {
    if (_gameOver || !_canFlip || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;

      if (_firstCard == null) {
        _firstCard = _cards[index];
      } else {
        _secondCard = _cards[index];
        _moves++;
        _canFlip = false;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    if (_firstCard!.matchId == _secondCard!.matchId) {
      _firstCard!.isMatched = true;
      _secondCard!.isMatched = true;
      _matchesFound++;

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _firstCard = null;
          _secondCard = null;
          _canFlip = true;
          if (_matchesFound == (_cards.length / 2)) {
            _gameWon = true;
            _endGame(true);
          }
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          int idx1 = _cards.indexOf(_firstCard!);
          int idx2 = _cards.indexOf(_secondCard!);

          _cards[idx1].isFlipped = false;
          _cards[idx2].isFlipped = false;

          _firstCard = null;
          _secondCard = null;
          _canFlip = true;
        });
      });
    }
  }

  void _endGame(bool success) {
    _timer?.cancel();
    setState(() => _gameOver = true);

    String nextAction = "CONTINUE INVESTIGATION";

    // Determine next action based on nextGameId
    if (widget.nextGameId != null) {
      if (widget.nextGameId == 'suspect_selection_case1') {
        nextAction = "MAKE FINAL ACCUSATION";
      } else if (widget.nextGameId == 'safe_game') {
        nextAction = "CRACK THE SAFE";
      }
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: success ? Colors.green : Colors.red, width: 3),
          ),
          title: Text(
            success ? "🎉 PUZZLE SOLVED!" : "⏰ TIME'S UP",
            style: TextStyle(
              color: success ? Colors.greenAccent : Colors.redAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            success
                ? "You matched all alibis in $_moves moves!\n\nHenry's alibi doesn't match with James. He's lying!"
                : "The trail went cold. Try again to find the inconsistencies.",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onGameComplete(success);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.green : Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  nextAction,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGameStats() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.neonBlue, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "TIME",
                style: TextStyle(
                  color: AppColors.neonRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _timeLeft.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "MATCHES",
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$_matchesFound/${_cards.length ~/ 2}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "MOVES",
                style: TextStyle(
                  color: AppColors.neonOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _moves.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: card.isMatched
                ? Colors.green
                : card.isFlipped
                ? AppColors.neonRed
                : AppColors.neonBlue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: card.isMatched
                  ? Colors.green.withOpacity(0.5)
                  : card.isFlipped
                  ? AppColors.neonRed.withOpacity(0.5)
                  : AppColors.neonBlue.withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Back of card
              if (!card.isFlipped)
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.cardBack),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.neonBlue.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.question_mark,
                        color: AppColors.neonBlue,
                        size: 40,
                      ),
                    ),
                  ),
                ),

              // Front of card
              if (card.isFlipped || card.isMatched)
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(card.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.type == 'suspect' ? 'SUSPECT' : 'ALIBI',
                            style: TextStyle(
                              color: card.type == 'suspect' ? AppColors.neonRed : AppColors.neonBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            card.type == 'suspect'
                                ? card.suspectName.split(' ').first.toUpperCase()
                                : (card.alibiText?.toUpperCase() ?? 'ALIBI'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (card.isMatched)
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, color: Colors.greenAccent, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'MATCHED',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate optimal grid layout based on screen size
    int crossAxisCount = 3; // Default 3 columns
    double cardAspectRatio = 0.75; // Wider cards (4:3 ratio)

    if (screenWidth > 600) {
      crossAxisCount = 4; // Tablets get 4 columns
      cardAspectRatio = 0.7;
    }

    if (screenHeight < 600) {
      cardAspectRatio = 0.65; // Shorter screens
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.9),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: AppColors.neonRed),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALIBI MATCH PUZZLE',
                          style: TextStyle(
                            color: AppColors.neonRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Match each suspect with their alibi',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            _buildGameStats(),

            // Instructions
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neonOrange),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.neonOrange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'FIND THE LIAR',
                        style: TextStyle(
                          color: AppColors.neonOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Flip cards to match each suspect with their correct alibi. Find the broken alibi!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Game Grid
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8),
                child: GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: cardAspectRatio,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) => _buildCard(index),
                ),
              ),
            ),

            // Bottom Info
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.black.withOpacity(0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'PAIRS FOUND',
                        style: TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '$_matchesFound/4',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'TIME LEFT',
                        style: TextStyle(
                          color: AppColors.neonRed,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '$_timeLeft sec',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'MOVES',
                        style: TextStyle(
                          color: AppColors.neonOrange,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '$_moves',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryCard {
  final String id;
  final String type;
  final String matchId;
  final String suspectName;
  final String? alibiText;
  final String imagePath;
  bool isFlipped = false;
  bool isMatched = false;

  MemoryCard({
    required this.id,
    required this.type,
    required this.matchId,
    required this.suspectName,
    this.alibiText,
    required this.imagePath,
  });
}