import 'package:brawe_app/ui/account/about_you_screen.dart';
import 'package:brawe_app/data/repositories/kyc_repository.dart';
import 'package:brawe_app/data/services/profile_service.dart';
import 'package:brawe_app/data/services/settings_service.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/edit_profile/widgets/edit_profile_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProfileSvc extends ProfileService {
  _ProfileSvc(this.data, {this.delay = Duration.zero}) : super(Dio(), Dio());
  final Map<String, dynamic> data;
  final Duration delay;
  @override
  Future<Map<String, dynamic>> getMyProfile() async {
    await Future<void>.delayed(delay);
    return data;
  }

  @override
  Future<Map<String, dynamic>> updateMyProfile({
    String? displayName,
    String? bio,
    Map<String, String>? socialLinks,
    String? accountType,
  }) async =>
      data;
}

class _SettingsSvc extends SettingsService {
  _SettingsSvc() : super(Dio());
  final patches = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> getSettings() async =>
      {'privacy_show_account_type': true, 'theme': 'dark'};
  @override
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> p) async {
    patches.add(p);
    return {'privacy_show_account_type': p['privacy_show_account_type'], 'theme': 'dark'};
  }
}

Future<void> _pump(WidgetTester tester, _ProfileSvc p, _SettingsSvc s) async {
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      profileServiceProvider.overrideWithValue(p),
      settingsServiceProvider.overrideWithValue(s),
      // verificação da conta sem rede no teste
      kycStatusProvider.overrideWith((ref) async => const KycStatus(
          identity: 'none', identityReason: null, business: 'none', businessReason: null,
          businessName: null, accountType: 'consumer')),
      // "Sobre você" sem rede no teste
      myAboutProvider.overrideWith((ref) async => <String, dynamic>{'gender': 'female', 'city': 'Curitiba'}),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      locale: const Locale('pt'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      home: const EditProfileScreen(),
    ),
  ));
}

String _textOf(WidgetTester t, String value) {
  final has = t
      .widgetList<EditableText>(find.byType(EditableText))
      .any((e) => e.controller.text == value);
  return has ? value : '';
}

void main() {
  final profile = {
    'user_id': 'u1',
    'username': 'ana',
    'display_name': 'Ana Souza',
    'bio': 'Lives toda semana',
    'social_links': {'instagram': 'ana.lives'},
    'account_type': 'creator',
  };

  testWidgets('campos vêm preenchidos com os dados atuais (perfil demora)',
      (tester) async {
    await _pump(tester, _ProfileSvc(profile, delay: const Duration(milliseconds: 300)),
        _SettingsSvc());
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(_textOf(tester, 'ana'), 'ana');
    expect(_textOf(tester, 'Ana Souza'), 'Ana Souza');
    expect(_textOf(tester, 'Lives toda semana'), 'Lives toda semana');
    expect(_textOf(tester, 'ana.lives'), 'ana.lives');
  });

  testWidgets('creator vê o interruptor do selo e salva de verdade',
      (tester) async {
    final settings = _SettingsSvc();
    await _pump(tester, _ProfileSvc(profile), settings);
    await tester.pumpAndSettle();
    final sw = find.byKey(const ValueKey('creator_badge_switch'));
    expect(sw, findsOneWidget);
    await tester.ensureVisible(sw);
    await tester.tap(sw);
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(settings.patches, [
      {'privacy_show_account_type': false}
    ]);
  });

  testWidgets('conta comum não vê o interruptor do selo', (tester) async {
    await _pump(
        tester, _ProfileSvc({...profile, 'account_type': 'consumer'}), _SettingsSvc());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('creator_badge_switch')), findsNothing);
  });
}
