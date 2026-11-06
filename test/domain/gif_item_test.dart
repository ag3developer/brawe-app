import 'package:brawe_app/domain/models/gif_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GifPage.fromJson lê itens e next_offset', () {
    final p = GifPage.fromJson({
      'items': [
        {'id': 'a', 'title': 't', 'preview_url': 'https://media1.giphy.com/p.webp', 'url': 'https://media1.giphy.com/a.gif', 'width': 200, 'height': 100},
        {'id': 'bad', 'url': '', 'width': 0, 'height': 0},
      ],
      'next_offset': 24,
    });
    expect(p.items.length, 1);
    expect(p.items.first.previewUrl, endsWith('.webp'));
    expect(p.nextOffset, 24);
    expect(p.items.first.toAttachment().aspectRatio, 2);
  });

  test('sem next_offset = última página; lixo não quebra', () {
    expect(GifPage.fromJson({'items': [], 'next_offset': null}).nextOffset, isNull);
    expect(GifPage.fromJson('x').items, isEmpty);
  });

  test('GifAttachment.tryParse aceita strings numéricas e rejeita incompleto', () {
    final g = GifAttachment.tryParse({'id': 'a', 'url': 'https://media1.giphy.com/a.gif', 'width': '320', 'height': 240});
    expect(g?.width, 320);
    expect(g?.toJson()['height'], 240);
    expect(GifAttachment.tryParse({'url': '', 'width': 1, 'height': 1}), isNull);
    expect(GifAttachment.tryParse(null), isNull);
  });

  test('preview ausente cai para a url completa', () {
    final i = GifItem.tryParse({'id': 'a', 'url': 'https://media1.giphy.com/a.gif', 'width': 1, 'height': 1});
    expect(i?.previewUrl, 'https://media1.giphy.com/a.gif');
  });
}
