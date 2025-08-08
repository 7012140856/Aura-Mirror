import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Mirror',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7F5AF0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MirrorPage(),
    );
  }
}

class MirrorPage extends StatefulWidget {
  const MirrorPage({super.key});
  @override
  State<MirrorPage> createState() => _MirrorPageState();
}

class _MirrorPageState extends State<MirrorPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraReady = false;
  String _currentCompliment = "";
  bool _showCompliment = true;
  Timer? _complimentTimer;
  final List<String> _compliments = [
    "AURA 1000000+++",
    "നിങ്ങൾ അതിമനോഹരനാണ്/അതിമനോഹരിയാണ്!",
    "ഇന്ന് നിങ്ങൾ തിളങ്ങുന്നു!",
    "നിങ്ങളുടെ പുഞ്ചിരി ഒരു മുറിയെ പ്രകാശിപ്പിക്കും!",
    "നിങ്ങൾക്ക് അസാധാരണമായ ആത്മവിശ്വാസമുണ്ട്!",
    "നിങ്ങളുടെ സാന്നിധ്യം സന്തോഷം നൽകുന്നു!",
    "നിങ്ങളുടെ പ്രതിഭ തിളങ്ങുന്നു!",
    "നിങ്ങൾ അതിശയിപ്പിക്കുന്ന ഒരു വ്യക്തിയാണ്!",
    "നിങ്ങളുടെ സൗന്ദര്യം അന്തർമുഖമാണ്!",
    "നിങ്ങളുടെ ആത്മാർത്ഥത അഭിനന്ദനീയമാണ്!",
    "നിങ്ങൾ ഒരു അത്ഭുതകരമായ വ്യക്തിയാണ്!",
    "നിങ്ങളുടെ ഊർജ്ജം അനുഗ്രഹിക്കപ്പെട്ടതാണ്!",
    "നിങ്ങൾ ഒരു പ്രത്യേക വ്യക്തിയാണ്!",
    "നിങ്ങളുടെ മനസ്സ് വിശുദ്ധമാണ്!",
    "നിങ്ങളുടെ സ്വഭാവം മനോഹരമാണ്!",
    "നിങ്ങൾ ഒരു പ്രചോദനമാണ്!",
    "നിങ്ങളുടെ ഉത്സാഹം അടിപൊളിയാണ്!",
    "നിങ്ങളുടെ ആത്മവിശ്വാസം അതിശയിപ്പിക്കുന്നു!",
    "നിങ്ങളുടെ സൗഹൃദം ആഹ്ലാദകരമാണ്!",
    "നിങ്ങളുടെ ധൈര്യം അഭിനന്ദനീയമാണ്!",
    "നിങ്ങൾ ഒരു യഥാർത്ഥ ചാമ്പ്യനാണ്!"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentCompliment = _compliments.first;
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _stopComplimentTimer();
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  void _getNextCompliment() {
    final currentIndex = _compliments.indexOf(_currentCompliment);
    final nextIndex = (currentIndex + 1) % _compliments.length;
    setState(() {
      _currentCompliment = _compliments[nextIndex];
    });
  }

  void _startComplimentTimer() {
    _stopComplimentTimer();
    _complimentTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _getNextCompliment();
        });
      }
    });
  }

  void _stopComplimentTimer() {
    _complimentTimer?.cancel();
    _complimentTimer = null;
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showError('Camera permission required');
        return;
      }

      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFocusMode(FocusMode.auto);
      
      if (!mounted) return;
      setState(() => _isCameraReady = true);
      _startComplimentTimer();
    } catch (e) {
      _showError('Camera initialization failed: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _stopComplimentTimer();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AURA MIRROR',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (_isCameraReady && _controller != null)
            CameraPreview(_controller!),
          if (!_isCameraReady)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),

          // White Mirror Frame
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 30,
              ),
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.3),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.6, 1.0],
              ),
            ),
          ),

          // Floating Compliment Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey(_currentCompliment),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F5AF0).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Text(
                    _currentCompliment,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(20),
          elevation: 10,
        ),
      );
    }
  }
}