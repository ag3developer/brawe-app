// Brawe Ads — público do impulsionamento (usado no fluxo "Impulsionar" e em "Editar público").
//
// Automático: Brasil inteiro, 18–99, qualquer interesse.
// Personalizar: Brasil inteiro · Cidades (busca) · Raio (mapa MapLibre com círculo ao vivo), idade e interesses.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../data/repositories/ads_repository.dart';
import '../../../domain/models/ad_models.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

/// Lugar escolhido (país, região, estado ou município) — só municípios são escolhidos no app,
/// os demais vêm de campanhas montadas no site e são mantidos ao editar.
class BoostPlace {
  const BoostPlace(this.kind, this.id, this.label);
  final String kind; // countries | regions | states | cities
  final String id;
  final String label;
}

class BoostAudience {
  BoostAudience({
    this.auto = true,
    this.mode = 'all',
    List<BoostPlace>? places,
    this.center,
    this.radiusKm = 20,
    this.ageMin = 18,
    this.ageMax = 99,
    this.gender = 'all',
    Set<String>? interests,
    this.exclude,
  }) : places = places ?? [],
       interests = interests ?? {};

  bool auto;

  /// all = Brasil inteiro · places = cidades · radius = raio
  String mode;
  List<BoostPlace> places;
  AdCity? center;
  int radiusKm;
  int ageMin;
  int ageMax;

  /// all · female · male
  String gender;
  Set<String> interests;

  /// exclusões feitas no site (o app não edita, só preserva)
  Map<String, dynamic>? exclude;

  bool get isValid =>
      auto ||
      switch (mode) {
        'places' => places.isNotEmpty,
        'radius' => center != null,
        _ => true,
      };

  Map<String, dynamic> location() {
    final ex = exclude ?? const <String, dynamic>{};
    if (auto || mode == 'all') {
      return {
        'mode': 'places',
        'countries': ['BR'],
        'exclude': ex,
      };
    }
    if (mode == 'radius') {
      return {
        'mode': 'radius',
        'center': center!.id,
        'radius_km': radiusKm,
        'exclude': ex,
      };
    }
    final out = <String, dynamic>{'mode': 'places', 'exclude': ex};
    for (final k in const ['countries', 'regions', 'states', 'cities']) {
      out[k] = places.where((p) => p.kind == k).map((p) => p.id).toList();
    }
    return out;
  }

  Map<String, dynamic> toTargeting(AdsPublicConfig cfg) => {
    'placements': cfg.boostPlacements,
    'platforms': const ['ios', 'android', 'web'],
    'audience': 'all',
    'age_min': auto ? 18 : ageMin,
    'age_max': auto ? 99 : ageMax,
    'gender': auto ? 'all' : gender,
    'location': location(),
    'interests': auto ? const <String>[] : interests.toList(),
  };

