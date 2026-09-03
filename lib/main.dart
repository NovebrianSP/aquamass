import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  runApp(const AquamassApp());
}

// ============================================================
// APP
// ============================================================

class AquamassApp extends StatelessWidget {
  const AquamassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aquamass',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: Brightness.light,
        ),
      ),
      home: const DuckHomeScreen(),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

class AppColors {
  static const Color green = Color(0xFF3EA446);
  static const Color teal = Color(0xFF1C5D5E);

  static const Color cream = Color(0xFFE1C38B);
  static const Color lightCream = Color(0xFFFFF4D8);

  static const Color coral = Color(0xFFB85C43);
  static const Color orange = Color(0xFFE68D37);

  static const Color yellow = Color(0xFFFFD84D);
  static const Color peach = Color(0xFFFFC98B);

  static const Color darkBrown = Color(0xFF5B3928);
  static const Color lightGreen = Color(0xFFDCEED3);
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ======================================================
    // BACKGROUND
    // ======================================================

    final backgroundPaint = Paint()
      ..color = Colors.white;

    canvas.drawRect(
      Offset.zero & size,
      backgroundPaint,
    );

    // ======================================================
    // GRID
    // ======================================================

    final gridPaint = Paint()
      ..color = const Color(0xFF3EA446).withOpacity(0.055)
      ..strokeWidth = 1;

    const double gridSize = 28;

    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // ======================================================
    // DECORATIVE CIRCLES
    // ======================================================

    // Circle kiri atas
    final circlePaint1 = Paint()
      ..color = AppColors.lightGreen.withOpacity(0.35);

    canvas.drawCircle(
      Offset(-30, 100),
      120,
      circlePaint1,
    );

