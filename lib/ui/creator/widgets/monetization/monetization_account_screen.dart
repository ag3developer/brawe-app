// Conta de recebimento da Monetização. País → forma de recebimento → campos
// (vindos do servidor) → titular. Todos os campos mostrados são obrigatórios.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../data/repositories/creator_payout_repository.dart';
import '../../../../domain/models/creator_payout.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../agency/agency_widgets.dart';
import 'monetization_l10n.dart';

class MonetizationAccountScreen extends ConsumerStatefulWidget {
  const MonetizationAccountScreen({super.key, required this.overview});
  final PayoutOverview overview;

  @override
  ConsumerState<MonetizationAccountScreen> createState() => _MonetizationAccountScreenState();
}

class _MonetizationAccountScreenState extends ConsumerState<MonetizationAccountScreen> {
  String _country = '';
  String _method = '';
  String _taxRegime = '';
  final Map<String, TextEditingController> _ctrls = {};
  final Map<String, String> _choices = {}; // key_type / account_type
  final _holderName = TextEditingController();
  final _holderDoc = TextEditingController();
  bool _busy = false;
  bool _showErrors = false;
  String _error = '';

  PayoutAccountForm get _form => widget.overview.form;
  List<String> get _methods => _country.isEmpty ? const [] : (_form.methodsByCountry[_country] ?? const []);
  List<String> get _fields => _method.isEmpty ? const [] : (_form.methodFields[_method] ?? const []);
  bool get _needsRegime => _country == 'BR' && _holderDoc.text.replaceAll(RegExp(r'\D'), '').length == 14;
  static const _selects = {'key_type', 'account_type'};

  @override
  void initState() {
    super.initState();
    final current = widget.overview.account?.country ?? '';
    if (current.isNotEmpty && _form.countries.contains(current)) _pickCountry(current);
    _holderDoc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _holderName.dispose();
    _holderDoc.dispose();
    super.dispose();
  }

  TextEditingController _ctrl(String k) => _ctrls.putIfAbsent(k, TextEditingController.new);

  void _pickCountry(String c) {
    _country = c;
    _method = '';
    _clearFields();
    final ms = _form.methodsByCountry[c] ?? const [];
    if (ms.length == 1) _method = ms.first;
  }

  void _clearFields() {
    for (final c in _ctrls.values) {
      c.clear();
    }
    _choices.clear();
  }

  String _value(String k) => _selects.contains(k) ? (_choices[k] ?? '') : _ctrl(k).text.trim();

  bool get _nameOk => _holderName.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length >= 2;

  bool get _allFilled =>
      _country.isNotEmpty &&
      _method.isNotEmpty &&
      _nameOk &&
      _holderDoc.text.trim().isNotEmpty &&
      (!_needsRegime || _taxRegime.isNotEmpty) &&
      _fields.every((k) => _value(k).isNotEmpty);

