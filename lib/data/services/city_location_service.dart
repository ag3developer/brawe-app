import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/post_poll.dart';

part 'city_location_service.g.dart';

enum CityLocationStatus {
  ok,
  denied,
  deniedForever,
  serviceDisabled,
  failed,
}

class CityLocationResult {
  const CityLocationResult(this.status, [this.location]);
  final CityLocationStatus status;
  final PostLocation? location;
}

/// Descobre a CIDADE do usuário para marcar um post.
///
/// Privacidade: pede só "durante o uso", lê a posição UMA vez com precisão
/// baixa (coarse) e faz a geocodificação reversa no aparelho. Só cidade,
/// UF/estado e país (ISO-2) saem daqui — coordenadas e rua são descartadas
/// e nunca chegam ao servidor.
class CityLocationService {
  const CityLocationService();

  Future<CityLocationResult> resolveCity() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const CityLocationResult(CityLocationStatus.serviceDisabled);
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        return const CityLocationResult(CityLocationStatus.deniedForever);
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.unableToDetermine) {
        return const CityLocationResult(CityLocationStatus.denied);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final loc = placemarksToCity(marks);
      if (loc == null) {
        return const CityLocationResult(CityLocationStatus.failed);
      }
      return CityLocationResult(CityLocationStatus.ok, loc);
    } catch (_) {
      return const CityLocationResult(CityLocationStatus.failed);
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}

@riverpod
CityLocationService cityLocationService(Ref ref) => const CityLocationService();

/// Converte o resultado do geocoder em [PostLocation] (cidade-nível).
/// Retorna null se não houver cidade ou país. Visível para teste.
PostLocation? placemarksToCity(List<Placemark> marks) {
  for (final m in marks) {
    final city = _clean(m.locality) ?? _clean(m.subAdministrativeArea);
    final country = _clean(m.isoCountryCode)?.toUpperCase();
    if (city == null || country == null || country.length != 2) continue;
    final region = _regionLabel(country, _clean(m.administrativeArea));
    return PostLocation(
      city: _cap(city),
      region: region == null ? null : _cap(region),
      country: country,
      label: PostLocation.buildLabel(_cap(city), region == null ? null : _cap(region), country),
    );
  }
  return null;
}

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

String _cap(String s) => s.length > 100 ? s.substring(0, 100) : s;

/// iOS devolve "PE"; Android devolve "Pernambuco". Para o Brasil
/// normalizamos para a sigla da UF, em qualquer plataforma.
String? _regionLabel(String country, String? region) {
  if (region == null) return null;
  if (country != 'BR') return region;
  if (region.length == 2) return region.toUpperCase();
  return _brStates[_fold(region)] ?? region;
}

String _fold(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const to = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final c in s.toLowerCase().runes) {
    final ch = String.fromCharCode(c);
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString().replaceFirst(RegExp(r'^state of '), '').replaceFirst(RegExp(r'^estado d[eo] '), '');
}

const _brStates = {
  'acre': 'AC',
  'alagoas': 'AL',
  'amapa': 'AP',
  'amazonas': 'AM',
  'bahia': 'BA',
  'ceara': 'CE',
  'distrito federal': 'DF',
  'espirito santo': 'ES',
  'goias': 'GO',
  'maranhao': 'MA',
  'mato grosso': 'MT',
  'mato grosso do sul': 'MS',
  'minas gerais': 'MG',
  'para': 'PA',
  'paraiba': 'PB',
  'parana': 'PR',
  'pernambuco': 'PE',
  'piaui': 'PI',
  'rio de janeiro': 'RJ',
  'rio grande do norte': 'RN',
  'rio grande do sul': 'RS',
  'rondonia': 'RO',
  'roraima': 'RR',
  'santa catarina': 'SC',
  'sao paulo': 'SP',
  'sergipe': 'SE',
  'tocantins': 'TO',
};
