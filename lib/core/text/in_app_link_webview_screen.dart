import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Tela genérica para abrir links compartilhados em posts/comentários
/// dentro do próprio app (in-app browser), no estilo Instagram/TikTok.
///
/// - AppBar com botão fechar (X) + botão "abrir externamente" (ícone).
/// - Loader enquanto a página carrega.
/// - Fallback: se o WebView falhar (ex.: link não suporta iframe, ou é um
///   deep link como `https://chat.whatsapp.com/...`), oferece abrir no
///   navegador/app externo diretamente.
///
/// Baseado no mesmo padrão usado em `LegalWebViewScreen` (Termos/Privacidade),
/// generalizado para qualquer URL vinda de conteúdo de usuário.
class InAppLinkWebViewScreen extends StatefulWidget {
  const InAppLinkWebViewScreen({super.key, required this.url, this.title});

  final String url;
  final String? title;

  /// Abre a tela via Navigator (push). Uso:
  /// `InAppLinkWebViewScreen.open(context, url);`
  static Future<void> open(BuildContext context, String url, {String? title}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InAppLinkWebViewScreen(url: url, title: title),
      ),
    );
  }

  @override
  State<InAppLinkWebViewScreen> createState() => _InAppLinkWebViewScreenState();
}

class _InAppLinkWebViewScreenState extends State<InAppLinkWebViewScreen> {
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

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);
  }

  @override
  Widget build(BuildContext context) {
    final host = Uri.tryParse(widget.url)?.host ?? widget.url;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? host, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Abrir no navegador',
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
                    const Text(
                      'Não foi possível carregar esta página aqui.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openExternal,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Abrir externamente'),
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
