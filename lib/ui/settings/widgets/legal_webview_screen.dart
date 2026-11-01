import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Tela in-app para exibir páginas legais (Termos, Privacidade, FAQ).
///
/// - Header com título + botão fechar (X).
/// - Loader enquanto carrega.
/// - Fallback: se o WebView falhar, abre no navegador externo.
class LegalWebViewScreen extends StatefulWidget {
  const LegalWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  /// Termos ou Privacidade DENTRO do app, no idioma do usuário (pt/en/es),
  /// em modo embutido (sem o cabeçalho do site).
  static Future<void> openLegal(BuildContext context, {required bool privacy}) {
    final s = S.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final locale = const {'pt', 'en', 'es'}.contains(lang) ? lang : 'en';
    final doc = privacy ? 'privacy' : 'terms';
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LegalWebViewScreen(
          url: '${AppConstants.legalBaseUrl}/$locale/$doc?embed=1',
          title: privacy ? s.settingsPrivacyPolicy : s.settingsTermsOfUse,
        ),
      ),
    );
  }

  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _errored = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            // Só marca erro se for falha do documento principal.
            if (error.isForMainFrame ?? true) {
              setState(() {
                _errored = true;
                _loading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _bgSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tema só pode ser lido depois do initState.
    if (!_bgSet) {
      _bgSet = true;
      _controller.setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: s.legalOpenInBrowser,
            onPressed: _openExternal,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_errored) WebViewWidget(controller: _controller),
          if (_loading && !_errored)
            const Center(child: CircularProgressIndicator()),
          if (_errored)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      s.legalLoadError,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openExternal,
                      icon: const Icon(Icons.open_in_new),
                      label: Text(s.legalOpenInBrowser),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
