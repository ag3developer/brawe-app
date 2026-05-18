import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/services/auth_service.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/themes/brawe_colors.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty) {
      AppSnackBar.showError(context, 'Informe sua senha atual.');
      return;
    }
    if (next.length < 8) {
      AppSnackBar.showError(context, 'A nova senha deve ter pelo menos 8 caracteres.');
      return;
    }
    if (next != confirm) {
      AppSnackBar.showError(context, 'As novas senhas não coincidem.');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).changePassword(
            currentPassword: current,
            newPassword: next,
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Senha alterada com sucesso.');
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map
          ? (e.response?.data['detail']?.toString() ?? 'Falha ao alterar senha.')
          : 'Falha ao alterar senha.';
      AppSnackBar.showError(context, detail);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Erro de conexão.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar senha'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha atual',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova senha',
                helperText: 'Mínimo 8 caracteres',
                prefixIcon: Icon(Icons.lock_reset_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar nova senha',
                prefixIcon: Icon(Icons.lock_reset_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.accentPrimary,
                foregroundColor: context.colors.textOnAccent,
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.textOnAccent,
                      ),
                    )
                  : const Text('Salvar nova senha'),
            ),
          ],
        ),
      ),
    );
  }
}
