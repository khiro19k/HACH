import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/remote/auth_service.dart';
import '../../providers/patient_provider.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _openQRScanner() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }
    
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى منح صلاحية الكاميرا لمسح الرمز')),
      );
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    _idController.text = code;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم مسح المعرف بنجاح')),
                    );
                  }
                }
              },
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.accentColor, width: 4),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_idController.text.isEmpty || _pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال المعرف والرمز السري')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // DEMO MODE CHECK
    if (_idController.text.trim() == 'DEMO123' && _pinController.text.trim() == '1234') {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network
      setState(() => _isLoading = false);
      context.go('/');
      return;
    }

    final authService = AuthService();
    final patient = await authService.loginWithIdAndPin(
      _idController.text.trim(),
      _pinController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (patient != null) {
      // Save profile to global state
      ref.read(patientProvider.notifier).setPatient(patient);
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات الدخول غير صحيحة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgGradientStart, AppTheme.bgGradientEnd],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _openQRScanner, // Keep the Easter egg/hidden scanner on logo tap if desired, or remove
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'images/logo.png', // Logo path
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image is missing
                        return const Icon(Icons.health_and_safety_rounded, size: 80, color: AppTheme.primaryColor);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'مرحباً بك في رفيق',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'قم بمسح الرمز التعريفي الخاص بك للمتابعة',
                  style: TextStyle(color: AppTheme.secondaryTextColor),
                ),
                const SizedBox(height: 48),
                
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'معرف المريض (من QR)',
                    prefixIcon: const Icon(Icons.person_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      onPressed: _openQRScanner,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'الرمز السري (PIN)',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _openQRScanner,
                  child: const Text('أو قم بمسح الرمز الآن', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
