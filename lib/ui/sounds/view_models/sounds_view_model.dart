import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../domain/models/sound.dart';

part 'sounds_view_model.g.dart';

// ── Trending ─────────────────────────────────────────────────────────────────

@riverpod
Future<List<Sound>> soundsTrending(Ref ref) =>
    ref.watch(soundRepositoryProvider).getTrending(period: 'week', limit: 20);

// ── Catálogo paginado ─────────────────────────────────────────────────────────

class SoundsCatalogState {
  final List<Sound> items;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? genre;
  final String? searchQuery;

  const SoundsCatalogState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.genre,
    this.searchQuery,
  });

  SoundsCatalogState copyWith({
    List<Sound>? items,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? genre,
    bool clearGenre = false,
    String? searchQuery,
    bool clearSearch = false,
  }) =>
      SoundsCatalogState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        genre: clearGenre ? null : (genre ?? this.genre),
        searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      );
}

@riverpod
class SoundsCatalogViewModel extends _$SoundsCatalogViewModel {
  @override
  SoundsCatalogState build() => const SoundsCatalogState();

  Future<void> load({bool reset = false}) async {
    if (state.isLoading) return;
    if (!reset && !state.hasMore) return;

    final page = reset ? 1 : state.page;
    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(soundRepositoryProvider);
      SoundCatalog result;

      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        final list = await repo.search(state.searchQuery!);
        result = SoundCatalog(
            items: list, total: list.length, page: 1, hasMore: false);
      } else {
        result = await repo.getCatalog(
          page: page,
          limit: 20,
          genre: state.genre,
        );
      }

      state = state.copyWith(
        items: reset ? result.items : [...state.items, ...result.items],
        isLoading: false,
        hasMore: result.hasMore,
        page: result.page + 1,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setGenre(String? genre) {
    state = state.copyWith(
      genre: genre,
      clearGenre: genre == null,
      clearSearch: true,
      items: [],
      page: 1,
      hasMore: true,
    );
    load(reset: true);
  }

  void setSearch(String query) {
    state = state.copyWith(
      searchQuery: query.trim().isEmpty ? null : query.trim(),
      clearSearch: query.trim().isEmpty,
      clearGenre: true,
      items: [],
      page: 1,
      hasMore: true,
    );
    load(reset: true);
  }

  void clearSearch() => setSearch('');

  Future<void> toggleSave(Sound sound) async {
    final repo = ref.read(soundRepositoryProvider);
    try {
      if (sound.isSaved) {
        await repo.unsaveSound(sound.id);
      } else {
        await repo.saveSound(sound.id);
      }
      // Atualiza isSaved localmente sem refetch
      state = state.copyWith(
        items: state.items
            .map((s) =>
                s.id == sound.id ? s.copyWith(isSaved: !s.isSaved) : s)
            .toList(),
      );
    } catch (_) {}
  }
}
