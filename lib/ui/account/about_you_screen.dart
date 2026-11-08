// Editar perfil › Sobre você: gênero, país e cidade (mesma etapa do cadastro).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/profile_service.dart';
import '../core/themes/brawe_colors.dart';
import '../onboarding/onboarding_screen.dart' show AboutYouStep;

/// Gênero, país e cidade do meu perfil (para mostrar em Editar perfil).
final myAboutProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async => Map<String, dynamic>.from(
    await ref.read(profileServiceProvider).getMyProfile(),
  ),
);

class AboutYouScreen extends ConsumerWidget {
  const AboutYouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final me = ref.watch(myAboutProvider).value;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: me == null
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: AboutYouStep(
                    initialGender: me['gender'] as String?,
                    initialCountry: me['country'] as String?,
                    onDone: () {
                      ref.invalidate(myAboutProvider);
                      context.pop();
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