    // Lingkaran outline kiri atas
    final outlinePaint1 = Paint()
      ..color = AppColors.green.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(70, 180),
      55,
      outlinePaint1,
    );

    // Circle kanan atas
    final circlePaint2 = Paint()
      ..color = AppColors.lightGreen.withOpacity(0.30);

    canvas.drawCircle(
      Offset(size.width + 35, 330),
      125,
      circlePaint2,
    );

    // Lingkaran outline kanan
    final outlinePaint2 = Paint()
      ..color = AppColors.green.withOpacity(0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(size.width - 40, 450),
      45,
      outlinePaint2,
    );

    // Circle kiri bawah
    final circlePaint3 = Paint()
      ..color = AppColors.peach.withOpacity(0.12);

    canvas.drawCircle(
      Offset(-40, size.height - 180),
      140,
      circlePaint3,
    );

    // Circle kanan bawah
    final circlePaint4 = Paint()
      ..color = AppColors.lightGreen.withOpacity(0.25);

    canvas.drawCircle(
      Offset(size.width + 30, size.height - 100),
      150,
      circlePaint4,
    );

    // Lingkaran kecil
    final smallCirclePaint = Paint()
      ..color = AppColors.yellow.withOpacity(0.15);

    canvas.drawCircle(
      Offset(size.width - 60, 120),
      22,
      smallCirclePaint,
    );

    canvas.drawCircle(
      Offset(50, size.height - 450),
      20,
      smallCirclePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class DuckHomeScreen extends StatefulWidget {
  const DuckHomeScreen({super.key});

  @override
  State<DuckHomeScreen> createState() =>
      _DuckHomeScreenState();
}

class _DuckHomeScreenState extends State<DuckHomeScreen>
    with WidgetsBindingObserver {
  // ----------------------------------------------------------
  // BASIC DATA
  // ----------------------------------------------------------

  double _weight = 60.0;

  int _waterIntake = 0;

  String _duckMessage =
      'Halo! Yuk jaga hidrasi hari ini! 🦆💧';

  // ----------------------------------------------------------
  // DRINK TARGET
  // ----------------------------------------------------------

  int _drinkCount = 0;

  int _drinkTarget = 8;

  // ----------------------------------------------------------
  // MONTHLY HISTORY
  // ----------------------------------------------------------

  final Map<String, int> _monthlyHistory = {};

  bool _isLoadingData = true;

  // ----------------------------------------------------------
  // SHARED PREFERENCES KEYS
  // ----------------------------------------------------------

  static const String _weightKey = 'weight';

  static const String _waterIntakeKey = 'water_intake';

  static const String _drinkCountKey = 'drink_count';

  static const String _drinkTargetKey = 'drink_target';

  static const String _todayKeyStorage = 'today_key';

  static const String _monthlyHistoryKey =
      'monthly_history';

  // ==========================================================
  // GETTERS
  // ==========================================================

  int get _waterTarget {
    return (_weight * 35).round();
  }

  double get _progress {
    if (_waterTarget <= 0) {
      return 0;
    }

    final value = _waterIntake / _waterTarget;

    if (value > 1) {
      return 1;
    }

    return value;
  }

  String get _todayKey {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String get _currentMonthKey {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}';
  }

  int get _daysInCurrentMonth {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month + 1,
      0,
    ).day;
  }

  /// Target air untuk 1 bulan.
  int get _monthlyTarget {
    return _waterTarget * _daysInCurrentMonth;
  }

  /// Total air yang sudah diminum pada bulan ini.
  int get _monthlyIntake {
    int total = 0;

    for (final entry in _monthlyHistory.entries) {
      if (entry.key.startsWith(_currentMonthKey)) {
        total += entry.value;
      }
    }

    return total;
  }

  /// Jumlah hari yang mencapai target air.
  int get _daysAchieved {
    int total = 0;

    for (final entry in _monthlyHistory.entries) {
      if (!entry.key.startsWith(_currentMonthKey)) {
        continue;
      }

      if (entry.value >= _waterTarget) {
        total++;
      }
    }

    return total;
  }

  double get _monthlyProgress {
    if (_monthlyTarget <= 0) {
      return 0;
    }

    final value =
        _monthlyIntake / _monthlyTarget;

    return value > 1 ? 1 : value;
  }

  int get _remainingDrinkTarget {
    final remaining =
        _drinkTarget - _drinkCount;

    return remaining < 0 ? 0 : remaining;
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // ==========================================================
  // APP LIFECYCLE
  // ==========================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state == AppLifecycleState.resumed) {
      _checkNewDay();
    }
  }

  // ==========================================================
  // LOAD DATA
  // ==========================================================

  Future<void> _loadData() async {
    final prefs =
    await SharedPreferences.getInstance();

    final savedWeight =
    prefs.getDouble(_weightKey);

    final savedWater =
    prefs.getInt(_waterIntakeKey);

    final savedDrinkCount =
    prefs.getInt(_drinkCountKey);

    final savedDrinkTarget =
    prefs.getInt(_drinkTargetKey);

    final savedToday =
    prefs.getString(_todayKeyStorage);

    final savedHistory =
    prefs.getStringList(_monthlyHistoryKey);

    if (!mounted) {
      return;
    }

    setState(() {
      if (savedWeight != null) {
        _weight = savedWeight;
      }

      if (savedDrinkTarget != null) {
        _drinkTarget =
            savedDrinkTarget.clamp(1, 20);
      }

      // Restore history.
      _monthlyHistory.clear();

      if (savedHistory != null) {
        for (final item in savedHistory) {
          final parts = item.split('|');

          if (parts.length != 2) {
            continue;
          }

          final date = parts[0];

          final amount =
          int.tryParse(parts[1]);

          if (amount != null) {
            _monthlyHistory[date] = amount;
          }
        }
      }

      // Jika tanggal sama, restore data hari ini.
      if (savedToday == _todayKey) {
        _waterIntake =
            savedWater ?? 0;

        _drinkCount =
            savedDrinkCount ?? 0;
      } else {
        // Hari baru.
        _waterIntake = 0;
        _drinkCount = 0;
      }

      // Pastikan history hari ini sinkron.
      _monthlyHistory[_todayKey] =
          _waterIntake;

      _isLoadingData = false;
    });

    await _saveData();

    await _scheduleNotifications();
  }

  // ==========================================================
  // CHECK NEW DAY
  // ==========================================================

  Future<void> _checkNewDay() async {
    final prefs =
    await SharedPreferences.getInstance();

    final savedToday =
    prefs.getString(_todayKeyStorage);

    if (savedToday == _todayKey) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _waterIntake = 0;
      _drinkCount = 0;

      _duckMessage =
      'Hari baru! Yuk mulai hidrasi lagi 🦆💧';

      _monthlyHistory[_todayKey] = 0;
    });

    await _saveData();

    await _scheduleNotifications();
  }

  // ==========================================================
  // SAVE DATA
  // ==========================================================

  Future<void> _saveData() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setDouble(
      _weightKey,
      _weight,
    );

    await prefs.setInt(
      _waterIntakeKey,
      _waterIntake,
    );

    await prefs.setInt(
      _drinkCountKey,
      _drinkCount,
    );

    await prefs.setInt(
      _drinkTargetKey,
      _drinkTarget,
    );

    await prefs.setString(
      _todayKeyStorage,
      _todayKey,
    );

    _monthlyHistory[_todayKey] =
        _waterIntake;

    final historyList =
    _monthlyHistory.entries.map(
          (entry) => '${entry.key}|${entry.value}',
    ).toList();

    await prefs.setStringList(
      _monthlyHistoryKey,
      historyList,
    );
  }

  // ==========================================================
  // NOTIFICATION
  // ==========================================================

  Future<void> _scheduleNotifications() async {
    await NotificationService.instance
        .scheduleDailyReminders(
      targetDrinks: _drinkTarget,
      currentDrinkCount: _drinkCount,
    );
  }

  // ==========================================================
  // ADD WATER
  // ==========================================================

  Future<void> _addWater(int amount) async {
    if (_isLoadingData) {
      return;
    }

    // Tambahkan volume air.
    setState(() {
      _waterIntake += amount;

      // Setiap tombol minum dianggap 1 sesi.
      _drinkCount++;

      if (_drinkCount >= _drinkTarget) {
        _duckMessage =
        'Yeay! Target minum hari ini tercapai! 🦆🎉';
      } else if (_progress >= 1) {
        _duckMessage =
        'Target air putih tercapai! Tetap minum secukupnya 💧';
      } else {
        _duckMessage =
        'Mantap! Satu tegukan lagi menuju target! 💧🦆';
      }

      _monthlyHistory[_todayKey] =
          _waterIntake;
    });

    await _saveData();

    // Schedule ulang.
    //
    // Jika target belum tercapai:
    // sisa reminder tetap aktif.
    //
    // Jika target sudah tercapai:
    // semua reminder hari ini dan yang tersisa
    // akan dibatalkan oleh scheduleDailyReminders()
    // karena currentDrinkCount >= target.
    await _scheduleNotifications();
  }

  // ==========================================================
  // RESET
  // ==========================================================

  Future<void> _resetWater() async {
    setState(() {
      _waterIntake = 0;
      _drinkCount = 0;

      _duckMessage =
      'Reset! Kita mulai lagi dari awal 💧🦆';

      _monthlyHistory[_todayKey] = 0;
    });

    await _saveData();

    await _scheduleNotifications();
  }

  // ==========================================================
  // WEIGHT
  // ==========================================================

  Future<void> _changeWeight(double value) async {
    setState(() {
      _weight = value;
    });

    await _saveData();

    // Karena target air berubah,
    // progress bulanan juga berubah.
  }

  Future<void> _showManualWeightDialog() async {
    final controller = TextEditingController(
      text: _weight.toStringAsFixed(0),
    );

    try {
      final result = await showDialog<double>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.lightCream,

            title: const Text(
              'Masukkan Berat Badan',
              style: TextStyle(
                color: AppColors.darkBrown,
                fontWeight: FontWeight.w900,
              ),
            ),

            content: TextField(
              controller: controller,
              autofocus: true,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: InputDecoration(
                suffixText: 'kg',
                hintText: 'Contoh: 60',
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),

              onSubmitted: (value) {
                final weight = double.tryParse(
                  value.replaceAll(',', '.'),
                );

                if (weight != null &&
                    weight >= 30 &&
                    weight <= 120) {
                  Navigator.of(dialogContext).pop(weight);
                }
              },
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Batal'),
              ),

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                ),

                onPressed: () {
                  final value = double.tryParse(
                    controller.text.replaceAll(',', '.'),
                  );

                  if (value == null ||
                      value < 30 ||
                      value > 120) {
                    return;
                  }

                  Navigator.of(dialogContext).pop(value);
                },

                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );

      if (result != null && mounted) {
        await _changeWeight(result);
      }
    } finally {
      controller.dispose();
    }
  }

  // ==========================================================
  // DRINK TARGET
  // ==========================================================

  Future<void> _changeDrinkTarget(
      int value,
      ) async {
    if (value < 1 || value > 20) {
      return;
    }

    setState(() {
      _drinkTarget = value;

      if (_drinkCount >= _drinkTarget) {
        _duckMessage =
        'Target baru sudah tercapai hari ini! 🎉';
      } else {
        _duckMessage =
        'Target minum diubah menjadi $_drinkTarget kali.';
      }
    });

    await _saveData();

    await _scheduleNotifications();
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.green,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [

          // ==================================================
          // BACKGROUND GRID + DECORATION
          // ==================================================

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: GridBackgroundPainter(),
              ),
            ),
          ),

          // ==================================================
          // MAIN CONTENT
          // ==================================================

          SafeArea(
            child: CustomScrollView(
              slivers: [

                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    30,
                  ),

                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [

                        _buildDuckMessageCard(),

                        const SizedBox(height: 16),

                        _buildWeightCard(),

                        const SizedBox(height: 16),

                        _buildDrinkTargetCard(),

                        const SizedBox(height: 16),

                        _buildWaterProgressCard(),

                        const SizedBox(height: 16),

                        _buildMonthlyCard(),

                        const SizedBox(height: 16),

                        _buildDrinkButtons(),

                        const SizedBox(height: 20),

                        _buildInfoCard(),

                        const SizedBox(height: 16),

                        _buildNotificationTestButton()

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius:
              BorderRadius.circular(17),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(17),
              child: Image.asset(
                'assets/bebek_profil.png',
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) {
                  return const Text(
                    '🦆',
                    style: TextStyle(
                      fontSize: 29,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'AQUAMASS',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.lightCream,
                  ),
                ),
                Text(
                  'Duck Hydration',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightCream
                        .withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          Material(
            color: AppColors.lightCream,
            borderRadius:
            BorderRadius.circular(15),
            child: InkWell(
              borderRadius:
              BorderRadius.circular(15),
              onTap: _resetWater,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.green,
                  size: 23,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DUCK MESSAGE
  // ==========================================================

  Widget _buildDuckMessageCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius:
        BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.green
              .withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          _buildDuckMascot(),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Duck says:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.coral,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _duckMessage,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DUCK MASCOT
  // ==========================================================

  Widget _buildDuckMascot() {
    return SizedBox(
      width: 90,
      height: 105,
      child: Image.asset(
        'assets/bebek_nobg.png',
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) {
          return const Center(
            child: Text(
              '🦆',
              style: TextStyle(
                fontSize: 65,
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // WEIGHT CARD
  // ==========================================================

  Widget _buildWeightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius:
        BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Berat badan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),

              GestureDetector(
                onTap:
                _showManualWeightDialog,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                          FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                _weight.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.teal,
                ),
              ),
              const Padding(
                padding:
                EdgeInsets.only(bottom: 7),
                child: Text(
                  ' kg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
            ],
          ),

          Slider(
            value: _weight,
            min: 30,
            max: 120,
            divisions: 90,
            activeColor: AppColors.green,
            inactiveColor:
            AppColors.green
                .withValues(alpha: 0.20),
            onChanged: (value) {
              setState(() {
                _weight = value;
              });
            },
            onChangeEnd:
            _changeWeight,
          ),

          const SizedBox(height: 3),

          Text(
            'Target air putih: $_waterTarget ml / hari',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DRINK TARGET CARD
  // ==========================================================

  Widget _buildDrinkTargetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius:
        BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Target minum per hari',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Atur berapa kali kamu ingin minum dalam sehari.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBrown
                  .withValues(alpha: 0.65),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _buildRoundButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  _changeDrinkTarget(
                    _drinkTarget - 1,
                  );
                },
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$_drinkTarget kali',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '$_drinkCount / $_drinkTarget tercapai',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ),
              ),

              _buildRoundButton(
                icon: Icons.add_rounded,
                onTap: () {
                  _changeDrinkTarget(
                    _drinkTarget + 1,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value:
              _drinkTarget <= 0
                  ? 0
                  : (_drinkCount /
                  _drinkTarget)
                  .clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor:
              AppColors.green
                  .withValues(alpha: 0.12),
              valueColor:
              const AlwaysStoppedAnimation(
                AppColors.green,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                size: 17,
                color: AppColors.orange,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  _drinkCount >= _drinkTarget
                      ? 'Semua reminder hari ini sudah dihentikan 🎉'
                      : 'Reminder aktif • $_remainingDrinkTarget kali lagi',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.yellow,
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: AppColors.darkBrown,
            size: 25,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // WATER PROGRESS
  // ==========================================================

  Widget _buildWaterProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius:
        BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hidrasi hari ini',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.lightCream,
              ),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: 175,
            height: 175,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 175,
                  height: 175,
                  child:
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 15,
                    backgroundColor:
                    Colors.white
                        .withValues(alpha: 0.12),
                    valueColor:
                    const AlwaysStoppedAnimation(
                      AppColors.yellow,
                    ),
                  ),
                ),

                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(_progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight:
                        FontWeight.w900,
                        color: AppColors.yellow,
                      ),
                    ),

                    Text(
                      '$_waterIntake / $_waterTarget ml',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        AppColors.lightCream,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.10),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_drink_rounded,
                  color: AppColors.yellow,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Sudah minum $_drinkCount kali hari ini',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color:
                      AppColors.lightCream,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MONTHLY CARD
  // ==========================================================

  Widget _buildMonthlyCard() {
    final average =
        _monthlyIntake /
            _daysInCurrentMonth;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius:
        BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.green,
                size: 24,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Kalkulasi bulan ini',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),

              Text(
                '${DateTime.now().month}/${DateTime.now().year}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coral,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildMonthlyRow(
            'Target bulanan',
            '${_monthlyTarget} ml',
            Icons.flag_rounded,
          ),

          const SizedBox(height: 10),

          _buildMonthlyRow(
            'Sudah diminum',
            '${_monthlyIntake} ml',
            Icons.water_drop_rounded,
          ),

          const SizedBox(height: 10),

          _buildMonthlyRow(
            'Rata-rata / hari',
            '${average.round()} ml',
            Icons.trending_up_rounded,
          ),

          const SizedBox(height: 10),

          _buildMonthlyRow(
            'Hari mencapai target',
            '$_daysAchieved / $_daysInCurrentMonth hari',
            Icons.emoji_events_rounded,
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _monthlyProgress,
              minHeight: 12,
              backgroundColor:
              AppColors.green
                  .withValues(alpha: 0.13),
              valueColor:
              const AlwaysStoppedAnimation(
                AppColors.green,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${(_monthlyProgress * 100).round()}% target bulan ini',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRow(
      String title,
      String value,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.yellow
                .withValues(alpha: 0.65),
            borderRadius:
            BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.darkBrown,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrown,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.green,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DRINK BUTTONS
  // ==========================================================

  Widget _buildDrinkButtons() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambah air putih',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBrown,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Setiap tombol dihitung sebagai 1 kali minum.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBrown,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildWaterButton(
                amount: 250,
                label: 'Small',
                icon: Icons.water_drop_outlined,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildWaterButton(
                amount: 600,
                label: 'Medium',
                icon: Icons.water_drop_rounded,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildWaterButton(
                amount: 1000,
                label: 'Large',
                icon:
                Icons.local_drink_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterButton({
    required int amount,
    required String label,
    required IconData icon,
  }) {
    return Material(
      color: AppColors.yellow,
      borderRadius:
      BorderRadius.circular(20),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(20),
        onTap: () => _addWater(amount),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 7,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.teal,
                size: 27,
              ),

              const SizedBox(height: 7),

              Text(
                '+$amount ml',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkBrown,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown
                      .withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INFO
  // ==========================================================

  Widget _buildNotificationTestButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await NotificationService.instance
                .showTestNotification();

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Notifikasi test dijadwalkan. Cek HP dalam 5 detik 💧🦆',
                ),
              ),
            );
          },
          icon: const Icon(Icons.notifications_active),
          label: const Text(
            'TEST NOTIFIKASI',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius:
        BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            '💡',
            style: TextStyle(
              fontSize: 25,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Target air putih dihitung berdasarkan berat badan '
                  'dengan rumus 35 ml/kg. Target jumlah minum '
                  'digunakan untuk menentukan reminder harian.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}