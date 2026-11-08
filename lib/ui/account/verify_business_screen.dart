// Dados da empresa: CNPJ com máscara (preenche razão social, nome fantasia, regime e endereço pela Receita),
// CEP com máscara (preenche o endereço), inscrição estadual (ou isento) e cartão CNPJ. Tudo obrigatório.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repositories/kyc_repository.dart';
import '../../gen/l10n/app_localizations.dart';
import '../core/themes/brawe_colors.dart';
import '../core/ui/grouped_list.dart';
import '../core/ui/mask_formatter.dart';

const _ufs = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];

class VerifyBusinessScreen extends ConsumerStatefulWidget {
  const VerifyBusinessScreen({super.key});

  @override
  ConsumerState<VerifyBusinessScreen> createState() =>
      _VerifyBusinessScreenState();
}

class _VerifyBusinessScreenState extends ConsumerState<VerifyBusinessScreen> {
  final _cnpj = TextEditingController();
  final _legal = TextEditingController();
  final _trade = TextEditingController();
  final _ie = TextEditingController();
  final _cep = TextEditingController();
  final _street = TextEditingController();
  final _number = TextEditingController();
  final _district = TextEditingController();
  final _city = TextEditingController();
  String _uf = '';
  String _regime = '';
  bool _ieExempt = false;
  String? _cardPath;
  String? _cardName;

