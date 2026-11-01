import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Brawe'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navFeed.
  ///
  /// In pt, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navChat.
  ///
  /// In pt, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @tabFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get tabFollowing;

  /// No description provided for @tabForYou.
  ///
  /// In pt, this message translates to:
  /// **'Para Você'**
  String get tabForYou;

  /// No description provided for @actionFollow.
  ///
  /// In pt, this message translates to:
  /// **'Seguir'**
  String get actionFollow;

  /// No description provided for @actionUnfollow.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get actionUnfollow;

  /// No description provided for @actionLike.
  ///
  /// In pt, this message translates to:
  /// **'Curtir'**
  String get actionLike;

  /// No description provided for @actionComment.
  ///
  /// In pt, this message translates to:
  /// **'Comentar'**
  String get actionComment;

  /// No description provided for @actionShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get actionShare;

  /// No description provided for @actionSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get actionSave;

  /// No description provided for @actionRepost.
  ///
  /// In pt, this message translates to:
  /// **'Repostar'**
  String get actionRepost;

  /// No description provided for @actionSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get actionSend;

  /// No description provided for @actionCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get actionConfirm;

  /// No description provided for @actionRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get actionRetry;

  /// No description provided for @actionRefresh.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get actionRefresh;

  /// No description provided for @actionDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get actionEdit;

  /// No description provided for @actionClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get actionClose;

  /// No description provided for @actionBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get actionBack;

  /// No description provided for @actionBlock.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear'**
  String get actionBlock;

  /// No description provided for @actionUnblock.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear'**
  String get actionUnblock;

  /// No description provided for @actionReport.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar'**
  String get actionReport;

  /// No description provided for @actionCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get actionCopy;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vídeo por aqui ainda.'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Siga creators ou volte mais tarde.'**
  String get feedEmptySubtitle;

  /// No description provided for @feedFollowingEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Siga pessoas para ver os posts delas aqui.'**
  String get feedFollowingEmptyTitle;

  /// No description provided for @feedLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o feed.'**
  String get feedLoadError;

  /// No description provided for @feedNoMore.
  ///
  /// In pt, this message translates to:
  /// **'Você está em dia! 🎉'**
  String get feedNoMore;

  /// No description provided for @profileEditButton.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil'**
  String get profileEditButton;

  /// No description provided for @profileFollowers.
  ///
  /// In pt, this message translates to:
  /// **'seguidores'**
  String get profileFollowers;

  /// No description provided for @profileFollowing.
  ///
  /// In pt, this message translates to:
  /// **'seguindo'**
  String get profileFollowing;

  /// No description provided for @profileLives.
  ///
  /// In pt, this message translates to:
  /// **'lives'**
  String get profileLives;

  /// No description provided for @profileViews.
  ///
  /// In pt, this message translates to:
  /// **'views'**
  String get profileViews;

  /// No description provided for @profileJoinedAt.
  ///
  /// In pt, this message translates to:
  /// **'entrou em {date}'**
  String profileJoinedAt(String date);

  /// No description provided for @profileTabPosts.
  ///
  /// In pt, this message translates to:
  /// **'Posts'**
  String get profileTabPosts;

  /// No description provided for @profileTabVideos.
  ///
  /// In pt, this message translates to:
  /// **'Vídeos'**
  String get profileTabVideos;

  /// No description provided for @profileTabSaved.
  ///
  /// In pt, this message translates to:
  /// **'Salvos'**
  String get profileTabSaved;

  /// No description provided for @authLogin.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get authRegister;

  /// No description provided for @authLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get authLogout;

  /// No description provided for @authEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get authForgotPassword;

  /// No description provided for @authWelcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta!'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get authCreateAccount;

  /// No description provided for @chatNewMessage.
  ///
  /// In pt, this message translates to:
  /// **'Nova mensagem'**
  String get chatNewMessage;

  /// No description provided for @chatPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem...'**
  String get chatPlaceholder;

  /// No description provided for @chatNoConversations.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conversa ainda.'**
  String get chatNoConversations;

  /// No description provided for @chatBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear {name}?'**
  String chatBlockTitle(String name);

  /// No description provided for @chatBlockedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'{name} foi bloqueado(a).'**
  String chatBlockedSuccess(String name);

  /// No description provided for @chatBlockError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao bloquear: {error}'**
  String chatBlockError(String error);

  /// No description provided for @chatImagePickError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao escolher imagem: {error}'**
  String chatImagePickError(String error);

  /// No description provided for @commentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comentários'**
  String get commentsTitle;

  /// No description provided for @commentsPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Adicione um comentário...'**
  String get commentsPlaceholder;

  /// No description provided for @commentsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum comentário ainda.\nSeja o primeiro!'**
  String get commentsEmpty;

  /// No description provided for @notificationsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma notificação ainda.'**
  String get notificationsEmpty;

  /// No description provided for @notificationLiked.
  ///
  /// In pt, this message translates to:
  /// **'{user} curtiu seu post.'**
  String notificationLiked(String user);

  /// No description provided for @notificationFollowed.
  ///
  /// In pt, this message translates to:
  /// **'{user} começou a te seguir.'**
  String notificationFollowed(String user);

  /// No description provided for @notificationCommented.
  ///
  /// In pt, this message translates to:
  /// **'{user} comentou no seu post.'**
  String notificationCommented(String user);

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Português · Español · English'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma do app'**
  String get settingsAppLanguage;

  /// No description provided for @settingsAppearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get settingsThemeSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get settingsNotifications;

  /// No description provided for @settingsNotifLiveStart.
  ///
  /// In pt, this message translates to:
  /// **'Lives começando'**
  String get settingsNotifLiveStart;

  /// No description provided for @settingsNotifLiveStartHint.
  ///
  /// In pt, this message translates to:
  /// **'Receba aviso quando seus creators favoritos forem ao vivo'**
  String get settingsNotifLiveStartHint;

  /// No description provided for @settingsNotifGifts.
  ///
  /// In pt, this message translates to:
  /// **'Presentes recebidos'**
  String get settingsNotifGifts;

  /// No description provided for @settingsNotifGiftsHint.
  ///
  /// In pt, this message translates to:
  /// **'Avisar quando alguém te enviar um gift'**
  String get settingsNotifGiftsHint;

  /// No description provided for @settingsNotifFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Novos seguidores'**
  String get settingsNotifFollowers;

  /// No description provided for @settingsNotifMessages.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens diretas'**
  String get settingsNotifMessages;

  /// No description provided for @settingsPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyShowViewers.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar nº de espectadores'**
  String get settingsPrivacyShowViewers;

  /// No description provided for @settingsPrivacyShowViewersHint.
  ///
  /// In pt, this message translates to:
  /// **'Outros podem ver quantas pessoas assistem suas lives'**
  String get settingsPrivacyShowViewersHint;

  /// No description provided for @settingsPrivacyShowEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar ganhos publicamente'**
  String get settingsPrivacyShowEarnings;

  /// No description provided for @settingsPrivacyShowEarningsHint.
  ///
  /// In pt, this message translates to:
  /// **'Exibir total de coins/ganhos no seu perfil'**
  String get settingsPrivacyShowEarningsHint;

  /// No description provided for @settingsSounds.
  ///
  /// In pt, this message translates to:
  /// **'Sons'**
  String get settingsSounds;

  /// No description provided for @settingsSoundsEnabled.
  ///
  /// In pt, this message translates to:
  /// **'Efeitos sonoros'**
  String get settingsSoundsEnabled;

  /// No description provided for @settingsSoundsHint.
  ///
  /// In pt, this message translates to:
  /// **'Sons ao receber gifts, mensagens etc.'**
  String get settingsSoundsHint;

  /// No description provided for @settingsAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre & Legal'**
  String get settingsAbout;

  /// No description provided for @settingsAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get settingsLogout;

  /// No description provided for @settingsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar suas configurações.'**
  String get settingsLoadError;

  /// No description provided for @settingsThemeAuto.
  ///
  /// In pt, this message translates to:
  /// **'Auto'**
  String get settingsThemeAuto;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsSupport.
  ///
  /// In pt, this message translates to:
  /// **'Suporte'**
  String get settingsSupport;

  /// No description provided for @settingsVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get settingsVersion;

  /// No description provided for @settingsChangePassword.
  ///
  /// In pt, this message translates to:
  /// **'Alterar senha'**
  String get settingsChangePassword;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair da sua conta?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsHelpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como podemos ajudar?'**
  String get settingsHelpTitle;

  /// No description provided for @settingsSendSupportEmail.
  ///
  /// In pt, this message translates to:
  /// **'Enviar e-mail ao suporte'**
  String get settingsSendSupportEmail;

  /// No description provided for @settingsNoMailApp.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum app de e-mail configurado.'**
  String get settingsNoMailApp;

  /// No description provided for @settingsHelpCenterFaq.
  ///
  /// In pt, this message translates to:
  /// **'Central de ajuda / FAQ'**
  String get settingsHelpCenterFaq;

  /// No description provided for @settingsSupportEmailSubject.
  ///
  /// In pt, this message translates to:
  /// **'Suporte Brawe — App v{version}'**
  String settingsSupportEmailSubject(String version);

  /// No description provided for @settingsCantOpenUrl.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir {url}'**
  String settingsCantOpenUrl(String url);

  /// No description provided for @cpCurrentPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha atual'**
  String get cpCurrentPassword;

  /// No description provided for @cpNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get cpNewPassword;

  /// No description provided for @cpConfirmNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar nova senha'**
  String get cpConfirmNewPassword;

  /// No description provided for @cpMin8Chars.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get cpMin8Chars;

  /// No description provided for @cpSaveNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Salvar nova senha'**
  String get cpSaveNewPassword;

  /// No description provided for @cpEnterCurrentPassword.
  ///
  /// In pt, this message translates to:
  /// **'Informe sua senha atual.'**
  String get cpEnterCurrentPassword;

  /// No description provided for @cpPasswordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'A nova senha deve ter pelo menos 8 caracteres.'**
  String get cpPasswordTooShort;

  /// No description provided for @cpPasswordsDontMatch.
  ///
  /// In pt, this message translates to:
  /// **'As novas senhas não coincidem.'**
  String get cpPasswordsDontMatch;

  /// No description provided for @cpChangedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Senha alterada com sucesso.'**
  String get cpChangedSuccess;

  /// No description provided for @cpChangeError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao alterar senha.'**
  String get cpChangeError;

  /// No description provided for @delAccTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get delAccTitle;

  /// No description provided for @delAccEnterPassword.
  ///
  /// In pt, this message translates to:
  /// **'Informe sua senha para confirmar.'**
  String get delAccEnterPassword;

  /// No description provided for @delAccAckRequired.
  ///
  /// In pt, this message translates to:
  /// **'Confirme que entende a ação.'**
  String get delAccAckRequired;

  /// No description provided for @delAccConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação é IRREVERSÍVEL. Sua conta será desativada e seus dados pessoais anonimizados (LGPD). Deseja continuar?'**
  String get delAccConfirmBody;

  /// No description provided for @delAccConfirmButton.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get delAccConfirmButton;

  /// No description provided for @delAccSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Conta excluída. Até logo.'**
  String get delAccSuccess;

  /// No description provided for @delAccError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao excluir conta.'**
  String get delAccError;

  /// No description provided for @delAccWarningBanner.
  ///
  /// In pt, this message translates to:
  /// **'Ao excluir sua conta, você perderá acesso permanente ao histórico de lives, gifts, saldo, conversas e seguidores. Saldos pendentes podem ser perdidos.'**
  String get delAccWarningBanner;

  /// No description provided for @delAccWhatHappens.
  ///
  /// In pt, this message translates to:
  /// **'O que acontece:'**
  String get delAccWhatHappens;

  /// No description provided for @delAccBullet1.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta será desativada imediatamente.'**
  String get delAccBullet1;

  /// No description provided for @delAccBullet2.
  ///
  /// In pt, this message translates to:
  /// **'Seu email e dados pessoais serão anonimizados.'**
  String get delAccBullet2;

  /// No description provided for @delAccBullet3.
  ///
  /// In pt, this message translates to:
  /// **'Você será desconectado de todos os dispositivos.'**
  String get delAccBullet3;

  /// No description provided for @delAccBullet4.
  ///
  /// In pt, this message translates to:
  /// **'Registros mantidos pelo prazo legal exigido.'**
  String get delAccBullet4;

  /// No description provided for @delAccPasswordHelper.
  ///
  /// In pt, this message translates to:
  /// **'Confirme sua identidade'**
  String get delAccPasswordHelper;

  /// No description provided for @delAccAckCheckbox.
  ///
  /// In pt, this message translates to:
  /// **'Entendo que esta ação é irreversível.'**
  String get delAccAckCheckbox;

  /// No description provided for @delAccDeleteMyAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir minha conta'**
  String get delAccDeleteMyAccount;

  /// No description provided for @legalOpenInBrowser.
  ///
  /// In pt, this message translates to:
  /// **'Abrir no navegador'**
  String get legalOpenInBrowser;

  /// No description provided for @legalLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar esta página.'**
  String get legalLoadError;

  /// No description provided for @languagePickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma'**
  String get languagePickerTitle;

  /// No description provided for @languagePt.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get languagePt;

  /// No description provided for @languageEs.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @languageEn.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @errorNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Verifique sua internet.'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente novamente.'**
  String get errorGeneric;

  /// No description provided for @errorNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo não encontrado.'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In pt, this message translates to:
  /// **'Sessão expirada. Faça login novamente.'**
  String get errorUnauthorized;

  /// No description provided for @giftComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'🎁 Em breve!'**
  String get giftComingSoon;

  /// No description provided for @liveBadge.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get liveBadge;

  /// No description provided for @viewerCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} assistindo'**
  String viewerCount(int count);

  /// No description provided for @authLoginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre na sua conta para continuar.'**
  String get authLoginSubtitle;

  /// No description provided for @authWelcomeBackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo\nde volta.'**
  String get authWelcomeBackTitle;

  /// No description provided for @authEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'voce@brawe.app'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'••••••••'**
  String get authPasswordHint;

  /// No description provided for @authEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-MAIL'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'SENHA'**
  String get authPasswordLabel;

  /// No description provided for @authForgotPasswordShort.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get authForgotPasswordShort;

  /// No description provided for @authLoggingIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrando…'**
  String get authLoggingIn;

  /// No description provided for @authNoAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta?'**
  String get authNoAccount;

  /// No description provided for @authCreateNow.
  ///
  /// In pt, this message translates to:
  /// **'Criar agora'**
  String get authCreateNow;

  /// No description provided for @authAcceptTermsAndPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Ao continuar você aceita os Termos de Uso\ne a Política de Privacidade.'**
  String get authAcceptTermsAndPrivacy;

  /// No description provided for @authWelcomeBackSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta.'**
  String get authWelcomeBackSuccess;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authEntrar.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get authEntrar;

  /// No description provided for @welcomeTagline.
  ///
  /// In pt, this message translates to:
  /// **'Conecte. Transmita. Cresça.'**
  String get welcomeTagline;

  /// No description provided for @welcomeAlreadyHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho uma conta'**
  String get welcomeAlreadyHaveAccount;

  /// No description provided for @welcomeAcceptTerms.
  ///
  /// In pt, this message translates to:
  /// **'Ao continuar você aceita os Termos de Uso.'**
  String get welcomeAcceptTerms;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get welcomeCreateAccount;

  /// No description provided for @signupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie sua conta.'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leva menos de um minuto para começar.'**
  String get signupSubtitle;

  /// No description provided for @signupNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get signupNameLabel;

  /// No description provided for @signupNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Como devemos te chamar?'**
  String get signupNameHint;

  /// No description provided for @signupEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get signupEmailLabel;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get signupPasswordLabel;

  /// No description provided for @signupPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'mínimo 8 caracteres'**
  String get signupPasswordHint;

  /// No description provided for @signupSponsorLabel.
  ///
  /// In pt, this message translates to:
  /// **'Código do patrocinador'**
  String get signupSponsorLabel;

  /// No description provided for @signupSponsorHint.
  ///
  /// In pt, this message translates to:
  /// **'BRAWE-XXXX'**
  String get signupSponsorHint;

  /// No description provided for @signupHaveReferral.
  ///
  /// In pt, this message translates to:
  /// **'Tenho um código de indicação'**
  String get signupHaveReferral;

  /// No description provided for @signupCreatingAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criando conta…'**
  String get signupCreatingAccount;

  /// No description provided for @signupCreateAccountButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signupCreateAccountButton;

  /// No description provided for @signupSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Conta criada com sucesso.'**
  String get signupSuccess;

  /// No description provided for @signupHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get signupHelp;

  /// No description provided for @signupCantOpenUrl.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir {url}'**
  String signupCantOpenUrl(String url);

  /// No description provided for @signupTermsPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito os '**
  String get signupTermsPrefix;

  /// No description provided for @signupTermsAnd.
  ///
  /// In pt, this message translates to:
  /// **' e a '**
  String get signupTermsAnd;

  /// No description provided for @signupTermsSuffix.
  ///
  /// In pt, this message translates to:
  /// **' do Brawe.'**
  String get signupTermsSuffix;

  /// No description provided for @pwStrengthWeak.
  ///
  /// In pt, this message translates to:
  /// **'Fraca'**
  String get pwStrengthWeak;

  /// No description provided for @pwStrengthMedium.
  ///
  /// In pt, this message translates to:
  /// **'Média'**
  String get pwStrengthMedium;

  /// No description provided for @pwStrengthGood.
  ///
  /// In pt, this message translates to:
  /// **'Boa'**
  String get pwStrengthGood;

  /// No description provided for @pwStrengthStrong.
  ///
  /// In pt, this message translates to:
  /// **'Forte'**
  String get pwStrengthStrong;

  /// No description provided for @forgotTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar senha'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu email e enviaremos instruções para criar uma nova senha.'**
  String get forgotSubtitle;

  /// No description provided for @forgotEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'EMAIL'**
  String get forgotEmailLabel;

  /// No description provided for @forgotEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'voce@exemplo.com'**
  String get forgotEmailHint;

  /// No description provided for @forgotInvalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'Informe um email válido.'**
  String get forgotInvalidEmail;

  /// No description provided for @forgotSending.
  ///
  /// In pt, this message translates to:
  /// **'Enviando...'**
  String get forgotSending;

  /// No description provided for @forgotSendInstructions.
  ///
  /// In pt, this message translates to:
  /// **'Enviar instruções'**
  String get forgotSendInstructions;

  /// No description provided for @forgotCannotSend.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar.'**
  String get forgotCannotSend;

  /// No description provided for @forgotBackToLogin.
  ///
  /// In pt, this message translates to:
  /// **'Voltar para login'**
  String get forgotBackToLogin;

  /// No description provided for @forgotCheckEmail.
  ///
  /// In pt, this message translates to:
  /// **'Verifique seu email'**
  String get forgotCheckEmail;

  /// No description provided for @forgotEmailSentBody.
  ///
  /// In pt, this message translates to:
  /// **'Se {email} estiver cadastrado, você receberá um link para criar uma nova senha em alguns minutos.'**
  String forgotEmailSentBody(String email);

  /// No description provided for @resetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar nova senha'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma senha forte de pelo menos 8 caracteres.'**
  String get resetSubtitle;

  /// No description provided for @resetNewPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'NOVA SENHA'**
  String get resetNewPasswordLabel;

  /// No description provided for @resetConfirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'CONFIRMAR SENHA'**
  String get resetConfirmPasswordLabel;

  /// No description provided for @resetPasswordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 8 caracteres.'**
  String get resetPasswordTooShort;

  /// No description provided for @resetPasswordsDontMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem.'**
  String get resetPasswordsDontMatch;

  /// No description provided for @resetSaving.
  ///
  /// In pt, this message translates to:
  /// **'Salvando...'**
  String get resetSaving;

  /// No description provided for @resetInvalidToken.
  ///
  /// In pt, this message translates to:
  /// **'Token inválido ou expirado.'**
  String get resetInvalidToken;

  /// No description provided for @navLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives'**
  String get navLives;

  /// No description provided for @createStoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Story'**
  String get createStoryTitle;

  /// No description provided for @createStorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Foto ou vídeo · some em 24h'**
  String get createStorySubtitle;

  /// No description provided for @createVideoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo'**
  String get createVideoTitle;

  /// No description provided for @createVideoSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Reels · aparece em Para Você'**
  String get createVideoSubtitle;

  /// No description provided for @createLiveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Live'**
  String get createLiveTitle;

  /// No description provided for @createLiveSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Transmita agora e receba gifts'**
  String get createLiveSubtitle;

  /// No description provided for @createPostTitle.
  ///
  /// In pt, this message translates to:
  /// **'Post'**
  String get createPostTitle;

  /// No description provided for @createPostSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Texto, foto ou link no seu feed'**
  String get createPostSubtitle;

  /// No description provided for @feedEmptyVideoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vídeo ou foto por aqui ainda.'**
  String get feedEmptyVideoTitle;

  /// No description provided for @feedEmptyVideoSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Siga creators ou volte mais tarde.\nPosts de texto estão na aba Feed.'**
  String get feedEmptyVideoSubtitle;

  /// No description provided for @liveJoining.
  ///
  /// In pt, this message translates to:
  /// **'Entrando na live…'**
  String get liveJoining;

  /// No description provided for @liveBadgeBattle.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO · BATALHA'**
  String get liveBadgeBattle;

  /// No description provided for @liveBadgeShop.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO · SHOP'**
  String get liveBadgeShop;

  /// No description provided for @liveOfferNow.
  ///
  /// In pt, this message translates to:
  /// **'OFERTA AGORA'**
  String get liveOfferNow;

  /// No description provided for @productFeatured.
  ///
  /// In pt, this message translates to:
  /// **'EM DESTAQUE'**
  String get productFeatured;

  /// No description provided for @videoLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o vídeo.'**
  String get videoLoadError;

  /// No description provided for @giftSendAnonymous.
  ///
  /// In pt, this message translates to:
  /// **'Enviar anonimamente'**
  String get giftSendAnonymous;

  /// No description provided for @giftAnonNameHidden.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome não será revelado'**
  String get giftAnonNameHidden;

  /// No description provided for @giftAnonNameVisible.
  ///
  /// In pt, this message translates to:
  /// **'Todos verão que foi você'**
  String get giftAnonNameVisible;

  /// No description provided for @giftSendButtonAnon.
  ///
  /// In pt, this message translates to:
  /// **'Enviar (anônimo)'**
  String get giftSendButtonAnon;

  /// No description provided for @giftSendButton.
  ///
  /// In pt, this message translates to:
  /// **'Enviar presente'**
  String get giftSendButton;

  /// No description provided for @giftSentAnon.
  ///
  /// In pt, this message translates to:
  /// **'Presente enviado anonimamente!'**
  String get giftSentAnon;

  /// No description provided for @giftSent.
  ///
  /// In pt, this message translates to:
  /// **'Presente enviado!'**
  String get giftSent;

  /// No description provided for @feedCannotLike.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível curtir. Tente novamente.'**
  String get feedCannotLike;

  /// No description provided for @feedUseLiveChat.
  ///
  /// In pt, this message translates to:
  /// **'Use o chat ao vivo para conversar.'**
  String get feedUseLiveChat;

  /// No description provided for @feedCannotShare.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível compartilhar.'**
  String get feedCannotShare;

  /// No description provided for @feedCannotFollow.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar o follow.'**
  String get feedCannotFollow;

  /// No description provided for @shareCheckBraweConnect.
  ///
  /// In pt, this message translates to:
  /// **'Confira no Brawe Connect'**
  String get shareCheckBraweConnect;

  /// No description provided for @homeStatFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get homeStatFollowers;

  /// No description provided for @homeStatFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get homeStatFollowing;

  /// No description provided for @homeStatLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives'**
  String get homeStatLives;

  /// No description provided for @profileViewFull.
  ///
  /// In pt, this message translates to:
  /// **'Ver perfil completo'**
  String get profileViewFull;

  /// No description provided for @createSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get createSheetTitle;

  /// No description provided for @createSheetSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhe um momento, abra uma live ou solte uma ideia.'**
  String get createSheetSubtitle;

  /// No description provided for @productsDrawerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Loja ao vivo'**
  String get productsDrawerTitle;

  /// No description provided for @productsDrawerItemCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} itens • {author}'**
  String productsDrawerItemCount(int count, String author);

  /// No description provided for @giftMysteryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Presente Misterioso'**
  String get giftMysteryTitle;

  /// No description provided for @giftMysterySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Surpreenda um dos streamers!\nO destino é escolhido aleatoriamente. 🎲'**
  String get giftMysterySubtitle;

  /// No description provided for @commentsErrorSend.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar comentário. Tente novamente.'**
  String get commentsErrorSend;

  /// No description provided for @commentsErrorLoad.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar comentários.'**
  String get commentsErrorLoad;

  /// No description provided for @commentsReplyingTo.
  ///
  /// In pt, this message translates to:
  /// **'Respondendo a @{username}'**
  String commentsReplyingTo(String username);

  /// No description provided for @commentsHintReply.
  ///
  /// In pt, this message translates to:
  /// **'Responder...'**
  String get commentsHintReply;

  /// No description provided for @commentsHintAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar comentário...'**
  String get commentsHintAdd;

  /// No description provided for @commentsReplyAction.
  ///
  /// In pt, this message translates to:
  /// **'Responder'**
  String get commentsReplyAction;

  /// No description provided for @postPublish.
  ///
  /// In pt, this message translates to:
  /// **'Publicar'**
  String get postPublish;

  /// No description provided for @postPublishedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Post publicado!'**
  String get postPublishedSuccess;

  /// No description provided for @postPublishError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao publicar. Tente novamente.'**
  String get postPublishError;

  /// No description provided for @postHintWhatsHappening.
  ///
  /// In pt, this message translates to:
  /// **'O que está acontecendo?'**
  String get postHintWhatsHappening;

  /// No description provided for @audiencePickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem pode ver?'**
  String get audiencePickerTitle;

  /// No description provided for @audienceAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get audienceAll;

  /// No description provided for @audienceFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get audienceFollowers;

  /// No description provided for @audienceOnlyMe.
  ///
  /// In pt, this message translates to:
  /// **'Apenas eu'**
  String get audienceOnlyMe;

  /// No description provided for @videoTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo muito grande. Máximo 100 MB.'**
  String get videoTooLarge;

  /// No description provided for @videoOpenError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o vídeo.'**
  String get videoOpenError;

  /// No description provided for @videoPublishedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo publicado! 🎬'**
  String get videoPublishedSuccess;

  /// No description provided for @videoPublishError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao publicar vídeo. Tente novamente.'**
  String get videoPublishError;

  /// No description provided for @videoSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo vídeo'**
  String get videoSheetTitle;

  /// No description provided for @videoSwapTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Trocar vídeo'**
  String get videoSwapTooltip;

  /// No description provided for @videoCaptionHint.
  ///
  /// In pt, this message translates to:
  /// **'Escreva uma legenda (opcional)…'**
  String get videoCaptionHint;

  /// No description provided for @videoPublishButton.
  ///
  /// In pt, this message translates to:
  /// **'Publicar vídeo'**
  String get videoPublishButton;

  /// No description provided for @videoSelect.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar vídeo'**
  String get videoSelect;

  /// No description provided for @videoFormatsHint.
  ///
  /// In pt, this message translates to:
  /// **'MP4 · MOV · WebM   ·   até 3 min   ·   100 MB'**
  String get videoFormatsHint;

  /// No description provided for @storySheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo story'**
  String get storySheetTitle;

  /// No description provided for @storyPublish.
  ///
  /// In pt, this message translates to:
  /// **'Publicar'**
  String get storyPublish;

  /// No description provided for @storyPublishedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Story publicado!'**
  String get storyPublishedSuccess;

  /// No description provided for @storyPublishError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao publicar story. Tente novamente.'**
  String get storyPublishError;

  /// No description provided for @storyPrefetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao carregar imagem do post.'**
  String get storyPrefetchError;

  /// No description provided for @storyPrefetchLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando imagem do post...'**
  String get storyPrefetchLoading;

  /// No description provided for @storyCaptionHint.
  ///
  /// In pt, this message translates to:
  /// **'Escreva uma legenda (opcional)…'**
  String get storyCaptionHint;

  /// No description provided for @storySwapMedia.
  ///
  /// In pt, this message translates to:
  /// **'Trocar mídia'**
  String get storySwapMedia;

  /// No description provided for @storyPickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecione ou grave uma mídia'**
  String get storyPickerTitle;

  /// No description provided for @storyPickerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Foto ou vídeo (até 60s)'**
  String get storyPickerSubtitle;

  /// No description provided for @storyPickerSectionGallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get storyPickerSectionGallery;

  /// No description provided for @storyPickerSectionCamera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get storyPickerSectionCamera;

  /// No description provided for @storyPickerChipPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get storyPickerChipPhoto;

  /// No description provided for @storyPickerChipVideo.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo'**
  String get storyPickerChipVideo;

  /// No description provided for @storyPickerChipRecordVideo.
  ///
  /// In pt, this message translates to:
  /// **'Gravar vídeo'**
  String get storyPickerChipRecordVideo;

  /// No description provided for @storiesReload.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar stories'**
  String get storiesReload;

  /// No description provided for @storiesYour.
  ///
  /// In pt, this message translates to:
  /// **'Seu story'**
  String get storiesYour;

  /// No description provided for @storiesCreate.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get storiesCreate;

  /// No description provided for @storiesFallbackUser.
  ///
  /// In pt, this message translates to:
  /// **'usuário'**
  String get storiesFallbackUser;

  /// No description provided for @storiesLiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'LIVE'**
  String get storiesLiveBadge;

  /// No description provided for @shareLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar contatos.'**
  String get shareLoadError;

  /// No description provided for @shareSentSuccess.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Enviado para {count} pessoa.} other{Enviado para {count} pessoas.}}'**
  String shareSentSuccess(int count);

  /// No description provided for @shareSentPartial.
  ///
  /// In pt, this message translates to:
  /// **'Enviado para {sent}. Falha em {failures}.'**
  String shareSentPartial(int sent, int failures);

  /// No description provided for @shareTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para...'**
  String get shareTitle;

  /// No description provided for @sharePostFallback.
  ///
  /// In pt, this message translates to:
  /// **'Publicação'**
  String get sharePostFallback;

  /// No description provided for @shareSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get shareSearchHint;

  /// No description provided for @shareErrorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get shareErrorGeneric;

  /// No description provided for @shareTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get shareTryAgain;

  /// No description provided for @shareRecents.
  ///
  /// In pt, this message translates to:
  /// **'Recentes'**
  String get shareRecents;

  /// No description provided for @shareFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get shareFollowers;

  /// No description provided for @shareUserFallback.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get shareUserFallback;

  /// No description provided for @shareNoContacts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum contato encontrado.'**
  String get shareNoContacts;

  /// No description provided for @shareCommentHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicione um comentário…'**
  String get shareCommentHint;

  /// No description provided for @shareOutsideBrawe.
  ///
  /// In pt, this message translates to:
  /// **'Fora do Brawe'**
  String get shareOutsideBrawe;

  /// No description provided for @shareSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get shareSend;

  /// No description provided for @shareSendWithCount.
  ///
  /// In pt, this message translates to:
  /// **'Enviar ({count})'**
  String shareSendWithCount(int count);

  /// No description provided for @giftSendError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o presente: {error}'**
  String giftSendError(Object error);

  /// No description provided for @giftLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os presentes.\n{error}'**
  String giftLoadError(Object error);

  /// No description provided for @giftEmptyState.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum presente disponível agora.'**
  String get giftEmptyState;

  /// No description provided for @giftSendTo.
  ///
  /// In pt, this message translates to:
  /// **'Enviar presente pra'**
  String get giftSendTo;

  /// No description provided for @giftChoose.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um presente'**
  String get giftChoose;

  /// No description provided for @giftSendCta.
  ///
  /// In pt, this message translates to:
  /// **'ENVIAR · 💎 {total}'**
  String giftSendCta(int total);

  /// No description provided for @suggestedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões para você'**
  String get suggestedTitle;

  /// No description provided for @suggestedSeeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get suggestedSeeAll;

  /// No description provided for @suggestedFollow.
  ///
  /// In pt, this message translates to:
  /// **'Seguir'**
  String get suggestedFollow;

  /// No description provided for @suggestedFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get suggestedFollowing;

  /// No description provided for @suggestedLiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get suggestedLiveBadge;

  /// No description provided for @composerMediaLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a mídia.'**
  String get composerMediaLoadError;

  /// No description provided for @composerPhotoError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao tirar foto.'**
  String get composerPhotoError;

  /// No description provided for @composerRecordStartError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao iniciar gravação.'**
  String get composerRecordStartError;

  /// No description provided for @composerRecordStopError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao finalizar gravação.'**
  String get composerRecordStopError;

  /// No description provided for @composerStoryPublished.
  ///
  /// In pt, this message translates to:
  /// **'Story publicado!'**
  String get composerStoryPublished;

  /// No description provided for @composerMultipleStoriesPublished.
  ///
  /// In pt, this message translates to:
  /// **'{count} stories publicados!'**
  String composerMultipleStoriesPublished(int count);

  /// No description provided for @composerPublishError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao publicar story.'**
  String get composerPublishError;

  /// Aviso quando o upload de story dá timeout: o backend pode ter persistido com sucesso mesmo assim. Evita o usuário pensar que falhou e tentar de novo, criando duplicatas.
  ///
  /// In pt, this message translates to:
  /// **'Conexão lenta — verifique seu feed; se o story já estiver lá, está publicado.'**
  String get composerPublishTimeoutMaybe;

  /// No description provided for @composerRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get composerRetry;

  /// No description provided for @composerPreparing.
  ///
  /// In pt, this message translates to:
  /// **'Preparando publicação…'**
  String get composerPreparing;

  /// No description provided for @composerCreateStory.
  ///
  /// In pt, this message translates to:
  /// **'Criar story'**
  String get composerCreateStory;

  /// No description provided for @composerCaptureHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque para foto • Segure para vídeo'**
  String get composerCaptureHint;

  /// No description provided for @composerGallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get composerGallery;

  /// No description provided for @composerTextOnly.
  ///
  /// In pt, this message translates to:
  /// **'Só texto'**
  String get composerTextOnly;

  /// No description provided for @composerFrameNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem moldura'**
  String get composerFrameNone;

  /// No description provided for @composerFramePolaroid.
  ///
  /// In pt, this message translates to:
  /// **'Polaroid'**
  String get composerFramePolaroid;

  /// No description provided for @composerFrameBrawe.
  ///
  /// In pt, this message translates to:
  /// **'Brawe'**
  String get composerFrameBrawe;

  /// No description provided for @composerFrameHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque 2x para moldura'**
  String get composerFrameHint;

  /// No description provided for @composerFrameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Moldura: {style}'**
  String composerFrameLabel(String style);

  /// No description provided for @composerCaptionHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma legenda...'**
  String get composerCaptionHint;

  /// No description provided for @composerYourStory.
  ///
  /// In pt, this message translates to:
  /// **'Seu story'**
  String get composerYourStory;

  /// No description provided for @composerShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get composerShare;

  /// No description provided for @composerTapOutsideHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque fora para concluir'**
  String get composerTapOutsideHint;

  /// No description provided for @composerTextHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite algo...'**
  String get composerTextHint;

  /// No description provided for @composerGuideTop.
  ///
  /// In pt, this message translates to:
  /// **'topo seguro'**
  String get composerGuideTop;

  /// No description provided for @composerGuideBottom.
  ///
  /// In pt, this message translates to:
  /// **'base segura'**
  String get composerGuideBottom;

  /// Tooltip do botão de download na top bar do editor de stories que salva a mídia editada na galeria/rolo da câmera.
  ///
  /// In pt, this message translates to:
  /// **'Salvar no dispositivo'**
  String get composerSaveToDevice;

  /// No description provided for @composerSavedToDevice.
  ///
  /// In pt, this message translates to:
  /// **'Salvo na galeria'**
  String get composerSavedToDevice;

  /// No description provided for @composerSavePermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permissão de acesso à galeria negada.'**
  String get composerSavePermissionDenied;

  /// No description provided for @composerSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar.'**
  String get composerSaveError;

  /// No description provided for @trimTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cortar vídeo'**
  String get trimTitle;

  /// No description provided for @trimSave.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get trimSave;

  /// No description provided for @trimCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get trimCancel;

  /// No description provided for @trimProcessing.
  ///
  /// In pt, this message translates to:
  /// **'Salvando…'**
  String get trimProcessing;

  /// No description provided for @trimDuration.
  ///
  /// In pt, this message translates to:
  /// **'{seconds}s'**
  String trimDuration(String seconds);

  /// No description provided for @trimError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o vídeo cortado.'**
  String get trimError;

  /// No description provided for @trimHint.
  ///
  /// In pt, this message translates to:
  /// **'Arraste as alças para escolher início e fim'**
  String get trimHint;

  /// No description provided for @volumeMixerButtonLabel.
  ///
  /// In pt, this message translates to:
  /// **'Volumes'**
  String get volumeMixerButtonLabel;

  /// No description provided for @volumeMixerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Volumes'**
  String get volumeMixerTitle;

  /// No description provided for @volumeMixerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste o volume da música e do áudio original do vídeo'**
  String get volumeMixerSubtitle;

  /// No description provided for @volumeMixerMusicLabel.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get volumeMixerMusicLabel;

  /// No description provided for @volumeMixerOriginalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Áudio original do vídeo'**
  String get volumeMixerOriginalLabel;

  /// No description provided for @volumeMixerDone.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get volumeMixerDone;

  /// Aba/categoria do tier gratuito de presentes (pagos com moedas/XP de quests). Renomeado de 'Free' para 'Cofre' — comunica que são presentes de um baú que o usuário acumulou com atividade, não com dinheiro real.
  ///
  /// In pt, this message translates to:
  /// **'Cofre'**
  String get giftTierFree;

  /// No description provided for @giftTierBasic.
  ///
  /// In pt, this message translates to:
  /// **'Básico'**
  String get giftTierBasic;

  /// No description provided for @giftTierPremium.
  ///
  /// In pt, this message translates to:
  /// **'Premium'**
  String get giftTierPremium;

  /// No description provided for @giftTierLuxury.
  ///
  /// In pt, this message translates to:
  /// **'Luxo'**
  String get giftTierLuxury;

  /// No description provided for @giftTierLegendary.
  ///
  /// In pt, this message translates to:
  /// **'Lendário'**
  String get giftTierLegendary;

  /// No description provided for @viewerDeleteStory.
  ///
  /// In pt, this message translates to:
  /// **'Excluir story'**
  String get viewerDeleteStory;

  /// No description provided for @viewerUnfollow.
  ///
  /// In pt, this message translates to:
  /// **'Deixar de seguir'**
  String get viewerUnfollow;

  /// No description provided for @viewerBlockUser.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear usuário'**
  String get viewerBlockUser;

  /// No description provided for @viewerReport.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar'**
  String get viewerReport;

  /// No description provided for @viewerDeleteConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não pode ser desfeita.'**
  String get viewerDeleteConfirm;

  /// No description provided for @viewerCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get viewerCancel;

  /// No description provided for @viewerDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get viewerDelete;

  /// No description provided for @viewerBlock.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear'**
  String get viewerBlock;

  /// No description provided for @viewerStoryDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Story excluído.'**
  String get viewerStoryDeleted;

  /// No description provided for @viewerDeleteError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível excluir o story. ({error})'**
  String viewerDeleteError(Object error);

  /// No description provided for @viewerUnfollowed.
  ///
  /// In pt, this message translates to:
  /// **'Você deixou de seguir @{username}.'**
  String viewerUnfollowed(String username);

  /// No description provided for @viewerUnfollowError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível deixar de seguir.'**
  String get viewerUnfollowError;

  /// No description provided for @viewerBlockConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Você não verá mais conteúdo de @{username}.'**
  String viewerBlockConfirm(String username);

  /// No description provided for @viewerBlockError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível bloquear.'**
  String get viewerBlockError;

  /// No description provided for @viewerReportPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Por que você está denunciando?'**
  String get viewerReportPrompt;

  /// No description provided for @viewerReportSpam.
  ///
  /// In pt, this message translates to:
  /// **'Spam ou enganoso'**
  String get viewerReportSpam;

  /// No description provided for @viewerReportHarassment.
  ///
  /// In pt, this message translates to:
  /// **'Assédio ou bullying'**
  String get viewerReportHarassment;

  /// No description provided for @viewerReportInappropriate.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo impróprio ou ofensivo'**
  String get viewerReportInappropriate;

  /// No description provided for @viewerReportImpersonation.
  ///
  /// In pt, this message translates to:
  /// **'Falsa identidade'**
  String get viewerReportImpersonation;

  /// No description provided for @viewerReportOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get viewerReportOther;

  /// No description provided for @viewerReportSent.
  ///
  /// In pt, this message translates to:
  /// **'Denúncia enviada. Obrigado.'**
  String get viewerReportSent;

  /// No description provided for @viewerReportError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar a denúncia.'**
  String get viewerReportError;

  /// No description provided for @viewerSeeOriginalPost.
  ///
  /// In pt, this message translates to:
  /// **'Ver post original'**
  String get viewerSeeOriginalPost;

  /// No description provided for @viewerReplySent.
  ///
  /// In pt, this message translates to:
  /// **'Resposta enviada.'**
  String get viewerReplySent;

  /// No description provided for @viewerReplyError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível responder.'**
  String get viewerReplyError;

  /// No description provided for @viewerReplyHint.
  ///
  /// In pt, this message translates to:
  /// **'Responder ao story...'**
  String get viewerReplyHint;

  /// No description provided for @viewerGiftSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviou {giftName} x{quantity} · 💎 {credits}'**
  String viewerGiftSent(String giftName, int quantity, int credits);

  /// No description provided for @viewerLoadViewersError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar visualizadores.'**
  String get viewerLoadViewersError;

  /// No description provided for @viewerTimeNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get viewerTimeNow;

  /// No description provided for @viewerTimeMinutes.
  ///
  /// In pt, this message translates to:
  /// **'há {minutes}m'**
  String viewerTimeMinutes(int minutes);

  /// No description provided for @viewerTimeHours.
  ///
  /// In pt, this message translates to:
  /// **'há {hours}h'**
  String viewerTimeHours(int hours);

  /// No description provided for @viewerTimeDays.
  ///
  /// In pt, this message translates to:
  /// **'há {days}d'**
  String viewerTimeDays(int days);

  /// No description provided for @viewerLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get viewerLoading;

  /// No description provided for @viewerNoViewers.
  ///
  /// In pt, this message translates to:
  /// **'Ainda ninguém viu este story.'**
  String get viewerNoViewers;

  /// No description provided for @viewerBlocked.
  ///
  /// In pt, this message translates to:
  /// **'@{username} bloqueado.'**
  String viewerBlocked(String username);

  /// No description provided for @viewerViewsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 visualização} other{{count} visualizações}}'**
  String viewerViewsCount(int count);

  /// No description provided for @feedTabForYou.
  ///
  /// In pt, this message translates to:
  /// **'Para Você'**
  String get feedTabForYou;

  /// No description provided for @feedTabFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get feedTabFollowing;

  /// No description provided for @feedEmptyQuietTitle.
  ///
  /// In pt, this message translates to:
  /// **'O feed está quietinho'**
  String get feedEmptyQuietTitle;

  /// No description provided for @feedEmptyQuietSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seja o primeiro a postar algo brilhante hoje.'**
  String get feedEmptyQuietSubtitle;

  /// No description provided for @feedEmptyFollowingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui ainda'**
  String get feedEmptyFollowingTitle;

  /// No description provided for @feedEmptyFollowingSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Siga pessoas para ver os posts delas aqui.'**
  String get feedEmptyFollowingSubtitle;

  /// No description provided for @feedOfflineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão por aqui'**
  String get feedOfflineTitle;

  /// No description provided for @feedOfflineSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua internet e tente de novo.'**
  String get feedOfflineSubtitle;

  /// No description provided for @feedRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get feedRetry;

  /// No description provided for @feedSaved.
  ///
  /// In pt, this message translates to:
  /// **'Salvo nos seus favoritos'**
  String get feedSaved;

  /// No description provided for @feedUnsaved.
  ///
  /// In pt, this message translates to:
  /// **'Removido dos favoritos'**
  String get feedUnsaved;

  /// No description provided for @feedLinkCopied.
  ///
  /// In pt, this message translates to:
  /// **'Link copiado!'**
  String get feedLinkCopied;

  /// No description provided for @feedDeletePostTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir post?'**
  String get feedDeletePostTitle;

  /// No description provided for @feedDeleteConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não pode ser desfeita.'**
  String get feedDeleteConfirm;

  /// No description provided for @feedCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get feedCancel;

  /// No description provided for @feedDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get feedDelete;

  /// No description provided for @feedPostDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Post excluído.'**
  String get feedPostDeleted;

  /// No description provided for @feedPostDeleteError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível excluir o post.'**
  String get feedPostDeleteError;

  /// No description provided for @feedUnfollowed.
  ///
  /// In pt, this message translates to:
  /// **'Você deixou de seguir @{username}.'**
  String feedUnfollowed(String username);

  /// No description provided for @feedUnfollowError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível deixar de seguir.'**
  String get feedUnfollowError;

  /// No description provided for @feedBlockUserTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear usuário'**
  String get feedBlockUserTitle;

  /// No description provided for @feedBlockConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Você não verá mais conteúdo de @{username}. Deseja continuar?'**
  String feedBlockConfirm(String username);

  /// No description provided for @feedBlock.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear'**
  String get feedBlock;

  /// No description provided for @feedBlockError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível bloquear.'**
  String get feedBlockError;

  /// No description provided for @feedReportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar post'**
  String get feedReportTitle;

  /// No description provided for @feedReportPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Por que você está denunciando?'**
  String get feedReportPrompt;

  /// No description provided for @feedReportSpam.
  ///
  /// In pt, this message translates to:
  /// **'Spam ou enganoso'**
  String get feedReportSpam;

  /// No description provided for @feedReportHarassment.
  ///
  /// In pt, this message translates to:
  /// **'Assédio ou bullying'**
  String get feedReportHarassment;

  /// No description provided for @feedReportInappropriate.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo impróprio ou ofensivo'**
  String get feedReportInappropriate;

  /// No description provided for @feedReportImpersonation.
  ///
  /// In pt, this message translates to:
  /// **'Falsa identidade'**
  String get feedReportImpersonation;

  /// No description provided for @feedReportOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get feedReportOther;

  /// No description provided for @feedReportSent.
  ///
  /// In pt, this message translates to:
  /// **'Denúncia enviada. Obrigado por nos avisar.'**
  String get feedReportSent;

  /// No description provided for @feedReportError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar a denúncia.'**
  String get feedReportError;

  /// No description provided for @feedRepostUndoConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer repost?'**
  String get feedRepostUndoConfirm;

  /// No description provided for @feedRepostConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Repostar para seus seguidores?'**
  String get feedRepostConfirm;

  /// No description provided for @feedRepostUndo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer repost'**
  String get feedRepostUndo;

  /// No description provided for @feedRepost.
  ///
  /// In pt, this message translates to:
  /// **'Repostar'**
  String get feedRepost;

  /// No description provided for @feedReposted.
  ///
  /// In pt, this message translates to:
  /// **'Repostado para seus seguidores'**
  String get feedReposted;

  /// No description provided for @shareToFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para seguidores'**
  String get shareToFollowers;

  /// No description provided for @feedRepostBanner.
  ///
  /// In pt, this message translates to:
  /// **'{name} repostou'**
  String feedRepostBanner(String name);

  /// No description provided for @feedQuotePost.
  ///
  /// In pt, this message translates to:
  /// **'Citar post'**
  String get feedQuotePost;

  /// No description provided for @feedCopyLink.
  ///
  /// In pt, this message translates to:
  /// **'Copiar link'**
  String get feedCopyLink;

  /// No description provided for @feedShareAsStory.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar como Story'**
  String get feedShareAsStory;

  /// No description provided for @feedUnfollow.
  ///
  /// In pt, this message translates to:
  /// **'Deixar de seguir'**
  String get feedUnfollow;

  /// No description provided for @feedReport.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar'**
  String get feedReport;

  /// No description provided for @feedDeletePost.
  ///
  /// In pt, this message translates to:
  /// **'Excluir post'**
  String get feedDeletePost;

  /// No description provided for @feedSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get feedSend;

  /// No description provided for @feedTimeNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get feedTimeNow;

  /// No description provided for @feedBlocked.
  ///
  /// In pt, this message translates to:
  /// **'@{username} bloqueado.'**
  String feedBlocked(String username);

  /// No description provided for @chatStatusOnline.
  ///
  /// In pt, this message translates to:
  /// **'Online'**
  String get chatStatusOnline;

  /// No description provided for @chatStatusAway.
  ///
  /// In pt, this message translates to:
  /// **'Ausente'**
  String get chatStatusAway;

  /// No description provided for @chatStatusDnd.
  ///
  /// In pt, this message translates to:
  /// **'Não perturbe'**
  String get chatStatusDnd;

  /// No description provided for @chatStatusInvisible.
  ///
  /// In pt, this message translates to:
  /// **'Invisível'**
  String get chatStatusInvisible;

  /// No description provided for @chatStatusSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meu Status'**
  String get chatStatusSheetTitle;

  /// No description provided for @chatStatusSheetSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha como você aparece para outros usuários.'**
  String get chatStatusSheetSubtitle;

  /// No description provided for @chatNewMessageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova Mensagem'**
  String get chatNewMessageTitle;

  /// No description provided for @chatSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar pessoas que você segue…'**
  String get chatSearchHint;

  /// No description provided for @chatFollowingLabel.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get chatFollowingLabel;

  /// No description provided for @chatStartConversationError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao iniciar conversa: {error}'**
  String chatStartConversationError(Object error);

  /// No description provided for @chatLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar: {error}'**
  String chatLoadError(Object error);

  /// No description provided for @chatLiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get chatLiveBadge;

  /// No description provided for @chatFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Chat'**
  String get chatFallbackName;

  /// No description provided for @chatEmptySearchTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma pessoa encontrada'**
  String get chatEmptySearchTitle;

  /// No description provided for @chatEmptySearchSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Tente pesquisar por nome ou @username de alguém que você segue.'**
  String get chatEmptySearchSubtitle;

  /// No description provided for @chatListTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens'**
  String get chatListTitle;

  /// No description provided for @chatListSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar conversas, pessoas…'**
  String get chatListSearchHint;

  /// No description provided for @chatListTabAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get chatListTabAll;

  /// No description provided for @chatListTabUnread.
  ///
  /// In pt, this message translates to:
  /// **'Não lidas'**
  String get chatListTabUnread;

  /// No description provided for @chatListTabArchived.
  ///
  /// In pt, this message translates to:
  /// **'Arquivadas'**
  String get chatListTabArchived;

  /// No description provided for @chatListRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get chatListRetry;

  /// No description provided for @chatListNewTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Nova conversa'**
  String get chatListNewTooltip;

  /// No description provided for @chatListEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comece uma conversa'**
  String get chatListEmptyTitle;

  /// No description provided for @chatListEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Suas mensagens com creators, amigos e brawers vão aparecer aqui.'**
  String get chatListEmptySubtitle;

  /// No description provided for @chatListTapToTalk.
  ///
  /// In pt, this message translates to:
  /// **'Toque para conversar'**
  String get chatListTapToTalk;

  /// No description provided for @chatListArchive.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar'**
  String get chatListArchive;

  /// No description provided for @chatListUnarchive.
  ///
  /// In pt, this message translates to:
  /// **'Desarquivar'**
  String get chatListUnarchive;

  /// No description provided for @chatListDelete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get chatListDelete;

  /// No description provided for @chatListDeleteConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar conversa?'**
  String get chatListDeleteConfirmTitle;

  /// No description provided for @chatListDeleteConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'A conversa será apagada apenas para você.'**
  String get chatListDeleteConfirmBody;

  /// No description provided for @chatListCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get chatListCancel;

  /// No description provided for @chatListTimeNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get chatListTimeNow;

  /// No description provided for @chatDetailPickImageError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao escolher imagem: {error}'**
  String chatDetailPickImageError(Object error);

  /// No description provided for @chatDetailBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear {name}?'**
  String chatDetailBlockTitle(String name);

  /// No description provided for @chatDetailBlockBody.
  ///
  /// In pt, this message translates to:
  /// **'Você não poderá mais enviar ou receber mensagens desta pessoa.'**
  String get chatDetailBlockBody;

  /// No description provided for @chatDetailCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get chatDetailCancel;

  /// No description provided for @chatDetailBlock.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear'**
  String get chatDetailBlock;

  /// No description provided for @chatDetailBlocked.
  ///
  /// In pt, this message translates to:
  /// **'{name} foi bloqueado(a).'**
  String chatDetailBlocked(String name);

  /// No description provided for @chatDetailBlockError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao bloquear: {error}'**
  String chatDetailBlockError(Object error);

  /// No description provided for @chatDetailViewProfile.
  ///
  /// In pt, this message translates to:
  /// **'Ver perfil'**
  String get chatDetailViewProfile;

  /// No description provided for @chatDetailOpenProfileError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o perfil deste contato.'**
  String get chatDetailOpenProfileError;

  /// No description provided for @chatDetailMute.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar notificações'**
  String get chatDetailMute;

  /// No description provided for @chatDetailComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get chatDetailComingSoon;

  /// No description provided for @chatDetailSearchInChat.
  ///
  /// In pt, this message translates to:
  /// **'Buscar na conversa'**
  String get chatDetailSearchInChat;

  /// No description provided for @chatDetailBlockMenu.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear {name}'**
  String chatDetailBlockMenu(String name);

  /// No description provided for @chatDetailReport.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar'**
  String get chatDetailReport;

  /// No description provided for @chatDetailReportSent.
  ///
  /// In pt, this message translates to:
  /// **'Denúncia enviada. Obrigado!'**
  String get chatDetailReportSent;

  /// No description provided for @chatDetailStatusTyping.
  ///
  /// In pt, this message translates to:
  /// **'digitando'**
  String get chatDetailStatusTyping;

  /// No description provided for @chatDetailStatusOnline.
  ///
  /// In pt, this message translates to:
  /// **'Online'**
  String get chatDetailStatusOnline;

  /// No description provided for @chatDetailStatusSeen.
  ///
  /// In pt, this message translates to:
  /// **'visto {when}'**
  String chatDetailStatusSeen(String when);

  /// No description provided for @chatDetailStatusOffline.
  ///
  /// In pt, this message translates to:
  /// **'Offline'**
  String get chatDetailStatusOffline;

  /// No description provided for @chatDetailDateToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get chatDetailDateToday;

  /// No description provided for @chatDetailDateYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get chatDetailDateYesterday;

  /// No description provided for @chatDetailReply.
  ///
  /// In pt, this message translates to:
  /// **'Responder'**
  String get chatDetailReply;

  /// No description provided for @chatDetailCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get chatDetailCopy;

  /// No description provided for @chatDetailDeleteForMe.
  ///
  /// In pt, this message translates to:
  /// **'Apagar para mim'**
  String get chatDetailDeleteForMe;

  /// No description provided for @chatDetailViewOnceBadge.
  ///
  /// In pt, this message translates to:
  /// **'Ver 1x'**
  String get chatDetailViewOnceBadge;

  /// No description provided for @chatDetailViewOnceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Visualização única'**
  String get chatDetailViewOnceTitle;

  /// No description provided for @chatDetailPhotoViewedOnce.
  ///
  /// In pt, this message translates to:
  /// **'Foto vista por 1 vez'**
  String get chatDetailPhotoViewedOnce;

  /// No description provided for @chatDetailPhotoUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Foto não está mais disponível'**
  String get chatDetailPhotoUnavailable;

  /// No description provided for @chatDetailEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Diga olá 👋'**
  String get chatDetailEmptyTitle;

  /// No description provided for @chatDetailEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Envie a primeira mensagem para começar a conversa.'**
  String get chatDetailEmptySubtitle;

  /// No description provided for @chatDetailReplying.
  ///
  /// In pt, this message translates to:
  /// **'Respondendo'**
  String get chatDetailReplying;

  /// No description provided for @chatDetailReplyImagePreview.
  ///
  /// In pt, this message translates to:
  /// **'📷 Foto'**
  String get chatDetailReplyImagePreview;

  /// No description provided for @chatDetailMessageHint.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem'**
  String get chatDetailMessageHint;

  /// No description provided for @chatDetailVoiceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem de voz'**
  String get chatDetailVoiceTitle;

  /// No description provided for @chatDetailVoiceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Em breve — gravação com waveform animado'**
  String get chatDetailVoiceSubtitle;

  /// No description provided for @chatDetailClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get chatDetailClose;

  /// No description provided for @chatDetailAttachGallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get chatDetailAttachGallery;

  /// No description provided for @chatDetailAttachCamera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get chatDetailAttachCamera;

  /// No description provided for @chatDetailAttachAudio.
  ///
  /// In pt, this message translates to:
  /// **'Áudio'**
  String get chatDetailAttachAudio;

  /// No description provided for @chatDetailAttachLocation.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get chatDetailAttachLocation;

  /// No description provided for @chatDetailAttachFile.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo'**
  String get chatDetailAttachFile;

  /// No description provided for @chatDetailAttachMystery.
  ///
  /// In pt, this message translates to:
  /// **'Mistério'**
  String get chatDetailAttachMystery;

  /// No description provided for @chatDetailRelativeNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get chatDetailRelativeNow;

  /// No description provided for @chatDetailRelativeMinutes.
  ///
  /// In pt, this message translates to:
  /// **'há {minutes}m'**
  String chatDetailRelativeMinutes(int minutes);

  /// No description provided for @chatDetailRelativeHours.
  ///
  /// In pt, this message translates to:
  /// **'há {hours}h'**
  String chatDetailRelativeHours(int hours);

  /// No description provided for @chatDetailRelativeDays.
  ///
  /// In pt, this message translates to:
  /// **'há {days}d'**
  String chatDetailRelativeDays(int days);

  /// No description provided for @chatDetailViewPost.
  ///
  /// In pt, this message translates to:
  /// **'Ver publicação'**
  String get chatDetailViewPost;

  /// No description provided for @chatDetailPostUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Publicação indisponível'**
  String get chatDetailPostUnavailable;

  /// No description provided for @chatDetailOpenPostSoon.
  ///
  /// In pt, this message translates to:
  /// **'Abrir publicação em breve'**
  String get chatDetailOpenPostSoon;

  /// No description provided for @chatDetailBurnedPreview.
  ///
  /// In pt, this message translates to:
  /// **'🔥 Mensagem queimada'**
  String get chatDetailBurnedPreview;

  /// No description provided for @chatDetailStreamerFallback.
  ///
  /// In pt, this message translates to:
  /// **'Streamer'**
  String get chatDetailStreamerFallback;

  /// No description provided for @chatDetailLiveFallbackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Live'**
  String get chatDetailLiveFallbackTitle;

  /// No description provided for @chatDetailLiveTapToWatch.
  ///
  /// In pt, this message translates to:
  /// **'Toque para assistir'**
  String get chatDetailLiveTapToWatch;

  /// No description provided for @chatDetailLiveSeeDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get chatDetailLiveSeeDetails;

  /// No description provided for @chatDetailEmojiSmileys.
  ///
  /// In pt, this message translates to:
  /// **'Smileys'**
  String get chatDetailEmojiSmileys;

  /// No description provided for @chatDetailEmojiGestures.
  ///
  /// In pt, this message translates to:
  /// **'Gestos'**
  String get chatDetailEmojiGestures;

  /// No description provided for @chatDetailEmojiHearts.
  ///
  /// In pt, this message translates to:
  /// **'Coração'**
  String get chatDetailEmojiHearts;

  /// No description provided for @chatDetailEmojiAnimals.
  ///
  /// In pt, this message translates to:
  /// **'Animais'**
  String get chatDetailEmojiAnimals;

  /// No description provided for @chatDetailEmojiFood.
  ///
  /// In pt, this message translates to:
  /// **'Comida'**
  String get chatDetailEmojiFood;

  /// No description provided for @chatDetailEmojiParty.
  ///
  /// In pt, this message translates to:
  /// **'Festa'**
  String get chatDetailEmojiParty;

  /// No description provided for @chatDetailEmojiObjects.
  ///
  /// In pt, this message translates to:
  /// **'Objetos'**
  String get chatDetailEmojiObjects;

  /// No description provided for @profileTabGallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get profileTabGallery;

  /// No description provided for @profileTabLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives'**
  String get profileTabLives;

  /// No description provided for @profileTabShop.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get profileTabShop;

  /// No description provided for @profileTooltipShop.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get profileTooltipShop;

  /// No description provided for @profileTooltipQuests.
  ///
  /// In pt, this message translates to:
  /// **'Quests'**
  String get profileTooltipQuests;

  /// No description provided for @profileTooltipNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get profileTooltipNotifications;

  /// No description provided for @profileTooltipWallet.
  ///
  /// In pt, this message translates to:
  /// **'Carteira'**
  String get profileTooltipWallet;

  /// No description provided for @profileShareFail.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível compartilhar.'**
  String get profileShareFail;

  /// No description provided for @profileLinkCopied.
  ///
  /// In pt, this message translates to:
  /// **'Link copiado para a área de transferência'**
  String get profileLinkCopied;

  /// No description provided for @profileBlockedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Usuário bloqueado.'**
  String get profileBlockedSuccess;

  /// No description provided for @profileBlockedError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao bloquear. Tente novamente.'**
  String get profileBlockedError;

  /// No description provided for @profileReportSent.
  ///
  /// In pt, this message translates to:
  /// **'Denúncia enviada. Obrigado.'**
  String get profileReportSent;

  /// No description provided for @profileReportError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao denunciar. Tente novamente.'**
  String get profileReportError;

  /// No description provided for @profileBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear'**
  String get profileBlockTitle;

  /// No description provided for @profileBlockBody.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja bloquear {name}? Vocês não poderão mais trocar mensagens nem ver conteúdo um do outro.'**
  String profileBlockBody(String name);

  /// No description provided for @profileFallbackUser.
  ///
  /// In pt, this message translates to:
  /// **'este usuário'**
  String get profileFallbackUser;

  /// No description provided for @profileReportQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Por que está denunciando?'**
  String get profileReportQuestion;

  /// No description provided for @profileReportReasonSpam.
  ///
  /// In pt, this message translates to:
  /// **'Spam'**
  String get profileReportReasonSpam;

  /// No description provided for @profileReportReasonHarassment.
  ///
  /// In pt, this message translates to:
  /// **'Assédio ou bullying'**
  String get profileReportReasonHarassment;

  /// No description provided for @profileReportReasonInappropriate.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo impróprio'**
  String get profileReportReasonInappropriate;

  /// No description provided for @profileReportReasonImpersonation.
  ///
  /// In pt, this message translates to:
  /// **'Falsa identidade'**
  String get profileReportReasonImpersonation;

  /// No description provided for @profileReportReasonOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro motivo'**
  String get profileReportReasonOther;

  /// No description provided for @profileOptionShareProfile.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar perfil'**
  String get profileOptionShareProfile;

  /// No description provided for @profileOptionCopyLink.
  ///
  /// In pt, this message translates to:
  /// **'Copiar link'**
  String get profileOptionCopyLink;

  /// No description provided for @profileOptionReport.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar'**
  String get profileOptionReport;

  /// No description provided for @profileOptionDailyQuests.
  ///
  /// In pt, this message translates to:
  /// **'Quests diárias'**
  String get profileOptionDailyQuests;

  /// No description provided for @profileOptionWallet.
  ///
  /// In pt, this message translates to:
  /// **'Carteira'**
  String get profileOptionWallet;

  /// No description provided for @profileOptionNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get profileOptionNotifications;

  /// No description provided for @profileOptionSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get profileOptionSettings;

  /// No description provided for @profileOptionLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get profileOptionLogout;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutBody.
  ///
  /// In pt, this message translates to:
  /// **'Você precisará entrar novamente para acessar sua arena.'**
  String get profileLogoutBody;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get profileLogoutConfirm;

  /// No description provided for @profileMessageButton.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem'**
  String get profileMessageButton;

  /// No description provided for @profileOpenConversationError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao abrir conversa: {error}'**
  String profileOpenConversationError(Object error);

  /// No description provided for @profileChatFallback.
  ///
  /// In pt, this message translates to:
  /// **'Chat'**
  String get profileChatFallback;

  /// No description provided for @profileUserFallback.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get profileUserFallback;

  /// No description provided for @profileEditTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil'**
  String get profileEditTooltip;

  /// No description provided for @profileStatFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get profileStatFollowers;

  /// No description provided for @profileStatFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get profileStatFollowing;

  /// No description provided for @profileStatLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives'**
  String get profileStatLives;

  /// No description provided for @profileStatViews.
  ///
  /// In pt, this message translates to:
  /// **'Views'**
  String get profileStatViews;

  /// No description provided for @profileLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o perfil'**
  String get profileLoadError;

  /// No description provided for @profileLoadErrorHint.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua conexão e tente novamente.'**
  String get profileLoadErrorHint;

  /// No description provided for @profileRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get profileRetry;

  /// No description provided for @profileSellerVerified.
  ///
  /// In pt, this message translates to:
  /// **'Parceiro verificado'**
  String get profileSellerVerified;

  /// No description provided for @profileSellerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Produtos selecionados com curadoria'**
  String get profileSellerSubtitle;

  /// No description provided for @shopVitrinePartnerItemsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} itens}}'**
  String shopVitrinePartnerItemsCount(int count);

  /// No description provided for @profileNoTextPosts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum post de texto ainda'**
  String get profileNoTextPosts;

  /// No description provided for @profilePostsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar posts'**
  String get profilePostsLoadError;

  /// No description provided for @profileNoLives.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma live ainda'**
  String get profileNoLives;

  /// No description provided for @profileLivesLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar lives'**
  String get profileLivesLoadError;

  /// No description provided for @profileShopEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Loja vazia'**
  String get profileShopEmpty;

  /// No description provided for @profileShopFeatured.
  ///
  /// In pt, this message translates to:
  /// **'Destaques'**
  String get profileShopFeatured;

  /// No description provided for @profileShopAllProducts.
  ///
  /// In pt, this message translates to:
  /// **'Todos os produtos'**
  String get profileShopAllProducts;

  /// No description provided for @profileShowcaseEmptyTitleMe.
  ///
  /// In pt, this message translates to:
  /// **'Sua vitrine está vazia'**
  String get profileShowcaseEmptyTitleMe;

  /// No description provided for @profileShowcaseEmptyTitleOther.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum produto ainda'**
  String get profileShowcaseEmptyTitleOther;

  /// No description provided for @profileShowcaseEmptySubtitleMe.
  ///
  /// In pt, this message translates to:
  /// **'Torne-se parceiro de marcas e mostre os produtos que você recomenda na sua vitrine.'**
  String get profileShowcaseEmptySubtitleMe;

  /// No description provided for @profileShowcaseEmptySubtitleOther.
  ///
  /// In pt, this message translates to:
  /// **'Este criador ainda não adicionou produtos à vitrine.'**
  String get profileShowcaseEmptySubtitleOther;

  /// No description provided for @profileShowcaseJoinCreatorNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Aderir ao Creator Network'**
  String get profileShowcaseJoinCreatorNetwork;

  /// No description provided for @profileLiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'LIVE'**
  String get profileLiveBadge;

  /// No description provided for @profileProductSoldOut.
  ///
  /// In pt, this message translates to:
  /// **'Esgotado'**
  String get profileProductSoldOut;

  /// No description provided for @profileProductSoldOutUppercase.
  ///
  /// In pt, this message translates to:
  /// **'ESGOTADO'**
  String get profileProductSoldOutUppercase;

  /// No description provided for @profileProductAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o produto'**
  String get profileProductAbout;

  /// No description provided for @profileProductUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get profileProductUnavailable;

  /// No description provided for @profileProductBuyNow.
  ///
  /// In pt, this message translates to:
  /// **'Comprar agora'**
  String get profileProductBuyNow;

  /// No description provided for @profileAddedToCart.
  ///
  /// In pt, this message translates to:
  /// **'🛒 Adicionado ao carrinho!'**
  String get profileAddedToCart;

  /// No description provided for @profileGalleryLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar galeria'**
  String get profileGalleryLoadError;

  /// No description provided for @profileGalleryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui ainda'**
  String get profileGalleryEmpty;

  /// No description provided for @profileGalleryRemoveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover mídia?'**
  String get profileGalleryRemoveTitle;

  /// No description provided for @profileGalleryRemoveBody.
  ///
  /// In pt, this message translates to:
  /// **'Essa ação não pode ser desfeita.'**
  String get profileGalleryRemoveBody;

  /// No description provided for @profileGalleryRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get profileGalleryRemove;

  /// No description provided for @profileVideoDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar vídeo?'**
  String get profileVideoDeleteTitle;

  /// No description provided for @profileVideoDelete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get profileVideoDelete;

  /// No description provided for @profileVideoDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo apagado'**
  String get profileVideoDeleted;

  /// No description provided for @profileVideoDeleteError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao apagar vídeo'**
  String get profileVideoDeleteError;

  /// No description provided for @profileVideoRepostStory.
  ///
  /// In pt, this message translates to:
  /// **'Repostar no Stories'**
  String get profileVideoRepostStory;

  /// No description provided for @profileVideoDeleteAction.
  ///
  /// In pt, this message translates to:
  /// **'Apagar vídeo'**
  String get profileVideoDeleteAction;

  /// No description provided for @profileVideoLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o vídeo.'**
  String get profileVideoLoadError;

  /// No description provided for @profileGalleryTabPhotos.
  ///
  /// In pt, this message translates to:
  /// **'Fotos ({count}/{max})'**
  String profileGalleryTabPhotos(int count, int max);

  /// No description provided for @profileGalleryTabVideos.
  ///
  /// In pt, this message translates to:
  /// **'Vídeos ({count}/{max})'**
  String profileGalleryTabVideos(int count, int max);

  /// No description provided for @profileGalleryPhotoAdded.
  ///
  /// In pt, this message translates to:
  /// **'Foto adicionada'**
  String get profileGalleryPhotoAdded;

  /// No description provided for @profileGalleryPhotoError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao enviar foto'**
  String get profileGalleryPhotoError;

  /// No description provided for @profileGalleryVideoAdded.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo adicionado'**
  String get profileGalleryVideoAdded;

  /// No description provided for @profileGalleryVideoError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao enviar vídeo'**
  String get profileGalleryVideoError;

  /// No description provided for @profileVideoDeleteBody.
  ///
  /// In pt, this message translates to:
  /// **'Essa ação não pode ser desfeita. O vídeo sairá do Para Você e do seu perfil.'**
  String get profileVideoDeleteBody;

  /// No description provided for @profileProductLastStock.
  ///
  /// In pt, this message translates to:
  /// **'Últimas {count}'**
  String profileProductLastStock(int count);

  /// No description provided for @profileProductSoldCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} vendidos'**
  String profileProductSoldCount(int count);

  /// No description provided for @profileProductLowStock.
  ///
  /// In pt, this message translates to:
  /// **'Apenas {count} restantes'**
  String profileProductLowStock(int count);

  /// No description provided for @profileProductInStock.
  ///
  /// In pt, this message translates to:
  /// **'{count} em estoque'**
  String profileProductInStock(int count);

  /// No description provided for @profileProductDescription.
  ///
  /// In pt, this message translates to:
  /// **'Produto exclusivo da loja oficial. Envio em até 3 dias úteis. Garantia de 30 dias e troca grátis.'**
  String get profileProductDescription;

  /// No description provided for @profilePriceBRL.
  ///
  /// In pt, this message translates to:
  /// **'R\\\$ {amount}'**
  String profilePriceBRL(String amount);

  /// No description provided for @profileVideosLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar vídeos'**
  String get profileVideosLoadError;

  /// No description provided for @profileVideosEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vídeo publicado ainda'**
  String get profileVideosEmpty;

  /// No description provided for @profileVideoSwipeHint.
  ///
  /// In pt, this message translates to:
  /// **'Deslize'**
  String get profileVideoSwipeHint;

  /// No description provided for @notificationsMarkAll.
  ///
  /// In pt, this message translates to:
  /// **'Marcar todas'**
  String get notificationsMarkAll;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tudo em dia!'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você não tem notificações novas.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui carregar suas notificações.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get notificationsTryAgain;

  /// No description provided for @notificationsTimeNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get notificationsTimeNow;

  /// No description provided for @notificationsTimeMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{n}m atrás'**
  String notificationsTimeMinutes(int n);

  /// No description provided for @notificationsTimeHours.
  ///
  /// In pt, this message translates to:
  /// **'{n}h atrás'**
  String notificationsTimeHours(int n);

  /// No description provided for @notificationsTimeDays.
  ///
  /// In pt, this message translates to:
  /// **'{n}d atrás'**
  String notificationsTimeDays(int n);

  /// No description provided for @followsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas'**
  String get followsTitle;

  /// No description provided for @followsTabFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get followsTabFollowers;

  /// No description provided for @followsTabFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get followsTabFollowing;

  /// No description provided for @followsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar...'**
  String get followsSearchHint;

  /// No description provided for @followsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar'**
  String get followsLoadError;

  /// No description provided for @followsTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get followsTryAgain;

  /// No description provided for @followsNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado para \"{q}\"'**
  String followsNoResults(String q);

  /// No description provided for @followsEmptyFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem seguidores'**
  String get followsEmptyFollowers;

  /// No description provided for @followsEmptyFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não segue ninguém'**
  String get followsEmptyFollowing;

  /// No description provided for @followsUserFallback.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get followsUserFallback;

  /// No description provided for @followsLiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'LIVE'**
  String get followsLiveBadge;

  /// No description provided for @questsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quests Diárias'**
  String get questsTitle;

  /// No description provided for @questsClaimAll.
  ///
  /// In pt, this message translates to:
  /// **'Coletar tudo ({count})'**
  String questsClaimAll(int count);

  /// No description provided for @questsClaimedReward.
  ///
  /// In pt, this message translates to:
  /// **'{n} recompensa(s) coletada(s)!'**
  String questsClaimedReward(int n);

  /// No description provided for @questsNothingToClaim.
  ///
  /// In pt, this message translates to:
  /// **'Nada para coletar agora.'**
  String get questsNothingToClaim;

  /// No description provided for @questsClaimSuccess.
  ///
  /// In pt, this message translates to:
  /// **'+{xp} XP · +{coins} moedas'**
  String questsClaimSuccess(int xp, int coins);

  /// No description provided for @questsClaimError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao resgatar. Tente novamente.'**
  String get questsClaimError;

  /// No description provided for @questsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem quests por enquanto.\nVolte mais tarde!'**
  String get questsEmpty;

  /// No description provided for @questsLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nível {level}'**
  String questsLevel(int level);

  /// No description provided for @questsXpProgress.
  ///
  /// In pt, this message translates to:
  /// **'{current} / {total} XP'**
  String questsXpProgress(int current, int total);

  /// No description provided for @questsSummaryCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas'**
  String get questsSummaryCompleted;

  /// No description provided for @questsSummaryXpToday.
  ///
  /// In pt, this message translates to:
  /// **'XP hoje'**
  String get questsSummaryXpToday;

  /// No description provided for @questsSummaryStreak.
  ///
  /// In pt, this message translates to:
  /// **'Streak'**
  String get questsSummaryStreak;

  /// No description provided for @questsStreakDays.
  ///
  /// In pt, this message translates to:
  /// **'{days}d'**
  String questsStreakDays(int days);

  /// No description provided for @questsProgressCount.
  ///
  /// In pt, this message translates to:
  /// **'{current} / {total}'**
  String questsProgressCount(int current, int total);

  /// No description provided for @questsRewardXp.
  ///
  /// In pt, this message translates to:
  /// **'+{xp} XP'**
  String questsRewardXp(int xp);

  /// No description provided for @questsRewardCoins.
  ///
  /// In pt, this message translates to:
  /// **'+{coins} moedas'**
  String questsRewardCoins(int coins);

  /// No description provided for @questsStatusClaimed.
  ///
  /// In pt, this message translates to:
  /// **'Coletado ✓'**
  String get questsStatusClaimed;

  /// No description provided for @questsStatusInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em progresso'**
  String get questsStatusInProgress;

  /// No description provided for @questsActionClaim.
  ///
  /// In pt, this message translates to:
  /// **'Coletar'**
  String get questsActionClaim;

  /// No description provided for @questsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui carregar as quests.'**
  String get questsLoadError;

  /// No description provided for @questsTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get questsTryAgain;

  /// No description provided for @questsSummaryCompletedValue.
  ///
  /// In pt, this message translates to:
  /// **'{done}/{total}'**
  String questsSummaryCompletedValue(int done, int total);

  /// No description provided for @walletTitle.
  ///
  /// In pt, this message translates to:
  /// **'Moedas Brawe'**
  String get walletTitle;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo de moedas'**
  String get walletAvailableBalance;

  /// No description provided for @walletCoins.
  ///
  /// In pt, this message translates to:
  /// **'moedas'**
  String get walletCoins;

  /// No description provided for @walletSectionBuyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comprar moedas'**
  String get walletSectionBuyTitle;

  /// No description provided for @walletSectionBuySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Use moedas para enviar presentes virtuais aos criadores nas lives'**
  String get walletSectionBuySubtitle;

  /// No description provided for @walletSectionHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de presentes'**
  String get walletSectionHistoryTitle;

  /// No description provided for @walletSectionHistorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Presentes enviados e recebidos em lives'**
  String get walletSectionHistorySubtitle;

  /// No description provided for @giftersTabReceived.
  ///
  /// In pt, this message translates to:
  /// **'Recebidos'**
  String get giftersTabReceived;

  /// No description provided for @giftersTabSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviados'**
  String get giftersTabSent;

  /// No description provided for @giftersEmptyReceivedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ainda ninguém te presenteou'**
  String get giftersEmptyReceivedTitle;

  /// No description provided for @giftersEmptyReceivedBody.
  ///
  /// In pt, this message translates to:
  /// **'Quando alguém te enviar gifts nas lives, eles vão aparecer agrupados por pessoa aqui.'**
  String get giftersEmptyReceivedBody;

  /// No description provided for @giftersEmptySentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não enviou gifts'**
  String get giftersEmptySentTitle;

  /// No description provided for @giftersEmptySentBody.
  ///
  /// In pt, this message translates to:
  /// **'Os criadores que você apoiar nas lives vão aparecer agrupados aqui.'**
  String get giftersEmptySentBody;

  /// No description provided for @giftersInLives.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 live} other{{n} lives}}'**
  String giftersInLives(int n);

  /// No description provided for @giftersGiftsCount.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 presente} other{{n} presentes}}'**
  String giftersGiftsCount(int n);

  /// No description provided for @giftersActionThank.
  ///
  /// In pt, this message translates to:
  /// **'Agradecer'**
  String get giftersActionThank;

  /// No description provided for @giftersActionMessage.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem'**
  String get giftersActionMessage;

  /// No description provided for @giftersActionFollow.
  ///
  /// In pt, this message translates to:
  /// **'Seguir'**
  String get giftersActionFollow;

  /// No description provided for @giftersActionFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get giftersActionFollowing;

  /// No description provided for @giftersDetailTotalReceived.
  ///
  /// In pt, this message translates to:
  /// **'Total recebido'**
  String get giftersDetailTotalReceived;

  /// No description provided for @giftersDetailTotalSent.
  ///
  /// In pt, this message translates to:
  /// **'Total enviado'**
  String get giftersDetailTotalSent;

  /// No description provided for @giftersDetailGiftsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Presentes'**
  String get giftersDetailGiftsTitle;

  /// No description provided for @giftersBadgeFollowsYou.
  ///
  /// In pt, this message translates to:
  /// **'Te segue'**
  String get giftersBadgeFollowsYou;

  /// No description provided for @giftersLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar'**
  String get giftersLoadError;

  /// No description provided for @giftersFollowError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao seguir. Tente novamente.'**
  String get giftersFollowError;

  /// No description provided for @walletPackageCoins.
  ///
  /// In pt, this message translates to:
  /// **'{n} moedas'**
  String walletPackageCoins(String n);

  /// No description provided for @walletPriceBRL.
  ///
  /// In pt, this message translates to:
  /// **'R\$ {value}'**
  String walletPriceBRL(String value);

  /// No description provided for @walletPurchaseInfo.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos in-app chegando em breve. Por enquanto, compre moedas pelo navegador em brawe.app/coins.'**
  String get walletPurchaseInfo;

  /// No description provided for @walletPurchaseUnderstood.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get walletPurchaseUnderstood;

  /// No description provided for @walletInfoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como funcionam as moedas'**
  String get walletInfoTitle;

  /// No description provided for @walletInfoQuestsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Missões diárias'**
  String get walletInfoQuestsTitle;

  /// No description provided for @walletInfoQuestsBody.
  ///
  /// In pt, this message translates to:
  /// **'Complete missões e ganhe moedas + XP todos os dias.'**
  String get walletInfoQuestsBody;

  /// No description provided for @walletInfoGiftsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Receba presentes'**
  String get walletInfoGiftsTitle;

  /// No description provided for @walletInfoGiftsBody.
  ///
  /// In pt, this message translates to:
  /// **'Seus seguidores podem enviar presentes virtuais durante suas lives.'**
  String get walletInfoGiftsBody;

  /// No description provided for @walletInfoUseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Envie presentes'**
  String get walletInfoUseTitle;

  /// No description provided for @walletInfoUseBody.
  ///
  /// In pt, this message translates to:
  /// **'Use moedas para enviar presentes virtuais aos criadores favoritos.'**
  String get walletInfoUseBody;

  /// No description provided for @walletLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui carregar suas moedas.'**
  String get walletLoadError;

  /// No description provided for @walletTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get walletTryAgain;

  /// No description provided for @walletActionAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get walletActionAdd;

  /// No description provided for @walletActionSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar presente'**
  String get walletActionSend;

  /// No description provided for @walletActionStatement.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get walletActionStatement;

  /// No description provided for @walletComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve.'**
  String get walletComingSoon;

  /// No description provided for @walletTxLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o histórico.'**
  String get walletTxLoadError;

  /// No description provided for @walletTxEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem presentes ainda.'**
  String get walletTxEmpty;

  /// No description provided for @walletTxTo.
  ///
  /// In pt, this message translates to:
  /// **'Para'**
  String get walletTxTo;

  /// No description provided for @walletTxFrom.
  ///
  /// In pt, this message translates to:
  /// **'De'**
  String get walletTxFrom;

  /// No description provided for @walletIapInfo.
  ///
  /// In pt, this message translates to:
  /// **'Compra processada pela loja oficial (Google Play / App Store). As moedas são creditadas automaticamente após o pagamento. Moedas são itens virtuais não-resgatáveis usados apenas para enviar presentes em lives.'**
  String get walletIapInfo;

  /// No description provided for @walletIapBuyFor.
  ///
  /// In pt, this message translates to:
  /// **'Comprar por {price}'**
  String walletIapBuyFor(String price);

  /// No description provided for @walletIapProcessing.
  ///
  /// In pt, this message translates to:
  /// **'Processando…'**
  String get walletIapProcessing;

  /// No description provided for @walletIapUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get walletIapUnavailable;

  /// No description provided for @walletIapPackageUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Pacote indisponível na loja. Tente novamente em breve.'**
  String get walletIapPackageUnavailable;

  /// No description provided for @walletIapNotSupported.
  ///
  /// In pt, this message translates to:
  /// **'Plataforma não suporta compras no app.'**
  String get walletIapNotSupported;

  /// No description provided for @walletIapStoreUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Compras no app indisponíveis neste dispositivo. Verifique se sua conta Google/Apple está configurada.'**
  String get walletIapStoreUnavailable;

  /// No description provided for @walletIapPaymentPending.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento em processamento. Você receberá as moedas assim que for confirmado pela loja.'**
  String get walletIapPaymentPending;

  /// No description provided for @walletIapPaymentError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao processar a compra. Tente novamente.'**
  String get walletIapPaymentError;

  /// No description provided for @walletIapSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Moedas creditadas com sucesso! (+{coins})'**
  String walletIapSuccess(String coins);

  /// No description provided for @earningsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recompensas de Criador'**
  String get earningsTitle;

  /// No description provided for @earningsCurrency.
  ///
  /// In pt, this message translates to:
  /// **'Moeda de exibição'**
  String get earningsCurrency;

  /// No description provided for @earningsCoinsBalance.
  ///
  /// In pt, this message translates to:
  /// **'Moedas disponíveis'**
  String get earningsCoinsBalance;

  /// No description provided for @earningsDiamondsBalance.
  ///
  /// In pt, this message translates to:
  /// **'Diamantes do Programa de Criador'**
  String get earningsDiamondsBalance;

  /// No description provided for @earningsDiamonds.
  ///
  /// In pt, this message translates to:
  /// **'diamantes'**
  String get earningsDiamonds;

  /// No description provided for @earningsTotalSpent.
  ///
  /// In pt, this message translates to:
  /// **'Moedas gastas em presentes'**
  String get earningsTotalSpent;

  /// No description provided for @earningsTotalEarned.
  ///
  /// In pt, this message translates to:
  /// **'Diamantes recebidos de presentes'**
  String get earningsTotalEarned;

  /// No description provided for @earningsAccountNumber.
  ///
  /// In pt, this message translates to:
  /// **'Brawe ID'**
  String get earningsAccountNumber;

  /// No description provided for @earningsPurchaseHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de compras'**
  String get earningsPurchaseHistoryTitle;

  /// No description provided for @earningsPurchaseHistorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Compras de moedas via App Store / Google Play'**
  String get earningsPurchaseHistorySubtitle;

  /// No description provided for @earningsGiftHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Presentes recebidos'**
  String get earningsGiftHistoryTitle;

  /// No description provided for @earningsGiftHistorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Origem dos seus diamantes do Programa de Criador'**
  String get earningsGiftHistorySubtitle;

  /// No description provided for @earningsNoPurchases.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não comprou moedas.'**
  String get earningsNoPurchases;

  /// No description provided for @earningsNoGifts.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não recebeu presentes.'**
  String get earningsNoGifts;

  /// No description provided for @earningsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar suas recompensas.'**
  String get earningsLoadError;

  /// No description provided for @earningsStatusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get earningsStatusCompleted;

  /// No description provided for @earningsStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get earningsStatusPending;

  /// No description provided for @earningsStatusFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falhou'**
  String get earningsStatusFailed;

  /// No description provided for @earningsStatusRefunded.
  ///
  /// In pt, this message translates to:
  /// **'Estornado'**
  String get earningsStatusRefunded;

  /// No description provided for @earningsDisclaimerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre Moedas e Diamantes'**
  String get earningsDisclaimerTitle;

  /// No description provided for @earningsDisclaimerBody.
  ///
  /// In pt, this message translates to:
  /// **'Moedas Brawe e Diamantes são itens virtuais não-resgatáveis usados exclusivamente para enviar presentes em lives. Não constituem investimento, valor mobiliário ou moeda eletrônica. Valores em USD/BRL/EUR são meramente informativos e não representam direito a saque ou conversão em dinheiro.'**
  String get earningsDisclaimerBody;

  /// No description provided for @earningsReferenceValueOnly.
  ///
  /// In pt, this message translates to:
  /// **'Valor de referência'**
  String get earningsReferenceValueOnly;

  /// No description provided for @postDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Publicação'**
  String get postDetailTitle;

  /// No description provided for @postDetailNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar esta publicação. Talvez ela tenha sido removida.'**
  String get postDetailNotFound;

  /// No description provided for @postDetailGoHome.
  ///
  /// In pt, this message translates to:
  /// **'Ir para Início'**
  String get postDetailGoHome;

  /// No description provided for @postLikersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Curtidas'**
  String get postLikersTitle;

  /// No description provided for @postLikersEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ainda ninguém curtiu esta publicação.'**
  String get postLikersEmpty;

  /// No description provided for @postLikersLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as curtidas.'**
  String get postLikersLoadError;

  /// No description provided for @postLikersTotal.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma curtida} =1{1 curtida} other{{count} curtidas}}'**
  String postLikersTotal(int count);

  /// No description provided for @reactionLike.
  ///
  /// In pt, this message translates to:
  /// **'Curtir'**
  String get reactionLike;

  /// No description provided for @reactionLove.
  ///
  /// In pt, this message translates to:
  /// **'Amei'**
  String get reactionLove;

  /// No description provided for @reactionFire.
  ///
  /// In pt, this message translates to:
  /// **'Top'**
  String get reactionFire;

  /// No description provided for @reactionLaugh.
  ///
  /// In pt, this message translates to:
  /// **'Haha'**
  String get reactionLaugh;

  /// No description provided for @reactionWow.
  ///
  /// In pt, this message translates to:
  /// **'Uau'**
  String get reactionWow;

  /// No description provided for @reactionSad.
  ///
  /// In pt, this message translates to:
  /// **'Triste'**
  String get reactionSad;

  /// No description provided for @exploreSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar streamers, lives, categorias…'**
  String get exploreSearchHint;

  /// No description provided for @exploreTabTrending.
  ///
  /// In pt, this message translates to:
  /// **'Em alta'**
  String get exploreTabTrending;

  /// No description provided for @exploreTabCategories.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get exploreTabCategories;

  /// No description provided for @exploreTabRecommended.
  ///
  /// In pt, this message translates to:
  /// **'Para você'**
  String get exploreTabRecommended;

  /// No description provided for @exploreSectionLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives ao vivo'**
  String get exploreSectionLives;

  /// No description provided for @exploreSectionTrendingStreamers.
  ///
  /// In pt, this message translates to:
  /// **'Streamers em alta'**
  String get exploreSectionTrendingStreamers;

  /// No description provided for @exploreSectionRecommendedLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives recomendadas'**
  String get exploreSectionRecommendedLives;

  /// No description provided for @exploreSectionRecommendedStreamers.
  ///
  /// In pt, this message translates to:
  /// **'Streamers que você pode gostar'**
  String get exploreSectionRecommendedStreamers;

  /// No description provided for @exploreEmptyTrending.
  ///
  /// In pt, this message translates to:
  /// **'Nada em alta agora'**
  String get exploreEmptyTrending;

  /// No description provided for @exploreEmptyCategories.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria disponível.'**
  String get exploreEmptyCategories;

  /// No description provided for @exploreEmptyRecommended.
  ///
  /// In pt, this message translates to:
  /// **'Siga alguns streamers para receber recomendações personalizadas!'**
  String get exploreEmptyRecommended;

  /// No description provided for @exploreEmptySearch.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado.'**
  String get exploreEmptySearch;

  /// No description provided for @exploreCategoryGeneral.
  ///
  /// In pt, this message translates to:
  /// **'Geral'**
  String get exploreCategoryGeneral;

  /// No description provided for @exploreFollowersCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} seguidores'**
  String exploreFollowersCount(int count);

  /// No description provided for @exploreCategoryLiveCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} ao vivo'**
  String exploreCategoryLiveCount(int count);

  /// No description provided for @exploreLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar. Puxe para baixo para tentar novamente.'**
  String get exploreLoadError;

  /// No description provided for @exploreLiveSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{streamer} • {category}'**
  String exploreLiveSubtitle(String streamer, String category);

  /// No description provided for @editProfileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil'**
  String get editProfileTitle;

  /// No description provided for @editProfileSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get editProfileSave;

  /// No description provided for @editProfileLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar perfil'**
  String get editProfileLoadError;

  /// No description provided for @editProfileSaved.
  ///
  /// In pt, this message translates to:
  /// **'Perfil atualizado'**
  String get editProfileSaved;

  /// No description provided for @editProfileSavedUsernameFailed.
  ///
  /// In pt, this message translates to:
  /// **'Perfil salvo, mas falhou ao atualizar o username'**
  String get editProfileSavedUsernameFailed;

  /// No description provided for @editProfileSectionInfo.
  ///
  /// In pt, this message translates to:
  /// **'Informações'**
  String get editProfileSectionInfo;

  /// No description provided for @editProfileSectionSocial.
  ///
  /// In pt, this message translates to:
  /// **'Links sociais'**
  String get editProfileSectionSocial;

  /// No description provided for @editProfileFieldName.
  ///
  /// In pt, this message translates to:
  /// **'Nome de exibição'**
  String get editProfileFieldName;

  /// No description provided for @editProfileFieldNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Obrigatório'**
  String get editProfileFieldNameRequired;

  /// No description provided for @editProfileFieldBio.
  ///
  /// In pt, this message translates to:
  /// **'Bio'**
  String get editProfileFieldBio;

  /// No description provided for @editProfileFieldBioHint.
  ///
  /// In pt, this message translates to:
  /// **'Conte um pouco sobre você...'**
  String get editProfileFieldBioHint;

  /// No description provided for @editProfileSocialInstagram.
  ///
  /// In pt, this message translates to:
  /// **'Instagram'**
  String get editProfileSocialInstagram;

  /// No description provided for @editProfileSocialTikTok.
  ///
  /// In pt, this message translates to:
  /// **'TikTok'**
  String get editProfileSocialTikTok;

  /// No description provided for @editProfileSocialTwitter.
  ///
  /// In pt, this message translates to:
  /// **'X / Twitter'**
  String get editProfileSocialTwitter;

  /// No description provided for @editProfileSocialYouTube.
  ///
  /// In pt, this message translates to:
  /// **'YouTube'**
  String get editProfileSocialYouTube;

  /// No description provided for @editProfileSocialWebsite.
  ///
  /// In pt, this message translates to:
  /// **'Website'**
  String get editProfileSocialWebsite;

  /// No description provided for @editProfileSocialUserHint.
  ///
  /// In pt, this message translates to:
  /// **'@usuario'**
  String get editProfileSocialUserHint;

  /// No description provided for @editProfileSocialChannelHint.
  ///
  /// In pt, this message translates to:
  /// **'canal'**
  String get editProfileSocialChannelHint;

  /// No description provided for @editProfileSocialUrlHint.
  ///
  /// In pt, this message translates to:
  /// **'https://...'**
  String get editProfileSocialUrlHint;

  /// No description provided for @editProfileBannerAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar banner'**
  String get editProfileBannerAdd;

  /// No description provided for @editProfileBannerPosition.
  ///
  /// In pt, this message translates to:
  /// **'Posicionar banner'**
  String get editProfileBannerPosition;

  /// No description provided for @editProfileAvatarPosition.
  ///
  /// In pt, this message translates to:
  /// **'Posicionar foto'**
  String get editProfileAvatarPosition;

  /// No description provided for @editProfileUsernameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Username'**
  String get editProfileUsernameLabel;

  /// No description provided for @editProfileUsernameHint.
  ///
  /// In pt, this message translates to:
  /// **'@seunome'**
  String get editProfileUsernameHint;

  /// No description provided for @editProfileUsernameAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get editProfileUsernameAvailable;

  /// No description provided for @editProfileUsernameTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 3 caracteres'**
  String get editProfileUsernameTooShort;

  /// No description provided for @editProfileUsernameInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Apenas letras, números e _ (deve começar com letra)'**
  String get editProfileUsernameInvalid;

  /// No description provided for @editProfileImageProcessError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível processar a imagem.'**
  String get editProfileImageProcessError;

  /// No description provided for @editProfileImageDone.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get editProfileImageDone;

  /// No description provided for @editProfileImageHint.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para reposicionar · Pinch para dar zoom'**
  String get editProfileImageHint;

  /// No description provided for @editProfileErrorSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Tente de novo.'**
  String get editProfileErrorSaveFailed;

  /// No description provided for @editProfileErrorUsernameCheck.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao verificar'**
  String get editProfileErrorUsernameCheck;

  /// No description provided for @editProfileErrorUsernameInUse.
  ///
  /// In pt, this message translates to:
  /// **'Este username já está em uso'**
  String get editProfileErrorUsernameInUse;

  /// No description provided for @editProfileErrorUsernameSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o username. Tente de novo.'**
  String get editProfileErrorUsernameSaveFailed;

  /// No description provided for @editProfileErrorAvatarUpload.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao enviar avatar.'**
  String get editProfileErrorAvatarUpload;

  /// No description provided for @editProfileErrorBannerUpload.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao enviar banner.'**
  String get editProfileErrorBannerUpload;

  /// No description provided for @editProfileErrorAvatarRemove.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao remover avatar.'**
  String get editProfileErrorAvatarRemove;

  /// No description provided for @editProfileErrorBannerRemove.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao remover banner.'**
  String get editProfileErrorBannerRemove;

  /// No description provided for @startLivePermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Precisamos de acesso à câmera e ao microfone para iniciar.'**
  String get startLivePermissionDenied;

  /// No description provided for @startLiveNoCamera.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma câmera encontrada neste dispositivo.'**
  String get startLiveNoCamera;

  /// No description provided for @startLiveCameraInitError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao inicializar a câmera: {error}'**
  String startLiveCameraInitError(String error);

  /// No description provided for @startLiveCameraInitFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao inicializar a câmera.'**
  String get startLiveCameraInitFailed;

  /// No description provided for @startLiveThumbCaptured.
  ///
  /// In pt, this message translates to:
  /// **'Capa capturada da câmera ✨'**
  String get startLiveThumbCaptured;

  /// No description provided for @startLiveThumbCaptureFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível capturar a capa.'**
  String get startLiveThumbCaptureFailed;

  /// No description provided for @startLiveThumbUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Capa atualizada.'**
  String get startLiveThumbUpdated;

  /// No description provided for @startLiveThumbCaptureNow.
  ///
  /// In pt, this message translates to:
  /// **'Capturar agora'**
  String get startLiveThumbCaptureNow;

  /// No description provided for @startLiveThumbCaptureNowSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Usa o frame atual da câmera'**
  String get startLiveThumbCaptureNowSubtitle;

  /// No description provided for @startLiveThumbPickGallery.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get startLiveThumbPickGallery;

  /// No description provided for @startLiveThumbRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover capa'**
  String get startLiveThumbRemove;

  /// No description provided for @startLiveRoomDataError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter os dados da live.'**
  String get startLiveRoomDataError;

  /// No description provided for @startLiveRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get startLiveRetry;

  /// No description provided for @startLiveTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'Diga sobre o que é sua live...'**
  String get startLiveTitleHint;

  /// No description provided for @startLiveCategoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get startLiveCategoryLabel;

  /// No description provided for @startLiveNotifyFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Avisar meus seguidores'**
  String get startLiveNotifyFollowers;

  /// No description provided for @startLiveGoLive.
  ///
  /// In pt, this message translates to:
  /// **'ENTRAR AO VIVO'**
  String get startLiveGoLive;

  /// No description provided for @startLiveSuggestions.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões'**
  String get startLiveSuggestions;

  /// No description provided for @startLiveErrorTitleTooShort.
  ///
  /// In pt, this message translates to:
  /// **'O título precisa ter pelo menos 3 caracteres.'**
  String get startLiveErrorTitleTooShort;

  /// No description provided for @startLiveErrorCategoryRequired.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma categoria para sua live.'**
  String get startLiveErrorCategoryRequired;

  /// No description provided for @liveCategoryShopping.
  ///
  /// In pt, this message translates to:
  /// **'Shopping'**
  String get liveCategoryShopping;

  /// No description provided for @liveCategoryGaming.
  ///
  /// In pt, this message translates to:
  /// **'Gaming'**
  String get liveCategoryGaming;

  /// No description provided for @liveCategoryTalkShow.
  ///
  /// In pt, this message translates to:
  /// **'Talk Show'**
  String get liveCategoryTalkShow;

  /// No description provided for @liveCategoryMusic.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get liveCategoryMusic;

  /// No description provided for @liveCategoryEducation.
  ///
  /// In pt, this message translates to:
  /// **'Educação'**
  String get liveCategoryEducation;

  /// No description provided for @liveCategoryFitness.
  ///
  /// In pt, this message translates to:
  /// **'Fitness'**
  String get liveCategoryFitness;

  /// No description provided for @liveCategoryCooking.
  ///
  /// In pt, this message translates to:
  /// **'Culinária'**
  String get liveCategoryCooking;

  /// No description provided for @liveCategoryBeauty.
  ///
  /// In pt, this message translates to:
  /// **'Beleza'**
  String get liveCategoryBeauty;

  /// No description provided for @liveCategoryTech.
  ///
  /// In pt, this message translates to:
  /// **'Tecnologia'**
  String get liveCategoryTech;

  /// No description provided for @liveCategorySports.
  ///
  /// In pt, this message translates to:
  /// **'Esportes'**
  String get liveCategorySports;

  /// No description provided for @liveCategoryEntertainment.
  ///
  /// In pt, this message translates to:
  /// **'Entretenimento'**
  String get liveCategoryEntertainment;

  /// No description provided for @liveCategoryOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get liveCategoryOther;

  /// No description provided for @liveVisibilityPublic.
  ///
  /// In pt, this message translates to:
  /// **'Público'**
  String get liveVisibilityPublic;

  /// No description provided for @liveVisibilityFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get liveVisibilityFollowers;

  /// No description provided for @liveVisibilityPrivate.
  ///
  /// In pt, this message translates to:
  /// **'Privada'**
  String get liveVisibilityPrivate;

  /// No description provided for @liveVisibilityPublicDesc.
  ///
  /// In pt, this message translates to:
  /// **'Qualquer pessoa pode entrar e descobrir'**
  String get liveVisibilityPublicDesc;

  /// No description provided for @liveVisibilityFollowersDesc.
  ///
  /// In pt, this message translates to:
  /// **'Apenas quem te segue pode entrar'**
  String get liveVisibilityFollowersDesc;

  /// No description provided for @liveVisibilityPrivateDesc.
  ///
  /// In pt, this message translates to:
  /// **'Apenas pessoas com link convidadas'**
  String get liveVisibilityPrivateDesc;

  /// No description provided for @warmupHeading.
  ///
  /// In pt, this message translates to:
  /// **'Aquecendo o público'**
  String get warmupHeading;

  /// No description provided for @warmupSubheading.
  ///
  /// In pt, this message translates to:
  /// **'Avisando seus seguidores...'**
  String get warmupSubheading;

  /// No description provided for @warmupOpensInSeconds.
  ///
  /// In pt, this message translates to:
  /// **'A live abre em {count} segundo{plural}'**
  String warmupOpensInSeconds(int count, String plural);

  /// No description provided for @warmupGoNow.
  ///
  /// In pt, this message translates to:
  /// **'Entrar ao vivo agora'**
  String get warmupGoNow;

  /// No description provided for @warmupCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar aquecimento'**
  String get warmupCancel;

  /// No description provided for @vibeNetworkWifi.
  ///
  /// In pt, this message translates to:
  /// **'Wi-Fi'**
  String get vibeNetworkWifi;

  /// No description provided for @vibeNetworkMobile.
  ///
  /// In pt, this message translates to:
  /// **'4G/5G'**
  String get vibeNetworkMobile;

  /// No description provided for @vibeNetworkEthernet.
  ///
  /// In pt, this message translates to:
  /// **'Ethernet'**
  String get vibeNetworkEthernet;

  /// No description provided for @vibeNetworkNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem rede'**
  String get vibeNetworkNone;

  /// No description provided for @vibeStatusGood.
  ///
  /// In pt, this message translates to:
  /// **'Tudo certo para entrar ao vivo'**
  String get vibeStatusGood;

  /// No description provided for @vibeStatusWarning.
  ///
  /// In pt, this message translates to:
  /// **'Funciona, mas pode oscilar'**
  String get vibeStatusWarning;

  /// No description provided for @vibeStatusBad.
  ///
  /// In pt, this message translates to:
  /// **'Atenção antes de começar'**
  String get vibeStatusBad;

  /// No description provided for @vibeNetworkLabel.
  ///
  /// In pt, this message translates to:
  /// **'Rede: {label}'**
  String vibeNetworkLabel(String label);

  /// No description provided for @vibeBatteryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Bateria: {level}%'**
  String vibeBatteryLabel(int level);

  /// No description provided for @shareLiveLoginNeeded.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para compartilhar'**
  String get shareLiveLoginNeeded;

  /// No description provided for @shareLiveLoadFollowersError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seus seguidores.'**
  String get shareLiveLoadFollowersError;

  /// No description provided for @shareLiveSentToCount.
  ///
  /// In pt, this message translates to:
  /// **'Live enviada para {count, plural, =1{{count} pessoa} other{{count} pessoas}} 🎉'**
  String shareLiveSentToCount(int count);

  /// No description provided for @shareLiveSendFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao compartilhar a live'**
  String get shareLiveSendFailed;

  /// No description provided for @shareLiveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar live'**
  String get shareLiveTitle;

  /// No description provided for @shareLiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'LIVE'**
  String get shareLiveBadge;

  /// No description provided for @shareLiveSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar seguidores'**
  String get shareLiveSearchHint;

  /// No description provided for @shareLiveErrorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get shareLiveErrorGeneric;

  /// No description provided for @shareLiveRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get shareLiveRetry;

  /// No description provided for @shareLiveEmptyFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum seguidor encontrado.'**
  String get shareLiveEmptyFollowers;

  /// No description provided for @shareLiveDefaultUser.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get shareLiveDefaultUser;

  /// No description provided for @shareLiveNoteHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma mensagem (opcional)…'**
  String get shareLiveNoteHint;

  /// No description provided for @shareLiveSendTo.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para {count}'**
  String shareLiveSendTo(int count);

  /// No description provided for @shareLiveSelectContacts.
  ///
  /// In pt, this message translates to:
  /// **'Selecione contatos'**
  String get shareLiveSelectContacts;

  /// No description provided for @broadcasterPermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Precisamos de acesso à câmera e ao microfone para você entrar ao vivo.'**
  String get broadcasterPermissionDenied;

  /// No description provided for @broadcasterNoCamera.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma câmera encontrada neste dispositivo.'**
  String get broadcasterNoCamera;

  /// No description provided for @broadcasterInitCameraFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao inicializar a câmera.'**
  String get broadcasterInitCameraFailed;

  /// No description provided for @broadcasterInitCameraError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao inicializar a câmera: {error}'**
  String broadcasterInitCameraError(String error);

  /// No description provided for @broadcasterRoomUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar a live: {error}'**
  String broadcasterRoomUpdateFailed(String error);

  /// No description provided for @broadcasterMissingStreamCreds.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível iniciar: URL RTMP ou chave de transmissão ausente.'**
  String get broadcasterMissingStreamCreds;

  /// No description provided for @broadcasterConnectedLive.
  ///
  /// In pt, this message translates to:
  /// **'Conectado! Você está ao vivo. 🔴'**
  String get broadcasterConnectedLive;

  /// No description provided for @broadcasterStreamStartError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao iniciar transmissão: {error}'**
  String broadcasterStreamStartError(String error);

  /// No description provided for @broadcasterLiveResumed.
  ///
  /// In pt, this message translates to:
  /// **'Live retomada — você está ao vivo.'**
  String get broadcasterLiveResumed;

  /// No description provided for @broadcasterLivePaused.
  ///
  /// In pt, this message translates to:
  /// **'Live pausada (BRB).'**
  String get broadcasterLivePaused;

  /// No description provided for @broadcasterPauseToggleError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao pausar/retomar: {error}'**
  String broadcasterPauseToggleError(String error);

  /// No description provided for @broadcasterDiscardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar live?'**
  String get broadcasterDiscardTitle;

  /// No description provided for @broadcasterDiscardMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você criou uma live mas ainda não começou a transmitir. Deseja descartá-la?'**
  String get broadcasterDiscardMessage;

  /// No description provided for @broadcasterCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get broadcasterCancel;

  /// No description provided for @broadcasterDiscard.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get broadcasterDiscard;

  /// No description provided for @broadcasterEndTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar live?'**
  String get broadcasterEndTitle;

  /// No description provided for @broadcasterEndMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja finalizar a transmissão? Seus viewers serão desconectados.'**
  String get broadcasterEndMessage;

  /// No description provided for @broadcasterContinueLive.
  ///
  /// In pt, this message translates to:
  /// **'Continuar ao vivo'**
  String get broadcasterContinueLive;

  /// No description provided for @broadcasterEnd.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar'**
  String get broadcasterEnd;

  /// No description provided for @liveSummaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo da live'**
  String get liveSummaryTitle;

  /// No description provided for @liveSummaryDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get liveSummaryDuration;

  /// No description provided for @liveSummaryPeakViewers.
  ///
  /// In pt, this message translates to:
  /// **'Pico de audiência'**
  String get liveSummaryPeakViewers;

  /// No description provided for @liveSummaryTotalViewers.
  ///
  /// In pt, this message translates to:
  /// **'Espectadores únicos'**
  String get liveSummaryTotalViewers;

  /// No description provided for @liveSummaryGiftsValue.
  ///
  /// In pt, this message translates to:
  /// **'Presentes recebidos'**
  String get liveSummaryGiftsValue;

  /// No description provided for @liveSummaryMysteryGifts.
  ///
  /// In pt, this message translates to:
  /// **'Presentes misteriosos revelados'**
  String get liveSummaryMysteryGifts;

  /// No description provided for @liveSummaryDone.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get liveSummaryDone;

  /// No description provided for @liveSummaryUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Sua live foi encerrada. Não foi possível carregar o resumo completo agora.'**
  String get liveSummaryUnavailable;

  /// No description provided for @broadcasterMoreResumeLive.
  ///
  /// In pt, this message translates to:
  /// **'Retomar live'**
  String get broadcasterMoreResumeLive;

  /// No description provided for @broadcasterMorePauseBrb.
  ///
  /// In pt, this message translates to:
  /// **'Pausar (BRB)'**
  String get broadcasterMorePauseBrb;

  /// No description provided for @broadcasterMoreResumeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Volta ao ar e continua a transmissão'**
  String get broadcasterMoreResumeSubtitle;

  /// No description provided for @broadcasterMorePauseSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pausa a transmissão sem encerrar'**
  String get broadcasterMorePauseSubtitle;

  /// No description provided for @broadcasterMoreSwitchCamera.
  ///
  /// In pt, this message translates to:
  /// **'Trocar câmera'**
  String get broadcasterMoreSwitchCamera;

  /// No description provided for @broadcasterMoreSwitchCameraSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterna entre frontal e traseira'**
  String get broadcasterMoreSwitchCameraSubtitle;

  /// No description provided for @broadcasterMoreShareLive.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar live'**
  String get broadcasterMoreShareLive;

  /// No description provided for @broadcasterMoreShareLiveSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar preview da live aos seus seguidores'**
  String get broadcasterMoreShareLiveSubtitle;

  /// No description provided for @broadcasterMoreEndLive.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar live'**
  String get broadcasterMoreEndLive;

  /// No description provided for @broadcasterMoreEndLiveSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Finaliza a transmissão para todos'**
  String get broadcasterMoreEndLiveSubtitle;

  /// No description provided for @broadcasterBadgePaused.
  ///
  /// In pt, this message translates to:
  /// **'PAUSED'**
  String get broadcasterBadgePaused;

  /// No description provided for @broadcasterBadgeLive.
  ///
  /// In pt, this message translates to:
  /// **'LIVE'**
  String get broadcasterBadgeLive;

  /// No description provided for @broadcasterTooltipResume.
  ///
  /// In pt, this message translates to:
  /// **'Retomar'**
  String get broadcasterTooltipResume;

  /// No description provided for @broadcasterTooltipPause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get broadcasterTooltipPause;

  /// No description provided for @broadcasterTooltipMore.
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get broadcasterTooltipMore;

  /// No description provided for @broadcasterTooltipEnd.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar'**
  String get broadcasterTooltipEnd;

  /// No description provided for @broadcasterViewerJoined.
  ///
  /// In pt, this message translates to:
  /// **'{name} entrou'**
  String broadcasterViewerJoined(String name);

  /// No description provided for @suggestTimeDawn.
  ///
  /// In pt, this message translates to:
  /// **'Madrugada'**
  String get suggestTimeDawn;

  /// No description provided for @suggestTimeMorning.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia'**
  String get suggestTimeMorning;

  /// No description provided for @suggestTimeAfternoon.
  ///
  /// In pt, this message translates to:
  /// **'Boa tarde'**
  String get suggestTimeAfternoon;

  /// No description provided for @suggestTimeEvening.
  ///
  /// In pt, this message translates to:
  /// **'Boa noite'**
  String get suggestTimeEvening;

  /// No description provided for @suggestModa1.
  ///
  /// In pt, this message translates to:
  /// **'{time} de moda — what to wear?'**
  String suggestModa1(String time);

  /// No description provided for @suggestModa2.
  ///
  /// In pt, this message translates to:
  /// **'Look do dia ao vivo'**
  String get suggestModa2;

  /// No description provided for @suggestModa3.
  ///
  /// In pt, this message translates to:
  /// **'Provador online — me ajuda a escolher'**
  String get suggestModa3;

  /// No description provided for @suggestBeleza1.
  ///
  /// In pt, this message translates to:
  /// **'{time} fazendo make ao vivo'**
  String suggestBeleza1(String time);

  /// No description provided for @suggestBeleza2.
  ///
  /// In pt, this message translates to:
  /// **'Skincare routine — bora juntos'**
  String get suggestBeleza2;

  /// No description provided for @suggestBeleza3.
  ///
  /// In pt, this message translates to:
  /// **'Resenha de produto novo'**
  String get suggestBeleza3;

  /// No description provided for @suggestJogos1.
  ///
  /// In pt, this message translates to:
  /// **'Bora jogar — quem entra?'**
  String get suggestJogos1;

  /// No description provided for @suggestJogos2.
  ///
  /// In pt, this message translates to:
  /// **'Rank up live • {time}'**
  String suggestJogos2(String time);

  /// No description provided for @suggestJogos3.
  ///
  /// In pt, this message translates to:
  /// **'Aquecimento antes do ranqueada'**
  String get suggestJogos3;

  /// No description provided for @suggestMusica1.
  ///
  /// In pt, this message translates to:
  /// **'{time} musical — pedidos abertos'**
  String suggestMusica1(String time);

  /// No description provided for @suggestMusica2.
  ///
  /// In pt, this message translates to:
  /// **'Tocando ao vivo — chega aí'**
  String get suggestMusica2;

  /// No description provided for @suggestMusica3.
  ///
  /// In pt, this message translates to:
  /// **'Playlist + papo'**
  String get suggestMusica3;

  /// No description provided for @suggestEsportes1.
  ///
  /// In pt, this message translates to:
  /// **'Comentando o jogo ao vivo'**
  String get suggestEsportes1;

  /// No description provided for @suggestEsportes2.
  ///
  /// In pt, this message translates to:
  /// **'{time} esportiva — vamos comentar'**
  String suggestEsportes2(String time);

  /// No description provided for @suggestEsportes3.
  ///
  /// In pt, this message translates to:
  /// **'Treino + papo'**
  String get suggestEsportes3;

  /// No description provided for @suggestComida1.
  ///
  /// In pt, this message translates to:
  /// **'{time} na cozinha — bora cozinhar'**
  String suggestComida1(String time);

  /// No description provided for @suggestComida2.
  ///
  /// In pt, this message translates to:
  /// **'Receita ao vivo'**
  String get suggestComida2;

  /// No description provided for @suggestComida3.
  ///
  /// In pt, this message translates to:
  /// **'Testando uma receita nova'**
  String get suggestComida3;

  /// No description provided for @suggestGeneric1.
  ///
  /// In pt, this message translates to:
  /// **'{time} com a galera'**
  String suggestGeneric1(String time);

  /// No description provided for @suggestGeneric2.
  ///
  /// In pt, this message translates to:
  /// **'Chega aí, vamos conversar'**
  String get suggestGeneric2;

  /// No description provided for @suggestGeneric3.
  ///
  /// In pt, this message translates to:
  /// **'Live aberta — pode chegar'**
  String get suggestGeneric3;

  /// No description provided for @liveCommentsHint.
  ///
  /// In pt, this message translates to:
  /// **'Diga algo...'**
  String get liveCommentsHint;

  /// No description provided for @liveCommentsSending.
  ///
  /// In pt, this message translates to:
  /// **'  Enviando...'**
  String get liveCommentsSending;

  /// No description provided for @giftsSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviou {name}!'**
  String giftsSent(String name);

  /// No description provided for @giftsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar um presente'**
  String get giftsTitle;

  /// No description provided for @giftsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum presente disponível'**
  String get giftsEmpty;

  /// No description provided for @giftsSendButton.
  ///
  /// In pt, this message translates to:
  /// **'ENVIAR'**
  String get giftsSendButton;

  /// No description provided for @giftsError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar presentes: {error}'**
  String giftsError(String error);

  /// No description provided for @giftsCreditsLabel.
  ///
  /// In pt, this message translates to:
  /// **'{count} Créditos'**
  String giftsCreditsLabel(int count);

  /// No description provided for @giftsPriceLabel.
  ///
  /// In pt, this message translates to:
  /// **'{price} pts'**
  String giftsPriceLabel(int price);

  /// No description provided for @liveFeedEmptyForYou.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma live no Para Você agora.'**
  String get liveFeedEmptyForYou;

  /// No description provided for @liveFeedEmptyAll.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma live ativa no momento.'**
  String get liveFeedEmptyAll;

  /// No description provided for @liveFeedEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Volte mais tarde ou puxe para atualizar.'**
  String get liveFeedEmptyHint;

  /// No description provided for @liveFeedRefresh.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get liveFeedRefresh;

  /// No description provided for @liveFeedRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get liveFeedRetry;

  /// No description provided for @liveFeedError.
  ///
  /// In pt, this message translates to:
  /// **'Erro: {error}'**
  String liveFeedError(String error);

  /// No description provided for @liveFeedCategoryForYou.
  ///
  /// In pt, this message translates to:
  /// **'Para Você'**
  String get liveFeedCategoryForYou;

  /// No description provided for @liveFeedCategoryAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas as Lives'**
  String get liveFeedCategoryAll;

  /// No description provided for @liveFeedShareMessage.
  ///
  /// In pt, this message translates to:
  /// **'Confira esta live no Brawe: {title}\n{url}'**
  String liveFeedShareMessage(String title, String url);

  /// No description provided for @liveFeedBadgeLive.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get liveFeedBadgeLive;

  /// No description provided for @liveFeedBadgeLiveWithCount.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO {count}'**
  String liveFeedBadgeLiveWithCount(int count);

  /// No description provided for @liveFeedGift.
  ///
  /// In pt, this message translates to:
  /// **'Presente'**
  String get liveFeedGift;

  /// No description provided for @liveFeedShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get liveFeedShare;

  /// No description provided for @livePlayerInputHint.
  ///
  /// In pt, this message translates to:
  /// **'Diga algo legal...'**
  String get livePlayerInputHint;

  /// No description provided for @livePlayerTooltipRose.
  ///
  /// In pt, this message translates to:
  /// **'Enviar rosa'**
  String get livePlayerTooltipRose;

  /// No description provided for @livePlayerTooltipGifts.
  ///
  /// In pt, this message translates to:
  /// **'Presentes'**
  String get livePlayerTooltipGifts;

  /// No description provided for @livePlayerTooltipLike.
  ///
  /// In pt, this message translates to:
  /// **'Curtir'**
  String get livePlayerTooltipLike;

  /// No description provided for @livePlayerTooltipSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get livePlayerTooltipSend;

  /// No description provided for @livePlayerGiftSentVerb.
  ///
  /// In pt, this message translates to:
  /// **' enviou '**
  String get livePlayerGiftSentVerb;

  /// No description provided for @livePlayerShareTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar com seguidores'**
  String get livePlayerShareTitle;

  /// No description provided for @livePlayerShareSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Envia esta live numa conversa'**
  String get livePlayerShareSubtitle;

  /// No description provided for @livePlayerReportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar live'**
  String get livePlayerReportTitle;

  /// No description provided for @livePlayerReportSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Avisar nossa equipe sobre algo errado'**
  String get livePlayerReportSubtitle;

  /// No description provided for @livePlayerReportSubmitted.
  ///
  /// In pt, this message translates to:
  /// **'Denúncia registrada. Obrigado.'**
  String get livePlayerReportSubmitted;

  /// No description provided for @liveCurrentUser.
  ///
  /// In pt, this message translates to:
  /// **'Você'**
  String get liveCurrentUser;

  /// No description provided for @commonFollow.
  ///
  /// In pt, this message translates to:
  /// **'SEGUIR'**
  String get commonFollow;

  /// No description provided for @liveBadgeLive.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get liveBadgeLive;

  /// No description provided for @homeSectionLiveBattles.
  ///
  /// In pt, this message translates to:
  /// **'BATALHAS DE LIVE STREAM'**
  String get homeSectionLiveBattles;

  /// No description provided for @homeSectionTopStreamers.
  ///
  /// In pt, this message translates to:
  /// **'TOP STREAMERS'**
  String get homeSectionTopStreamers;

  /// No description provided for @homeSectionCategories.
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIAS'**
  String get homeSectionCategories;

  /// No description provided for @homeSectionStreamCard.
  ///
  /// In pt, this message translates to:
  /// **'CARTÃO DE STREAM'**
  String get homeSectionStreamCard;

  /// No description provided for @homeSectionLiveCommerce.
  ///
  /// In pt, this message translates to:
  /// **'LIVE COMMERCE SHOW'**
  String get homeSectionLiveCommerce;

  /// No description provided for @homeSectionRecentLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives recentes'**
  String get homeSectionRecentLives;

  /// No description provided for @homeErrorLoadingStats.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar estatísticas'**
  String get homeErrorLoadingStats;

  /// No description provided for @homeErrorLoadingLives.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar lives'**
  String get homeErrorLoadingLives;

  /// No description provided for @homeEmptyPastLives.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma live anterior encontrada'**
  String get homeEmptyPastLives;

  /// No description provided for @homeEmptyStreamers.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum streamer ainda'**
  String get homeEmptyStreamers;

  /// No description provided for @homeBattleWatchBet.
  ///
  /// In pt, this message translates to:
  /// **'ASSISTIR E APOSTAR'**
  String get homeBattleWatchBet;

  /// No description provided for @homeBattleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Batalha PK'**
  String get homeBattleLabel;

  /// No description provided for @commonError.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get commonError;

  /// No description provided for @videoTooltipRepostStory.
  ///
  /// In pt, this message translates to:
  /// **'Repostar nos Stories'**
  String get videoTooltipRepostStory;

  /// No description provided for @liveBattleTapToWatch.
  ///
  /// In pt, this message translates to:
  /// **'Toque para assistir ao vivo'**
  String get liveBattleTapToWatch;

  /// No description provided for @liveBattleMysteryGift.
  ///
  /// In pt, this message translates to:
  /// **'Presente Misterioso'**
  String get liveBattleMysteryGift;

  /// No description provided for @livePeekWatchLive.
  ///
  /// In pt, this message translates to:
  /// **'Assistir ao vivo'**
  String get livePeekWatchLive;

  /// No description provided for @productSoldOut.
  ///
  /// In pt, this message translates to:
  /// **'Esgotado'**
  String get productSoldOut;

  /// No description provided for @productBuy.
  ///
  /// In pt, this message translates to:
  /// **'Comprar'**
  String get productBuy;

  /// No description provided for @productLowStock.
  ///
  /// In pt, this message translates to:
  /// **'Apenas {count} restantes'**
  String productLowStock(int count);

  /// No description provided for @productSoldCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} vendidos'**
  String productSoldCount(int count);

  /// No description provided for @emojiCatSmileys.
  ///
  /// In pt, this message translates to:
  /// **'Smileys'**
  String get emojiCatSmileys;

  /// No description provided for @emojiCatGestures.
  ///
  /// In pt, this message translates to:
  /// **'Gestos'**
  String get emojiCatGestures;

  /// No description provided for @emojiCatHearts.
  ///
  /// In pt, this message translates to:
  /// **'Coração'**
  String get emojiCatHearts;

  /// No description provided for @emojiCatAnimals.
  ///
  /// In pt, this message translates to:
  /// **'Animais'**
  String get emojiCatAnimals;

  /// No description provided for @emojiCatFood.
  ///
  /// In pt, this message translates to:
  /// **'Comida'**
  String get emojiCatFood;

  /// No description provided for @emojiCatParty.
  ///
  /// In pt, this message translates to:
  /// **'Festa'**
  String get emojiCatParty;

  /// No description provided for @emojiCatObjects.
  ///
  /// In pt, this message translates to:
  /// **'Objetos'**
  String get emojiCatObjects;

  /// No description provided for @battleVs.
  ///
  /// In pt, this message translates to:
  /// **'VS'**
  String get battleVs;

  /// No description provided for @battleTimer.
  ///
  /// In pt, this message translates to:
  /// **'Tempo restante'**
  String get battleTimer;

  /// No description provided for @battleSendGift.
  ///
  /// In pt, this message translates to:
  /// **'Enviar presente'**
  String get battleSendGift;

  /// No description provided for @battleSupport.
  ///
  /// In pt, this message translates to:
  /// **'Apoiar'**
  String get battleSupport;

  /// No description provided for @battleWinner.
  ///
  /// In pt, this message translates to:
  /// **'Vencedor'**
  String get battleWinner;

  /// No description provided for @battleDraw.
  ///
  /// In pt, this message translates to:
  /// **'Empate'**
  String get battleDraw;

  /// No description provided for @battleEnded.
  ///
  /// In pt, this message translates to:
  /// **'Batalha encerrada'**
  String get battleEnded;

  /// No description provided for @battleResultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resultado da batalha'**
  String get battleResultTitle;

  /// No description provided for @battleResultShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar resultado'**
  String get battleResultShare;

  /// No description provided for @battleResultWatchAgain.
  ///
  /// In pt, this message translates to:
  /// **'Assistir outra batalha'**
  String get battleResultWatchAgain;

  /// No description provided for @battleScoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'{score} pts'**
  String battleScoreLabel(String score);

  /// No description provided for @battleTopSupporters.
  ///
  /// In pt, this message translates to:
  /// **'Top apoiadores'**
  String get battleTopSupporters;

  /// No description provided for @battleYouScore.
  ///
  /// In pt, this message translates to:
  /// **'Você: {score}'**
  String battleYouScore(String score);

  /// No description provided for @battleRivalScore.
  ///
  /// In pt, this message translates to:
  /// **'Rival: {score}'**
  String battleRivalScore(String score);

  /// No description provided for @battleCountdownStarting.
  ///
  /// In pt, this message translates to:
  /// **'Começando em {count}'**
  String battleCountdownStarting(int count);

  /// No description provided for @battleInviteReceived.
  ///
  /// In pt, this message translates to:
  /// **'{name} te desafiou para uma batalha!'**
  String battleInviteReceived(String name);

  /// No description provided for @battleAccept.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get battleAccept;

  /// No description provided for @battleDecline.
  ///
  /// In pt, this message translates to:
  /// **'Recusar'**
  String get battleDecline;

  /// No description provided for @battleLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando batalha...'**
  String get battleLoading;

  /// No description provided for @battleError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar batalha'**
  String get battleError;

  /// No description provided for @battleGiftReceived.
  ///
  /// In pt, this message translates to:
  /// **'{sender} enviou {gift}'**
  String battleGiftReceived(String sender, String gift);

  /// No description provided for @battleMomentum.
  ///
  /// In pt, this message translates to:
  /// **'PEGANDO FOGO'**
  String get battleMomentum;

  /// No description provided for @battleLeadChange.
  ///
  /// In pt, this message translates to:
  /// **'VIROU!'**
  String get battleLeadChange;

  /// No description provided for @battleFinalStretch.
  ///
  /// In pt, this message translates to:
  /// **'RETA FINAL'**
  String get battleFinalStretch;

  /// No description provided for @battleSendToWin.
  ///
  /// In pt, this message translates to:
  /// **'Mande presentes pra decidir!'**
  String get battleSendToWin;

  /// No description provided for @battleMvp.
  ///
  /// In pt, this message translates to:
  /// **'MVP'**
  String get battleMvp;

  /// No description provided for @sharedPostReactionApplied.
  ///
  /// In pt, this message translates to:
  /// **'Reação enviada ✨'**
  String get sharedPostReactionApplied;

  /// No description provided for @sharedPostMinutesAgo.
  ///
  /// In pt, this message translates to:
  /// **'há {count} min'**
  String sharedPostMinutesAgo(int count);

  /// No description provided for @sharedPostHoursAgo.
  ///
  /// In pt, this message translates to:
  /// **'há {count} h'**
  String sharedPostHoursAgo(int count);

  /// No description provided for @sharedPostDaysAgo.
  ///
  /// In pt, this message translates to:
  /// **'há {count} d'**
  String sharedPostDaysAgo(int count);

  /// No description provided for @topUpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar coins'**
  String get topUpTitle;

  /// No description provided for @topUpSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Compre direto pela loja do seu celular'**
  String get topUpSubtitle;

  /// No description provided for @topUpReasonGift.
  ///
  /// In pt, this message translates to:
  /// **'Saldo insuficiente para este presente'**
  String get topUpReasonGift;

  /// No description provided for @topUpReasonBattle.
  ///
  /// In pt, this message translates to:
  /// **'Continue na batalha! Recarregue agora'**
  String get topUpReasonBattle;

  /// No description provided for @topUpStoreDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento seguro via Play Store / App Store'**
  String get topUpStoreDisclaimer;

  /// No description provided for @earningsNoPurchasesHint.
  ///
  /// In pt, this message translates to:
  /// **'Quando você comprar coins pela App Store ou Google Play elas aparecerão aqui.'**
  String get earningsNoPurchasesHint;

  /// No description provided for @earningsNoGiftsHint.
  ///
  /// In pt, this message translates to:
  /// **'Os diamantes do Creator Program vêm dos gifts que você recebe em lives.'**
  String get earningsNoGiftsHint;

  /// No description provided for @creatorProgramTitle.
  ///
  /// In pt, this message translates to:
  /// **'Brawe Creator Network'**
  String get creatorProgramTitle;

  /// No description provided for @creatorProgramSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cresça sua audiência. Construa sua comunidade. Faça parte da Brawe.'**
  String get creatorProgramSubtitle;

  /// No description provided for @creatorProgramDescription.
  ///
  /// In pt, this message translates to:
  /// **'A Rede de Criadores Brawe é o programa oficial para criadores que querem crescer, ganhar visibilidade e construir uma comunidade dentro da Brawe.'**
  String get creatorProgramDescription;

  /// No description provided for @creatorActionApplyNow.
  ///
  /// In pt, this message translates to:
  /// **'Quero me inscrever'**
  String get creatorActionApplyNow;

  /// No description provided for @creatorActionViewLevels.
  ///
  /// In pt, this message translates to:
  /// **'Ver níveis de creator'**
  String get creatorActionViewLevels;

  /// No description provided for @creatorActionCheckStatus.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhar inscrição'**
  String get creatorActionCheckStatus;

  /// No description provided for @creatorBenefitsHeader.
  ///
  /// In pt, this message translates to:
  /// **'O que você ganha'**
  String get creatorBenefitsHeader;

  /// No description provided for @creatorBenefit1.
  ///
  /// In pt, this message translates to:
  /// **'Seja descoberto por novas audiências'**
  String get creatorBenefit1;

  /// No description provided for @creatorBenefit2.
  ///
  /// In pt, this message translates to:
  /// **'Construa sua identidade de creator'**
  String get creatorBenefit2;

  /// No description provided for @creatorBenefit3.
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueie badges oficiais'**
  String get creatorBenefit3;

  /// No description provided for @creatorBenefit4.
  ///
  /// In pt, this message translates to:
  /// **'Cresça com lives e conteúdo'**
  String get creatorBenefit4;

  /// No description provided for @creatorBenefit5.
  ///
  /// In pt, this message translates to:
  /// **'Faça parte de uma comunidade premium'**
  String get creatorBenefit5;

  /// No description provided for @creatorTotalCreators.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 creator na rede} other{{n} creators na rede}}'**
  String creatorTotalCreators(int n);

  /// No description provided for @creatorLevelsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Níveis de Creator'**
  String get creatorLevelsTitle;

  /// No description provided for @creatorLevelsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cada nível representa um momento da sua jornada.'**
  String get creatorLevelsSubtitle;

  /// No description provided for @creatorTierRisingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rising Creator'**
  String get creatorTierRisingTitle;

  /// No description provided for @creatorTierRisingBody.
  ///
  /// In pt, this message translates to:
  /// **'Para creators em crescimento que querem oportunidade real de alcance.'**
  String get creatorTierRisingBody;

  /// No description provided for @creatorTierFeaturedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Featured Creator'**
  String get creatorTierFeaturedTitle;

  /// No description provided for @creatorTierFeaturedBody.
  ///
  /// In pt, this message translates to:
  /// **'Para creators ativos com conteúdo consistente e potencial editorial.'**
  String get creatorTierFeaturedBody;

  /// No description provided for @creatorTierLiveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Live Creator'**
  String get creatorTierLiveTitle;

  /// No description provided for @creatorTierLiveBody.
  ///
  /// In pt, this message translates to:
  /// **'Para streamers, hosts e creators focados em lives e batalhas.'**
  String get creatorTierLiveBody;

  /// No description provided for @creatorTierAmbassadorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ambassador'**
  String get creatorTierAmbassadorTitle;

  /// No description provided for @creatorTierAmbassadorBody.
  ///
  /// In pt, this message translates to:
  /// **'Para creators reconhecidos que representam a visão da Brawe.'**
  String get creatorTierAmbassadorBody;

  /// No description provided for @creatorTierFoundingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Founding Creator'**
  String get creatorTierFoundingTitle;

  /// No description provided for @creatorTierFoundingBody.
  ///
  /// In pt, this message translates to:
  /// **'Para creators selecionados que ajudam a moldar o futuro da Brawe.'**
  String get creatorTierFoundingBody;

  /// No description provided for @creatorTierApplyCta.
  ///
  /// In pt, this message translates to:
  /// **'Inscrever-se como creator'**
  String get creatorTierApplyCta;

  /// No description provided for @creatorFormTitle.
  ///
  /// In pt, this message translates to:
  /// **'Inscrever-se na Rede'**
  String get creatorFormTitle;

  /// No description provided for @creatorFormSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Conte mais sobre sua jornada como creator.'**
  String get creatorFormSubtitle;

  /// No description provided for @creatorFormDescription.
  ///
  /// In pt, this message translates to:
  /// **'Analisamos cada inscrição com cuidado para entender seu conteúdo, objetivos e potencial dentro da Brawe.'**
  String get creatorFormDescription;

  /// No description provided for @creatorFormSectionIdentity.
  ///
  /// In pt, this message translates to:
  /// **'Identidade'**
  String get creatorFormSectionIdentity;

  /// No description provided for @creatorFormSectionContent.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo'**
  String get creatorFormSectionContent;

  /// No description provided for @creatorFormSectionSocial.
  ///
  /// In pt, this message translates to:
  /// **'Redes sociais'**
  String get creatorFormSectionSocial;

  /// No description provided for @creatorFormSectionAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre você'**
  String get creatorFormSectionAbout;

  /// No description provided for @creatorFormFullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get creatorFormFullName;

  /// No description provided for @creatorFormUsername.
  ///
  /// In pt, this message translates to:
  /// **'Username'**
  String get creatorFormUsername;

  /// No description provided for @creatorFormEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get creatorFormEmail;

  /// No description provided for @creatorFormPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get creatorFormPhone;

  /// No description provided for @creatorFormCountry.
  ///
  /// In pt, this message translates to:
  /// **'País'**
  String get creatorFormCountry;

  /// No description provided for @creatorFormCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get creatorFormCity;

  /// No description provided for @creatorFormLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma principal'**
  String get creatorFormLanguage;

  /// No description provided for @creatorFormNiche.
  ///
  /// In pt, this message translates to:
  /// **'Nicho de conteúdo'**
  String get creatorFormNiche;

  /// No description provided for @creatorFormNichePlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Ex: lifestyle, música, games, educação...'**
  String get creatorFormNichePlaceholder;

  /// No description provided for @creatorFormCategory.
  ///
  /// In pt, this message translates to:
  /// **'Categoria de creator'**
  String get creatorFormCategory;

  /// No description provided for @creatorFormSocialLinks.
  ///
  /// In pt, this message translates to:
  /// **'Links de redes sociais'**
  String get creatorFormSocialLinks;

  /// No description provided for @creatorFormSocialPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Cole seu Instagram, TikTok, YouTube...'**
  String get creatorFormSocialPlaceholder;

  /// No description provided for @creatorFormFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores aproximados'**
  String get creatorFormFollowers;

  /// No description provided for @creatorFormDoesLive.
  ///
  /// In pt, this message translates to:
  /// **'Você faz lives atualmente?'**
  String get creatorFormDoesLive;

  /// No description provided for @creatorFormBio.
  ///
  /// In pt, this message translates to:
  /// **'Conte sua história'**
  String get creatorFormBio;

  /// No description provided for @creatorFormBioPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Conte quem é você como creator'**
  String get creatorFormBioPlaceholder;

  /// No description provided for @creatorFormMotivation.
  ///
  /// In pt, this message translates to:
  /// **'Sua motivação'**
  String get creatorFormMotivation;

  /// No description provided for @creatorFormMotivationPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Por que quer crescer com a Brawe?'**
  String get creatorFormMotivationPlaceholder;

  /// No description provided for @creatorFormGoals.
  ///
  /// In pt, this message translates to:
  /// **'Seus objetivos'**
  String get creatorFormGoals;

  /// No description provided for @creatorFormGoalsPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'O que quer alcançar como creator?'**
  String get creatorFormGoalsPlaceholder;

  /// No description provided for @creatorFormPortfolio.
  ///
  /// In pt, this message translates to:
  /// **'Portfólio (opcional)'**
  String get creatorFormPortfolio;

  /// No description provided for @creatorFormSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Enviar inscrição'**
  String get creatorFormSubmit;

  /// No description provided for @creatorFormSaveDraft.
  ///
  /// In pt, this message translates to:
  /// **'Salvar rascunho'**
  String get creatorFormSaveDraft;

  /// No description provided for @creatorFormCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get creatorFormCancel;

  /// No description provided for @creatorFormTermsPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito os '**
  String get creatorFormTermsPrefix;

  /// No description provided for @creatorFormTermsLink.
  ///
  /// In pt, this message translates to:
  /// **'Termos do Brawe Creator Network'**
  String get creatorFormTermsLink;

  /// No description provided for @creatorFormTermsSuffix.
  ///
  /// In pt, this message translates to:
  /// **'.'**
  String get creatorFormTermsSuffix;

  /// No description provided for @creatorFormTermsMustAccept.
  ///
  /// In pt, this message translates to:
  /// **'Você precisa aceitar os Termos para se inscrever.'**
  String get creatorFormTermsMustAccept;

  /// No description provided for @creatorFormTermsOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir Termos'**
  String get creatorFormTermsOpen;

  /// No description provided for @creatorFormTermsClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get creatorFormTermsClose;

  /// No description provided for @creatorFormTermsVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão {version}'**
  String creatorFormTermsVersion(String version);

  /// No description provided for @creatorFormValidationRequired.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get creatorFormValidationRequired;

  /// No description provided for @creatorFormValidationEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get creatorFormValidationEmail;

  /// No description provided for @creatorFormValidationSocial.
  ///
  /// In pt, this message translates to:
  /// **'Adicione pelo menos uma rede social'**
  String get creatorFormValidationSocial;

  /// No description provided for @creatorFormSubmitting.
  ///
  /// In pt, this message translates to:
  /// **'Enviando sua inscrição...'**
  String get creatorFormSubmitting;

  /// No description provided for @creatorFormSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Inscrição enviada com sucesso.'**
  String get creatorFormSuccess;

  /// No description provided for @creatorFormError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar sua inscrição. Tente novamente.'**
  String get creatorFormError;

  /// No description provided for @creatorFormAlreadyExists.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem uma inscrição ativa.'**
  String get creatorFormAlreadyExists;

  /// No description provided for @creatorSubmittedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Inscrição enviada'**
  String get creatorSubmittedTitle;

  /// No description provided for @creatorSubmittedBody.
  ///
  /// In pt, this message translates to:
  /// **'Obrigado por se inscrever na Brawe Creator Network. Nossa equipe vai revisar seu perfil e avisaremos quando houver atualização.'**
  String get creatorSubmittedBody;

  /// No description provided for @creatorSubmittedStep1.
  ///
  /// In pt, this message translates to:
  /// **'Sua inscrição está aguardando revisão.'**
  String get creatorSubmittedStep1;

  /// No description provided for @creatorSubmittedStep2.
  ///
  /// In pt, this message translates to:
  /// **'Podemos pedir mais informações se necessário.'**
  String get creatorSubmittedStep2;

  /// No description provided for @creatorSubmittedStep3.
  ///
  /// In pt, this message translates to:
  /// **'Você pode acompanhar o status quando quiser.'**
  String get creatorSubmittedStep3;

  /// No description provided for @creatorSubmittedTrack.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhar inscrição'**
  String get creatorSubmittedTrack;

  /// No description provided for @creatorSubmittedHome.
  ///
  /// In pt, this message translates to:
  /// **'Voltar pro Início'**
  String get creatorSubmittedHome;

  /// No description provided for @creatorStatusPendingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Inscrição recebida'**
  String get creatorStatusPendingTitle;

  /// No description provided for @creatorStatusPendingBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua inscrição foi recebida e está aguardando revisão.'**
  String get creatorStatusPendingBody;

  /// No description provided for @creatorStatusAnalysisTitle.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get creatorStatusAnalysisTitle;

  /// No description provided for @creatorStatusAnalysisBody.
  ///
  /// In pt, this message translates to:
  /// **'Nossa equipe está revisando seu perfil de creator.'**
  String get creatorStatusAnalysisBody;

  /// No description provided for @creatorStatusApprovedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você foi aprovado!'**
  String get creatorStatusApprovedTitle;

  /// No description provided for @creatorStatusApprovedBody.
  ///
  /// In pt, this message translates to:
  /// **'Parabéns! Você agora faz parte da Brawe Creator Network.'**
  String get creatorStatusApprovedBody;

  /// No description provided for @creatorStatusRejectedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Inscrição não aprovada'**
  String get creatorStatusRejectedTitle;

  /// No description provided for @creatorStatusRejectedBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua inscrição não foi aprovada neste momento. Você pode melhorar seu perfil e tentar novamente mais tarde.'**
  String get creatorStatusRejectedBody;

  /// No description provided for @creatorStatusWaitlistTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você está na waitlist'**
  String get creatorStatusWaitlistTitle;

  /// No description provided for @creatorStatusWaitlistBody.
  ///
  /// In pt, this message translates to:
  /// **'Seu perfil tem potencial e podemos convidá-lo em breve.'**
  String get creatorStatusWaitlistBody;

  /// No description provided for @creatorStatusNeedsInfoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Precisamos de mais informações'**
  String get creatorStatusNeedsInfoTitle;

  /// No description provided for @creatorStatusNeedsInfoBody.
  ///
  /// In pt, this message translates to:
  /// **'Atualize sua inscrição com os detalhes solicitados.'**
  String get creatorStatusNeedsInfoBody;

  /// No description provided for @creatorStatusInvitedAmbassadorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convite Ambassador'**
  String get creatorStatusInvitedAmbassadorTitle;

  /// No description provided for @creatorStatusInvitedAmbassadorBody.
  ///
  /// In pt, this message translates to:
  /// **'Você foi convidado para o programa Brawe Ambassadors.'**
  String get creatorStatusInvitedAmbassadorBody;

  /// No description provided for @creatorStatusInvitedFoundingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convite Founding Creator'**
  String get creatorStatusInvitedFoundingTitle;

  /// No description provided for @creatorStatusInvitedFoundingBody.
  ///
  /// In pt, this message translates to:
  /// **'Você foi convidado para ser Brawe Founding Creator.'**
  String get creatorStatusInvitedFoundingBody;

  /// No description provided for @creatorStatusUpdateApplication.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar inscrição'**
  String get creatorStatusUpdateApplication;

  /// No description provided for @creatorStatusContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get creatorStatusContinue;

  /// No description provided for @creatorStatusStartOnboarding.
  ///
  /// In pt, this message translates to:
  /// **'Começar onboarding'**
  String get creatorStatusStartOnboarding;

  /// No description provided for @creatorOnboardingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo à Brawe Creator Network'**
  String get creatorOnboardingTitle;

  /// No description provided for @creatorOnboardingSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Vamos configurar sua presença e ajudar pessoas a descobrirem seu conteúdo.'**
  String get creatorOnboardingSubtitle;

  /// No description provided for @creatorOnboardingStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar setup'**
  String get creatorOnboardingStart;

  /// No description provided for @creatorOnboardingSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular por enquanto'**
  String get creatorOnboardingSkip;

  /// No description provided for @creatorOnboardingProgress.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} concluído'**
  String creatorOnboardingProgress(int done, int total);

  /// No description provided for @creatorProfileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de Creator'**
  String get creatorProfileTitle;

  /// No description provided for @creatorProfileSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Personalize como você aparece como creator.'**
  String get creatorProfileSubtitle;

  /// No description provided for @creatorProfileFieldDisplayName.
  ///
  /// In pt, this message translates to:
  /// **'Nome público'**
  String get creatorProfileFieldDisplayName;

  /// No description provided for @creatorProfileFieldBio.
  ///
  /// In pt, this message translates to:
  /// **'Bio de creator'**
  String get creatorProfileFieldBio;

  /// No description provided for @creatorProfileFieldCategory.
  ///
  /// In pt, this message translates to:
  /// **'Categoria de conteúdo'**
  String get creatorProfileFieldCategory;

  /// No description provided for @creatorProfileFieldSocial.
  ///
  /// In pt, this message translates to:
  /// **'Links públicos'**
  String get creatorProfileFieldSocial;

  /// No description provided for @creatorProfileFieldBadgeVisibility.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar badge no perfil'**
  String get creatorProfileFieldBadgeVisibility;

  /// No description provided for @creatorProfileSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get creatorProfileSave;

  /// No description provided for @creatorProfilePreview.
  ///
  /// In pt, this message translates to:
  /// **'Visualizar perfil'**
  String get creatorProfilePreview;

  /// No description provided for @creatorProfileSaved.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de creator atualizado.'**
  String get creatorProfileSaved;

  /// No description provided for @creatorProfileSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar o perfil de creator.'**
  String get creatorProfileSaveError;

  /// No description provided for @creatorBadgeScreenTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu Badge de Creator'**
  String get creatorBadgeScreenTitle;

  /// No description provided for @creatorBadgeScreenSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu badge ajuda as pessoas a reconhecerem seu papel dentro da Brawe Creator Network.'**
  String get creatorBadgeScreenSubtitle;

  /// No description provided for @creatorBadgeLocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueado'**
  String get creatorBadgeLocked;

  /// No description provided for @creatorBadgeUnlocked.
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueado'**
  String get creatorBadgeUnlocked;

  /// No description provided for @creatorBadgeViewBenefits.
  ///
  /// In pt, this message translates to:
  /// **'Ver benefícios'**
  String get creatorBadgeViewBenefits;

  /// No description provided for @creatorBadgeBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get creatorBadgeBack;

  /// No description provided for @creatorDashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Painel do Creator'**
  String get creatorDashboardTitle;

  /// No description provided for @creatorDashboardSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe seu crescimento e gerencie sua presença.'**
  String get creatorDashboardSubtitle;

  /// No description provided for @creatorDashboardCardViews.
  ///
  /// In pt, this message translates to:
  /// **'Visualizações de perfil'**
  String get creatorDashboardCardViews;

  /// No description provided for @creatorDashboardCardFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Crescimento de seguidores'**
  String get creatorDashboardCardFollowers;

  /// No description provided for @creatorDashboardCardReach.
  ///
  /// In pt, this message translates to:
  /// **'Alcance de conteúdo'**
  String get creatorDashboardCardReach;

  /// No description provided for @creatorDashboardCardLives.
  ///
  /// In pt, this message translates to:
  /// **'Atividade em lives'**
  String get creatorDashboardCardLives;

  /// No description provided for @creatorDashboardCardStatus.
  ///
  /// In pt, this message translates to:
  /// **'Status de creator'**
  String get creatorDashboardCardStatus;

  /// No description provided for @creatorDashboardQuickCreatePost.
  ///
  /// In pt, this message translates to:
  /// **'Criar post'**
  String get creatorDashboardQuickCreatePost;

  /// No description provided for @creatorDashboardQuickGoLive.
  ///
  /// In pt, this message translates to:
  /// **'Entrar ao vivo'**
  String get creatorDashboardQuickGoLive;

  /// No description provided for @creatorDashboardQuickEditProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil'**
  String get creatorDashboardQuickEditProfile;

  /// No description provided for @creatorDashboardQuickViewBadge.
  ///
  /// In pt, this message translates to:
  /// **'Ver badge'**
  String get creatorDashboardQuickViewBadge;

  /// No description provided for @creatorDashboardQuickInsights.
  ///
  /// In pt, this message translates to:
  /// **'Ver insights'**
  String get creatorDashboardQuickInsights;

  /// No description provided for @adminCreatorAppsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Inscrições de Creators'**
  String get adminCreatorAppsTitle;

  /// No description provided for @adminCreatorAppsFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get adminCreatorAppsFilterAll;

  /// No description provided for @adminCreatorAppsFilterPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes'**
  String get adminCreatorAppsFilterPending;

  /// No description provided for @adminCreatorAppsFilterAnalysis.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get adminCreatorAppsFilterAnalysis;

  /// No description provided for @adminCreatorAppsFilterApproved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovados'**
  String get adminCreatorAppsFilterApproved;

  /// No description provided for @adminCreatorAppsFilterRejected.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitados'**
  String get adminCreatorAppsFilterRejected;

  /// No description provided for @adminCreatorAppsFilterWaitlist.
  ///
  /// In pt, this message translates to:
  /// **'Waitlist'**
  String get adminCreatorAppsFilterWaitlist;

  /// No description provided for @adminCreatorAppsFilterNeedsInfo.
  ///
  /// In pt, this message translates to:
  /// **'Precisa info'**
  String get adminCreatorAppsFilterNeedsInfo;

  /// No description provided for @adminCreatorAppsReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisar'**
  String get adminCreatorAppsReview;

  /// No description provided for @adminCreatorAppsFilter.
  ///
  /// In pt, this message translates to:
  /// **'Filtros'**
  String get adminCreatorAppsFilter;

  /// No description provided for @adminCreatorAppsExport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get adminCreatorAppsExport;

  /// No description provided for @adminCreatorAppsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar nome, username ou e-mail'**
  String get adminCreatorAppsSearchHint;

  /// No description provided for @adminCreatorAppsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma inscrição encontrada.'**
  String get adminCreatorAppsEmpty;

  /// No description provided for @adminCreatorAppsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar inscrições.'**
  String get adminCreatorAppsLoadError;

  /// No description provided for @adminCreatorAppDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Análise da Inscrição'**
  String get adminCreatorAppDetailTitle;

  /// No description provided for @adminCreatorSectionInfo.
  ///
  /// In pt, this message translates to:
  /// **'Informações do creator'**
  String get adminCreatorSectionInfo;

  /// No description provided for @adminCreatorSectionSocial.
  ///
  /// In pt, this message translates to:
  /// **'Redes sociais'**
  String get adminCreatorSectionSocial;

  /// No description provided for @adminCreatorSectionNiche.
  ///
  /// In pt, this message translates to:
  /// **'Nicho de conteúdo'**
  String get adminCreatorSectionNiche;

  /// No description provided for @adminCreatorSectionMotivation.
  ///
  /// In pt, this message translates to:
  /// **'Motivação'**
  String get adminCreatorSectionMotivation;

  /// No description provided for @adminCreatorSectionGoals.
  ///
  /// In pt, this message translates to:
  /// **'Objetivos'**
  String get adminCreatorSectionGoals;

  /// No description provided for @adminCreatorSectionNotes.
  ///
  /// In pt, this message translates to:
  /// **'Notas internas'**
  String get adminCreatorSectionNotes;

  /// No description provided for @adminCreatorSectionSuggestedTier.
  ///
  /// In pt, this message translates to:
  /// **'Tier sugerido'**
  String get adminCreatorSectionSuggestedTier;

  /// No description provided for @adminCreatorActionApprove.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar'**
  String get adminCreatorActionApprove;

  /// No description provided for @adminCreatorActionReject.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitar'**
  String get adminCreatorActionReject;

  /// No description provided for @adminCreatorActionWaitlist.
  ///
  /// In pt, this message translates to:
  /// **'Mover para waitlist'**
  String get adminCreatorActionWaitlist;

  /// No description provided for @adminCreatorActionRequestInfo.
  ///
  /// In pt, this message translates to:
  /// **'Pedir mais informações'**
  String get adminCreatorActionRequestInfo;

  /// No description provided for @adminCreatorActionInviteAmbassador.
  ///
  /// In pt, this message translates to:
  /// **'Convidar como Ambassador'**
  String get adminCreatorActionInviteAmbassador;

  /// No description provided for @adminCreatorActionInviteFounding.
  ///
  /// In pt, this message translates to:
  /// **'Convidar como Founding Creator'**
  String get adminCreatorActionInviteFounding;

  /// No description provided for @adminCreatorActionSaveNotes.
  ///
  /// In pt, this message translates to:
  /// **'Salvar notas'**
  String get adminCreatorActionSaveNotes;

  /// No description provided for @adminCreatorConfirmApprove.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que quer aprovar este creator?'**
  String get adminCreatorConfirmApprove;

  /// No description provided for @adminCreatorConfirmReject.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que quer rejeitar esta inscrição?'**
  String get adminCreatorConfirmReject;

  /// No description provided for @adminCreatorConfirmRequestInfo.
  ///
  /// In pt, this message translates to:
  /// **'Diga ao creator quais informações estão faltando.'**
  String get adminCreatorConfirmRequestInfo;

  /// No description provided for @adminCreatorReviewSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Decisão registrada.'**
  String get adminCreatorReviewSuccess;

  /// No description provided for @adminCreatorReviewError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível registrar a decisão.'**
  String get adminCreatorReviewError;

  /// No description provided for @adminCreatorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar Creators'**
  String get adminCreatorsTitle;

  /// No description provided for @adminCreatorsFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos os creators'**
  String get adminCreatorsFilterAll;

  /// No description provided for @adminCreatorsFilterRising.
  ///
  /// In pt, this message translates to:
  /// **'Rising'**
  String get adminCreatorsFilterRising;

  /// No description provided for @adminCreatorsFilterFeatured.
  ///
  /// In pt, this message translates to:
  /// **'Featured'**
  String get adminCreatorsFilterFeatured;

  /// No description provided for @adminCreatorsFilterLive.
  ///
  /// In pt, this message translates to:
  /// **'Live'**
  String get adminCreatorsFilterLive;

  /// No description provided for @adminCreatorsFilterAmbassadors.
  ///
  /// In pt, this message translates to:
  /// **'Ambassadors'**
  String get adminCreatorsFilterAmbassadors;

  /// No description provided for @adminCreatorsFilterFounding.
  ///
  /// In pt, this message translates to:
  /// **'Founding'**
  String get adminCreatorsFilterFounding;

  /// No description provided for @adminCreatorsActionEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar creator'**
  String get adminCreatorsActionEdit;

  /// No description provided for @adminCreatorsActionChangeBadge.
  ///
  /// In pt, this message translates to:
  /// **'Mudar badge'**
  String get adminCreatorsActionChangeBadge;

  /// No description provided for @adminCreatorsActionFeature.
  ///
  /// In pt, this message translates to:
  /// **'Destacar'**
  String get adminCreatorsActionFeature;

  /// No description provided for @adminCreatorsActionDisable.
  ///
  /// In pt, this message translates to:
  /// **'Desativar'**
  String get adminCreatorsActionDisable;

  /// No description provided for @creatorTimelineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Linha do tempo'**
  String get creatorTimelineTitle;

  /// No description provided for @creatorTimelineSubmitted.
  ///
  /// In pt, this message translates to:
  /// **'Inscrição enviada'**
  String get creatorTimelineSubmitted;

  /// No description provided for @creatorTimelineUnderReview.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get creatorTimelineUnderReview;

  /// No description provided for @creatorTimelineFinalDecision.
  ///
  /// In pt, this message translates to:
  /// **'Decisão final'**
  String get creatorTimelineFinalDecision;

  /// No description provided for @creatorTimelineResult.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get creatorTimelineResult;

  /// No description provided for @creatorYourApplication.
  ///
  /// In pt, this message translates to:
  /// **'Sua inscrição'**
  String get creatorYourApplication;

  /// No description provided for @creatorInfoName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get creatorInfoName;

  /// No description provided for @creatorInfoUsername.
  ///
  /// In pt, this message translates to:
  /// **'Username'**
  String get creatorInfoUsername;

  /// No description provided for @creatorInfoCountry.
  ///
  /// In pt, this message translates to:
  /// **'País'**
  String get creatorInfoCountry;

  /// No description provided for @creatorInfoNiche.
  ///
  /// In pt, this message translates to:
  /// **'Nicho'**
  String get creatorInfoNiche;

  /// No description provided for @creatorInfoRequestedTier.
  ///
  /// In pt, this message translates to:
  /// **'Tier solicitado'**
  String get creatorInfoRequestedTier;

  /// No description provided for @creatorInfoFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get creatorInfoFollowers;

  /// No description provided for @creatorInfoDoesLive.
  ///
  /// In pt, this message translates to:
  /// **'Faz lives'**
  String get creatorInfoDoesLive;

  /// No description provided for @creatorQuickShortcuts.
  ///
  /// In pt, this message translates to:
  /// **'Atalhos rápidos'**
  String get creatorQuickShortcuts;

  /// No description provided for @creatorBadgeActive.
  ///
  /// In pt, this message translates to:
  /// **'ATIVO'**
  String get creatorBadgeActive;

  /// No description provided for @commonYes.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get commonNo;

  /// No description provided for @commonRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get commonRetry;

  /// No description provided for @editProfileAccountTypeSection.
  ///
  /// In pt, this message translates to:
  /// **'TIPO DE CONTA'**
  String get editProfileAccountTypeSection;

  /// No description provided for @editProfileAccountTypeCreator.
  ///
  /// In pt, this message translates to:
  /// **'Criador'**
  String get editProfileAccountTypeCreator;

  /// No description provided for @editProfileAccountTypeMusician.
  ///
  /// In pt, this message translates to:
  /// **'Músico'**
  String get editProfileAccountTypeMusician;

  /// No description provided for @editProfileAccountTypeBusiness.
  ///
  /// In pt, this message translates to:
  /// **'Empresa'**
  String get editProfileAccountTypeBusiness;

  /// No description provided for @editProfileMusicianBannerHint.
  ///
  /// In pt, this message translates to:
  /// **'Crie seu perfil de artista no Brawe Sounds e apareça no catálogo.'**
  String get editProfileMusicianBannerHint;

  /// No description provided for @editProfileMusicianArtistName.
  ///
  /// In pt, this message translates to:
  /// **'Nome artístico'**
  String get editProfileMusicianArtistName;

  /// No description provided for @editProfileMusicianArtistNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Como aparece no Brawe Sounds'**
  String get editProfileMusicianArtistNameHint;

  /// No description provided for @editProfileMusicianCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get editProfileMusicianCity;

  /// No description provided for @editProfileMusicianCityHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: São Paulo, SP'**
  String get editProfileMusicianCityHint;

  /// No description provided for @editProfileMusicianSpotify.
  ///
  /// In pt, this message translates to:
  /// **'Spotify'**
  String get editProfileMusicianSpotify;

  /// No description provided for @editProfileMusicianAppleMusic.
  ///
  /// In pt, this message translates to:
  /// **'Apple Music'**
  String get editProfileMusicianAppleMusic;

  /// No description provided for @editProfileMusicianGenres.
  ///
  /// In pt, this message translates to:
  /// **'GÊNEROS'**
  String get editProfileMusicianGenres;

  /// No description provided for @soundsGenreFunk.
  ///
  /// In pt, this message translates to:
  /// **'Funk'**
  String get soundsGenreFunk;

  /// No description provided for @soundsGenreSertanejo.
  ///
  /// In pt, this message translates to:
  /// **'Sertanejo'**
  String get soundsGenreSertanejo;

  /// No description provided for @soundsGenrePagode.
  ///
  /// In pt, this message translates to:
  /// **'Pagode'**
  String get soundsGenrePagode;

  /// No description provided for @soundsGenreForro.
  ///
  /// In pt, this message translates to:
  /// **'Forró'**
  String get soundsGenreForro;

  /// No description provided for @soundsGenrePop.
  ///
  /// In pt, this message translates to:
  /// **'Pop'**
  String get soundsGenrePop;

  /// No description provided for @soundsGenreRap.
  ///
  /// In pt, this message translates to:
  /// **'Rap'**
  String get soundsGenreRap;

  /// No description provided for @soundsGenreElectro.
  ///
  /// In pt, this message translates to:
  /// **'Eletrônico'**
  String get soundsGenreElectro;

  /// No description provided for @soundsGenreGospel.
  ///
  /// In pt, this message translates to:
  /// **'Gospel'**
  String get soundsGenreGospel;

  /// No description provided for @soundsGenreRock.
  ///
  /// In pt, this message translates to:
  /// **'Rock'**
  String get soundsGenreRock;

  /// No description provided for @soundsGenreMpb.
  ///
  /// In pt, this message translates to:
  /// **'MPB'**
  String get soundsGenreMpb;

  /// No description provided for @soundsArtistTracks.
  ///
  /// In pt, this message translates to:
  /// **'{count,plural, =1{1 faixa} other{{count} faixas}}'**
  String soundsArtistTracks(int count);

  /// No description provided for @soundsArtistPlays.
  ///
  /// In pt, this message translates to:
  /// **'{count} plays'**
  String soundsArtistPlays(Object count);

  /// No description provided for @soundsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Brawe Sounds'**
  String get soundsTitle;

  /// No description provided for @soundsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Descubra trilhas incríveis'**
  String get soundsSubtitle;

  /// No description provided for @soundsTabTrending.
  ///
  /// In pt, this message translates to:
  /// **'Em alta'**
  String get soundsTabTrending;

  /// No description provided for @soundsTabCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo'**
  String get soundsTabCatalog;

  /// No description provided for @soundsSearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar músicas ou artistas...'**
  String get soundsSearch;

  /// No description provided for @soundsGenreAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get soundsGenreAll;

  /// No description provided for @soundsEmptyTrending.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma música em alta ainda'**
  String get soundsEmptyTrending;

  /// No description provided for @soundsEmptyCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma música encontrada'**
  String get soundsEmptyCatalog;

  /// No description provided for @soundsEmptySearch.
  ///
  /// In pt, this message translates to:
  /// **'Sem resultados para \"{query}\"'**
  String soundsEmptySearch(String query);

  /// No description provided for @soundsLoadMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregar mais'**
  String get soundsLoadMore;

  /// No description provided for @soundsUsedTimes.
  ///
  /// In pt, this message translates to:
  /// **'{count,plural, =1{usado 1 vez} other{usado {count} vezes}}'**
  String soundsUsedTimes(int count);

  /// No description provided for @soundsSaved.
  ///
  /// In pt, this message translates to:
  /// **'Salvo'**
  String get soundsSaved;

  /// No description provided for @soundsSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get soundsSave;

  /// No description provided for @soundsUse.
  ///
  /// In pt, this message translates to:
  /// **'Usar'**
  String get soundsUse;

  /// No description provided for @soundsPlayerLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get soundsPlayerLoading;

  /// No description provided for @soundsPlayerError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar áudio'**
  String get soundsPlayerError;

  /// No description provided for @navSounds.
  ///
  /// In pt, this message translates to:
  /// **'Sounds'**
  String get navSounds;

  /// No description provided for @createSoundsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sounds'**
  String get createSoundsTitle;

  /// No description provided for @createSoundsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma música original ao seu post'**
  String get createSoundsSubtitle;

  /// No description provided for @postSoundLabel.
  ///
  /// In pt, this message translates to:
  /// **'Som: {title}'**
  String postSoundLabel(String title);

  /// No description provided for @postSoundRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover som'**
  String get postSoundRemove;

  /// No description provided for @contentSoundOriginalAudio.
  ///
  /// In pt, this message translates to:
  /// **'Áudio original'**
  String get contentSoundOriginalAudio;

  /// No description provided for @contentSoundUseThis.
  ///
  /// In pt, this message translates to:
  /// **'Usar esta música'**
  String get contentSoundUseThis;

  /// No description provided for @contentSoundUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Música indisponível'**
  String get contentSoundUnavailable;

  /// No description provided for @contentSoundView.
  ///
  /// In pt, this message translates to:
  /// **'Ver música'**
  String get contentSoundView;

  /// No description provided for @contentSoundNowPlaying.
  ///
  /// In pt, this message translates to:
  /// **'Tocando agora'**
  String get contentSoundNowPlaying;

  /// No description provided for @contentSoundByArtist.
  ///
  /// In pt, this message translates to:
  /// **'{title} · {artist}'**
  String contentSoundByArtist(String title, String artist);

  /// No description provided for @soundTrimTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cortar música'**
  String get soundTrimTitle;

  /// No description provided for @soundTrimSave.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get soundTrimSave;

  /// No description provided for @soundTrimCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get soundTrimCancel;

  /// No description provided for @soundTrimHint.
  ///
  /// In pt, this message translates to:
  /// **'Arraste as alças para escolher o trecho da música'**
  String get soundTrimHint;

  /// No description provided for @soundTrimMaxDuration.
  ///
  /// In pt, this message translates to:
  /// **'Máximo de {seconds}s para este conteúdo'**
  String soundTrimMaxDuration(int seconds);

  /// No description provided for @soundTrimSelectedDuration.
  ///
  /// In pt, this message translates to:
  /// **'{seconds}s selecionados'**
  String soundTrimSelectedDuration(int seconds);

  /// No description provided for @soundTrimError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível processar o trecho selecionado.'**
  String get soundTrimError;

  /// No description provided for @soundVolumeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Volume da música'**
  String get soundVolumeLabel;

  /// No description provided for @originalAudioVolumeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Volume do áudio original'**
  String get originalAudioVolumeLabel;

  /// No description provided for @analyticsViewersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Audiência'**
  String get analyticsViewersTitle;

  /// No description provided for @analyticsViewersTotalViewers.
  ///
  /// In pt, this message translates to:
  /// **'Total de viewers'**
  String get analyticsViewersTotalViewers;

  /// No description provided for @analyticsViewersAvgPerLive.
  ///
  /// In pt, this message translates to:
  /// **'Média/live'**
  String get analyticsViewersAvgPerLive;

  /// No description provided for @analyticsViewersChartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Visualizações por dia'**
  String get analyticsViewersChartTitle;

  /// No description provided for @analyticsViewersLegendViewers.
  ///
  /// In pt, this message translates to:
  /// **'Viewers'**
  String get analyticsViewersLegendViewers;

  /// No description provided for @analyticsViewersLegendPeak.
  ///
  /// In pt, this message translates to:
  /// **'Pico'**
  String get analyticsViewersLegendPeak;

  /// No description provided for @analyticsViewersBestDays.
  ///
  /// In pt, this message translates to:
  /// **'Melhores dias'**
  String get analyticsViewersBestDays;

  /// No description provided for @analyticsViewersNoData.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados'**
  String get analyticsViewersNoData;

  /// No description provided for @analyticsViewersUnit.
  ///
  /// In pt, this message translates to:
  /// **' viewers'**
  String get analyticsViewersUnit;

  /// No description provided for @analyticsFollowersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get analyticsFollowersTitle;

  /// No description provided for @analyticsFollowersCount.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get analyticsFollowersCount;

  /// No description provided for @analyticsFollowersFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get analyticsFollowersFollowing;

  /// No description provided for @analyticsFollowersTrendTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tendência de engajamento'**
  String get analyticsFollowersTrendTitle;

  /// No description provided for @analyticsFollowersTrendSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Audiência das lives — correlação direta com crescimento'**
  String get analyticsFollowersTrendSubtitle;

  /// No description provided for @analyticsFollowersLegendEngagement.
  ///
  /// In pt, this message translates to:
  /// **'Engajamento'**
  String get analyticsFollowersLegendEngagement;

  /// No description provided for @analyticsFollowersSummaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo da conta'**
  String get analyticsFollowersSummaryTitle;

  /// No description provided for @analyticsFollowersSummaryFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get analyticsFollowersSummaryFollowers;

  /// No description provided for @analyticsFollowersSummaryFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get analyticsFollowersSummaryFollowing;

  /// No description provided for @analyticsFollowersSummaryLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives realizadas'**
  String get analyticsFollowersSummaryLives;

  /// No description provided for @analyticsFollowersSummaryRatio.
  ///
  /// In pt, this message translates to:
  /// **'Taxa seguidor/live'**
  String get analyticsFollowersSummaryRatio;

  /// No description provided for @analyticsFollowersTipsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dicas para crescer'**
  String get analyticsFollowersTipsTitle;

  /// No description provided for @analyticsFollowersTip1Title.
  ///
  /// In pt, this message translates to:
  /// **'Faça lives regularmente'**
  String get analyticsFollowersTip1Title;

  /// No description provided for @analyticsFollowersTip1Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Consistência aumenta seguidores em +40%'**
  String get analyticsFollowersTip1Subtitle;

  /// No description provided for @analyticsFollowersTip2Title.
  ///
  /// In pt, this message translates to:
  /// **'Interaja com a audiência'**
  String get analyticsFollowersTip2Title;

  /// No description provided for @analyticsFollowersTip2Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Responder comentários aumenta retenção'**
  String get analyticsFollowersTip2Subtitle;

  /// No description provided for @analyticsFollowersTip3Title.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhe seus conteúdos'**
  String get analyticsFollowersTip3Title;

  /// No description provided for @analyticsFollowersTip3Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Stories e posts aumentam o alcance'**
  String get analyticsFollowersTip3Subtitle;

  /// No description provided for @analyticsLivesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de Lives'**
  String get analyticsLivesTitle;

  /// No description provided for @analyticsLivesErrorLoad.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar lives'**
  String get analyticsLivesErrorLoad;

  /// No description provided for @analyticsLivesRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get analyticsLivesRetry;

  /// No description provided for @analyticsLivesKpiTotal.
  ///
  /// In pt, this message translates to:
  /// **'Lives'**
  String get analyticsLivesKpiTotal;

  /// No description provided for @analyticsLivesKpiAvgViewers.
  ///
  /// In pt, this message translates to:
  /// **'Viewers méd.'**
  String get analyticsLivesKpiAvgViewers;

  /// No description provided for @analyticsLivesKpiGifts.
  ///
  /// In pt, this message translates to:
  /// **'Gifts (USDT)'**
  String get analyticsLivesKpiGifts;

  /// No description provided for @analyticsLivesDuration.
  ///
  /// In pt, this message translates to:
  /// **'{min} min'**
  String analyticsLivesDuration(String min);

  /// No description provided for @analyticsLivesNoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Live sem título'**
  String get analyticsLivesNoTitle;

  /// No description provided for @analyticsLivesMetricViewers.
  ///
  /// In pt, this message translates to:
  /// **'viewers'**
  String get analyticsLivesMetricViewers;

  /// No description provided for @analyticsLivesMetricPeak.
  ///
  /// In pt, this message translates to:
  /// **'pico'**
  String get analyticsLivesMetricPeak;

  /// No description provided for @analyticsLivesMetricUsdt.
  ///
  /// In pt, this message translates to:
  /// **'USDT'**
  String get analyticsLivesMetricUsdt;

  /// No description provided for @analyticsLivesReplayLabel.
  ///
  /// In pt, this message translates to:
  /// **'Replay'**
  String get analyticsLivesReplayLabel;

  /// No description provided for @analyticsLivesReplayExpired.
  ///
  /// In pt, this message translates to:
  /// **'Replay não disponível'**
  String get analyticsLivesReplayExpired;

  /// No description provided for @analyticsLivesReplayExpiredSub.
  ///
  /// In pt, this message translates to:
  /// **'O vídeo pode ter expirado (>30 dias)'**
  String get analyticsLivesReplayExpiredSub;

  /// No description provided for @analyticsLivesEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma live realizada ainda'**
  String get analyticsLivesEmptyTitle;

  /// No description provided for @analyticsLivesEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Faça sua primeira live e veja as métricas aqui'**
  String get analyticsLivesEmptySubtitle;

  /// No description provided for @analyticsLivesMonthsShort.
  ///
  /// In pt, this message translates to:
  /// **'Jan,Fev,Mar,Abr,Mai,Jun,Jul,Ago,Set,Out,Nov,Dez'**
  String get analyticsLivesMonthsShort;

  /// No description provided for @analyticsReachTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alcance e Monetização'**
  String get analyticsReachTitle;

  /// No description provided for @analyticsReachKpiGifts.
  ///
  /// In pt, this message translates to:
  /// **'Gifts recebidos'**
  String get analyticsReachKpiGifts;

  /// No description provided for @analyticsReachKpiEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos (USDT)'**
  String get analyticsReachKpiEarnings;

  /// No description provided for @analyticsReachEarningsChartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos por dia'**
  String get analyticsReachEarningsChartTitle;

  /// No description provided for @analyticsReachLegendEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos USDT'**
  String get analyticsReachLegendEarnings;

  /// No description provided for @analyticsReachLegendFee.
  ///
  /// In pt, this message translates to:
  /// **'Taxa plataforma'**
  String get analyticsReachLegendFee;

  /// No description provided for @analyticsReachTopGiftsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Top Gifts recebidos'**
  String get analyticsReachTopGiftsTitle;

  /// No description provided for @analyticsReachNoGifts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum gift recebido ainda'**
  String get analyticsReachNoGifts;

  /// No description provided for @analyticsReachMonetizationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Monetização total'**
  String get analyticsReachMonetizationTitle;

  /// No description provided for @analyticsReachTotalEarned.
  ///
  /// In pt, this message translates to:
  /// **'Total ganho'**
  String get analyticsReachTotalEarned;

  /// No description provided for @analyticsReachTotalGifts.
  ///
  /// In pt, this message translates to:
  /// **'Gifts totais'**
  String get analyticsReachTotalGifts;

  /// No description provided for @analyticsReachEarningsPerLive.
  ///
  /// In pt, this message translates to:
  /// **'Ganho/live'**
  String get analyticsReachEarningsPerLive;

  /// No description provided for @analyticsDashboardAvgViewers.
  ///
  /// In pt, this message translates to:
  /// **'méd./live'**
  String get analyticsDashboardAvgViewers;

  /// No description provided for @analyticsDashboardSeeGrowth.
  ///
  /// In pt, this message translates to:
  /// **'Ver crescimento'**
  String get analyticsDashboardSeeGrowth;

  /// No description provided for @analyticsDashboardGifts.
  ///
  /// In pt, this message translates to:
  /// **'gifts'**
  String get analyticsDashboardGifts;

  /// No description provided for @analyticsDashboardMinAvg.
  ///
  /// In pt, this message translates to:
  /// **'{min} min méd.'**
  String analyticsDashboardMinAvg(String min);

  /// No description provided for @shopVitrineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vitrine de {name}'**
  String shopVitrineTitle(String name);

  /// No description provided for @shopVitrineSearchTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Buscar na vitrine'**
  String get shopVitrineSearchTooltip;

  /// No description provided for @shopVitrineFilterTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Classificar produtos'**
  String get shopVitrineFilterTooltip;

  /// No description provided for @shopVitrineViewModeTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Mudar visualização'**
  String get shopVitrineViewModeTooltip;

  /// No description provided for @shopVitrineSortTitle.
  ///
  /// In pt, this message translates to:
  /// **'Classificar por'**
  String get shopVitrineSortTitle;

  /// No description provided for @shopVitrineSortCreatorChoice.
  ///
  /// In pt, this message translates to:
  /// **'Escolha do criador'**
  String get shopVitrineSortCreatorChoice;

  /// No description provided for @shopVitrineSortBestSelling.
  ///
  /// In pt, this message translates to:
  /// **'Mais vendidos'**
  String get shopVitrineSortBestSelling;

  /// No description provided for @shopVitrineSortNewest.
  ///
  /// In pt, this message translates to:
  /// **'Novidades'**
  String get shopVitrineSortNewest;

  /// No description provided for @shopVitrineSortPriceAsc.
  ///
  /// In pt, this message translates to:
  /// **'Preço: menor para maior'**
  String get shopVitrineSortPriceAsc;

  /// No description provided for @shopVitrineSortPriceDesc.
  ///
  /// In pt, this message translates to:
  /// **'Preço: maior para menor'**
  String get shopVitrineSortPriceDesc;

  /// No description provided for @shopVitrineSoldOnline.
  ///
  /// In pt, this message translates to:
  /// **'{count} vendidos online'**
  String shopVitrineSoldOnline(String count);

  /// No description provided for @shopVitrineFreeShipping.
  ///
  /// In pt, this message translates to:
  /// **'Frete grátis'**
  String get shopVitrineFreeShipping;

  /// No description provided for @shopProductPageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Produto'**
  String get shopProductPageTitle;

  /// No description provided for @shopProductPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço'**
  String get shopProductPrice;

  /// No description provided for @shopProductOriginalPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço original'**
  String get shopProductOriginalPrice;

  /// No description provided for @shopProductDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get shopProductDiscount;

  /// No description provided for @shopProductAddToCart.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ao carrinho'**
  String get shopProductAddToCart;

  /// No description provided for @shopProductBuyNow.
  ///
  /// In pt, this message translates to:
  /// **'Comprar agora'**
  String get shopProductBuyNow;

  /// No description provided for @shopProductDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get shopProductDescription;

  /// No description provided for @shopProductStore.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get shopProductStore;

  /// No description provided for @shopProductViewStore.
  ///
  /// In pt, this message translates to:
  /// **'Ver loja'**
  String get shopProductViewStore;

  /// No description provided for @shopProductQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get shopProductQuantity;

  /// No description provided for @shopProductRating.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação'**
  String get shopProductRating;

  /// No description provided for @shopProductReviews.
  ///
  /// In pt, this message translates to:
  /// **'avaliações'**
  String get shopProductReviews;

  /// No description provided for @shopProductSold.
  ///
  /// In pt, this message translates to:
  /// **'vendidos'**
  String get shopProductSold;

  /// No description provided for @shopProductOutOfStock.
  ///
  /// In pt, this message translates to:
  /// **'Fora de estoque'**
  String get shopProductOutOfStock;

  /// No description provided for @shopProductNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Produto não encontrado.'**
  String get shopProductNotFound;

  /// No description provided for @shopProductError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o produto.'**
  String get shopProductError;

  /// No description provided for @shopProductAddedToCart.
  ///
  /// In pt, this message translates to:
  /// **'Produto adicionado ao carrinho ✓'**
  String get shopProductAddedToCart;

  /// No description provided for @shopProductAddToCartError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível adicionar ao carrinho.'**
  String get shopProductAddToCartError;

  /// No description provided for @shopProductCartTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Carrinho'**
  String get shopProductCartTooltip;

  /// No description provided for @shopProductSearchTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Buscar produtos'**
  String get shopProductSearchTooltip;

  /// No description provided for @shopProductShareTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get shopProductShareTooltip;

  /// No description provided for @shopProductMoreTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Mais opções'**
  String get shopProductMoreTooltip;

  /// No description provided for @shopProductShareFail.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível compartilhar o produto.'**
  String get shopProductShareFail;

  /// No description provided for @shopProductLinkCopied.
  ///
  /// In pt, this message translates to:
  /// **'Link do produto copiado!'**
  String get shopProductLinkCopied;

  /// No description provided for @shopProductOptionShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar produto'**
  String get shopProductOptionShare;

  /// No description provided for @shopProductOptionCopyLink.
  ///
  /// In pt, this message translates to:
  /// **'Copiar link'**
  String get shopProductOptionCopyLink;

  /// No description provided for @shopProductOptionReport.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar produto'**
  String get shopProductOptionReport;

  /// No description provided for @shopProductReportQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Por que você está denunciando este produto?'**
  String get shopProductReportQuestion;

  /// No description provided for @shopProductReportSent.
  ///
  /// In pt, this message translates to:
  /// **'Denúncia enviada. Obrigado por ajudar a manter a Brawe segura.'**
  String get shopProductReportSent;

  /// No description provided for @shopProductReportError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar a denúncia. Tente novamente.'**
  String get shopProductReportError;

  /// No description provided for @shopProductFooterStore.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get shopProductFooterStore;

  /// No description provided for @shopProductFooterChat.
  ///
  /// In pt, this message translates to:
  /// **'Chat'**
  String get shopProductFooterChat;

  /// No description provided for @shopProductChatComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Chat com a loja em breve.'**
  String get shopProductChatComingSoon;

  /// No description provided for @shopProductTabOverview.
  ///
  /// In pt, this message translates to:
  /// **'Visão geral'**
  String get shopProductTabOverview;

  /// No description provided for @shopProductTabReviews.
  ///
  /// In pt, this message translates to:
  /// **'Avaliações'**
  String get shopProductTabReviews;

  /// No description provided for @shopProductTabDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get shopProductTabDescription;

  /// No description provided for @shopProductTabRecommendations.
  ///
  /// In pt, this message translates to:
  /// **'Recomendações'**
  String get shopProductTabRecommendations;

  /// No description provided for @shopProductReviewsComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Avaliações de produtos em breve.'**
  String get shopProductReviewsComingSoon;

  /// No description provided for @shopProductRecommendationsComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Recomendações de outros produtos em breve.'**
  String get shopProductRecommendationsComingSoon;

  /// No description provided for @shopCartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Carrinho'**
  String get shopCartTitle;

  /// No description provided for @shopCartClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar carrinho'**
  String get shopCartClear;

  /// No description provided for @shopCartClearConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Limpar carrinho?'**
  String get shopCartClearConfirmTitle;

  /// No description provided for @shopCartClearConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Todos os itens serão removidos do seu carrinho.'**
  String get shopCartClearConfirmBody;

  /// No description provided for @shopCartEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu carrinho está vazio'**
  String get shopCartEmptyTitle;

  /// No description provided for @shopCartEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Explore a vitrine e encontre produtos incríveis.'**
  String get shopCartEmptyBody;

  /// No description provided for @shopCartViewShowcase.
  ///
  /// In pt, this message translates to:
  /// **'Ver vitrine'**
  String get shopCartViewShowcase;

  /// No description provided for @shopCartError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o carrinho.'**
  String get shopCartError;

  /// No description provided for @shopCartRemoveItem.
  ///
  /// In pt, this message translates to:
  /// **'Remover item'**
  String get shopCartRemoveItem;

  /// No description provided for @shopCartSubtotal.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal'**
  String get shopCartSubtotal;

  /// No description provided for @shopCartTax.
  ///
  /// In pt, this message translates to:
  /// **'Taxas'**
  String get shopCartTax;

  /// No description provided for @shopCartShipping.
  ///
  /// In pt, this message translates to:
  /// **'Frete'**
  String get shopCartShipping;

  /// No description provided for @shopCartDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get shopCartDiscount;

  /// No description provided for @shopCartTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get shopCartTotal;

  /// No description provided for @shopCartContinueToCheckout.
  ///
  /// In pt, this message translates to:
  /// **'Continuar para checkout'**
  String get shopCartContinueToCheckout;

  /// No description provided for @shopCartUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar o item.'**
  String get shopCartUpdateError;

  /// No description provided for @shopCartRemoveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível remover o item.'**
  String get shopCartRemoveError;

  /// No description provided for @shopCartClearError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível limpar o carrinho.'**
  String get shopCartClearError;

  /// No description provided for @shopCheckoutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar compra'**
  String get shopCheckoutTitle;

  /// No description provided for @shopCheckoutAddressSection.
  ///
  /// In pt, this message translates to:
  /// **'Endereço de entrega'**
  String get shopCheckoutAddressSection;

  /// No description provided for @shopCheckoutAddressEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não tem endereços salvos.'**
  String get shopCheckoutAddressEmpty;

  /// No description provided for @shopCheckoutAddNewAddress.
  ///
  /// In pt, this message translates to:
  /// **'Usar outro endereço'**
  String get shopCheckoutAddNewAddress;

  /// No description provided for @shopCheckoutAddressLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do endereço (ex.: Casa, Trabalho)'**
  String get shopCheckoutAddressLabel;

  /// No description provided for @shopCheckoutAddressStreet.
  ///
  /// In pt, this message translates to:
  /// **'Rua'**
  String get shopCheckoutAddressStreet;

  /// No description provided for @shopCheckoutAddressNumber.
  ///
  /// In pt, this message translates to:
  /// **'Número'**
  String get shopCheckoutAddressNumber;

  /// No description provided for @shopCheckoutAddressComplement.
  ///
  /// In pt, this message translates to:
  /// **'Complemento (opcional)'**
  String get shopCheckoutAddressComplement;

  /// No description provided for @shopCheckoutAddressNeighborhood.
  ///
  /// In pt, this message translates to:
  /// **'Bairro'**
  String get shopCheckoutAddressNeighborhood;

  /// No description provided for @shopCheckoutAddressCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get shopCheckoutAddressCity;

  /// No description provided for @shopCheckoutAddressState.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get shopCheckoutAddressState;

  /// No description provided for @shopCheckoutAddressPostalCode.
  ///
  /// In pt, this message translates to:
  /// **'CEP'**
  String get shopCheckoutAddressPostalCode;

  /// No description provided for @shopCheckoutAddressSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar endereço'**
  String get shopCheckoutAddressSave;

  /// No description provided for @shopCheckoutAddressSaved.
  ///
  /// In pt, this message translates to:
  /// **'Endereço salvo ✓'**
  String get shopCheckoutAddressSaved;

  /// No description provided for @shopCheckoutAddressSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o endereço.'**
  String get shopCheckoutAddressSaveError;

  /// No description provided for @shopCheckoutAddressRequired.
  ///
  /// In pt, this message translates to:
  /// **'Selecione ou cadastre um endereço de entrega.'**
  String get shopCheckoutAddressRequired;

  /// No description provided for @shopCheckoutCustomerSection.
  ///
  /// In pt, this message translates to:
  /// **'Dados do cliente'**
  String get shopCheckoutCustomerSection;

  /// No description provided for @shopCheckoutCustomerName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get shopCheckoutCustomerName;

  /// No description provided for @shopCheckoutCustomerEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get shopCheckoutCustomerEmail;

  /// No description provided for @shopCheckoutCustomerPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone (opcional)'**
  String get shopCheckoutCustomerPhone;

  /// No description provided for @shopCheckoutRecipientSection.
  ///
  /// In pt, this message translates to:
  /// **'Destinatário (para nota fiscal)'**
  String get shopCheckoutRecipientSection;

  /// No description provided for @shopCheckoutRecipientHint.
  ///
  /// In pt, this message translates to:
  /// **'A loja precisa desses dados para emitir a nota fiscal do seu pedido.'**
  String get shopCheckoutRecipientHint;

  /// No description provided for @shopCheckoutRecipientName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo do destinatário'**
  String get shopCheckoutRecipientName;

  /// No description provided for @shopCheckoutDocumentType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get shopCheckoutDocumentType;

  /// No description provided for @shopCheckoutDocumentRequired.
  ///
  /// In pt, this message translates to:
  /// **'CPF/CNPJ é obrigatório para emissão de NF.'**
  String get shopCheckoutDocumentRequired;

  /// No description provided for @shopCheckoutCpfInvalid.
  ///
  /// In pt, this message translates to:
  /// **'CPF deve ter 11 dígitos.'**
  String get shopCheckoutCpfInvalid;

  /// No description provided for @shopCheckoutCnpjInvalid.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ deve ter 14 dígitos.'**
  String get shopCheckoutCnpjInvalid;

  /// No description provided for @shopCheckoutNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu nome completo.'**
  String get shopCheckoutNameRequired;

  /// No description provided for @shopCheckoutEmailRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu e-mail.'**
  String get shopCheckoutEmailRequired;

  /// No description provided for @shopCheckoutEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido.'**
  String get shopCheckoutEmailInvalid;

  /// No description provided for @shopCheckoutShippingSection.
  ///
  /// In pt, this message translates to:
  /// **'Método de envio'**
  String get shopCheckoutShippingSection;

  /// No description provided for @shopCheckoutShippingStandard.
  ///
  /// In pt, this message translates to:
  /// **'Padrão'**
  String get shopCheckoutShippingStandard;

  /// No description provided for @shopCheckoutShippingExpress.
  ///
  /// In pt, this message translates to:
  /// **'Expresso'**
  String get shopCheckoutShippingExpress;

  /// No description provided for @shopCheckoutPaymentSection.
  ///
  /// In pt, this message translates to:
  /// **'Método de pagamento'**
  String get shopCheckoutPaymentSection;

  /// No description provided for @shopCheckoutPaymentPix.
  ///
  /// In pt, this message translates to:
  /// **'PIX'**
  String get shopCheckoutPaymentPix;

  /// No description provided for @shopCheckoutPaymentCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão'**
  String get shopCheckoutPaymentCard;

  /// No description provided for @shopCheckoutPaymentCrypto.
  ///
  /// In pt, this message translates to:
  /// **'Cripto'**
  String get shopCheckoutPaymentCrypto;

  /// No description provided for @shopCheckoutSummarySection.
  ///
  /// In pt, this message translates to:
  /// **'Resumo do pedido'**
  String get shopCheckoutSummarySection;

  /// No description provided for @shopCheckoutSubtotal.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal'**
  String get shopCheckoutSubtotal;

  /// No description provided for @shopCheckoutTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get shopCheckoutTotal;

  /// No description provided for @shopCheckoutConfirmOrder.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar pedido'**
  String get shopCheckoutConfirmOrder;

  /// No description provided for @shopCheckoutError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir o pedido. Tente novamente.'**
  String get shopCheckoutError;

  /// No description provided for @shopCheckoutDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get shopCheckoutDiscount;

  /// No description provided for @shopCheckoutFreeShipping.
  ///
  /// In pt, this message translates to:
  /// **'Grátis'**
  String get shopCheckoutFreeShipping;

  /// No description provided for @shopCheckoutAddNote.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar nota'**
  String get shopCheckoutAddNote;

  /// No description provided for @shopCheckoutTotalItems.
  ///
  /// In pt, this message translates to:
  /// **'Total ({count} {count, plural, =1{item} other{itens}})'**
  String shopCheckoutTotalItems(int count);

  /// No description provided for @shopCheckoutTermsPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Ao concluir o pedido, você concorda com os '**
  String get shopCheckoutTermsPrefix;

  /// No description provided for @shopCheckoutTermsLink.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get shopCheckoutTermsLink;

  /// No description provided for @shopCheckoutTermsAnd.
  ///
  /// In pt, this message translates to:
  /// **' e a '**
  String get shopCheckoutTermsAnd;

  /// No description provided for @shopCheckoutPrivacyLink.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get shopCheckoutPrivacyLink;

  /// No description provided for @shopCheckoutTermsSuffix.
  ///
  /// In pt, this message translates to:
  /// **' da Brawe.'**
  String get shopCheckoutTermsSuffix;

  /// No description provided for @shopPaymentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get shopPaymentTitle;

  /// No description provided for @shopPaymentOrderNumber.
  ///
  /// In pt, this message translates to:
  /// **'Pedido #{number}'**
  String shopPaymentOrderNumber(String number);

  /// No description provided for @shopPaymentTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get shopPaymentTotal;

  /// No description provided for @shopPaymentPixTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pague com PIX'**
  String get shopPaymentPixTitle;

  /// No description provided for @shopPaymentPixInstructions.
  ///
  /// In pt, this message translates to:
  /// **'Escaneie o QR code no app do seu banco para concluir o pagamento.'**
  String get shopPaymentPixInstructions;

  /// No description provided for @shopPaymentAlreadyPaid.
  ///
  /// In pt, this message translates to:
  /// **'Já paguei'**
  String get shopPaymentAlreadyPaid;

  /// No description provided for @shopPaymentCardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento com cartão'**
  String get shopPaymentCardTitle;

  /// No description provided for @shopPaymentCardComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Integração de cartão em breve.'**
  String get shopPaymentCardComingSoon;

  /// No description provided for @shopPaymentCryptoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pague com criptomoeda'**
  String get shopPaymentCryptoTitle;

  /// No description provided for @shopPaymentCryptoComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Endereço de carteira em breve.'**
  String get shopPaymentCryptoComingSoon;

  /// No description provided for @shopPaymentViewOrders.
  ///
  /// In pt, this message translates to:
  /// **'Ver meus pedidos'**
  String get shopPaymentViewOrders;

  /// No description provided for @shopPaymentStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando pagamento'**
  String get shopPaymentStatusPending;

  /// No description provided for @shopPaymentStatusPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento confirmado ✓'**
  String get shopPaymentStatusPaid;

  /// No description provided for @shopPaymentStatusFailed.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento falhou'**
  String get shopPaymentStatusFailed;

  /// No description provided for @shopPaymentError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível verificar o status do pagamento.'**
  String get shopPaymentError;

  /// No description provided for @shopStoreProductsSection.
  ///
  /// In pt, this message translates to:
  /// **'Produtos'**
  String get shopStoreProductsSection;

  /// No description provided for @shopStoreEmptyProducts.
  ///
  /// In pt, this message translates to:
  /// **'Esta loja ainda não tem produtos.'**
  String get shopStoreEmptyProducts;

  /// No description provided for @shopStoreProductsError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os produtos.'**
  String get shopStoreProductsError;

  /// No description provided for @shopStoreError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a loja.'**
  String get shopStoreError;

  /// No description provided for @shopStoreNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Loja não encontrada.'**
  String get shopStoreNotFound;

  /// No description provided for @shopStorePremiumBadge.
  ///
  /// In pt, this message translates to:
  /// **'Premium'**
  String get shopStorePremiumBadge;

  /// No description provided for @shopStoreBravePassBadge.
  ///
  /// In pt, this message translates to:
  /// **'Brawe Pass'**
  String get shopStoreBravePassBadge;

  /// No description provided for @shopStoreRatingCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} avaliações'**
  String shopStoreRatingCount(String count);

  /// No description provided for @shopStoreReadMore.
  ///
  /// In pt, this message translates to:
  /// **'Ver mais'**
  String get shopStoreReadMore;

  /// No description provided for @shopStoreReadLess.
  ///
  /// In pt, this message translates to:
  /// **'Ver menos'**
  String get shopStoreReadLess;

  /// No description provided for @shopStoreChatCta.
  ///
  /// In pt, this message translates to:
  /// **'Falar com a loja'**
  String get shopStoreChatCta;

  /// No description provided for @shopStoreChatUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Esta loja ainda não pode receber mensagens.'**
  String get shopStoreChatUnavailable;

  /// No description provided for @shopStoreChatError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o chat: {error}'**
  String shopStoreChatError(String error);

  /// No description provided for @profileTooltipFindFriends.
  ///
  /// In pt, this message translates to:
  /// **'Encontrar amigos'**
  String get profileTooltipFindFriends;

  /// No description provided for @findFriendsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encontrar amigos'**
  String get findFriendsTitle;

  /// No description provided for @findFriendsMyQrCode.
  ///
  /// In pt, this message translates to:
  /// **'Meu código QR'**
  String get findFriendsMyQrCode;

  /// No description provided for @findFriendsQrHint.
  ///
  /// In pt, this message translates to:
  /// **'Outras pessoas podem escanear este código para ver seu perfil ou fazer login rapidamente'**
  String get findFriendsQrHint;

  /// No description provided for @findFriendsScanButton.
  ///
  /// In pt, this message translates to:
  /// **'Escanear código'**
  String get findFriendsScanButton;

  /// No description provided for @findFriendsSuggestionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões para você'**
  String get findFriendsSuggestionsTitle;

  /// No description provided for @findFriendsSuggestionsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma sugestão por agora'**
  String get findFriendsSuggestionsEmpty;

  /// No description provided for @findFriendsFollowButton.
  ///
  /// In pt, this message translates to:
  /// **'Seguir'**
  String get findFriendsFollowButton;

  /// No description provided for @findFriendsFollowingButton.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get findFriendsFollowingButton;

  /// No description provided for @qrScannerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escanear código QR'**
  String get qrScannerTitle;

  /// No description provided for @qrScannerHint.
  ///
  /// In pt, this message translates to:
  /// **'Aponte a câmera para um QR code do Brawe'**
  String get qrScannerHint;

  /// No description provided for @qrScannerCameraPermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permita o acesso à câmera para escanear códigos QR.'**
  String get qrScannerCameraPermissionDenied;

  /// No description provided for @qrScannerInvalidCode.
  ///
  /// In pt, this message translates to:
  /// **'Este código QR não é válido.'**
  String get qrScannerInvalidCode;

  /// No description provided for @qrScannerLoginApproved.
  ///
  /// In pt, this message translates to:
  /// **'Login aprovado com sucesso!'**
  String get qrScannerLoginApproved;

  /// No description provided for @qrScannerLoginConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar login'**
  String get qrScannerLoginConfirmTitle;

  /// No description provided for @qrScannerLoginConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar login em outro dispositivo usando esta conta?'**
  String get qrScannerLoginConfirmBody;

  /// No description provided for @qrScannerLoginError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível aprovar o login: {error}'**
  String qrScannerLoginError(String error);

  /// No description provided for @actionApprove.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar'**
  String get actionApprove;

  /// No description provided for @questsRewardCollected.
  ///
  /// In pt, this message translates to:
  /// **'Recompensa coletada!'**
  String get questsRewardCollected;

  /// No description provided for @questsXpReceived.
  ///
  /// In pt, this message translates to:
  /// **'{xp} XP recebido'**
  String questsXpReceived(int xp);

  /// No description provided for @questsCoinsReceived.
  ///
  /// In pt, this message translates to:
  /// **'{coins} moedas recebidas'**
  String questsCoinsReceived(int coins);

  /// No description provided for @questsLevelUp.
  ///
  /// In pt, this message translates to:
  /// **'Nível alcançado!'**
  String get questsLevelUp;

  /// No description provided for @questsFailedToClaim.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível coletar a recompensa'**
  String get questsFailedToClaim;

  /// No description provided for @questsAlreadyClaimed.
  ///
  /// In pt, this message translates to:
  /// **'Recompensa já coletada'**
  String get questsAlreadyClaimed;

  /// No description provided for @shareSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get shareSheetTitle;

  /// No description provided for @shareSentBadge.
  ///
  /// In pt, this message translates to:
  /// **'Enviado'**
  String get shareSentBadge;

  /// No description provided for @shareRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get shareRetry;

  /// No description provided for @shareActionStories.
  ///
  /// In pt, this message translates to:
  /// **'Stories'**
  String get shareActionStories;

  /// No description provided for @shareActionRepost.
  ///
  /// In pt, this message translates to:
  /// **'Repostar'**
  String get shareActionRepost;

  /// No description provided for @shareActionCopyLink.
  ///
  /// In pt, this message translates to:
  /// **'Copiar link'**
  String get shareActionCopyLink;

  /// No description provided for @shareActionMore.
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get shareActionMore;

  /// No description provided for @composerToolText.
  ///
  /// In pt, this message translates to:
  /// **'Texto'**
  String get composerToolText;

  /// No description provided for @composerToolMusic.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get composerToolMusic;

  /// No description provided for @composerToolTrim.
  ///
  /// In pt, this message translates to:
  /// **'Cortar'**
  String get composerToolTrim;

  /// No description provided for @composerToolSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get composerToolSave;

  /// No description provided for @composerToolFrame.
  ///
  /// In pt, this message translates to:
  /// **'Moldura'**
  String get composerToolFrame;

  /// No description provided for @composerToolResetZoom.
  ///
  /// In pt, this message translates to:
  /// **'Reajustar'**
  String get composerToolResetZoom;

  /// No description provided for @composerToolBackground.
  ///
  /// In pt, this message translates to:
  /// **'Fundo'**
  String get composerToolBackground;

  /// No description provided for @composerDone.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get composerDone;

  /// No description provided for @composerClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get composerClose;

  /// No description provided for @composerTextAlignTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Alinhamento'**
  String get composerTextAlignTooltip;

  /// No description provided for @composerTextBackgroundTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Fundo do texto'**
  String get composerTextBackgroundTooltip;

  /// No description provided for @composerFontClassic.
  ///
  /// In pt, this message translates to:
  /// **'Clássico'**
  String get composerFontClassic;

  /// No description provided for @composerFontModern.
  ///
  /// In pt, this message translates to:
  /// **'Moderno'**
  String get composerFontModern;

  /// No description provided for @composerFontSerif.
  ///
  /// In pt, this message translates to:
  /// **'Serif'**
  String get composerFontSerif;

  /// No description provided for @composerFontTypewriter.
  ///
  /// In pt, this message translates to:
  /// **'Máquina'**
  String get composerFontTypewriter;

  /// No description provided for @composerFontNeon.
  ///
  /// In pt, this message translates to:
  /// **'Neon'**
  String get composerFontNeon;

  /// No description provided for @composerDiscardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar story?'**
  String get composerDiscardTitle;

  /// No description provided for @composerDiscardMessage.
  ///
  /// In pt, this message translates to:
  /// **'Suas edições serão perdidas.'**
  String get composerDiscardMessage;

  /// No description provided for @composerDiscard.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get composerDiscard;

  /// No description provided for @composerKeepEditing.
  ///
  /// In pt, this message translates to:
  /// **'Continuar editando'**
  String get composerKeepEditing;

  /// No description provided for @composerVolumeMix.
  ///
  /// In pt, this message translates to:
  /// **'Volumes'**
  String get composerVolumeMix;

  /// No description provided for @composerOverlayError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível aplicar o texto ao vídeo.'**
  String get composerOverlayError;

  /// No description provided for @composerModeStory.
  ///
  /// In pt, this message translates to:
  /// **'Story'**
  String get composerModeStory;

  /// No description provided for @composerModeText.
  ///
  /// In pt, this message translates to:
  /// **'Texto'**
  String get composerModeText;

  /// No description provided for @composerFlipCamera.
  ///
  /// In pt, this message translates to:
  /// **'Virar câmera'**
  String get composerFlipCamera;

  /// No description provided for @composerFlash.
  ///
  /// In pt, this message translates to:
  /// **'Flash'**
  String get composerFlash;

  /// No description provided for @composerCameraPermissionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Permita o acesso à câmera'**
  String get composerCameraPermissionTitle;

  /// No description provided for @composerCameraPermissionBody.
  ///
  /// In pt, this message translates to:
  /// **'Para criar stories com foto e vídeo, o Brawe precisa da câmera e do microfone.'**
  String get composerCameraPermissionBody;

  /// No description provided for @composerOpenSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir ajustes'**
  String get composerOpenSettings;

  /// No description provided for @composerNoCamera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera indisponível'**
  String get composerNoCamera;

  /// No description provided for @feedViewsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 visualização} other{{formatted} visualizações}}'**
  String feedViewsCount(int count, String formatted);

  /// No description provided for @feedRepostUndone.
  ///
  /// In pt, this message translates to:
  /// **'Repost desfeito'**
  String get feedRepostUndone;

  /// No description provided for @profileTabReposts.
  ///
  /// In pt, this message translates to:
  /// **'Reposts'**
  String get profileTabReposts;

  /// No description provided for @profileNoReposts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum repost ainda'**
  String get profileNoReposts;

  /// No description provided for @liveEndedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Live encerrada'**
  String get liveEndedTitle;

  /// No description provided for @liveEndedByStreamer.
  ///
  /// In pt, this message translates to:
  /// **'{name} encerrou a live.'**
  String liveEndedByStreamer(String name);

  /// No description provided for @liveEndedAlready.
  ///
  /// In pt, this message translates to:
  /// **'Esta live já foi encerrada por {name}.'**
  String liveEndedAlready(String name);

  /// No description provided for @liveEndedLasted.
  ///
  /// In pt, this message translates to:
  /// **'Durou {duration}'**
  String liveEndedLasted(String duration);

  /// No description provided for @liveEndedFollow.
  ///
  /// In pt, this message translates to:
  /// **'Seguir'**
  String get liveEndedFollow;

  /// No description provided for @liveEndedFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get liveEndedFollowing;

  /// No description provided for @liveEndedFollowHint.
  ///
  /// In pt, this message translates to:
  /// **'Siga para saber quando {name} entrar ao vivo de novo.'**
  String liveEndedFollowHint(String name);

  /// No description provided for @liveEndedNextLive.
  ///
  /// In pt, this message translates to:
  /// **'Próxima live'**
  String get liveEndedNextLive;

  /// No description provided for @liveEndedWatchNow.
  ///
  /// In pt, this message translates to:
  /// **'Assistir'**
  String get liveEndedWatchNow;

  /// No description provided for @liveEndedGoingIn.
  ///
  /// In pt, this message translates to:
  /// **'Indo para a próxima live em {seconds}s'**
  String liveEndedGoingIn(int seconds);

  /// No description provided for @liveEndedStay.
  ///
  /// In pt, this message translates to:
  /// **'Ficar aqui'**
  String get liveEndedStay;

  /// No description provided for @liveEndedNoOther.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma outra live no ar agora.'**
  String get liveEndedNoOther;

  /// No description provided for @liveEndedBackHome.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get liveEndedBackHome;

  /// No description provided for @liveEndedWatching.
  ///
  /// In pt, this message translates to:
  /// **'{count} assistindo'**
  String liveEndedWatching(String count);

  /// No description provided for @livePausedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Volto já'**
  String get livePausedTitle;

  /// No description provided for @livePausedBy.
  ///
  /// In pt, this message translates to:
  /// **'{name} pausou a live'**
  String livePausedBy(String name);

  /// No description provided for @livePausedBackIn.
  ///
  /// In pt, this message translates to:
  /// **'Volta em até {time}'**
  String livePausedBackIn(String time);

  /// No description provided for @livePausedResuming.
  ///
  /// In pt, this message translates to:
  /// **'Voltando…'**
  String get livePausedResuming;

  /// No description provided for @livePausedResumingHint.
  ///
  /// In pt, this message translates to:
  /// **'A transmissão volta em instantes'**
  String get livePausedResumingHint;

  /// No description provided for @broadcasterPausedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Live pausada'**
  String get broadcasterPausedTitle;

  /// No description provided for @broadcasterPausedHint.
  ///
  /// In pt, this message translates to:
  /// **'Câmera e microfone desligados. Seus espectadores veem o aviso de pausa.'**
  String get broadcasterPausedHint;

  /// No description provided for @broadcasterResumeIn.
  ///
  /// In pt, this message translates to:
  /// **'Retome em {time}'**
  String broadcasterResumeIn(String time);

  /// No description provided for @broadcasterResumeButton.
  ///
  /// In pt, this message translates to:
  /// **'Retomar live'**
  String get broadcasterResumeButton;

  /// No description provided for @broadcasterResumingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Voltando ao ar…'**
  String get broadcasterResumingTitle;

  /// No description provided for @broadcasterResumingHint.
  ///
  /// In pt, this message translates to:
  /// **'Seus espectadores voltam a te ver em alguns segundos.'**
  String get broadcasterResumingHint;

  /// No description provided for @broadcasterBackLive.
  ///
  /// In pt, this message translates to:
  /// **'Você está ao vivo'**
  String get broadcasterBackLive;

  /// No description provided for @relHidePosts.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar publicações'**
  String get relHidePosts;

  /// No description provided for @relShowPosts.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar publicações'**
  String get relShowPosts;

  /// No description provided for @relHiddenSnack.
  ///
  /// In pt, this message translates to:
  /// **'Você não verá mais as publicações de {name}.'**
  String relHiddenSnack(String name);

  /// No description provided for @relShownSnack.
  ///
  /// In pt, this message translates to:
  /// **'As publicações de {name} voltaram a aparecer.'**
  String relShownSnack(String name);

  /// No description provided for @relActionError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir. Tente de novo.'**
  String get relActionError;

  /// No description provided for @profileBlockedState.
  ///
  /// In pt, this message translates to:
  /// **'Você bloqueou este usuário'**
  String get profileBlockedState;

  /// No description provided for @profileBlockedStateHint.
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueie para ver o perfil e as publicações.'**
  String get profileBlockedStateHint;

  /// No description provided for @profileUnblock.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear'**
  String get profileUnblock;

  /// No description provided for @profileUnblocked.
  ///
  /// In pt, this message translates to:
  /// **'Usuário desbloqueado.'**
  String get profileUnblocked;

  /// No description provided for @profileUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Perfil indisponível'**
  String get profileUnavailable;

  /// No description provided for @profileUnavailableHint.
  ///
  /// In pt, this message translates to:
  /// **'Este conteúdo não está disponível para você.'**
  String get profileUnavailableHint;

  /// No description provided for @liveOwnTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você está ao vivo'**
  String get liveOwnTitle;

  /// No description provided for @liveOwnBody.
  ///
  /// In pt, this message translates to:
  /// **'Esta é a sua live, transmitida em outro aparelho. Para assistir como espectador, entre com outra conta.'**
  String get liveOwnBody;

  /// No description provided for @liveOwnBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get liveOwnBack;

  /// No description provided for @liveConnecting.
  ///
  /// In pt, this message translates to:
  /// **'Conectando à live…'**
  String get liveConnecting;

  /// No description provided for @rankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Top Presenteadores'**
  String get rankingTitle;

  /// No description provided for @rankingTabLive.
  ///
  /// In pt, this message translates to:
  /// **'Esta live'**
  String get rankingTabLive;

  /// No description provided for @rankingTabWeek.
  ///
  /// In pt, this message translates to:
  /// **'Semana do criador'**
  String get rankingTabWeek;

  /// No description provided for @rankingRoomTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total da live: {points} moedas'**
  String rankingRoomTotal(String points);

  /// No description provided for @rankingEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum presente ainda'**
  String get rankingEmpty;

  /// No description provided for @rankingEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Seja o primeiro a presentear!'**
  String get rankingEmptyHint;

  /// No description provided for @rankingGiftCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 presente} other{{count} presentes}}'**
  String rankingGiftCount(int count);

  /// No description provided for @rankingYouBadge.
  ///
  /// In pt, this message translates to:
  /// **'Você'**
  String get rankingYouBadge;

  /// No description provided for @rankingFooterGap.
  ///
  /// In pt, this message translates to:
  /// **'Você está em #{rank} · faltam {gap} para passar {name}'**
  String rankingFooterGap(int rank, String gap, String name);

  /// No description provided for @rankingFooterLeader.
  ///
  /// In pt, this message translates to:
  /// **'Você está em #1 · lidera o ranking'**
  String get rankingFooterLeader;

  /// No description provided for @rankingFooterOnly.
  ///
  /// In pt, this message translates to:
  /// **'Você está em #{rank}'**
  String rankingFooterOnly(int rank);

  /// No description provided for @rankingFooterJoin.
  ///
  /// In pt, this message translates to:
  /// **'Envie um presente para entrar no ranking'**
  String get rankingFooterJoin;

  /// No description provided for @overtakenMessage.
  ///
  /// In pt, this message translates to:
  /// **'{name} passou você! Faltam {gap} moedas para retomar o #{rank}'**
  String overtakenMessage(String name, String gap, int rank);

  /// No description provided for @overtakenRetake.
  ///
  /// In pt, this message translates to:
  /// **'Retomar'**
  String get overtakenRetake;

  /// No description provided for @newTopGifterBanner.
  ///
  /// In pt, this message translates to:
  /// **'Novo #1 da live: {name}'**
  String newTopGifterBanner(String name);

  /// No description provided for @giftsNeedHint.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {gap} moedas para retomar sua posição'**
  String giftsNeedHint(String gap);

  /// No description provided for @giftsNeedHintNone.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um presente de pelo menos {gap} moedas para retomar sua posição'**
  String giftsNeedHintNone(String gap);

  /// No description provided for @liveEntranceJoined.
  ///
  /// In pt, this message translates to:
  /// **'{name} entrou na live'**
  String liveEntranceJoined(String name);

  /// No description provided for @liveEntranceTopOne.
  ///
  /// In pt, this message translates to:
  /// **'O #1 da live chegou'**
  String get liveEntranceTopOne;

  /// No description provided for @liveLevelUpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Subiu de nível!'**
  String get liveLevelUpTitle;

  /// No description provided for @liveLevelUpLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nível {level}'**
  String liveLevelUpLevel(int level);

  /// No description provided for @liveLevelUpPublic.
  ///
  /// In pt, this message translates to:
  /// **'{name} subiu para o nível {level}'**
  String liveLevelUpPublic(String name, int level);

  /// No description provided for @liveGoalDefaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meta da live'**
  String get liveGoalDefaultTitle;

  /// No description provided for @liveGoalReached.
  ///
  /// In pt, this message translates to:
  /// **'Meta batida!'**
  String get liveGoalReached;

  /// No description provided for @liveGoalOption.
  ///
  /// In pt, this message translates to:
  /// **'Meta da live'**
  String get liveGoalOption;

  /// No description provided for @liveGoalOptionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Defina uma meta de moedas para a live'**
  String get liveGoalOptionSubtitle;

  /// No description provided for @liveGoalSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meta da live'**
  String get liveGoalSheetTitle;

  /// No description provided for @liveGoalPointsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Meta (moedas)'**
  String get liveGoalPointsLabel;

  /// No description provided for @liveGoalTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título curto (ex.: Sorteio de um prêmio)'**
  String get liveGoalTitleLabel;

  /// No description provided for @liveGoalSave.
  ///
  /// In pt, this message translates to:
  /// **'Definir meta'**
  String get liveGoalSave;

  /// No description provided for @liveGoalClear.
  ///
  /// In pt, this message translates to:
  /// **'Remover meta'**
  String get liveGoalClear;

  /// No description provided for @liveGoalSaved.
  ///
  /// In pt, this message translates to:
  /// **'Meta atualizada'**
  String get liveGoalSaved;

  /// No description provided for @liveGoalError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar a meta'**
  String get liveGoalError;

  /// No description provided for @liveGoalInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe uma meta maior que zero'**
  String get liveGoalInvalid;

  /// No description provided for @questLiveTag.
  ///
  /// In pt, this message translates to:
  /// **'NA LIVE'**
  String get questLiveTag;

  /// No description provided for @questWatchLive.
  ///
  /// In pt, this message translates to:
  /// **'Assista lives'**
  String get questWatchLive;

  /// No description provided for @questSendLiveGift.
  ///
  /// In pt, this message translates to:
  /// **'Envie presentes na live'**
  String get questSendLiveGift;

  /// No description provided for @questLiveChat.
  ///
  /// In pt, this message translates to:
  /// **'Converse na live'**
  String get questLiveChat;

  /// No description provided for @rankingSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ranking da live'**
  String get rankingSheetTitle;

  /// No description provided for @rankingTabGifts.
  ///
  /// In pt, this message translates to:
  /// **'Presentes'**
  String get rankingTabGifts;

  /// No description provided for @rankingTabLikes.
  ///
  /// In pt, this message translates to:
  /// **'Curtidas'**
  String get rankingTabLikes;

  /// No description provided for @likesRoomTotal.
  ///
  /// In pt, this message translates to:
  /// **'{likes} curtidas · {people, plural, =1{1 pessoa} other{{people} pessoas}}'**
  String likesRoomTotal(String likes, int people);

  /// No description provided for @likesFooterGap.
  ///
  /// In pt, this message translates to:
  /// **'Você está em #{rank} · faltam {gap} curtidas para passar {name}'**
  String likesFooterGap(int rank, String gap, String name);

  /// No description provided for @likesFooterLeader.
  ///
  /// In pt, this message translates to:
  /// **'Você está em #1 · quem mais curtiu a live'**
  String get likesFooterLeader;

  /// No description provided for @likesFooterOnly.
  ///
  /// In pt, this message translates to:
  /// **'Você está em #{rank}'**
  String likesFooterOnly(int rank);

  /// No description provided for @likesFooterJoin.
  ///
  /// In pt, this message translates to:
  /// **'Curta a live para entrar no ranking'**
  String get likesFooterJoin;

  /// No description provided for @likesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém curtiu ainda'**
  String get likesEmpty;

  /// No description provided for @likesEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Seja o primeiro a curtir!'**
  String get likesEmptyHint;

  /// No description provided for @likesNote.
  ///
  /// In pt, this message translates to:
  /// **'Curtidas não somam no ranking de presentes'**
  String get likesNote;

  /// No description provided for @rankingSendGift.
  ///
  /// In pt, this message translates to:
  /// **'Presentear'**
  String get rankingSendGift;

  /// No description provided for @rankingLikeNow.
  ///
  /// In pt, this message translates to:
  /// **'Curtir'**
  String get rankingLikeNow;

  /// No description provided for @likeMilestoneBanner.
  ///
  /// In pt, this message translates to:
  /// **'A live chegou a {count} curtidas!'**
  String likeMilestoneBanner(String count);

  /// No description provided for @questLiveLike.
  ///
  /// In pt, this message translates to:
  /// **'Curtir lives'**
  String get questLiveLike;

  /// No description provided for @noticeOvertakenTitle.
  ///
  /// In pt, this message translates to:
  /// **'{name} passou você!'**
  String noticeOvertakenTitle(String name);

  /// No description provided for @noticeOvertakenBody.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {gap} moedas para retomar o #{rank}'**
  String noticeOvertakenBody(String gap, int rank);

  /// No description provided for @noticeLevelUpBody.
  ///
  /// In pt, this message translates to:
  /// **'Você chegou ao nível {level}'**
  String noticeLevelUpBody(int level);

  /// No description provided for @noticeNewTopTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo #1 da live'**
  String get noticeNewTopTitle;

  /// No description provided for @goalsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Metas da live'**
  String get goalsTitle;

  /// No description provided for @goalsButton.
  ///
  /// In pt, this message translates to:
  /// **'Metas'**
  String get goalsButton;

  /// No description provided for @goalTypeGift.
  ///
  /// In pt, this message translates to:
  /// **'Presente'**
  String get goalTypeGift;

  /// No description provided for @goalTypeLikes.
  ///
  /// In pt, this message translates to:
  /// **'Curtidas'**
  String get goalTypeLikes;

  /// No description provided for @goalLikesLabel.
  ///
  /// In pt, this message translates to:
  /// **'{count} curtidas'**
  String goalLikesLabel(String count);

  /// No description provided for @goalProgress.
  ///
  /// In pt, this message translates to:
  /// **'{progress} de {target}'**
  String goalProgress(String progress, String target);

  /// No description provided for @goalReached.
  ///
  /// In pt, this message translates to:
  /// **'Meta batida'**
  String get goalReached;

  /// No description provided for @goalReachedChat.
  ///
  /// In pt, this message translates to:
  /// **'Meta batida: {goal}'**
  String goalReachedChat(String goal);

  /// No description provided for @goalSendGift.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get goalSendGift;

  /// No description provided for @goalLike.
  ///
  /// In pt, this message translates to:
  /// **'Curtir'**
  String get goalLike;

  /// No description provided for @goalsViewerHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em Enviar para abrir a sacola já no presente da meta.'**
  String get goalsViewerHint;

  /// No description provided for @goalsEmptyCreator.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um presente e a quantidade, ou uma meta de curtidas. Até 3 metas.'**
  String get goalsEmptyCreator;

  /// No description provided for @goalPickGift.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um presente'**
  String get goalPickGift;

  /// No description provided for @goalAddGift.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar {count} {gift}'**
  String goalAddGift(String count, String gift);

  /// No description provided for @goalAddLikes.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar {count} curtidas'**
  String goalAddLikes(String count);

  /// No description provided for @goalsSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar metas'**
  String get goalsSave;

  /// No description provided for @goalsRemoveAll.
  ///
  /// In pt, this message translates to:
  /// **'Remover metas'**
  String get goalsRemoveAll;

  /// No description provided for @goalsSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar as metas'**
  String get goalsSaveError;

  /// No description provided for @giftTickerText.
  ///
  /// In pt, this message translates to:
  /// **'{sender} enviou {gift} para {streamer}'**
  String giftTickerText(String sender, String gift, String streamer);

  /// No description provided for @videoFullscreen.
  ///
  /// In pt, this message translates to:
  /// **'Tela cheia'**
  String get videoFullscreen;

  /// No description provided for @liveOwnEnd.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar esta live'**
  String get liveOwnEnd;

  /// No description provided for @liveOwnEndConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar a live?'**
  String get liveOwnEndConfirmTitle;

  /// No description provided for @liveOwnEndConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'A live termina para todos, inclusive no outro aparelho.'**
  String get liveOwnEndConfirmBody;

  /// No description provided for @liveOwnEnded.
  ///
  /// In pt, this message translates to:
  /// **'Live encerrada'**
  String get liveOwnEnded;

  /// No description provided for @liveOwnEndError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível encerrar a live'**
  String get liveOwnEndError;

  /// No description provided for @liveWaitingSignal.
  ///
  /// In pt, this message translates to:
  /// **'Sem sinal do criador no momento.\nTentando de novo…'**
  String get liveWaitingSignal;

  /// No description provided for @commentsHintAddMention.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar comentário... use @ para marcar'**
  String get commentsHintAddMention;

  /// No description provided for @commentsMentionFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get commentsMentionFollowing;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'pt':
      return SPt();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
