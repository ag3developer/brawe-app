import 'package:brawe_app/data/services/iap_service.dart';
import 'package:brawe_app/data/repositories/gift_repository.dart';
import 'package:brawe_app/data/repositories/stories_repository.dart';
import 'package:brawe_app/domain/models/gift.dart';
import 'package:brawe_app/domain/models/story.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/core/view_models/credits_view_model.dart';
import 'package:brawe_app/ui/live_feed/view_models/gift_catalog_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

Gift testGift(String id, String name, double price, {String tier = 'basic'}) =>
    Gift(
      id: id,
      slug: id,
      name: name,
      emoji: '🎁',
      priceCredits: price,
      tier: tier,
    );

final List<GiftTier> testTiers = [
  GiftTier(
    name: 'free',
    gifts: [
      const Gift(
        id: 'f1',
        slug: 'f1',
        name: 'Coração',
        emoji: '❤️',
        isMonetary: false,
        priceCoins: 5,
        tier: 'free',
      ),
    ],
  ),
  GiftTier(
    name: 'basic',
    gifts: [
      testGift('rose', 'Rosa', 10),
      testGift('cafe', 'Café quentinho', 50),
      testGift('heart', 'Coração grande', 99),
      testGift('crown', 'Coroa real', 500),
      testGift('gem', 'Diamante', 1000, tier: 'luxury'),
      testGift('car', 'Carro esportivo', 12500, tier: 'luxury'),
      testGift('star', 'Estrela', 20),
      testGift('ring', 'Anel', 300),
    ],
  ),
  GiftTier(name: 'premium', gifts: [testGift('yacht', 'Iate', 5000)]),
];

class FakeCatalog extends GiftCatalogViewModel {
  @override
  Future<List<GiftTier>> build() async => testTiers;
}

class FakeCredits extends CreditsViewModel {
  FakeCredits(this.value);
  final double value;
  @override
  Future<double> build() async => value;
  @override
  Future<void> refresh() async {}
}

class FakeGiftRepo implements GiftRepository {
  final List<String> sent = [];
  @override
  Future<Map<String, dynamic>> sendStoryGift({
    required String storyId,
    required String giftId,
    int quantity = 1,
  }) async {
    sent.add(giftId);
    return {};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStoriesRepo implements StoriesRepository {
  FakeStoriesRepo(this.viewers);
  final List<StoryViewerInfo> viewers;
  @override
  Future<({List<StoryViewerInfo> viewers, int total})> getViewers(
    String storyId, {
    int limit = 50,
    int offset = 0,
  }) async => (viewers: viewers, total: viewers.length);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<Override> giftOverrides({
  required FakeGiftRepo repo,
  double balance = 100000,
}) => [
  giftCatalogViewModelProvider.overrideWith(FakeCatalog.new),
  creditsViewModelProvider.overrideWith(() => FakeCredits(balance)),
  giftRepositoryProvider.overrideWithValue(repo),
  // sem loja de verdade no teste: venda de Coins fechada (não abre conexão com Apple/Google)
  coinPurchaseOpenProvider.overrideWithValue(false),
];

/// App mínimo com tema real (claro/escuro), l10n pt e escala de texto.
Widget testApp({
  required Widget home,
  required List<Override> overrides,
  bool dark = false,
  double textScale = 1,
  GlobalKey? boundaryKey,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('pt'),
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(textScale)),
          child: RepaintBoundary(key: boundaryKey, child: child),
        );
      },
      home: home,
    ),
  );
}

void setScreen(WidgetTester tester, double w, double h) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(w, h);
  addTearDown(tester.view.reset);
}
