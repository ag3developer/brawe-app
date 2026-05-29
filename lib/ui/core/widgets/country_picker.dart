// ============================================================================
// COUNTRY PICKER — campo de seleção de país com bandeira emoji + ISO code
// ============================================================================
// Usado por:
//   • Inscrição na Brawe Creator Network (envia ISO-2 que o backend valida)
//   • Edição de perfil, etc.
//
// Lista enxuta (~60 países top da nossa audiência: LATAM + EUA + EU + Ásia
// principais). O backend valida `country` como string 2-3 chars (ISO 3166-1).
// ============================================================================

import 'package:flutter/material.dart';

import '../themes/brawe_colors.dart';

class Country {
  final String code; // ISO-2 (BR, US, ES...)
  final String name; // Nome localizado
  final String flag; // 🇧🇷
  const Country(this.code, this.name, this.flag);
}

/// Lista curada — ordem alfabética por nome em PT.
/// Se faltar algum, adicionar aqui (e o backend aceita qualquer ISO-2/3).
const List<Country> kCountries = [
  Country('AR', 'Argentina', '🇦🇷'),
  Country('AU', 'Austrália', '🇦🇺'),
  Country('AT', 'Áustria', '🇦🇹'),
  Country('BE', 'Bélgica', '🇧🇪'),
  Country('BO', 'Bolívia', '🇧🇴'),
  Country('BR', 'Brasil', '🇧🇷'),
  Country('CA', 'Canadá', '🇨🇦'),
  Country('CL', 'Chile', '🇨🇱'),
  Country('CN', 'China', '🇨🇳'),
  Country('CO', 'Colômbia', '🇨🇴'),
  Country('KR', 'Coreia do Sul', '🇰🇷'),
  Country('CR', 'Costa Rica', '🇨🇷'),
  Country('CU', 'Cuba', '🇨🇺'),
  Country('DK', 'Dinamarca', '🇩🇰'),
  Country('EC', 'Equador', '🇪🇨'),
  Country('SV', 'El Salvador', '🇸🇻'),
  Country('AE', 'Emirados Árabes', '🇦🇪'),
  Country('ES', 'Espanha', '🇪🇸'),
  Country('US', 'Estados Unidos', '🇺🇸'),
  Country('PH', 'Filipinas', '🇵🇭'),
  Country('FI', 'Finlândia', '🇫🇮'),
  Country('FR', 'França', '🇫🇷'),
  Country('DE', 'Alemanha', '🇩🇪'),
  Country('GR', 'Grécia', '🇬🇷'),
  Country('GT', 'Guatemala', '🇬🇹'),
  Country('HN', 'Honduras', '🇭🇳'),
  Country('HK', 'Hong Kong', '🇭🇰'),
  Country('IN', 'Índia', '🇮🇳'),
  Country('ID', 'Indonésia', '🇮🇩'),
  Country('IE', 'Irlanda', '🇮🇪'),
  Country('IL', 'Israel', '🇮🇱'),
  Country('IT', 'Itália', '🇮🇹'),
  Country('JP', 'Japão', '🇯🇵'),
  Country('MY', 'Malásia', '🇲🇾'),
  Country('MX', 'México', '🇲🇽'),
  Country('NI', 'Nicarágua', '🇳🇮'),
  Country('NO', 'Noruega', '🇳🇴'),
  Country('NZ', 'Nova Zelândia', '🇳🇿'),
  Country('NL', 'Países Baixos', '🇳🇱'),
  Country('PA', 'Panamá', '🇵🇦'),
  Country('PY', 'Paraguai', '🇵🇾'),
  Country('PE', 'Peru', '🇵🇪'),
  Country('PL', 'Polônia', '🇵🇱'),
  Country('PT', 'Portugal', '🇵🇹'),
  Country('GB', 'Reino Unido', '🇬🇧'),
  Country('DO', 'República Dominicana', '🇩🇴'),
  Country('CZ', 'República Tcheca', '🇨🇿'),
  Country('RO', 'Romênia', '🇷🇴'),
  Country('RU', 'Rússia', '🇷🇺'),
  Country('SG', 'Singapura', '🇸🇬'),
  Country('SE', 'Suécia', '🇸🇪'),
  Country('CH', 'Suíça', '🇨🇭'),
  Country('TH', 'Tailândia', '🇹🇭'),
  Country('TW', 'Taiwan', '🇹🇼'),
  Country('TR', 'Turquia', '🇹🇷'),
  Country('UA', 'Ucrânia', '🇺🇦'),
  Country('UY', 'Uruguai', '🇺🇾'),
  Country('VE', 'Venezuela', '🇻🇪'),
  Country('VN', 'Vietnã', '🇻🇳'),
  Country('ZA', 'África do Sul', '🇿🇦'),
];

Country? findCountryByCode(String? code) {
  if (code == null || code.isEmpty) return null;
  final upper = code.toUpperCase();
  for (final c in kCountries) {
    if (c.code == upper) return c;
  }
  return null;
}

/// Abre um bottom sheet com busca e retorna o país escolhido (ou null).
Future<Country?> showCountryPicker(
  BuildContext context, {
  String? selectedCode,
  String title = 'Selecione o país',
  String searchHint = 'Buscar país...',
}) {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _CountryPickerSheet(
      selectedCode: selectedCode,
      title: title,
      searchHint: searchHint,
    ),
  );
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.selectedCode,
    required this.title,
    required this.searchHint,
  });
  final String? selectedCode;
  final String title;
  final String searchHint;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? kCountries
        : kCountries.where((c) {
            final q = _query.toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                c.code.toLowerCase().contains(q);
          }).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              widget.title,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: Icon(Icons.search_rounded,
                    color: context.colors.textSecondary),
                filled: true,
                fillColor: context.colors.surface,
                hintStyle: TextStyle(color: context.colors.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.border),
                ),
              ),
              style: TextStyle(color: context.colors.textPrimary),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                final isSelected = c.code == widget.selectedCode?.toUpperCase();
                return ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 28)),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    c.code,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor:
                      context.colors.accentPrimary.withValues(alpha: 0.08),
                  onTap: () => Navigator.of(context).pop(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
