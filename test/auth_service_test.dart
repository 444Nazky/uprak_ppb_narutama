import 'package:data_siswa/services/app_preferences.dart';
import 'package:data_siswa/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('login berhasil dengan akun demo', () async {
    final auth = AuthService(preferences: AppPreferences.instance);

    final success = await auth.signIn('admin', 'admin123');

    expect(success, isTrue);
    expect(await auth.restoreSession(), 'admin');
  });

  test('login gagal dengan password salah', () async {
    final auth = AuthService(preferences: AppPreferences.instance);

    final success = await auth.signIn('admin', 'salah');

    expect(success, isFalse);
    expect(await auth.restoreSession(), isNull);
  });

  test('logout menghapus sesi', () async {
    final auth = AuthService(preferences: AppPreferences.instance);
    await auth.signIn('admin', 'admin123');

    await auth.signOut();

    expect(await auth.restoreSession(), isNull);
  });
}
