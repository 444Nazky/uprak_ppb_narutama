import 'package:data_siswa/state/app_state.dart';
import 'package:data_siswa/theme/app_theme.dart';
import 'package:data_siswa/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _fokusPassword = FocusNode();

  bool _sembunyi = true;
  bool _memuat = false;
  String? _galat;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _fokusPassword.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();
    setState(() => _galat = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _memuat = true);
    final state = AppScope.baca(context);
    final berhasil = await state.login(_username.text, _password.text);
    if (!mounted) return;
    setState(() {
      _memuat = false;
      if (!berhasil) {
        _galat = 'Username atau password tidak sesuai. Periksa kembali.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: tema.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness:
              tema.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Kepala(tema: tema)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Masuk ke akun Anda', style: tema.textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            Text(
                              'Kelola data siswa dari satu tempat. Masuk dengan akun sekolah.',
                              style: tema.textTheme.bodyMedium?.copyWith(
                                color: tema.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_galat != null) ...[
                              _PesanGalat(pesan: _galat!),
                              const SizedBox(height: 16),
                            ],
                            LabeledField(
                              label: 'Username',
                              wajib: true,
                              child: TextFormField(
                                controller: _username,
                                enabled: !_memuat,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan username',
                                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                                ),
                                validator: (nilai) {
                                  if (nilai == null || nilai.trim().isEmpty) {
                                    return 'Username tidak boleh kosong.';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _fokusPassword.requestFocus(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            LabeledField(
                              label: 'Password',
                              wajib: true,
                              child: TextFormField(
                                controller: _password,
                                focusNode: _fokusPassword,
                                enabled: !_memuat,
                                obscureText: _sembunyi,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  hintText: 'Masukkan password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded, size: 20),
                                  suffixIcon: IconButton(
                                    tooltip: _sembunyi
                                        ? 'Tampilkan password'
                                        : 'Sembunyikan password',
                                    onPressed: () =>
                                        setState(() => _sembunyi = !_sembunyi),
                                    icon: Icon(
                                      _sembunyi
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (nilai) {
                                  if (nilai == null || nilai.isEmpty) {
                                    return 'Password tidak boleh kosong.';
                                  }
                                  if (nilai.length < 6) {
                                    return 'Password minimal 6 karakter.';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _masuk(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _memuat ? null : _masuk,
                              child: _memuat
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Login'),
                            ),
                            const SizedBox(height: 20),
                            const _PetunjukAkun(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Kepala extends StatelessWidget {
  const _Kepala({required this.tema});

  final ThemeData tema;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      decoration: const BoxDecoration(
        color: AppColors.cobaltDeep,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.field),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: const Icon(Icons.groups_2_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 22),
            Text(
              'Aplikasi\nData Siswa',
              style: tema.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                height: 1.12,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'SMK Plus Pelita Nusantara Bogor',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PesanGalat extends StatelessWidget {
  const _PesanGalat({required this.pesan});

  final String pesan;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final gelap = tema.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: gelap ? AppColors.danger.withValues(alpha: 0.16) : AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 19, color: gelap ? const Color(0xFFFFB4AC) : AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pesan,
              style: tema.textTheme.bodySmall?.copyWith(
                color: gelap ? const Color(0xFFFFD5D0) : const Color(0xFF8A1C13),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetunjukAkun extends StatelessWidget {
  const _PetunjukAkun();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tema.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tema.colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: tema.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(text: 'Akun demo untuk pengujian: '),
                  TextSpan(
                    text: 'admin / admin123',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
