import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/providers/affiliate_origin_provider.dart';
import '../../../data/providers/cart_notifier_provider.dart';
import '../../../data/providers/marketplace_providers.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/viacep_service.dart';
import '../../../domain/models/marketplace_models.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/mask_formatter.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../widgets/checkout/address_selection_sheet.dart';
import '../widgets/checkout/checkout_bottom_bar.dart';
import '../widgets/checkout/checkout_terms.dart';
import '../widgets/checkout/delivery_address_section.dart';
import '../widgets/checkout/order_price_summary.dart';
import '../widgets/checkout/payment_method_section.dart';
import '../widgets/checkout/store_section.dart';

enum _ShippingMethod { standard, express }

enum _DocumentType { cpf, cnpj }

/// Checkout page accessed via `/shop/checkout` route.
///
/// Collects shipping address, customer info, shipping method and payment
/// method, then submits a [CheckoutRequest] via
/// `marketplaceRepositoryProvider.checkout`.
///
/// **TODO (gap):** Real payment gateway integration (Wolknow) is out of
/// scope for this task — `paymentMethod` is only collected as a string here
/// and handled by [ShopPaymentPage] afterwards.
class ShopCheckoutPage extends ConsumerStatefulWidget {
  const ShopCheckoutPage({super.key});

  @override
  ConsumerState<ShopCheckoutPage> createState() => _ShopCheckoutPageState();
}

