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
  /// **'Automático'**
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
  /// **' da Brawe.'**
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

  /// No description provided for @liveStoryBattleBadge.
  ///
  /// In pt, this message translates to:
  /// **'BATALHA'**
  String get liveStoryBattleBadge;

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

  /// No description provided for @postAddPoll.
  ///
  /// In pt, this message translates to:
  /// **'Enquete'**
  String get postAddPoll;

  /// No description provided for @postAddLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get postAddLocation;

  /// No description provided for @pollEditorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enquete'**
  String get pollEditorTitle;

  /// No description provided for @pollOptionHint.
  ///
  /// In pt, this message translates to:
  /// **'Opção {n}'**
  String pollOptionHint(int n);

  /// No description provided for @pollAddOption.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar opção'**
  String get pollAddOption;

  /// No description provided for @pollRemoveOption.
  ///
  /// In pt, this message translates to:
  /// **'Remover opção'**
  String get pollRemoveOption;

  /// No description provided for @pollRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover enquete'**
  String get pollRemove;

  /// No description provided for @pollDurationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get pollDurationLabel;

  /// No description provided for @pollDurationDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia} other{{count} dias}}'**
  String pollDurationDays(int count);

  /// No description provided for @pollRulesHint.
  ///
  /// In pt, this message translates to:
  /// **'Todas as opções são obrigatórias: de 2 a 4, até 60 caracteres, sem repetir. O voto não pode ser alterado.'**
  String get pollRulesHint;

  /// No description provided for @pollErrorEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Preencha esta opção'**
  String get pollErrorEmpty;

  /// No description provided for @pollErrorDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Opção repetida'**
  String get pollErrorDuplicate;

  /// No description provided for @pollNeedsQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Escreva a pergunta no texto do post'**
  String get pollNeedsQuestion;

  /// No description provided for @pollBlockedByImage.
  ///
  /// In pt, this message translates to:
  /// **'Enquete e foto não podem ser usadas juntas. Remova a foto para criar uma enquete.'**
  String get pollBlockedByImage;

  /// No description provided for @imageBlockedByPoll.
  ///
  /// In pt, this message translates to:
  /// **'Enquete e foto não podem ser usadas juntas. Remova a enquete para anexar uma foto.'**
  String get imageBlockedByPoll;

  /// No description provided for @pollVotesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 voto} other{{count} votos}}'**
  String pollVotesCount(int count);

  /// No description provided for @pollEndsInDays.
  ///
  /// In pt, this message translates to:
  /// **'termina em {count} d'**
  String pollEndsInDays(int count);

  /// No description provided for @pollEndsInHours.
  ///
  /// In pt, this message translates to:
  /// **'termina em {count} h'**
  String pollEndsInHours(int count);

  /// No description provided for @pollEndsInMinutes.
  ///
  /// In pt, this message translates to:
  /// **'termina em {count} min'**
  String pollEndsInMinutes(int count);

  /// No description provided for @pollEnded.
  ///
  /// In pt, this message translates to:
  /// **'Encerrada'**
  String get pollEnded;

  /// No description provided for @pollVoteToSee.
  ///
  /// In pt, this message translates to:
  /// **'Vote para ver os resultados'**
  String get pollVoteToSee;

  /// No description provided for @pollVoteError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível registrar seu voto. Tente de novo.'**
  String get pollVoteError;

  /// No description provided for @pollAlreadyVoted.
  ///
  /// In pt, this message translates to:
  /// **'Você já votou nesta enquete.'**
  String get pollAlreadyVoted;

  /// No description provided for @pollEndedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Esta enquete já foi encerrada.'**
  String get pollEndedMessage;

  /// No description provided for @pollMyVoteSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Seu voto'**
  String get pollMyVoteSemantics;

  /// No description provided for @postLocationRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover localização'**
  String get postLocationRemove;

  /// No description provided for @postLocationLoading.
  ///
  /// In pt, this message translates to:
  /// **'Obtendo sua cidade...'**
  String get postLocationLoading;

  /// No description provided for @postLocationDenied.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissão de localização. Libere nos Ajustes para marcar sua cidade.'**
  String get postLocationDenied;

  /// No description provided for @postLocationServiceOff.
  ///
  /// In pt, this message translates to:
  /// **'A localização do aparelho está desligada.'**
  String get postLocationServiceOff;

  /// No description provided for @postLocationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível descobrir sua cidade.'**
  String get postLocationFailed;

  /// No description provided for @postLocationOpenSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir Ajustes'**
  String get postLocationOpenSettings;

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
  /// **'Escreva uma legenda…'**
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
  /// **'Fora da Brawe'**
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
  /// **'Confira esta live na Brawe: {title}\n{url}'**
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

  /// No description provided for @battleTopSupporters.
  ///
  /// In pt, this message translates to:
  /// **'Top apoiadores'**
  String get battleTopSupporters;

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

  /// No description provided for @topUpStoreDisclaimerApple.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento seguro pela App Store'**
  String get topUpStoreDisclaimerApple;

  /// No description provided for @topUpStoreDisclaimerGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento seguro pelo Google Play'**
  String get topUpStoreDisclaimerGoogle;

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
  /// **'Gifts (USD)'**
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
  /// **'USD'**
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
  /// **'Ganhos (USD)'**
  String get analyticsReachKpiEarnings;

  /// No description provided for @analyticsReachEarningsChartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos por dia'**
  String get analyticsReachEarningsChartTitle;

  /// No description provided for @analyticsReachLegendEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos USD'**
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
  /// **'Aponte a câmera para um QR code da Brawe'**
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
  /// **'Para criar stories com foto e vídeo, a Brawe precisa da câmera e do microfone.'**
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
  /// **'Obrigado por assistir!'**
  String liveEndedByStreamer(String name);

  /// No description provided for @liveEndedAlready.
  ///
  /// In pt, this message translates to:
  /// **'Você chegou depois que ela terminou.'**
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

  /// No description provided for @eventChipEndsIn.
  ///
  /// In pt, this message translates to:
  /// **'termina em {time}'**
  String eventChipEndsIn(String time);

  /// No description provided for @rankingTabEvent.
  ///
  /// In pt, this message translates to:
  /// **'Evento'**
  String get rankingTabEvent;

  /// No description provided for @rankingPrizeFirst.
  ///
  /// In pt, this message translates to:
  /// **'Prêmio do 1º lugar: {prize}'**
  String rankingPrizeFirst(String prize);

  /// No description provided for @awardGrantedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você ganhou um prêmio!'**
  String get awardGrantedTitle;

  /// No description provided for @profileAwardsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Prêmios'**
  String get profileAwardsTitle;

  /// No description provided for @profileAwardUntil.
  ///
  /// In pt, this message translates to:
  /// **'até {date}'**
  String profileAwardUntil(String date);

  /// No description provided for @chatErrorNotSent.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem não enviada'**
  String get chatErrorNotSent;

  /// No description provided for @chatErrorLink.
  ///
  /// In pt, this message translates to:
  /// **'Links não são permitidos no chat'**
  String get chatErrorLink;

  /// No description provided for @chatErrorPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefones não são permitidos no chat'**
  String get chatErrorPhone;

  /// No description provided for @chatErrorMutedUntil.
  ///
  /// In pt, this message translates to:
  /// **'Você foi silenciado até {time}'**
  String chatErrorMutedUntil(String time);

  /// No description provided for @chatErrorMutedLiveEnd.
  ///
  /// In pt, this message translates to:
  /// **'Você foi silenciado até o fim da live'**
  String get chatErrorMutedLiveEnd;

  /// No description provided for @chatErrorSlowWait.
  ///
  /// In pt, this message translates to:
  /// **'Modo lento: aguarde {seconds} s'**
  String chatErrorSlowWait(int seconds);

  /// No description provided for @chatErrorSlowGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Modo lento: aguarde um instante'**
  String get chatErrorSlowGeneric;

  /// No description provided for @chatSlowModeHint.
  ///
  /// In pt, this message translates to:
  /// **'Modo lento: {seconds} s'**
  String chatSlowModeHint(int seconds);

  /// No description provided for @chatPinnedUnpin.
  ///
  /// In pt, this message translates to:
  /// **'Desafixar'**
  String get chatPinnedUnpin;

  /// No description provided for @chatModeratorBadge.
  ///
  /// In pt, this message translates to:
  /// **'Moderador'**
  String get chatModeratorBadge;

  /// No description provided for @modMute5.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar 5 min'**
  String get modMute5;

  /// No description provided for @modMute60.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar 1 h'**
  String get modMute60;

  /// No description provided for @modMuteRest.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar até o fim da live'**
  String get modMuteRest;

  /// No description provided for @modPinMessage.
  ///
  /// In pt, this message translates to:
  /// **'Fixar mensagem'**
  String get modPinMessage;

  /// No description provided for @modMakeModerator.
  ///
  /// In pt, this message translates to:
  /// **'Tornar moderador'**
  String get modMakeModerator;

  /// No description provided for @modRemoveModerator.
  ///
  /// In pt, this message translates to:
  /// **'Remover moderador'**
  String get modRemoveModerator;

  /// No description provided for @modMutedToast.
  ///
  /// In pt, this message translates to:
  /// **'{name} foi silenciado'**
  String modMutedToast(String name);

  /// No description provided for @modPinnedToast.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem fixada'**
  String get modPinnedToast;

  /// No description provided for @modUnpinnedToast.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem desafixada'**
  String get modUnpinnedToast;

  /// No description provided for @modMadeModeratorToast.
  ///
  /// In pt, this message translates to:
  /// **'{name} agora é moderador'**
  String modMadeModeratorToast(String name);

  /// No description provided for @modRemovedModeratorToast.
  ///
  /// In pt, this message translates to:
  /// **'{name} não é mais moderador'**
  String modRemovedModeratorToast(String name);

  /// No description provided for @modActionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a ação'**
  String get modActionFailed;

  /// No description provided for @modNotAllowed.
  ///
  /// In pt, this message translates to:
  /// **'Você não tem permissão para isso'**
  String get modNotAllowed;

  /// No description provided for @modModeratorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Moderadores'**
  String get modModeratorsTitle;

  /// No description provided for @modModeratorsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem ajuda a cuidar do chat da sua live'**
  String get modModeratorsSubtitle;

  /// No description provided for @modModeratorsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não tem moderadores. Toque no nome de alguém no chat para promovê-lo.'**
  String get modModeratorsEmpty;

  /// No description provided for @modModeratorsLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os moderadores'**
  String get modModeratorsLoadFailed;

  /// No description provided for @modRemoveConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get modRemoveConfirm;

  /// No description provided for @battleDurationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get battleDurationLabel;

  /// No description provided for @battleDurationMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{minutes} min'**
  String battleDurationMinutes(int minutes);

  /// No description provided for @battleDurationSeconds.
  ///
  /// In pt, this message translates to:
  /// **'{seconds} s'**
  String battleDurationSeconds(int seconds);

  /// No description provided for @questFrequencyWeekly.
  ///
  /// In pt, this message translates to:
  /// **'Semanal'**
  String get questFrequencyWeekly;

  /// No description provided for @questFrequencyEvent.
  ///
  /// In pt, this message translates to:
  /// **'Evento'**
  String get questFrequencyEvent;

  /// No description provided for @questFrequencyDaily.
  ///
  /// In pt, this message translates to:
  /// **'Diária'**
  String get questFrequencyDaily;

  /// No description provided for @reportReasonChildSafety.
  ///
  /// In pt, this message translates to:
  /// **'Abuso ou exploração de menores'**
  String get reportReasonChildSafety;

  /// No description provided for @reportChildSafetyNote.
  ///
  /// In pt, this message translates to:
  /// **'Se uma criança estiver em perigo imediato, procure as autoridades (no Brasil: Disque 100 ou 190).'**
  String get reportChildSafetyNote;

  /// No description provided for @liveReport.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar live'**
  String get liveReport;

  /// No description provided for @settingsSendFeedback.
  ///
  /// In pt, this message translates to:
  /// **'Enviar feedback'**
  String get settingsSendFeedback;

  /// No description provided for @settingsChildSafety.
  ///
  /// In pt, this message translates to:
  /// **'Normas de Segurança Infantil'**
  String get settingsChildSafety;

  /// No description provided for @feedbackIntro.
  ///
  /// In pt, this message translates to:
  /// **'Conte o que aconteceu. Sua mensagem vai direto para a nossa equipe, sem sair do app.'**
  String get feedbackIntro;

  /// No description provided for @feedbackTypeBug.
  ///
  /// In pt, this message translates to:
  /// **'Problema no app'**
  String get feedbackTypeBug;

  /// No description provided for @feedbackTypeSuggestion.
  ///
  /// In pt, this message translates to:
  /// **'Sugestão'**
  String get feedbackTypeSuggestion;

  /// No description provided for @feedbackTypeChildSafety.
  ///
  /// In pt, this message translates to:
  /// **'Segurança infantil'**
  String get feedbackTypeChildSafety;

  /// No description provided for @feedbackHint.
  ///
  /// In pt, this message translates to:
  /// **'Descreva aqui…'**
  String get feedbackHint;

  /// No description provided for @feedbackSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get feedbackSend;

  /// No description provided for @feedbackSent.
  ///
  /// In pt, this message translates to:
  /// **'Feedback enviado. Obrigado!'**
  String get feedbackSent;

  /// No description provided for @feedbackError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar. Tente novamente.'**
  String get feedbackError;

  /// No description provided for @feedbackTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Escreva pelo menos 10 caracteres.'**
  String get feedbackTooShort;

  /// No description provided for @suspendedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta suspensa'**
  String get suspendedTitle;

  /// No description provided for @suspendedBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta no Brawe Connect foi suspensa por violar as nossas Diretrizes da Comunidade.'**
  String get suspendedBody;

  /// No description provided for @suspendedReasonLabel.
  ///
  /// In pt, this message translates to:
  /// **'Motivo'**
  String get suspendedReasonLabel;

  /// No description provided for @suspendedUntil.
  ///
  /// In pt, this message translates to:
  /// **'A suspensão termina em {date}.'**
  String suspendedUntil(String date);

  /// No description provided for @suspendedPermanent.
  ///
  /// In pt, this message translates to:
  /// **'Esta suspensão é permanente.'**
  String get suspendedPermanent;

  /// No description provided for @suspendedAppeal.
  ///
  /// In pt, this message translates to:
  /// **'Se você acredita que foi um engano, fale com o nosso suporte.'**
  String get suspendedAppeal;

  /// No description provided for @suspendedContact.
  ///
  /// In pt, this message translates to:
  /// **'Falar com o suporte'**
  String get suspendedContact;

  /// No description provided for @suspendedRetry.
  ///
  /// In pt, this message translates to:
  /// **'Verificar novamente'**
  String get suspendedRetry;

  /// No description provided for @suspendedStillActive.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta continua suspensa.'**
  String get suspendedStillActive;

  /// No description provided for @questsTabMissions.
  ///
  /// In pt, this message translates to:
  /// **'Missões'**
  String get questsTabMissions;

  /// No description provided for @questsTabAchievements.
  ///
  /// In pt, this message translates to:
  /// **'Conquistas'**
  String get questsTabAchievements;

  /// No description provided for @questsTabJourney.
  ///
  /// In pt, this message translates to:
  /// **'Jornada'**
  String get questsTabJourney;

  /// No description provided for @questsResetsIn.
  ///
  /// In pt, this message translates to:
  /// **'Novas missões em {time}'**
  String questsResetsIn(String time);

  /// No description provided for @questsDayProgress.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} concluídas'**
  String questsDayProgress(int done, int total);

  /// No description provided for @questsSectionDaily.
  ///
  /// In pt, this message translates to:
  /// **'Missões diárias'**
  String get questsSectionDaily;

  /// No description provided for @questsSectionWeekly.
  ///
  /// In pt, this message translates to:
  /// **'Missões da semana'**
  String get questsSectionWeekly;

  /// No description provided for @questsSectionEvent.
  ///
  /// In pt, this message translates to:
  /// **'Missões de evento'**
  String get questsSectionEvent;

  /// No description provided for @questsAllDoneMascot.
  ///
  /// In pt, this message translates to:
  /// **'Você completou todas as missões de hoje! Volte amanhã para manter a sequência.'**
  String get questsAllDoneMascot;

  /// No description provided for @questsStreakMascot.
  ///
  /// In pt, this message translates to:
  /// **'Sequência de {days} dias! Continue assim!'**
  String questsStreakMascot(int days);

  /// No description provided for @questsStartMascot.
  ///
  /// In pt, this message translates to:
  /// **'Complete todas as missões de hoje para começar uma sequência e ganhar emblemas.'**
  String get questsStartMascot;

  /// No description provided for @questsNextBadge.
  ///
  /// In pt, this message translates to:
  /// **'Próximo emblema em {days} dias'**
  String questsNextBadge(int days);

  /// No description provided for @questsStreakBonus.
  ///
  /// In pt, this message translates to:
  /// **'Bônus de sequência {label}'**
  String questsStreakBonus(String label);

  /// No description provided for @questsLevelUpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Subiu de nível!'**
  String get questsLevelUpTitle;

  /// No description provided for @questsLevelUpBody.
  ///
  /// In pt, this message translates to:
  /// **'Você chegou ao nível {level}'**
  String questsLevelUpBody(int level);

  /// No description provided for @questsBadgeUnlockedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Emblema desbloqueado!'**
  String get questsBadgeUnlockedTitle;

  /// No description provided for @questsContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get questsContinue;

  /// No description provided for @questsStatsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus números'**
  String get questsStatsTitle;

  /// No description provided for @questsStatQuests.
  ///
  /// In pt, this message translates to:
  /// **'Missões concluídas'**
  String get questsStatQuests;

  /// No description provided for @questsStatXp.
  ///
  /// In pt, this message translates to:
  /// **'XP total'**
  String get questsStatXp;

  /// No description provided for @questsStatCoins.
  ///
  /// In pt, this message translates to:
  /// **'Moedas ganhas'**
  String get questsStatCoins;

  /// No description provided for @questsStatBestStreak.
  ///
  /// In pt, this message translates to:
  /// **'Maior sequência'**
  String get questsStatBestStreak;

  /// No description provided for @questsBadgesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Emblemas'**
  String get questsBadgesTitle;

  /// No description provided for @questsBadgesCount.
  ///
  /// In pt, this message translates to:
  /// **'{unlocked} de {total}'**
  String questsBadgesCount(int unlocked, int total);

  /// No description provided for @questsBadgeLocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueado'**
  String get questsBadgeLocked;

  /// No description provided for @questsBadgeEarned.
  ///
  /// In pt, this message translates to:
  /// **'Conquistado'**
  String get questsBadgeEarned;

  /// No description provided for @questsBadgeEarnedOn.
  ///
  /// In pt, this message translates to:
  /// **'Conquistado em {date}'**
  String questsBadgeEarnedOn(String date);

  /// No description provided for @questsBadgeRequirement.
  ///
  /// In pt, this message translates to:
  /// **'Complete todas as missões do dia por {days} dias seguidos.'**
  String questsBadgeRequirement(int days);

  /// No description provided for @questsBadgeProgress.
  ///
  /// In pt, this message translates to:
  /// **'{current} de {target} dias'**
  String questsBadgeProgress(int current, int target);

  /// No description provided for @questBadgeStreak3.
  ///
  /// In pt, this message translates to:
  /// **'Iniciante Dedicado'**
  String get questBadgeStreak3;

  /// No description provided for @questBadgeStreak7.
  ///
  /// In pt, this message translates to:
  /// **'Guerreiro Semanal'**
  String get questBadgeStreak7;

  /// No description provided for @questBadgeStreak14.
  ///
  /// In pt, this message translates to:
  /// **'Veterano'**
  String get questBadgeStreak14;

  /// No description provided for @questBadgeStreak30.
  ///
  /// In pt, this message translates to:
  /// **'Lenda do Mês'**
  String get questBadgeStreak30;

  /// No description provided for @questBadgeStreak60.
  ///
  /// In pt, this message translates to:
  /// **'Mestre da Consistência'**
  String get questBadgeStreak60;

  /// No description provided for @questBadgeStreak100.
  ///
  /// In pt, this message translates to:
  /// **'Ícone Brawe'**
  String get questBadgeStreak100;

  /// No description provided for @questsAwardsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Prêmios recebidos'**
  String get questsAwardsTitle;

  /// No description provided for @questsAwardsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não recebeu prêmios. Participe de lives, eventos e batalhas para ganhar.'**
  String get questsAwardsEmpty;

  /// No description provided for @questsAwardActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get questsAwardActive;

  /// No description provided for @questsAwardExpired.
  ///
  /// In pt, this message translates to:
  /// **'Expirado'**
  String get questsAwardExpired;

  /// No description provided for @questsAwardRevoked.
  ///
  /// In pt, this message translates to:
  /// **'Revogado'**
  String get questsAwardRevoked;

  /// No description provided for @questsAwardScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get questsAwardScheduled;

  /// No description provided for @questsAwardValidUntil.
  ///
  /// In pt, this message translates to:
  /// **'Válido até {date}'**
  String questsAwardValidUntil(String date);

  /// No description provided for @questsAwardEndedOn.
  ///
  /// In pt, this message translates to:
  /// **'Encerrado em {date}'**
  String questsAwardEndedOn(String date);

  /// No description provided for @questsAwardStartsOn.
  ///
  /// In pt, this message translates to:
  /// **'Começa em {date}'**
  String questsAwardStartsOn(String date);

  /// No description provided for @questsAwardSourceEvent.
  ///
  /// In pt, this message translates to:
  /// **'Evento'**
  String get questsAwardSourceEvent;

  /// No description provided for @questsAwardSourceCreatorWeek.
  ///
  /// In pt, this message translates to:
  /// **'Semana do criador'**
  String get questsAwardSourceCreatorWeek;

  /// No description provided for @questsAwardSourceLive.
  ///
  /// In pt, this message translates to:
  /// **'Live'**
  String get questsAwardSourceLive;

  /// No description provided for @questsAwardSourceBattle.
  ///
  /// In pt, this message translates to:
  /// **'Batalha'**
  String get questsAwardSourceBattle;

  /// No description provided for @questsAwardRank.
  ///
  /// In pt, this message translates to:
  /// **'{rank}º lugar'**
  String questsAwardRank(int rank);

  /// No description provided for @questsAwardCoins.
  ///
  /// In pt, this message translates to:
  /// **'+{coins} moedas'**
  String questsAwardCoins(int coins);

  /// No description provided for @questsAwardFrame.
  ///
  /// In pt, this message translates to:
  /// **'Moldura'**
  String get questsAwardFrame;

  /// No description provided for @questsAwardEntry.
  ///
  /// In pt, this message translates to:
  /// **'Entrada especial'**
  String get questsAwardEntry;

  /// No description provided for @questsTimelineEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sua jornada começa agora. Conclua missões para ver suas conquistas aqui.'**
  String get questsTimelineEmpty;

  /// No description provided for @questsTimelineToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get questsTimelineToday;

  /// No description provided for @questsTimelineYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get questsTimelineYesterday;

  /// No description provided for @questsTimelineQuest.
  ///
  /// In pt, this message translates to:
  /// **'Missão concluída'**
  String get questsTimelineQuest;

  /// No description provided for @questsTimelineAward.
  ///
  /// In pt, this message translates to:
  /// **'Prêmio recebido'**
  String get questsTimelineAward;

  /// No description provided for @questsTimelineBadge.
  ///
  /// In pt, this message translates to:
  /// **'Emblema conquistado'**
  String get questsTimelineBadge;

  /// No description provided for @questsTimelineLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nível {level} alcançado'**
  String questsTimelineLevel(int level);

  /// No description provided for @questsJourneyError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar sua jornada.'**
  String get questsJourneyError;

  /// No description provided for @questsLevelShort.
  ///
  /// In pt, this message translates to:
  /// **'Nv. {level}'**
  String questsLevelShort(int level);

  /// No description provided for @findFriendsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por nome ou @usuário'**
  String get findFriendsSearchHint;

  /// No description provided for @findFriendsSearchNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma pessoa encontrada para \"{query}\"'**
  String findFriendsSearchNoResults(String query);

  /// No description provided for @findFriendsSearchError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível buscar agora. Verifique sua conexão.'**
  String get findFriendsSearchError;

  /// No description provided for @findFriendsSuggestionsError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as sugestões.'**
  String get findFriendsSuggestionsError;

  /// No description provided for @findFriendsRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get findFriendsRetry;

  /// No description provided for @creatorGuideTitle.
  ///
  /// In pt, this message translates to:
  /// **'Guia do Criador'**
  String get creatorGuideTitle;

  /// No description provided for @creatorGuideIntro.
  ///
  /// In pt, this message translates to:
  /// **'Tudo o que você precisa saber para crescer na Brawe.'**
  String get creatorGuideIntro;

  /// No description provided for @creatorGuideToc.
  ///
  /// In pt, this message translates to:
  /// **'Sumário'**
  String get creatorGuideToc;

  /// No description provided for @creatorGuideSecWhat.
  ///
  /// In pt, this message translates to:
  /// **'O que é'**
  String get creatorGuideSecWhat;

  /// No description provided for @creatorGuideSecBenefits.
  ///
  /// In pt, this message translates to:
  /// **'Benefícios'**
  String get creatorGuideSecBenefits;

  /// No description provided for @creatorGuideSecLevels.
  ///
  /// In pt, this message translates to:
  /// **'Níveis'**
  String get creatorGuideSecLevels;

  /// No description provided for @creatorGuideSecHow.
  ///
  /// In pt, this message translates to:
  /// **'Como entrar'**
  String get creatorGuideSecHow;

  /// No description provided for @creatorGuideSecRules.
  ///
  /// In pt, this message translates to:
  /// **'Diretrizes'**
  String get creatorGuideSecRules;

  /// No description provided for @creatorGuideSecFaq.
  ///
  /// In pt, this message translates to:
  /// **'Perguntas frequentes'**
  String get creatorGuideSecFaq;

  /// No description provided for @creatorGuideWhatBody.
  ///
  /// In pt, this message translates to:
  /// **'Programa oficial da Brawe para quem cria conteúdo e quer crescer, ser descoberto e construir comunidade.'**
  String get creatorGuideWhatBody;

  /// No description provided for @creatorGuideWhatPoint1.
  ///
  /// In pt, this message translates to:
  /// **'Gratuito para se inscrever'**
  String get creatorGuideWhatPoint1;

  /// No description provided for @creatorGuideWhatPoint2.
  ///
  /// In pt, this message translates to:
  /// **'Análise feita por pessoas'**
  String get creatorGuideWhatPoint2;

  /// No description provided for @creatorGuideWhatPoint3.
  ///
  /// In pt, this message translates to:
  /// **'Cresça por níveis'**
  String get creatorGuideWhatPoint3;

  /// No description provided for @creatorGuideHowStep1.
  ///
  /// In pt, this message translates to:
  /// **'Preencha a inscrição'**
  String get creatorGuideHowStep1;

  /// No description provided for @creatorGuideHowStep2.
  ///
  /// In pt, this message translates to:
  /// **'Nossa equipe analisa seu perfil'**
  String get creatorGuideHowStep2;

  /// No description provided for @creatorGuideHowStep3.
  ///
  /// In pt, this message translates to:
  /// **'Você recebe a resposta no app'**
  String get creatorGuideHowStep3;

  /// No description provided for @creatorGuideHowStep4.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado, ative seu perfil de creator'**
  String get creatorGuideHowStep4;

  /// No description provided for @creatorGuideRule1.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo original ou com créditos'**
  String get creatorGuideRule1;

  /// No description provided for @creatorGuideRule2.
  ///
  /// In pt, this message translates to:
  /// **'Respeito à comunidade, sem ódio ou assédio'**
  String get creatorGuideRule2;

  /// No description provided for @creatorGuideRule3.
  ///
  /// In pt, this message translates to:
  /// **'Nada de seguidores falsos ou compra de engajamento'**
  String get creatorGuideRule3;

  /// No description provided for @creatorGuideRule4.
  ///
  /// In pt, this message translates to:
  /// **'Segurança de menores sempre em primeiro lugar'**
  String get creatorGuideRule4;

  /// No description provided for @creatorGuideRule5.
  ///
  /// In pt, this message translates to:
  /// **'Siga os Termos e a Política de Privacidade'**
  String get creatorGuideRule5;

  /// No description provided for @creatorGuideFaq1Q.
  ///
  /// In pt, this message translates to:
  /// **'Quanto custa participar?'**
  String get creatorGuideFaq1Q;

  /// No description provided for @creatorGuideFaq1A.
  ///
  /// In pt, this message translates to:
  /// **'Nada. A inscrição e a participação na rede são gratuitas.'**
  String get creatorGuideFaq1A;

  /// No description provided for @creatorGuideFaq2Q.
  ///
  /// In pt, this message translates to:
  /// **'Quanto tempo leva a análise?'**
  String get creatorGuideFaq2Q;

  /// No description provided for @creatorGuideFaq2A.
  ///
  /// In pt, this message translates to:
  /// **'Avisamos você assim que houver novidade. Acompanhe o status no app.'**
  String get creatorGuideFaq2A;

  /// No description provided for @creatorGuideFaq3Q.
  ///
  /// In pt, this message translates to:
  /// **'Preciso de muitos seguidores?'**
  String get creatorGuideFaq3Q;

  /// No description provided for @creatorGuideFaq3A.
  ///
  /// In pt, this message translates to:
  /// **'Não. Avaliamos consistência, qualidade e potencial, não só números.'**
  String get creatorGuideFaq3A;

  /// No description provided for @creatorGuideFaq4Q.
  ///
  /// In pt, this message translates to:
  /// **'Posso me inscrever de novo se for recusado?'**
  String get creatorGuideFaq4Q;

  /// No description provided for @creatorGuideFaq4A.
  ///
  /// In pt, this message translates to:
  /// **'Sim. Melhore seu perfil e envie uma nova inscrição depois.'**
  String get creatorGuideFaq4A;

  /// No description provided for @creatorGuideCtaTerms.
  ///
  /// In pt, this message translates to:
  /// **'Ler os termos'**
  String get creatorGuideCtaTerms;

  /// No description provided for @creatorApplyTypeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de criador'**
  String get creatorApplyTypeTitle;

  /// No description provided for @creatorApplyTypeHint.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o que melhor descreve seu conteúdo.'**
  String get creatorApplyTypeHint;

  /// No description provided for @creatorApplyNicheLifestyle.
  ///
  /// In pt, this message translates to:
  /// **'Lifestyle'**
  String get creatorApplyNicheLifestyle;

  /// No description provided for @creatorApplyNicheGames.
  ///
  /// In pt, this message translates to:
  /// **'Games'**
  String get creatorApplyNicheGames;

  /// No description provided for @creatorApplyNicheMusic.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get creatorApplyNicheMusic;

  /// No description provided for @creatorApplyNicheFashion.
  ///
  /// In pt, this message translates to:
  /// **'Moda'**
  String get creatorApplyNicheFashion;

  /// No description provided for @creatorApplyNicheBeauty.
  ///
  /// In pt, this message translates to:
  /// **'Beleza'**
  String get creatorApplyNicheBeauty;

  /// No description provided for @creatorApplyNicheFitness.
  ///
  /// In pt, this message translates to:
  /// **'Fitness'**
  String get creatorApplyNicheFitness;

  /// No description provided for @creatorApplyNicheComedy.
  ///
  /// In pt, this message translates to:
  /// **'Comédia'**
  String get creatorApplyNicheComedy;

  /// No description provided for @creatorApplyNicheBusiness.
  ///
  /// In pt, this message translates to:
  /// **'Negócios'**
  String get creatorApplyNicheBusiness;

  /// No description provided for @creatorApplyNicheTech.
  ///
  /// In pt, this message translates to:
  /// **'Tecnologia'**
  String get creatorApplyNicheTech;

  /// No description provided for @creatorApplyNicheEducation.
  ///
  /// In pt, this message translates to:
  /// **'Educação'**
  String get creatorApplyNicheEducation;

  /// No description provided for @creatorApplyNicheTravel.
  ///
  /// In pt, this message translates to:
  /// **'Viagens'**
  String get creatorApplyNicheTravel;

  /// No description provided for @creatorApplyNicheEntertainment.
  ///
  /// In pt, this message translates to:
  /// **'Entretenimento'**
  String get creatorApplyNicheEntertainment;

  /// No description provided for @creatorApplyNicheSports.
  ///
  /// In pt, this message translates to:
  /// **'Esportes'**
  String get creatorApplyNicheSports;

  /// No description provided for @creatorApplyNicheCooking.
  ///
  /// In pt, this message translates to:
  /// **'Culinária'**
  String get creatorApplyNicheCooking;

  /// No description provided for @creatorApplyNicheOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get creatorApplyNicheOther;

  /// No description provided for @creatorApplyTermsAnd.
  ///
  /// In pt, this message translates to:
  /// **' e a '**
  String get creatorApplyTermsAnd;

  /// No description provided for @creatorApplyTermsUse.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get creatorApplyTermsUse;

  /// No description provided for @creatorApplyAcceptButton.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito'**
  String get creatorApplyAcceptButton;

  /// No description provided for @creatorApplyErrUsername.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de 2 caracteres'**
  String get creatorApplyErrUsername;

  /// No description provided for @creatorApplyErrName.
  ///
  /// In pt, this message translates to:
  /// **'Informe nome e sobrenome'**
  String get creatorApplyErrName;

  /// No description provided for @creatorApplyErrUrl.
  ///
  /// In pt, this message translates to:
  /// **'Informe um link válido (https://...)'**
  String get creatorApplyErrUrl;

  /// No description provided for @creatorApplyErrCountry.
  ///
  /// In pt, this message translates to:
  /// **'Selecione seu país'**
  String get creatorApplyErrCountry;

  /// No description provided for @creatorApplyErrPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone inválido'**
  String get creatorApplyErrPhone;

  /// No description provided for @creatorApplyErrFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Informe um número válido'**
  String get creatorApplyErrFollowers;

  /// No description provided for @creatorApplyErrNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Verifique sua internet e tente novamente.'**
  String get creatorApplyErrNetwork;

  /// No description provided for @creatorApplyErrServer.
  ///
  /// In pt, this message translates to:
  /// **'Servidor indisponível no momento. Tente novamente em instantes.'**
  String get creatorApplyErrServer;

  /// No description provided for @creatorApplyErrSession.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão expirou. Entre novamente para se inscrever.'**
  String get creatorApplyErrSession;

  /// No description provided for @creatorApplyErrFields.
  ///
  /// In pt, this message translates to:
  /// **'Alguns dados não foram aceitos. Revise o formulário: {fields}.'**
  String creatorApplyErrFields(String fields);

  /// No description provided for @creatorApplyOptional.
  ///
  /// In pt, this message translates to:
  /// **'opcional'**
  String get creatorApplyOptional;

  /// No description provided for @creatorApplyInstagramHint.
  ///
  /// In pt, this message translates to:
  /// **'usuario (sem @)'**
  String get creatorApplyInstagramHint;

  /// No description provided for @creatorApplyCategoryHint.
  ///
  /// In pt, this message translates to:
  /// **'Opcional: o nível que você pretende alcançar.'**
  String get creatorApplyCategoryHint;

  /// No description provided for @rewardsTabReceived.
  ///
  /// In pt, this message translates to:
  /// **'Recebidos'**
  String get rewardsTabReceived;

  /// No description provided for @rewardsTabSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviados'**
  String get rewardsTabSent;

  /// No description provided for @rewardsPeriodToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get rewardsPeriodToday;

  /// No description provided for @rewardsPeriod7d.
  ///
  /// In pt, this message translates to:
  /// **'7 dias'**
  String get rewardsPeriod7d;

  /// No description provided for @rewardsPeriod30d.
  ///
  /// In pt, this message translates to:
  /// **'30 dias'**
  String get rewardsPeriod30d;

  /// No description provided for @rewardsPeriodAll.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get rewardsPeriodAll;

  /// No description provided for @rewardsHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de presentes'**
  String get rewardsHistoryTitle;

  /// No description provided for @rewardsHistorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Presentes que você recebeu e enviou'**
  String get rewardsHistorySubtitle;

  /// No description provided for @rewardsNoSent.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não enviou presentes.'**
  String get rewardsNoSent;

  /// No description provided for @rewardsNoSentHint.
  ///
  /// In pt, this message translates to:
  /// **'Os presentes que você enviar em lives aparecerão aqui.'**
  String get rewardsNoSentHint;

  /// No description provided for @rewardsNoPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Nada neste período.'**
  String get rewardsNoPeriod;

  /// No description provided for @rewardsNoPeriodHint.
  ///
  /// In pt, this message translates to:
  /// **'Tente outro período para ver mais itens.'**
  String get rewardsNoPeriodHint;

  /// No description provided for @rewardsPeriodTotalReceived.
  ///
  /// In pt, this message translates to:
  /// **'Total recebido no período'**
  String get rewardsPeriodTotalReceived;

  /// No description provided for @rewardsPeriodTotalSent.
  ///
  /// In pt, this message translates to:
  /// **'Total enviado no período'**
  String get rewardsPeriodTotalSent;

  /// No description provided for @rewardsGiftsCount.
  ///
  /// In pt, this message translates to:
  /// **'{n} presentes'**
  String rewardsGiftsCount(int n);

  /// No description provided for @rewardsFromTo.
  ///
  /// In pt, this message translates to:
  /// **'{label} {name}'**
  String rewardsFromTo(String label, String name);

  /// No description provided for @rewardsPurchaseDisabled.
  ///
  /// In pt, this message translates to:
  /// **'A compra de moedas estará disponível em breve.'**
  String get rewardsPurchaseDisabled;

  /// No description provided for @liveTopUpAction.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar'**
  String get liveTopUpAction;

  /// No description provided for @rewardsToggleCoins.
  ///
  /// In pt, this message translates to:
  /// **'Moedas'**
  String get rewardsToggleCoins;

  /// No description provided for @rewardsToggleDiamonds.
  ///
  /// In pt, this message translates to:
  /// **'Diamantes'**
  String get rewardsToggleDiamonds;

  /// No description provided for @rewardsDiamondsAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Diamantes disponíveis'**
  String get rewardsDiamondsAvailable;

  /// No description provided for @rewardsPeriodLabel.
  ///
  /// In pt, this message translates to:
  /// **'Período'**
  String get rewardsPeriodLabel;

  /// No description provided for @creatorDashSince.
  ///
  /// In pt, this message translates to:
  /// **'Creator desde {date}'**
  String creatorDashSince(String date);

  /// No description provided for @creatorDashCurrentLevel.
  ///
  /// In pt, this message translates to:
  /// **'Seu nível'**
  String get creatorDashCurrentLevel;

  /// No description provided for @creatorDashOverallProgress.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% do caminho até {tier}'**
  String creatorDashOverallProgress(int percent, String tier);

  /// No description provided for @creatorDashInviteNext.
  ///
  /// In pt, this message translates to:
  /// **'O próximo nível é por convite da equipe Brawe. Continue criando e brilhando!'**
  String get creatorDashInviteNext;

  /// No description provided for @creatorDashTopLevel.
  ///
  /// In pt, this message translates to:
  /// **'Você chegou ao topo da jornada. Obrigado por construir a Brawe!'**
  String get creatorDashTopLevel;

  /// No description provided for @creatorDashTrailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua trilha'**
  String get creatorDashTrailTitle;

  /// No description provided for @creatorDashTrailHere.
  ///
  /// In pt, this message translates to:
  /// **'Você está aqui'**
  String get creatorDashTrailHere;

  /// No description provided for @creatorDashTrailLocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueado'**
  String get creatorDashTrailLocked;

  /// No description provided for @creatorDashTrailInviteOnly.
  ///
  /// In pt, this message translates to:
  /// **'Por convite'**
  String get creatorDashTrailInviteOnly;

  /// No description provided for @creatorDashTrailSince.
  ///
  /// In pt, this message translates to:
  /// **'Desde {date}'**
  String creatorDashTrailSince(String date);

  /// No description provided for @creatorDashGoalsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Metas para {tier}'**
  String creatorDashGoalsTitle(String tier);

  /// No description provided for @creatorDashGoalsHint.
  ///
  /// In pt, this message translates to:
  /// **'Cumpra as metas e mostre à equipe que você está pronto.'**
  String get creatorDashGoalsHint;

  /// No description provided for @creatorDashGoalsAllDone.
  ///
  /// In pt, this message translates to:
  /// **'Metas cumpridas! A equipe Brawe vai avaliar seu perfil para o próximo nível.'**
  String get creatorDashGoalsAllDone;

  /// No description provided for @creatorDashGoalOf.
  ///
  /// In pt, this message translates to:
  /// **'{current} de {target}'**
  String creatorDashGoalOf(String current, String target);

  /// No description provided for @creatorDashGoalDone.
  ///
  /// In pt, this message translates to:
  /// **'Meta cumprida'**
  String get creatorDashGoalDone;

  /// No description provided for @creatorJourneyMetricFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get creatorJourneyMetricFollowers;

  /// No description provided for @creatorJourneyMetricLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives realizadas'**
  String get creatorJourneyMetricLives;

  /// No description provided for @creatorJourneyMetricLiveMinutes.
  ///
  /// In pt, this message translates to:
  /// **'Minutos ao vivo'**
  String get creatorJourneyMetricLiveMinutes;

  /// No description provided for @creatorJourneyMetricPosts.
  ///
  /// In pt, this message translates to:
  /// **'Posts publicados'**
  String get creatorJourneyMetricPosts;

  /// No description provided for @creatorJourneyMetricGiftCredits.
  ///
  /// In pt, this message translates to:
  /// **'Presentes recebidos'**
  String get creatorJourneyMetricGiftCredits;

  /// No description provided for @creatorJourneyMetricActiveDays.
  ///
  /// In pt, this message translates to:
  /// **'Dias como creator'**
  String get creatorJourneyMetricActiveDays;

  /// No description provided for @creatorJourneyMetricViewers.
  ///
  /// In pt, this message translates to:
  /// **'Espectadores nas lives'**
  String get creatorJourneyMetricViewers;

  /// No description provided for @creatorJourneyRemainingFollowers.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Falta 1 seguidor} other{Faltam {n} seguidores}}'**
  String creatorJourneyRemainingFollowers(int n);

  /// No description provided for @creatorJourneyRemainingLives.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Falta 1 live} other{Faltam {n} lives}}'**
  String creatorJourneyRemainingLives(int n);

  /// No description provided for @creatorJourneyRemainingLiveMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Falta 1 minuto ao vivo} other{Faltam {n} minutos ao vivo}}'**
  String creatorJourneyRemainingLiveMinutes(int n);

  /// No description provided for @creatorJourneyRemainingPosts.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Falta 1 post} other{Faltam {n} posts}}'**
  String creatorJourneyRemainingPosts(int n);

  /// No description provided for @creatorJourneyRemainingGiftCredits.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Falta 1 crédito em presentes} other{Faltam {n} créditos em presentes}}'**
  String creatorJourneyRemainingGiftCredits(int n);

  /// No description provided for @creatorJourneyRemainingActiveDays.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Falta 1 dia} other{Faltam {n} dias}}'**
  String creatorJourneyRemainingActiveDays(int n);

  /// No description provided for @creatorDashWeekTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua semana'**
  String get creatorDashWeekTitle;

  /// No description provided for @creatorDashWeekSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 7 dias comparados aos 7 anteriores'**
  String get creatorDashWeekSubtitle;

  /// No description provided for @creatorDashWeekNewFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Novos seguidores'**
  String get creatorDashWeekNewFollowers;

  /// No description provided for @creatorDashWeekUp.
  ///
  /// In pt, this message translates to:
  /// **'{n} a mais que na semana passada'**
  String creatorDashWeekUp(String n);

  /// No description provided for @creatorDashWeekDown.
  ///
  /// In pt, this message translates to:
  /// **'{n} a menos que na semana passada'**
  String creatorDashWeekDown(String n);

  /// No description provided for @creatorDashWeekSame.
  ///
  /// In pt, this message translates to:
  /// **'Igual à semana passada'**
  String get creatorDashWeekSame;

  /// No description provided for @creatorDashWeekSeeMore.
  ///
  /// In pt, this message translates to:
  /// **'Ver análise'**
  String get creatorDashWeekSeeMore;

  /// No description provided for @creatorDashBenefitsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus benefícios'**
  String get creatorDashBenefitsTitle;

  /// No description provided for @creatorDashBenefitsNextTitle.
  ///
  /// In pt, this message translates to:
  /// **'Libera em {tier}'**
  String creatorDashBenefitsNextTitle(String tier);

  /// No description provided for @creatorDashBenefitActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get creatorDashBenefitActive;

  /// No description provided for @creatorDashShortcutAnalytics.
  ///
  /// In pt, this message translates to:
  /// **'Análises'**
  String get creatorDashShortcutAnalytics;

  /// No description provided for @creatorDashShortcutSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get creatorDashShortcutSettings;

  /// No description provided for @creatorDashErrorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar sua jornada. Puxe para tentar de novo.'**
  String get creatorDashErrorTitle;

  /// No description provided for @creatorJourneyBadgeGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Badge de creator'**
  String get creatorJourneyBadgeGeneric;

  /// No description provided for @creatorJourneyBadgeEarnedOn.
  ///
  /// In pt, this message translates to:
  /// **'Conquistado em {date}'**
  String creatorJourneyBadgeEarnedOn(String date);

  /// No description provided for @creatorJourneyBadgeBenefitsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Benefícios ativos'**
  String get creatorJourneyBadgeBenefitsTitle;

  /// No description provided for @creatorJourneyBadgeNextTitle.
  ///
  /// In pt, this message translates to:
  /// **'Próximo nível'**
  String get creatorJourneyBadgeNextTitle;

  /// No description provided for @creatorJourneyBadgeAllTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus badges'**
  String get creatorJourneyBadgeAllTitle;

  /// No description provided for @creatorJourneyBadgeOpenDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Abrir painel do creator'**
  String get creatorJourneyBadgeOpenDashboard;

  /// No description provided for @creatorJourneyBenefitRisingBadgeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Badge Rising'**
  String get creatorJourneyBenefitRisingBadgeTitle;

  /// No description provided for @creatorJourneyBenefitRisingBadgeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Seu selo oficial de creator aparece no perfil, nas lives e nos comentários.'**
  String get creatorJourneyBenefitRisingBadgeDesc;

  /// No description provided for @creatorJourneyBenefitCreatorProfileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de Creator'**
  String get creatorJourneyBenefitCreatorProfileTitle;

  /// No description provided for @creatorJourneyBenefitCreatorProfileDesc.
  ///
  /// In pt, this message translates to:
  /// **'Perfil com identidade própria na rede de creators da Brawe.'**
  String get creatorJourneyBenefitCreatorProfileDesc;

  /// No description provided for @creatorJourneyBenefitDiscoverySuggestionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões de descoberta'**
  String get creatorJourneyBenefitDiscoverySuggestionsTitle;

  /// No description provided for @creatorJourneyBenefitDiscoverySuggestionsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Seu conteúdo pode ser sugerido a pessoas que ainda não te seguem.'**
  String get creatorJourneyBenefitDiscoverySuggestionsDesc;

  /// No description provided for @creatorJourneyBenefitAnalyticsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Análises detalhadas'**
  String get creatorJourneyBenefitAnalyticsTitle;

  /// No description provided for @creatorJourneyBenefitAnalyticsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe seguidores, alcance e lives com gráficos e números reais.'**
  String get creatorJourneyBenefitAnalyticsDesc;

  /// No description provided for @creatorJourneyBenefitFeaturedBadgeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Badge Featured'**
  String get creatorJourneyBenefitFeaturedBadgeTitle;

  /// No description provided for @creatorJourneyBenefitFeaturedBadgeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Selo de destaque que mostra que você é um creator consistente.'**
  String get creatorJourneyBenefitFeaturedBadgeDesc;

  /// No description provided for @creatorJourneyBenefitEditorialHighlightTitle.
  ///
  /// In pt, this message translates to:
  /// **'Destaque editorial'**
  String get creatorJourneyBenefitEditorialHighlightTitle;

  /// No description provided for @creatorJourneyBenefitEditorialHighlightDesc.
  ///
  /// In pt, this message translates to:
  /// **'Chance de aparecer nas vitrines selecionadas pela equipe Brawe.'**
  String get creatorJourneyBenefitEditorialHighlightDesc;

  /// No description provided for @creatorJourneyBenefitMoreReachTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mais alcance orgânico'**
  String get creatorJourneyBenefitMoreReachTitle;

  /// No description provided for @creatorJourneyBenefitMoreReachDesc.
  ///
  /// In pt, this message translates to:
  /// **'Seu conteúdo ganha mais força na descoberta e chega a mais gente.'**
  String get creatorJourneyBenefitMoreReachDesc;

  /// No description provided for @creatorJourneyBenefitLiveBadgeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Badge Live'**
  String get creatorJourneyBenefitLiveBadgeTitle;

  /// No description provided for @creatorJourneyBenefitLiveBadgeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Selo exclusivo para quem constrói comunidade ao vivo.'**
  String get creatorJourneyBenefitLiveBadgeDesc;

  /// No description provided for @creatorJourneyBenefitAdvancedLiveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recursos avançados de live'**
  String get creatorJourneyBenefitAdvancedLiveTitle;

  /// No description provided for @creatorJourneyBenefitAdvancedLiveDesc.
  ///
  /// In pt, this message translates to:
  /// **'Ferramentas extras para fazer lives mais profissionais.'**
  String get creatorJourneyBenefitAdvancedLiveDesc;

  /// No description provided for @creatorJourneyBenefitLiveBattlesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Batalhas ao vivo'**
  String get creatorJourneyBenefitLiveBattlesTitle;

  /// No description provided for @creatorJourneyBenefitLiveBattlesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Participe de batalhas e dispute presentes com outros creators.'**
  String get creatorJourneyBenefitLiveBattlesDesc;

  /// No description provided for @creatorJourneyBenefitLiveRankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ranking de Live Creators'**
  String get creatorJourneyBenefitLiveRankingTitle;

  /// No description provided for @creatorJourneyBenefitLiveRankingDesc.
  ///
  /// In pt, this message translates to:
  /// **'Apareça no ranking público dos creators que mais brilham nas lives.'**
  String get creatorJourneyBenefitLiveRankingDesc;

  /// No description provided for @creatorJourneyBenefitAmbassadorBadgeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Badge Ambassador'**
  String get creatorJourneyBenefitAmbassadorBadgeTitle;

  /// No description provided for @creatorJourneyBenefitAmbassadorBadgeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Selo de quem representa a Brawe com reconhecimento oficial.'**
  String get creatorJourneyBenefitAmbassadorBadgeDesc;

  /// No description provided for @creatorJourneyBenefitAmbassadorPageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Página de embaixador'**
  String get creatorJourneyBenefitAmbassadorPageTitle;

  /// No description provided for @creatorJourneyBenefitAmbassadorPageDesc.
  ///
  /// In pt, this message translates to:
  /// **'Uma página oficial para contar sua história e suas conquistas.'**
  String get creatorJourneyBenefitAmbassadorPageDesc;

  /// No description provided for @creatorJourneyBenefitOfficialCampaignsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Campanhas oficiais'**
  String get creatorJourneyBenefitOfficialCampaignsTitle;

  /// No description provided for @creatorJourneyBenefitOfficialCampaignsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Convites para participar de campanhas e ações da marca Brawe.'**
  String get creatorJourneyBenefitOfficialCampaignsDesc;

  /// No description provided for @creatorJourneyBenefitPremiumHighlightTitle.
  ///
  /// In pt, this message translates to:
  /// **'Destaque premium'**
  String get creatorJourneyBenefitPremiumHighlightTitle;

  /// No description provided for @creatorJourneyBenefitPremiumHighlightDesc.
  ///
  /// In pt, this message translates to:
  /// **'Posição privilegiada nos destaques da plataforma.'**
  String get creatorJourneyBenefitPremiumHighlightDesc;

  /// No description provided for @creatorJourneyBenefitFoundingBadgeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Badge Founding'**
  String get creatorJourneyBenefitFoundingBadgeTitle;

  /// No description provided for @creatorJourneyBenefitFoundingBadgeDesc.
  ///
  /// In pt, this message translates to:
  /// **'O selo mais raro: para quem constrói a Brawe desde o início.'**
  String get creatorJourneyBenefitFoundingBadgeDesc;

  /// No description provided for @creatorJourneyBenefitFoundingSealTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selo de Fundador'**
  String get creatorJourneyBenefitFoundingSealTitle;

  /// No description provided for @creatorJourneyBenefitFoundingSealDesc.
  ///
  /// In pt, this message translates to:
  /// **'Reconhecimento permanente como parte da história da Brawe.'**
  String get creatorJourneyBenefitFoundingSealDesc;

  /// No description provided for @creatorJourneyBenefitEarlyAccessTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesso antecipado'**
  String get creatorJourneyBenefitEarlyAccessTitle;

  /// No description provided for @creatorJourneyBenefitEarlyAccessDesc.
  ///
  /// In pt, this message translates to:
  /// **'Teste novos recursos antes de todo mundo.'**
  String get creatorJourneyBenefitEarlyAccessDesc;

  /// No description provided for @creatorJourneyBenefitRoadmapVoiceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Voz no roadmap'**
  String get creatorJourneyBenefitRoadmapVoiceTitle;

  /// No description provided for @creatorJourneyBenefitRoadmapVoiceDesc.
  ///
  /// In pt, this message translates to:
  /// **'Sua opinião ajuda a decidir o que a Brawe vai construir.'**
  String get creatorJourneyBenefitRoadmapVoiceDesc;

  /// No description provided for @creatorDashShowAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get creatorDashShowAll;

  /// No description provided for @creatorDashShowLess.
  ///
  /// In pt, this message translates to:
  /// **'Ver menos'**
  String get creatorDashShowLess;

  /// No description provided for @analyticsPreviousPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Período anterior'**
  String get analyticsPreviousPeriod;

  /// No description provided for @analyticsNoDataTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados no período'**
  String get analyticsNoDataTitle;

  /// No description provided for @analyticsNoDataSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Tente outro período ou volte após novas atividades.'**
  String get analyticsNoDataSubtitle;

  /// No description provided for @analyticsPeriod7d.
  ///
  /// In pt, this message translates to:
  /// **'7D'**
  String get analyticsPeriod7d;

  /// No description provided for @analyticsPeriod30d.
  ///
  /// In pt, this message translates to:
  /// **'30D'**
  String get analyticsPeriod30d;

  /// No description provided for @analyticsPeriod90d.
  ///
  /// In pt, this message translates to:
  /// **'3M'**
  String get analyticsPeriod90d;

  /// No description provided for @analyticsPeriod365d.
  ///
  /// In pt, this message translates to:
  /// **'1A'**
  String get analyticsPeriod365d;

  /// No description provided for @analyticsVsPrevious.
  ///
  /// In pt, this message translates to:
  /// **'vs. período anterior'**
  String get analyticsVsPrevious;

  /// No description provided for @analyticsCompare.
  ///
  /// In pt, this message translates to:
  /// **'Comparar'**
  String get analyticsCompare;

  /// No description provided for @analyticsErrorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar'**
  String get analyticsErrorTitle;

  /// No description provided for @analyticsRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get analyticsRetry;

  /// No description provided for @analyticsTopGiftsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Top presentes'**
  String get analyticsTopGiftsTitle;

  /// No description provided for @analyticsTopGiftsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Os mais recebidos no período'**
  String get analyticsTopGiftsSubtitle;

  /// No description provided for @analyticsTopGiftsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum presente recebido neste período'**
  String get analyticsTopGiftsEmpty;

  /// No description provided for @analyticsTopGiftsBest.
  ///
  /// In pt, this message translates to:
  /// **'Mais valioso'**
  String get analyticsTopGiftsBest;

  /// No description provided for @analyticsTopGiftsReceived.
  ///
  /// In pt, this message translates to:
  /// **'{count} recebidos'**
  String analyticsTopGiftsReceived(String count);

  /// No description provided for @analyticsEarningsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos'**
  String get analyticsEarningsLabel;

  /// No description provided for @analyticsGiftsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Presentes'**
  String get analyticsGiftsLabel;

  /// No description provided for @analyticsAvgPerGift.
  ///
  /// In pt, this message translates to:
  /// **'Média por presente'**
  String get analyticsAvgPerGift;

  /// No description provided for @analyticsEarningsChartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos por dia'**
  String get analyticsEarningsChartTitle;

  /// No description provided for @analyticsGiftsChartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Presentes por dia'**
  String get analyticsGiftsChartTitle;

  /// No description provided for @analyticsFollowersNew.
  ///
  /// In pt, this message translates to:
  /// **'Novos seguidores'**
  String get analyticsFollowersNew;

  /// No description provided for @analyticsFollowersChartTotal.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores acumulados'**
  String get analyticsFollowersChartTotal;

  /// No description provided for @analyticsFollowersChartNew.
  ///
  /// In pt, this message translates to:
  /// **'Novos por dia'**
  String get analyticsFollowersChartNew;

  /// No description provided for @analyticsViewersKpiPeak.
  ///
  /// In pt, this message translates to:
  /// **'Pico de audiência'**
  String get analyticsViewersKpiPeak;

  /// No description provided for @analyticsWeekOf.
  ///
  /// In pt, this message translates to:
  /// **'Semana de {date}'**
  String analyticsWeekOf(String date);

  /// No description provided for @analyticsLivesMinutesLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tempo ao vivo'**
  String get analyticsLivesMinutesLabel;

  /// No description provided for @analyticsLivesChartLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives por dia'**
  String get analyticsLivesChartLives;

  /// No description provided for @analyticsLivesChartMinutes.
  ///
  /// In pt, this message translates to:
  /// **'Minutos ao vivo'**
  String get analyticsLivesChartMinutes;

  /// No description provided for @analyticsLivesHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de lives'**
  String get analyticsLivesHistoryTitle;

  /// No description provided for @analyticsLivesMetricEarned.
  ///
  /// In pt, this message translates to:
  /// **'em presentes'**
  String get analyticsLivesMetricEarned;

  /// No description provided for @analyticsMinutesShort.
  ///
  /// In pt, this message translates to:
  /// **'{n} min'**
  String analyticsMinutesShort(String n);

  /// No description provided for @analyticsHoursMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{h}h {m}min'**
  String analyticsHoursMinutes(String h, String m);

  /// No description provided for @analyticsRange7d.
  ///
  /// In pt, this message translates to:
  /// **'nos últimos 7 dias'**
  String get analyticsRange7d;

  /// No description provided for @analyticsRange30d.
  ///
  /// In pt, this message translates to:
  /// **'nos últimos 30 dias'**
  String get analyticsRange30d;

  /// No description provided for @analyticsRange90d.
  ///
  /// In pt, this message translates to:
  /// **'nos últimos 3 meses'**
  String get analyticsRange90d;

  /// No description provided for @analyticsRange365d.
  ///
  /// In pt, this message translates to:
  /// **'no último ano'**
  String get analyticsRange365d;

  /// No description provided for @analyticsEmptyFollowersNew.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum seguidor novo {range}'**
  String analyticsEmptyFollowersNew(String range);

  /// No description provided for @analyticsEmptyFollowersTotal.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não tem seguidores'**
  String get analyticsEmptyFollowersTotal;

  /// No description provided for @analyticsEmptyEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ganho {range}'**
  String analyticsEmptyEarnings(String range);

  /// No description provided for @analyticsEmptyGifts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum presente recebido {range}'**
  String analyticsEmptyGifts(String range);

  /// No description provided for @analyticsEmptyViewers.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum espectador {range}'**
  String analyticsEmptyViewers(String range);

  /// No description provided for @analyticsEmptyLives.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma live {range}'**
  String analyticsEmptyLives(String range);

  /// No description provided for @analyticsEmptyMinutes.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum minuto ao vivo {range}'**
  String analyticsEmptyMinutes(String range);

  /// No description provided for @analyticsHubTitle.
  ///
  /// In pt, this message translates to:
  /// **'Análises'**
  String get analyticsHubTitle;

  /// No description provided for @analyticsTabOverview.
  ///
  /// In pt, this message translates to:
  /// **'Visão geral'**
  String get analyticsTabOverview;

  /// No description provided for @analyticsTabFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get analyticsTabFollowers;

  /// No description provided for @analyticsTabAudience.
  ///
  /// In pt, this message translates to:
  /// **'Audiência'**
  String get analyticsTabAudience;

  /// No description provided for @analyticsTabLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives'**
  String get analyticsTabLives;

  /// No description provided for @analyticsTabEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos'**
  String get analyticsTabEarnings;

  /// No description provided for @analyticsOverviewTopGift.
  ///
  /// In pt, this message translates to:
  /// **'Presente em destaque'**
  String get analyticsOverviewTopGift;

  /// No description provided for @analyticsOverviewSeeDetails.
  ///
  /// In pt, this message translates to:
  /// **'Toque num indicador para ver os detalhes'**
  String get analyticsOverviewSeeDetails;

  /// No description provided for @gifterLevelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meu nível'**
  String get gifterLevelTitle;

  /// No description provided for @gifterLevelLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nível {level}'**
  String gifterLevelLevel(int level);

  /// No description provided for @gifterLevelXpProgress.
  ///
  /// In pt, this message translates to:
  /// **'{current} / {total} XP'**
  String gifterLevelXpProgress(String current, String total);

  /// No description provided for @gifterLevelXpMissing.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {xp} XP para o nível {level}'**
  String gifterLevelXpMissing(String xp, int level);

  /// No description provided for @gifterLevelMaxReached.
  ///
  /// In pt, this message translates to:
  /// **'Nível máximo alcançado'**
  String get gifterLevelMaxReached;

  /// No description provided for @gifterLevelNextTier.
  ///
  /// In pt, this message translates to:
  /// **'Próxima faixa'**
  String get gifterLevelNextTier;

  /// No description provided for @gifterLevelNextTierLine.
  ///
  /// In pt, this message translates to:
  /// **'{name} · nível {level} · faltam {xp} XP'**
  String gifterLevelNextTierLine(String name, int level, String xp);

  /// No description provided for @gifterLevelHowToEarn.
  ///
  /// In pt, this message translates to:
  /// **'Como ganhar XP'**
  String get gifterLevelHowToEarn;

  /// No description provided for @gifterLevelRuleGiftPerCoin.
  ///
  /// In pt, this message translates to:
  /// **'Enviar presentes · {xp} XP por moeda (até {cap} por envio)'**
  String gifterLevelRuleGiftPerCoin(int xp, String cap);

  /// No description provided for @gifterLevelRuleGiftPerCoinNoCap.
  ///
  /// In pt, this message translates to:
  /// **'Enviar presentes · {xp} XP por moeda'**
  String gifterLevelRuleGiftPerCoinNoCap(int xp);

  /// No description provided for @gifterLevelRuleGiftFlat.
  ///
  /// In pt, this message translates to:
  /// **'Enviar presentes · +{xp} XP por presente'**
  String gifterLevelRuleGiftFlat(int xp);

  /// No description provided for @gifterLevelRuleWatch.
  ///
  /// In pt, this message translates to:
  /// **'Assistir lives · {xp} XP por minuto (até {cap} min)'**
  String gifterLevelRuleWatch(int xp, int cap);

  /// No description provided for @gifterLevelRuleWatchNoCap.
  ///
  /// In pt, this message translates to:
  /// **'Assistir lives · {xp} XP por minuto'**
  String gifterLevelRuleWatchNoCap(int xp);

  /// No description provided for @gifterLevelRuleJoin.
  ///
  /// In pt, this message translates to:
  /// **'Entrar numa live · +{xp} XP'**
  String gifterLevelRuleJoin(int xp);

  /// No description provided for @gifterLevelRuleChat.
  ///
  /// In pt, this message translates to:
  /// **'Comentar no chat · +{xp} XP'**
  String gifterLevelRuleChat(int xp);

  /// No description provided for @gifterLevelTiers.
  ///
  /// In pt, this message translates to:
  /// **'Faixas'**
  String get gifterLevelTiers;

  /// No description provided for @gifterLevelRange.
  ///
  /// In pt, this message translates to:
  /// **'Nível {from}–{to}'**
  String gifterLevelRange(int from, int to);

  /// No description provided for @gifterLevelRangeOpen.
  ///
  /// In pt, this message translates to:
  /// **'Nível {from}'**
  String gifterLevelRangeOpen(int from);

  /// No description provided for @gifterLevelXpRequired.
  ///
  /// In pt, this message translates to:
  /// **'{xp} XP'**
  String gifterLevelXpRequired(String xp);

  /// No description provided for @gifterLevelBenefitVip.
  ///
  /// In pt, this message translates to:
  /// **'Entrada VIP'**
  String get gifterLevelBenefitVip;

  /// No description provided for @gifterLevelBenefitEntryEffect.
  ///
  /// In pt, this message translates to:
  /// **'Efeito de entrada'**
  String get gifterLevelBenefitEntryEffect;

  /// No description provided for @gifterLevelBenefitAnnounce.
  ///
  /// In pt, this message translates to:
  /// **'Anúncio ao subir de nível'**
  String get gifterLevelBenefitAnnounce;

  /// No description provided for @gifterLevelYouAreHere.
  ///
  /// In pt, this message translates to:
  /// **'Você está aqui'**
  String get gifterLevelYouAreHere;

  /// No description provided for @gifterLevelTierXpMissing.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {xp} XP'**
  String gifterLevelTierXpMissing(String xp);

  /// No description provided for @gifterLevelLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seu nível.'**
  String get gifterLevelLoadError;

  /// No description provided for @gifterLevelRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get gifterLevelRetry;

  /// No description provided for @gifterLevelSeeLevels.
  ///
  /// In pt, this message translates to:
  /// **'Ver níveis'**
  String get gifterLevelSeeLevels;

  /// No description provided for @gifterLevelStatusAchieved.
  ///
  /// In pt, this message translates to:
  /// **'Conquistada'**
  String get gifterLevelStatusAchieved;

  /// No description provided for @gifterLevelStatusCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Faixa atual'**
  String get gifterLevelStatusCurrent;

  /// No description provided for @gifterLevelStatusLocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueada'**
  String get gifterLevelStatusLocked;

  /// No description provided for @gifterLevelBackToCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao meu nível'**
  String get gifterLevelBackToCurrent;

  /// No description provided for @gifterLevelBenefits.
  ///
  /// In pt, this message translates to:
  /// **'Benefícios'**
  String get gifterLevelBenefits;

  /// No description provided for @gifterLevelNoBenefits.
  ///
  /// In pt, this message translates to:
  /// **'Emblema exclusivo no chat'**
  String get gifterLevelNoBenefits;

  /// No description provided for @gifterLevelSwipeHint.
  ///
  /// In pt, this message translates to:
  /// **'Deslize para ver todas as faixas'**
  String get gifterLevelSwipeHint;

  /// No description provided for @gifterLevelUnlockedAt.
  ///
  /// In pt, this message translates to:
  /// **'Conquistada ao chegar em {xp} XP'**
  String gifterLevelUnlockedAt(String xp);

  /// No description provided for @gifterLevelTierProgress.
  ///
  /// In pt, this message translates to:
  /// **'Você tem {current} de {total} XP'**
  String gifterLevelTierProgress(String current, String total);

  /// No description provided for @gifterLevelTiersCount.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} faixas'**
  String gifterLevelTiersCount(int done, int total);

  /// No description provided for @menuSectionProgress.
  ///
  /// In pt, this message translates to:
  /// **'Meu progresso'**
  String get menuSectionProgress;

  /// No description provided for @menuSectionMoney.
  ///
  /// In pt, this message translates to:
  /// **'Moedas e presentes'**
  String get menuSectionMoney;

  /// No description provided for @menuSectionCreator.
  ///
  /// In pt, this message translates to:
  /// **'Criador'**
  String get menuSectionCreator;

  /// No description provided for @menuSectionAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get menuSectionAccount;

  /// No description provided for @menuSectionProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get menuSectionProfile;

  /// No description provided for @menuSectionPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e segurança'**
  String get menuSectionPrivacy;

  /// No description provided for @menuQuestsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Missões, conquistas e jornada'**
  String get menuQuestsSubtitle;

  /// No description provided for @menuLevelSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Faixas, emblemas e XP'**
  String get menuLevelSubtitle;

  /// No description provided for @menuWalletSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Suas moedas para presentear'**
  String get menuWalletSubtitle;

  /// No description provided for @menuCreatorSubtitleMember.
  ///
  /// In pt, this message translates to:
  /// **'Painel, ganhos e análises'**
  String get menuCreatorSubtitleMember;

  /// No description provided for @menuCreatorSubtitleJoin.
  ///
  /// In pt, this message translates to:
  /// **'Saiba como ganhar com suas lives'**
  String get menuCreatorSubtitleJoin;

  /// No description provided for @menuSettingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade, notificações e mais'**
  String get menuSettingsSubtitle;

  /// No description provided for @creatorShortcutEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos'**
  String get creatorShortcutEarnings;

  /// No description provided for @notifFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get notifFilterAll;

  /// No description provided for @notifFilterLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives'**
  String get notifFilterLives;

  /// No description provided for @notifFilterSocial.
  ///
  /// In pt, this message translates to:
  /// **'Social'**
  String get notifFilterSocial;

  /// No description provided for @notifFilterMissions.
  ///
  /// In pt, this message translates to:
  /// **'Missões'**
  String get notifFilterMissions;

  /// No description provided for @notifFilterGifts.
  ///
  /// In pt, this message translates to:
  /// **'Presentes'**
  String get notifFilterGifts;

  /// No description provided for @notifFilterOther.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get notifFilterOther;

  /// No description provided for @notifGroupToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get notifGroupToday;

  /// No description provided for @notifGroupYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get notifGroupYesterday;

  /// No description provided for @notifGroupWeek.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get notifGroupWeek;

  /// No description provided for @notifGroupOlder.
  ///
  /// In pt, this message translates to:
  /// **'Anteriores'**
  String get notifGroupOlder;

  /// No description provided for @notifFilterEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui nesta categoria'**
  String get notifFilterEmpty;

  /// No description provided for @notifMarkAllTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Marcar todas como lidas'**
  String get notifMarkAllTooltip;

  /// No description provided for @linkSharedPost.
  ///
  /// In pt, this message translates to:
  /// **'📎 Publicação compartilhada'**
  String get linkSharedPost;

  /// No description provided for @chatViewOncePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get chatViewOncePhoto;

  /// No description provided for @chatViewOnceTapToOpen.
  ///
  /// In pt, this message translates to:
  /// **'Toque para abrir · visualização única'**
  String get chatViewOnceTapToOpen;

  /// No description provided for @chatViewOnceSent.
  ///
  /// In pt, this message translates to:
  /// **'Visualização única · enviada'**
  String get chatViewOnceSent;

  /// No description provided for @chatViewOnceOpened.
  ///
  /// In pt, this message translates to:
  /// **'Aberta'**
  String get chatViewOnceOpened;

  /// No description provided for @chatCopied.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem copiada'**
  String get chatCopied;

  /// No description provided for @chatEmojiKeyboard.
  ///
  /// In pt, this message translates to:
  /// **'Teclado'**
  String get chatEmojiKeyboard;

  /// No description provided for @chatDeleteForEveryone.
  ///
  /// In pt, this message translates to:
  /// **'Apagar para todos'**
  String get chatDeleteForEveryone;

  /// No description provided for @chatDeleteForEveryoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar para todos?'**
  String get chatDeleteForEveryoneTitle;

  /// No description provided for @chatDeleteForEveryoneBody.
  ///
  /// In pt, this message translates to:
  /// **'A mensagem some para você e para a outra pessoa.'**
  String get chatDeleteForEveryoneBody;

  /// No description provided for @chatMessageDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem apagada'**
  String get chatMessageDeleted;

  /// No description provided for @chatErrLoadMessages.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as mensagens.'**
  String get chatErrLoadMessages;

  /// No description provided for @chatErrSend.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar a mensagem.'**
  String get chatErrSend;

  /// No description provided for @chatErrReact.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível reagir à mensagem.'**
  String get chatErrReact;

  /// No description provided for @chatErrAudio.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o áudio.'**
  String get chatErrAudio;

  /// No description provided for @chatErrImage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar a imagem.'**
  String get chatErrImage;

  /// No description provided for @chatErrDelete.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível apagar a mensagem.'**
  String get chatErrDelete;

  /// No description provided for @chatErrLoadConversations.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as conversas.'**
  String get chatErrLoadConversations;

  /// No description provided for @chatErrArchive.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível arquivar a conversa.'**
  String get chatErrArchive;

  /// No description provided for @chatErrUnarchive.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível desarquivar a conversa.'**
  String get chatErrUnarchive;

  /// No description provided for @chatErrDeleteConversation.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível apagar a conversa.'**
  String get chatErrDeleteConversation;

  /// No description provided for @chatErrStart.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível iniciar a conversa.'**
  String get chatErrStart;

  /// No description provided for @chatMicDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permissão de microfone negada'**
  String get chatMicDenied;

  /// No description provided for @chatErrEdit.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível editar a mensagem.'**
  String get chatErrEdit;

  /// No description provided for @chatErrOpenGift.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o cofre. Tente de novo.'**
  String get chatErrOpenGift;

  /// No description provided for @chatErrFile.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o arquivo.'**
  String get chatErrFile;

  /// No description provided for @chatEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get chatEdit;

  /// No description provided for @chatEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar mensagem'**
  String get chatEditTitle;

  /// No description provided for @chatEditSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get chatEditSave;

  /// No description provided for @chatEdited.
  ///
  /// In pt, this message translates to:
  /// **'editada'**
  String get chatEdited;

  /// No description provided for @chatForward.
  ///
  /// In pt, this message translates to:
  /// **'Encaminhar'**
  String get chatForward;

  /// No description provided for @chatForwarded.
  ///
  /// In pt, this message translates to:
  /// **'Encaminhada'**
  String get chatForwarded;

  /// No description provided for @chatForwardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encaminhar para'**
  String get chatForwardTitle;

  /// No description provided for @chatForwardSent.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem encaminhada'**
  String get chatForwardSent;

  /// No description provided for @chatForwardEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não tem outras conversas'**
  String get chatForwardEmpty;

  /// No description provided for @chatMsgSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar mensagens'**
  String get chatMsgSearchHint;

  /// No description provided for @chatSearchEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma mensagem encontrada'**
  String get chatSearchEmpty;

  /// No description provided for @chatSearchMinChars.
  ///
  /// In pt, this message translates to:
  /// **'Digite pelo menos 2 letras'**
  String get chatSearchMinChars;

  /// No description provided for @chatUnmute.
  ///
  /// In pt, this message translates to:
  /// **'Ativar notificações'**
  String get chatUnmute;

  /// No description provided for @chatMutedToast.
  ///
  /// In pt, this message translates to:
  /// **'Conversa silenciada'**
  String get chatMutedToast;

  /// No description provided for @chatUnmutedToast.
  ///
  /// In pt, this message translates to:
  /// **'Notificações ativadas'**
  String get chatUnmutedToast;

  /// No description provided for @chatPin.
  ///
  /// In pt, this message translates to:
  /// **'Fixar conversa'**
  String get chatPin;

  /// No description provided for @chatUnpin.
  ///
  /// In pt, this message translates to:
  /// **'Desafixar conversa'**
  String get chatUnpin;

  /// No description provided for @chatPinnedToast.
  ///
  /// In pt, this message translates to:
  /// **'Conversa fixada no topo'**
  String get chatPinnedToast;

  /// No description provided for @chatUnpinnedToast.
  ///
  /// In pt, this message translates to:
  /// **'Conversa desafixada'**
  String get chatUnpinnedToast;

  /// No description provided for @chatPinLimit.
  ///
  /// In pt, this message translates to:
  /// **'Você pode fixar até 5 conversas'**
  String get chatPinLimit;

  /// No description provided for @chatLocationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get chatLocationTitle;

  /// No description provided for @chatLocationOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir no mapa'**
  String get chatLocationOpen;

  /// No description provided for @chatLocationDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permita o acesso à localização nos Ajustes para enviar.'**
  String get chatLocationDenied;

  /// No description provided for @chatLocationGetting.
  ///
  /// In pt, this message translates to:
  /// **'Obtendo sua localização…'**
  String get chatLocationGetting;

  /// No description provided for @chatLocationError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter sua localização.'**
  String get chatLocationError;

  /// No description provided for @chatLocationConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar sua localização atual?'**
  String get chatLocationConfirmTitle;

  /// No description provided for @chatLocationConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'A outra pessoa verá onde você está agora.'**
  String get chatLocationConfirmBody;

  /// No description provided for @chatSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get chatSend;

  /// No description provided for @chatFileOpen.
  ///
  /// In pt, this message translates to:
  /// **'Toque para abrir'**
  String get chatFileOpen;

  /// No description provided for @chatStoryReacted.
  ///
  /// In pt, this message translates to:
  /// **'Reagiu ao seu story'**
  String get chatStoryReacted;

  /// No description provided for @chatStoryReactedMine.
  ///
  /// In pt, this message translates to:
  /// **'Você reagiu ao story'**
  String get chatStoryReactedMine;

  /// No description provided for @chatStoryReplied.
  ///
  /// In pt, this message translates to:
  /// **'Respondeu ao seu story'**
  String get chatStoryReplied;

  /// No description provided for @chatStoryRepliedMine.
  ///
  /// In pt, this message translates to:
  /// **'Você respondeu ao story'**
  String get chatStoryRepliedMine;

  /// No description provided for @chatStoryUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Story não disponível'**
  String get chatStoryUnavailable;

  /// No description provided for @chatVaultReceived.
  ///
  /// In pt, this message translates to:
  /// **'Você recebeu um cofre!'**
  String get chatVaultReceived;

  /// No description provided for @chatVaultFromStory.
  ///
  /// In pt, this message translates to:
  /// **'Presente do seu story'**
  String get chatVaultFromStory;

  /// No description provided for @chatVaultTapToOpen.
  ///
  /// In pt, this message translates to:
  /// **'Toque para abrir'**
  String get chatVaultTapToOpen;

  /// No description provided for @chatVaultSentMine.
  ///
  /// In pt, this message translates to:
  /// **'Você enviou um cofre'**
  String get chatVaultSentMine;

  /// No description provided for @chatVaultWaiting.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando ser aberto'**
  String get chatVaultWaiting;

  /// No description provided for @chatVaultOpenedBy.
  ///
  /// In pt, this message translates to:
  /// **'Cofre aberto'**
  String get chatVaultOpenedBy;

  /// No description provided for @chatVaultYouGot.
  ///
  /// In pt, this message translates to:
  /// **'Você ganhou'**
  String get chatVaultYouGot;

  /// No description provided for @chatVaultEarnings.
  ///
  /// In pt, this message translates to:
  /// **'+{value} nas suas recompensas de criador'**
  String chatVaultEarnings(String value);

  /// No description provided for @chatVaultCollect.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get chatVaultCollect;

  /// No description provided for @chatVaultSeeRewards.
  ///
  /// In pt, this message translates to:
  /// **'Ver recompensas'**
  String get chatVaultSeeRewards;

  /// No description provided for @chatVaultTapHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque no cofre!'**
  String get chatVaultTapHint;

  /// No description provided for @chatVaultTierCommon.
  ///
  /// In pt, this message translates to:
  /// **'Comum'**
  String get chatVaultTierCommon;

  /// No description provided for @chatVaultTierRare.
  ///
  /// In pt, this message translates to:
  /// **'Raro'**
  String get chatVaultTierRare;

  /// No description provided for @chatVaultTierEpic.
  ///
  /// In pt, this message translates to:
  /// **'Épico'**
  String get chatVaultTierEpic;

  /// No description provided for @chatVaultTierLegendary.
  ///
  /// In pt, this message translates to:
  /// **'Lendário'**
  String get chatVaultTierLegendary;

  /// No description provided for @chatVaultReplay.
  ///
  /// In pt, this message translates to:
  /// **'Ver de novo'**
  String get chatVaultReplay;

  /// No description provided for @onbStepOf.
  ///
  /// In pt, this message translates to:
  /// **'Passo {current} de {total}'**
  String onbStepOf(int current, int total);

  /// No description provided for @onbContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get onbContinue;

  /// No description provided for @onbSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onbSkip;

  /// No description provided for @onbSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get onbSignOut;

  /// No description provided for @onbError.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente de novo.'**
  String get onbError;

  /// No description provided for @onbBirthTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quando você nasceu?'**
  String get onbBirthTitle;

  /// No description provided for @onbBirthSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Precisamos confirmar sua idade. Ela não aparece no seu perfil.'**
  String get onbBirthSubtitle;

  /// No description provided for @onbUnderageTitle.
  ///
  /// In pt, this message translates to:
  /// **'A Brawe é para maiores de 18 anos'**
  String get onbUnderageTitle;

  /// No description provided for @onbUnderageBody.
  ///
  /// In pt, this message translates to:
  /// **'Pela segurança da comunidade, contas de menores de 18 anos não são permitidas.'**
  String get onbUnderageBody;

  /// No description provided for @onbUsernameTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha seu @'**
  String get onbUsernameTitle;

  /// No description provided for @onbUsernameSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'É assim que as pessoas vão te encontrar e te marcar.'**
  String get onbUsernameSubtitle;

  /// No description provided for @onbUsernameRules.
  ///
  /// In pt, this message translates to:
  /// **'3 a 30 caracteres: letras, números, ponto e _'**
  String get onbUsernameRules;

  /// No description provided for @onbUsernameChecking.
  ///
  /// In pt, this message translates to:
  /// **'Verificando…'**
  String get onbUsernameChecking;

  /// No description provided for @onbUsernameAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get onbUsernameAvailable;

  /// No description provided for @onbPhotoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma foto'**
  String get onbPhotoTitle;

  /// No description provided for @onbPhotoSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'As pessoas confiam mais em perfis com foto. Ela é necessária para usar a Brawe.'**
  String get onbPhotoSubtitle;

  /// No description provided for @onbPhotoGallery.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get onbPhotoGallery;

  /// No description provided for @onbPhotoCamera.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get onbPhotoCamera;

  /// No description provided for @onbPhotoChange.
  ///
  /// In pt, this message translates to:
  /// **'Trocar foto'**
  String get onbPhotoChange;

  /// No description provided for @onbPhotoPosition.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste sua foto'**
  String get onbPhotoPosition;

  /// No description provided for @onbPhotoError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar a foto. Tente de novo.'**
  String get onbPhotoError;

  /// No description provided for @onbBioTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conte um pouco sobre você'**
  String get onbBioTitle;

  /// No description provided for @onbBioSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Uma frase curta para a sua bio. Dá para mudar depois.'**
  String get onbBioSubtitle;

  /// No description provided for @onbBioHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Música, games e live toda sexta 🎮'**
  String get onbBioHint;

  /// No description provided for @onbFollowTitle.
  ///
  /// In pt, this message translates to:
  /// **'Siga pessoas'**
  String get onbFollowTitle;

  /// No description provided for @onbFollowSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Siga pelo menos 3 pessoas para ver conteúdo no seu feed.'**
  String get onbFollowSubtitle;

  /// No description provided for @onbFollow.
  ///
  /// In pt, this message translates to:
  /// **'Seguir'**
  String get onbFollow;

  /// No description provided for @onbFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get onbFollowing;

  /// No description provided for @onbFollowAll.
  ///
  /// In pt, this message translates to:
  /// **'Seguir todos'**
  String get onbFollowAll;

  /// No description provided for @onbFollowers.
  ///
  /// In pt, this message translates to:
  /// **'{count} seguidores'**
  String onbFollowers(String count);

  /// No description provided for @onbFollowEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não temos sugestões. Você pode encontrar pessoas depois em \"Encontrar amigos\".'**
  String get onbFollowEmpty;

  /// No description provided for @onbFinish.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get onbFinish;

  /// No description provided for @onbInterestsTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que você curte?'**
  String get onbInterestsTitle;

  /// No description provided for @onbInterestsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha os assuntos que você quer ver. Usamos isso para sugerir pessoas e conteúdos.'**
  String get onbInterestsSubtitle;

  /// No description provided for @onbInterestsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} selecionados'**
  String onbInterestsCount(int count);

  /// No description provided for @videoPubTrim.
  ///
  /// In pt, this message translates to:
  /// **'Cortar'**
  String get videoPubTrim;

  /// No description provided for @videoPubCover.
  ///
  /// In pt, this message translates to:
  /// **'Capa'**
  String get videoPubCover;

  /// No description provided for @videoPubCoverAuto.
  ///
  /// In pt, this message translates to:
  /// **'Capa automática'**
  String get videoPubCoverAuto;

  /// No description provided for @videoPubCoverCustom.
  ///
  /// In pt, this message translates to:
  /// **'Capa personalizada'**
  String get videoPubCoverCustom;

  /// No description provided for @videoPubCoverFrame.
  ///
  /// In pt, this message translates to:
  /// **'Quadro do vídeo'**
  String get videoPubCoverFrame;

  /// No description provided for @videoPubCoverGallery.
  ///
  /// In pt, this message translates to:
  /// **'Imagem da galeria'**
  String get videoPubCoverGallery;

  /// No description provided for @videoPubCoverRemove.
  ///
  /// In pt, this message translates to:
  /// **'Usar capa automática'**
  String get videoPubCoverRemove;

  /// No description provided for @videoPubCoverTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolher capa'**
  String get videoPubCoverTitle;

  /// No description provided for @videoPubCoverFrameHint.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para escolher o quadro da capa'**
  String get videoPubCoverFrameHint;

  /// No description provided for @videoPubCoverUse.
  ///
  /// In pt, this message translates to:
  /// **'Usar esta capa'**
  String get videoPubCoverUse;

  /// No description provided for @videoPubCoverCrop.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar capa'**
  String get videoPubCoverCrop;

  /// No description provided for @videoPubCoverError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gerar a capa. Tente outro quadro ou imagem.'**
  String get videoPubCoverError;

  /// No description provided for @videoPubStepVideo.
  ///
  /// In pt, this message translates to:
  /// **'Enviando vídeo...'**
  String get videoPubStepVideo;

  /// No description provided for @videoPubStepCover.
  ///
  /// In pt, this message translates to:
  /// **'Enviando capa...'**
  String get videoPubStepCover;

  /// No description provided for @videoPubStepPost.
  ///
  /// In pt, this message translates to:
  /// **'Publicando...'**
  String get videoPubStepPost;

  /// No description provided for @videoPubCoverUploadError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao enviar a capa. Verifique sua conexão e tente de novo.'**
  String get videoPubCoverUploadError;

  /// No description provided for @videoPubTooLong.
  ///
  /// In pt, this message translates to:
  /// **'O vídeo passa de 3 minutos. Corte o vídeo para publicar.'**
  String get videoPubTooLong;

  /// No description provided for @videoPubTrimPrepareError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível preparar o vídeo cortado. Tente novamente.'**
  String get videoPubTrimPrepareError;

  /// No description provided for @signupErrName.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu nome (mínimo 2 letras).'**
  String get signupErrName;

  /// No description provided for @signupErrEmail.
  ///
  /// In pt, this message translates to:
  /// **'Digite um e-mail válido.'**
  String get signupErrEmail;

  /// No description provided for @signupErrPassword.
  ///
  /// In pt, this message translates to:
  /// **'A senha precisa ter pelo menos 8 caracteres.'**
  String get signupErrPassword;

  /// No description provided for @signupErrTerms.
  ///
  /// In pt, this message translates to:
  /// **'Você precisa aceitar os Termos e a Política de Privacidade.'**
  String get signupErrTerms;

  /// No description provided for @signupErrEmailTaken.
  ///
  /// In pt, this message translates to:
  /// **'Este e-mail já tem conta. Entre com ele ou recupere a senha.'**
  String get signupErrEmailTaken;

  /// No description provided for @signupSendingCode.
  ///
  /// In pt, this message translates to:
  /// **'Enviando código…'**
  String get signupSendingCode;

  /// No description provided for @codeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirme seu e-mail'**
  String get codeTitle;

  /// No description provided for @codeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um código de 6 dígitos para\n{email}'**
  String codeSubtitle(String email);

  /// No description provided for @codeVerifying.
  ///
  /// In pt, this message translates to:
  /// **'Verificando…'**
  String get codeVerifying;

  /// No description provided for @codeInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Código incorreto. Restam {count} tentativas.'**
  String codeInvalid(int count);

  /// No description provided for @codeInvalidSimple.
  ///
  /// In pt, this message translates to:
  /// **'Código incorreto.'**
  String get codeInvalidSimple;

  /// No description provided for @codeExpired.
  ///
  /// In pt, this message translates to:
  /// **'O código expirou. Peça um novo.'**
  String get codeExpired;

  /// No description provided for @codeTooMany.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Peça um novo código.'**
  String get codeTooMany;

  /// No description provided for @codeResend.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar código'**
  String get codeResend;

  /// No description provided for @codeResendIn.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar em {seconds}s'**
  String codeResendIn(int seconds);

  /// No description provided for @codeResent.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um novo código.'**
  String get codeResent;

  /// No description provided for @codeChangeEmail.
  ///
  /// In pt, this message translates to:
  /// **'Trocar e-mail'**
  String get codeChangeEmail;

  /// No description provided for @codeSpamHint.
  ///
  /// In pt, this message translates to:
  /// **'Não chegou? Confira a caixa de spam ou promoções.'**
  String get codeSpamHint;

  /// No description provided for @codeError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o código. Tente de novo.'**
  String get codeError;

  /// No description provided for @codeTooManyRequests.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas a partir desta rede. Tente de novo em alguns minutos.'**
  String get codeTooManyRequests;

  /// No description provided for @settingsThemeAutoHint.
  ///
  /// In pt, this message translates to:
  /// **'Segue o modo claro/escuro do seu celular. Com a troca automática do celular ligada, muda sozinho ao anoitecer e ao amanhecer.'**
  String get settingsThemeAutoHint;

  /// No description provided for @battleYou.
  ///
  /// In pt, this message translates to:
  /// **'Você'**
  String get battleYou;

  /// No description provided for @battleMuteOpponent.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar adversário'**
  String get battleMuteOpponent;

  /// No description provided for @battleUnmuteOpponent.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir adversário'**
  String get battleUnmuteOpponent;

  /// No description provided for @battleListenTo.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir {name}'**
  String battleListenTo(String name);

  /// No description provided for @battleRematch.
  ///
  /// In pt, this message translates to:
  /// **'Pedir revanche'**
  String get battleRematch;

  /// No description provided for @battleRematchSent.
  ///
  /// In pt, this message translates to:
  /// **'Convite de revanche enviado'**
  String get battleRematchSent;

  /// No description provided for @battleClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get battleClose;

  /// No description provided for @battleFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get battleFollowing;

  /// No description provided for @battleLeaveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da batalha?'**
  String get battleLeaveTitle;

  /// No description provided for @battleLeaveConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get battleLeaveConfirm;

  /// No description provided for @battleCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get battleCancel;

  /// No description provided for @battleLeave.
  ///
  /// In pt, this message translates to:
  /// **'Sair da batalha'**
  String get battleLeave;

  /// No description provided for @battleActionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Batalha'**
  String get battleActionLabel;

  /// No description provided for @battleActionActive.
  ///
  /// In pt, this message translates to:
  /// **'Em batalha'**
  String get battleActionActive;

  /// No description provided for @battleErrNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Verifique sua internet.'**
  String get battleErrNetwork;

  /// No description provided for @battleErrGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir. Tente novamente.'**
  String get battleErrGeneric;

  /// No description provided for @battleErrCooldown.
  ///
  /// In pt, this message translates to:
  /// **'Aguarde {seconds}s para convidar este criador de novo.'**
  String battleErrCooldown(int seconds);

  /// No description provided for @battleErrBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Não é possível convidar este criador.'**
  String get battleErrBlocked;

  /// No description provided for @battleErrBusy.
  ///
  /// In pt, this message translates to:
  /// **'Este criador está ocupado em outra batalha.'**
  String get battleErrBusy;

  /// No description provided for @battleErrExpired.
  ///
  /// In pt, this message translates to:
  /// **'Este convite expirou.'**
  String get battleErrExpired;

  /// No description provided for @battleErrAnswered.
  ///
  /// In pt, this message translates to:
  /// **'Este convite já foi respondido.'**
  String get battleErrAnswered;

  /// No description provided for @battleErrNotEligible.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não pode iniciar batalhas.'**
  String get battleErrNotEligible;

  /// No description provided for @battleErrSendInvite.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o convite.'**
  String get battleErrSendInvite;

  /// No description provided for @battleErrAccept.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível aceitar a batalha.'**
  String get battleErrAccept;

  /// No description provided for @battleErrRematch.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível pedir a revanche.'**
  String get battleErrRematch;

  /// No description provided for @battleErrEnd.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível sair da batalha.'**
  String get battleErrEnd;

  /// No description provided for @battleInviteExpiresIn.
  ///
  /// In pt, this message translates to:
  /// **'Expira em {seconds}s'**
  String battleInviteExpiresIn(int seconds);

  /// No description provided for @battleInviteAccepted.
  ///
  /// In pt, this message translates to:
  /// **'{name} aceitou! Prepare-se'**
  String battleInviteAccepted(String name);

  /// No description provided for @battleInviteDeclined.
  ///
  /// In pt, this message translates to:
  /// **'{name} recusou o convite'**
  String battleInviteDeclined(String name);

  /// No description provided for @battleInviteNoReply.
  ///
  /// In pt, this message translates to:
  /// **'{name} não respondeu a tempo'**
  String battleInviteNoReply(String name);

  /// No description provided for @battleInviteExpired.
  ///
  /// In pt, this message translates to:
  /// **'O convite de batalha expirou'**
  String get battleInviteExpired;

  /// No description provided for @battleInviteCancelled.
  ///
  /// In pt, this message translates to:
  /// **'O convite de batalha foi cancelado'**
  String get battleInviteCancelled;

  /// No description provided for @battleCancelledMsg.
  ///
  /// In pt, this message translates to:
  /// **'A batalha foi cancelada'**
  String get battleCancelledMsg;

  /// No description provided for @battleInviteNoAnswer.
  ///
  /// In pt, this message translates to:
  /// **'Sem resposta ao convite de batalha'**
  String get battleInviteNoAnswer;

  /// No description provided for @battleInviteWait.
  ///
  /// In pt, this message translates to:
  /// **'Aguarde a resposta do convite atual ou cancele-o'**
  String get battleInviteWait;

  /// No description provided for @battleOpponentFallback.
  ///
  /// In pt, this message translates to:
  /// **'O oponente'**
  String get battleOpponentFallback;

  /// No description provided for @battleSomeCreator.
  ///
  /// In pt, this message translates to:
  /// **'Um criador'**
  String get battleSomeCreator;

  /// No description provided for @battleRtcConnecting.
  ///
  /// In pt, this message translates to:
  /// **'Conectando com o adversário…'**
  String get battleRtcConnecting;

  /// No description provided for @battleRtcFallback.
  ///
  /// In pt, this message translates to:
  /// **'Sem tempo real: a batalha segue em modo normal.'**
  String get battleRtcFallback;

  /// No description provided for @battleOpponentCamera.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando câmera do adversário'**
  String get battleOpponentCamera;

  /// No description provided for @battleStartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar Batalha'**
  String get battleStartTitle;

  /// No description provided for @battleSheetSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Criadores ao vivo disponíveis agora'**
  String get battleSheetSubtitle;

  /// No description provided for @battleSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar criador ao vivo...'**
  String get battleSearchHint;

  /// No description provided for @battleLoadCandidatesFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar criadores ao vivo'**
  String get battleLoadCandidatesFailed;

  /// No description provided for @battleRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get battleRetry;

  /// No description provided for @battleNoCreatorQuery.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum criador disponível com \"{query}\"'**
  String battleNoCreatorQuery(String query);

  /// No description provided for @battleNoCreator.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum criador disponível para batalha agora.\nPuxe para atualizar.'**
  String get battleNoCreator;

  /// No description provided for @battleInviteCreator.
  ///
  /// In pt, this message translates to:
  /// **'Convidar {name}'**
  String battleInviteCreator(String name);

  /// No description provided for @battleSelectCreator.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um criador'**
  String get battleSelectCreator;

  /// No description provided for @battleLiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get battleLiveBadge;

  /// No description provided for @battleViewLive.
  ///
  /// In pt, this message translates to:
  /// **'Ver a live de {name}'**
  String battleViewLive(String name);

  /// No description provided for @battleWaitingAccept.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando {name} aceitar… {seconds}s'**
  String battleWaitingAccept(String name, int seconds);

  /// No description provided for @linkConnect.
  ///
  /// In pt, this message translates to:
  /// **'Conectar'**
  String get linkConnect;

  /// No description provided for @linkDisconnect.
  ///
  /// In pt, this message translates to:
  /// **'Desconectar'**
  String get linkDisconnect;

  /// No description provided for @linkStartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conectar com um criador'**
  String get linkStartTitle;

  /// No description provided for @linkInviteCreator.
  ///
  /// In pt, this message translates to:
  /// **'Conectar com {name}'**
  String linkInviteCreator(String name);

  /// No description provided for @linkInviteReceived.
  ///
  /// In pt, this message translates to:
  /// **'{name} quer se conectar com você'**
  String linkInviteReceived(String name);

  /// No description provided for @linkInviteWithBattle.
  ///
  /// In pt, this message translates to:
  /// **'Com batalha'**
  String get linkInviteWithBattle;

  /// No description provided for @linkInviteAccepted.
  ///
  /// In pt, this message translates to:
  /// **'{name} aceitou a conexão'**
  String linkInviteAccepted(String name);

  /// No description provided for @linkEnded.
  ///
  /// In pt, this message translates to:
  /// **'A conexão foi encerrada'**
  String get linkEnded;

  /// No description provided for @linkDisconnectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desconectar?'**
  String get linkDisconnectTitle;

  /// No description provided for @linkDisconnectBody.
  ///
  /// In pt, this message translates to:
  /// **'A conexão com {name} será encerrada. Se houver uma batalha em andamento, você desiste dela.'**
  String linkDisconnectBody(String name);

  /// No description provided for @linkFollowAction.
  ///
  /// In pt, this message translates to:
  /// **'+ Seguir'**
  String get linkFollowAction;

  /// No description provided for @linkErrDisconnect.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível desconectar.'**
  String get linkErrDisconnect;

  /// No description provided for @linkErrInvite.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o convite de conexão.'**
  String get linkErrInvite;

  /// No description provided for @linkErrAccept.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível aceitar a conexão.'**
  String get linkErrAccept;

  /// No description provided for @battleFlashChallenge.
  ///
  /// In pt, this message translates to:
  /// **'Envie {count} {gift} · {time}'**
  String battleFlashChallenge(int count, String gift, String time);

  /// No description provided for @battleFlashProgress.
  ///
  /// In pt, this message translates to:
  /// **'{done}/{total}'**
  String battleFlashProgress(int done, int total);

  /// No description provided for @battleFlashBoost.
  ///
  /// In pt, this message translates to:
  /// **'{mult}X ativo · {time}'**
  String battleFlashBoost(String mult, String time);

  /// No description provided for @battleSealWin.
  ///
  /// In pt, this message translates to:
  /// **'VITÓRIA'**
  String get battleSealWin;

  /// No description provided for @battleSealLose.
  ///
  /// In pt, this message translates to:
  /// **'DERROTA'**
  String get battleSealLose;

  /// No description provided for @battleSealDraw.
  ///
  /// In pt, this message translates to:
  /// **'EMPATE'**
  String get battleSealDraw;

  /// No description provided for @battleEndLabel.
  ///
  /// In pt, this message translates to:
  /// **'FIM'**
  String get battleEndLabel;

  /// No description provided for @battleMvpPill.
  ///
  /// In pt, this message translates to:
  /// **'MVP {name} · {score}'**
  String battleMvpPill(String name, String score);

  /// No description provided for @battleRuleHint.
  ///
  /// In pt, this message translates to:
  /// **'Envie presentes para pontuar'**
  String get battleRuleHint;

  /// No description provided for @viewLiveAction.
  ///
  /// In pt, this message translates to:
  /// **'Ver a live'**
  String get viewLiveAction;

  /// No description provided for @eventPageGiftsWorth.
  ///
  /// In pt, this message translates to:
  /// **'Presentes valem {mult} pontos'**
  String eventPageGiftsWorth(String mult);

  /// No description provided for @eventPageEndsIn.
  ///
  /// In pt, this message translates to:
  /// **'Termina em {time}'**
  String eventPageEndsIn(String time);

  /// No description provided for @eventPageYourPosition.
  ///
  /// In pt, this message translates to:
  /// **'Sua posição'**
  String get eventPageYourPosition;

  /// No description provided for @eventPageRankPoints.
  ///
  /// In pt, this message translates to:
  /// **'#{rank} · {points} pts'**
  String eventPageRankPoints(int rank, String points);

  /// No description provided for @eventPageToTop10.
  ///
  /// In pt, this message translates to:
  /// **'faltam {points} para o top 10'**
  String eventPageToTop10(String points);

  /// No description provided for @eventPageInTop10.
  ///
  /// In pt, this message translates to:
  /// **'Você está no top 10'**
  String get eventPageInTop10;

  /// No description provided for @eventPageNoRank.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não pontuou'**
  String get eventPageNoRank;

  /// No description provided for @eventPagePrizes.
  ///
  /// In pt, this message translates to:
  /// **'Prêmios'**
  String get eventPagePrizes;

  /// No description provided for @eventPageRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking do evento'**
  String get eventPageRanking;

  /// No description provided for @eventPageSeeFull.
  ///
  /// In pt, this message translates to:
  /// **'Ver ranking completo'**
  String get eventPageSeeFull;

  /// No description provided for @eventPageGifts.
  ///
  /// In pt, this message translates to:
  /// **'Presentes do evento'**
  String get eventPageGifts;

  /// No description provided for @eventPageSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar presente'**
  String get eventPageSend;

  /// No description provided for @eventPageHow.
  ///
  /// In pt, this message translates to:
  /// **'Como funciona'**
  String get eventPageHow;

  /// No description provided for @eventPagePrizeRank.
  ///
  /// In pt, this message translates to:
  /// **'{from}º–{to}º'**
  String eventPagePrizeRank(int from, int to);

  /// No description provided for @eventPagePrizeOne.
  ///
  /// In pt, this message translates to:
  /// **'{rank}º'**
  String eventPagePrizeOne(int rank);

  /// No description provided for @battleEndedTitle.
  ///
  /// In pt, this message translates to:
  /// **'BATALHA ENCERRADA'**
  String get battleEndedTitle;

  /// No description provided for @battleEndedLeft.
  ///
  /// In pt, this message translates to:
  /// **'{name} saiu da batalha'**
  String battleEndedLeft(String name);

  /// No description provided for @battleEndedLive.
  ///
  /// In pt, this message translates to:
  /// **'A live de {name} caiu'**
  String battleEndedLive(String name);

  /// No description provided for @battleEndedRtc.
  ///
  /// In pt, this message translates to:
  /// **'A conexão caiu'**
  String get battleEndedRtc;

  /// No description provided for @battleLeaveBodyStreak.
  ///
  /// In pt, this message translates to:
  /// **'Se você sair agora, ninguém vence e você perde sua sequência de {n} vitórias.'**
  String battleLeaveBodyStreak(int n);

  /// No description provided for @battleLeaveBodyNoStreak.
  ///
  /// In pt, this message translates to:
  /// **'Se você sair agora, ninguém vence.'**
  String get battleLeaveBodyNoStreak;

  /// No description provided for @battleMutedLine.
  ///
  /// In pt, this message translates to:
  /// **'Você e seu público não ouvem {name}'**
  String battleMutedLine(String name);

  /// No description provided for @battleMutedByLine.
  ///
  /// In pt, this message translates to:
  /// **'{name} silenciou você'**
  String battleMutedByLine(String name);

  /// No description provided for @battlePauseUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Pausar não está disponível durante a conexão ou a batalha'**
  String get battlePauseUnavailable;

  /// No description provided for @battleEndedLeftAnon.
  ///
  /// In pt, this message translates to:
  /// **'Um criador saiu da batalha'**
  String get battleEndedLeftAnon;

  /// No description provided for @battleEndedLiveAnon.
  ///
  /// In pt, this message translates to:
  /// **'A live de um criador caiu'**
  String get battleEndedLiveAnon;

  /// No description provided for @battleNarrStart.
  ///
  /// In pt, this message translates to:
  /// **'A batalha começou! Cada presente conta'**
  String get battleNarrStart;

  /// No description provided for @battleNarrLeadOwn.
  ///
  /// In pt, this message translates to:
  /// **'VIROU! {team} passou na frente'**
  String battleNarrLeadOwn(String team);

  /// No description provided for @battleNarrLeadOther.
  ///
  /// In pt, this message translates to:
  /// **'{team} passou na frente. Bora virar!'**
  String battleNarrLeadOther(String team);

  /// No description provided for @battleNarrMomentum.
  ///
  /// In pt, this message translates to:
  /// **'{team} está pegando fogo'**
  String battleNarrMomentum(String team);

  /// No description provided for @battleNarrFlashStart.
  ///
  /// In pt, this message translates to:
  /// **'Desafio relâmpago: envie {pontos} {nome} em {tempo}'**
  String battleNarrFlashStart(String pontos, String nome, String tempo);

  /// No description provided for @battleNarrFlashDone.
  ///
  /// In pt, this message translates to:
  /// **'Desafio feito! {mult} por {tempo}'**
  String battleNarrFlashDone(String mult, String tempo);

  /// No description provided for @battleNarrFinal10.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 10 segundos! Cada presente vale {mult}'**
  String battleNarrFinal10(String mult);

  /// No description provided for @battleNarrVictory.
  ///
  /// In pt, this message translates to:
  /// **'VITÓRIA de {team}!'**
  String battleNarrVictory(String team);

  /// No description provided for @battleNarrDefeat.
  ///
  /// In pt, this message translates to:
  /// **'Fim! {team} venceu desta vez'**
  String battleNarrDefeat(String team);

  /// No description provided for @battleNarrDraw.
  ///
  /// In pt, this message translates to:
  /// **'EMPATE!'**
  String get battleNarrDraw;

  /// No description provided for @battleNarrEnded.
  ///
  /// In pt, this message translates to:
  /// **'Batalha encerrada'**
  String get battleNarrEnded;

  /// No description provided for @agencyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Minha agência'**
  String get agencyTitle;

  /// No description provided for @agencyPendingInvites.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 convite} other{{count} convites}}'**
  String agencyPendingInvites(int count);

  /// No description provided for @agencyEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Agências ajudam criadores a crescer: acompanham seus resultados, organizam eventos e apoiam sua rotina de lives.'**
  String get agencyEmptyBody;

  /// No description provided for @agencyInfoEarningsBody.
  ///
  /// In pt, this message translates to:
  /// **'A Brawe continua pagando seus ganhos diretamente a você. A comissão da agência é paga pela Brawe, nunca descontada de você.'**
  String get agencyInfoEarningsBody;

  /// No description provided for @agencyInfoOneBody.
  ///
  /// In pt, this message translates to:
  /// **'Você só pode estar em uma agência. Ao aceitar um convite, os outros pendentes são cancelados.'**
  String get agencyInfoOneBody;

  /// No description provided for @agencyOpenBody.
  ///
  /// In pt, this message translates to:
  /// **'Agências podem encontrar você no diretório de criadores e enviar convites. Você decide se aceita.'**
  String get agencyOpenBody;

  /// No description provided for @agencyInvitesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convites pendentes'**
  String get agencyInvitesTitle;

  /// No description provided for @agencyInviteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convite de agência'**
  String get agencyInviteTitle;

  /// No description provided for @agencyContractMonths.
  ///
  /// In pt, this message translates to:
  /// **'{months, plural, =1{1 mês} other{{months} meses}}'**
  String agencyContractMonths(int months);

  /// No description provided for @agencyContractOf.
  ///
  /// In pt, this message translates to:
  /// **'Contrato de {duration}'**
  String agencyContractOf(String duration);

  /// No description provided for @agencyContractLength.
  ///
  /// In pt, this message translates to:
  /// **'Duração do contrato'**
  String get agencyContractLength;

  /// No description provided for @agencyInvitedByTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem convidou'**
  String get agencyInvitedByTitle;

  /// No description provided for @agencyRoleOwner.
  ///
  /// In pt, this message translates to:
  /// **'Dono da agência'**
  String get agencyRoleOwner;

  /// No description provided for @agencyRoleManager.
  ///
  /// In pt, this message translates to:
  /// **'Gerente da agência (recrutador)'**
  String get agencyRoleManager;

  /// No description provided for @agencyRoleAnalyst.
  ///
  /// In pt, this message translates to:
  /// **'Equipe da agência'**
  String get agencyRoleAnalyst;

  /// No description provided for @agencyRoleUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Representante da agência'**
  String get agencyRoleUnknown;

  /// No description provided for @agencyInvitedOn.
  ///
  /// In pt, this message translates to:
  /// **'Convite enviado em {date}'**
  String agencyInvitedOn(String date);

  /// No description provided for @agencyMessageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem da agência'**
  String get agencyMessageTitle;

  /// No description provided for @agencyWhatChangesTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que muda para você'**
  String get agencyWhatChangesTitle;

  /// No description provided for @agencyTermsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Termos e condições'**
  String get agencyTermsTitle;

  /// No description provided for @agencyTermsVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão {version}'**
  String agencyTermsVersion(String version);

  /// No description provided for @agencyTermsStandard.
  ///
  /// In pt, this message translates to:
  /// **'Termos padrão Brawe'**
  String get agencyTermsStandard;

  /// No description provided for @agencyTermsAddendum.
  ///
  /// In pt, this message translates to:
  /// **'Adendo da agência'**
  String get agencyTermsAddendum;

  /// No description provided for @agencyTermsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Termos indisponíveis no momento.'**
  String get agencyTermsEmpty;

  /// No description provided for @agencyAcceptCheckbox.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito os termos e condições (versão {version})'**
  String agencyAcceptCheckbox(String version);

  /// No description provided for @agencyAcceptButton.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar convite'**
  String get agencyAcceptButton;

  /// No description provided for @agencyDeclineButton.
  ///
  /// In pt, this message translates to:
  /// **'Recusar'**
  String get agencyDeclineButton;

  /// No description provided for @agencyAcceptConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar na {name}?'**
  String agencyAcceptConfirmTitle(String name);

  /// No description provided for @agencyAcceptConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Seu vínculo começa hoje. Antes do fim do contrato, a saída é feita em acordo com a agência.'**
  String get agencyAcceptConfirmBody;

  /// No description provided for @agencyDeclineConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recusar convite?'**
  String get agencyDeclineConfirmTitle;

  /// No description provided for @agencyDeclineConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Recusar não tem nenhum efeito na sua conta. A agência verá que o convite foi recusado.'**
  String get agencyDeclineConfirmBody;

  /// No description provided for @agencyAcceptedSnack.
  ///
  /// In pt, this message translates to:
  /// **'Você agora faz parte de {name}'**
  String agencyAcceptedSnack(String name);

  /// No description provided for @agencyDeclinedSnack.
  ///
  /// In pt, this message translates to:
  /// **'Convite recusado'**
  String get agencyDeclinedSnack;

  /// No description provided for @agencyLeftSnack.
  ///
  /// In pt, this message translates to:
  /// **'Você saiu da agência'**
  String get agencyLeftSnack;

  /// No description provided for @agencyInviteUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Este convite não está mais disponível.'**
  String get agencyInviteUnavailable;

  /// No description provided for @agencyCreatorsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 criador} other{{count} criadores}}'**
  String agencyCreatorsCount(int count);

  /// No description provided for @agencyPartnerSince.
  ///
  /// In pt, this message translates to:
  /// **'Parceira desde {date}'**
  String agencyPartnerSince(String date);

  /// No description provided for @agencyTrialBadge.
  ///
  /// In pt, this message translates to:
  /// **'Em teste'**
  String get agencyTrialBadge;

  /// No description provided for @agencyContractTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contrato'**
  String get agencyContractTitle;

  /// No description provided for @agencyContractPeriod.
  ///
  /// In pt, this message translates to:
  /// **'{start} a {end}'**
  String agencyContractPeriod(String start, String end);

  /// No description provided for @agencyDaysLeft.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =0{Termina hoje} =1{Falta 1 dia} other{Faltam {days} dias}}'**
  String agencyDaysLeft(int days);

  /// No description provided for @agencyContractProgress.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% do contrato'**
  String agencyContractProgress(int percent);

  /// No description provided for @agencyHours.
  ///
  /// In pt, this message translates to:
  /// **'Horas ao vivo'**
  String get agencyHours;

  /// No description provided for @agencyDaysLive.
  ///
  /// In pt, this message translates to:
  /// **'Dias com live'**
  String get agencyDaysLive;

  /// No description provided for @agencyDiamonds.
  ///
  /// In pt, this message translates to:
  /// **'Diamantes'**
  String get agencyDiamonds;

  /// No description provided for @agencyFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get agencyFollowers;

  /// No description provided for @agencyRankValue.
  ///
  /// In pt, this message translates to:
  /// **'#{rank} de {total}'**
  String agencyRankValue(int rank, int total);

  /// No description provided for @agencyGuidelinesNotMet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda faltam metas neste mês'**
  String get agencyGuidelinesNotMet;

  /// No description provided for @agencyMissingHours.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {value} h'**
  String agencyMissingHours(String value);

  /// No description provided for @agencyMissingDays.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =1{Falta 1 dia} other{Faltam {days} dias}}'**
  String agencyMissingDays(int days);

  /// No description provided for @agencyNoIncidents.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma ocorrência'**
  String get agencyNoIncidents;

  /// No description provided for @agencyIncidentWarning.
  ///
  /// In pt, this message translates to:
  /// **'Advertência'**
  String get agencyIncidentWarning;

  /// No description provided for @agencyIncidentSuspension.
  ///
  /// In pt, this message translates to:
  /// **'Suspensão'**
  String get agencyIncidentSuspension;

  /// No description provided for @agencyIncidentBan.
  ///
  /// In pt, this message translates to:
  /// **'Banimento'**
  String get agencyIncidentBan;

  /// No description provided for @agencyIncidentFraud.
  ///
  /// In pt, this message translates to:
  /// **'Fraude'**
  String get agencyIncidentFraud;

  /// No description provided for @agencyEventsHow.
  ///
  /// In pt, this message translates to:
  /// **'Entre ao vivo durante o período do evento para participar.'**
  String get agencyEventsHow;

  /// No description provided for @agencyEventLive.
  ///
  /// In pt, this message translates to:
  /// **'Ao vivo'**
  String get agencyEventLive;

  /// No description provided for @agencyEventScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get agencyEventScheduled;

  /// No description provided for @agencyEventEnded.
  ///
  /// In pt, this message translates to:
  /// **'Encerrado'**
  String get agencyEventEnded;

  /// No description provided for @agencyEventMultiplier.
  ///
  /// In pt, this message translates to:
  /// **'Multiplicador x{value}'**
  String agencyEventMultiplier(String value);

  /// No description provided for @agencyLeaveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da agência'**
  String get agencyLeaveTitle;

  /// No description provided for @agencyLeaveAllowed.
  ///
  /// In pt, this message translates to:
  /// **'Você pode sair agora, sem multa. Seus ganhos e sua conta não mudam.'**
  String get agencyLeaveAllowed;

  /// No description provided for @agencyLeaveButton.
  ///
  /// In pt, this message translates to:
  /// **'Sair da agência'**
  String get agencyLeaveButton;

  /// No description provided for @agencyLeaveConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair de {name}?'**
  String agencyLeaveConfirmTitle(String name);

  /// No description provided for @agencyLeaveConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'O vínculo será encerrado. Isso não pode ser desfeito: para voltar, você precisará receber um novo convite.'**
  String get agencyLeaveConfirmBody;

  /// No description provided for @agencyLeaveConfirmAction.
  ///
  /// In pt, this message translates to:
  /// **'Sair agora'**
  String get agencyLeaveConfirmAction;

  /// No description provided for @agencyExitRuleFree.
  ///
  /// In pt, this message translates to:
  /// **'No fim do contrato você sai livremente, pelo app.'**
  String get agencyExitRuleFree;

  /// No description provided for @agencyExitRuleAbuse.
  ///
  /// In pt, this message translates to:
  /// **'Em caso de abuso (cobranças, pagamentos fora da Brawe, pressão), peça uma análise da Brawe.'**
  String get agencyExitRuleAbuse;

  /// No description provided for @agencyLeaveSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Saída da agência'**
  String get agencyLeaveSectionTitle;

  /// No description provided for @agencyLeaveRequestBody.
  ///
  /// In pt, this message translates to:
  /// **'Seu contrato vai até {date}. Para sair antes, você pede o desligamento em acordo com a agência. Se ela não responder no prazo, você fica livre automaticamente.'**
  String agencyLeaveRequestBody(String date);

  /// No description provided for @agencyLeaveRequestBodyNoDate.
  ///
  /// In pt, this message translates to:
  /// **'Para sair antes do fim do contrato, você pede o desligamento em acordo com a agência. Se ela não responder no prazo, você fica livre automaticamente.'**
  String get agencyLeaveRequestBodyNoDate;

  /// No description provided for @agencyLeaveRequestButton.
  ///
  /// In pt, this message translates to:
  /// **'Pedir desligamento à agência'**
  String get agencyLeaveRequestButton;

  /// No description provided for @agencyLeaveRequestSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedir desligamento'**
  String get agencyLeaveRequestSheetTitle;

  /// No description provided for @agencyLeaveRequestSheetBody.
  ///
  /// In pt, this message translates to:
  /// **'A agência recebe seu pedido e responde. Se aprovar, o vínculo termina na hora. Se não responder no prazo, você fica livre automaticamente.'**
  String get agencyLeaveRequestSheetBody;

  /// No description provided for @agencyLeaveReasonLabel.
  ///
  /// In pt, this message translates to:
  /// **'Motivo'**
  String get agencyLeaveReasonLabel;

  /// No description provided for @agencyLeaveReasonHint.
  ///
  /// In pt, this message translates to:
  /// **'Conte à agência por que quer sair'**
  String get agencyLeaveReasonHint;

  /// No description provided for @agencyLeaveRequestSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar pedido'**
  String get agencyLeaveRequestSend;

  /// No description provided for @agencyLeaveRequestSentSnack.
  ///
  /// In pt, this message translates to:
  /// **'Pedido enviado à agência.'**
  String get agencyLeaveRequestSentSnack;

  /// No description provided for @agencyLeavePendingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedido de desligamento enviado'**
  String get agencyLeavePendingTitle;

  /// No description provided for @agencyLeavePendingSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviado em {date}. Aguardando a resposta da agência.'**
  String agencyLeavePendingSent(String date);

  /// No description provided for @agencyLeavePendingDue.
  ///
  /// In pt, this message translates to:
  /// **'Se a agência não responder até {date}, você fica livre automaticamente.'**
  String agencyLeavePendingDue(String date);

  /// No description provided for @agencyLeavePendingBrawe.
  ///
  /// In pt, this message translates to:
  /// **'Seu pedido está em análise da Brawe.'**
  String get agencyLeavePendingBrawe;

  /// No description provided for @agencyReviewPendingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Análise da Brawe solicitada'**
  String get agencyReviewPendingTitle;

  /// No description provided for @agencyLeaveCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar pedido'**
  String get agencyLeaveCancel;

  /// No description provided for @agencyLeaveCancelledSnack.
  ///
  /// In pt, this message translates to:
  /// **'Pedido cancelado.'**
  String get agencyLeaveCancelledSnack;

  /// No description provided for @agencyLeaveDeclinedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedido recusado'**
  String get agencyLeaveDeclinedTitle;

  /// No description provided for @agencyLeaveDeclinedBody.
  ///
  /// In pt, this message translates to:
  /// **'A agência não aprovou a sua saída por enquanto.'**
  String get agencyLeaveDeclinedBody;

  /// No description provided for @agencyLeaveAgencyAnswer.
  ///
  /// In pt, this message translates to:
  /// **'Resposta da agência'**
  String get agencyLeaveAgencyAnswer;

  /// No description provided for @agencyLeaveRetryAt.
  ///
  /// In pt, this message translates to:
  /// **'Você poderá pedir de novo a partir de {date}.'**
  String agencyLeaveRetryAt(String date);

  /// No description provided for @agencyReviewLink.
  ///
  /// In pt, this message translates to:
  /// **'Pedir análise da Brawe'**
  String get agencyReviewLink;

  /// No description provided for @agencyReviewSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedir análise da Brawe'**
  String get agencyReviewSheetTitle;

  /// No description provided for @agencyReviewSheetBody.
  ///
  /// In pt, this message translates to:
  /// **'Use só se houver abuso. A Brawe analisa direto, sem passar pela agência, e pode encerrar o vínculo.'**
  String get agencyReviewSheetBody;

  /// No description provided for @agencyReviewCategoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'O que está acontecendo?'**
  String get agencyReviewCategoryLabel;

  /// No description provided for @agencyReviewCatMoney.
  ///
  /// In pt, this message translates to:
  /// **'A agência cobra dinheiro de mim'**
  String get agencyReviewCatMoney;

  /// No description provided for @agencyReviewCatOffplatform.
  ///
  /// In pt, this message translates to:
  /// **'Pedem pagamentos fora da Brawe'**
  String get agencyReviewCatOffplatform;

  /// No description provided for @agencyReviewCatPressure.
  ///
  /// In pt, this message translates to:
  /// **'Pressão ou assédio'**
  String get agencyReviewCatPressure;

  /// No description provided for @agencyReviewCatSuspended.
  ///
  /// In pt, this message translates to:
  /// **'A agência foi suspensa ou banida'**
  String get agencyReviewCatSuspended;

  /// No description provided for @agencyReviewCatOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro motivo'**
  String get agencyReviewCatOther;

  /// No description provided for @agencyReviewDetailLabel.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get agencyReviewDetailLabel;

  /// No description provided for @agencyReviewSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar à Brawe'**
  String get agencyReviewSend;

  /// No description provided for @agencyReviewSentSnack.
  ///
  /// In pt, this message translates to:
  /// **'Pedido enviado. A Brawe vai analisar.'**
  String get agencyReviewSentSnack;

  /// No description provided for @agencyErrLeaveRequiresAgreement.
  ///
  /// In pt, this message translates to:
  /// **'Antes do fim do contrato, peça o desligamento à agência.'**
  String get agencyErrLeaveRequiresAgreement;

  /// No description provided for @agencyErrLeaveRequestOpen.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem um pedido em aberto.'**
  String get agencyErrLeaveRequestOpen;

  /// No description provided for @agencyErrLeaveCooldown.
  ///
  /// In pt, this message translates to:
  /// **'Você poderá pedir de novo a partir de {date}.'**
  String agencyErrLeaveCooldown(String date);

  /// No description provided for @agencyErrLeaveCooldownNoDate.
  ///
  /// In pt, this message translates to:
  /// **'Aguarde um pouco para pedir de novo.'**
  String get agencyErrLeaveCooldownNoDate;

  /// No description provided for @agencyErrLeaveNotOpen.
  ///
  /// In pt, this message translates to:
  /// **'Este pedido já foi respondido ou cancelado.'**
  String get agencyErrLeaveNotOpen;

  /// No description provided for @agencyErrReasonTooLong.
  ///
  /// In pt, this message translates to:
  /// **'O texto passa de 500 caracteres.'**
  String get agencyErrReasonTooLong;

  /// No description provided for @agencyReasonMinHint.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de 10 caracteres'**
  String get agencyReasonMinHint;

  /// No description provided for @agencyErrReasonTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Escreva pelo menos 10 caracteres.'**
  String get agencyErrReasonTooShort;

  /// No description provided for @agencyErrReasonRequired.
  ///
  /// In pt, this message translates to:
  /// **'Escreva o motivo.'**
  String get agencyErrReasonRequired;

  /// No description provided for @agencyErrLeaveIsFree.
  ///
  /// In pt, this message translates to:
  /// **'O contrato terminou: você já pode sair direto.'**
  String get agencyErrLeaveIsFree;

  /// No description provided for @agencyLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar sua agência'**
  String get agencyLoadError;

  /// No description provided for @agencyErrTermsMismatch.
  ///
  /// In pt, this message translates to:
  /// **'Os termos foram atualizados. Leia a versão atual e tente de novo.'**
  String get agencyErrTermsMismatch;

  /// No description provided for @agencyErrCannotLeaveYet.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não pode sair. Liberado em {date}.'**
  String agencyErrCannotLeaveYet(String date);

  /// No description provided for @agencyErrCannotLeaveYetNoDate.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não pode sair da agência.'**
  String get agencyErrCannotLeaveYetNoDate;

  /// No description provided for @agencyErrAlreadyInAgency.
  ///
  /// In pt, this message translates to:
  /// **'Você já está em uma agência.'**
  String get agencyErrAlreadyInAgency;

  /// No description provided for @agencyErrNotApproved.
  ///
  /// In pt, this message translates to:
  /// **'Esta agência não está disponível no momento.'**
  String get agencyErrNotApproved;

  /// No description provided for @agencyErrNotEligible.
  ///
  /// In pt, this message translates to:
  /// **'Seu perfil de criador não está ativo.'**
  String get agencyErrNotEligible;

  /// No description provided for @agencyErrNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Convite não encontrado.'**
  String get agencyErrNotFound;

  /// No description provided for @agencyErrNotInAgency.
  ///
  /// In pt, this message translates to:
  /// **'Você não está em uma agência.'**
  String get agencyErrNotInAgency;

  /// No description provided for @agencyErrNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Verifique sua internet e tente de novo.'**
  String get agencyErrNetwork;

  /// No description provided for @agencyErrGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente novamente.'**
  String get agencyErrGeneric;

  /// No description provided for @agencyChatInvitedYou.
  ///
  /// In pt, this message translates to:
  /// **'convidou você para a agência'**
  String get agencyChatInvitedYou;

  /// No description provided for @agencyChatInviteSent.
  ///
  /// In pt, this message translates to:
  /// **'Convite enviado ao criador'**
  String get agencyChatInviteSent;

  /// No description provided for @agencyChatOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir convite'**
  String get agencyChatOpen;

  /// No description provided for @agencyChatPreview.
  ///
  /// In pt, this message translates to:
  /// **'Convite de agência'**
  String get agencyChatPreview;

  /// No description provided for @creatorPanelTabHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get creatorPanelTabHome;

  /// No description provided for @creatorPanelTabPerformance.
  ///
  /// In pt, this message translates to:
  /// **'Desempenho'**
  String get creatorPanelTabPerformance;

  /// No description provided for @creatorPanelTabAgency.
  ///
  /// In pt, this message translates to:
  /// **'Agência'**
  String get creatorPanelTabAgency;

  /// No description provided for @creatorPanelTabBenefits.
  ///
  /// In pt, this message translates to:
  /// **'Benefícios'**
  String get creatorPanelTabBenefits;

  /// No description provided for @creatorPanelEarnings30.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos em 30 dias'**
  String get creatorPanelEarnings30;

  /// No description provided for @creatorPanelNextLevel.
  ///
  /// In pt, this message translates to:
  /// **'Próximo nível'**
  String get creatorPanelNextLevel;

  /// No description provided for @creatorPanelAgenciesRow.
  ///
  /// In pt, this message translates to:
  /// **'Agências'**
  String get creatorPanelAgenciesRow;

  /// No description provided for @creatorPanelAgenciesOpen.
  ///
  /// In pt, this message translates to:
  /// **'Aberto a convites'**
  String get creatorPanelAgenciesOpen;

  /// No description provided for @creatorPanelHowItWorks.
  ///
  /// In pt, this message translates to:
  /// **'Como funciona'**
  String get creatorPanelHowItWorks;

  /// No description provided for @creatorPanelHowTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como funcionam as agências'**
  String get creatorPanelHowTitle;

  /// No description provided for @creatorPanelAnalyticsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Análises completas'**
  String get creatorPanelAnalyticsTitle;

  /// No description provided for @creatorPanelAnalyticsBody.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos, público, seguidores e lives'**
  String get creatorPanelAnalyticsBody;

  /// No description provided for @creatorPanelProfileFallback.
  ///
  /// In pt, this message translates to:
  /// **'Criador'**
  String get creatorPanelProfileFallback;

  /// No description provided for @creatorPanelOpenError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Tente de novo.'**
  String get creatorPanelOpenError;

  /// No description provided for @agencySince.
  ///
  /// In pt, this message translates to:
  /// **'Agenciado desde {date}'**
  String agencySince(String date);

  /// No description provided for @agencyTalk.
  ///
  /// In pt, this message translates to:
  /// **'Falar'**
  String get agencyTalk;

  /// No description provided for @agencyTalkError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a conversa.'**
  String get agencyTalkError;

  /// No description provided for @agencySubSummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo'**
  String get agencySubSummary;

  /// No description provided for @agencySubGoals.
  ///
  /// In pt, this message translates to:
  /// **'Metas'**
  String get agencySubGoals;

  /// No description provided for @agencySubEvents.
  ///
  /// In pt, this message translates to:
  /// **'Eventos'**
  String get agencySubEvents;

  /// No description provided for @agencySubContract.
  ///
  /// In pt, this message translates to:
  /// **'Contrato'**
  String get agencySubContract;

  /// No description provided for @agencyPeriodThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get agencyPeriodThisMonth;

  /// No description provided for @agencyPeriodLabel.
  ///
  /// In pt, this message translates to:
  /// **'Período'**
  String get agencyPeriodLabel;

  /// No description provided for @agencyRankUp.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Subiu 1 posição} other{Subiu {n} posições}}'**
  String agencyRankUp(int n);

  /// No description provided for @agencyRankDown.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Caiu 1 posição} other{Caiu {n} posições}}'**
  String agencyRankDown(int n);

  /// No description provided for @agencyRankSame.
  ///
  /// In pt, this message translates to:
  /// **'Mesma posição do mês anterior'**
  String get agencyRankSame;

  /// No description provided for @agencyPositionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Posição na agência'**
  String get agencyPositionLabel;

  /// No description provided for @agencyMonthGoalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meta do mês'**
  String get agencyMonthGoalTitle;

  /// No description provided for @agencyMonthGoalPercent.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% da meta'**
  String agencyMonthGoalPercent(String percent);

  /// No description provided for @agencyMonthGoalMet.
  ///
  /// In pt, this message translates to:
  /// **'Meta batida'**
  String get agencyMonthGoalMet;

  /// No description provided for @agencyMonthGoalNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem meta definida para este mês'**
  String get agencyMonthGoalNone;

  /// No description provided for @agencyChartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 6 meses'**
  String get agencyChartTitle;

  /// No description provided for @agencyChartEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados nos últimos meses'**
  String get agencyChartEmpty;

  /// No description provided for @agencyPerfError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o desempenho'**
  String get agencyPerfError;

  /// No description provided for @agencyGoalDone.
  ///
  /// In pt, this message translates to:
  /// **'Meta cumprida'**
  String get agencyGoalDone;

  /// No description provided for @agencyGoalHoursValue.
  ///
  /// In pt, this message translates to:
  /// **'{have} de {need} h'**
  String agencyGoalHoursValue(String have, String need);

  /// No description provided for @agencyGoalDaysValue.
  ///
  /// In pt, this message translates to:
  /// **'{have} de {need} dias'**
  String agencyGoalDaysValue(String have, String need);

  /// No description provided for @agencyIncFilterMonth.
  ///
  /// In pt, this message translates to:
  /// **'Do mês'**
  String get agencyIncFilterMonth;

  /// No description provided for @agencyIncFilter90.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 90 dias'**
  String get agencyIncFilter90;

  /// No description provided for @agencyIncidentPoints.
  ///
  /// In pt, this message translates to:
  /// **'{points, plural, =1{1 ponto} other{{points} pontos}}'**
  String agencyIncidentPoints(int points);

  /// No description provided for @agencyEventsFilterUpcoming.
  ///
  /// In pt, this message translates to:
  /// **'Próximos'**
  String get agencyEventsFilterUpcoming;

  /// No description provided for @agencyEventsFilterLive.
  ///
  /// In pt, this message translates to:
  /// **'Em andamento'**
  String get agencyEventsFilterLive;

  /// No description provided for @agencyEventsFilterEnded.
  ///
  /// In pt, this message translates to:
  /// **'Encerrados'**
  String get agencyEventsFilterEnded;

  /// No description provided for @agencyEventsEmptyUpcoming.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento agendado.'**
  String get agencyEventsEmptyUpcoming;

  /// No description provided for @agencyEventsEmptyLive.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento em andamento agora.'**
  String get agencyEventsEmptyLive;

  /// No description provided for @agencyEventsEmptyEnded.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento encerrado.'**
  String get agencyEventsEmptyEnded;

  /// No description provided for @agencyContractViewTerms.
  ///
  /// In pt, this message translates to:
  /// **'Ver termos'**
  String get agencyContractViewTerms;

  /// No description provided for @agencyContractUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Contrato sem data de término'**
  String get agencyContractUnknown;

  /// No description provided for @agencyLeaveRequestConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar pedido de desligamento?'**
  String get agencyLeaveRequestConfirmTitle;

  /// No description provided for @agencyLeaveRequestConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'A agência precisa aprovar. Se ela não responder no prazo, você fica livre automaticamente.'**
  String get agencyLeaveRequestConfirmBody;

  /// No description provided for @agencyReviewConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedir análise da Brawe?'**
  String get agencyReviewConfirmTitle;

  /// No description provided for @agencyReviewConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Use apenas em caso de abuso. A Brawe analisa direto, sem passar pela agência.'**
  String get agencyReviewConfirmBody;

  /// No description provided for @agencyLeaveSentOn.
  ///
  /// In pt, this message translates to:
  /// **'Enviado em {date}'**
  String agencyLeaveSentOn(String date);

  /// No description provided for @agencyInvitesBanner.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Você tem 1 convite de agência} other{Você tem {count} convites de agência}}'**
  String agencyInvitesBanner(int count);

  /// No description provided for @agencyInvitesView.
  ///
  /// In pt, this message translates to:
  /// **'Ver'**
  String get agencyInvitesView;

  /// No description provided for @agencyInviteRowBy.
  ///
  /// In pt, this message translates to:
  /// **'{name} · {role}'**
  String agencyInviteRowBy(String name, String role);

  /// No description provided for @agencyInvitesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum convite pendente.'**
  String get agencyInvitesEmpty;

  /// No description provided for @agencyPerkEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos pagos pela Brawe'**
  String get agencyPerkEarnings;

  /// No description provided for @agencyPerkNoCharges.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma cobrança'**
  String get agencyPerkNoCharges;

  /// No description provided for @agencyPerkAccount.
  ///
  /// In pt, this message translates to:
  /// **'Você mantém sua conta'**
  String get agencyPerkAccount;

  /// No description provided for @agencyPerkExit.
  ///
  /// In pt, this message translates to:
  /// **'Saída no fim do contrato ou em acordo; sem resposta da agência no prazo, você fica livre'**
  String get agencyPerkExit;

  /// No description provided for @agencyTermsRead.
  ///
  /// In pt, this message translates to:
  /// **'Ler termos completos'**
  String get agencyTermsRead;

  /// No description provided for @agencyTermsExpand.
  ///
  /// In pt, this message translates to:
  /// **'Termos e condições'**
  String get agencyTermsExpand;

  /// No description provided for @agencyIncidentsTitleShort.
  ///
  /// In pt, this message translates to:
  /// **'Ocorrências'**
  String get agencyIncidentsTitleShort;

  /// No description provided for @creatorDashWeekSameShort.
  ///
  /// In pt, this message translates to:
  /// **'Igual'**
  String get creatorDashWeekSameShort;

  /// No description provided for @agencyAcceptedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Aceito em'**
  String get agencyAcceptedLabel;

  /// No description provided for @agencyExitRuleAgreement.
  ///
  /// In pt, this message translates to:
  /// **'Antes do fim, a saída é em acordo com a agência. Se ela não responder no prazo (15 dias), você fica livre e pode entrar em outra agência.'**
  String get agencyExitRuleAgreement;

  /// No description provided for @creatorApplyBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get creatorApplyBack;

  /// No description provided for @creatorApplyNext.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get creatorApplyNext;

  /// No description provided for @creatorApplyAsAccount.
  ///
  /// In pt, this message translates to:
  /// **'Vamos usar os dados da sua conta Brawe.'**
  String get creatorApplyAsAccount;

  /// No description provided for @creatorApplyStepContent.
  ///
  /// In pt, this message translates to:
  /// **'Seu conteúdo'**
  String get creatorApplyStepContent;

  /// No description provided for @creatorApplyStepNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Sua rede'**
  String get creatorApplyStepNetwork;

  /// No description provided for @creatorApplyStepAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre você'**
  String get creatorApplyStepAbout;

  /// No description provided for @creatorApplyStepOf.
  ///
  /// In pt, this message translates to:
  /// **'Etapa {n} de {total}'**
  String creatorApplyStepOf(int n, int total);

  /// No description provided for @creatorApplyPlatformLabel.
  ///
  /// In pt, this message translates to:
  /// **'Rede principal'**
  String get creatorApplyPlatformLabel;

  /// No description provided for @creatorApplyHandleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Seu usuário nessa rede'**
  String get creatorApplyHandleLabel;

  /// No description provided for @creatorApplyHandleWhy.
  ///
  /// In pt, this message translates to:
  /// **'Precisamos do seu perfil em uma rede social para analisar seu conteúdo e sua audiência. Só a equipe de aprovação vê.'**
  String get creatorApplyHandleWhy;

  /// No description provided for @creatorApplyErrHandle.
  ///
  /// In pt, this message translates to:
  /// **'Use apenas letras, números, ponto, hífen ou sublinhado (mín. 2)'**
  String get creatorApplyErrHandle;

  /// No description provided for @creatorApplyErrMotivation.
  ///
  /// In pt, this message translates to:
  /// **'Escreva pelo menos {min} caracteres'**
  String creatorApplyErrMotivation(int min);

  /// No description provided for @creatorApplyErrFollowersMin.
  ///
  /// In pt, this message translates to:
  /// **'Informe quantos seguidores você tem (mínimo 1)'**
  String get creatorApplyErrFollowersMin;

  /// No description provided for @editProfileCreatorBadgeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar selo de creator'**
  String get editProfileCreatorBadgeTitle;

  /// No description provided for @editProfileCreatorBadgeHint.
  ///
  /// In pt, this message translates to:
  /// **'Exibe o selo da Creator Network no seu perfil.'**
  String get editProfileCreatorBadgeHint;

  /// No description provided for @editProfileCreatorBadgeSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a visibilidade do selo.'**
  String get editProfileCreatorBadgeSaveFailed;

  /// No description provided for @videoPubSound.
  ///
  /// In pt, this message translates to:
  /// **'Som'**
  String get videoPubSound;

  /// No description provided for @videoPubCoverAt.
  ///
  /// In pt, this message translates to:
  /// **'Capa em {time}'**
  String videoPubCoverAt(String time);

  /// No description provided for @videoUpQueued.
  ///
  /// In pt, this message translates to:
  /// **'Na fila…'**
  String get videoUpQueued;

  /// No description provided for @videoUpUploading.
  ///
  /// In pt, this message translates to:
  /// **'Publicando… {percent}%'**
  String videoUpUploading(int percent);

  /// No description provided for @videoUpProcessing.
  ///
  /// In pt, this message translates to:
  /// **'Processando…'**
  String get videoUpProcessing;

  /// No description provided for @videoUpFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falhou no envio'**
  String get videoUpFailed;

  /// No description provided for @videoUpRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get videoUpRetry;

  /// No description provided for @videoUpDone.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo publicado'**
  String get videoUpDone;

  /// No description provided for @videoUpView.
  ///
  /// In pt, this message translates to:
  /// **'Ver'**
  String get videoUpView;

  /// No description provided for @videoUpCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar envio'**
  String get videoUpCancel;

  /// No description provided for @videoUpDismiss.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get videoUpDismiss;

  /// No description provided for @chatSystemReadOnlyNote.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens oficiais da Brawe'**
  String get chatSystemReadOnlyNote;

  /// No description provided for @chatSystemOfficialLabel.
  ///
  /// In pt, this message translates to:
  /// **'Conta oficial'**
  String get chatSystemOfficialLabel;

  /// No description provided for @navChatUnreadSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Chat, {count} conversas não lidas'**
  String navChatUnreadSemantics(int count);

  /// No description provided for @gifSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar GIFs'**
  String get gifSearchHint;

  /// No description provided for @gifClearSearch.
  ///
  /// In pt, this message translates to:
  /// **'Limpar busca'**
  String get gifClearSearch;

  /// No description provided for @gifPoweredBy.
  ///
  /// In pt, this message translates to:
  /// **'Powered by GIPHY'**
  String get gifPoweredBy;

  /// No description provided for @gifUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'GIFs indisponíveis no momento'**
  String get gifUnavailable;

  /// No description provided for @gifErrorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os GIFs.'**
  String get gifErrorGeneric;

  /// No description provided for @gifRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get gifRetry;

  /// No description provided for @gifEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum GIF encontrado'**
  String get gifEmptyTitle;

  /// No description provided for @gifEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Tente outra palavra.'**
  String get gifEmptyHint;

  /// No description provided for @gifSemantics.
  ///
  /// In pt, this message translates to:
  /// **'GIF'**
  String get gifSemantics;

  /// No description provided for @gifTapToPause.
  ///
  /// In pt, this message translates to:
  /// **'Toque para pausar'**
  String get gifTapToPause;

  /// No description provided for @gifTapToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Toque para reproduzir'**
  String get gifTapToPlay;

  /// No description provided for @gifButtonSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Enviar um GIF'**
  String get gifButtonSemantics;

  /// No description provided for @notifFilterLikes.
  ///
  /// In pt, this message translates to:
  /// **'Curtidas'**
  String get notifFilterLikes;

  /// No description provided for @notifFilterComments.
  ///
  /// In pt, this message translates to:
  /// **'Comentários'**
  String get notifFilterComments;

  /// No description provided for @notifFilterFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get notifFilterFollowers;

  /// No description provided for @notifFilterMentions.
  ///
  /// In pt, this message translates to:
  /// **'Menções'**
  String get notifFilterMentions;

  /// No description provided for @notifFilterBrawe.
  ///
  /// In pt, this message translates to:
  /// **'Brawe'**
  String get notifFilterBrawe;

  /// No description provided for @notifActorsTwo.
  ///
  /// In pt, this message translates to:
  /// **'{a} e {b}'**
  String notifActorsTwo(String a, String b);

  /// No description provided for @notifActorsThree.
  ///
  /// In pt, this message translates to:
  /// **'{a}, {b} e {c}'**
  String notifActorsThree(String a, String b, String c);

  /// No description provided for @notifActorsMore.
  ///
  /// In pt, this message translates to:
  /// **'{a}, {b} e mais {n}'**
  String notifActorsMore(String a, String b, int n);

  /// No description provided for @notifVerbLike.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{curtiu seu post} other{curtiram seu post}}'**
  String notifVerbLike(int count);

  /// No description provided for @notifVerbComment.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{comentou no seu post} other{comentaram no seu post}}'**
  String notifVerbComment(int count);

  /// No description provided for @notifVerbReply.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{respondeu seu comentário} other{responderam seu comentário}}'**
  String notifVerbReply(int count);

  /// No description provided for @notifVerbFollow.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{começou a seguir você} other{começaram a seguir você}}'**
  String notifVerbFollow(int count);

  /// No description provided for @notifVerbGift.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{enviou presentes na sua live} other{enviaram presentes na sua live}}'**
  String notifVerbGift(int count);

  /// No description provided for @notifVerbMention.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{marcou você num comentário} other{marcaram você em comentários}}'**
  String notifVerbMention(int count);

  /// No description provided for @notifVerbStoryReaction.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{reagiu ao seu story} other{reagiram ao seu story}}'**
  String notifVerbStoryReaction(int count);

  /// No description provided for @notifGiftDiamonds.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{({value} diamante)} other{({value} diamantes)}}'**
  String notifGiftDiamonds(int count, String value);

  /// No description provided for @notifNewFollowersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novos seguidores'**
  String get notifNewFollowersTitle;

  /// No description provided for @notifNewFollowersEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum seguidor novo para mostrar'**
  String get notifNewFollowersEmpty;

  /// No description provided for @notifUnreadLabel.
  ///
  /// In pt, this message translates to:
  /// **'Não lida'**
  String get notifUnreadLabel;

  /// No description provided for @storyGiftSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get storyGiftSend;

  /// No description provided for @storyGiftConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar {gift} por {price}?'**
  String storyGiftConfirmTitle(String gift, String price);

  /// No description provided for @storyGiftBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo: {balance}'**
  String storyGiftBalance(String balance);

  /// No description provided for @storyUpUploading.
  ///
  /// In pt, this message translates to:
  /// **'Publicando story… {percent}%'**
  String storyUpUploading(int percent);

  /// No description provided for @storyUpProcessing.
  ///
  /// In pt, this message translates to:
  /// **'Publicando story…'**
  String get storyUpProcessing;

  /// No description provided for @storyUpDone.
  ///
  /// In pt, this message translates to:
  /// **'Story publicado'**
  String get storyUpDone;

  /// No description provided for @storyUpFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falhou ao publicar o story'**
  String get storyUpFailed;

  /// No description provided for @sessionEndedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão foi encerrada. Entre novamente.'**
  String get sessionEndedMessage;

  /// No description provided for @stepUpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirme que é você'**
  String get stepUpTitle;

  /// No description provided for @stepUpSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um código para {email}'**
  String stepUpSubtitle(String email);

  /// No description provided for @stepUpHint.
  ///
  /// In pt, this message translates to:
  /// **'Detectamos um acesso de um aparelho novo. Digite o código para entrar.'**
  String get stepUpHint;

  /// No description provided for @stepUpBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao login'**
  String get stepUpBack;

  /// No description provided for @stepUpTooMany.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Tente de novo em {time}.'**
  String stepUpTooMany(String time);

  /// No description provided for @secTitle.
  ///
  /// In pt, this message translates to:
  /// **'Segurança'**
  String get secTitle;

  /// No description provided for @secSettingsEntrySub.
  ///
  /// In pt, this message translates to:
  /// **'Aparelhos conectados, histórico de acessos e proteção da conta'**
  String get secSettingsEntrySub;

  /// No description provided for @secTabDevices.
  ///
  /// In pt, this message translates to:
  /// **'Aparelhos'**
  String get secTabDevices;

  /// No description provided for @secTabHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get secTabHistory;

  /// No description provided for @secTabProtect.
  ///
  /// In pt, this message translates to:
  /// **'Proteção'**
  String get secTabProtect;

  /// No description provided for @secDevicesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aparelhos conectados'**
  String get secDevicesTitle;

  /// No description provided for @secDevicesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Estes aparelhos estão com a sua conta aberta.'**
  String get secDevicesSubtitle;

  /// No description provided for @secThisDevice.
  ///
  /// In pt, this message translates to:
  /// **'Este aparelho'**
  String get secThisDevice;

  /// No description provided for @secActiveNow.
  ///
  /// In pt, this message translates to:
  /// **'Ativo agora'**
  String get secActiveNow;

  /// No description provided for @secLastActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo {time}'**
  String secLastActive(String time);

  /// No description provided for @secTimeMinutes.
  ///
  /// In pt, this message translates to:
  /// **'há {n} min'**
  String secTimeMinutes(int n);

  /// No description provided for @secTimeHours.
  ///
  /// In pt, this message translates to:
  /// **'há {n} h'**
  String secTimeHours(int n);

  /// No description provided for @secTimeDays.
  ///
  /// In pt, this message translates to:
  /// **'há {n} d'**
  String secTimeDays(int n);

  /// No description provided for @secEndSession.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar sessão'**
  String get secEndSession;

  /// No description provided for @secEndSessionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar a sessão neste aparelho?'**
  String get secEndSessionTitle;

  /// No description provided for @secEndSessionBody.
  ///
  /// In pt, this message translates to:
  /// **'{device} será desconectado e precisará entrar de novo.'**
  String secEndSessionBody(String device);

  /// No description provided for @secEndedOk.
  ///
  /// In pt, this message translates to:
  /// **'Sessão encerrada.'**
  String get secEndedOk;

  /// No description provided for @secSignOutOthers.
  ///
  /// In pt, this message translates to:
  /// **'Sair de todos os outros aparelhos'**
  String get secSignOutOthers;

  /// No description provided for @secSignOutOthersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair dos outros aparelhos?'**
  String get secSignOutOthersTitle;

  /// No description provided for @secSignOutOthersBody.
  ///
  /// In pt, this message translates to:
  /// **'Todos os aparelhos, menos este, serão desconectados.'**
  String get secSignOutOthersBody;

  /// No description provided for @secSignedOutOthersOk.
  ///
  /// In pt, this message translates to:
  /// **'Os outros aparelhos foram desconectados.'**
  String get secSignedOutOthersOk;

  /// No description provided for @secNoOtherDevices.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum outro aparelho conectado.'**
  String get secNoOtherDevices;

  /// No description provided for @secDevicesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma sessão ativa encontrada.'**
  String get secDevicesEmpty;

  /// No description provided for @secLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar agora.'**
  String get secLoadError;

  /// No description provided for @secUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Este recurso ainda não está disponível. Tente novamente em breve.'**
  String get secUnavailable;

  /// No description provided for @secActionError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir. Tente de novo.'**
  String get secActionError;

  /// No description provided for @secClientApp.
  ///
  /// In pt, this message translates to:
  /// **'App Brawe'**
  String get secClientApp;

  /// No description provided for @secClientPartners.
  ///
  /// In pt, this message translates to:
  /// **'Brawe Partners'**
  String get secClientPartners;

  /// No description provided for @secClientWeb.
  ///
  /// In pt, this message translates to:
  /// **'Navegador'**
  String get secClientWeb;

  /// No description provided for @secAppVersion.
  ///
  /// In pt, this message translates to:
  /// **'versão {v}'**
  String secAppVersion(String v);

  /// No description provided for @secUnknownDevice.
  ///
  /// In pt, this message translates to:
  /// **'Aparelho desconhecido'**
  String get secUnknownDevice;

  /// No description provided for @secUnknownPlace.
  ///
  /// In pt, this message translates to:
  /// **'Local não identificado'**
  String get secUnknownPlace;

  /// No description provided for @secHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de acessos'**
  String get secHistoryTitle;

  /// No description provided for @secFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get secFilterAll;

  /// No description provided for @secFilterLogins.
  ///
  /// In pt, this message translates to:
  /// **'Logins'**
  String get secFilterLogins;

  /// No description provided for @secFilterFailures.
  ///
  /// In pt, this message translates to:
  /// **'Falhas'**
  String get secFilterFailures;

  /// No description provided for @secFilterChanges.
  ///
  /// In pt, this message translates to:
  /// **'Alterações'**
  String get secFilterChanges;

  /// No description provided for @secHistoryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento neste filtro.'**
  String get secHistoryEmpty;

  /// No description provided for @secLoadMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregar mais'**
  String get secLoadMore;

  /// No description provided for @secEvLogin.
  ///
  /// In pt, this message translates to:
  /// **'Login'**
  String get secEvLogin;

  /// No description provided for @secEvLoginFailed.
  ///
  /// In pt, this message translates to:
  /// **'Tentativa de login falhou'**
  String get secEvLoginFailed;

  /// No description provided for @secEvLoginBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Login bloqueado'**
  String get secEvLoginBlocked;

  /// No description provided for @secEvLogout.
  ///
  /// In pt, this message translates to:
  /// **'Saída da conta'**
  String get secEvLogout;

  /// No description provided for @secEvSessionRevoked.
  ///
  /// In pt, this message translates to:
  /// **'Sessão encerrada'**
  String get secEvSessionRevoked;

  /// No description provided for @secEvSessionsRevokedAll.
  ///
  /// In pt, this message translates to:
  /// **'Outros aparelhos desconectados'**
  String get secEvSessionsRevokedAll;

  /// No description provided for @secEvPasswordChanged.
  ///
  /// In pt, this message translates to:
  /// **'Senha alterada'**
  String get secEvPasswordChanged;

  /// No description provided for @secEvPasswordResetRequested.
  ///
  /// In pt, this message translates to:
  /// **'Redefinição de senha solicitada'**
  String get secEvPasswordResetRequested;

  /// No description provided for @secEvPasswordReset.
  ///
  /// In pt, this message translates to:
  /// **'Senha redefinida'**
  String get secEvPasswordReset;

  /// No description provided for @secEvQrLogin.
  ///
  /// In pt, this message translates to:
  /// **'Login por QR code'**
  String get secEvQrLogin;

  /// No description provided for @secEvLoginCode.
  ///
  /// In pt, this message translates to:
  /// **'Login por código'**
  String get secEvLoginCode;

  /// No description provided for @secEvStepUpRequired.
  ///
  /// In pt, this message translates to:
  /// **'Verificação pedida'**
  String get secEvStepUpRequired;

  /// No description provided for @secEvStepUpPassed.
  ///
  /// In pt, this message translates to:
  /// **'Verificação concluída'**
  String get secEvStepUpPassed;

  /// No description provided for @secEvNewDeviceAlert.
  ///
  /// In pt, this message translates to:
  /// **'Alerta de aparelho novo'**
  String get secEvNewDeviceAlert;

  /// No description provided for @secEvUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Evento de segurança'**
  String get secEvUnknown;

  /// No description provided for @secProtectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não reconhece um acesso?'**
  String get secProtectTitle;

  /// No description provided for @secProtectBody.
  ///
  /// In pt, this message translates to:
  /// **'Se viu algo estranho, proteja sua conta agora: saímos de todos os outros aparelhos e você define uma senha nova.'**
  String get secProtectBody;

  /// No description provided for @secProtectButton.
  ///
  /// In pt, this message translates to:
  /// **'Proteger minha conta'**
  String get secProtectButton;

  /// No description provided for @secProtectSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Proteger sua conta'**
  String get secProtectSheetTitle;

  /// No description provided for @secProtectSheetIntro.
  ///
  /// In pt, this message translates to:
  /// **'Vamos fazer duas coisas agora:'**
  String get secProtectSheetIntro;

  /// No description provided for @secProtectStep1.
  ///
  /// In pt, this message translates to:
  /// **'Sair de todos os outros aparelhos. Você continua conectado aqui.'**
  String get secProtectStep1;

  /// No description provided for @secProtectStep2.
  ///
  /// In pt, this message translates to:
  /// **'Pedir que você crie uma senha nova. Essa etapa é obrigatória.'**
  String get secProtectStep2;

  /// No description provided for @secProtectConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Proteger agora'**
  String get secProtectConfirm;

  /// No description provided for @secCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get secCancel;

  /// No description provided for @secRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get secRetry;

  /// No description provided for @secProtectError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível proteger a conta. Tente de novo.'**
  String get secProtectError;

  /// No description provided for @secChangePasswordSub.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma senha nova e forte'**
  String get secChangePasswordSub;

  /// No description provided for @secPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por segurança, defina uma senha nova para continuar.'**
  String get secPasswordRequired;

  /// No description provided for @secGeoAttribution.
  ///
  /// In pt, this message translates to:
  /// **'IP Geolocation by DB-IP'**
  String get secGeoAttribution;

  /// No description provided for @secSettingsEntry.
  ///
  /// In pt, this message translates to:
  /// **'Segurança'**
  String get secSettingsEntry;

  /// No description provided for @payoutBalanceAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponível para saque'**
  String get payoutBalanceAvailable;

  /// No description provided for @payoutBalanceApprox.
  ///
  /// In pt, this message translates to:
  /// **'Aproximadamente {value}'**
  String payoutBalanceApprox(String value);

  /// No description provided for @payoutBalanceNoRate.
  ///
  /// In pt, this message translates to:
  /// **'Valor em reais indisponível agora'**
  String get payoutBalanceNoRate;

  /// No description provided for @payoutBalanceHolding.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando liberação'**
  String get payoutBalanceHolding;

  /// No description provided for @payoutBalanceInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em saque'**
  String get payoutBalanceInProgress;

  /// No description provided for @payoutBalanceWithdrawn.
  ///
  /// In pt, this message translates to:
  /// **'Já sacado'**
  String get payoutBalanceWithdrawn;

  /// No description provided for @payoutBalanceReleaseNote.
  ///
  /// In pt, this message translates to:
  /// **'Cada presente fica {days, plural, one {{days} dia} other {{days} dias}} em análise. Próxima liberação: {date}.'**
  String payoutBalanceReleaseNote(String date, int days);

  /// No description provided for @payoutBalanceWithdraw.
  ///
  /// In pt, this message translates to:
  /// **'Sacar'**
  String get payoutBalanceWithdraw;

  /// No description provided for @payoutBalanceAddAccountFirst.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar conta para sacar'**
  String get payoutBalanceAddAccountFirst;

  /// No description provided for @payoutBalanceMinimum.
  ///
  /// In pt, this message translates to:
  /// **'Saque mínimo de {amount}. Pagamento em até {days, plural, one {{days} dia útil} other {{days} dias úteis}}.'**
  String payoutBalanceMinimum(String amount, int days);

  /// No description provided for @payoutBalanceHowTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como chegamos nesse valor'**
  String get payoutBalanceHowTitle;

  /// No description provided for @payoutBalanceReceived.
  ///
  /// In pt, this message translates to:
  /// **'Recebido em presentes'**
  String get payoutBalanceReceived;

  /// No description provided for @payoutBalanceFromLive.
  ///
  /// In pt, this message translates to:
  /// **'Lives {value}'**
  String payoutBalanceFromLive(String value);

  /// No description provided for @payoutBalanceFromStory.
  ///
  /// In pt, this message translates to:
  /// **'Stories {value}'**
  String payoutBalanceFromStory(String value);

  /// No description provided for @payoutBalanceFromOther.
  ///
  /// In pt, this message translates to:
  /// **'Outros {value}'**
  String payoutBalanceFromOther(String value);

  /// No description provided for @payoutBalanceHoldingHint.
  ///
  /// In pt, this message translates to:
  /// **'Cada presente fica {days, plural, one {{days} dia} other {{days} dias}} em análise antes de liberar.'**
  String payoutBalanceHoldingHint(int days);

  /// No description provided for @payoutBalanceInProgressHint.
  ///
  /// In pt, this message translates to:
  /// **'Pedidos aguardando pagamento.'**
  String get payoutBalanceInProgressHint;

  /// No description provided for @payoutBalanceAvailableShort.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get payoutBalanceAvailableShort;

  /// No description provided for @payoutSoonTitle.
  ///
  /// In pt, this message translates to:
  /// **'Saques em breve'**
  String get payoutSoonTitle;

  /// No description provided for @payoutSoonSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus diamantes já estão acumulando. Avisaremos quando os saques forem liberados.'**
  String get payoutSoonSubtitle;

  /// No description provided for @payoutOpenTitle.
  ///
  /// In pt, this message translates to:
  /// **'Saque em andamento'**
  String get payoutOpenTitle;

  /// No description provided for @payoutOpenDiamonds.
  ///
  /// In pt, this message translates to:
  /// **'{diamonds} diamantes'**
  String payoutOpenDiamonds(String diamonds);

  /// No description provided for @payoutOpenRequestedNote.
  ///
  /// In pt, this message translates to:
  /// **'Estamos analisando seu pedido. O pagamento sai em até {days, plural, one {{days} dia útil} other {{days} dias úteis}} após a aprovação.'**
  String payoutOpenRequestedNote(int days);

  /// No description provided for @payoutOpenApprovedNote.
  ///
  /// In pt, this message translates to:
  /// **'Pedido aprovado. O pagamento sai em até {days, plural, one {{days} dia útil} other {{days} dias úteis}}.'**
  String payoutOpenApprovedNote(int days);

  /// No description provided for @payoutOpenRequestedAt.
  ///
  /// In pt, this message translates to:
  /// **'Pedido em {date}'**
  String payoutOpenRequestedAt(String date);

  /// No description provided for @payoutOpenCancelConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar este saque? Os diamantes voltam para o seu saldo.'**
  String get payoutOpenCancelConfirm;

  /// No description provided for @payoutOpenKeep.
  ///
  /// In pt, this message translates to:
  /// **'Manter'**
  String get payoutOpenKeep;

  /// No description provided for @payoutOpenCancelYes.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar saque'**
  String get payoutOpenCancelYes;

  /// No description provided for @payoutOpenCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar saque'**
  String get payoutOpenCancel;

  /// No description provided for @payoutStatusRequested.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get payoutStatusRequested;

  /// No description provided for @payoutStatusApproved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado'**
  String get payoutStatusApproved;

  /// No description provided for @payoutStatusPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pago'**
  String get payoutStatusPaid;

  /// No description provided for @payoutStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Recusado'**
  String get payoutStatusRejected;

  /// No description provided for @payoutStatusCanceled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelado'**
  String get payoutStatusCanceled;

  /// No description provided for @payoutAccountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta de recebimento'**
  String get payoutAccountTitle;

  /// No description provided for @payoutAccountStatusPendingReview.
  ///
  /// In pt, this message translates to:
  /// **'Em verificação'**
  String get payoutAccountStatusPendingReview;

  /// No description provided for @payoutAccountStatusVerified.
  ///
  /// In pt, this message translates to:
  /// **'Verificada'**
  String get payoutAccountStatusVerified;

  /// No description provided for @payoutAccountStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Recusada'**
  String get payoutAccountStatusRejected;

  /// No description provided for @payoutAccountPendingNote.
  ///
  /// In pt, this message translates to:
  /// **'Verificamos a conta no primeiro pagamento. Você já pode pedir saque.'**
  String get payoutAccountPendingNote;

  /// No description provided for @payoutAccountRejectedNote.
  ///
  /// In pt, this message translates to:
  /// **'Motivo: {reason}. Cadastre outra conta para sacar.'**
  String payoutAccountRejectedNote(String reason);

  /// No description provided for @payoutAccountNoReason.
  ///
  /// In pt, this message translates to:
  /// **'não informado'**
  String get payoutAccountNoReason;

  /// No description provided for @payoutAccountChange.
  ///
  /// In pt, this message translates to:
  /// **'Trocar conta'**
  String get payoutAccountChange;

  /// No description provided for @payoutAccountEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre a conta onde você quer receber. Ela precisa estar no seu nome.'**
  String get payoutAccountEmpty;

  /// No description provided for @payoutAccountAdd.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar conta'**
  String get payoutAccountAdd;

  /// No description provided for @payoutAccountFormTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta de recebimento'**
  String get payoutAccountFormTitle;

  /// No description provided for @payoutAccountFormIntro.
  ///
  /// In pt, this message translates to:
  /// **'Informe onde quer receber. A conta precisa ser sua: nome completo e documento do titular.'**
  String get payoutAccountFormIntro;

  /// No description provided for @payoutAccountSelect.
  ///
  /// In pt, this message translates to:
  /// **'Selecione'**
  String get payoutAccountSelect;

  /// No description provided for @payoutAccountOtherCountry.
  ///
  /// In pt, this message translates to:
  /// **'Outro país'**
  String get payoutAccountOtherCountry;

  /// No description provided for @payoutAccountPaidInBrl.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento em reais (R\$), pela cotação PTAX do Banco Central.'**
  String get payoutAccountPaidInBrl;

  /// No description provided for @payoutAccountPaidInUsd.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento em dólares (US\$).'**
  String get payoutAccountPaidInUsd;

  /// No description provided for @payoutAccountDocBr.
  ///
  /// In pt, this message translates to:
  /// **'CPF ou CNPJ do titular'**
  String get payoutAccountDocBr;

  /// No description provided for @payoutAccountDocOther.
  ///
  /// In pt, this message translates to:
  /// **'Documento de identificação fiscal do titular'**
  String get payoutAccountDocOther;

  /// No description provided for @payoutAccountHolderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Titular da conta'**
  String get payoutAccountHolderTitle;

  /// No description provided for @payoutAccountHolderHint.
  ///
  /// In pt, this message translates to:
  /// **'Deve ser a mesma pessoa que cria os conteúdos na Brawe.'**
  String get payoutAccountHolderHint;

  /// No description provided for @payoutAccountHolderNamePlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo, como no documento'**
  String get payoutAccountHolderNamePlaceholder;

  /// No description provided for @payoutAccountSecurityNote.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados bancários são guardados criptografados e só aparecem mascarados. Enviaremos um e-mail de segurança avisando da alteração.'**
  String get payoutAccountSecurityNote;

  /// No description provided for @payoutAccountReviewNote.
  ///
  /// In pt, this message translates to:
  /// **'A conta fica em verificação e é conferida pela Brawe no primeiro pagamento.'**
  String get payoutAccountReviewNote;

  /// No description provided for @payoutAccountSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar conta'**
  String get payoutAccountSave;

  /// No description provided for @payoutFieldsCountry.
  ///
  /// In pt, this message translates to:
  /// **'País da conta'**
  String get payoutFieldsCountry;

  /// No description provided for @payoutFieldsMethod.
  ///
  /// In pt, this message translates to:
  /// **'Forma de recebimento'**
  String get payoutFieldsMethod;

  /// No description provided for @payoutFieldsHolderName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo do titular'**
  String get payoutFieldsHolderName;

  /// No description provided for @payoutFieldsHolderTaxId.
  ///
  /// In pt, this message translates to:
  /// **'Documento do titular'**
  String get payoutFieldsHolderTaxId;

  /// No description provided for @payoutFieldsKeyType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de chave Pix'**
  String get payoutFieldsKeyType;

  /// No description provided for @payoutFieldsKey.
  ///
  /// In pt, this message translates to:
  /// **'Chave Pix'**
  String get payoutFieldsKey;

  /// No description provided for @payoutFieldsBankCode.
  ///
  /// In pt, this message translates to:
  /// **'Código do banco'**
  String get payoutFieldsBankCode;

  /// No description provided for @payoutFieldsBranch.
  ///
  /// In pt, this message translates to:
  /// **'Agência'**
  String get payoutFieldsBranch;

  /// No description provided for @payoutFieldsAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get payoutFieldsAccount;

  /// No description provided for @payoutFieldsAccountDigit.
  ///
  /// In pt, this message translates to:
  /// **'Dígito da conta'**
  String get payoutFieldsAccountDigit;

  /// No description provided for @payoutFieldsIban.
  ///
  /// In pt, this message translates to:
  /// **'IBAN'**
  String get payoutFieldsIban;

  /// No description provided for @payoutFieldsRoutingNumber.
  ///
  /// In pt, this message translates to:
  /// **'Routing number (ABA)'**
  String get payoutFieldsRoutingNumber;

  /// No description provided for @payoutFieldsAccountNumber.
  ///
  /// In pt, this message translates to:
  /// **'Número da conta'**
  String get payoutFieldsAccountNumber;

  /// No description provided for @payoutFieldsAccountType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de conta'**
  String get payoutFieldsAccountType;

  /// No description provided for @payoutFieldsSwift.
  ///
  /// In pt, this message translates to:
  /// **'SWIFT/BIC'**
  String get payoutFieldsSwift;

  /// No description provided for @payoutFieldsBankName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do banco'**
  String get payoutFieldsBankName;

  /// No description provided for @payoutFieldsBankAddress.
  ///
  /// In pt, this message translates to:
  /// **'Endereço do banco'**
  String get payoutFieldsBankAddress;

  /// No description provided for @payoutFieldsTaxRegime.
  ///
  /// In pt, this message translates to:
  /// **'Regime tributário da empresa'**
  String get payoutFieldsTaxRegime;

  /// No description provided for @payoutMethodsPix.
  ///
  /// In pt, this message translates to:
  /// **'Pix'**
  String get payoutMethodsPix;

  /// No description provided for @payoutMethodsBankBr.
  ///
  /// In pt, this message translates to:
  /// **'Conta bancária'**
  String get payoutMethodsBankBr;

  /// No description provided for @payoutMethodsIban.
  ///
  /// In pt, this message translates to:
  /// **'IBAN'**
  String get payoutMethodsIban;

  /// No description provided for @payoutMethodsUsAch.
  ///
  /// In pt, this message translates to:
  /// **'ACH (EUA)'**
  String get payoutMethodsUsAch;

  /// No description provided for @payoutMethodsSwift.
  ///
  /// In pt, this message translates to:
  /// **'Transferência SWIFT'**
  String get payoutMethodsSwift;

  /// No description provided for @payoutPixKeyTypesCpf.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get payoutPixKeyTypesCpf;

  /// No description provided for @payoutPixKeyTypesCnpj.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ'**
  String get payoutPixKeyTypesCnpj;

  /// No description provided for @payoutPixKeyTypesEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get payoutPixKeyTypesEmail;

  /// No description provided for @payoutPixKeyTypesPhone.
  ///
  /// In pt, this message translates to:
  /// **'Celular'**
  String get payoutPixKeyTypesPhone;

  /// No description provided for @payoutPixKeyTypesRandom.
  ///
  /// In pt, this message translates to:
  /// **'Chave aleatória'**
  String get payoutPixKeyTypesRandom;

  /// No description provided for @payoutAccountTypesChecking.
  ///
  /// In pt, this message translates to:
  /// **'Conta corrente (checking)'**
  String get payoutAccountTypesChecking;

  /// No description provided for @payoutAccountTypesSavings.
  ///
  /// In pt, this message translates to:
  /// **'Poupança (savings)'**
  String get payoutAccountTypesSavings;

  /// No description provided for @payoutKeyPlaceholderCpf.
  ///
  /// In pt, this message translates to:
  /// **'000.000.000-00'**
  String get payoutKeyPlaceholderCpf;

  /// No description provided for @payoutKeyPlaceholderCnpj.
  ///
  /// In pt, this message translates to:
  /// **'00.000.000/0000-00'**
  String get payoutKeyPlaceholderCnpj;

  /// No description provided for @payoutKeyPlaceholderEmail.
  ///
  /// In pt, this message translates to:
  /// **'voce@email.com'**
  String get payoutKeyPlaceholderEmail;

  /// No description provided for @payoutKeyPlaceholderPhone.
  ///
  /// In pt, this message translates to:
  /// **'(11) 91234-5678'**
  String get payoutKeyPlaceholderPhone;

  /// No description provided for @payoutKeyPlaceholderRandom.
  ///
  /// In pt, this message translates to:
  /// **'Chave aleatória'**
  String get payoutKeyPlaceholderRandom;

  /// No description provided for @payoutKeyPlaceholderNone.
  ///
  /// In pt, this message translates to:
  /// **'Chave Pix'**
  String get payoutKeyPlaceholderNone;

  /// No description provided for @payoutHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de saques'**
  String get payoutHistoryTitle;

  /// No description provided for @payoutHistoryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não fez nenhum saque.'**
  String get payoutHistoryEmpty;

  /// No description provided for @payoutHistoryRejectedNote.
  ///
  /// In pt, this message translates to:
  /// **'Motivo: {reason}. Os diamantes voltaram para o seu saldo.'**
  String payoutHistoryRejectedNote(String reason);

  /// No description provided for @payoutHistoryReference.
  ///
  /// In pt, this message translates to:
  /// **'Comprovante: {ref}'**
  String payoutHistoryReference(String ref);

  /// No description provided for @payoutHistoryTotalReceived.
  ///
  /// In pt, this message translates to:
  /// **'Total já recebido: {amount}'**
  String payoutHistoryTotalReceived(String amount);

  /// No description provided for @payoutWithdrawTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sacar'**
  String get payoutWithdrawTitle;

  /// No description provided for @payoutWithdrawStepOf.
  ///
  /// In pt, this message translates to:
  /// **'Etapa {current} de {total}'**
  String payoutWithdrawStepOf(String current, String total);

  /// No description provided for @payoutWithdrawAmountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quanto você quer sacar?'**
  String get payoutWithdrawAmountTitle;

  /// No description provided for @payoutWithdrawAmountSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você tem {available} diamantes disponíveis.'**
  String payoutWithdrawAmountSubtitle(String available);

  /// No description provided for @payoutWithdrawDiamondsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Diamantes'**
  String get payoutWithdrawDiamondsLabel;

  /// No description provided for @payoutWithdrawAll.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get payoutWithdrawAll;

  /// No description provided for @payoutWithdrawMinHint.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de {diamonds} diamantes ({amount}).'**
  String payoutWithdrawMinHint(String amount, String diamonds);

  /// No description provided for @payoutWithdrawTypeToQuote.
  ///
  /// In pt, this message translates to:
  /// **'Digite a quantidade para ver quanto você recebe.'**
  String get payoutWithdrawTypeToQuote;

  /// No description provided for @payoutWithdrawCalculating.
  ///
  /// In pt, this message translates to:
  /// **'Calculando…'**
  String get payoutWithdrawCalculating;

  /// No description provided for @payoutWithdrawYouReceive.
  ///
  /// In pt, this message translates to:
  /// **'Você recebe'**
  String get payoutWithdrawYouReceive;

  /// No description provided for @payoutWithdrawAfterRetentions.
  ///
  /// In pt, this message translates to:
  /// **'{gross} menos {tax} de retenções'**
  String payoutWithdrawAfterRetentions(String gross, String tax);

  /// No description provided for @payoutWithdrawContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get payoutWithdrawContinue;

  /// No description provided for @payoutWithdrawReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confira o saque'**
  String get payoutWithdrawReviewTitle;

  /// No description provided for @payoutWithdrawReviewSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Veja o cálculo completo antes de confirmar.'**
  String get payoutWithdrawReviewSubtitle;

  /// No description provided for @payoutWithdrawDiamonds.
  ///
  /// In pt, this message translates to:
  /// **'Diamantes'**
  String get payoutWithdrawDiamonds;

  /// No description provided for @payoutWithdrawPtax.
  ///
  /// In pt, this message translates to:
  /// **'Cotação PTAX de {date}'**
  String payoutWithdrawPtax(String date);

  /// No description provided for @payoutWithdrawValueUsd.
  ///
  /// In pt, this message translates to:
  /// **'Valor em dólares'**
  String get payoutWithdrawValueUsd;

  /// No description provided for @payoutWithdrawGross.
  ///
  /// In pt, this message translates to:
  /// **'Valor bruto'**
  String get payoutWithdrawGross;

  /// No description provided for @payoutWithdrawRetentions.
  ///
  /// In pt, this message translates to:
  /// **'Retenções'**
  String get payoutWithdrawRetentions;

  /// No description provided for @payoutWithdrawNoRetentions.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma'**
  String get payoutWithdrawNoRetentions;

  /// No description provided for @payoutWithdrawNet.
  ///
  /// In pt, this message translates to:
  /// **'Você recebe'**
  String get payoutWithdrawNet;

  /// No description provided for @payoutWithdrawPtaxNote.
  ///
  /// In pt, this message translates to:
  /// **'Cotação de {side} do {bulletin} (Banco Central), do último boletim de fechamento.'**
  String payoutWithdrawPtaxNote(String bulletin, String side);

  /// No description provided for @payoutWithdrawPaidTo.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento para'**
  String get payoutWithdrawPaidTo;

  /// No description provided for @payoutWithdrawSla.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento em até {days, plural, one {{days} dia útil} other {{days} dias úteis}} após a aprovação.'**
  String payoutWithdrawSla(int days);

  /// No description provided for @payoutWithdrawFirstPaymentCheck.
  ///
  /// In pt, this message translates to:
  /// **'Como é seu primeiro pagamento, a Brawe confere a conta antes de pagar.'**
  String get payoutWithdrawFirstPaymentCheck;

  /// No description provided for @payoutWithdrawSendCode.
  ///
  /// In pt, this message translates to:
  /// **'Enviar código por e-mail'**
  String get payoutWithdrawSendCode;

  /// No description provided for @payoutWithdrawMonthPrior.
  ///
  /// In pt, this message translates to:
  /// **'As retenções consideram os saques que você já fez este mês ({amount}).'**
  String payoutWithdrawMonthPrior(String amount);

  /// No description provided for @payoutWithdrawRetentionsHelp.
  ///
  /// In pt, this message translates to:
  /// **'Retenções exigidas por lei, recolhidas pela Brawe em seu nome. Você recebe o informe de rendimentos.'**
  String get payoutWithdrawRetentionsHelp;

  /// No description provided for @payoutCodeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirme com o código'**
  String get payoutCodeTitle;

  /// No description provided for @payoutCodeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um código de 6 dígitos para {email}.'**
  String payoutCodeSubtitle(String email);

  /// No description provided for @payoutCodeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Código de 6 dígitos'**
  String get payoutCodeLabel;

  /// No description provided for @payoutCodeConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar saque'**
  String get payoutCodeConfirm;

  /// No description provided for @payoutCodeResend.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar código'**
  String get payoutCodeResend;

  /// No description provided for @payoutCodeResendIn.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar código em {seconds}s'**
  String payoutCodeResendIn(String seconds);

  /// No description provided for @payoutCodeResent.
  ///
  /// In pt, this message translates to:
  /// **'Novo código enviado para {email}.'**
  String payoutCodeResent(String email);

  /// No description provided for @payoutDoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedido enviado'**
  String get payoutDoneTitle;

  /// No description provided for @payoutDoneSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu saque está em análise. O pagamento sai em até {days, plural, one {{days} dia útil} other {{days} dias úteis}} após a aprovação, e você acompanha o status aqui.'**
  String payoutDoneSubtitle(int days);

  /// No description provided for @payoutDoneStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get payoutDoneStatus;

  /// No description provided for @payoutDoneBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar para Ganhos'**
  String get payoutDoneBack;

  /// No description provided for @payoutErrorsNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com o servidor. Confira sua internet e tente de novo.'**
  String get payoutErrorsNetwork;

  /// No description provided for @payoutErrorsDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Os saques ainda não estão liberados.'**
  String get payoutErrorsDisabled;

  /// No description provided for @payoutErrorsAccountRequired.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre sua conta de recebimento para sacar.'**
  String get payoutErrorsAccountRequired;

  /// No description provided for @payoutErrorsAccountRejected.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta de recebimento foi recusada. Cadastre outra conta.'**
  String get payoutErrorsAccountRejected;

  /// No description provided for @payoutErrorsInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Espere o saque em andamento terminar para trocar a conta.'**
  String get payoutErrorsInProgress;

  /// No description provided for @payoutErrorsOpenLimit.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem um saque em andamento. Espere ele terminar ou cancele.'**
  String get payoutErrorsOpenLimit;

  /// No description provided for @payoutErrorsConflict.
  ///
  /// In pt, this message translates to:
  /// **'Seu saldo mudou. Atualize a página e tente de novo.'**
  String get payoutErrorsConflict;

  /// No description provided for @payoutErrorsFxUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A cotação do dólar está indisponível agora. Tente de novo em instantes.'**
  String get payoutErrorsFxUnavailable;

  /// No description provided for @payoutErrorsNetNotPositive.
  ///
  /// In pt, this message translates to:
  /// **'Depois das retenções, o valor líquido ficaria zerado. Escolha uma quantia maior.'**
  String get payoutErrorsNetNotPositive;

  /// No description provided for @payoutErrorsInvalidAmount.
  ///
  /// In pt, this message translates to:
  /// **'Informe uma quantidade de diamantes válida.'**
  String get payoutErrorsInvalidAmount;

  /// No description provided for @payoutErrorsBelowMinimum.
  ///
  /// In pt, this message translates to:
  /// **'O saque mínimo é de {diamonds} diamantes ({amount}).'**
  String payoutErrorsBelowMinimum(String amount, String diamonds);

  /// No description provided for @payoutErrorsInsufficient.
  ///
  /// In pt, this message translates to:
  /// **'Saldo insuficiente. Você tem {available} diamantes disponíveis.'**
  String payoutErrorsInsufficient(String available);

  /// No description provided for @payoutErrorsTooMany.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Espere um pouco e tente de novo.'**
  String get payoutErrorsTooMany;

  /// No description provided for @payoutErrorsSendFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos enviar o e-mail agora. Tente de novo.'**
  String get payoutErrorsSendFailed;

  /// No description provided for @payoutErrorsResendTooSoon.
  ///
  /// In pt, this message translates to:
  /// **'Aguarde {seconds}s para reenviar o código.'**
  String payoutErrorsResendTooSoon(String seconds);

  /// No description provided for @payoutErrorsCodeInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Código incorreto. {left, plural, one {Resta {left} tentativa} other {Restam {left} tentativas}}.'**
  String payoutErrorsCodeInvalid(int left);

  /// No description provided for @payoutErrorsCodeExpired.
  ///
  /// In pt, this message translates to:
  /// **'Este código expirou. Toque em “Reenviar código”.'**
  String get payoutErrorsCodeExpired;

  /// No description provided for @payoutErrorsTooManyAttempts.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas erradas. Volte e peça um novo código.'**
  String get payoutErrorsTooManyAttempts;

  /// No description provided for @payoutErrorsHolderMismatch.
  ///
  /// In pt, this message translates to:
  /// **'A chave Pix (CPF/CNPJ) precisa ser do próprio titular da conta.'**
  String get payoutErrorsHolderMismatch;

  /// No description provided for @payoutErrorsInvalidMethod.
  ///
  /// In pt, this message translates to:
  /// **'Esta forma de recebimento não está disponível para o país escolhido.'**
  String get payoutErrorsInvalidMethod;

  /// No description provided for @payoutErrorsInvalidField.
  ///
  /// In pt, this message translates to:
  /// **'Confira o campo “{field}”.'**
  String payoutErrorsInvalidField(String field);

  /// No description provided for @payoutErrorsInvalidData.
  ///
  /// In pt, this message translates to:
  /// **'Confira os dados informados.'**
  String get payoutErrorsInvalidData;

  /// No description provided for @payoutErrorsGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir agora. Tente de novo.'**
  String get payoutErrorsGeneric;

  /// No description provided for @payoutErrorsFillAll.
  ///
  /// In pt, this message translates to:
  /// **'Preencha todos os campos, com o nome completo do titular.'**
  String get payoutErrorsFillAll;

  /// No description provided for @payoutErrorsPickMethod.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a forma de recebimento.'**
  String get payoutErrorsPickMethod;

  /// No description provided for @payoutTaxRegimesSimples.
  ///
  /// In pt, this message translates to:
  /// **'Simples Nacional ou MEI'**
  String get payoutTaxRegimesSimples;

  /// No description provided for @payoutTaxRegimesNormal.
  ///
  /// In pt, this message translates to:
  /// **'Lucro Presumido ou Real'**
  String get payoutTaxRegimesNormal;

  /// No description provided for @payoutHolderTypesPf.
  ///
  /// In pt, this message translates to:
  /// **'Pessoa física'**
  String get payoutHolderTypesPf;

  /// No description provided for @payoutHolderTypesPj.
  ///
  /// In pt, this message translates to:
  /// **'Empresa'**
  String get payoutHolderTypesPj;

  /// No description provided for @payoutHolderTypesPjSimples.
  ///
  /// In pt, this message translates to:
  /// **'Empresa (Simples/MEI)'**
  String get payoutHolderTypesPjSimples;

  /// No description provided for @creatorPanelTabMonetization.
  ///
  /// In pt, this message translates to:
  /// **'Monetização'**
  String get creatorPanelTabMonetization;

  /// No description provided for @payoutOnlyGiftsNote.
  ///
  /// In pt, this message translates to:
  /// **'Só os diamantes de presentes recebidos em lives e stories podem ser sacados. Coins compradas servem para usar dentro da Brawe e não são sacáveis.'**
  String get payoutOnlyGiftsNote;

  /// No description provided for @payoutLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a monetização.'**
  String get payoutLoadError;

  /// No description provided for @payoutCancelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar saque?'**
  String get payoutCancelTitle;

  /// No description provided for @payoutDoneBackMonetization.
  ///
  /// In pt, this message translates to:
  /// **'Voltar para Monetização'**
  String get payoutDoneBackMonetization;

  /// No description provided for @payoutCountryBR.
  ///
  /// In pt, this message translates to:
  /// **'Brasil'**
  String get payoutCountryBR;

  /// No description provided for @payoutCountryUS.
  ///
  /// In pt, this message translates to:
  /// **'Estados Unidos'**
  String get payoutCountryUS;

  /// No description provided for @payoutCountryPT.
  ///
  /// In pt, this message translates to:
  /// **'Portugal'**
  String get payoutCountryPT;

  /// No description provided for @payoutCountryAR.
  ///
  /// In pt, this message translates to:
  /// **'Argentina'**
  String get payoutCountryAR;

  /// No description provided for @payoutCountryCL.
  ///
  /// In pt, this message translates to:
  /// **'Chile'**
  String get payoutCountryCL;

  /// No description provided for @payoutCountryCO.
  ///
  /// In pt, this message translates to:
  /// **'Colômbia'**
  String get payoutCountryCO;

  /// No description provided for @payoutCountryMX.
  ///
  /// In pt, this message translates to:
  /// **'México'**
  String get payoutCountryMX;

  /// No description provided for @payoutCountryPE.
  ///
  /// In pt, this message translates to:
  /// **'Peru'**
  String get payoutCountryPE;

  /// No description provided for @payoutCountryUY.
  ///
  /// In pt, this message translates to:
  /// **'Uruguai'**
  String get payoutCountryUY;

  /// No description provided for @payoutCountryES.
  ///
  /// In pt, this message translates to:
  /// **'Espanha'**
  String get payoutCountryES;

  /// No description provided for @payoutSeeMonetization.
  ///
  /// In pt, this message translates to:
  /// **'Sacar em Monetização'**
  String get payoutSeeMonetization;

  /// No description provided for @adsSponsored.
  ///
  /// In pt, this message translates to:
  /// **'Patrocinado'**
  String get adsSponsored;

  /// No description provided for @adsWhy.
  ///
  /// In pt, this message translates to:
  /// **'Por que estou vendo isto?'**
  String get adsWhy;

  /// No description provided for @adsWhyAdvertiser.
  ///
  /// In pt, this message translates to:
  /// **'Este anúncio é de {name}.'**
  String adsWhyAdvertiser(String name);

  /// No description provided for @adsWhyFooter.
  ///
  /// In pt, this message translates to:
  /// **'Anúncios na Brawe nunca usam suas mensagens nem aparecem para menores de 18 anos.'**
  String get adsWhyFooter;

  /// No description provided for @adsHide.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar este anúncio'**
  String get adsHide;

  /// No description provided for @adsLessFrom.
  ///
  /// In pt, this message translates to:
  /// **'Ver menos de {name}'**
  String adsLessFrom(String name);

  /// No description provided for @adsReport.
  ///
  /// In pt, this message translates to:
  /// **'Denunciar anúncio'**
  String get adsReport;

  /// No description provided for @adsHidden.
  ///
  /// In pt, this message translates to:
  /// **'Anúncio ocultado'**
  String get adsHidden;

  /// No description provided for @adsReportThanks.
  ///
  /// In pt, this message translates to:
  /// **'Obrigado. A equipe da Brawe vai revisar este anúncio.'**
  String get adsReportThanks;

  /// No description provided for @adsReasonMisleading.
  ///
  /// In pt, this message translates to:
  /// **'Enganoso ou golpe'**
  String get adsReasonMisleading;

  /// No description provided for @adsReasonOffensive.
  ///
  /// In pt, this message translates to:
  /// **'Ofensivo'**
  String get adsReasonOffensive;

  /// No description provided for @adsReasonAdult.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo adulto'**
  String get adsReasonAdult;

  /// No description provided for @adsReasonProhibited.
  ///
  /// In pt, this message translates to:
  /// **'Produto proibido'**
  String get adsReasonProhibited;

  /// No description provided for @adsReasonRepetitive.
  ///
  /// In pt, this message translates to:
  /// **'Aparece demais'**
  String get adsReasonRepetitive;

  /// No description provided for @adsReasonOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro motivo'**
  String get adsReasonOther;

  /// No description provided for @adsSeeProfile.
  ///
  /// In pt, this message translates to:
  /// **'Ver perfil'**
  String get adsSeeProfile;

  /// No description provided for @adsWatchLive.
  ///
  /// In pt, this message translates to:
  /// **'Assistir à live'**
  String get adsWatchLive;

  /// No description provided for @postBoost.
  ///
  /// In pt, this message translates to:
  /// **'Impulsionar'**
  String get postBoost;

  /// No description provided for @postBoostHint.
  ///
  /// In pt, this message translates to:
  /// **'Mostre para mais pessoas'**
  String get postBoostHint;

  /// No description provided for @boostTitle.
  ///
  /// In pt, this message translates to:
  /// **'Impulsionar post'**
  String get boostTitle;

  /// No description provided for @boostStepAudience.
  ///
  /// In pt, this message translates to:
  /// **'Público'**
  String get boostStepAudience;

  /// No description provided for @boostStepBudget.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento'**
  String get boostStepBudget;

  /// No description provided for @boostStepReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisar'**
  String get boostStepReview;

  /// No description provided for @boostAuto.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get boostAuto;

  /// No description provided for @boostAutoHint.
  ///
  /// In pt, this message translates to:
  /// **'A Brawe escolhe quem tem mais chance de se interessar, em todo o Brasil.'**
  String get boostAutoHint;

  /// No description provided for @boostCustom.
  ///
  /// In pt, this message translates to:
  /// **'Personalizar'**
  String get boostCustom;

  /// No description provided for @boostCustomHint.
  ///
  /// In pt, this message translates to:
  /// **'Escolha onde, idade e interesses.'**
  String get boostCustomHint;

  /// No description provided for @boostLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get boostLocation;

  /// No description provided for @boostAllBrazil.
  ///
  /// In pt, this message translates to:
  /// **'Brasil inteiro'**
  String get boostAllBrazil;

  /// No description provided for @boostPlaces.
  ///
  /// In pt, this message translates to:
  /// **'Cidades'**
  String get boostPlaces;

  /// No description provided for @boostRadius.
  ///
  /// In pt, this message translates to:
  /// **'Raio'**
  String get boostRadius;

  /// No description provided for @boostSearchCity.
  ///
  /// In pt, this message translates to:
  /// **'Buscar cidade'**
  String get boostSearchCity;

  /// No description provided for @boostNoCity.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma cidade encontrada'**
  String get boostNoCity;

  /// No description provided for @boostUseMyLocation.
  ///
  /// In pt, this message translates to:
  /// **'Usar minha localização'**
  String get boostUseMyLocation;

  /// No description provided for @boostCenter.
  ///
  /// In pt, this message translates to:
  /// **'Centro do raio'**
  String get boostCenter;

  /// No description provided for @boostKm.
  ///
  /// In pt, this message translates to:
  /// **'{km} km'**
  String boostKm(String km);

  /// No description provided for @boostAge.
  ///
  /// In pt, this message translates to:
  /// **'Idade'**
  String get boostAge;

  /// No description provided for @boostAgeRange.
  ///
  /// In pt, this message translates to:
  /// **'{from} a {to} anos'**
  String boostAgeRange(String from, String to);

  /// No description provided for @boostInterests.
  ///
  /// In pt, this message translates to:
  /// **'Interesses'**
  String get boostInterests;

  /// No description provided for @boostAnyInterest.
  ///
  /// In pt, this message translates to:
  /// **'Qualquer interesse'**
  String get boostAnyInterest;

  /// No description provided for @boostPerDay.
  ///
  /// In pt, this message translates to:
  /// **'Por dia'**
  String get boostPerDay;

  /// No description provided for @boostDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get boostDuration;

  /// No description provided for @boostDaysN.
  ///
  /// In pt, this message translates to:
  /// **'{n} dias'**
  String boostDaysN(String n);

  /// No description provided for @boostTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get boostTotal;

  /// No description provided for @boostCoins.
  ///
  /// In pt, this message translates to:
  /// **'{n} Coins'**
  String boostCoins(String n);

  /// No description provided for @boostBalance.
  ///
  /// In pt, this message translates to:
  /// **'Seu saldo: {n} Coins'**
  String boostBalance(String n);

  /// No description provided for @boostInsufficient.
  ///
  /// In pt, this message translates to:
  /// **'Saldo insuficiente para este orçamento.'**
  String get boostInsufficient;

  /// No description provided for @boostTopUp.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar Coins'**
  String get boostTopUp;

  /// No description provided for @boostEstimate.
  ///
  /// In pt, this message translates to:
  /// **'Público estimado'**
  String get boostEstimate;

  /// No description provided for @boostNext.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get boostNext;

  /// No description provided for @boostPay.
  ///
  /// In pt, this message translates to:
  /// **'Impulsionar · {n} Coins'**
  String boostPay(String n);

  /// No description provided for @boostTerms.
  ///
  /// In pt, this message translates to:
  /// **'Ao impulsionar, você confirma que o post segue as regras de anúncios da Brawe. O que não for gasto volta para você.'**
  String get boostTerms;

  /// No description provided for @boostDoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu post está sendo impulsionado'**
  String get boostDoneTitle;

  /// No description provided for @boostDoneHint.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe alcance, cliques e gastos em Meus anúncios.'**
  String get boostDoneHint;

  /// No description provided for @boostSeeCampaigns.
  ///
  /// In pt, this message translates to:
  /// **'Ver meus anúncios'**
  String get boostSeeCampaigns;

  /// No description provided for @boostError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível impulsionar. Tente de novo.'**
  String get boostError;

  /// No description provided for @boostCitiesInRadius.
  ///
  /// In pt, this message translates to:
  /// **'≈ {n} cidades no raio'**
  String boostCitiesInRadius(String n);

  /// No description provided for @myAdsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meus anúncios'**
  String get myAdsTitle;

  /// No description provided for @myAdsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não impulsionou nenhum post.'**
  String get myAdsEmpty;

  /// No description provided for @myAdsEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em Impulsionar em um post seu para começar.'**
  String get myAdsEmptyHint;

  /// No description provided for @myAdsStatusDraft.
  ///
  /// In pt, this message translates to:
  /// **'Rascunho'**
  String get myAdsStatusDraft;

  /// No description provided for @myAdsStatusReview.
  ///
  /// In pt, this message translates to:
  /// **'Em revisão'**
  String get myAdsStatusReview;

  /// No description provided for @myAdsStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'No ar'**
  String get myAdsStatusActive;

  /// No description provided for @myAdsStatusPaused.
  ///
  /// In pt, this message translates to:
  /// **'Pausada'**
  String get myAdsStatusPaused;

  /// No description provided for @myAdsStatusEnded.
  ///
  /// In pt, this message translates to:
  /// **'Encerrada'**
  String get myAdsStatusEnded;

  /// No description provided for @myAdsStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Recusada'**
  String get myAdsStatusRejected;

  /// No description provided for @myAdsImpressions.
  ///
  /// In pt, this message translates to:
  /// **'Impressões'**
  String get myAdsImpressions;

  /// No description provided for @myAdsReach.
  ///
  /// In pt, this message translates to:
  /// **'Alcance'**
  String get myAdsReach;

  /// No description provided for @myAdsClicks.
  ///
  /// In pt, this message translates to:
  /// **'Cliques'**
  String get myAdsClicks;

  /// No description provided for @myAdsViews.
  ///
  /// In pt, this message translates to:
  /// **'Visualizações'**
  String get myAdsViews;

  /// No description provided for @myAdsNewFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Novos seguidores'**
  String get myAdsNewFollowers;

  /// No description provided for @myAdsProfileVisits.
  ///
  /// In pt, this message translates to:
  /// **'Visitas ao perfil'**
  String get myAdsProfileVisits;

  /// No description provided for @myAdsSpent.
  ///
  /// In pt, this message translates to:
  /// **'Gasto'**
  String get myAdsSpent;

  /// No description provided for @myAdsOf.
  ///
  /// In pt, this message translates to:
  /// **'de {total}'**
  String myAdsOf(String total);

  /// No description provided for @myAdsEndsOn.
  ///
  /// In pt, this message translates to:
  /// **'Termina em {date}'**
  String myAdsEndsOn(String date);

  /// No description provided for @myAdsPause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get myAdsPause;

  /// No description provided for @myAdsResume.
  ///
  /// In pt, this message translates to:
  /// **'Retomar'**
  String get myAdsResume;

  /// No description provided for @myAdsCancel.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar'**
  String get myAdsCancel;

  /// No description provided for @myAdsCancelConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar o anúncio agora? As Coins do que não foi gasto voltam para você.'**
  String get myAdsCancelConfirm;

  /// No description provided for @myAdsIncreaseDaily.
  ///
  /// In pt, this message translates to:
  /// **'Aumentar por dia'**
  String get myAdsIncreaseDaily;

  /// No description provided for @myAdsIncreaseCost.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {days} dias: {coins} Coins a mais'**
  String myAdsIncreaseCost(String days, String coins);

  /// No description provided for @myAdsOnlyUp.
  ///
  /// In pt, this message translates to:
  /// **'O valor por dia só pode aumentar.'**
  String get myAdsOnlyUp;

  /// No description provided for @myAdsEditAudience.
  ///
  /// In pt, this message translates to:
  /// **'Editar público'**
  String get myAdsEditAudience;

  /// No description provided for @myAdsAudienceSaved.
  ///
  /// In pt, this message translates to:
  /// **'Público atualizado'**
  String get myAdsAudienceSaved;

  /// No description provided for @myAdsPausedByTeam.
  ///
  /// In pt, this message translates to:
  /// **'Pausado pela equipe da Brawe.'**
  String get myAdsPausedByTeam;

  /// No description provided for @myAdsSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get myAdsSave;

  /// No description provided for @boostTapMap.
  ///
  /// In pt, this message translates to:
  /// **'Toque no mapa para mudar o centro.'**
  String get boostTapMap;

  /// No description provided for @boostInterestsNarrow.
  ///
  /// In pt, this message translates to:
  /// **'Interesses deixam o público menor. Se o alcance ficar baixo, tire alguns.'**
  String get boostInterestsNarrow;

  /// No description provided for @boostRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get boostRetry;

  /// No description provided for @boostPerDayShort.
  ///
  /// In pt, this message translates to:
  /// **'por dia'**
  String get boostPerDayShort;

  /// No description provided for @boostFinish.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get boostFinish;

  /// No description provided for @myAdsAtMax.
  ///
  /// In pt, this message translates to:
  /// **'Você já está no valor máximo por dia.'**
  String get myAdsAtMax;

  /// No description provided for @myAdsEntry.
  ///
  /// In pt, this message translates to:
  /// **'Anúncios e impulsionamentos'**
  String get myAdsEntry;

  /// No description provided for @adsRepEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Os resultados aparecem aqui assim que o anúncio começar a ser exibido.'**
  String get adsRepEmpty;

  /// No description provided for @adsRepPeople.
  ///
  /// In pt, this message translates to:
  /// **'pessoas'**
  String get adsRepPeople;

  /// No description provided for @adsRepFrequency.
  ///
  /// In pt, this message translates to:
  /// **'Frequência'**
  String get adsRepFrequency;

  /// No description provided for @adsRepCtr.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de cliques'**
  String get adsRepCtr;

  /// No description provided for @adsRepCpm.
  ///
  /// In pt, this message translates to:
  /// **'Custo por mil'**
  String get adsRepCpm;

  /// No description provided for @adsRepOverTime.
  ///
  /// In pt, this message translates to:
  /// **'Ao longo dos dias'**
  String get adsRepOverTime;

  /// No description provided for @adsRepVideo.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo'**
  String get adsRepVideo;

  /// No description provided for @adsRepAvgWatch.
  ///
  /// In pt, this message translates to:
  /// **'Tempo médio: {s} s'**
  String adsRepAvgWatch(String s);

  /// No description provided for @adsRepWatched25.
  ///
  /// In pt, this message translates to:
  /// **'Assistiram 25%'**
  String get adsRepWatched25;

  /// No description provided for @adsRepWatched50.
  ///
  /// In pt, this message translates to:
  /// **'Assistiram metade'**
  String get adsRepWatched50;

  /// No description provided for @adsRepWatched100.
  ///
  /// In pt, this message translates to:
  /// **'Assistiram até o fim'**
  String get adsRepWatched100;

  /// No description provided for @adsRepAudience.
  ///
  /// In pt, this message translates to:
  /// **'Quem viu'**
  String get adsRepAudience;

  /// No description provided for @adsRepAge.
  ///
  /// In pt, this message translates to:
  /// **'Idade'**
  String get adsRepAge;

  /// No description provided for @adsRepCities.
  ///
  /// In pt, this message translates to:
  /// **'Cidades'**
  String get adsRepCities;

  /// No description provided for @adsRepStates.
  ///
  /// In pt, this message translates to:
  /// **'Estados'**
  String get adsRepStates;

  /// No description provided for @adsRepRegions.
  ///
  /// In pt, this message translates to:
  /// **'Regiões'**
  String get adsRepRegions;

  /// No description provided for @adsRepInterests.
  ///
  /// In pt, this message translates to:
  /// **'Interesses'**
  String get adsRepInterests;

  /// No description provided for @adsRepOthers.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get adsRepOthers;

  /// No description provided for @adsRepUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Não informada'**
  String get adsRepUnknown;

  /// No description provided for @adsRepNoData.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados ainda'**
  String get adsRepNoData;

  /// No description provided for @adsRepPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Só números somados. Grupos com poucas pessoas entram em \"Outros\" para ninguém ser identificado.'**
  String get adsRepPrivacy;

  /// No description provided for @adsRepLoggedOut.
  ///
  /// In pt, this message translates to:
  /// **'{n} pessoas viram sem estar logadas'**
  String adsRepLoggedOut(String n);

  /// No description provided for @adsRepHours.
  ///
  /// In pt, this message translates to:
  /// **'Melhores horários'**
  String get adsRepHours;

  /// No description provided for @adsRepBestHour.
  ///
  /// In pt, this message translates to:
  /// **'Mais visto às {h}h'**
  String adsRepBestHour(String h);

  /// No description provided for @adsRepWhere.
  ///
  /// In pt, this message translates to:
  /// **'Onde apareceu'**
  String get adsRepWhere;

  /// No description provided for @adsRepPlatforms.
  ///
  /// In pt, this message translates to:
  /// **'Aparelhos'**
  String get adsRepPlatforms;

  /// No description provided for @adsRepPlForyou.
  ///
  /// In pt, this message translates to:
  /// **'Para você'**
  String get adsRepPlForyou;

  /// No description provided for @adsRepPlFollowing.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get adsRepPlFollowing;

  /// No description provided for @adsRepPlStories.
  ///
  /// In pt, this message translates to:
  /// **'Stories'**
  String get adsRepPlStories;

  /// No description provided for @adsRepPlLives.
  ///
  /// In pt, this message translates to:
  /// **'Lives'**
  String get adsRepPlLives;

  /// No description provided for @adsRepPlExplore.
  ///
  /// In pt, this message translates to:
  /// **'Explorar'**
  String get adsRepPlExplore;

  /// No description provided for @adsRepPlWeb.
  ///
  /// In pt, this message translates to:
  /// **'Início do site'**
  String get adsRepPlWeb;

  /// No description provided for @adsRepLive.
  ///
  /// In pt, this message translates to:
  /// **'Live'**
  String get adsRepLive;

  /// No description provided for @adsRepLiveFromAd.
  ///
  /// In pt, this message translates to:
  /// **'Entraram pelo anúncio'**
  String get adsRepLiveFromAd;

  /// No description provided for @adsRepLivePeak.
  ///
  /// In pt, this message translates to:
  /// **'Pico de espectadores'**
  String get adsRepLivePeak;

  /// No description provided for @adsRepLiveGifts.
  ///
  /// In pt, this message translates to:
  /// **'Presentes'**
  String get adsRepLiveGifts;

  /// No description provided for @adsRepLiveMinutes.
  ///
  /// In pt, this message translates to:
  /// **'Minutos assistidos'**
  String get adsRepLiveMinutes;

  /// No description provided for @adsRepCoins.
  ///
  /// In pt, this message translates to:
  /// **'Coins'**
  String get adsRepCoins;

  /// No description provided for @adsRepCoinsPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pagas'**
  String get adsRepCoinsPaid;

  /// No description provided for @adsRepCoinsUsed.
  ///
  /// In pt, this message translates to:
  /// **'Usadas'**
  String get adsRepCoinsUsed;

  /// No description provided for @adsRepCoinsRefunded.
  ///
  /// In pt, this message translates to:
  /// **'Devolvidas'**
  String get adsRepCoinsRefunded;

  /// No description provided for @adsRepChanges.
  ///
  /// In pt, this message translates to:
  /// **'Alterações'**
  String get adsRepChanges;

  /// No description provided for @adsRepChangeDaily.
  ///
  /// In pt, this message translates to:
  /// **'Valor por dia'**
  String get adsRepChangeDaily;

  /// No description provided for @adsRepChangeTotal.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento total'**
  String get adsRepChangeTotal;

  /// No description provided for @adsRepChangeEnd.
  ///
  /// In pt, this message translates to:
  /// **'Data de término'**
  String get adsRepChangeEnd;

  /// No description provided for @adsRepResults.
  ///
  /// In pt, this message translates to:
  /// **'Resultados'**
  String get adsRepResults;

  /// No description provided for @boostStepGoal.
  ///
  /// In pt, this message translates to:
  /// **'Objetivo'**
  String get boostStepGoal;

  /// No description provided for @boostGoalTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que você quer com esse impulsionamento?'**
  String get boostGoalTitle;

  /// No description provided for @boostGoalViews.
  ///
  /// In pt, this message translates to:
  /// **'Mais visualizações'**
  String get boostGoalViews;

  /// No description provided for @boostGoalViewsHint.
  ///
  /// In pt, this message translates to:
  /// **'Mostra o post para mais gente.'**
  String get boostGoalViewsHint;

  /// No description provided for @boostGoalFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Mais seguidores'**
  String get boostGoalFollowers;

  /// No description provided for @boostGoalFollowersHint.
  ///
  /// In pt, this message translates to:
  /// **'Quem vê conhece seu perfil e pode seguir você.'**
  String get boostGoalFollowersHint;

  /// No description provided for @boostGoalProfile.
  ///
  /// In pt, this message translates to:
  /// **'Visitas ao perfil'**
  String get boostGoalProfile;

  /// No description provided for @boostGoalProfileHint.
  ///
  /// In pt, this message translates to:
  /// **'Mais pessoas abrindo o seu perfil.'**
  String get boostGoalProfileHint;

  /// No description provided for @boostGoalContacts.
  ///
  /// In pt, this message translates to:
  /// **'Receber mensagens'**
  String get boostGoalContacts;

  /// No description provided for @boostGoalContactsHint.
  ///
  /// In pt, this message translates to:
  /// **'Um botão para as pessoas falarem com você.'**
  String get boostGoalContactsHint;

  /// No description provided for @boostContactVia.
  ///
  /// In pt, this message translates to:
  /// **'Onde você quer receber as mensagens?'**
  String get boostContactVia;

  /// No description provided for @boostContactChat.
  ///
  /// In pt, this message translates to:
  /// **'Chat da Brawe'**
  String get boostContactChat;

  /// No description provided for @boostContactChatHint.
  ///
  /// In pt, this message translates to:
  /// **'As conversas chegam no seu Chat, aqui no app. Cada mensagem conta como contato no relatório.'**
  String get boostContactChatHint;

  /// No description provided for @boostContactWhatsapp.
  ///
  /// In pt, this message translates to:
  /// **'WhatsApp'**
  String get boostContactWhatsapp;

  /// No description provided for @boostContactWhatsappHint.
  ///
  /// In pt, this message translates to:
  /// **'O botão abre o seu WhatsApp com a mensagem pronta. Cada toque conta como contato no relatório.'**
  String get boostContactWhatsappHint;

  /// No description provided for @boostWhatsappPhone.
  ///
  /// In pt, this message translates to:
  /// **'Seu WhatsApp com DDD'**
  String get boostWhatsappPhone;

  /// No description provided for @boostWhatsappMessage.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem pronta'**
  String get boostWhatsappMessage;

  /// No description provided for @boostWhatsappMessageDefault.
  ///
  /// In pt, this message translates to:
  /// **'Olá! Vi seu post na Brawe e quero saber mais.'**
  String get boostWhatsappMessageDefault;

  /// No description provided for @boostPreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia'**
  String get boostPreview;

  /// No description provided for @boostPreviewHint.
  ///
  /// In pt, this message translates to:
  /// **'Assim o seu post aparece em cada lugar do app. Deslize para ver.'**
  String get boostPreviewHint;

  /// No description provided for @boostPlForYou.
  ///
  /// In pt, this message translates to:
  /// **'Para você'**
  String get boostPlForYou;

  /// No description provided for @boostPlFeed.
  ///
  /// In pt, this message translates to:
  /// **'Feed'**
  String get boostPlFeed;

  /// No description provided for @boostPlStories.
  ///
  /// In pt, this message translates to:
  /// **'Stories'**
  String get boostPlStories;

  /// No description provided for @boostPlTiles.
  ///
  /// In pt, this message translates to:
  /// **'Lives e Explorar'**
  String get boostPlTiles;

  /// No description provided for @boostAlreadyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Este post já está sendo impulsionado'**
  String get boostAlreadyTitle;

  /// No description provided for @boostAlreadyHint.
  ///
  /// In pt, this message translates to:
  /// **'Para alcançar mais pessoas, aumente o valor por dia ou edite o público da campanha que já existe (feita no app ou no site).'**
  String get boostAlreadyHint;

  /// No description provided for @boostSeeCampaign.
  ///
  /// In pt, this message translates to:
  /// **'Ver campanha'**
  String get boostSeeCampaign;

  /// No description provided for @adsCtaMessage.
  ///
  /// In pt, this message translates to:
  /// **'Enviar mensagem'**
  String get adsCtaMessage;

  /// No description provided for @adsCtaWhatsapp.
  ///
  /// In pt, this message translates to:
  /// **'Chamar no WhatsApp'**
  String get adsCtaWhatsapp;

  /// No description provided for @myAdsKindBrand.
  ///
  /// In pt, this message translates to:
  /// **'Anúncio da marca'**
  String get myAdsKindBrand;

  /// No description provided for @myAdsKindBoost.
  ///
  /// In pt, this message translates to:
  /// **'Impulsionamento'**
  String get myAdsKindBoost;

  /// No description provided for @myAdsLeadsChat.
  ///
  /// In pt, this message translates to:
  /// **'As mensagens de quem viu o anúncio chegam no seu Chat.'**
  String get myAdsLeadsChat;

  /// No description provided for @myAdsLeadsWhatsapp.
  ///
  /// In pt, this message translates to:
  /// **'Os contatos de quem viu o anúncio chegam no seu WhatsApp.'**
  String get myAdsLeadsWhatsapp;

  /// No description provided for @myAdsOpenChat.
  ///
  /// In pt, this message translates to:
  /// **'Abrir chat'**
  String get myAdsOpenChat;

  /// No description provided for @myAdsBrandEditOnWeb.
  ///
  /// In pt, this message translates to:
  /// **'Anúncio da marca: o criativo e o público se editam no painel de anúncios, pelo computador.'**
  String get myAdsBrandEditOnWeb;

  /// No description provided for @adsRepContacts.
  ///
  /// In pt, this message translates to:
  /// **'Contatos recebidos'**
  String get adsRepContacts;

  /// No description provided for @adsFollow.
  ///
  /// In pt, this message translates to:
  /// **'Seguir'**
  String get adsFollow;

  /// No description provided for @adsFollowingNow.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get adsFollowingNow;

  /// No description provided for @adsSeePost.
  ///
  /// In pt, this message translates to:
  /// **'Ver publicação'**
  String get adsSeePost;

  /// No description provided for @adsWatchVideo.
  ///
  /// In pt, this message translates to:
  /// **'Assistir vídeo'**
  String get adsWatchVideo;

  /// No description provided for @adsLearnMore.
  ///
  /// In pt, this message translates to:
  /// **'Saiba mais'**
  String get adsLearnMore;

  /// No description provided for @settingsGroupPreferences.
  ///
  /// In pt, this message translates to:
  /// **'Preferências'**
  String get settingsGroupPreferences;

  /// No description provided for @settingsGroupHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get settingsGroupHelp;

  /// No description provided for @settingsGroupAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get settingsGroupAbout;

  /// No description provided for @artistProfSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar: {error}'**
  String artistProfSaveError(String error);

  /// No description provided for @artistProfRequired.
  ///
  /// In pt, this message translates to:
  /// **'Obrigatório'**
  String get artistProfRequired;

  /// No description provided for @artistProfSectionIdentity.
  ///
  /// In pt, this message translates to:
  /// **'Identidade artística'**
  String get artistProfSectionIdentity;

  /// No description provided for @artistProfArtistName.
  ///
  /// In pt, this message translates to:
  /// **'Nome artístico'**
  String get artistProfArtistName;

  /// No description provided for @artistProfArtistNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Como você é conhecido'**
  String get artistProfArtistNameHint;

  /// No description provided for @artistProfBio.
  ///
  /// In pt, this message translates to:
  /// **'Bio do artista'**
  String get artistProfBio;

  /// No description provided for @artistProfBioHint.
  ///
  /// In pt, this message translates to:
  /// **'Conte sua história musical...'**
  String get artistProfBioHint;

  /// No description provided for @artistProfSectionLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get artistProfSectionLocation;

  /// No description provided for @artistProfCountry.
  ///
  /// In pt, this message translates to:
  /// **'País'**
  String get artistProfCountry;

  /// No description provided for @artistProfCountryHint.
  ///
  /// In pt, this message translates to:
  /// **'Selecione seu país'**
  String get artistProfCountryHint;

  /// No description provided for @artistProfCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get artistProfCity;

  /// No description provided for @artistProfCityHint.
  ///
  /// In pt, this message translates to:
  /// **'Sua cidade'**
  String get artistProfCityHint;

  /// No description provided for @artistProfLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma nativo'**
  String get artistProfLanguage;

  /// No description provided for @artistProfLanguageHint.
  ///
  /// In pt, this message translates to:
  /// **'Idioma principal'**
  String get artistProfLanguageHint;

  /// No description provided for @artistProfSectionGenres.
  ///
  /// In pt, this message translates to:
  /// **'Gêneros musicais'**
  String get artistProfSectionGenres;

  /// No description provided for @artistProfGenresHint.
  ///
  /// In pt, this message translates to:
  /// **'Selecione até 5 gêneros'**
  String get artistProfGenresHint;

  /// No description provided for @artistProfSectionPlatforms.
  ///
  /// In pt, this message translates to:
  /// **'Plataformas de streaming'**
  String get artistProfSectionPlatforms;

  /// No description provided for @artistProfCountryBR.
  ///
  /// In pt, this message translates to:
  /// **'Brasil'**
  String get artistProfCountryBR;

  /// No description provided for @artistProfCountryPT.
  ///
  /// In pt, this message translates to:
  /// **'Portugal'**
  String get artistProfCountryPT;

  /// No description provided for @artistProfCountryUS.
  ///
  /// In pt, this message translates to:
  /// **'Estados Unidos'**
  String get artistProfCountryUS;

  /// No description provided for @artistProfCountryAR.
  ///
  /// In pt, this message translates to:
  /// **'Argentina'**
  String get artistProfCountryAR;

  /// No description provided for @artistProfCountryMX.
  ///
  /// In pt, this message translates to:
  /// **'México'**
  String get artistProfCountryMX;

  /// No description provided for @artistProfCountryCO.
  ///
  /// In pt, this message translates to:
  /// **'Colômbia'**
  String get artistProfCountryCO;

  /// No description provided for @artistProfCountryCL.
  ///
  /// In pt, this message translates to:
  /// **'Chile'**
  String get artistProfCountryCL;

  /// No description provided for @artistProfCountryPE.
  ///
  /// In pt, this message translates to:
  /// **'Peru'**
  String get artistProfCountryPE;

  /// No description provided for @artistProfCountryUY.
  ///
  /// In pt, this message translates to:
  /// **'Uruguai'**
  String get artistProfCountryUY;

  /// No description provided for @artistProfCountryPY.
  ///
  /// In pt, this message translates to:
  /// **'Paraguai'**
  String get artistProfCountryPY;

  /// No description provided for @artistProfCountryBO.
  ///
  /// In pt, this message translates to:
  /// **'Bolívia'**
  String get artistProfCountryBO;

  /// No description provided for @artistProfCountryEC.
  ///
  /// In pt, this message translates to:
  /// **'Equador'**
  String get artistProfCountryEC;

  /// No description provided for @artistProfCountryVE.
  ///
  /// In pt, this message translates to:
  /// **'Venezuela'**
  String get artistProfCountryVE;

  /// No description provided for @artistProfCountryES.
  ///
  /// In pt, this message translates to:
  /// **'Espanha'**
  String get artistProfCountryES;

  /// No description provided for @artistProfCountryFR.
  ///
  /// In pt, this message translates to:
  /// **'França'**
  String get artistProfCountryFR;

  /// No description provided for @artistProfCountryDE.
  ///
  /// In pt, this message translates to:
  /// **'Alemanha'**
  String get artistProfCountryDE;

  /// No description provided for @artistProfCountryIT.
  ///
  /// In pt, this message translates to:
  /// **'Itália'**
  String get artistProfCountryIT;

  /// No description provided for @artistProfCountryGB.
  ///
  /// In pt, this message translates to:
  /// **'Reino Unido'**
  String get artistProfCountryGB;

  /// No description provided for @artistProfCountryJP.
  ///
  /// In pt, this message translates to:
  /// **'Japão'**
  String get artistProfCountryJP;

  /// No description provided for @artistProfCountryKR.
  ///
  /// In pt, this message translates to:
  /// **'Coreia do Sul'**
  String get artistProfCountryKR;

  /// No description provided for @artistProfCountryNG.
  ///
  /// In pt, this message translates to:
  /// **'Nigéria'**
  String get artistProfCountryNG;

  /// No description provided for @artistProfCountryGH.
  ///
  /// In pt, this message translates to:
  /// **'Gana'**
  String get artistProfCountryGH;

  /// No description provided for @artistProfCountryZA.
  ///
  /// In pt, this message translates to:
  /// **'África do Sul'**
  String get artistProfCountryZA;

  /// No description provided for @artistProfCountryAO.
  ///
  /// In pt, this message translates to:
  /// **'Angola'**
  String get artistProfCountryAO;

  /// No description provided for @artistProfCountryMZ.
  ///
  /// In pt, this message translates to:
  /// **'Moçambique'**
  String get artistProfCountryMZ;

  /// No description provided for @artistProfCountryCV.
  ///
  /// In pt, this message translates to:
  /// **'Cabo Verde'**
  String get artistProfCountryCV;

  /// No description provided for @bizProfSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar: {error}'**
  String bizProfSaveError(String error);

  /// No description provided for @bizProfRequired.
  ///
  /// In pt, this message translates to:
  /// **'Obrigatório'**
  String get bizProfRequired;

  /// No description provided for @bizProfSectionCompany.
  ///
  /// In pt, this message translates to:
  /// **'Empresa / Marca'**
  String get bizProfSectionCompany;

  /// No description provided for @bizProfCompanyName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da empresa ou marca'**
  String get bizProfCompanyName;

  /// No description provided for @bizProfCompanyNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Minha Empresa S.A.'**
  String get bizProfCompanyNameHint;

  /// No description provided for @bizProfAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre a empresa'**
  String get bizProfAbout;

  /// No description provided for @bizProfAboutHint.
  ///
  /// In pt, this message translates to:
  /// **'Descreva sua empresa ou marca...'**
  String get bizProfAboutHint;

  /// No description provided for @bizProfSector.
  ///
  /// In pt, this message translates to:
  /// **'Setor de atuação'**
  String get bizProfSector;

  /// No description provided for @bizProfSectorHint.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um setor'**
  String get bizProfSectorHint;

  /// No description provided for @bizProfSectionLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get bizProfSectionLocation;

  /// No description provided for @bizProfCountry.
  ///
  /// In pt, this message translates to:
  /// **'País de operação'**
  String get bizProfCountry;

  /// No description provided for @bizProfCountryHint.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o país'**
  String get bizProfCountryHint;

  /// No description provided for @bizProfCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get bizProfCity;

  /// No description provided for @bizProfCityHint.
  ///
  /// In pt, this message translates to:
  /// **'Cidade sede'**
  String get bizProfCityHint;

  /// No description provided for @bizProfLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma principal'**
  String get bizProfLanguage;

  /// No description provided for @bizProfLanguageHint.
  ///
  /// In pt, this message translates to:
  /// **'Idioma de operação'**
  String get bizProfLanguageHint;

  /// No description provided for @bizProfSectionFiscal.
  ///
  /// In pt, this message translates to:
  /// **'Dados fiscais'**
  String get bizProfSectionFiscal;

  /// No description provided for @bizProfFiscalRow.
  ///
  /// In pt, this message translates to:
  /// **'Dados fiscais e CNPJ'**
  String get bizProfFiscalRow;

  /// No description provided for @bizProfFiscalRowHint.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para verificação'**
  String get bizProfFiscalRowHint;

  /// No description provided for @bizProfSectionLinks.
  ///
  /// In pt, this message translates to:
  /// **'Links'**
  String get bizProfSectionLinks;

  /// No description provided for @bizProfWebsite.
  ///
  /// In pt, this message translates to:
  /// **'Website'**
  String get bizProfWebsite;

  /// No description provided for @bizProfWebsiteHint.
  ///
  /// In pt, this message translates to:
  /// **'https://suaempresa.com'**
  String get bizProfWebsiteHint;

  /// No description provided for @bizProfInstagramHint.
  ///
  /// In pt, this message translates to:
  /// **'@suaempresa'**
  String get bizProfInstagramHint;

  /// No description provided for @bizProfWhatsappHint.
  ///
  /// In pt, this message translates to:
  /// **'+55 11 99999-9999'**
  String get bizProfWhatsappHint;

  /// No description provided for @bizProfSectorFashionBeauty.
  ///
  /// In pt, this message translates to:
  /// **'Moda & Beleza'**
  String get bizProfSectorFashionBeauty;

  /// No description provided for @bizProfSectorTech.
  ///
  /// In pt, this message translates to:
  /// **'Tecnologia'**
  String get bizProfSectorTech;

  /// No description provided for @bizProfSectorFood.
  ///
  /// In pt, this message translates to:
  /// **'Alimentação & Bebidas'**
  String get bizProfSectorFood;

  /// No description provided for @bizProfSectorEntertainment.
  ///
  /// In pt, this message translates to:
  /// **'Entretenimento'**
  String get bizProfSectorEntertainment;

  /// No description provided for @bizProfSectorEducation.
  ///
  /// In pt, this message translates to:
  /// **'Educação'**
  String get bizProfSectorEducation;

  /// No description provided for @bizProfSectorHealth.
  ///
  /// In pt, this message translates to:
  /// **'Saúde & Bem-estar'**
  String get bizProfSectorHealth;

  /// No description provided for @bizProfSectorFinance.
  ///
  /// In pt, this message translates to:
  /// **'Finanças & Investimentos'**
  String get bizProfSectorFinance;

  /// No description provided for @bizProfSectorRetail.
  ///
  /// In pt, this message translates to:
  /// **'Varejo & E-commerce'**
  String get bizProfSectorRetail;

  /// No description provided for @bizProfSectorMusic.
  ///
  /// In pt, this message translates to:
  /// **'Música & Áudio'**
  String get bizProfSectorMusic;

  /// No description provided for @bizProfSectorGames.
  ///
  /// In pt, this message translates to:
  /// **'Games'**
  String get bizProfSectorGames;

  /// No description provided for @bizProfSectorSports.
  ///
  /// In pt, this message translates to:
  /// **'Esportes'**
  String get bizProfSectorSports;

  /// No description provided for @bizProfSectorRealEstate.
  ///
  /// In pt, this message translates to:
  /// **'Imóveis'**
  String get bizProfSectorRealEstate;

  /// No description provided for @bizProfSectorAgro.
  ///
  /// In pt, this message translates to:
  /// **'Agro & Sustentabilidade'**
  String get bizProfSectorAgro;

  /// No description provided for @bizProfSectorServices.
  ///
  /// In pt, this message translates to:
  /// **'Serviços Profissionais'**
  String get bizProfSectorServices;

  /// No description provided for @bizProfSectorNgo.
  ///
  /// In pt, this message translates to:
  /// **'ONG & Social'**
  String get bizProfSectorNgo;

  /// No description provided for @bizProfSectorOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get bizProfSectorOther;

  /// No description provided for @bizProfCountryBR.
  ///
  /// In pt, this message translates to:
  /// **'Brasil'**
  String get bizProfCountryBR;

  /// No description provided for @bizProfCountryPT.
  ///
  /// In pt, this message translates to:
  /// **'Portugal'**
  String get bizProfCountryPT;

  /// No description provided for @bizProfCountryUS.
  ///
  /// In pt, this message translates to:
  /// **'Estados Unidos'**
  String get bizProfCountryUS;

  /// No description provided for @bizProfCountryAR.
  ///
  /// In pt, this message translates to:
  /// **'Argentina'**
  String get bizProfCountryAR;

  /// No description provided for @bizProfCountryMX.
  ///
  /// In pt, this message translates to:
  /// **'México'**
  String get bizProfCountryMX;

  /// No description provided for @bizProfCountryCO.
  ///
  /// In pt, this message translates to:
  /// **'Colômbia'**
  String get bizProfCountryCO;

  /// No description provided for @bizProfCountryCL.
  ///
  /// In pt, this message translates to:
  /// **'Chile'**
  String get bizProfCountryCL;

  /// No description provided for @bizProfCountryES.
  ///
  /// In pt, this message translates to:
  /// **'Espanha'**
  String get bizProfCountryES;

  /// No description provided for @bizProfCountryDE.
  ///
  /// In pt, this message translates to:
  /// **'Alemanha'**
  String get bizProfCountryDE;

  /// No description provided for @bizProfCountryGB.
  ///
  /// In pt, this message translates to:
  /// **'Reino Unido'**
  String get bizProfCountryGB;

  /// No description provided for @bizProfCountryAO.
  ///
  /// In pt, this message translates to:
  /// **'Angola'**
  String get bizProfCountryAO;

  /// No description provided for @bizProfCountryMZ.
  ///
  /// In pt, this message translates to:
  /// **'Moçambique'**
  String get bizProfCountryMZ;

  /// No description provided for @acctTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de conta'**
  String get acctTitle;

  /// No description provided for @acctPersonal.
  ///
  /// In pt, this message translates to:
  /// **'Pessoal'**
  String get acctPersonal;

  /// No description provided for @acctPersonalHint.
  ///
  /// In pt, this message translates to:
  /// **'Para seguir, assistir, conversar e publicar.'**
  String get acctPersonalHint;

  /// No description provided for @acctCreator.
  ///
  /// In pt, this message translates to:
  /// **'Criador'**
  String get acctCreator;

  /// No description provided for @acctCreatorHint.
  ///
  /// In pt, this message translates to:
  /// **'Para quem faz lives e conteúdo e quer crescer e ganhar com isso.'**
  String get acctCreatorHint;

  /// No description provided for @acctArtist.
  ///
  /// In pt, this message translates to:
  /// **'Artista'**
  String get acctArtist;

  /// No description provided for @acctArtistHint.
  ///
  /// In pt, this message translates to:
  /// **'Músicos, bandas e DJs: perfil artístico com seus links de música.'**
  String get acctArtistHint;

  /// No description provided for @acctBusiness.
  ///
  /// In pt, this message translates to:
  /// **'Empresa'**
  String get acctBusiness;

  /// No description provided for @acctBusinessHint.
  ///
  /// In pt, this message translates to:
  /// **'Marcas e negócios. Exige identidade verificada e CNPJ aprovado.'**
  String get acctBusinessHint;

  /// No description provided for @acctFooter.
  ///
  /// In pt, this message translates to:
  /// **'Você pode trocar entre Pessoal, Criador e Artista quando quiser. Seus posts, seguidores e Coins continuam iguais.'**
  String get acctFooter;

  /// No description provided for @acctConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mudar para {name}?'**
  String acctConfirmTitle(String name);

  /// No description provided for @acctConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Seu perfil passa a mostrar este tipo de conta. Dá para voltar depois.'**
  String get acctConfirmBody;

  /// No description provided for @acctConfirmAction.
  ///
  /// In pt, this message translates to:
  /// **'Mudar'**
  String get acctConfirmAction;

  /// No description provided for @acctChanged.
  ///
  /// In pt, this message translates to:
  /// **'Agora sua conta é {name}'**
  String acctChanged(String name);

  /// No description provided for @acctChangeFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível trocar o tipo de conta.'**
  String get acctChangeFailed;

  /// No description provided for @acctBusinessStepsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Para virar Empresa'**
  String get acctBusinessStepsTitle;

  /// No description provided for @acctBusinessStepsBody.
  ///
  /// In pt, this message translates to:
  /// **'Para proteger quem compra e anuncia, contas de empresa passam por dois passos.'**
  String get acctBusinessStepsBody;

  /// No description provided for @acctStepIdentity.
  ///
  /// In pt, this message translates to:
  /// **'Verificar sua identidade'**
  String get acctStepIdentity;

  /// No description provided for @acctStepBusiness.
  ///
  /// In pt, this message translates to:
  /// **'Enviar CNPJ e dados fiscais'**
  String get acctStepBusiness;

  /// No description provided for @acctStepIdentityAction.
  ///
  /// In pt, this message translates to:
  /// **'Verificar identidade'**
  String get acctStepIdentityAction;

  /// No description provided for @acctStepBusinessAction.
  ///
  /// In pt, this message translates to:
  /// **'Enviar dados da empresa'**
  String get acctStepBusinessAction;

  /// No description provided for @editProfileCreatorPanel.
  ///
  /// In pt, this message translates to:
  /// **'Painel do criador'**
  String get editProfileCreatorPanel;

  /// No description provided for @editProfileArtistPage.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de artista'**
  String get editProfileArtistPage;

  /// No description provided for @editProfileBusinessPage.
  ///
  /// In pt, this message translates to:
  /// **'Perfil da empresa'**
  String get editProfileBusinessPage;

  /// No description provided for @editProfileWebsite.
  ///
  /// In pt, this message translates to:
  /// **'Site'**
  String get editProfileWebsite;

  /// No description provided for @kycTitle.
  ///
  /// In pt, this message translates to:
  /// **'Verificação'**
  String get kycTitle;

  /// No description provided for @kycApproved.
  ///
  /// In pt, this message translates to:
  /// **'Verificada'**
  String get kycApproved;

  /// No description provided for @kycInReview.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get kycInReview;

  /// No description provided for @kycRejected.
  ///
  /// In pt, this message translates to:
  /// **'Recusada'**
  String get kycRejected;

  /// No description provided for @kycNotStarted.
  ///
  /// In pt, this message translates to:
  /// **'Não verificada'**
  String get kycNotStarted;

  /// No description provided for @kycLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a verificação.'**
  String get kycLoadError;

  /// No description provided for @kycError.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente de novo.'**
  String get kycError;

  /// No description provided for @kycHeaderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua conta'**
  String get kycHeaderTitle;

  /// No description provided for @kycHeaderDone.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta é verificada'**
  String get kycHeaderDone;

  /// No description provided for @kycHeaderBody.
  ///
  /// In pt, this message translates to:
  /// **'Conta verificada ganha o selo azul, mais confiança de quem te segue e pode virar Empresa.'**
  String get kycHeaderBody;

  /// No description provided for @kycIdentityCaption.
  ///
  /// In pt, this message translates to:
  /// **'Identidade'**
  String get kycIdentityCaption;

  /// No description provided for @kycIdentityRow.
  ///
  /// In pt, this message translates to:
  /// **'Verificar identidade'**
  String get kycIdentityRow;

  /// No description provided for @kycIdentityRowHint.
  ///
  /// In pt, this message translates to:
  /// **'Documento + vídeo rápido'**
  String get kycIdentityRowHint;

  /// No description provided for @kycIdentityFooter.
  ///
  /// In pt, this message translates to:
  /// **'Leva uns 2 minutos. No Brasil: CNH Digital do dia. Outros países: passaporte.'**
  String get kycIdentityFooter;

  /// No description provided for @kycRejectedReason.
  ///
  /// In pt, this message translates to:
  /// **'Recusada: {reason}. Você pode enviar de novo.'**
  String kycRejectedReason(String reason);

  /// No description provided for @kycBusinessCaption.
  ///
  /// In pt, this message translates to:
  /// **'Empresa'**
  String get kycBusinessCaption;

  /// No description provided for @kycBusinessRow.
  ///
  /// In pt, this message translates to:
  /// **'Dados da empresa'**
  String get kycBusinessRow;

  /// No description provided for @kycBusinessRowHint.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ e dados fiscais'**
  String get kycBusinessRowHint;

  /// No description provided for @kycBusinessFooter.
  ///
  /// In pt, this message translates to:
  /// **'Com o CNPJ aprovado, sua conta vira Empresa.'**
  String get kycBusinessFooter;

  /// No description provided for @kycBusinessLocked.
  ///
  /// In pt, this message translates to:
  /// **'Disponível depois da identidade verificada.'**
  String get kycBusinessLocked;

  /// No description provided for @kycPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Seus documentos e o vídeo ficam cifrados, só a equipe de verificação vê, e são apagados assim que a análise termina.'**
  String get kycPrivacy;

  /// No description provided for @kycStepDocument.
  ///
  /// In pt, this message translates to:
  /// **'Documento'**
  String get kycStepDocument;

  /// No description provided for @kycStepLiveness.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo'**
  String get kycStepLiveness;

  /// No description provided for @kycStepSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get kycStepSend;

  /// No description provided for @kycCountry.
  ///
  /// In pt, this message translates to:
  /// **'País do documento'**
  String get kycCountry;

  /// No description provided for @kycCountrySearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar país'**
  String get kycCountrySearch;

  /// No description provided for @kycCountryChoose.
  ///
  /// In pt, this message translates to:
  /// **'Escolher país'**
  String get kycCountryChoose;

  /// No description provided for @kycDocument.
  ///
  /// In pt, this message translates to:
  /// **'Documento'**
  String get kycDocument;

  /// No description provided for @kycDocCnh.
  ///
  /// In pt, this message translates to:
  /// **'CNH Digital'**
  String get kycDocCnh;

  /// No description provided for @kycDocCnhHint.
  ///
  /// In pt, this message translates to:
  /// **'PDF exportado hoje no app CNH do Brasil'**
  String get kycDocCnhHint;

  /// No description provided for @kycDocPassport.
  ///
  /// In pt, this message translates to:
  /// **'Passaporte'**
  String get kycDocPassport;

  /// No description provided for @kycDocPassportHint.
  ///
  /// In pt, this message translates to:
  /// **'Página com foto, legível e dentro da validade'**
  String get kycDocPassportHint;

  /// No description provided for @kycCnhHowTo.
  ///
  /// In pt, this message translates to:
  /// **'No app CNH do Brasil (gov.br): abra sua CNH, toque em Compartilhar › Exportar e salve o PDF. Precisa ser gerado hoje.'**
  String get kycCnhHowTo;

  /// No description provided for @kycPassportHowTo.
  ///
  /// In pt, this message translates to:
  /// **'Envie a página com sua foto, sem reflexos e com os quatro cantos visíveis.'**
  String get kycPassportHowTo;

  /// No description provided for @kycPickFile.
  ///
  /// In pt, this message translates to:
  /// **'Escolher arquivo'**
  String get kycPickFile;

  /// No description provided for @kycChangeFile.
  ///
  /// In pt, this message translates to:
  /// **'Toque para trocar'**
  String get kycChangeFile;

  /// No description provided for @kycTakePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto do passaporte'**
  String get kycTakePhoto;

  /// No description provided for @kycLivenessIntro.
  ///
  /// In pt, this message translates to:
  /// **'Agora um vídeo curto para mostrar que é você mesmo. A câmera da frente abre e mostra o que você vai falar.'**
  String get kycLivenessIntro;

  /// No description provided for @kycTipLight.
  ///
  /// In pt, this message translates to:
  /// **'Fique num lugar bem iluminado'**
  String get kycTipLight;

  /// No description provided for @kycTipFace.
  ///
  /// In pt, this message translates to:
  /// **'Rosto livre: sem óculos escuros, boné ou máscara'**
  String get kycTipFace;

  /// No description provided for @kycTipTurn.
  ///
  /// In pt, this message translates to:
  /// **'Vire devagar o rosto para um lado e para o outro'**
  String get kycTipTurn;

  /// No description provided for @kycTipSpeak.
  ///
  /// In pt, this message translates to:
  /// **'Fale em voz alta o texto que aparece na tela'**
  String get kycTipSpeak;

  /// No description provided for @kycRecord.
  ///
  /// In pt, this message translates to:
  /// **'Gravar vídeo'**
  String get kycRecord;

  /// No description provided for @kycRecorded.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo gravado'**
  String get kycRecorded;

  /// No description provided for @kycRecordAgain.
  ///
  /// In pt, this message translates to:
  /// **'Toque para gravar de novo'**
  String get kycRecordAgain;

  /// No description provided for @kycReview.
  ///
  /// In pt, this message translates to:
  /// **'Confira'**
  String get kycReview;

  /// No description provided for @kycConsent.
  ///
  /// In pt, this message translates to:
  /// **'Autorizo a Brawe a usar este documento e o vídeo apenas para verificar minha identidade, conforme a LGPD.'**
  String get kycConsent;

  /// No description provided for @kycSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para análise'**
  String get kycSubmit;

  /// No description provided for @kycSentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviado para análise'**
  String get kycSentTitle;

  /// No description provided for @kycSentBody.
  ///
  /// In pt, this message translates to:
  /// **'Nossa equipe confere em até 2 dias úteis. Quando aprovar, o selo azul aparece no seu perfil.'**
  String get kycSentBody;

  /// No description provided for @kycBizSentBody.
  ///
  /// In pt, this message translates to:
  /// **'Nossa equipe confere em até 2 dias úteis. Quando aprovar, sua conta vira Empresa.'**
  String get kycBizSentBody;

  /// No description provided for @kycSay.
  ///
  /// In pt, this message translates to:
  /// **'Fale em voz alta:'**
  String get kycSay;

  /// No description provided for @kycScript.
  ///
  /// In pt, this message translates to:
  /// **'Meu nome é {name}. Hoje é {date}, {time}. Código {code}.'**
  String kycScript(String name, String date, String time, String code);

  /// No description provided for @kycCamReady.
  ///
  /// In pt, this message translates to:
  /// **'Encaixe o rosto e toque para gravar'**
  String get kycCamReady;

  /// No description provided for @kycCamLook.
  ///
  /// In pt, this message translates to:
  /// **'Olhe para a câmera'**
  String get kycCamLook;

  /// No description provided for @kycCamLeft.
  ///
  /// In pt, this message translates to:
  /// **'Vire devagar para a esquerda'**
  String get kycCamLeft;

  /// No description provided for @kycCamRight.
  ///
  /// In pt, this message translates to:
  /// **'Agora para a direita'**
  String get kycCamRight;

  /// No description provided for @kycCamSpeak.
  ///
  /// In pt, this message translates to:
  /// **'Fale o texto e toque para parar'**
  String get kycCamSpeak;

  /// No description provided for @kycCamError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a câmera. Permita o acesso à câmera e ao microfone nos Ajustes.'**
  String get kycCamError;

  /// No description provided for @kycTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Grave pelo menos 5 segundos'**
  String get kycTooShort;

  /// No description provided for @kycBizCompany.
  ///
  /// In pt, this message translates to:
  /// **'Empresa'**
  String get kycBizCompany;

  /// No description provided for @kycBizCnpjHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite o CNPJ: nome e endereço vêm da Receita Federal.'**
  String get kycBizCnpjHint;

  /// No description provided for @kycBizSituation.
  ///
  /// In pt, this message translates to:
  /// **'Situação na Receita: {status}'**
  String kycBizSituation(String status);

  /// No description provided for @kycBizLegalName.
  ///
  /// In pt, this message translates to:
  /// **'Razão social'**
  String get kycBizLegalName;

  /// No description provided for @kycBizTradeName.
  ///
  /// In pt, this message translates to:
  /// **'Nome fantasia'**
  String get kycBizTradeName;

  /// No description provided for @kycBizTax.
  ///
  /// In pt, this message translates to:
  /// **'Fiscal'**
  String get kycBizTax;

  /// No description provided for @kycBizRegime.
  ///
  /// In pt, this message translates to:
  /// **'Regime tributário'**
  String get kycBizRegime;

  /// No description provided for @kycRegimeSimples.
  ///
  /// In pt, this message translates to:
  /// **'Simples Nacional'**
  String get kycRegimeSimples;

  /// No description provided for @kycRegimePresumido.
  ///
  /// In pt, this message translates to:
  /// **'Lucro Presumido'**
  String get kycRegimePresumido;

  /// No description provided for @kycRegimeReal.
  ///
  /// In pt, this message translates to:
  /// **'Lucro Real'**
  String get kycRegimeReal;

  /// No description provided for @kycBizIe.
  ///
  /// In pt, this message translates to:
  /// **'Inscrição estadual'**
  String get kycBizIe;

  /// No description provided for @kycBizIeExempt.
  ///
  /// In pt, this message translates to:
  /// **'Isento de inscrição estadual'**
  String get kycBizIeExempt;

  /// No description provided for @kycBizAddress.
  ///
  /// In pt, this message translates to:
  /// **'Endereço'**
  String get kycBizAddress;

  /// No description provided for @kycBizZip.
  ///
  /// In pt, this message translates to:
  /// **'CEP'**
  String get kycBizZip;

  /// No description provided for @kycBizStreet.
  ///
  /// In pt, this message translates to:
  /// **'Rua'**
  String get kycBizStreet;

  /// No description provided for @kycBizNumber.
  ///
  /// In pt, this message translates to:
  /// **'Número'**
  String get kycBizNumber;

  /// No description provided for @kycBizDistrict.
  ///
  /// In pt, this message translates to:
  /// **'Bairro'**
  String get kycBizDistrict;

  /// No description provided for @kycBizCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get kycBizCity;

  /// No description provided for @kycBizCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão CNPJ'**
  String get kycBizCard;

  /// No description provided for @kycBizCardHint.
  ///
  /// In pt, this message translates to:
  /// **'Baixe o comprovante de inscrição no site da Receita Federal (PDF) ou envie uma foto nítida.'**
  String get kycBizCardHint;

  /// No description provided for @onbInterestsPickMin.
  ///
  /// In pt, this message translates to:
  /// **'Escolha pelo menos {n}'**
  String onbInterestsPickMin(String n);

  /// No description provided for @onbAboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre você'**
  String get onbAboutTitle;

  /// No description provided for @onbAboutSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda a mostrar pessoas, lives e ofertas da sua região.'**
  String get onbAboutSubtitle;

  /// No description provided for @onbGender.
  ///
  /// In pt, this message translates to:
  /// **'Gênero'**
  String get onbGender;

  /// No description provided for @onbGenderFemale.
  ///
  /// In pt, this message translates to:
  /// **'Feminino'**
  String get onbGenderFemale;

  /// No description provided for @onbGenderMale.
  ///
  /// In pt, this message translates to:
  /// **'Masculino'**
  String get onbGenderMale;

  /// No description provided for @onbGenderOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get onbGenderOther;

  /// No description provided for @onbGenderUndisclosed.
  ///
  /// In pt, this message translates to:
  /// **'Prefiro não dizer'**
  String get onbGenderUndisclosed;

  /// No description provided for @onbWhereYouLive.
  ///
  /// In pt, this message translates to:
  /// **'Onde você mora'**
  String get onbWhereYouLive;

  /// No description provided for @onbCityHint.
  ///
  /// In pt, this message translates to:
  /// **'Sua cidade'**
  String get onbCityHint;

  /// No description provided for @onbAboutPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Não mostramos seu gênero nem sua cidade no perfil. Usamos só para personalizar o que você vê.'**
  String get onbAboutPrivacy;

  /// No description provided for @editProfileAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre você'**
  String get editProfileAbout;

  /// No description provided for @boostGenderAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get boostGenderAll;

  /// No description provided for @boostGenderFemale.
  ///
  /// In pt, this message translates to:
  /// **'Mulheres'**
  String get boostGenderFemale;

  /// No description provided for @boostGenderMale.
  ///
  /// In pt, this message translates to:
  /// **'Homens'**
  String get boostGenderMale;

  /// No description provided for @adsRepGenderOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro / não disse'**
  String get adsRepGenderOther;
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
