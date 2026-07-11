import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers/cart_notifier_provider.dart';
import '../../../data/providers/marketplace_providers.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/marketplace_models.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../utils/currency_formatter.dart';

enum _ShippingMethod { standard, express }

enum _PaymentMethod { pix, card, crypto }

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
  final _documentController = TextEditingController();

  // New address form fields
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();

  ShippingAddress? _selectedAddress;
  _ShippingMethod _shippingMethod = _ShippingMethod.standard;
  _PaymentMethod _paymentMethod = _PaymentMethod.pix;

  bool _isSubmitting = false;
  bool _isSavingAddress = false;

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
    _documentController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1280;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          S.of(context).shopCheckoutTitle,
          style: TextStyle(color: context.colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: isDesktop
              ? _buildDesktopLayout(context, cartState)
              : _buildMobileLayout(context, cartState),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CartState cartState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressSection(context),
          const SizedBox(height: 24),
          _buildCustomerSection(context),
          const SizedBox(height: 24),
          _buildShippingSection(context),
          const SizedBox(height: 24),
          _buildPaymentSection(context),
          const SizedBox(height: 24),
          _buildSummarySection(context, cartState),
          const SizedBox(height: 24),
          _buildConfirmButton(context, cartState),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CartState cartState) {
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
                _buildAddressSection(context),
                const SizedBox(height: 24),
                _buildCustomerSection(context),
                const SizedBox(height: 24),
                _buildShippingSection(context),
                const SizedBox(height: 24),
                _buildPaymentSection(context),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummarySection(context, cartState),
                const SizedBox(height: 24),
                _buildConfirmButton(context, cartState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sections ───────────────────────────────────────────────────────

  Widget _sectionCard(BuildContext context, String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    final addressesAsync = ref.watch(savedAddressesProvider);

    return _sectionCard(
      context,
      S.of(context).shopCheckoutAddressSection,
      addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _buildAddressForm(context),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).shopCheckoutAddressEmpty,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 12),
                _buildAddressForm(context),
              ],
            );
          }

          _selectedAddress ??= addresses.first;

          return RadioGroup<ShippingAddress>(
            groupValue: _selectedAddress,
            onChanged: (value) => setState(() => _selectedAddress = value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final address in addresses)
                  RadioListTile<ShippingAddress>(
                    contentPadding: EdgeInsets.zero,
                    value: address,
                    activeColor: context.colors.accentPrimary,
                    title: Text(
                      '${address.street}, ${address.number}',
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                    subtitle: Text(
                      '${address.neighborhood}, ${address.city} - ${address.state} · ${address.postalCode}',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _textField(
          context,
          _postalCodeController,
          S.of(context).shopCheckoutAddressPostalCode,
        ),
        const SizedBox(height: 12),
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
    return _sectionCard(
      context,
      S.of(context).shopCheckoutCustomerSection,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: _inputDecoration(
              context,
              S.of(context).shopCheckoutCustomerName,
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? S.of(context).shopCheckoutNameRequired
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
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
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: _inputDecoration(
              context,
              S.of(context).shopCheckoutCustomerPhone,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _documentController,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: _inputDecoration(
              context,
              S.of(context).shopCheckoutCustomerDocument,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingSection(BuildContext context) {
    return _sectionCard(
      context,
      S.of(context).shopCheckoutShippingSection,
      RadioGroup<_ShippingMethod>(
        groupValue: _shippingMethod,
        onChanged: (value) => setState(() => _shippingMethod = value!),
        child: Column(
          children: [
            RadioListTile<_ShippingMethod>(
              contentPadding: EdgeInsets.zero,
              value: _ShippingMethod.standard,
              activeColor: context.colors.accentPrimary,
              title: Text(
                S.of(context).shopCheckoutShippingStandard,
                style: TextStyle(color: context.colors.textPrimary),
              ),
            ),
            RadioListTile<_ShippingMethod>(
              contentPadding: EdgeInsets.zero,
              value: _ShippingMethod.express,
              activeColor: context.colors.accentPrimary,
              title: Text(
                S.of(context).shopCheckoutShippingExpress,
                style: TextStyle(color: context.colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return _sectionCard(
      context,
      S.of(context).shopCheckoutPaymentSection,
      RadioGroup<_PaymentMethod>(
        groupValue: _paymentMethod,
        onChanged: (value) => setState(() => _paymentMethod = value!),
        child: Column(
          children: [
            RadioListTile<_PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              value: _PaymentMethod.pix,
              activeColor: context.colors.accentPrimary,
              title: Text(
                S.of(context).shopCheckoutPaymentPix,
                style: TextStyle(color: context.colors.textPrimary),
              ),
            ),
            RadioListTile<_PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              value: _PaymentMethod.card,
              activeColor: context.colors.accentPrimary,
              title: Text(
                S.of(context).shopCheckoutPaymentCard,
                style: TextStyle(color: context.colors.textPrimary),
              ),
            ),
            RadioListTile<_PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              value: _PaymentMethod.crypto,
              activeColor: context.colors.accentPrimary,
              title: Text(
                S.of(context).shopCheckoutPaymentCrypto,
                style: TextStyle(color: context.colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartState cartState) {
    return _sectionCard(
      context,
      S.of(context).shopCheckoutSummarySection,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in cartState.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.productName}',
                      style: TextStyle(color: context.colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatBRL(item.totalPrice),
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).shopCheckoutSubtotal,
                style: TextStyle(color: context.colors.textSecondary),
              ),
              Text(
                formatBRL(cartState.subtotal),
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).shopCheckoutTotal,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatBRL(cartState.total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, CartState cartState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isSubmitting || cartState.isEmpty)
            ? null
            : () => _confirmOrder(context, cartState),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.accentPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                S.of(context).shopCheckoutConfirmOrder,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
      style: TextStyle(color: context.colors.textPrimary),
      decoration: _inputDecoration(context, label),
      validator: required
          ? (value) => (value == null || value.trim().isEmpty)
                ? S.of(context).shopCheckoutAddressRequired
                : null
          : null,
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: context.colors.textSecondary),
      filled: true,
      fillColor: context.colors.surfaceHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  ShippingAddress? _buildAddressFromForm() {
    if (_streetController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty ||
        _neighborhoodController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _postalCodeController.text.trim().isEmpty) {
      return null;
    }
    return ShippingAddress(
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      complement: _complementController.text.trim().isEmpty
          ? null
          : _complementController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
    );
  }

  Future<void> _saveAddress(BuildContext context) async {
    final address = _buildAddressFromForm();
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).shopCheckoutAddressRequired)),
      );
      return;
    }

    setState(() => _isSavingAddress = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final saved = await repo.createAddress(address) as ShippingAddress;
      ref.invalidate(savedAddressesProvider);
      setState(() {
        _selectedAddress = saved;
        _isSavingAddress = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).shopCheckoutAddressSaved)),
        );
      }
    } catch (_) {
      setState(() => _isSavingAddress = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).shopCheckoutAddressSaveError)),
        );
      }
    }
  }

  Future<void> _confirmOrder(BuildContext context, CartState cartState) async {
    if (!_formKey.currentState!.validate()) return;

    final address = _selectedAddress ?? _buildAddressFromForm();
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).shopCheckoutAddressRequired)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = CheckoutRequest(
      shippingAddress: address,
      customerName: _nameController.text.trim(),
      customerEmail: _emailController.text.trim(),
      customerPhone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      customerDocument: _documentController.text.trim().isEmpty
          ? null
          : _documentController.text.trim(),
      shippingMethod: _shippingMethod == _ShippingMethod.express
          ? 'express'
          : 'standard',
      paymentMethod: switch (_paymentMethod) {
        _PaymentMethod.pix => 'pix',
        _PaymentMethod.card => 'card',
        _PaymentMethod.crypto => 'crypto',
      },
      sessionId: CartSession.id,
    );

    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final order = await repo.checkout(request) as Order;
      if (!context.mounted) return;
      setState(() => _isSubmitting = false);
      context.pushReplacement('/shop/checkout/payment/${order.id}');
    } catch (_) {
      setState(() => _isSubmitting = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).shopCheckoutError)),
        );
      }
    }
  }
}