  /// Monta a partir do público salvo da campanha (para "Editar público").
  factory BoostAudience.fromTargeting(Map<String, dynamic> t) {
    final loc = (t['location'] as Map?)?.cast<String, dynamic>() ?? const {};
    final ageMin = (t['age_min'] as num?)?.toInt() ?? 18;
    final ageMax = (t['age_max'] as num?)?.toInt() ?? 99;
    final gender = (t['gender'] as String?) ?? 'all';
    final interests = ((t['interests'] as List?) ?? const [])
        .map((e) => e.toString())
        .toSet();
    final exclude = (loc['exclude'] as Map?)?.cast<String, dynamic>();
    final mode = loc['mode']?.toString() ?? 'all';
    if (mode == 'radius') {
      return BoostAudience(
        auto: false,
        mode: 'radius',
        center: AdCity(
          id: loc['center'].toString(),
          label: loc['center_label']?.toString() ?? '',
          lat: (loc['lat'] as num?)?.toDouble() ?? -15.78,
          lng: (loc['lng'] as num?)?.toDouble() ?? -47.93,
        ),
        radiusKm: (loc['radius_km'] as num?)?.toInt() ?? 20,
        ageMin: ageMin,
        ageMax: ageMax,
        gender: gender,
        interests: interests,
        exclude: exclude,
      );
    }
    final places = <BoostPlace>[];
    if (mode == 'places') {
      final labels = ((loc['labels'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList();
      var i = 0;
      for (final k in const ['countries', 'regions', 'states', 'cities']) {
        for (final id in (loc[k] as List?) ?? const []) {
          places.add(
            BoostPlace(
              k,
              id.toString(),
              i < labels.length ? labels[i] : id.toString(),
            ),
          );
          i++;
        }
      }
    }
    final onlyBrazil =
        places.length == 1 &&
        places.first.kind == 'countries' &&
        places.first.id == 'BR';
    final isAuto =
        (mode == 'all' || onlyBrazil) &&
        gender == 'all' &&
        ageMin == 18 &&
        ageMax == 99 &&
        interests.isEmpty &&
        (exclude == null || _emptyExclude(exclude));
    return BoostAudience(
      auto: isAuto,
      mode: mode == 'all' || onlyBrazil ? 'all' : 'places',
      places: onlyBrazil ? [] : places,
      ageMin: ageMin,
      ageMax: ageMax,
      gender: gender,
      interests: interests,
      exclude: exclude,
    );
  }

  static bool _emptyExclude(Map<String, dynamic> e) => const [
    'countries',
    'regions',
    'states',
    'cities',
  ].every((k) => ((e[k] as List?) ?? const []).isEmpty);
}

/// Editor do público. Chama [onChanged] a cada mudança (o objeto é o mesmo, alterado).
class BoostAudienceEditor extends ConsumerStatefulWidget {
  const BoostAudienceEditor({
    super.key,
    required this.audience,
    required this.config,
    required this.onChanged,
  });
  final BoostAudience audience;
  final AdsPublicConfig config;
  final VoidCallback onChanged;

  @override
  ConsumerState<BoostAudienceEditor> createState() =>
      _BoostAudienceEditorState();
}

class _BoostAudienceEditorState extends ConsumerState<BoostAudienceEditor> {
  BoostAudience get a => widget.audience;

  void _set(VoidCallback f) {
    setState(f);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChoiceCard(
          selected: a.auto,
          icon: LucideIcons.sparkles,
          title: s.boostAuto,
          subtitle: s.boostAutoHint,
          onTap: () => _set(() => a.auto = true),
        ),
        const SizedBox(height: 10),
        _ChoiceCard(
          selected: !a.auto,
          icon: LucideIcons.slidersHorizontal,
          title: s.boostCustom,
          subtitle: s.boostCustomHint,
          onTap: () => _set(() => a.auto = false),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: a.auto
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _Label(s.boostLocation),
                    const SizedBox(height: 10),
                    _Segmented(
                      value: a.mode,
                      items: {
                        'all': s.boostAllBrazil,
                        'places': s.boostPlaces,
                        'radius': s.boostRadius,
                      },
                      onChanged: (v) => _set(() => a.mode = v),
                    ),
                    const SizedBox(height: 14),
                    if (a.mode == 'places')
                      _CitiesPicker(audience: a, onChanged: () => _set(() {})),
                    if (a.mode == 'radius')
                      _RadiusPicker(
                        audience: a,
                        maxKm: widget.config.radiusMaxKm,
                        onChanged: () => _set(() {}),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _Label(s.boostAge),
                        const Spacer(),
                        Text(
                          s.boostAgeRange(
                            '${a.ageMin}',
                            a.ageMax >= 65 ? '65+' : '${a.ageMax}',
                          ),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      min: 18,
                      max: 65,
                      divisions: 47,
                      values: RangeValues(
                        a.ageMin.toDouble(),
                        math.min(a.ageMax, 65).toDouble(),
                      ),
                      onChanged: (v) => _set(() {
                        a.ageMin = v.start.round();
                        a.ageMax = v.end.round() >= 65 ? 99 : v.end.round();
                      }),
                    ),
                    const SizedBox(height: 16),
                    _Label(s.onbGender),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final e in {
                          'all': s.boostGenderAll,
                          'female': s.boostGenderFemale,
                          'male': s.boostGenderMale,
                        }.entries)
                          ChoiceChip(
                            label: Text(e.value),
                            selected: a.gender == e.key,
                            showCheckmark: false,
                            shape: const StadiumBorder(),
                            onSelected: (_) => _set(() => a.gender = e.key),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        _Label(s.boostInterests),
                        const Spacer(),
                        if (a.interests.isEmpty)
                          Text(
                            s.boostAnyInterest,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final i in {
                          ...widget.config.interestSuggestions,
                          ...a.interests,
                        })
                          FilterChip(
                            label: Text(i),
                            selected: a.interests.contains(i),
                            showCheckmark: false,
                            shape: const StadiumBorder(),
                            onSelected: (on) => _set(() {
                              if (on && a.interests.length < 10) {
                                a.interests.add(i);
                              } else {
                                a.interests.remove(i);
                              }
                            }),
                          ),
                      ],
                    ),
                    if (a.interests.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.info,
                            size: 14,
                            color: colors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.boostInterestsNarrow,
                              style: TextStyle(
                                color: colors.textTertiary,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

// ── cidades ─────────────────────────────────────────────────────────────

class _CitiesPicker extends ConsumerStatefulWidget {
  const _CitiesPicker({required this.audience, required this.onChanged});
  final BoostAudience audience;
  final VoidCallback onChanged;

  @override
  ConsumerState<_CitiesPicker> createState() => _CitiesPickerState();
}

class _CitiesPickerState extends ConsumerState<_CitiesPicker> {
  final _q = TextEditingController();
  Timer? _debounce;
  List<AdCity> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _search(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      if (v.trim().length < 2) {
        setState(() => _results = []);
        return;
      }
      setState(() => _searching = true);
      try {
        final r = await ref.read(adsRepositoryProvider).searchCities(v);
        if (mounted && _q.text == v) setState(() => _results = r);
      } catch (_) {
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final a = widget.audience;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchField(
          controller: _q,
          hint: s.boostSearchCity,
          onChanged: _search,
          busy: _searching,
        ),
        if (_results.isNotEmpty || (_q.text.trim().length >= 2 && !_searching))
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: _results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      s.boostNoCity,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      for (final c in _results)
                        ListTile(
                          dense: true,
                          leading: Icon(
                            LucideIcons.mapPin,
                            size: 18,
                            color: colors.textSecondary,
                          ),
                          title: Text(c.label),
                          trailing:
                              a.places.any(
                                (p) => p.kind == 'cities' && p.id == c.id,
                              )
                              ? Icon(
                                  LucideIcons.check,
                                  size: 18,
                                  color: colors.accentPrimary,
                                )
                              : null,
                          onTap: () {
                            if (!a.places.any(
                              (p) => p.kind == 'cities' && p.id == c.id,
                            )) {
                              a.places.add(BoostPlace('cities', c.id, c.label));
                            }
                            _q.clear();
                            setState(() => _results = []);
                            FocusScope.of(context).unfocus();
                            widget.onChanged();
                          },
                        ),
                    ],
                  ),
          ),
        if (a.places.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in a.places)
                InputChip(
                  label: Text(p.label),
                  shape: const StadiumBorder(),
                  avatar: Icon(
                    LucideIcons.mapPin,
                    size: 15,
                    color: colors.accentPrimary,
                  ),
                  onDeleted: () {
                    a.places.remove(p);
                    widget.onChanged();
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── raio (mapa) ─────────────────────────────────────────────────────────

const _mapStyle = 'https://tiles.openfreemap.org/styles/liberty';

class _RadiusPicker extends ConsumerStatefulWidget {
  const _RadiusPicker({
    required this.audience,
    required this.maxKm,
    required this.onChanged,
  });
  final BoostAudience audience;
  final int maxKm;
  final VoidCallback onChanged;

  @override
  ConsumerState<_RadiusPicker> createState() => _RadiusPickerState();
}

class _RadiusPickerState extends ConsumerState<_RadiusPicker> {
  MapLibreMapController? _map;
  Fill? _fill;
  Line? _ring;
  Circle? _dot;
  bool _styleReady = false;
  bool _locating = false;
  bool _myLocation = false;
  final _q = TextEditingController();
  Timer? _debounce;
  List<AdCity> _results = [];

  BoostAudience get a => widget.audience;

  @override
  void initState() {
    super.initState();
    _initPermission();
    if (a.center == null) _locate(silent: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  Future<void> _initPermission() async {
    try {
      final p = await Geolocator.checkPermission();
      if (mounted &&
          (p == LocationPermission.always ||
              p == LocationPermission.whileInUse)) {
        setState(() => _myLocation = true);
      }
    } catch (_) {}
  }

  /// GPS (se a pessoa deixar) → município mais próximo; sem GPS, o servidor usa o IP.
  Future<void> _locate({bool silent = false}) async {
    setState(() => _locating = true);
    double? lat, lng;
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied && !silent) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.always ||
          p == LocationPermission.whileInUse) {
        if (mounted) setState(() => _myLocation = true);
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 8),
          ),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {}
    try {
      final w = await ref
          .read(adsRepositoryProvider)
          .whereAmI(lat: lat, lng: lng);
      if (w.city != null && mounted) _setCenter(w.city!);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _setCenter(AdCity c) {
    a.center = c;
    widget.onChanged();
    _draw(fit: true);
  }

  Future<void> _tapMap(LatLng p) async {
    try {
      final w = await ref
          .read(adsRepositoryProvider)
          .whereAmI(lat: p.latitude, lng: p.longitude);
      if (w.city != null && mounted) _setCenter(w.city!);
    } catch (_) {}
  }

  static List<LatLng> _circle(double lat, double lng, double km, {int n = 72}) {
    const r = 6371.0;
    final d = km / r;
    final la = lat * math.pi / 180, lo = lng * math.pi / 180;
    return [
      for (var i = 0; i <= n; i++)
        () {
          final b = 2 * math.pi * i / n;
          final la2 = math.asin(
            math.sin(la) * math.cos(d) +
                math.cos(la) * math.sin(d) * math.cos(b),
          );
          final lo2 =
              lo +
              math.atan2(
                math.sin(b) * math.sin(d) * math.cos(la),
                math.cos(d) - math.sin(la) * math.sin(la2),
              );
          return LatLng(la2 * 180 / math.pi, lo2 * 180 / math.pi);
        }(),
    ];
  }

  Future<void> _draw({bool fit = false}) async {
    final m = _map, c = a.center;
    if (m == null || !_styleReady || c == null) return;
    final ring = _circle(c.lat, c.lng, a.radiusKm.toDouble());
    const blue = '#2563EB';
    try {
      if (_fill == null) {
        _fill = await m.addFill(
          FillOptions(geometry: [ring], fillColor: blue, fillOpacity: 0.16),
        );
        _ring = await m.addLine(
          LineOptions(
            geometry: ring,
            lineColor: blue,
            lineWidth: 2,
            lineOpacity: 0.9,
          ),
        );
        _dot = await m.addCircle(
          CircleOptions(
            geometry: LatLng(c.lat, c.lng),
            circleRadius: 6,
            circleColor: blue,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2.5,
          ),
        );
      } else {
        await m.updateFill(_fill!, FillOptions(geometry: [ring]));
        await m.updateLine(_ring!, LineOptions(geometry: ring));
        await m.updateCircle(
          _dot!,
          CircleOptions(geometry: LatLng(c.lat, c.lng)),
        );
      }
      if (fit) {
        var s = 90.0, w = 180.0, n = -90.0, e = -180.0;
        for (final p in ring) {
          s = math.min(s, p.latitude);
          n = math.max(n, p.latitude);
          w = math.min(w, p.longitude);
          e = math.max(e, p.longitude);
        }
        await m.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e)),
            left: 28,
            right: 28,
            top: 28,
            bottom: 28,
          ),
          duration: const Duration(milliseconds: 650),
        );
      }
    } catch (_) {}
  }

  void _search(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      if (v.trim().length < 2) {
        setState(() => _results = []);
        return;
      }
      try {
        final r = await ref.read(adsRepositoryProvider).searchCities(v);
        if (mounted && _q.text == v) setState(() => _results = r);
      } catch (_) {}
    });
  }

  // escala do controle: passos curtos perto (1–50 km) e maiores longe
  double get _sliderValue => math.sqrt((a.radiusKm - 1) / (widget.maxKm - 1));
  int _kmFrom(double v) {
    final km = 1 + (v * v) * (widget.maxKm - 1);
    final step = km < 20 ? 1 : (km < 100 ? 5 : 10);
    return ((km / step).round() * step).clamp(1, widget.maxKm);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final c = a.center;
    final h = (MediaQuery.sizeOf(context).height * 0.34).clamp(220.0, 380.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: h,
            child: Stack(
              children: [
                MapLibreMap(
                  styleString: _mapStyle,
                  initialCameraPosition: CameraPosition(
                    target: c != null
                        ? LatLng(c.lat, c.lng)
                        : const LatLng(-14.2, -51.9),
                    zoom: c != null ? 9 : 3.2,
                  ),
                  onMapCreated: (m) => _map = m,
                  onStyleLoadedCallback: () {
                    _styleReady = true;
                    _draw(fit: true);
                  },
                  onMapClick: (_, p) => _tapMap(p),
                  myLocationEnabled: _myLocation,
                  myLocationRenderMode: MyLocationRenderMode.normal,
                  compassEnabled: false,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  attributionButtonPosition:
                      AttributionButtonPosition.bottomRight,
                  attributionButtonMargins: const math.Point(6, 6),
                ),
                // raio em destaque, por cima do mapa
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      s.boostKm('${a.radiusKm}'),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Material(
                    color: colors.surfaceElevated.withValues(alpha: 0.94),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      tooltip: s.boostUseMyLocation,
                      onPressed: _locating ? null : () => _locate(),
                      icon: _locating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              LucideIcons.locateFixed,
                              size: 20,
                              color: colors.accentPrimary,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Slider(
          value: _sliderValue.clamp(0.0, 1.0),
          onChanged: (v) {
            final km = _kmFrom(v);
            if (km == a.radiusKm) return;
            setState(() => a.radiusKm = km);
            widget.onChanged();
            _draw();
          },
          onChangeEnd: (_) => _draw(fit: true),
        ),
        Row(
          children: [
            Icon(LucideIcons.mapPin, size: 16, color: colors.accentPrimary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                c == null ? s.boostCenter : '${s.boostCenter}: ${c.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          s.boostTapMap,
          style: TextStyle(color: colors.textTertiary, fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        _SearchField(
          controller: _q,
          hint: s.boostSearchCity,
          onChanged: _search,
        ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final r in _results)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                    title: Text(r.label),
                    onTap: () {
                      _q.clear();
                      setState(() => _results = []);
                      FocusScope.of(context).unfocus();
                      _setCenter(r);
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── peças visuais ───────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: context.colors.textPrimary,
      fontSize: 15.5,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected
          ? colors.accentPrimary.withValues(alpha: 0.08)
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? colors.accentPrimary : colors.border,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.accentPrimary
                      : colors.surfaceHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: selected ? colors.textOnAccent : colors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? colors.accentPrimary : Colors.transparent,
                  border: Border.all(
                    color: selected ? colors.accentPrimary : colors.border,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Icon(
                        LucideIcons.check,
                        size: 13,
                        color: colors.textOnAccent,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final e in items.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: value == e.key
                        ? colors.surfaceElevated
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: value == e.key
                        ? const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    e.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == e.key
                          ? colors.textPrimary
                          : colors.textSecondary,
                      fontWeight: value == e.key
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.busy = false,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          LucideIcons.search,
          size: 18,
          color: colors.textSecondary,
        ),
        suffixIcon: busy
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        filled: true,
        fillColor: colors.surfaceHighest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