  bool _lookingCnpj = false;
  bool _lookingCep = false;
  String? _cnpjStatus; // situação na Receita
  bool? _cnpjActive;
  String? _cnpjError;
  bool _sending = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [
      _cnpj,
      _legal,
      _trade,
      _ie,
      _cep,
      _street,
      _number,
      _district,
      _city,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onCnpj(String v) async {
    setState(() {
      _cnpjError = null;
      _cnpjStatus = null;
      _cnpjActive = null;
    });
    final d = DigitMask.digits(v);
    if (d.length != 14) return;
    setState(() => _lookingCnpj = true);
    try {
      final info = await ref.read(kycRepositoryProvider).lookupCnpj(d);
      if (!mounted || DigitMask.digits(_cnpj.text) != d) return;
      HapticFeedback.selectionClick();
      setState(() {
        _legal.text = info.legalName;
        _trade.text = info.tradeName.isNotEmpty
            ? info.tradeName
            : info.legalName;
        if (info.taxRegime.isNotEmpty) _regime = info.taxRegime;
        _cnpjStatus = info.situation;
        _cnpjActive = info.active;
        final a = info.address;
        if ((a['zip'] ?? '').isNotEmpty)
          _cep.text = DigitMask.cep.apply(a['zip']!);
        _street.text = a['street'] ?? _street.text;
        _number.text = a['number'] ?? _number.text;
        _district.text = a['district'] ?? _district.text;
        _city.text = a['city'] ?? _city.text;
        if (_ufs.contains(a['state'])) _uf = a['state']!;
      });
    } on KycFailure catch (e) {
      if (mounted) setState(() => _cnpjError = e.message);
    } finally {
      if (mounted) setState(() => _lookingCnpj = false);
    }
  }

  Future<void> _onCep(String v) async {
    final d = DigitMask.digits(v);
    if (d.length != 8) return;
    setState(() => _lookingCep = true);
    try {
      final a = await ref.read(kycRepositoryProvider).lookupCep(d);
      if (!mounted) return;
      setState(() {
        if ((a['street'] ?? '').isNotEmpty) _street.text = a['street']!;
        if ((a['district'] ?? '').isNotEmpty) _district.text = a['district']!;
        if ((a['city'] ?? '').isNotEmpty) _city.text = a['city']!;
        if (_ufs.contains(a['state'])) _uf = a['state']!;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _lookingCep = false);
    }
  }

  Future<void> _pickCard() async {
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final f = res?.files.single;
    if (f?.path == null) return;
    setState(() {
      _cardPath = f!.path;
      _cardName = f.name;
    });
  }

  bool get _valid =>
      DigitMask.digits(_cnpj.text).length == 14 &&
      _cnpjError == null &&
      _legal.text.trim().length >= 2 &&
      _trade.text.trim().length >= 2 &&
      _regime.isNotEmpty &&
      (_ieExempt || _ie.text.trim().length >= 2) &&
      DigitMask.digits(_cep.text).length == 8 &&
      _street.text.trim().length >= 2 &&
      _number.text.trim().isNotEmpty &&
      _district.text.trim().length >= 2 &&
      _city.text.trim().length >= 2 &&
      _uf.isNotEmpty &&
      _cardPath != null;

  Future<void> _submit() async {
    final s = S.of(context);
    setState(() => _sending = true);
    try {
      await ref.read(kycRepositoryProvider).submitBusiness({
        'cnpj': DigitMask.digits(_cnpj.text),
        'legal_name': _legal.text.trim(),
        'trade_name': _trade.text.trim(),
        'tax_regime': _regime,
        'state_registration': _ieExempt ? 'ISENTO' : _ie.text.trim(),
        'street': _street.text.trim(),
        'number': _number.text.trim(),
        'district': _district.text.trim(),
        'city': _city.text.trim(),
        'state': _uf,
        'zip': DigitMask.digits(_cep.text),
      }, _cardPath!);
      ref.invalidate(kycStatusProvider);
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => _done = true);
    } on KycFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message.isNotEmpty ? e.message : s.kycError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController c, {
    String? hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? fmt,
    ValueChanged<String>? onChanged,
    Widget? trailing,
    TextCapitalization caps = TextCapitalization.words,
    bool enabled = true,
  }) {
    return GroupedField(
      label: label,
      trailing: trailing,
      child: TextField(
        controller: c,
        enabled: enabled,
        keyboardType: keyboard,
        inputFormatters: fmt,
        textCapitalization: caps,
        onChanged: (v) {
          onChanged?.call(v);
          setState(() {});
        },
        style: TextStyle(color: context.colors.textPrimary, fontSize: 15.5),
        decoration: groupedInput(context, hint: hint),
      ),
    );
  }

  Widget _spinner() => const SizedBox(
    width: 16,
    height: 16,
    child: CircularProgressIndicator(strokeWidth: 2),
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    if (_done) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.hourglass,
                  size: 56,
                  color: colors.accentPrimary,
                ),
                const SizedBox(height: 20),
                Text(
                  s.kycSentTitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  s.kycBizSentBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(s.boostFinish),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final regimes = {
      'mei': 'MEI',
      'simples': s.kycRegimeSimples,
      'presumido': s.kycRegimePresumido,
      'real': s.kycRegimeReal,
    };
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.kycBusinessRow),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: GroupedBody(
        children: [
          GroupedSection(
            caption: s.kycBizCompany,
            indent: 16,
            footer:
                _cnpjError ??
                (_cnpjStatus == null
                    ? s.kycBizCnpjHint
                    : s.kycBizSituation(_cnpjStatus!)),
            children: [
              _field(
                'CNPJ',
                _cnpj,
                hint: '00.000.000/0000-00',
                keyboard: TextInputType.number,
                fmt: [DigitMask.cnpj],
                caps: TextCapitalization.none,
                onChanged: _onCnpj,
                trailing: _lookingCnpj
                    ? _spinner()
                    : _cnpjActive == null
                    ? null
                    : Icon(
                        _cnpjActive!
                            ? LucideIcons.circleCheck
                            : LucideIcons.circleAlert,
                        size: 18,
                        color: _cnpjActive! ? colors.success : colors.warning,
                      ),
              ),
              _field(s.kycBizLegalName, _legal),
              _field(s.kycBizTradeName, _trade),
            ],
          ),
          GroupedSection(
            caption: s.kycBizTax,
            indent: 16,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.kycBizRegime,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in regimes.entries)
                          ChoiceChip(
                            label: Text(e.value),
                            selected: _regime == e.key,
                            showCheckmark: false,
                            shape: const StadiumBorder(),
                            onSelected: (_) => setState(() => _regime = e.key),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              _field(
                s.kycBizIe,
                _ie,
                enabled: !_ieExempt,
                hint: _ieExempt ? s.kycBizIeExempt : null,
                keyboard: TextInputType.number,
                caps: TextCapitalization.characters,
              ),
              GroupedRow(
                title: s.kycBizIeExempt,
                trailing: Switch.adaptive(
                  value: _ieExempt,
                  activeTrackColor: colors.accentPrimary,
                  onChanged: (v) => setState(() => _ieExempt = v),
                ),
              ),
            ],
          ),
          GroupedSection(
            caption: s.kycBizAddress,
            indent: 16,
            children: [
              _field(
                s.kycBizZip,
                _cep,
                hint: '00000-000',
                keyboard: TextInputType.number,
                fmt: [DigitMask.cep],
                caps: TextCapitalization.none,
                onChanged: _onCep,
                trailing: _lookingCep ? _spinner() : null,
              ),
              _field(s.kycBizStreet, _street),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      s.kycBizNumber,
                      _number,
                      keyboard: TextInputType.text,
                      caps: TextCapitalization.characters,
                    ),
                  ),
                  Expanded(flex: 2, child: _field(s.kycBizDistrict, _district)),
                ],
              ),
              Row(
                children: [
                  Expanded(flex: 3, child: _field(s.kycBizCity, _city)),
                  Expanded(
                    child: GroupedField(
                      label: 'UF',
                      child: DropdownButton<String>(
                        value: _uf.isEmpty ? null : _uf,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        hint: const Text('—'),
                        items: [
                          for (final u in _ufs)
                            DropdownMenuItem(value: u, child: Text(u)),
                        ],
                        onChanged: (v) => setState(() => _uf = v ?? ''),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GroupedSection(
            caption: s.kycBizCard,
            footer: s.kycBizCardHint,
            children: [
              GroupedRow(
                icon: _cardPath == null
                    ? LucideIcons.upload
                    : LucideIcons.fileCheck,
                title: _cardPath == null ? s.kycPickFile : (_cardName ?? ''),
                subtitle: _cardPath == null ? null : s.kycChangeFile,
                onTap: _pickCard,
                trailing: _cardPath == null
                    ? null
                    : Icon(LucideIcons.check, color: colors.success, size: 20),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              s.kycPrivacy,
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _valid && !_sending ? _submit : null,
                  child: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          s.kycSubmit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
