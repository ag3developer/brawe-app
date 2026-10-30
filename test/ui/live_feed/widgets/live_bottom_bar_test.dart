import 'package:brawe_app/ui/live/shared/widgets/actions/live_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests para `LiveBottomBar` (TELA DO ESPECTADOR).
///
/// Cobre os requisitos da última mudança:
/// 1. Botão "Rosa" 🌹 substituiu o "Seguir" — tap dispara `onSendRose`.
/// 2. Input de chat é transparente — não tem `BackdropFilter` nem
///    `Container` com cor de fundo opaca/glass.
/// 3. Botões "Curtir", "Presentes" e "Compartilhar" continuam disparando
///    seus callbacks (regression).
void main() {
  // Helper: monta o widget envolto em MaterialApp/Scaffold com os
  // callbacks que queremos espionar.
  Future<_TapSpies> pumpBar(
    WidgetTester tester, {
    bool hasStorefront = false,
    bool isLiked = false,
  }) async {
    final spies = _TapSpies();
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: LiveBottomBar(
              controller: controller,
              focusNode: focus,
              isSending: false,
              isLiked: isLiked,
              likesCount: 0,
              onSend: () => spies.send++,
              onSendRose: () => spies.rose++,
              onGifts: () => spies.gifts++,
              onLike: () => spies.like++,
              onShare: () => spies.share++,
              onSeguir: () => spies.seguir++,
              onShop: () => spies.shop++,
              hasStorefront: hasStorefront,
            ),
          ),
        ),
      ),
    );
    return spies;
  }

  group('LiveBottomBar', () {
    testWidgets('botão Rosa 🌹 dispara onSendRose (não onSeguir)',
        (tester) async {
      final spies = await pumpBar(tester);

      // Label "Rosa" precisa existir; "Seguir" NÃO deve existir mais.
      expect(find.text('Rosa'), findsOneWidget);
      expect(find.text('Seguir'), findsNothing);

      // Emoji 🌹 visível em algum Text descendente.
      expect(find.text('🌹'), findsOneWidget);

      await tester.tap(find.text('Rosa'));
      await tester.pump();

      expect(spies.rose, 1, reason: 'onSendRose deve ser chamado uma vez');
      expect(spies.seguir, 0, reason: 'onSeguir não deve ser chamado');
    });

    testWidgets('botão Presentes dispara onGifts', (tester) async {
      final spies = await pumpBar(tester);
      await tester.tap(find.text('Presentes'));
      await tester.pump();
      expect(spies.gifts, 1);
    });

    testWidgets('botão Curtir dispara onLike', (tester) async {
      final spies = await pumpBar(tester);
      await tester.tap(find.text('Curtir'));
      await tester.pump();
      expect(spies.like, 1);
    });

    testWidgets('botão Compartilhar dispara onShare', (tester) async {
      final spies = await pumpBar(tester);
      await tester.tap(find.text('Compartilhar'));
      await tester.pump();
      expect(spies.share, 1);
    });

    testWidgets('Loja só aparece quando hasStorefront=true', (tester) async {
      final spies = await pumpBar(tester, hasStorefront: false);
      expect(find.text('Loja'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      final spies2 = await pumpBar(tester, hasStorefront: true);
      expect(find.text('Loja'), findsOneWidget);
      await tester.tap(find.text('Loja'));
      await tester.pump();
      expect(spies2.shop, 1);
      // garantir que pumpBar reset não vazou
      expect(spies.shop, 0);
    });

    testWidgets('input de chat é transparente (sem BackdropFilter/glass)',
        (tester) async {
      await pumpBar(tester);

      // Não deve haver BackdropFilter (removido para visual minimalista).
      expect(find.byType(BackdropFilter), findsNothing);

      // Hint do input precisa estar lá.
      expect(find.text('Diga algo...'), findsOneWidget);

      // O DecoratedBox que envolve o input deve ter color: Colors.transparent
      // (validamos pelo decoration). Pegamos o primeiro DecoratedBox que
      // contenha um TextField como descendente.
      final boxFinder = find.ancestor(
        of: find.byType(TextField),
        matching: find.byType(DecoratedBox),
      );
      expect(boxFinder, findsWidgets);
      final box = tester.widget<DecoratedBox>(boxFinder.first);
      final deco = box.decoration as BoxDecoration;
      expect(
        deco.color,
        Colors.transparent,
        reason: 'O input deve ter fundo transparente (estilo ChatTicker)',
      );
    });

    testWidgets('ícone do input começa como chat quando texto vazio',
        (tester) async {
      await pumpBar(tester);
      // Texto vazio → ícone de chat (abre o teclado), não send.
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      // O Icons.send_rounded existe SÓ no botão "Compartilhar" da linha
      // de ações (ainda assim aparece — mas não no input).
      // Validamos pelo Row do TextField que NÃO contém send_rounded.
      final inputRow = find
          .ancestor(of: find.byType(TextField), matching: find.byType(Row))
          .first;
      final sendInsideInput = find.descendant(
        of: inputRow,
        matching: find.byIcon(Icons.send_rounded),
      );
      expect(sendInsideInput, findsNothing);
    });

    testWidgets('ao digitar, as ações somem e o input ocupa a linha',
        (tester) async {
      await pumpBar(tester);
      expect(find.text('Curtir'), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(find.text('Curtir'), findsNothing);
      expect(find.text('Presente'), findsNothing);

      // Toque fora da barra fecha o teclado e as ações voltam.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.text('Curtir'), findsOneWidget);
    });

    testWidgets('limita a mensagem a 150 caracteres', (tester) async {
      await pumpBar(tester);
      await tester.enterText(find.byType(TextField), 'a' * 200);
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text.length, LiveBottomBar.maxMessageLength);
    });
  });
}

/// Contador de quantas vezes cada callback foi chamado.
class _TapSpies {
  int send = 0;
  int rose = 0;
  int gifts = 0;
  int like = 0;
  int share = 0;
  int seguir = 0;
  int shop = 0;
}