class _ShopCheckoutPageState extends ConsumerState<ShopCheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Customer fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // New address form fields
  final _labelController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  // Dados fiscais do destinatário — OBRIGATÓRIOS: a loja precisa desses
  // dados para emitir NF do pedido físico (não é opcional em compras reais).
  final _recipientNameController = TextEditingController();
  final _recipientDocumentController = TextEditingController();
  _DocumentType _documentType = _DocumentType.cpf;

  ShippingAddress? _selectedAddress;
  // Controla explicitamente a intenção de "usar outro endereço" — sem essa
  // flag, `_selectedAddress ??= addresses.first` no build reatribuiria o
  // endereço salvo assim que o usuário zerasse a seleção, escondendo o
  // formulário de novo endereço antes mesmo dele aparecer.
  bool _addingNewAddress = false;
  // Sem seletor de método de envio na UI: o backend não expõe custos
  // diferentes para padrão/expresso ainda, então mantemos 'standard' fixo
  // em vez de mostrar uma opção que não afeta nada de real no pedido.
  final _shippingMethod = _ShippingMethod.standard;
  CheckoutPaymentMethod _paymentMethod = CheckoutPaymentMethod.pix;

  bool _isSubmitting = false;
  bool _isSavingAddress = false;
  bool _isFetchingCep = false;
  String? _cepError;
  bool _cepFilled = false;
  // Erros mostrados na própria tela (junto do botão), não em SnackBar.
  String? _addressError;
  String? _submitError;
  double _calculatedShipping = 0.0;

  // Quantidade sendo atualizada por item — evita múltiplas requisições
  // simultâneas para o mesmo item (o usuário vê um spinner local nesse
  // item enquanto a chamada está em andamento).
  final Set<String> _updatingItemIds = <String>{};

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _labelController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _recipientNameController.dispose();
    _recipientDocumentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final addressesAsync = ref.watch(savedAddressesProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1280;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 48,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            size: 20,
            color: context.colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          S.of(context).shopCheckoutTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: isDesktop
                    ? _buildDesktopLayout(context, cartState, addressesAsync)
                    : _buildMobileLayout(context, cartState, addressesAsync),
              ),
              if (_submitError != null)
                _InlineNotice(message: _submitError!, isError: true),
              CheckoutBottomBar(
                itemCount: cartState.itemCount,
                total: cartState.total,
                isSubmitting: _isSubmitting,
                enabled: !cartState.isEmpty,
                onConfirm: () => _confirmOrder(context, cartState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CartState cartState,
    AsyncValue<List<ShippingAddress>> addressesAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressBlock(context, addressesAsync),
          const SizedBox(height: 10),
          ..._buildStoreSections(context, cartState),
          const SizedBox(height: 10),
          _buildCustomerSection(context),
          const SizedBox(height: 10),
          OrderPriceSummary(
            subtotal: cartState.subtotal,
            shipping: _calculatedShipping > 0
                ? _calculatedShipping
                : cartState.shipping,
            discount: cartState.discount,
            total:
                cartState.subtotal -
                cartState.discount +
                (_calculatedShipping > 0
                    ? _calculatedShipping
                    : cartState.shipping),
          ),
          const SizedBox(height: 10),
          PaymentMethodSection(
            selected: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),
          const SizedBox(height: 16),
          const CheckoutTerms(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CartState cartState,
    AsyncValue<List<ShippingAddress>> addressesAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressBlock(context, addressesAsync),
                const SizedBox(height: 10),
                ..._buildStoreSections(context, cartState),
                const SizedBox(height: 10),
                _buildCustomerSection(context),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OrderPriceSummary(
                  subtotal: cartState.subtotal,
                  shipping: _calculatedShipping > 0
                      ? _calculatedShipping
                      : cartState.shipping,
                  discount: cartState.discount,
                  total:
                      cartState.subtotal -
                      cartState.discount +
                      (_calculatedShipping > 0
                          ? _calculatedShipping
                          : cartState.shipping),
                ),
                const SizedBox(height: 10),
                PaymentMethodSection(
                  selected: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v),
                ),
                const SizedBox(height: 16),
                const CheckoutTerms(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Address block (compact, single address + bottom sheet) ───────────

  Widget _buildAddressBlock(
    BuildContext context,
    AsyncValue<List<ShippingAddress>> addressesAsync,
  ) {
    return addressesAsync.when(
      loading: () => Container(
        height: 64,
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      error: (_, _) => _buildAddressForm(context),
      data: (addresses) {
        if (addresses.isEmpty || _addingNewAddress) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (addresses.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.of(context).shopCheckoutAddNewAddress,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _addingNewAddress = false;
                        _selectedAddress = addresses.first;
                      }),
                      child: Text(S.of(context).actionCancel),
                    ),
                  ],
                ),
              _sectionCard(
                context,
                S.of(context).shopCheckoutAddressSection,
                _buildAddressForm(context),
              ),
            ],
          );
        }

        _selectedAddress ??= addresses.first;
        return DeliveryAddressSection(
          address: _selectedAddress!,
          customerPhone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          onTap: () => _openAddressSelection(context, addresses),
        );
      },
    );
  }

  Future<void> _openAddressSelection(
    BuildContext context,
    List<ShippingAddress> addresses,
  ) async {
    final result = await AddressSelectionSheet.show(
      context,
      addresses: addresses,
      selected: _selectedAddress,
    );
    if (result == null || !mounted) return;
    if (result == '__new__') {
      setState(() {
        _addingNewAddress = true;
        _selectedAddress = null;
        _calculatedShipping = 0.0;
      });
      return;
    }
    if (result is ShippingAddress) {
      setState(() => _selectedAddress = result);
      // Calculate shipping cost when address is selected
      await _calculateShippingCost(context);
    }
  }

  Future<void> _calculateShippingCost(BuildContext context) async {
    if (_selectedAddress == null) return;

    try {
      final cartState = ref.read(cartNotifierProvider);
      final repository = ref.read(marketplaceRepositoryProvider);

      // Group items by store to calculate shipping per store
      final byStore = <String, List<CartItem>>{};
      for (final item in cartState.items) {
        byStore.putIfAbsent(item.storeId, () => []).add(item);
      }

      double totalShipping = 0.0;
      for (final storeId in byStore.keys) {
        try {
          final shippingResponse = await repository.calculateShipping(
            storeId,
            _selectedAddress!.postalCode.replaceAll(RegExp(r'\D'), ''),
          );

          // Response is {options: [{id, name, price, ...}]}
          // Select the cheapest option (or first standard option)
          if (shippingResponse is Map<String, dynamic> &&
              shippingResponse.containsKey('options')) {
            final options = shippingResponse['options'] as List?;
            if (options != null && options.isNotEmpty) {
              // Find 'standard' method or use first option
              dynamic selectedOption = options.firstWhere(
                (opt) => opt['id'] == 'standard',
                orElse: () => options.first,
              );

              if (selectedOption is Map<String, dynamic>) {
                final price = selectedOption['price'];
                if (price is num) {
                  totalShipping += price.toDouble();
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error calculating shipping for store $storeId: $e');
        }
      }

      if (mounted) {
        setState(() {
          _calculatedShipping = totalShipping;
        });
      }
    } catch (e) {
      debugPrint('Error calculating shipping: $e');
    }
  }

  // ─── Store sections (grouped cart items) ───────────────────────────────

  List<Widget> _buildStoreSections(BuildContext context, CartState cartState) {
    if (cartState.items.isEmpty) return const [];

    // Agrupa por loja (dado real via CartItem.storeId/storeName) — se todo
    // o carrinho for de uma única loja, isso gera apenas 1 seção; se houver
    // múltiplas lojas, uma seção por loja, cada uma com seu próprio frete.
    final byStore = <String, List<CartItem>>{};
    for (final item in cartState.items) {
      byStore.putIfAbsent(item.storeId, () => []).add(item);
    }

    final storeIds = byStore.keys.toList();
    // O frete/desconto atual vem agregado no carrinho (não por loja) — ao
    // dividir por múltiplas lojas, distribuímos o mesmo total já calculado
    // apenas na primeira seção, para não inventar valores por loja que o
    // backend não fornece.
    return [
      for (var i = 0; i < storeIds.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: StoreSection(
            storeName: byStore[storeIds[i]]!.first.storeName,
            items: byStore[storeIds[i]]!,
            shippingCost: i == 0 ? cartState.shipping : 0,
            isFreeShipping: i == 0 && cartState.shipping == 0,
            isUpdating: (item) => _updatingItemIds.contains(item.id),
            onQuantityChanged: _onQuantityChanged,
          ),
        ),
    ];
  }

  Future<void> _onQuantityChanged(CartItem item, int newQuantity) async {
    // Evita disparar uma nova requisição para o mesmo item enquanto a
    // anterior ainda está em andamento (previne múltiplas chamadas
    // simultâneas ao tocar rapidamente em +/-).
    if (_updatingItemIds.contains(item.id)) return;
    setState(() => _updatingItemIds.add(item.id));
    try {
      if (newQuantity < 1) {
        await ref.read(cartNotifierProvider.notifier).removeItem(item.id);
      } else {
        await ref
            .read(cartNotifierProvider.notifier)
            .updateQuantity(item.id, newQuantity);
      }
    } finally {
      if (mounted) setState(() => _updatingItemIds.remove(item.id));
    }
  }

  // ─── Sections ───────────────────────────────────────────────────────

  Widget _sectionCard(BuildContext context, String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.overlay.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildAddressForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textField(
          context,
          _labelController,
          S.of(context).shopCheckoutAddressLabel,
          required: false,
        ),
        const SizedBox(height: 12),
        _textField(
          context,
          _streetController,
          S.of(context).shopCheckoutAddressStreet,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _textField(
                context,
                _numberController,
                S.of(context).shopCheckoutAddressNumber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _textField(
                context,
                _complementController,
                S.of(context).shopCheckoutAddressComplement,
                required: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _textField(
          context,
          _neighborhoodController,
          S.of(context).shopCheckoutAddressNeighborhood,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _textField(
                context,
                _cityController,
                S.of(context).shopCheckoutAddressCity,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _textField(
                context,
                _stateController,
                S.of(context).shopCheckoutAddressState,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCepField(context),
        const SizedBox(height: 20),
        Divider(color: context.colors.divider, height: 1),
        const SizedBox(height: 16),
        Text(
          S.of(context).shopCheckoutRecipientSection,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          S.of(context).shopCheckoutRecipientHint,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _textField(
          context,
          _recipientNameController,
          S.of(context).shopCheckoutRecipientName,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<_DocumentType>(
                initialValue: _documentType,
                decoration: _inputDecoration(
                  context,
                  S.of(context).shopCheckoutDocumentType,
                ),
                dropdownColor: context.colors.surfaceElevated,
                style: TextStyle(color: context.colors.textPrimary),
                items: [
                  DropdownMenuItem(
                    value: _DocumentType.cpf,
                    child: const Text('CPF'),
                  ),
                  DropdownMenuItem(
                    value: _DocumentType.cnpj,
                    child: const Text('CNPJ'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _documentType = value;
                    // reaplica a máscara do novo tipo ao que já foi digitado
                    final mask = value == _DocumentType.cpf
                        ? DigitMask.cpf
                        : DigitMask.cnpj;
                    _recipientDocumentController.text = mask.apply(
                      _recipientDocumentController.text,
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _recipientDocumentController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  _documentType == _DocumentType.cpf
                      ? DigitMask.cpf
                      : DigitMask.cnpj,
                ],
                style: TextStyle(color: context.colors.textPrimary),
                decoration: _inputDecoration(
                  context,
                  _documentType == _DocumentType.cpf ? 'CPF' : 'CNPJ',
                ),
                validator: _validateDocument,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_addressError != null) ...[
          _InlineNotice(message: _addressError!, isError: true),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isSavingAddress ? null : () => _saveAddress(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colors.border),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isSavingAddress
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(S.of(context).shopCheckoutAddressSave),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSection(BuildContext context) {
    // Nome já vem do destinatário do endereço (evita repetir a mesma
    // informação em dois lugares da tela) — aqui só e-mail (para o
    // recibo) e telefone (usado no bloco compacto de endereço, mascarado).
    // Ambos pré-preenchidos a partir do perfil quando disponível.
    return _sectionCard(
      context,
      S.of(context).shopCheckoutCustomerSection,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: _inputDecoration(
              context,
              S.of(context).shopCheckoutCustomerEmail,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return S.of(context).shopCheckoutEmailRequired;
              }
              if (!value.contains('@') || !value.contains('.')) {
                return S.of(context).shopCheckoutEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [DigitMask.phoneBr],
            style: TextStyle(color: context.colors.textPrimary),
            decoration: _inputDecoration(
              context,
              S.of(context).shopCheckoutCustomerPhone,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  Widget _textField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(color: context.colors.textPrimary),
      decoration: _inputDecoration(context, label),
      validator: required
          ? (value) => (value == null || value.trim().isEmpty)
                ? S.of(context).shopCheckoutAddressRequired
                : null
          : null,
    );
  }

  Widget _buildCepField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _postalCodeController,
          style: TextStyle(color: context.colors.textPrimary),
          inputFormatters: [DigitMask.cep],
          decoration:
              _inputDecoration(
                context,
                S.of(context).shopCheckoutAddressPostalCode,
              ).copyWith(
                suffixIcon: _isFetchingCep
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              context.colors.accentPrimary,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return S.of(context).shopCheckoutAddressRequired;
            }
            if (!ViaCepService.isValidCepFormat(value)) {
              return S.of(context).moneyCheckoutCepInvalid;
            }
            return null;
          },
          onChanged: (value) {
            // Auto-fetch address when CEP is complete
            if (ViaCepService.isValidCepFormat(value) && _cepError == null) {
              _fetchAddressFromCep(value, context);
            }
            setState(() {
              _cepError = null;
              _cepFilled = false;
            });
          },
        ),
        if (_cepError != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _cepError!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.colors.danger),
            ),
          ),
        ] else if (_cepFilled) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  LucideIcons.circleCheck,
                  size: 14,
                  color: context.colors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  S.of(context).moneyCheckoutCepFilled,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _fetchAddressFromCep(String cep, BuildContext context) async {
    setState(() {
      _isFetchingCep = true;
      _cepError = null;
    });

    try {
      final viaCepService = ref.read(viaCepServiceProvider);
      final address = await viaCepService.searchCep(cep);

      // Auto-fill other fields
      setState(() {
        _streetController.text = address.street;
        _neighborhoodController.text = address.neighborhood;
        _cityController.text = address.city;
        _stateController.text = address.state;
        _isFetchingCep = false;
        _cepFilled = true;
      });
    } on InvalidCepException catch (e) {
      setState(() {
        _cepError = e.message;
        _isFetchingCep = false;
      });
    } catch (e) {
      setState(() {
        _cepError = S.of(context).moneyCheckoutCepLookupError;
        _isFetchingCep = false;
      });
    }
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: context.colors.textSecondary),
      filled: true,
      fillColor: context.colors.surfaceHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colors.accentPrimary, width: 1.5),
      ),
    );
  }

  ShippingAddress? _buildAddressFromForm() {
    if (_streetController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty ||
        _neighborhoodController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _postalCodeController.text.trim().isEmpty ||
        _recipientNameController.text.trim().isEmpty ||
        _validateDocument(_recipientDocumentController.text) != null) {
      return null;
    }
    return ShippingAddress(
      label: _labelController.text.trim().isEmpty
          ? null
          : _labelController.text.trim(),
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      complement: _complementController.text.trim().isEmpty
          ? null
          : _complementController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      documentType: _documentType == _DocumentType.cpf ? 'cpf' : 'cnpj',
      documentNumber: _recipientDocumentController.text.trim().replaceAll(
        RegExp(r'\D'),
        '',
      ),
      recipientName: _recipientNameController.text.trim(),
    );
  }

  /// Valida CPF (11 dígitos) ou CNPJ (14 dígitos) conforme [_documentType].
  /// Não valida os dígitos verificadores (isso é feito no backend) — aqui
  /// só garante que o usuário preencheu algo com o tamanho certo, para dar
  /// feedback imediato no formulário.
  String? _validateDocument(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    final expectedLength = _documentType == _DocumentType.cpf ? 11 : 14;
    if (digits.isEmpty) {
      return S.of(context).shopCheckoutDocumentRequired;
    }
    if (digits.length != expectedLength) {
      return _documentType == _DocumentType.cpf
          ? S.of(context).shopCheckoutCpfInvalid
          : S.of(context).shopCheckoutCnpjInvalid;
    }
    return null;
  }

  Future<void> _saveAddress(BuildContext context) async {
    final address = _buildAddressFromForm();
    if (address == null) {
      setState(() => _addressError = S.of(context).shopCheckoutAddressRequired);
      _formKey.currentState?.validate();
      return;
    }

    setState(() {
      _isSavingAddress = true;
      _addressError = null;
    });
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final saved = await repo.createAddress(address) as ShippingAddress;
      ref.invalidate(savedAddressesProvider);
      setState(() {
        _selectedAddress = saved;
        _addingNewAddress = false;
        _isSavingAddress = false;
      });
      // o endereço salvo aparece no cartão de entrega; sem aviso extra
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSavingAddress = false;
        _addressError = S.of(context).shopCheckoutAddressSaveError;
      });
    }
  }

  Future<void> _confirmOrder(BuildContext context, CartState cartState) async {
    // Guarda extra contra duplo-clique/duplo-tap: o botão já desabilita
    // com `isSubmitting`, mas isso reforça mesmo se _confirmOrder for
    // chamado novamente antes do primeiro setState ser aplicado — evita
    // criar dois pedidos para a mesma compra.
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final address = _selectedAddress ?? _buildAddressFromForm();
    if (address == null) {
      setState(() => _submitError = S.of(context).shopCheckoutAddressRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    // ⭐ CRÍTICO: preserva a atribuição do afiliado capturada na vitrine
    // (via ?ref=... ou ?affiliate_code=...) e persistida em
    // AffiliateOriginManager. Sem isso, o pedido nunca registra comissão
    // mesmo quando a compra começou por um link de afiliado.
    String? affiliateId;
    try {
      final affiliateManager = await ref.read(
        affiliateOriginManagerProvider.future,
      );
      affiliateId = affiliateManager.getStoredAffiliateId();
    } catch (e) {
      debugPrint('⚠️ Failed to read affiliate origin: $e');
    }

    final request = CheckoutRequest(
      shippingAddress: address,
      customerName: _nameController.text.trim(),
      customerEmail: _emailController.text.trim(),
      customerPhone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      // CPF/CNPJ do DESTINATÁRIO do endereço — obrigatório para a loja
      // emitir NF do pedido (ver ShippingAddress.documentNumber).
      customerDocument: address.documentNumber,
      shippingMethod: _shippingMethod == _ShippingMethod.express
          ? 'express'
          : 'standard',
      shippingCost: _calculatedShipping > 0 ? _calculatedShipping : 0.0,
      paymentMethod: switch (_paymentMethod) {
        CheckoutPaymentMethod.pix => 'pix',
        CheckoutPaymentMethod.card => 'card',
        CheckoutPaymentMethod.crypto => 'crypto',
      },
      sessionId: CartSession.id,
      affiliateId: affiliateId,
    );

    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      debugPrint('📤 Sending checkout request...');
      final rawResponse = await repo.checkout(request);
      debugPrint('📥 Raw response: $rawResponse');
      debugPrint('📥 Response type: ${rawResponse.runtimeType}');

      final order = rawResponse as Order;
      if (!context.mounted) return;
      setState(() => _isSubmitting = false);
      debugPrint('✅ Order created successfully: ${order.id}');
      debugPrint(
        '🔀 Navigating to payment page: /shop/checkout/payment/${order.id}',
      );
      context.pushReplacement('/shop/checkout/payment/${order.id}');
    } catch (e) {
      debugPrint('❌ Checkout error: $e');
      debugPrint('❌ Error stack: ${StackTrace.current}');
      debugPrint('❌ Error type: ${e.runtimeType}');
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = S.of(context).shopCheckoutError;
      });
    }
  }
}

/// Aviso na própria tela (no lugar de SnackBar): ícone + mensagem em cartão discreto.
class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, this.isError = false});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = isError ? c.danger : c.success;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isError ? LucideIcons.circleAlert : LucideIcons.circleCheck,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
