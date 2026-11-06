import 'package:flutter/material.dart';

/// Informa às abas do painel se estão dentro do NestedScrollView (cabeçalho
/// recolhível), para injetar a sobreposição da barra de abas fixa.
class CreatorPanelScope extends InheritedWidget {
  const CreatorPanelScope({super.key, required this.nested, required super.child});
  final bool nested;

  static bool nestedOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CreatorPanelScope>()?.nested ?? false;

  @override
  bool updateShouldNotify(CreatorPanelScope old) => old.nested != nested;
}

/// Primeiro sliver de cada aba: acomoda a barra de abas fixa do painel.
class PanelOverlapInjector extends StatelessWidget {
  const PanelOverlapInjector({super.key});
  @override
  Widget build(BuildContext context) {
    if (!CreatorPanelScope.nestedOf(context)) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context));
  }
}

/// Rolagem de uma aba: pull-to-refresh + injeção de sobreposição.
class PanelTabScroll extends StatelessWidget {
  const PanelTabScroll({super.key, required this.slivers, required this.onRefresh, this.storageKey});
  final List<Widget> slivers;
  final Future<void> Function() onRefresh;
  final String? storageKey;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: storageKey == null ? null : PageStorageKey<String>(storageKey!),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [const PanelOverlapInjector(), ...slivers, const SliverPadding(padding: EdgeInsets.only(bottom: 24))],
      ),
    );
  }
}
