import 'package:brawe_app/domain/models/live_comment.dart';
import 'package:brawe_app/ui/live_feed/widgets/live_comments_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LiveCommentsOverlay renders comments and submits input', (
    tester,
  ) async {
    String? submittedMessage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveCommentsOverlay(
            comments: [
              LiveComment(
                id: 'comment-1',
                userId: 'user-1',
                userName: 'Alice',
                message: 'Hello there',
                timestamp: DateTime.utc(2026, 3, 12, 12),
              ),
            ],
            isSending: false,
            onSendComment: (message) {
              submittedMessage = message;
            },
          ),
        ),
      ),
    );

    final richTextContents = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((widget) => widget.text.toPlainText())
        .toList();
    expect(
      richTextContents.any((content) => content.contains('Alice Hello there')),
      isTrue,
    );

    await tester.enterText(find.byType(TextField), 'Host reply');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(submittedMessage, 'Host reply');
    expect(find.text('Host reply'), findsNothing);
  });
}
