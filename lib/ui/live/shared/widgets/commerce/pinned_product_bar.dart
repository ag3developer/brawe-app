import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/services/socket_service.dart';

/// 🛒 Produto pinado (event-driven via Socket).
///
/// Modelo imutável representando o produto que o streamer pinou na live.
/// Use [PinnedProduct.tryParse] para parse defensivo de payloads do Socket
/// (`product_pinned` event).
class PinnedProduct {
  const PinnedProduct({
    required this.id,
    required this.name,
    required this.priceLabel,
    this.subtitle,
    this.thumbnailUrl,
  });
  final String id;
  final String name;
  final String priceLabel;
  final String? subtitle;
  final String? thumbnailUrl;

  static PinnedProduct? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = (raw['id'] ?? raw['product_id'] ?? '').toString();
    final name = (raw['name'] ?? raw['title'] ?? '').toString();
    if (id.isEmpty || name.isEmpty) return null;
    final priceRaw = raw['price_label'] ??
        raw['priceLabel'] ??
        (raw['price'] != null ? 'R\$ ${raw['price']}' : '');
    final subtitleRaw =
        raw['subtitle'] ?? raw['short_description'] ?? raw['description'];
    return PinnedProduct(
      id: id,
      name: name,
      priceLabel: priceRaw.toString(),
      subtitle: subtitleRaw?.toString(),
      thumbnailUrl: (raw['thumbnail_url'] ?? raw['image_url'] ?? raw['thumb'])
          ?.toString(),
    );
  }
}

/// Barra de produto pinado (event-driven).
///
/// Aparece com slide-in suave quando o streamer pinar um produto da
/// vitrine via Socket (`product_pinned`). Some com slide-out quando o
/// streamer despinar (`product_unpinned`). Tap → abre drawer/checkout.
///
/// Estilo: pílula glass minimalista, mini-thumb + nome + preço + chevron.
/// Nada de card pesado — mantém o vídeo como protagonista.
class PinnedProductBar extends ConsumerStatefulWidget {
  const PinnedProductBar({super.key, required this.roomId});
  final String roomId;

  @override
  ConsumerState<PinnedProductBar> createState() => _PinnedProductBarState();
}

class _PinnedProductBarState extends ConsumerState<PinnedProductBar> {
  PinnedProduct? _product;

  late final void Function(dynamic) _onPinned;
  late final void Function(dynamic) _onUnpinned;

  @override
  void initState() {
    super.initState();
    _onPinned = (data) {
      final p = PinnedProduct.tryParse(
          data is Map ? data['product'] ?? data : data);
      if (!mounted || p == null) return;
      setState(() => _product = p);
    };
    _onUnpinned = (_) {
      if (!mounted) return;
      setState(() => _product = null);
    };
    final socket = ref.read(socketServiceProvider);
    socket.on('product_pinned', _onPinned);
    socket.on('product_unpinned', _onUnpinned);
  }

  @override
  void dispose() {
    try {
      final socket = ref.read(socketServiceProvider);
      socket.off('product_pinned', _onPinned);
      socket.off('product_unpinned', _onUnpinned);
    } catch (_) {}
    super.dispose();
  }

  void _openProduct() {
    final p = _product;
    if (p == null) return;
    // TODO: substituir por sheet de checkout/produto real.
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A0B14),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.priceLabel,
                style: const TextStyle(
                  color: Color(0xFFB44CF0),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Abrir produto na vitrine — em breve.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.6),
          end: Offset.zero,
        ).animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: p == null
          ? const SizedBox(key: ValueKey('empty'), height: 0)
          : Padding(
              key: ValueKey('pinned-${p.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: _openProduct,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                              width: 0.6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // ── Thumb 64×64 ─────────────────────────
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: p.thumbnailUrl != null
                                      ? Image.network(
                                          p.thumbnailUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _thumbPlaceholder(),
                                        )
                                      : _thumbPlaceholder(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // ── Título · subtítulo · preço ──────────
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        height: 1.15,
                                      ),
                                    ),
                                    if ((p.subtitle ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        p.subtitle!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.65),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.15,
                                        ),
                                      ),
                                    ],
                                    if (p.priceLabel.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        p.priceLabel,
                                        style: const TextStyle(
                                          color: Color(0xFFFFC56B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // ── Botão "Ver produto" gradient pill ──
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF4F8B),
                                      Color(0xFFB44CF0),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB44CF0)
                                          .withValues(alpha: 0.45),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Ver produto',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ── Pin icon top-right (decorativo) ─────────
                        Positioned(
                          top: 6,
                          right: 8,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFB44CF0)
                                  .withValues(alpha: 0.22),
                              border: Border.all(
                                color: const Color(0xFFB44CF0)
                                    .withValues(alpha: 0.55),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.push_pin_rounded,
                              color: Color(0xFFD9B4FF),
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _thumbPlaceholder() => Container(
        color: Colors.white.withValues(alpha: 0.08),
        child: const Icon(Icons.shopping_bag_outlined,
            color: Colors.white54, size: 18),
      );
}
