import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_streamer/data/models/media_entry.dart';
import 'package:iptv_streamer/data/models/media_type.dart';
import 'package:iptv_streamer/features/widgets/media_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MediaCard renderiza titulo e responde a toque',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    var tapped = false;
    const entry = MediaEntry(
      id: 'x',
      title: 'Canal Ficticio',
      url: 'http://x/c.ts',
      type: MediaType.live,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: MediaCard(
                entry: entry,
                onSelected: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Canal Ficticio'), findsOneWidget);
    await tester.tap(find.byType(MediaCard));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('Fallback sem logo mostra inicial do titulo', (tester) async {
    const entry = MediaEntry(
      id: 'y',
      title: 'Globo',
      url: 'http://x/g.ts',
      type: MediaType.live,
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: MediaCard(entry: entry, onSelected: () {}))),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('G'), findsOneWidget);
  });
}
