/// Wallet model. Mirrors brawe-connect/backend GET /credits/balance.
class Wallet {
  final double balance;
  final String currency;
  final String? accountNumber;
  final bool hasAccount;

  const Wallet({
    required this.balance,
    required this.currency,
    this.accountNumber,
    required this.hasAccount,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? 'USD',
      accountNumber: json['account_number'] as String?,
      hasAccount: json['has_account'] as bool? ?? false,
    );
  }
}

/// Static coin packages — mirrors web COIN_PACKAGES at frontend/app/[locale]/connect/coins/page.tsx
class CoinPackage {
  final String id;
  final int coins;
  final double priceBRL;
  final double priceUSD;
  final String label;
  final bool popular;
  final bool bestValue;

  const CoinPackage({
    required this.id,
    required this.coins,
    required this.priceBRL,
    required this.priceUSD,
    this.label = '',
    this.popular = false,
    this.bestValue = false,
  });
}

const kCoinPackages = <CoinPackage>[
  CoinPackage(id: 'pack_83', coins: 83, priceBRL: 5, priceUSD: 1),
  CoinPackage(id: 'pack_416', coins: 416, priceBRL: 25, priceUSD: 5),
  CoinPackage(
    id: 'pack_2083',
    coins: 2083,
    priceBRL: 125,
    priceUSD: 25,
    popular: true,
    label: 'POPULAR',
  ),
  CoinPackage(id: 'pack_10416', coins: 10416, priceBRL: 625, priceUSD: 125),
  CoinPackage(id: 'pack_52083', coins: 52083, priceBRL: 3125, priceUSD: 625),
  CoinPackage(
    id: 'pack_260416',
    coins: 260416,
    priceBRL: 15625,
    priceUSD: 3125,
    bestValue: true,
    label: 'MELHOR VALOR',
  ),
];


/// Single gift transaction (sent or received).
class WalletTransaction {
  final String id;
  final String type; // 'sent' | 'received'
  final String counterpartyName;
  final String counterpartyId;
  final String giftName;
  final int quantity;
  final int amountCredits; // negative if sent
  final double amountUsdt;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.counterpartyName,
    required this.counterpartyId,
    required this.giftName,
    required this.quantity,
    required this.amountCredits,
    required this.amountUsdt,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'received').toString(),
      counterpartyName: (json['counterparty_name'] ?? '').toString(),
      counterpartyId: (json['counterparty_id'] ?? '').toString(),
      giftName: (json['gift_name'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      amountCredits: (json['amount_credits'] as num?)?.toInt() ?? 0,
      amountUsdt: (json['amount_usdt'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }
}
