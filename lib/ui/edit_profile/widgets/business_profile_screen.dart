import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/kyc_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/grouped_list.dart';
import '../../core/ui/mask_formatter.dart';

/// "Perfil da empresa": dados verificados (somente leitura) + o que aparece na página
/// (categoria, e-mail e WhatsApp comerciais, mostrar cidade). Nome, bio, foto e links
/// ficam em Editar perfil.
class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _category;
  bool _showCity = true;
  bool _initialized = false;
  bool _saving = false;
  BusinessPage? _initial;
  final Map<String, String> _fieldErrors = {};

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _init(BusinessMe me) {
    if (_initialized) return;
    _initialized = true;
    _initial = me.page;
    _category = me.page.category;
    _emailCtrl.text = me.page.email ?? '';
    _phoneCtrl.text = DigitMask.phoneBr.apply(me.page.whatsapp ?? '');
    _showCity = me.page.showCity;
  }

  String? _emailError(S s) {
    final v = _emailCtrl.text.trim();
    if (v.isEmpty) return s.bizPageRequired;
    if (!_emailRe.hasMatch(v)) return s.bizPageEmailInvalid;
    return null;
  }

  String? _phoneError(S s) {
    final d = DigitMask.digits(_phoneCtrl.text);
    if (d.isEmpty) return s.bizPageRequired;
    if (d.length < 10) return s.bizPagePhoneInvalid;
    return null;
  }

  bool get _valid =>
      _category != null &&
      _emailRe.hasMatch(_emailCtrl.text.trim()) &&
      DigitMask.digits(_phoneCtrl.text).length >= 10;

  bool get _changed {
    final i = _initial;
    if (i == null) return false;
    return _category != i.category ||
        _emailCtrl.text.trim() != (i.email ?? '') ||
        DigitMask.digits(_phoneCtrl.text) !=
            DigitMask.digits(i.whatsapp ?? '') ||
        _showCity != i.showCity;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    final colors = context.colors;
    setState(() {
      _saving = true;
      _fieldErrors.clear();
    });
    try {
      final email = _emailCtrl.text.trim();
      final phone = DigitMask.digits(_phoneCtrl.text);
      await ref
          .read(kycRepositoryProvider)
          .saveBusinessPage(
            category: _category!,
            contactEmail: email,
            whatsapp: phone,
            showCity: _showCity,
          );
      if (!mounted) return;
      setState(() {
        _initial = BusinessPage(
          category: _category,
          email: email,
          whatsapp: phone,
          showCity: _showCity,
        );
      });
      ref.invalidate(businessMeProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.bizPageSaved),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final f = e is KycFailure ? e : null;
      final msg = (f?.message.isNotEmpty ?? false)
          ? f!.message
          : s.bizPageSaveError;
      if (f?.field != null && f!.field!.isNotEmpty) {
        setState(() => _fieldErrors[f.field!] = msg);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: colors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _categoryLabel(S s, String key) => businessCategoryLabel(s, key);

  Future<void> _pickCategory(S s, List<String> cats) async {
    final colors = context.colors;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Text(
                s.bizPageCategory,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final c in cats)
                      ListTile(
                        title: Text(
                          _categoryLabel(s, c),
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        trailing: c == _category
                            ? Icon(
                                LucideIcons.check,
                                size: 18,
                                color: colors.accentPrimary,
                              )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(c),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _category = picked;
        _fieldErrors.remove('category');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final async = ref.watch(businessMeProvider);
    final me = async.value;
    final approved = me?.verification?.status == 'approved';
    if (me != null && approved) _init(me);
    final canSave = approved && _valid && _changed && !_saving;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.bizPageTitle),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (approved)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _saving
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: canSave ? _save : null,
                      child: Text(
                        s.actionSave,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        child: me == null
            ? (async.hasError
                  ? _error(s)
                  : Center(
                      child: CircularProgressIndicator(
                        color: colors.accentPrimary,
                      ),
                    ))
            : RefreshIndicator.adaptive(
                onRefresh: () async => ref.invalidate(businessMeProvider),
                child: GroupedBody(children: _content(s, me)),
              ),
      ),
    );
  }

  Widget _error(S s) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            s.bizPageLoadError,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.invalidate(businessMeProvider),
            child: Text(s.bizPageRetry),
          ),
        ],
      ),
    ),
  );

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
    child: Text(
      text,
      style: TextStyle(
        color: context.colors.textTertiary,
        fontSize: 12.5,
        height: 1.35,
      ),
    ),
  );

  List<Widget> _content(S s, BusinessMe me) {
    final colors = context.colors;
    final v = me.verification;
    final status = v?.status;

    if (v == null) {
      return [
        _statusCard(
          icon: LucideIcons.building2,
          color: colors.textSecondary,
          title: s.bizPageNoneTitle,
          body: s.bizPageNoneBody,
          action: s.bizPageVerifyCta,
        ),
      ];
    }
    if (status == 'pending') {
      return [
        _statusCard(
          icon: LucideIcons.clock,
          color: colors.warning,
          title: s.bizPagePendingTitle,
          body: s.bizPagePendingBody,
        ),
      ];
    }
    if (status == 'rejected') {
      return [
        _statusCard(
          icon: LucideIcons.circleAlert,
          color: colors.danger,
          title: s.bizPageRejectedTitle,
          body: (v.reason?.isNotEmpty ?? false)
              ? v.reason!
              : s.bizPageRejectedBody,
          action: s.bizPageSendAgain,
        ),
      ];
    }

    final date = v.reviewedAt == null
        ? null
        : MaterialLocalizations.of(context).formatShortDate(v.reviewedAt!);
    final place = [
      v.city,
      v.state,
    ].whereType<String>().where((e) => e.isNotEmpty).join('/');
    return [
      GroupedSection(
        caption: s.bizPageVerifiedSection,
        footer: s.bizPageVerifiedFooter,
        indent: 16,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Icon(LucideIcons.badgeCheck, size: 18, color: colors.success),
                const SizedBox(width: 8),
                Text(
                  date == null
                      ? s.bizPageVerifiedChip
                      : s.bizPageVerifiedChipDate(date),
                  style: TextStyle(
                    color: colors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (v.tradeName != null)
            GroupedRow(title: s.bizPageTradeName, value: v.tradeName),
          if (v.legalName != null)
            GroupedRow(title: s.bizPageLegalName, subtitle: v.legalName),
          if (v.cnpj != null) GroupedRow(title: 'CNPJ', value: v.cnpj),
          if (place.isNotEmpty)
            GroupedRow(title: s.bizPageCityState, value: place),
        ],
      ),
      GroupedSection(
        caption: s.bizPagePageSection,
        indent: 16,
        children: [
          GroupedRow(
            title: s.bizPageCategory,
            value: _category == null
                ? s.bizPageCategoryHint
                : _categoryLabel(s, _category!),
            valueColor: _category == null ? colors.textTertiary : null,
            onTap: () => _pickCategory(s, me.categories),
          ),
          GroupedField(
            label: s.bizPageEmail,
            child: TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              style: TextStyle(color: colors.textPrimary, fontSize: 15.5),
              decoration: groupedInput(
                context,
                hint: 'contato@empresa.com',
              ).copyWith(errorText: _fieldErrors['contact_email']),
              onChanged: (_) =>
                  setState(() => _fieldErrors.remove('contact_email')),
            ),
          ),
          GroupedField(
            label: s.bizPageWhatsapp,
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                DigitMask.phoneBr,
                LengthLimitingTextInputFormatter(15),
              ],
              style: TextStyle(color: colors.textPrimary, fontSize: 15.5),
              decoration: groupedInput(
                context,
                hint: '(00) 00000-0000',
              ).copyWith(errorText: _fieldErrors['whatsapp']),
              onChanged: (_) => setState(() => _fieldErrors.remove('whatsapp')),
            ),
          ),
          GroupedRow(
            title: s.bizPageShowCity,
            trailing: Switch.adaptive(
              value: _showCity,
              onChanged: (b) => setState(() => _showCity = b),
            ),
          ),
        ],
      ),
      if (_fieldErrors['category'] != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _fieldErrors['category']!,
            style: TextStyle(color: colors.danger, fontSize: 12.5),
          ),
        ),
      _fieldHints(s),
      _hint(s.bizPageFooterHint),
    ];
  }

  /// Mensagens de validação dos campos já tocados (E-mail e WhatsApp).
  Widget _fieldHints(S s) {
    final errs = <String?>[
      if (_emailCtrl.text.isNotEmpty) _emailError(s),
      if (_phoneCtrl.text.isNotEmpty) _phoneError(s),
    ].whereType<String>().toList();
    if (errs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in errs)
            Text(
              e,
              style: TextStyle(color: context.colors.danger, fontSize: 12.5),
            ),
        ],
      ),
    );
  }

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    String? action,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentPrimary,
                  foregroundColor: colors.textOnAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => context.push('/account/verify/business'),
                child: Text(action),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Nome traduzido da categoria da empresa (chave do servidor).
String businessCategoryLabel(S s, String key) => switch (key) {
  'fashion_beauty' => s.bizPageCatFashionBeauty,
  'tech' => s.bizPageCatTech,
  'food' => s.bizPageCatFood,
  'entertainment' => s.bizPageCatEntertainment,
  'education' => s.bizPageCatEducation,
  'health' => s.bizPageCatHealth,
  'finance' => s.bizPageCatFinance,
  'retail' => s.bizPageCatRetail,
  'music' => s.bizPageCatMusic,
  'games' => s.bizPageCatGames,
  'sports' => s.bizPageCatSports,
  'real_estate' => s.bizPageCatRealEstate,
  'agro' => s.bizPageCatAgro,
  'services' => s.bizPageCatServices,
  'ngo' => s.bizPageCatNgo,
  _ => s.bizPageCatOther,
};
