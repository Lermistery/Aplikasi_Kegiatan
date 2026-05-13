import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_kegiatanku/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KegiatanKuApp());
    expect(find.text('KegiatanKu'), findsWidgets);
  });
}
