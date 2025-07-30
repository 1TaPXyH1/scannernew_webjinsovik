import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/network_service.dart';
import '../screens/home.dart';
import '../screens/result.dart';

class ScanScreen extends StatefulWidget {
  final String selectedStore;
  const ScanScreen({super.key, required this.selectedStore});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = false;
  bool torchOn = false;

  bool _showSuccess = false;
  bool _hasError = false;
  String _errorMessage = '';

  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();

    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _borderAnimation = Tween<double>(begin: 2, end: 5).animate(
      CurvedAnimation(
        parent: _borderAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    controller.dispose();
    super.dispose();
  }

  void toggleTorch() {
    controller.toggleTorch();
    setState(() {
      torchOn = !torchOn;
    });
  }

  Future<void> _handleBarcode(Barcode barcode) async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      _hasError = false;
      _showSuccess = false;
    });

    final code = barcode.rawValue ?? '';
    final networkService = NetworkService();
    final isConnected = await networkService.isConnected();

    if (!mounted) return;

    if (!isConnected) {
      setState(() {
        _errorMessage = "Помилка інтернет з'єднання";
        _hasError = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _hasError = false;
        isScanning = false;
      });
      return;
    }

    if (!code.startsWith('210700')) {
      setState(() {
        _errorMessage = "Невірний штрихкод";
        _hasError = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _hasError = false;
        isScanning = false;
      });
      return;
    }

    setState(() {
      _showSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          barcode: code,
          selectedStore: widget.selectedStore,
          errorMessage: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize = MediaQuery.of(context).size.width * 0.8;

    return WillPopScope(
      onWillPop: () async => false,
      child: Semantics(
        label: 'Екран сканування',
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text('Сканер'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                ),
                tooltip: 'Закрити сканер',
              ),
            ],
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                controller: controller,
                onDetect: (capture) async {
                  if (capture.barcodes.isEmpty) return;
                  await _handleBarcode(capture.barcodes.first);
                },
              ),

              // Маска для затемнення поза зоною сканування
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: boxSize,
                          height: boxSize,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Зона сканування з анімованою рамкою
              AnimatedBuilder(
                animation: _borderAnimationController,
                builder: (context, child) {
                  return Center(
                    child: Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              _hasError ? Colors.redAccent : Colors.blueAccent,
                          width: _borderAnimation.value,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _hasError
                                ? Colors.redAccent.withOpacity(0.5)
                                : Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Підказка над зоною сканування
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Наведіть камеру на штрихкод у рамці',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: Colors.black54,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Повідомлення про успіх
              if (_showSuccess)
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showSuccess ? 1.0 : 0.0,
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'УСПІШНО СКАНОВАНО',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Повідомлення про помилку
              if (_hasError)
                Positioned(
                  bottom: 80,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _errorMessage.isEmpty
                          ? 'Помилка сканування'
                          : _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              // Нижня кнопка ліхтарика
              Positioned(
                bottom: 24,
                child: FloatingActionButton(
                  onPressed: toggleTorch,
                  tooltip:
                      torchOn ? 'Вимкнути фонарик' : 'Увімкнути фонарик',
                  backgroundColor:
                      torchOn ? Colors.blueAccent : Colors.grey[700],
                  child: Icon(torchOn ? Icons.flash_on : Icons.flash_off),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