  Future<void> _save() async {
    final s = S.of(context);
    final f = PayoutFmt.of(context);
    setState(() => _showErrors = true);
    if (!_allFilled) {
      setState(() => _error = s.payoutErrorsFillAll);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      await ref.read(creatorPayoutRepositoryProvider).saveAccount(
            country: _country,
            method: _method,
            holderName: _holderName.text.trim(),
            holderTaxId: _holderDoc.text.trim(),
            fields: {for (final k in _fields) k: _value(k)},
            taxRegime: _needsRegime ? _taxRegime : null,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = payoutErrorText(s, f, e, widget.overview);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final currency = _country.isEmpty ? '' : (_form.currencyByCountry[_country] ?? '');

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(s.payoutAccountFormTitle, style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Text(s.payoutAccountFormIntro, style: AgencyText.caption(context)),
            const SizedBox(height: 18),
            _Labeled(
              label: s.payoutFieldsCountry,
              child: _Dropdown(
                value: _country,
                hint: s.payoutAccountSelect,
                error: _showErrors && _country.isEmpty,
                items: {for (final x in _form.countries) x: payoutCountryLabel(s, x)},
                onChanged: (v) => setState(() => _pickCountry(v)),
              ),
            ),
            if (currency.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(currency == 'BRL' ? s.payoutAccountPaidInBrl : s.payoutAccountPaidInUsd,
                  style: AgencyText.caption(context).copyWith(fontSize: 11.5)),
            ],
            if (_methods.length > 1) ...[
              const SizedBox(height: 18),
              Text(s.payoutFieldsMethod, style: AgencyText.caption(context)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final m in _methods)
                  ChoiceChip(
                    label: Text(payoutMethodLabel(s, m)),
                    selected: _method == m,
                    onSelected: (_) => setState(() {
                      _method = m;
                      _clearFields();
                    }),
                  ),
              ]),
              if (_showErrors && _method.isEmpty) ...[
                const SizedBox(height: 6),
                Text(s.payoutErrorsPickMethod, style: TextStyle(color: c.danger, fontSize: 12)),
              ],
            ],
            if (_method.isNotEmpty) ...[
              for (final k in _fields) ...[
                const SizedBox(height: 16),
                _Labeled(label: payoutFieldLabel(s, k), child: _fieldInput(s, k)),
              ],
              const SizedBox(height: 22),
              const AgencyDivider(),
              const SizedBox(height: 16),
              Text(s.payoutAccountHolderTitle, style: AgencyText.title(context)),
              const SizedBox(height: 2),
              Text(s.payoutAccountHolderHint, style: AgencyText.caption(context)),
              const SizedBox(height: 14),
              _Labeled(
                label: s.payoutFieldsHolderName,
                child: _Input(
                  controller: _holderName,
                  hint: s.payoutAccountHolderNamePlaceholder,
                  error: _showErrors && !_nameOk,
                  maxLength: 200,
                  capitalization: TextCapitalization.words,
                  autofill: const [AutofillHints.name],
                ),
              ),
              const SizedBox(height: 16),
              _Labeled(
                label: _country == 'BR' ? s.payoutAccountDocBr : s.payoutAccountDocOther,
                child: _Input(
                  controller: _holderDoc,
                  hint: _country == 'BR' ? '000.000.000-00' : s.payoutAccountDocOther,
                  error: _showErrors && _holderDoc.text.trim().isEmpty,
                  maxLength: 30,
                  numeric: _country == 'BR',
                ),
              ),
              if (_needsRegime) ...[
                const SizedBox(height: 16),
                _Labeled(
                  label: s.payoutFieldsTaxRegime,
                  child: _Dropdown(
                    value: _taxRegime,
                    hint: s.payoutAccountSelect,
                    error: _showErrors && _taxRegime.isEmpty,
                    items: {for (final r in _form.taxRegimes) r: payoutTaxRegimeLabel(s, r)},
                    onChanged: (v) => setState(() => _taxRegime = v),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(LucideIcons.shieldCheck, size: 15, color: c.textTertiary),
                const SizedBox(width: 8),
                Expanded(child: Text(s.payoutAccountSecurityNote, style: AgencyText.caption(context).copyWith(fontSize: 11.5))),
              ]),
              const SizedBox(height: 8),
              Text(s.payoutAccountReviewNote, style: AgencyText.caption(context).copyWith(fontSize: 11.5)),
            ],
            if (_error.isNotEmpty) ...[const SizedBox(height: 16), PayoutErrorBox(text: _error)],
            if (_method.isNotEmpty) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(s.payoutAccountSave),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fieldInput(S s, String k) {
    final bad = _showErrors && _value(k).isEmpty;
    if (k == 'key_type') {
      return _Dropdown(
        value: _choices[k] ?? '',
        hint: s.payoutAccountSelect,
        error: bad,
        items: {for (final x in _form.pixKeyTypes) x: payoutPixKeyTypeLabel(s, x)},
        onChanged: (v) => setState(() => _choices[k] = v),
      );
    }
    if (k == 'account_type') {
      return _Dropdown(
        value: _choices[k] ?? '',
        hint: s.payoutAccountSelect,
        error: bad,
        items: {for (final x in const ['checking', 'savings']) x: payoutAccountTypeLabel(s, x)},
        onChanged: (v) => setState(() => _choices[k] = v),
      );
    }
    final numeric = const {'bank_code', 'branch', 'account', 'routing_number'}.contains(k);
    final upper = const {'iban', 'swift', 'account_digit'}.contains(k);
    final hint = switch (k) {
      'key' => payoutKeyPlaceholder(s, _choices['key_type']),
      'bank_code' => '001',
      'branch' => '0001',
      'account_digit' => '0',
      _ => payoutFieldLabel(s, k),
    };
    return _Input(
      controller: _ctrl(k),
      hint: hint,
      error: bad,
      numeric: numeric,
      capitalization: upper ? TextCapitalization.characters : TextCapitalization.none,
      maxLength: k == 'bank_address' ? 250 : 120,
      onChanged: (_) => setState(() {}),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AgencyText.caption(context)),
        const SizedBox(height: 6),
        child,
      ]);
}

InputDecoration _decoration(BuildContext context, String hint, bool error) {
  final c = context.colors;
  OutlineInputBorder b(Color col) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: col));
  return InputDecoration(
    hintText: hint,
    counterText: '',
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: b(error ? c.danger : c.border),
    focusedBorder: b(error ? c.danger : c.accentPrimary),
    border: b(c.border),
  );
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    required this.error,
    this.numeric = false,
    this.capitalization = TextCapitalization.none,
    this.maxLength,
    this.autofill,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final bool error;
  final bool numeric;
  final TextCapitalization capitalization;
  final int? maxLength;
  final Iterable<String>? autofill;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        textCapitalization: capitalization,
        autocorrect: false,
        enableSuggestions: false,
        maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        autofillHints: autofill,
        onChanged: onChanged,
        decoration: _decoration(context, hint, error),
      );
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.value, required this.hint, required this.items, required this.onChanged, required this.error});
  final String value;
  final String hint;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  final bool error;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        // a chave recria o campo quando o valor muda por fora (ex.: trocou o método)
        key: ValueKey('dd:$value'),
        initialValue: value.isEmpty ? null : value,
        isExpanded: true,
        hint: Text(hint),
        decoration: _decoration(context, hint, error),
        items: [for (final e in items.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      );
}

/// Caixa de erro (texto já traduzido).
class PayoutErrorBox extends StatelessWidget {
  const PayoutErrorBox({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.danger.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(LucideIcons.circleAlert, size: 16, color: c.danger),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: c.danger, fontSize: 13, height: 1.35))),
      ]),
    );
  }
}
