import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/explore_models.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/explore_view_model.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(searchControllerProvider.notifier).search(value);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E18),
        elevation: 0,
        title: TextField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          autofocus: false,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Buscar streamers, lives, categorias…',
            hintStyle: const TextStyle(color: AppColors.coolGray, fontSize: 14),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.coolGray, size: 20),
            suffixIcon: isSearching
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.coolGray),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(searchControllerProvider.notifier).clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.slate,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        bottom: isSearching
            ? null
            : TabBar(
                controller: _tabs,
                labelColor: AppColors.electricPurple,
                unselectedLabelColor: AppColors.coolGray,
                indicatorColor: AppColors.electricPurple,
                tabs: const [
                  Tab(text: 'Em alta'),
                  Tab(text: 'Categorias'),
                  Tab(text: 'Para você'),
                ],
              ),
      ),
      body: isSearching
          ? const _SearchResults()
          : TabBarView(
              controller: _tabs,
              children: const [
                _TrendingTab(),
                _CategoriesTab(),
                _RecommendedTab(),
              ],
            ),
    );
  }
}

// ─── Trending ──────────────────────────────────────────────────
class _TrendingTab extends ConsumerWidget {
  const _TrendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingExploreProvider);
    return RefreshIndicator(
      color: AppColors.electricPurple,
      onRefresh: () async => ref.refresh(trendingExploreProvider.future),
      child: trending.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.electricPurple),
        ),
        error: (_, __) => const _ErrorView(),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (data.lives.isNotEmpty) ...[
              const _SectionHeader(title: 'Lives ao vivo', icon: Icons.live_tv),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.lives.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _LiveCard(live: data.lives[i]),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (data.streamers.isNotEmpty) ...[
              const _SectionHeader(
                  title: 'Streamers em alta', icon: Icons.trending_up),
              const SizedBox(height: 12),
              ...data.streamers
                  .map((s) => _StreamerTile(streamer: s))
                  ,
            ],
            if (data.lives.isEmpty && data.streamers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: Text(
                    'Nada em alta agora',
                    style: TextStyle(color: AppColors.coolGray),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Categorias ────────────────────────────────────────────────
class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(exploreCategoriesProvider);
    return RefreshIndicator(
      color: AppColors.electricPurple,
      onRefresh: () async => ref.refresh(exploreCategoriesProvider.future),
      child: categories.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.electricPurple),
        ),
        error: (_, __) => const _ErrorView(),
        data: (cats) => cats.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text('Nenhuma categoria disponível.',
                        style: TextStyle(color: AppColors.coolGray)),
                  ),
                ],
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: cats.length,
                itemBuilder: (_, i) => _CategoryCard(category: cats[i]),
              ),
      ),
    );
  }
}

// ─── Recomendados ──────────────────────────────────────────────
class _RecommendedTab extends ConsumerWidget {
  const _RecommendedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rec = ref.watch(recommendedExploreProvider);
    return RefreshIndicator(
      color: AppColors.electricPurple,
      onRefresh: () async => ref.refresh(recommendedExploreProvider.future),
      child: rec.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.electricPurple),
        ),
        error: (_, __) => const _ErrorView(),
        data: (data) {
          final items = [...data.lives];
          return items.isEmpty && data.streamers.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Siga alguns streamers para receber recomendações personalizadas!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (items.isNotEmpty) ...[
                      const _SectionHeader(
                          title: 'Lives recomendadas', icon: Icons.recommend),
                      const SizedBox(height: 12),
                      ...items.map((l) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LiveCard(live: l, fullWidth: true),
                          )),
                    ],
                    if (data.streamers.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const _SectionHeader(
                          title: 'Streamers que você pode gostar',
                          icon: Icons.person_add),
                      const SizedBox(height: 12),
                      ...data.streamers.map((s) => _StreamerTile(streamer: s)),
                    ],
                  ],
                );
        },
      ),
    );
  }
}

// ─── Resultados de busca ───────────────────────────────────────
class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchControllerProvider);
    return results.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.electricPurple),
      ),
      error: (_, __) => const _ErrorView(),
      data: (list) => list.isEmpty
          ? const Center(
              child: Text(
                'Nenhum resultado.',
                style: TextStyle(color: AppColors.coolGray),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (_, i) => _SearchTile(result: list[i]),
            ),
    );
  }
}

// ─── Components ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.electricPurple, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  final TrendingLive live;
  final bool fullWidth;
  const _LiveCard({required this.live, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    final width = fullWidth ? double.infinity : 280.0;
    return GestureDetector(
      onTap: () => context.push('/live/${live.roomId}'),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (live.thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: live.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(color: Colors.black54),
                    )
                  else
                    Container(color: Colors.black45),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AO VIVO',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${live.viewerCount}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    live.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${live.streamerName ?? ''} • ${live.category ?? 'Geral'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.coolGray, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamerTile extends StatelessWidget {
  final TrendingStreamer streamer;
  const _StreamerTile({required this.streamer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/profile/${streamer.userId}'),
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.slate,
            backgroundImage: streamer.avatarUrl != null
                ? CachedNetworkImageProvider(streamer.avatarUrl!)
                : null,
            child: streamer.avatarUrl == null
                ? Text(
                    streamer.displayName.isNotEmpty
                        ? streamer.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          if (streamer.isLive)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF0B0E18), width: 1.5),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        streamer.displayName,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        '${streamer.followerCount} seguidores',
        style: const TextStyle(color: AppColors.coolGray, fontSize: 12),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ExploreCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: filtrar lives por categoria
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.electricPurple, AppColors.coolCyan],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.live_tv, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${category.liveCount} ao vivo',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  final SearchResult result;
  const _SearchTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final isLive = result.type == 'live';
    return ListTile(
      onTap: () {
        if (isLive) {
          context.push('/live/${result.id}');
        } else {
          context.push('/profile/${result.id}');
        }
      },
      leading: ClipRRect(
        borderRadius:
            BorderRadius.circular(isLive ? 6 : 24),
        child: SizedBox(
          width: 48,
          height: 48,
          child: result.thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: result.thumbnail!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.slate),
                )
              : Container(
                  color: AppColors.slate,
                  child: Icon(
                    isLive ? Icons.live_tv : Icons.person,
                    color: AppColors.coolGray,
                  ),
                ),
        ),
      ),
      title: Row(
        children: [
          if (isLive)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Text(
              result.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      subtitle: result.subtitle != null
          ? Text(
              result.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(color: AppColors.coolGray, fontSize: 12),
            )
          : null,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();
  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Erro ao carregar. Puxe para baixo para tentar novamente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.coolGray),
          ),
        ),
      );
}
