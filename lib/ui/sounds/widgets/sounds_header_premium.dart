import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Header premium para Brawe Sounds com design elegante e moderno.
///
/// Features:
/// - Gradiente de marca fixo no fundo
/// - Ícone grande e destacado
/// - Título com subtítulo
/// - Search bar integrada
/// - Tabs com indicador premium
/// - Animação de entrada suave
class SoundsPremiumHeader extends StatefulWidget {
  final TabController tabs;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSearch;

  const SoundsPremiumHeader({
    super.key,
    required this.tabs,
    required this.searchCtrl,
    required this.onSearch,
    required this.onClearSearch,
  });

  @override
  State<SoundsPremiumHeader> createState() => _SoundsPremiumHeaderState();
}

class _SoundsPremiumHeaderState extends State<SoundsPremiumHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      backgroundColor: colors.background,
      elevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        collapseMode: CollapseMode.parallax,
        background: _buildExpandedHeader(context, s, colors, isDark),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(108),
        child: _buildSearchAndTabs(context, s, colors),
      ),
    );
  }

  Widget _buildExpandedHeader(
    BuildContext context,
    S s,
    BraweColors colors,
    bool isDark,
  ) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideIn,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.braweBlue.withValues(alpha: 0.12),
                AppColors.braweSky.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Icon + Title em linha
                Row(
                  children: [
                    // Icon container com glow
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.braweBlue,
                            AppColors.braweSky,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.braweBlue.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/brawe_sounds_icon.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Título principal
                          Text(
                            s.soundsTitle,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Subtítulo
                          Text(
                            s.soundsSubtitle,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndTabs(BuildContext context, S s, BraweColors colors) {
    return Container(
      color: colors.background,
      child: Column(
        children: [
          // Search bar premium
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: _buildSearchBar(context, s, colors),
          ),
          // Tabs com indicador premium
          _buildPremiumTabs(context, s, colors),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, S s, BraweColors colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.braweBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.searchCtrl,
        onChanged: widget.onSearch,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: s.soundsSearch,
          hintStyle: TextStyle(
            color: colors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search, color: colors.textSecondary, size: 22),
          ),
          suffixIcon: ValueListenableBuilder(
            valueListenable: widget.searchCtrl,
            builder: (_, val, _) => val.text.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      onPressed: widget.onClearSearch,
                      splashRadius: 20,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: colors.surfaceHighest,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colors.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colors.border.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.braweBlue.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTabs(BuildContext context, S s, BraweColors colors) {
    return TabBar(
      controller: widget.tabs,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: _PremiumTabIndicator(color: AppColors.mutedRed),
      labelColor: colors.textPrimary,
      unselectedLabelColor: colors.textSecondary,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      tabs: [
        Tab(text: s.soundsTabTrending),
        Tab(text: s.soundsTabCatalog),
      ],
    );
  }
}

/// Indicador de tab customizado com estilo premium.
class _PremiumTabIndicator extends Decoration {
  final Color color;

  _PremiumTabIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _PremiumTabIndicatorPainter(color: color);
}

class _PremiumTabIndicatorPainter extends BoxPainter {
  final Color color;

  _PremiumTabIndicatorPainter({required this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;

    final width = config.size!.width;
    final height = config.size!.height;

    // Desenhar linha com rounded ends
    canvas.drawLine(
      Offset(offset.dx + 12, offset.dy + height - 2),
      Offset(offset.dx + width - 12, offset.dy + height - 2),
      paint,
    );

    // Adicionar glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 6;

    canvas.drawLine(
      Offset(offset.dx + 12, offset.dy + height - 2),
      Offset(offset.dx + width - 12, offset.dy + height - 2),
      glowPaint,
    );
  }
}
