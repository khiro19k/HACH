import '../../../../core/network/supabase_config.dart';

class AuthService {
  final _client = SupabaseConfig.client;

  Future<Map<String, dynamic>?> loginWithIdAndPin(String qrToken, String pinCode) async {
    try {
      print('--- AUTHENTICATING ---');
      
      // Search by qr_magic_token as discovered in schema
      final response = await _client
          .from('patients')
          .select()
          .eq('qr_magic_token', qrToken)
          .maybeSingle();

      if (response == null) {
        print('Error: QR Token not found.');
        return null;
      }

      // Verify PIN (flexible for int/string)
      final storedPin = response['pin_code'].toString();
      if (storedPin == pinCode) {
        print('Login Success: ${response['full_name']}');
        return response;
      } else {
        print('Error: PIN Mismatch.');
        return null;
      }
    } catch (e) {
      print('Auth Error: $e');
      return null;
    }
  }

  // Future for Magic Link auth if needed specifically by Supabase Auth
  Future<void> sendMagicLink(String email) async {
    await _client.auth.signInWithOtp(email: email);
  }

  bool get isAuthenticated => _client.auth.currentUser != null;
  String? get currentPatientId => _client.auth.currentUser?.id;
}
