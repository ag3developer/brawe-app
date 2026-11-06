import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import 'agency_l10n.dart';
import 'agency_markdown.dart';
import 'agency_widgets.dart';

/// Abre os termos em tela cheia (por cima da barra de navegação).
Future<void> openAgencyTerms(BuildContext context, AgencyTerms terms, {String? version}) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(builder: (_) => AgencyTermsScreen(terms: terms, version: version)),
  );
}

/// Termos padrão Brawe + adendo da agência, no idioma do usuário.
class AgencyTermsScreen extends StatelessWidget {
  const AgencyTermsScreen({super.key, required this.terms, this.version});
  final AgencyTerms terms;
  final String? version;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final lang = agencyLang(context);
    final std = terms.standardFor(lang);
    final add = terms.addendumFor(lang);
    final v = version ?? terms.version;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(s.agencyTermsTitle, style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (v != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AgencyChip(label: s.agencyTermsVersion(v), icon: LucideIcons.fileSignature, color: c.accentPrimary),
                    ),
                  if (terms.isEmpty) Text(s.agencyTermsEmpty, style: AgencyText.caption(context)),
                  if (std != null) ...[
                    _Heading(s.agencyTermsStandard, LucideIcons.scrollText),
                    AgencyMarkdown(std),
                  ],
                  if (add != null) ...[
                    const SizedBox(height: 20),
                    _Heading(s.agencyTermsAddendum, LucideIcons.building2),
                    AgencyMarkdown(add),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, this.icon);
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: c.accentPrimary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: c.accentPrimary, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: .3))),
      ]),
    );
  }
}

/// Termos recolhidos: cabeçalho que expande uma prévia rolável e o atalho
/// "Ler termos completos" (tela cheia).
class AgencyTermsCollapsible extends StatefulWidget {
  const AgencyTermsCollapsible({super.key, required this.terms});
  final AgencyTerms terms;
  @override
  State<AgencyTermsCollapsible> createState() => _AgencyTermsCollapsibleState();
}

class _AgencyTermsCollapsibleState extends State<AgencyTermsCollapsible> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final terms = widget.terms;
    final lang = agencyLang(context);
    final std = terms.standardFor(lang);
    return AgencyBox(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Icon(LucideIcons.fileSignature, size: 16, color: c.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text(s.agencyTermsExpand, style: AgencyText.title(context))),
                if (terms.version != null) ...[
                  Text(terms.version!, style: AgencyText.caption(context)),
                  const SizedBox(width: 6),
                ],
                Icon(_open ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 18, color: c.textTertiary),
              ]),
            ),
          ),
        ),
        if (_open) ...[
          const AgencyDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ClipRect(
                child: SingleChildScrollView(
                  child: terms.isEmpty
                      ? Text(s.agencyTermsEmpty, style: AgencyText.caption(context))
                      : AgencyMarkdown(std ?? terms.addendumFor(lang) ?? ''),
                ),
              ),
            ),
          ),
        ],
        const AgencyDivider(),
        InkWell(
          onTap: () => openAgencyTerms(context, terms),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: Text(s.agencyTermsRead,
                      style: TextStyle(color: c.accentPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                ),
                Icon(LucideIcons.chevronRight, size: 18, color: c.accentPrimary),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
