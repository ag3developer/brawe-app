// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Brawe';

  @override
  String get navHome => 'Inicio';

  @override
  String get navFeed => 'Feed';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get tabFollowing => 'Siguiendo';

  @override
  String get tabForYou => 'Para Ti';

  @override
  String get actionFollow => 'Seguir';

  @override
  String get actionUnfollow => 'Siguiendo';

  @override
  String get actionLike => 'Me gusta';

  @override
  String get actionComment => 'Comentar';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionRepost => 'Repostear';

  @override
  String get actionSend => 'Enviar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionRetry => 'Intentar de nuevo';

  @override
  String get actionRefresh => 'Actualizar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionBack => 'Volver';

  @override
  String get actionBlock => 'Bloquear';

  @override
  String get actionUnblock => 'Desbloquear';

  @override
  String get actionReport => 'Denunciar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get feedEmptyTitle => 'Aún no hay videos aquí.';

  @override
  String get feedEmptySubtitle => 'Sigue a creadores o vuelve más tarde.';

  @override
  String get feedFollowingEmptyTitle =>
      'Sigue personas para ver sus posts aquí.';

  @override
  String get feedLoadError => 'No se pudo cargar el feed.';

  @override
  String get feedNoMore => '¡Estás al día! 🎉';

  @override
  String get profileEditButton => 'Editar perfil';

  @override
  String get profileFollowers => 'seguidores';

  @override
  String get profileFollowing => 'siguiendo';

  @override
  String get profileLives => 'directos';

  @override
  String get profileViews => 'vistas';

  @override
  String profileJoinedAt(String date) {
    return 'se unió en $date';
  }

  @override
  String get profileTabPosts => 'Posts';

  @override
  String get profileTabVideos => 'Videos';

  @override
  String get profileTabSaved => 'Guardados';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authLogout => 'Cerrar sesión';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authWelcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get chatNewMessage => 'Nuevo mensaje';

  @override
  String get chatPlaceholder => 'Mensaje...';

  @override
  String get chatNoConversations => 'Sin conversaciones aún.';

  @override
  String chatBlockTitle(String name) {
    return '¿Bloquear a $name?';
  }

  @override
  String chatBlockedSuccess(String name) {
    return '$name ha sido bloqueado(a).';
  }

  @override
  String chatBlockError(String error) {
    return 'Error al bloquear: $error';
  }

  @override
  String chatImagePickError(String error) {
    return 'Error al elegir imagen: $error';
  }

  @override
  String get commentsTitle => 'Comentarios';

  @override
  String get commentsPlaceholder => 'Agrega un comentario...';

  @override
  String get commentsEmpty => 'Aún no hay comentarios.\n¡Sé el primero!';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsEmpty => 'Sin notificaciones aún.';

  @override
  String notificationLiked(String user) {
    return 'A $user le gustó tu post.';
  }

  @override
  String notificationFollowed(String user) {
    return '$user empezó a seguirte.';
  }

  @override
  String notificationCommented(String user) {
    return '$user comentó en tu post.';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Português · Español · English';

  @override
  String get settingsAppLanguage => 'Idioma de la app';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotifLiveStart => 'Directos comenzando';

  @override
  String get settingsNotifLiveStartHint =>
      'Recibe aviso cuando tus creadores favoritos estén en vivo';

  @override
  String get settingsNotifGifts => 'Regalos recibidos';

  @override
  String get settingsNotifGiftsHint =>
      'Avisar cuando alguien te envíe un regalo';

  @override
  String get settingsNotifFollowers => 'Nuevos seguidores';

  @override
  String get settingsNotifMessages => 'Mensajes directos';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsPrivacyShowViewers => 'Mostrar nº de espectadores';

  @override
  String get settingsPrivacyShowViewersHint =>
      'Otros pueden ver cuántas personas ven tus directos';

  @override
  String get settingsPrivacyShowEarnings => 'Mostrar ganancias públicamente';

  @override
  String get settingsPrivacyShowEarningsHint =>
      'Mostrar total de coins/ganancias en tu perfil';

  @override
  String get settingsSounds => 'Sonidos';

  @override
  String get settingsSoundsEnabled => 'Efectos de sonido';

  @override
  String get settingsSoundsHint => 'Sonidos al recibir regalos, mensajes, etc.';

  @override
  String get settingsAbout => 'Acerca de & Legal';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLoadError => 'No pudimos cargar tu configuración.';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsTermsOfUse => 'Términos de Uso';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidad';

  @override
  String get settingsSupport => 'Soporte';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsLogoutConfirm => '¿Seguro que quieres cerrar sesión?';

  @override
  String get settingsHelpTitle => '¿Cómo podemos ayudarte?';

  @override
  String get settingsSendSupportEmail => 'Enviar correo al soporte';

  @override
  String get settingsNoMailApp => 'Ningún app de correo configurada.';

  @override
  String get settingsHelpCenterFaq => 'Centro de ayuda / FAQ';

  @override
  String settingsSupportEmailSubject(String version) {
    return 'Soporte Brawe — App v$version';
  }

  @override
  String settingsCantOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get cpCurrentPassword => 'Contraseña actual';

  @override
  String get cpNewPassword => 'Nueva contraseña';

  @override
  String get cpConfirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get cpMin8Chars => 'Mínimo 8 caracteres';

  @override
  String get cpSaveNewPassword => 'Guardar nueva contraseña';

  @override
  String get cpEnterCurrentPassword => 'Ingresa tu contraseña actual.';

  @override
  String get cpPasswordTooShort =>
      'La nueva contraseña debe tener al menos 8 caracteres.';

  @override
  String get cpPasswordsDontMatch => 'Las nuevas contraseñas no coinciden.';

  @override
  String get cpChangedSuccess => 'Contraseña cambiada con éxito.';

  @override
  String get cpChangeError => 'Error al cambiar la contraseña.';

  @override
  String get delAccTitle => 'Eliminar cuenta';

  @override
  String get delAccEnterPassword => 'Ingresa tu contraseña para confirmar.';

  @override
  String get delAccAckRequired => 'Confirma que entiendes la acción.';

  @override
  String get delAccConfirmBody =>
      'Esta acción es IRREVERSIBLE. Tu cuenta será desactivada y tus datos personales anonimizados (RGPD). ¿Deseas continuar?';

  @override
  String get delAccConfirmButton => 'Eliminar cuenta';

  @override
  String get delAccSuccess => 'Cuenta eliminada. Hasta luego.';

  @override
  String get delAccError => 'Error al eliminar la cuenta.';

  @override
  String get delAccWarningBanner =>
      'Al eliminar tu cuenta perderás permanentemente el acceso al historial de lives, regalos, saldo, conversaciones y seguidores. Los saldos pendientes pueden perderse.';

  @override
  String get delAccWhatHappens => 'Qué sucede:';

  @override
  String get delAccBullet1 => 'Tu cuenta será desactivada inmediatamente.';

  @override
  String get delAccBullet2 => 'Tu email y datos personales serán anonimizados.';

  @override
  String get delAccBullet3 => 'Cerrarás sesión en todos los dispositivos.';

  @override
  String get delAccBullet4 =>
      'Se conservarán los registros por el plazo legal requerido.';

  @override
  String get delAccPasswordHelper => 'Confirma tu identidad';

  @override
  String get delAccAckCheckbox => 'Entiendo que esta acción es irreversible.';

  @override
  String get delAccDeleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get legalOpenInBrowser => 'Abrir en el navegador';

  @override
  String get legalLoadError => 'No se pudo cargar esta página.';

  @override
  String get languagePickerTitle => 'Elige el idioma';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'English';

  @override
  String get errorNetwork => 'Sin conexión. Verifica tu internet.';

  @override
  String get errorGeneric => 'Algo salió mal. Intenta de nuevo.';

  @override
  String get errorNotFound => 'Contenido no encontrado.';

  @override
  String get errorUnauthorized => 'Sesión expirada. Inicia sesión de nuevo.';

  @override
  String get giftComingSoon => '🎁 ¡Próximamente!';

  @override
  String get liveBadge => 'EN VIVO';

  @override
  String viewerCount(int count) {
    return '$count viendo';
  }

  @override
  String get authLoginSubtitle => 'Inicia sesión en tu cuenta para continuar.';

  @override
  String get authWelcomeBackTitle => 'Bienvenido\nde vuelta.';

  @override
  String get authEmailHint => 'tu@brawe.app';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authEmailLabel => 'CORREO';

  @override
  String get authPasswordLabel => 'CONTRASEÑA';

  @override
  String get authForgotPasswordShort => 'Olvidé mi contraseña';

  @override
  String get authLoggingIn => 'Entrando…';

  @override
  String get authNoAccount => '¿No tienes cuenta?';

  @override
  String get authCreateNow => 'Crear ahora';

  @override
  String get authAcceptTermsAndPrivacy =>
      'Al continuar aceptas los Términos de Uso\ny la Política de Privacidad.';

  @override
  String get authWelcomeBackSuccess => 'Bienvenido de vuelta.';

  @override
  String get authAlreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authEntrar => 'Entrar';

  @override
  String get welcomeTagline => 'Conecta. Transmite. Crece.';

  @override
  String get welcomeAlreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get welcomeAcceptTerms => 'Al continuar aceptas los Términos de Uso.';

  @override
  String get welcomeCreateAccount => 'Crear cuenta';

  @override
  String get signupTitle => 'Crea tu cuenta.';

  @override
  String get signupSubtitle => 'Toma menos de un minuto empezar.';

  @override
  String get signupNameLabel => 'Nombre completo';

  @override
  String get signupNameHint => '¿Cómo debemos llamarte?';

  @override
  String get signupEmailLabel => 'Correo';

  @override
  String get signupPasswordLabel => 'Contraseña';

  @override
  String get signupPasswordHint => 'mínimo 8 caracteres';

  @override
  String get signupSponsorLabel => 'Código de patrocinador';

  @override
  String get signupSponsorHint => 'BRAWE-XXXX';

  @override
  String get signupHaveReferral => 'Tengo un código de referido';

  @override
  String get signupCreatingAccount => 'Creando cuenta…';

  @override
  String get signupCreateAccountButton => 'Crear cuenta';

  @override
  String get signupSuccess => 'Cuenta creada con éxito.';

  @override
  String get signupHelp => 'Ayuda';

  @override
  String signupCantOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get signupTermsPrefix => 'He leído y acepto los ';

  @override
  String get signupTermsAnd => ' y la ';

  @override
  String get signupTermsSuffix => ' de Brawe.';

  @override
  String get pwStrengthWeak => 'Débil';

  @override
  String get pwStrengthMedium => 'Media';

  @override
  String get pwStrengthGood => 'Buena';

  @override
  String get pwStrengthStrong => 'Fuerte';

  @override
  String get forgotTitle => 'Recuperar contraseña';

  @override
  String get forgotSubtitle =>
      'Ingresa tu correo y te enviaremos instrucciones para crear una nueva contraseña.';

  @override
  String get forgotEmailLabel => 'CORREO';

  @override
  String get forgotEmailHint => 'tu@ejemplo.com';

  @override
  String get forgotInvalidEmail => 'Ingresa un correo válido.';

  @override
  String get forgotSending => 'Enviando...';

  @override
  String get forgotSendInstructions => 'Enviar instrucciones';

  @override
  String get forgotCannotSend => 'No se pudo enviar.';

  @override
  String get forgotBackToLogin => 'Volver al inicio de sesión';

  @override
  String get forgotCheckEmail => 'Revisa tu correo';

  @override
  String forgotEmailSentBody(String email) {
    return 'Si $email está registrado, recibirás un enlace para crear una nueva contraseña en unos minutos.';
  }

  @override
  String get resetTitle => 'Crear nueva contraseña';

  @override
  String get resetSubtitle =>
      'Elige una contraseña fuerte de al menos 8 caracteres.';

  @override
  String get resetNewPasswordLabel => 'NUEVA CONTRASEÑA';

  @override
  String get resetConfirmPasswordLabel => 'CONFIRMAR CONTRASEÑA';

  @override
  String get resetPasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get resetPasswordsDontMatch => 'Las contraseñas no coinciden.';

  @override
  String get resetSaving => 'Guardando...';

  @override
  String get resetInvalidToken => 'Token inválido o caducado.';

  @override
  String get navLives => 'Lives';

  @override
  String get createStoryTitle => 'Historia';

  @override
  String get createStorySubtitle => 'Foto o video · desaparece en 24h';

  @override
  String get createVideoTitle => 'Video';

  @override
  String get createVideoSubtitle => 'Reels · aparece en Para Ti';

  @override
  String get createLiveTitle => 'Live';

  @override
  String get createLiveSubtitle => 'Transmite ahora y recibe regalos';

  @override
  String get createPostTitle => 'Publicación';

  @override
  String get createPostSubtitle => 'Texto, foto o enlace en tu feed';

  @override
  String get feedEmptyVideoTitle => 'Aún no hay video ni foto por aquí.';

  @override
  String get feedEmptyVideoSubtitle =>
      'Sigue a creadores o vuelve más tarde.\nLas publicaciones de texto están en la pestaña Feed.';

  @override
  String get liveJoining => 'Entrando a la live…';

  @override
  String get liveBadgeBattle => 'EN VIVO · BATALLA';

  @override
  String get liveBadgeShop => 'EN VIVO · SHOP';

  @override
  String get liveOfferNow => 'OFERTA AHORA';

  @override
  String get productFeatured => 'DESTACADO';

  @override
  String get videoLoadError => 'No se pudo cargar el video.';

  @override
  String get giftSendAnonymous => 'Enviar anónimamente';

  @override
  String get giftAnonNameHidden => 'Tu nombre no será revelado';

  @override
  String get giftAnonNameVisible => 'Todos verán que fuiste tú';

  @override
  String get giftSendButtonAnon => 'Enviar (anónimo)';

  @override
  String get giftSendButton => 'Enviar regalo';

  @override
  String get giftSentAnon => '¡Regalo enviado anónimamente!';

  @override
  String get giftSent => '¡Regalo enviado!';

  @override
  String get feedCannotLike => 'No se pudo dar like. Inténtalo de nuevo.';

  @override
  String get feedUseLiveChat => 'Usa el chat en vivo para hablar.';

  @override
  String get feedCannotShare => 'No se pudo compartir.';

  @override
  String get feedCannotFollow => 'No se pudo actualizar el seguimiento.';

  @override
  String get shareCheckBraweConnect => 'Míralo en Brawe Connect';

  @override
  String get homeStatFollowers => 'Seguidores';

  @override
  String get homeStatFollowing => 'Siguiendo';

  @override
  String get homeStatLives => 'Lives';

  @override
  String get profileViewFull => 'Ver perfil completo';

  @override
  String get createSheetTitle => 'Crear';

  @override
  String get createSheetSubtitle =>
      'Comparte un momento, abre un live o suelta una idea.';

  @override
  String get productsDrawerTitle => 'Tienda en vivo';

  @override
  String productsDrawerItemCount(int count, String author) {
    return '$count artículos • $author';
  }

  @override
  String get giftMysteryTitle => 'Regalo Misterioso';

  @override
  String get giftMysterySubtitle =>
      '¡Sorprende a uno de los streamers!\nEl destino se elige al azar. 🎲';

  @override
  String get commentsErrorSend =>
      'Error al enviar comentario. Inténtalo de nuevo.';

  @override
  String get commentsErrorLoad => 'Error al cargar comentarios.';

  @override
  String commentsReplyingTo(String username) {
    return 'Respondiendo a @$username';
  }

  @override
  String get commentsHintReply => 'Responder...';

  @override
  String get commentsHintAdd => 'Añadir comentario...';

  @override
  String get commentsReplyAction => 'Responder';

  @override
  String get postPublish => 'Publicar';

  @override
  String get postPublishedSuccess => '¡Publicación creada!';

  @override
  String get postPublishError => 'Error al publicar. Inténtalo de nuevo.';

  @override
  String get postHintWhatsHappening => '¿Qué está pasando?';

  @override
  String get audiencePickerTitle => '¿Quién puede ver?';

  @override
  String get audienceAll => 'Todos';

  @override
  String get audienceFollowers => 'Seguidores';

  @override
  String get audienceOnlyMe => 'Solo yo';

  @override
  String get videoTooLarge => 'Vídeo demasiado grande. Máximo 100 MB.';

  @override
  String get videoOpenError => 'No se pudo abrir el vídeo.';

  @override
  String get videoPublishedSuccess => '¡Vídeo publicado! 🎬';

  @override
  String get videoPublishError =>
      'Error al publicar vídeo. Inténtalo de nuevo.';

  @override
  String get videoSheetTitle => 'Nuevo vídeo';

  @override
  String get videoSwapTooltip => 'Cambiar vídeo';

  @override
  String get videoCaptionHint => 'Escribe una descripción (opcional)…';

  @override
  String get videoPublishButton => 'Publicar vídeo';

  @override
  String get videoSelect => 'Seleccionar vídeo';

  @override
  String get videoFormatsHint =>
      'MP4 · MOV · WebM   ·   hasta 3 min   ·   100 MB';

  @override
  String get storySheetTitle => 'Nueva story';

  @override
  String get storyPublish => 'Publicar';

  @override
  String get storyPublishedSuccess => '¡Story publicada!';

  @override
  String get storyPublishError =>
      'Error al publicar story. Inténtalo de nuevo.';

  @override
  String get storyPrefetchError => 'Error al cargar imagen del post.';

  @override
  String get storyPrefetchLoading => 'Cargando imagen del post...';

  @override
  String get storyCaptionHint => 'Escribe una descripción (opcional)…';

  @override
  String get storySwapMedia => 'Cambiar medio';

  @override
  String get storyPickerTitle => 'Selecciona o graba un medio';

  @override
  String get storyPickerSubtitle => 'Foto o vídeo (hasta 60s)';

  @override
  String get storyPickerSectionGallery => 'Galería';

  @override
  String get storyPickerSectionCamera => 'Cámara';

  @override
  String get storyPickerChipPhoto => 'Foto';

  @override
  String get storyPickerChipVideo => 'Vídeo';

  @override
  String get storyPickerChipRecordVideo => 'Grabar vídeo';

  @override
  String get storiesReload => 'Recargar stories';

  @override
  String get storiesYour => 'Tu story';

  @override
  String get storiesCreate => 'Crear';

  @override
  String get storiesFallbackUser => 'usuario';

  @override
  String get storiesLiveBadge => 'LIVE';

  @override
  String get shareLoadError => 'No se pudieron cargar los contactos.';

  @override
  String shareSentSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado a $count personas.',
      one: 'Enviado a $count persona.',
    );
    return '$_temp0';
  }

  @override
  String shareSentPartial(int sent, int failures) {
    return 'Enviado a $sent. Falló en $failures.';
  }

  @override
  String get shareTitle => 'Enviar a...';

  @override
  String get sharePostFallback => 'Publicación';

  @override
  String get shareSearchHint => 'Buscar';

  @override
  String get shareErrorGeneric => 'Error';

  @override
  String get shareTryAgain => 'Intentar de nuevo';

  @override
  String get shareRecents => 'Recientes';

  @override
  String get shareFollowers => 'Seguidores';

  @override
  String get shareUserFallback => 'Usuario';

  @override
  String get shareNoContacts => 'No se encontraron contactos.';

  @override
  String get shareCommentHint => 'Añade un comentario…';

  @override
  String get shareOutsideBrawe => 'Fuera de Brawe';

  @override
  String get shareSend => 'Enviar';

  @override
  String shareSendWithCount(int count) {
    return 'Enviar ($count)';
  }

  @override
  String giftSendError(Object error) {
    return 'No se pudo enviar el regalo: $error';
  }

  @override
  String giftLoadError(Object error) {
    return 'No se pudieron cargar los regalos.\n$error';
  }

  @override
  String get giftEmptyState => 'No hay regalos disponibles ahora.';

  @override
  String get giftSendTo => 'Enviar regalo a';

  @override
  String get giftChoose => 'Elige un regalo';

  @override
  String giftSendCta(int total) {
    return 'ENVIAR · 💎 $total';
  }

  @override
  String get suggestedTitle => 'Sugerencias para ti';

  @override
  String get suggestedSeeAll => 'Ver todos';

  @override
  String get suggestedFollow => 'Seguir';

  @override
  String get suggestedFollowing => 'Siguiendo';

  @override
  String get suggestedLiveBadge => 'EN VIVO';

  @override
  String get composerMediaLoadError => 'No se pudo cargar el contenido.';

  @override
  String get composerPhotoError => 'Error al tomar foto.';

  @override
  String get composerRecordStartError => 'Error al iniciar grabación.';

  @override
  String get composerRecordStopError => 'Error al finalizar grabación.';

  @override
  String get composerStoryPublished => '¡Story publicado!';

  @override
  String composerMultipleStoriesPublished(int count) {
    return '¡$count stories publicados!';
  }

  @override
  String get composerPublishError => 'Error al publicar story.';

  @override
  String get composerPublishTimeoutMaybe =>
      'Conexión lenta — revisa tu feed; si el story está allí, ya se publicó.';

  @override
  String get composerRetry => 'Reintentar';

  @override
  String get composerPreparing => 'Preparando publicación…';

  @override
  String get composerCreateStory => 'Crear story';

  @override
  String get composerCaptureHint => 'Toca para foto • Mantén para video';

  @override
  String get composerGallery => 'Galería';

  @override
  String get composerTextOnly => 'Solo texto';

  @override
  String get composerFrameNone => 'Sin marco';

  @override
  String get composerFramePolaroid => 'Polaroid';

  @override
  String get composerFrameBrawe => 'Brawe';

  @override
  String get composerFrameHint => 'Toca 2 veces para marco';

  @override
  String composerFrameLabel(String style) {
    return 'Marco: $style';
  }

  @override
  String get composerCaptionHint => 'Añade una leyenda...';

  @override
  String get composerYourStory => 'Tu historia';

  @override
  String get composerShare => 'Compartir';

  @override
  String get composerTapOutsideHint => 'Toca afuera para terminar';

  @override
  String get composerTextHint => 'Escribe algo...';

  @override
  String get composerGuideTop => 'tope seguro';

  @override
  String get composerGuideBottom => 'base segura';

  @override
  String get composerSaveToDevice => 'Guardar en el dispositivo';

  @override
  String get composerSavedToDevice => 'Guardado en la galería';

  @override
  String get composerSavePermissionDenied => 'Acceso a la galería denegado.';

  @override
  String get composerSaveError => 'No se pudo guardar.';

  @override
  String get trimTitle => 'Recortar video';

  @override
  String get trimSave => 'Listo';

  @override
  String get trimCancel => 'Cancelar';

  @override
  String get trimProcessing => 'Guardando…';

  @override
  String trimDuration(String seconds) {
    return '${seconds}s';
  }

  @override
  String get trimError => 'No se pudo guardar el video recortado.';

  @override
  String get trimHint => 'Arrastra los controles para elegir inicio y fin';

  @override
  String get volumeMixerButtonLabel => 'Volúmenes';

  @override
  String get volumeMixerTitle => 'Volúmenes';

  @override
  String get volumeMixerSubtitle =>
      'Ajusta el volumen de la música y el audio original del video';

  @override
  String get volumeMixerMusicLabel => 'Música';

  @override
  String get volumeMixerOriginalLabel => 'Audio original del video';

  @override
  String get volumeMixerDone => 'Listo';

  @override
  String get giftTierFree => 'Bóveda';

  @override
  String get giftTierBasic => 'Básico';

  @override
  String get giftTierPremium => 'Premium';

  @override
  String get giftTierLuxury => 'Lujo';

  @override
  String get giftTierLegendary => 'Legendario';

  @override
  String get viewerDeleteStory => 'Eliminar story';

  @override
  String get viewerUnfollow => 'Dejar de seguir';

  @override
  String get viewerBlockUser => 'Bloquear usuario';

  @override
  String get viewerReport => 'Denunciar';

  @override
  String get viewerDeleteConfirm => 'Esta acción no se puede deshacer.';

  @override
  String get viewerCancel => 'Cancelar';

  @override
  String get viewerDelete => 'Eliminar';

  @override
  String get viewerBlock => 'Bloquear';

  @override
  String get viewerStoryDeleted => 'Story eliminado.';

  @override
  String viewerDeleteError(Object error) {
    return 'No se pudo eliminar el story. ($error)';
  }

  @override
  String viewerUnfollowed(String username) {
    return 'Dejaste de seguir a @$username.';
  }

  @override
  String get viewerUnfollowError => 'No se pudo dejar de seguir.';

  @override
  String viewerBlockConfirm(String username) {
    return 'Ya no verás contenido de @$username.';
  }

  @override
  String get viewerBlockError => 'No se pudo bloquear.';

  @override
  String get viewerReportPrompt => '¿Por qué estás denunciando?';

  @override
  String get viewerReportSpam => 'Spam o engañoso';

  @override
  String get viewerReportHarassment => 'Acoso o bullying';

  @override
  String get viewerReportInappropriate => 'Contenido inapropiado u ofensivo';

  @override
  String get viewerReportImpersonation => 'Identidad falsa';

  @override
  String get viewerReportOther => 'Otro';

  @override
  String get viewerReportSent => 'Denuncia enviada. Gracias.';

  @override
  String get viewerReportError => 'No se pudo enviar la denuncia.';

  @override
  String get viewerSeeOriginalPost => 'Ver publicación original';

  @override
  String get viewerReplySent => 'Respuesta enviada.';

  @override
  String get viewerReplyError => 'No se pudo responder.';

  @override
  String get viewerReplyHint => 'Responder al story...';

  @override
  String viewerGiftSent(String giftName, int quantity, int credits) {
    return 'Envió $giftName x$quantity · 💎 $credits';
  }

  @override
  String get viewerLoadViewersError =>
      'No se pudieron cargar los visualizadores.';

  @override
  String get viewerTimeNow => 'ahora';

  @override
  String viewerTimeMinutes(int minutes) {
    return 'hace ${minutes}m';
  }

  @override
  String viewerTimeHours(int hours) {
    return 'hace ${hours}h';
  }

  @override
  String viewerTimeDays(int days) {
    return 'hace ${days}d';
  }

  @override
  String get viewerLoading => 'Cargando...';

  @override
  String get viewerNoViewers => 'Nadie ha visto este story aún.';

  @override
  String viewerBlocked(String username) {
    return '@$username bloqueado.';
  }

  @override
  String viewerViewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visualizaciones',
      one: '1 visualización',
    );
    return '$_temp0';
  }

  @override
  String get feedTabForYou => 'Para Ti';

  @override
  String get feedTabFollowing => 'Siguiendo';

  @override
  String get feedEmptyQuietTitle => 'El feed está tranquilo';

  @override
  String get feedEmptyQuietSubtitle =>
      'Sé el primero en publicar algo brillante hoy.';

  @override
  String get feedEmptyFollowingTitle => 'Nada por aquí aún';

  @override
  String get feedEmptyFollowingSubtitle =>
      'Sigue personas para ver sus publicaciones aquí.';

  @override
  String get feedOfflineTitle => 'Sin conexión por aquí';

  @override
  String get feedOfflineSubtitle => 'Verifica tu internet e intenta de nuevo.';

  @override
  String get feedRetry => 'Intentar de nuevo';

  @override
  String get feedSaved => 'Guardado en tus favoritos';

  @override
  String get feedUnsaved => 'Eliminado de favoritos';

  @override
  String get feedLinkCopied => '¡Enlace copiado!';

  @override
  String get feedDeletePostTitle => '¿Eliminar publicación?';

  @override
  String get feedDeleteConfirm => 'Esta acción no se puede deshacer.';

  @override
  String get feedCancel => 'Cancelar';

  @override
  String get feedDelete => 'Eliminar';

  @override
  String get feedPostDeleted => 'Publicación eliminada.';

  @override
  String get feedPostDeleteError => 'No se pudo eliminar la publicación.';

  @override
  String feedUnfollowed(String username) {
    return 'Dejaste de seguir a @$username.';
  }

  @override
  String get feedUnfollowError => 'No se pudo dejar de seguir.';

  @override
  String get feedBlockUserTitle => 'Bloquear usuario';

  @override
  String feedBlockConfirm(String username) {
    return 'Ya no verás contenido de @$username. ¿Continuar?';
  }

  @override
  String get feedBlock => 'Bloquear';

  @override
  String get feedBlockError => 'No se pudo bloquear.';

  @override
  String get feedReportTitle => 'Denunciar publicación';

  @override
  String get feedReportPrompt => '¿Por qué estás denunciando?';

  @override
  String get feedReportSpam => 'Spam o engañoso';

  @override
  String get feedReportHarassment => 'Acoso o bullying';

  @override
  String get feedReportInappropriate => 'Contenido inapropiado u ofensivo';

  @override
  String get feedReportImpersonation => 'Identidad falsa';

  @override
  String get feedReportOther => 'Otro';

  @override
  String get feedReportSent => 'Denuncia enviada. Gracias por avisarnos.';

  @override
  String get feedReportError => 'No se pudo enviar la denuncia.';

  @override
  String get feedRepostUndoConfirm => '¿Deshacer repost?';

  @override
  String get feedRepostConfirm => '¿Repostar a tus seguidores?';

  @override
  String get feedRepostUndo => 'Deshacer repost';

  @override
  String get feedRepost => 'Repostar';

  @override
  String get feedReposted => 'Reposteado a tus seguidores';

  @override
  String get shareToFollowers => 'Enviar a seguidores';

  @override
  String feedRepostBanner(String name) {
    return '$name reposteó';
  }

  @override
  String get feedQuotePost => 'Citar publicación';

  @override
  String get feedCopyLink => 'Copiar enlace';

  @override
  String get feedShareAsStory => 'Compartir como Story';

  @override
  String get feedUnfollow => 'Dejar de seguir';

  @override
  String get feedReport => 'Denunciar';

  @override
  String get feedDeletePost => 'Eliminar publicación';

  @override
  String get feedSend => 'Enviar';

  @override
  String get feedTimeNow => 'ahora';

  @override
  String feedBlocked(String username) {
    return '@$username bloqueado.';
  }

  @override
  String get chatStatusOnline => 'En línea';

  @override
  String get chatStatusAway => 'Ausente';

  @override
  String get chatStatusDnd => 'No molestar';

  @override
  String get chatStatusInvisible => 'Invisible';

  @override
  String get chatStatusSheetTitle => 'Mi estado';

  @override
  String get chatStatusSheetSubtitle =>
      'Elige cómo apareces ante otros usuarios.';

  @override
  String get chatNewMessageTitle => 'Nuevo mensaje';

  @override
  String get chatSearchHint => 'Buscar personas que sigues…';

  @override
  String get chatFollowingLabel => 'Siguiendo';

  @override
  String chatStartConversationError(Object error) {
    return 'Error al iniciar conversación: $error';
  }

  @override
  String chatLoadError(Object error) {
    return 'Error al cargar: $error';
  }

  @override
  String get chatLiveBadge => 'EN VIVO';

  @override
  String get chatFallbackName => 'Chat';

  @override
  String get chatEmptySearchTitle => 'No se encontraron personas';

  @override
  String get chatEmptySearchSubtitle =>
      'Prueba buscar por nombre o @username de alguien que sigues.';

  @override
  String get chatListTitle => 'Mensajes';

  @override
  String get chatListSearchHint => 'Buscar conversaciones, personas…';

  @override
  String get chatListTabAll => 'Todas';

  @override
  String get chatListTabUnread => 'No leídas';

  @override
  String get chatListTabArchived => 'Archivadas';

  @override
  String get chatListRetry => 'Intentar de nuevo';

  @override
  String get chatListNewTooltip => 'Nueva conversación';

  @override
  String get chatListEmptyTitle => 'Inicia una conversación';

  @override
  String get chatListEmptySubtitle =>
      'Tus mensajes con creators, amigos y brawers aparecerán aquí.';

  @override
  String get chatListTapToTalk => 'Toca para conversar';

  @override
  String get chatListArchive => 'Archivar';

  @override
  String get chatListUnarchive => 'Desarchivar';

  @override
  String get chatListDelete => 'Eliminar';

  @override
  String get chatListDeleteConfirmTitle => '¿Eliminar conversación?';

  @override
  String get chatListDeleteConfirmBody =>
      'La conversación se eliminará solo para ti.';

  @override
  String get chatListCancel => 'Cancelar';

  @override
  String get chatListTimeNow => 'ahora';

  @override
  String chatDetailPickImageError(Object error) {
    return 'Error al elegir imagen: $error';
  }

  @override
  String chatDetailBlockTitle(String name) {
    return '¿Bloquear a $name?';
  }

  @override
  String get chatDetailBlockBody =>
      'Ya no podrás enviar ni recibir mensajes de esta persona.';

  @override
  String get chatDetailCancel => 'Cancelar';

  @override
  String get chatDetailBlock => 'Bloquear';

  @override
  String chatDetailBlocked(String name) {
    return '$name ha sido bloqueado(a).';
  }

  @override
  String chatDetailBlockError(Object error) {
    return 'Error al bloquear: $error';
  }

  @override
  String get chatDetailViewProfile => 'Ver perfil';

  @override
  String get chatDetailOpenProfileError =>
      'No se pudo abrir el perfil de este contacto.';

  @override
  String get chatDetailMute => 'Silenciar notificaciones';

  @override
  String get chatDetailComingSoon => 'Pronto';

  @override
  String get chatDetailSearchInChat => 'Buscar en el chat';

  @override
  String chatDetailBlockMenu(String name) {
    return 'Bloquear a $name';
  }

  @override
  String get chatDetailReport => 'Denunciar';

  @override
  String get chatDetailReportSent => 'Denuncia enviada. ¡Gracias!';

  @override
  String get chatDetailStatusTyping => 'escribiendo';

  @override
  String get chatDetailStatusOnline => 'En línea';

  @override
  String chatDetailStatusSeen(String when) {
    return 'visto $when';
  }

  @override
  String get chatDetailStatusOffline => 'Desconectado';

  @override
  String get chatDetailDateToday => 'Hoy';

  @override
  String get chatDetailDateYesterday => 'Ayer';

  @override
  String get chatDetailReply => 'Responder';

  @override
  String get chatDetailCopy => 'Copiar';

  @override
  String get chatDetailDeleteForMe => 'Eliminar para mí';

  @override
  String get chatDetailViewOnceBadge => 'Ver 1 vez';

  @override
  String get chatDetailViewOnceTitle => 'Visualización única';

  @override
  String get chatDetailPhotoViewedOnce => 'Foto vista 1 vez';

  @override
  String get chatDetailPhotoUnavailable => 'La foto ya no está disponible';

  @override
  String get chatDetailEmptyTitle => 'Saluda 👋';

  @override
  String get chatDetailEmptySubtitle =>
      'Envía el primer mensaje para iniciar la conversación.';

  @override
  String get chatDetailReplying => 'Respondiendo';

  @override
  String get chatDetailReplyImagePreview => '📷 Foto';

  @override
  String get chatDetailMessageHint => 'Mensaje';

  @override
  String get chatDetailVoiceTitle => 'Mensaje de voz';

  @override
  String get chatDetailVoiceSubtitle =>
      'Pronto — grabación con waveform animado';

  @override
  String get chatDetailClose => 'Cerrar';

  @override
  String get chatDetailAttachGallery => 'Galería';

  @override
  String get chatDetailAttachCamera => 'Cámara';

  @override
  String get chatDetailAttachAudio => 'Audio';

  @override
  String get chatDetailAttachLocation => 'Ubicación';

  @override
  String get chatDetailAttachFile => 'Archivo';

  @override
  String get chatDetailAttachMystery => 'Misterio';

  @override
  String get chatDetailRelativeNow => 'ahora';

  @override
  String chatDetailRelativeMinutes(int minutes) {
    return 'hace ${minutes}m';
  }

  @override
  String chatDetailRelativeHours(int hours) {
    return 'hace ${hours}h';
  }

  @override
  String chatDetailRelativeDays(int days) {
    return 'hace ${days}d';
  }

  @override
  String get chatDetailViewPost => 'Ver publicación';

  @override
  String get chatDetailPostUnavailable => 'Publicación no disponible';

  @override
  String get chatDetailOpenPostSoon => 'Abrir publicación próximamente';

  @override
  String get chatDetailBurnedPreview => '🔥 Mensaje quemado';

  @override
  String get chatDetailStreamerFallback => 'Streamer';

  @override
  String get chatDetailLiveFallbackTitle => 'En vivo';

  @override
  String get chatDetailLiveTapToWatch => 'Toca para ver';

  @override
  String get chatDetailLiveSeeDetails => 'Ver detalles';

  @override
  String get chatDetailEmojiSmileys => 'Emoticonos';

  @override
  String get chatDetailEmojiGestures => 'Gestos';

  @override
  String get chatDetailEmojiHearts => 'Corazones';

  @override
  String get chatDetailEmojiAnimals => 'Animales';

  @override
  String get chatDetailEmojiFood => 'Comida';

  @override
  String get chatDetailEmojiParty => 'Fiesta';

  @override
  String get chatDetailEmojiObjects => 'Objetos';

  @override
  String get profileTabGallery => 'Galería';

  @override
  String get profileTabLives => 'Directos';

  @override
  String get profileTabShop => 'Tienda';

  @override
  String get profileTooltipShop => 'Tienda';

  @override
  String get profileTooltipQuests => 'Misiones';

  @override
  String get profileTooltipNotifications => 'Notificaciones';

  @override
  String get profileTooltipWallet => 'Cartera';

  @override
  String get profileShareFail => 'No se pudo compartir.';

  @override
  String get profileLinkCopied => 'Enlace copiado al portapapeles';

  @override
  String get profileBlockedSuccess => 'Usuario bloqueado.';

  @override
  String get profileBlockedError => 'No se pudo bloquear. Inténtalo de nuevo.';

  @override
  String get profileReportSent => 'Denuncia enviada. Gracias.';

  @override
  String get profileReportError => 'No se pudo denunciar. Inténtalo de nuevo.';

  @override
  String get profileBlockTitle => 'Bloquear';

  @override
  String profileBlockBody(String name) {
    return '¿Seguro que quieres bloquear a $name? Ya no podrán intercambiar mensajes ni ver el contenido del otro.';
  }

  @override
  String get profileFallbackUser => 'este usuario';

  @override
  String get profileReportQuestion => '¿Por qué denuncias?';

  @override
  String get profileReportReasonSpam => 'Spam';

  @override
  String get profileReportReasonHarassment => 'Acoso o bullying';

  @override
  String get profileReportReasonInappropriate => 'Contenido inapropiado';

  @override
  String get profileReportReasonImpersonation => 'Suplantación de identidad';

  @override
  String get profileReportReasonOther => 'Otro motivo';

  @override
  String get profileOptionShareProfile => 'Compartir perfil';

  @override
  String get profileOptionCopyLink => 'Copiar enlace';

  @override
  String get profileOptionReport => 'Denunciar';

  @override
  String get profileOptionDailyQuests => 'Misiones diarias';

  @override
  String get profileOptionWallet => 'Cartera';

  @override
  String get profileOptionNotifications => 'Notificaciones';

  @override
  String get profileOptionSettings => 'Configuración';

  @override
  String get profileOptionLogout => 'Cerrar sesión';

  @override
  String get profileLogoutTitle => '¿Cerrar sesión?';

  @override
  String get profileLogoutBody =>
      'Tendrás que iniciar sesión de nuevo para acceder a tu arena.';

  @override
  String get profileLogoutConfirm => 'Cerrar sesión';

  @override
  String get profileMessageButton => 'Mensaje';

  @override
  String profileOpenConversationError(Object error) {
    return 'Error al abrir la conversación: $error';
  }

  @override
  String get profileChatFallback => 'Chat';

  @override
  String get profileUserFallback => 'Usuario';

  @override
  String get profileEditTooltip => 'Editar perfil';

  @override
  String get profileStatFollowers => 'Seguidores';

  @override
  String get profileStatFollowing => 'Siguiendo';

  @override
  String get profileStatLives => 'Directos';

  @override
  String get profileStatViews => 'Vistas';

  @override
  String get profileLoadError => 'No se pudo cargar el perfil';

  @override
  String get profileLoadErrorHint =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get profileRetry => 'Reintentar';

  @override
  String get profileSellerVerified => 'Socio verificado';

  @override
  String get profileSellerSubtitle => 'Selección de productos con curaduría';

  @override
  String shopVitrinePartnerItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
    );
    return '$_temp0';
  }

  @override
  String get profileNoTextPosts => 'Aún no hay publicaciones de texto';

  @override
  String get profilePostsLoadError => 'Error al cargar publicaciones';

  @override
  String get profileNoLives => 'Aún no hay directos';

  @override
  String get profileLivesLoadError => 'Error al cargar directos';

  @override
  String get profileShopEmpty => 'Tienda vacía';

  @override
  String get profileShopFeatured => 'Destacados';

  @override
  String get profileShopAllProducts => 'Todos los productos';

  @override
  String get profileShowcaseEmptyTitleMe => 'Tu vitrina está vacía';

  @override
  String get profileShowcaseEmptyTitleOther => 'Aún no hay productos';

  @override
  String get profileShowcaseEmptySubtitleMe =>
      'Convírtete en socio de marcas y muestra los productos que recomiendas en tu vitrina.';

  @override
  String get profileShowcaseEmptySubtitleOther =>
      'Este creador aún no ha agregado productos a su vitrina.';

  @override
  String get profileShowcaseJoinCreatorNetwork => 'Unirse a la Creator Network';

  @override
  String get profileLiveBadge => 'EN VIVO';

  @override
  String get profileProductSoldOut => 'Agotado';

  @override
  String get profileProductSoldOutUppercase => 'AGOTADO';

  @override
  String get profileProductAbout => 'Sobre el producto';

  @override
  String get profileProductUnavailable => 'No disponible';

  @override
  String get profileProductBuyNow => 'Comprar ahora';

  @override
  String get profileAddedToCart => '🛒 ¡Añadido al carrito!';

  @override
  String get profileGalleryLoadError => 'Error al cargar la galería';

  @override
  String get profileGalleryEmpty => 'Aún no hay nada aquí';

  @override
  String get profileGalleryRemoveTitle => '¿Eliminar contenido?';

  @override
  String get profileGalleryRemoveBody => 'Esta acción no se puede deshacer.';

  @override
  String get profileGalleryRemove => 'Eliminar';

  @override
  String get profileVideoDeleteTitle => '¿Eliminar vídeo?';

  @override
  String get profileVideoDelete => 'Eliminar';

  @override
  String get profileVideoDeleted => 'Vídeo eliminado';

  @override
  String get profileVideoDeleteError => 'No se pudo eliminar el vídeo';

  @override
  String get profileVideoRepostStory => 'Repostear en Stories';

  @override
  String get profileVideoDeleteAction => 'Eliminar vídeo';

  @override
  String get profileVideoLoadError => 'No se pudo cargar el vídeo.';

  @override
  String profileGalleryTabPhotos(int count, int max) {
    return 'Fotos ($count/$max)';
  }

  @override
  String profileGalleryTabVideos(int count, int max) {
    return 'Vídeos ($count/$max)';
  }

  @override
  String get profileGalleryPhotoAdded => 'Foto añadida';

  @override
  String get profileGalleryPhotoError => 'No se pudo subir la foto';

  @override
  String get profileGalleryVideoAdded => 'Vídeo añadido';

  @override
  String get profileGalleryVideoError => 'No se pudo subir el vídeo';

  @override
  String get profileVideoDeleteBody =>
      'Esta acción no se puede deshacer. El vídeo se eliminará de Para Ti y de tu perfil.';

  @override
  String profileProductLastStock(int count) {
    return 'Últimas $count';
  }

  @override
  String profileProductSoldCount(int count) {
    return '$count vendidos';
  }

  @override
  String profileProductLowStock(int count) {
    return 'Solo quedan $count';
  }

  @override
  String profileProductInStock(int count) {
    return '$count en stock';
  }

  @override
  String get profileProductDescription =>
      'Producto exclusivo de la tienda oficial. Envío en hasta 3 días hábiles. Garantía de 30 días y cambio gratis.';

  @override
  String profilePriceBRL(String amount) {
    return 'R\\\$ $amount';
  }

  @override
  String get profileVideosLoadError => 'Error al cargar los vídeos';

  @override
  String get profileVideosEmpty => 'Aún no hay vídeos publicados';

  @override
  String get profileVideoSwipeHint => 'Desliza';

  @override
  String get notificationsMarkAll => 'Marcar todas';

  @override
  String get notificationsEmptyTitle => '¡Todo al día!';

  @override
  String get notificationsEmptySubtitle => 'No tienes notificaciones nuevas.';

  @override
  String get notificationsLoadError => 'No pude cargar tus notificaciones.';

  @override
  String get notificationsTryAgain => 'Intentar de nuevo';

  @override
  String get notificationsTimeNow => 'ahora';

  @override
  String notificationsTimeMinutes(int n) {
    return 'hace ${n}m';
  }

  @override
  String notificationsTimeHours(int n) {
    return 'hace ${n}h';
  }

  @override
  String notificationsTimeDays(int n) {
    return 'hace ${n}d';
  }

  @override
  String get followsTitle => 'Personas';

  @override
  String get followsTabFollowers => 'Seguidores';

  @override
  String get followsTabFollowing => 'Siguiendo';

  @override
  String get followsSearchHint => 'Buscar...';

  @override
  String get followsLoadError => 'Error al cargar';

  @override
  String get followsTryAgain => 'Intentar de nuevo';

  @override
  String followsNoResults(String q) {
    return 'Sin resultados para \"$q\"';
  }

  @override
  String get followsEmptyFollowers => 'Aún sin seguidores';

  @override
  String get followsEmptyFollowing => 'Aún no sigues a nadie';

  @override
  String get followsUserFallback => 'Usuario';

  @override
  String get followsLiveBadge => 'LIVE';

  @override
  String get questsTitle => 'Misiones Diarias';

  @override
  String questsClaimAll(int count) {
    return 'Reclamar todo ($count)';
  }

  @override
  String questsClaimedReward(int n) {
    return '¡$n recompensa(s) recogida(s)!';
  }

  @override
  String get questsNothingToClaim => 'Nada para reclamar ahora.';

  @override
  String questsClaimSuccess(int xp, int coins) {
    return '+$xp XP · +$coins monedas';
  }

  @override
  String get questsClaimError => 'Error al reclamar. Intenta de nuevo.';

  @override
  String get questsEmpty => 'No hay misiones por ahora.\n¡Vuelve más tarde!';

  @override
  String questsLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String questsXpProgress(int current, int total) {
    return '$current / $total XP';
  }

  @override
  String get questsSummaryCompleted => 'Completadas';

  @override
  String get questsSummaryXpToday => 'XP hoy';

  @override
  String get questsSummaryStreak => 'Racha';

  @override
  String questsStreakDays(int days) {
    return '${days}d';
  }

  @override
  String questsProgressCount(int current, int total) {
    return '$current / $total';
  }

  @override
  String questsRewardXp(int xp) {
    return '+$xp XP';
  }

  @override
  String questsRewardCoins(int coins) {
    return '+$coins monedas';
  }

  @override
  String get questsStatusClaimed => 'Reclamado ✓';

  @override
  String get questsStatusInProgress => 'En progreso';

  @override
  String get questsActionClaim => 'Reclamar';

  @override
  String get questsLoadError => 'No pude cargar las misiones.';

  @override
  String get questsTryAgain => 'Intentar de nuevo';

  @override
  String questsSummaryCompletedValue(int done, int total) {
    return '$done/$total';
  }

  @override
  String get walletTitle => 'Monedas Brawe';

  @override
  String get walletAvailableBalance => 'Saldo de monedas';

  @override
  String get walletCoins => 'monedas';

  @override
  String get walletSectionBuyTitle => 'Comprar monedas';

  @override
  String get walletSectionBuySubtitle =>
      'Usa monedas para enviar regalos virtuales a los creadores en directos';

  @override
  String get walletSectionHistoryTitle => 'Historial de regalos';

  @override
  String get walletSectionHistorySubtitle =>
      'Regalos enviados y recibidos en directos';

  @override
  String get giftersTabReceived => 'Recibidos';

  @override
  String get giftersTabSent => 'Enviados';

  @override
  String get giftersEmptyReceivedTitle => 'Aún nadie te ha regalado';

  @override
  String get giftersEmptyReceivedBody =>
      'Cuando alguien te envíe regalos en los directos, aparecerán agrupados por persona aquí.';

  @override
  String get giftersEmptySentTitle => 'Aún no has enviado regalos';

  @override
  String get giftersEmptySentBody =>
      'Los creadores que apoyes en los directos aparecerán agrupados aquí.';

  @override
  String giftersInLives(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n directos',
      one: '1 directo',
    );
    return '$_temp0';
  }

  @override
  String giftersGiftsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n regalos',
      one: '1 regalo',
    );
    return '$_temp0';
  }

  @override
  String get giftersActionThank => 'Agradecer';

  @override
  String get giftersActionMessage => 'Mensaje';

  @override
  String get giftersActionFollow => 'Seguir';

  @override
  String get giftersActionFollowing => 'Siguiendo';

  @override
  String get giftersDetailTotalReceived => 'Total recibido';

  @override
  String get giftersDetailTotalSent => 'Total enviado';

  @override
  String get giftersDetailGiftsTitle => 'Regalos';

  @override
  String get giftersBadgeFollowsYou => 'Te sigue';

  @override
  String get giftersLoadError => 'No se pudo cargar';

  @override
  String get giftersFollowError => 'Error al seguir. Inténtalo de nuevo.';

  @override
  String walletPackageCoins(String n) {
    return '$n monedas';
  }

  @override
  String walletPriceBRL(String value) {
    return 'R\$ $value';
  }

  @override
  String get walletPurchaseInfo =>
      'Pagos en la app próximamente. Por ahora, compra monedas en el navegador en brawe.app/coins.';

  @override
  String get walletPurchaseUnderstood => 'Entendido';

  @override
  String get walletInfoTitle => 'Cómo funcionan las monedas';

  @override
  String get walletInfoQuestsTitle => 'Misiones diarias';

  @override
  String get walletInfoQuestsBody =>
      'Completa misiones y gana monedas + XP cada día.';

  @override
  String get walletInfoGiftsTitle => 'Recibe regalos';

  @override
  String get walletInfoGiftsBody =>
      'Tus seguidores pueden enviar regalos virtuales durante tus directos.';

  @override
  String get walletInfoUseTitle => 'Envía regalos';

  @override
  String get walletInfoUseBody =>
      'Usa monedas para enviar regalos virtuales a tus creadores favoritos.';

  @override
  String get walletLoadError => 'No pude cargar tus monedas.';

  @override
  String get walletTryAgain => 'Intentar de nuevo';

  @override
  String get walletActionAdd => 'Añadir';

  @override
  String get walletActionSend => 'Enviar regalo';

  @override
  String get walletActionStatement => 'Historial';

  @override
  String get walletComingSoon => 'Próximamente.';

  @override
  String get walletTxLoadError => 'No se pudo cargar el historial.';

  @override
  String get walletTxEmpty => 'Aún sin regalos.';

  @override
  String get walletTxTo => 'Para';

  @override
  String get walletTxFrom => 'De';

  @override
  String get walletIapInfo =>
      'Compra procesada por la tienda oficial (Google Play / App Store). Las monedas se acreditan automáticamente tras el pago. Las monedas son artículos virtuales no canjeables usados solo para enviar regalos en directos.';

  @override
  String walletIapBuyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get walletIapProcessing => 'Procesando…';

  @override
  String get walletIapUnavailable => 'No disponible';

  @override
  String get walletIapPackageUnavailable =>
      'Paquete no disponible en la tienda. Inténtalo pronto.';

  @override
  String get walletIapNotSupported =>
      'Esta plataforma no admite compras dentro de la app.';

  @override
  String get walletIapStoreUnavailable =>
      'Compras dentro de la app no disponibles en este dispositivo. Verifica tu cuenta de Google/Apple.';

  @override
  String get walletIapPaymentPending =>
      'Pago en proceso. Recibirás las monedas cuando la tienda lo confirme.';

  @override
  String get walletIapPaymentError =>
      'No se pudo procesar la compra. Inténtalo de nuevo.';

  @override
  String walletIapSuccess(String coins) {
    return '¡Monedas acreditadas con éxito! (+$coins)';
  }

  @override
  String get earningsTitle => 'Recompensas de Creador';

  @override
  String get earningsCurrency => 'Moneda de visualización';

  @override
  String get earningsCoinsBalance => 'Monedas disponibles';

  @override
  String get earningsDiamondsBalance => 'Diamantes del Programa de Creador';

  @override
  String get earningsDiamonds => 'diamantes';

  @override
  String get earningsTotalSpent => 'Monedas gastadas en regalos';

  @override
  String get earningsTotalEarned => 'Diamantes recibidos en regalos';

  @override
  String get earningsAccountNumber => 'Brawe ID';

  @override
  String get earningsPurchaseHistoryTitle => 'Historial de compras';

  @override
  String get earningsPurchaseHistorySubtitle =>
      'Compras de monedas vía App Store / Google Play';

  @override
  String get earningsGiftHistoryTitle => 'Regalos recibidos';

  @override
  String get earningsGiftHistorySubtitle =>
      'Origen de tus diamantes del Programa de Creador';

  @override
  String get earningsNoPurchases => 'Aún no has comprado monedas.';

  @override
  String get earningsNoGifts => 'Aún no has recibido regalos.';

  @override
  String get earningsLoadError => 'No se pudieron cargar tus recompensas.';

  @override
  String get earningsStatusCompleted => 'Completado';

  @override
  String get earningsStatusPending => 'Pendiente';

  @override
  String get earningsStatusFailed => 'Fallido';

  @override
  String get earningsStatusRefunded => 'Reembolsado';

  @override
  String get earningsDisclaimerTitle => 'Sobre Monedas y Diamantes';

  @override
  String get earningsDisclaimerBody =>
      'Las Monedas y Diamantes Brawe son artículos virtuales no canjeables usados exclusivamente para enviar regalos durante transmisiones en vivo. No constituyen inversión, valores ni dinero electrónico. Los valores en USD/BRL/EUR son meramente referenciales y no representan derecho a retiro o conversión en efectivo.';

  @override
  String get earningsReferenceValueOnly => 'Valor de referencia';

  @override
  String get postDetailTitle => 'Publicación';

  @override
  String get postDetailNotFound =>
      'No pudimos cargar esta publicación. Es posible que haya sido eliminada.';

  @override
  String get postDetailGoHome => 'Ir al Inicio';

  @override
  String get postLikersTitle => 'Me gusta';

  @override
  String get postLikersEmpty => 'Aún nadie le ha dado me gusta.';

  @override
  String get postLikersLoadError => 'No se pudieron cargar los me gusta.';

  @override
  String postLikersTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
      zero: 'Sin me gusta',
    );
    return '$_temp0';
  }

  @override
  String get reactionLike => 'Me gusta';

  @override
  String get reactionLove => 'Me encanta';

  @override
  String get reactionFire => 'Fuego';

  @override
  String get reactionLaugh => 'Jaja';

  @override
  String get reactionWow => 'Wow';

  @override
  String get reactionSad => 'Triste';

  @override
  String get exploreSearchHint => 'Buscar streamers, directos, categorías…';

  @override
  String get exploreTabTrending => 'En tendencia';

  @override
  String get exploreTabCategories => 'Categorías';

  @override
  String get exploreTabRecommended => 'Para ti';

  @override
  String get exploreSectionLives => 'En directo ahora';

  @override
  String get exploreSectionTrendingStreamers => 'Streamers en tendencia';

  @override
  String get exploreSectionRecommendedLives => 'Directos recomendados';

  @override
  String get exploreSectionRecommendedStreamers =>
      'Streamers que te pueden gustar';

  @override
  String get exploreEmptyTrending => 'Nada en tendencia ahora';

  @override
  String get exploreEmptyCategories => 'No hay categorías disponibles.';

  @override
  String get exploreEmptyRecommended =>
      '¡Sigue algunos streamers para recibir recomendaciones personalizadas!';

  @override
  String get exploreEmptySearch => 'Sin resultados.';

  @override
  String get exploreCategoryGeneral => 'General';

  @override
  String exploreFollowersCount(int count) {
    return '$count seguidores';
  }

  @override
  String exploreCategoryLiveCount(int count) {
    return '$count en directo';
  }

  @override
  String get exploreLoadError =>
      'Error al cargar. Desliza hacia abajo para reintentar.';

  @override
  String exploreLiveSubtitle(String streamer, String category) {
    return '$streamer • $category';
  }

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get editProfileSave => 'Guardar';

  @override
  String get editProfileLoadError => 'Error al cargar el perfil';

  @override
  String get editProfileSaved => 'Perfil actualizado';

  @override
  String get editProfileSavedUsernameFailed =>
      'Perfil guardado, pero falló al actualizar el username';

  @override
  String get editProfileSectionInfo => 'Información';

  @override
  String get editProfileSectionSocial => 'Enlaces sociales';

  @override
  String get editProfileFieldName => 'Nombre para mostrar';

  @override
  String get editProfileFieldNameRequired => 'Obligatorio';

  @override
  String get editProfileFieldBio => 'Bio';

  @override
  String get editProfileFieldBioHint => 'Cuéntanos un poco sobre ti...';

  @override
  String get editProfileSocialInstagram => 'Instagram';

  @override
  String get editProfileSocialTikTok => 'TikTok';

  @override
  String get editProfileSocialTwitter => 'X / Twitter';

  @override
  String get editProfileSocialYouTube => 'YouTube';

  @override
  String get editProfileSocialWebsite => 'Sitio web';

  @override
  String get editProfileSocialUserHint => '@usuario';

  @override
  String get editProfileSocialChannelHint => 'canal';

  @override
  String get editProfileSocialUrlHint => 'https://...';

  @override
  String get editProfileBannerAdd => 'Agregar banner';

  @override
  String get editProfileBannerPosition => 'Posicionar banner';

  @override
  String get editProfileAvatarPosition => 'Posicionar foto';

  @override
  String get editProfileUsernameLabel => 'Username';

  @override
  String get editProfileUsernameHint => '@tunombre';

  @override
  String get editProfileUsernameAvailable => 'Disponible';

  @override
  String get editProfileUsernameTooShort => 'Mínimo 3 caracteres';

  @override
  String get editProfileUsernameInvalid =>
      'Solo letras, números y _ (debe comenzar con letra)';

  @override
  String get editProfileImageProcessError => 'No se pudo procesar la imagen.';

  @override
  String get editProfileImageDone => 'Listo';

  @override
  String get editProfileImageHint =>
      'Arrastra para reposicionar · Pellizca para hacer zoom';

  @override
  String get editProfileErrorSaveFailed =>
      'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get editProfileErrorUsernameCheck => 'Error al verificar';

  @override
  String get editProfileErrorUsernameInUse => 'Este username ya está en uso';

  @override
  String get editProfileErrorUsernameSaveFailed =>
      'No se pudo guardar el username. Inténtalo de nuevo.';

  @override
  String get editProfileErrorAvatarUpload => 'Error al subir el avatar.';

  @override
  String get editProfileErrorBannerUpload => 'Error al subir el banner.';

  @override
  String get editProfileErrorAvatarRemove => 'Error al eliminar el avatar.';

  @override
  String get editProfileErrorBannerRemove => 'Error al eliminar el banner.';

  @override
  String get startLivePermissionDenied =>
      'Necesitamos acceso a la cámara y al micrófono para empezar.';

  @override
  String get startLiveNoCamera => 'No se encontró cámara en este dispositivo.';

  @override
  String startLiveCameraInitError(String error) {
    return 'Error al inicializar la cámara: $error';
  }

  @override
  String get startLiveCameraInitFailed => 'Error al inicializar la cámara.';

  @override
  String get startLiveThumbCaptured => 'Portada capturada de la cámara ✨';

  @override
  String get startLiveThumbCaptureFailed => 'No se pudo capturar la portada.';

  @override
  String get startLiveThumbUpdated => 'Portada actualizada.';

  @override
  String get startLiveThumbCaptureNow => 'Capturar ahora';

  @override
  String get startLiveThumbCaptureNowSubtitle =>
      'Usa el frame actual de la cámara';

  @override
  String get startLiveThumbPickGallery => 'Elegir de la galería';

  @override
  String get startLiveThumbRemove => 'Quitar portada';

  @override
  String get startLiveRoomDataError =>
      'No se pudieron obtener los datos del live.';

  @override
  String get startLiveRetry => 'Reintentar';

  @override
  String get startLiveTitleHint => 'Cuenta de qué va tu live...';

  @override
  String get startLiveCategoryLabel => 'Categoría';

  @override
  String get startLiveNotifyFollowers => 'Avisar a mis seguidores';

  @override
  String get startLiveGoLive => 'ENTRAR EN VIVO';

  @override
  String get startLiveSuggestions => 'Sugerencias';

  @override
  String get startLiveErrorTitleTooShort =>
      'El título debe tener al menos 3 caracteres.';

  @override
  String get startLiveErrorCategoryRequired =>
      'Selecciona una categoría para tu live.';

  @override
  String get liveCategoryShopping => 'Shopping';

  @override
  String get liveCategoryGaming => 'Gaming';

  @override
  String get liveCategoryTalkShow => 'Talk Show';

  @override
  String get liveCategoryMusic => 'Música';

  @override
  String get liveCategoryEducation => 'Educación';

  @override
  String get liveCategoryFitness => 'Fitness';

  @override
  String get liveCategoryCooking => 'Cocina';

  @override
  String get liveCategoryBeauty => 'Belleza';

  @override
  String get liveCategoryTech => 'Tecnología';

  @override
  String get liveCategorySports => 'Deportes';

  @override
  String get liveCategoryEntertainment => 'Entretenimiento';

  @override
  String get liveCategoryOther => 'Otro';

  @override
  String get liveVisibilityPublic => 'Público';

  @override
  String get liveVisibilityFollowers => 'Seguidores';

  @override
  String get liveVisibilityPrivate => 'Privado';

  @override
  String get liveVisibilityPublicDesc =>
      'Cualquier persona puede entrar y descubrir';

  @override
  String get liveVisibilityFollowersDesc => 'Solo quien te sigue puede entrar';

  @override
  String get liveVisibilityPrivateDesc =>
      'Solo personas con el enlace invitadas';

  @override
  String get warmupHeading => 'Calentando al público';

  @override
  String get warmupSubheading => 'Avisando a tus seguidores...';

  @override
  String warmupOpensInSeconds(int count, String plural) {
    return 'El live abre en $count segundo$plural';
  }

  @override
  String get warmupGoNow => 'Entrar en vivo ahora';

  @override
  String get warmupCancel => 'Cancelar calentamiento';

  @override
  String get vibeNetworkWifi => 'Wi-Fi';

  @override
  String get vibeNetworkMobile => '4G/5G';

  @override
  String get vibeNetworkEthernet => 'Ethernet';

  @override
  String get vibeNetworkNone => 'Sin red';

  @override
  String get vibeStatusGood => 'Todo listo para entrar en vivo';

  @override
  String get vibeStatusWarning => 'Funciona, pero puede oscilar';

  @override
  String get vibeStatusBad => 'Atención antes de empezar';

  @override
  String vibeNetworkLabel(String label) {
    return 'Red: $label';
  }

  @override
  String vibeBatteryLabel(int level) {
    return 'Batería: $level%';
  }

  @override
  String get shareLiveLoginNeeded => 'Inicia sesión para compartir';

  @override
  String get shareLiveLoadFollowersError =>
      'No se pudieron cargar tus seguidores.';

  @override
  String shareLiveSentToCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString personas',
      one: '$countString persona',
    );
    return 'Live enviado a $_temp0 🎉';
  }

  @override
  String get shareLiveSendFailed => 'Error al compartir el live';

  @override
  String get shareLiveTitle => 'Compartir live';

  @override
  String get shareLiveBadge => 'LIVE';

  @override
  String get shareLiveSearchHint => 'Buscar seguidores';

  @override
  String get shareLiveErrorGeneric => 'Error';

  @override
  String get shareLiveRetry => 'Reintentar';

  @override
  String get shareLiveEmptyFollowers => 'No se encontraron seguidores.';

  @override
  String get shareLiveDefaultUser => 'Usuario';

  @override
  String get shareLiveNoteHint => 'Añade un mensaje (opcional)…';

  @override
  String shareLiveSendTo(int count) {
    return 'Enviar a $count';
  }

  @override
  String get shareLiveSelectContacts => 'Selecciona contactos';

  @override
  String get broadcasterPermissionDenied =>
      'Necesitamos acceso a la cámara y al micrófono para que entres en vivo.';

  @override
  String get broadcasterNoCamera =>
      'No se encontró ninguna cámara en este dispositivo.';

  @override
  String get broadcasterInitCameraFailed => 'Error al inicializar la cámara.';

  @override
  String broadcasterInitCameraError(String error) {
    return 'Error al inicializar la cámara: $error';
  }

  @override
  String broadcasterRoomUpdateFailed(String error) {
    return 'No se pudo actualizar el live: $error';
  }

  @override
  String get broadcasterMissingStreamCreds =>
      'No se pudo iniciar: falta URL RTMP o clave de transmisión.';

  @override
  String get broadcasterConnectedLive => '¡Conectado! Estás en vivo. 🔴';

  @override
  String broadcasterStreamStartError(String error) {
    return 'Error al iniciar la transmisión: $error';
  }

  @override
  String get broadcasterLiveResumed =>
      'Live reanudado — estás de vuelta al aire.';

  @override
  String get broadcasterLivePaused => 'Live pausado (BRB).';

  @override
  String broadcasterPauseToggleError(String error) {
    return 'Error al pausar/reanudar: $error';
  }

  @override
  String get broadcasterDiscardTitle => '¿Descartar live?';

  @override
  String get broadcasterDiscardMessage =>
      'Creaste un live pero aún no empezaste a transmitir. ¿Descartarlo?';

  @override
  String get broadcasterCancel => 'Cancelar';

  @override
  String get broadcasterDiscard => 'Descartar';

  @override
  String get broadcasterEndTitle => '¿Finalizar live?';

  @override
  String get broadcasterEndMessage =>
      '¿Seguro que quieres finalizar la transmisión? Tus viewers serán desconectados.';

  @override
  String get broadcasterContinueLive => 'Seguir en vivo';

  @override
  String get broadcasterEnd => 'Finalizar';

  @override
  String get liveSummaryTitle => 'Resumen de la transmisión';

  @override
  String get liveSummaryDuration => 'Duración';

  @override
  String get liveSummaryPeakViewers => 'Pico de audiencia';

  @override
  String get liveSummaryTotalViewers => 'Espectadores únicos';

  @override
  String get liveSummaryGiftsValue => 'Regalos recibidos';

  @override
  String get liveSummaryMysteryGifts => 'Regalos misteriosos revelados';

  @override
  String get liveSummaryDone => 'Listo';

  @override
  String get liveSummaryUnavailable =>
      'Tu transmisión ha finalizado. No se pudo cargar el resumen completo ahora.';

  @override
  String get broadcasterMoreResumeLive => 'Reanudar live';

  @override
  String get broadcasterMorePauseBrb => 'Pausar (BRB)';

  @override
  String get broadcasterMoreResumeSubtitle =>
      'Vuelve al aire y continúa transmitiendo';

  @override
  String get broadcasterMorePauseSubtitle =>
      'Pausa la transmisión sin finalizarla';

  @override
  String get broadcasterMoreSwitchCamera => 'Cambiar cámara';

  @override
  String get broadcasterMoreSwitchCameraSubtitle =>
      'Alterna entre frontal y trasera';

  @override
  String get broadcasterMoreShareLive => 'Compartir live';

  @override
  String get broadcasterMoreShareLiveSubtitle =>
      'Envía preview del live a tus seguidores';

  @override
  String get broadcasterMoreEndLive => 'Finalizar live';

  @override
  String get broadcasterMoreEndLiveSubtitle =>
      'Finaliza la transmisión para todos';

  @override
  String get broadcasterBadgePaused => 'PAUSED';

  @override
  String get broadcasterBadgeLive => 'LIVE';

  @override
  String get broadcasterTooltipResume => 'Reanudar';

  @override
  String get broadcasterTooltipPause => 'Pausar';

  @override
  String get broadcasterTooltipMore => 'Más';

  @override
  String get broadcasterTooltipEnd => 'Finalizar';

  @override
  String broadcasterViewerJoined(String name) {
    return '$name entró';
  }

  @override
  String get suggestTimeDawn => 'Madrugada';

  @override
  String get suggestTimeMorning => 'Buenos días';

  @override
  String get suggestTimeAfternoon => 'Buenas tardes';

  @override
  String get suggestTimeEvening => 'Buenas noches';

  @override
  String suggestModa1(String time) {
    return '$time de moda — ¿qué me pongo?';
  }

  @override
  String get suggestModa2 => 'Look del día en vivo';

  @override
  String get suggestModa3 => 'Probador online — ayúdame a elegir';

  @override
  String suggestBeleza1(String time) {
    return '$time maquillaje en vivo';
  }

  @override
  String get suggestBeleza2 => 'Skincare routine — juntos';

  @override
  String get suggestBeleza3 => 'Reseña de producto nuevo';

  @override
  String get suggestJogos1 => 'A jugar — ¿quién entra?';

  @override
  String suggestJogos2(String time) {
    return 'Rank up live • $time';
  }

  @override
  String get suggestJogos3 => 'Calentamiento antes de ranked';

  @override
  String suggestMusica1(String time) {
    return '$time musical — pedidos abiertos';
  }

  @override
  String get suggestMusica2 => 'Tocando en vivo — vente';

  @override
  String get suggestMusica3 => 'Playlist + charla';

  @override
  String get suggestEsportes1 => 'Comentando el partido en vivo';

  @override
  String suggestEsportes2(String time) {
    return '$time deportiva — comentamos';
  }

  @override
  String get suggestEsportes3 => 'Entreno + charla';

  @override
  String suggestComida1(String time) {
    return '$time en la cocina — cocinemos';
  }

  @override
  String get suggestComida2 => 'Receta en vivo';

  @override
  String get suggestComida3 => 'Probando una receta nueva';

  @override
  String suggestGeneric1(String time) {
    return '$time con la banda';
  }

  @override
  String get suggestGeneric2 => 'Vente, hablamos';

  @override
  String get suggestGeneric3 => 'Live abierto — pasa por aquí';

  @override
  String get liveCommentsHint => 'Di algo...';

  @override
  String get liveCommentsSending => '  Enviando...';

  @override
  String giftsSent(String name) {
    return '¡Enviaste $name!';
  }

  @override
  String get giftsTitle => 'Enviar un regalo';

  @override
  String get giftsEmpty => 'No hay regalos disponibles';

  @override
  String get giftsSendButton => 'ENVIAR';

  @override
  String giftsError(String error) {
    return 'Error al cargar los regalos: $error';
  }

  @override
  String giftsCreditsLabel(int count) {
    return '$count Créditos';
  }

  @override
  String giftsPriceLabel(int price) {
    return '$price pts';
  }

  @override
  String get liveFeedEmptyForYou => 'No hay lives en Para Ti ahora.';

  @override
  String get liveFeedEmptyAll => 'No hay lives activos en este momento.';

  @override
  String get liveFeedEmptyHint => 'Vuelve más tarde o desliza para actualizar.';

  @override
  String get liveFeedRefresh => 'Actualizar';

  @override
  String get liveFeedRetry => 'Reintentar';

  @override
  String liveFeedError(String error) {
    return 'Error: $error';
  }

  @override
  String get liveFeedCategoryForYou => 'Para Ti';

  @override
  String get liveFeedCategoryAll => 'Todos los Lives';

  @override
  String liveFeedShareMessage(String title, String url) {
    return 'Mira este live en Brawe: $title\n$url';
  }

  @override
  String get liveFeedBadgeLive => 'EN VIVO';

  @override
  String liveFeedBadgeLiveWithCount(int count) {
    return 'EN VIVO $count';
  }

  @override
  String get liveFeedGift => 'Regalo';

  @override
  String get liveFeedShare => 'Compartir';

  @override
  String get livePlayerInputHint => 'Di algo genial...';

  @override
  String get livePlayerTooltipRose => 'Enviar rosa';

  @override
  String get livePlayerTooltipGifts => 'Regalos';

  @override
  String get livePlayerTooltipLike => 'Me gusta';

  @override
  String get livePlayerTooltipSend => 'Enviar';

  @override
  String get livePlayerGiftSentVerb => ' envió ';

  @override
  String get livePlayerShareTitle => 'Compartir con seguidores';

  @override
  String get livePlayerShareSubtitle => 'Envía este live en una conversación';

  @override
  String get livePlayerReportTitle => 'Denunciar live';

  @override
  String get livePlayerReportSubtitle =>
      'Avisa a nuestro equipo sobre algo incorrecto';

  @override
  String get livePlayerReportSubmitted => 'Denuncia registrada. Gracias.';

  @override
  String get liveCurrentUser => 'Tú';

  @override
  String get commonFollow => 'SEGUIR';

  @override
  String get liveBadgeLive => 'EN VIVO';

  @override
  String get homeSectionLiveBattles => 'BATALLAS DE LIVE STREAM';

  @override
  String get homeSectionTopStreamers => 'TOP STREAMERS';

  @override
  String get homeSectionCategories => 'CATEGORÍAS';

  @override
  String get homeSectionStreamCard => 'TARJETA DE STREAM';

  @override
  String get homeSectionLiveCommerce => 'LIVE COMMERCE SHOW';

  @override
  String get homeSectionRecentLives => 'Lives recientes';

  @override
  String get homeErrorLoadingStats => 'Error al cargar estadísticas';

  @override
  String get homeErrorLoadingLives => 'Error al cargar lives';

  @override
  String get homeEmptyPastLives => 'No se encontraron lives anteriores';

  @override
  String get homeEmptyStreamers => 'Aún no hay streamers';

  @override
  String get homeBattleWatchBet => 'VER Y APOSTAR';

  @override
  String get homeBattleLabel => 'Batalla PK';

  @override
  String get commonError => 'Error';

  @override
  String get videoTooltipRepostStory => 'Republicar en Stories';

  @override
  String get liveBattleTapToWatch => 'Toca para ver en vivo';

  @override
  String get liveBattleMysteryGift => 'Regalo Misterioso';

  @override
  String get livePeekWatchLive => 'Ver en Vivo';

  @override
  String get productSoldOut => 'Agotado';

  @override
  String get productBuy => 'Comprar';

  @override
  String productLowStock(int count) {
    return 'Solo quedan $count';
  }

  @override
  String productSoldCount(int count) {
    return '$count vendidos';
  }

  @override
  String get emojiCatSmileys => 'Smileys';

  @override
  String get emojiCatGestures => 'Gestos';

  @override
  String get emojiCatHearts => 'Corazón';

  @override
  String get emojiCatAnimals => 'Animales';

  @override
  String get emojiCatFood => 'Comida';

  @override
  String get emojiCatParty => 'Fiesta';

  @override
  String get emojiCatObjects => 'Objetos';

  @override
  String get battleVs => 'VS';

  @override
  String get battleTimer => 'Tiempo restante';

  @override
  String get battleSendGift => 'Enviar regalo';

  @override
  String get battleSupport => 'Apoyar';

  @override
  String get battleWinner => 'Ganador';

  @override
  String get battleDraw => 'Empate';

  @override
  String get battleEnded => 'Batalla terminada';

  @override
  String get battleResultTitle => 'Resultado de la batalla';

  @override
  String get battleResultShare => 'Compartir resultado';

  @override
  String get battleResultWatchAgain => 'Ver otra batalla';

  @override
  String battleScoreLabel(String score) {
    return '$score pts';
  }

  @override
  String get battleTopSupporters => 'Top apoyadores';

  @override
  String battleYouScore(String score) {
    return 'Tú: $score';
  }

  @override
  String battleRivalScore(String score) {
    return 'Rival: $score';
  }

  @override
  String battleCountdownStarting(int count) {
    return 'Comenzando en $count';
  }

  @override
  String battleInviteReceived(String name) {
    return '¡$name te desafió a una batalla!';
  }

  @override
  String get battleAccept => 'Aceptar';

  @override
  String get battleDecline => 'Rechazar';

  @override
  String get battleLoading => 'Cargando batalla...';

  @override
  String get battleError => 'Error al cargar batalla';

  @override
  String battleGiftReceived(String sender, String gift) {
    return '$sender envió $gift';
  }

  @override
  String get battleMomentum => 'EN LLAMAS';

  @override
  String get battleLeadChange => '¡CAMBIO DE LÍDER!';

  @override
  String get battleFinalStretch => 'RECTA FINAL';

  @override
  String get battleSendToWin => '¡Envía regalos para decidir!';

  @override
  String get battleMvp => 'MVP';

  @override
  String get sharedPostReactionApplied => 'Reacción enviada ✨';

  @override
  String sharedPostMinutesAgo(int count) {
    return 'hace $count min';
  }

  @override
  String sharedPostHoursAgo(int count) {
    return 'hace $count h';
  }

  @override
  String sharedPostDaysAgo(int count) {
    return 'hace $count d';
  }

  @override
  String get topUpTitle => 'Recargar coins';

  @override
  String get topUpSubtitle => 'Compra directo por la tienda de tu celular';

  @override
  String get topUpReasonGift => 'Saldo insuficiente para este regalo';

  @override
  String get topUpReasonBattle => '¡Sigue en la batalla! Recarga ahora';

  @override
  String get topUpStoreDisclaimer => 'Pago seguro vía Play Store / App Store';

  @override
  String get earningsNoPurchasesHint =>
      'Cuando compres coins por App Store o Google Play, aparecerán aquí.';

  @override
  String get earningsNoGiftsHint =>
      'Los diamantes del Creator Program vienen de los regalos que recibes en lives.';

  @override
  String get creatorProgramTitle => 'Brawe Creator Network';

  @override
  String get creatorProgramSubtitle =>
      'Crece tu audiencia. Construye tu comunidad. Forma parte de Brawe.';

  @override
  String get creatorProgramDescription =>
      'La Red de Creadores Brawe es el programa oficial para creadores que quieren crecer, ganar visibilidad y construir una comunidad dentro de Brawe.';

  @override
  String get creatorActionApplyNow => 'Quiero inscribirme';

  @override
  String get creatorActionViewLevels => 'Ver niveles de creador';

  @override
  String get creatorActionCheckStatus => 'Ver mi inscripción';

  @override
  String get creatorBenefitsHeader => 'Lo que ganas';

  @override
  String get creatorBenefit1 => 'Sé descubierto por nuevas audiencias';

  @override
  String get creatorBenefit2 => 'Construye tu identidad de creador';

  @override
  String get creatorBenefit3 => 'Desbloquea badges oficiales';

  @override
  String get creatorBenefit4 => 'Crece con lives y contenido';

  @override
  String get creatorBenefit5 => 'Únete a una comunidad premium';

  @override
  String creatorTotalCreators(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n creadores en la red',
      one: '1 creador en la red',
    );
    return '$_temp0';
  }

  @override
  String get creatorLevelsTitle => 'Niveles de Creador';

  @override
  String get creatorLevelsSubtitle =>
      'Cada nivel representa un momento de tu trayectoria.';

  @override
  String get creatorTierRisingTitle => 'Rising Creator';

  @override
  String get creatorTierRisingBody =>
      'Para creadores en crecimiento listos para ser descubiertos.';

  @override
  String get creatorTierFeaturedTitle => 'Featured Creator';

  @override
  String get creatorTierFeaturedBody =>
      'Para creadores activos con contenido sólido y comunidad en potencial.';

  @override
  String get creatorTierLiveTitle => 'Live Creator';

  @override
  String get creatorTierLiveBody =>
      'Para streamers, hosts y creadores enfocados en lives.';

  @override
  String get creatorTierAmbassadorTitle => 'Ambassador';

  @override
  String get creatorTierAmbassadorBody =>
      'Para creadores reconocidos que representan la visión de Brawe.';

  @override
  String get creatorTierFoundingTitle => 'Founding Creator';

  @override
  String get creatorTierFoundingBody =>
      'Para creadores seleccionados que ayudan a moldear el futuro de Brawe.';

  @override
  String get creatorTierApplyCta => 'Inscribirme como creador';

  @override
  String get creatorFormTitle => 'Inscríbete en la Red';

  @override
  String get creatorFormSubtitle => 'Cuéntanos más sobre tu trayectoria.';

  @override
  String get creatorFormDescription =>
      'Revisamos cada inscripción con cuidado para entender tu contenido, objetivos y potencial dentro de Brawe.';

  @override
  String get creatorFormSectionIdentity => 'Identidad';

  @override
  String get creatorFormSectionContent => 'Contenido';

  @override
  String get creatorFormSectionSocial => 'Redes sociales';

  @override
  String get creatorFormSectionAbout => 'Sobre ti';

  @override
  String get creatorFormFullName => 'Nombre completo';

  @override
  String get creatorFormUsername => 'Username';

  @override
  String get creatorFormEmail => 'Correo electrónico';

  @override
  String get creatorFormPhone => 'Teléfono';

  @override
  String get creatorFormCountry => 'País';

  @override
  String get creatorFormCity => 'Ciudad';

  @override
  String get creatorFormLanguage => 'Idioma principal';

  @override
  String get creatorFormNiche => 'Nicho de contenido';

  @override
  String get creatorFormNichePlaceholder =>
      'Ejemplo: lifestyle, música, games, educación...';

  @override
  String get creatorFormCategory => 'Categoría de creador';

  @override
  String get creatorFormSocialLinks => 'Enlaces de redes';

  @override
  String get creatorFormSocialPlaceholder =>
      'Pega tu Instagram, TikTok, YouTube...';

  @override
  String get creatorFormFollowers => 'Seguidores aproximados';

  @override
  String get creatorFormDoesLive => '¿Haces lives actualmente?';

  @override
  String get creatorFormBio => 'Cuéntanos sobre ti';

  @override
  String get creatorFormBioPlaceholder => '¿Quién eres como creador?';

  @override
  String get creatorFormMotivation => 'Tu motivación';

  @override
  String get creatorFormMotivationPlaceholder =>
      '¿Por qué quieres crecer con Brawe?';

  @override
  String get creatorFormGoals => 'Tus objetivos';

  @override
  String get creatorFormGoalsPlaceholder => '¿Qué quieres lograr como creador?';

  @override
  String get creatorFormPortfolio => 'Portfolio (opcional)';

  @override
  String get creatorFormSubmit => 'Enviar inscripción';

  @override
  String get creatorFormSaveDraft => 'Guardar borrador';

  @override
  String get creatorFormCancel => 'Cancelar';

  @override
  String get creatorFormTermsPrefix => 'He leído y acepto los ';

  @override
  String get creatorFormTermsLink => 'Términos de Brawe Creator Network';

  @override
  String get creatorFormTermsSuffix => '.';

  @override
  String get creatorFormTermsMustAccept =>
      'Debes aceptar los Términos para inscribirte.';

  @override
  String get creatorFormTermsOpen => 'Abrir Términos';

  @override
  String get creatorFormTermsClose => 'Cerrar';

  @override
  String creatorFormTermsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get creatorFormValidationRequired => 'Campo obligatorio';

  @override
  String get creatorFormValidationEmail => 'Correo inválido';

  @override
  String get creatorFormValidationSocial => 'Añade al menos una red social';

  @override
  String get creatorFormSubmitting => 'Enviando tu inscripción...';

  @override
  String get creatorFormSuccess => 'Inscripción enviada con éxito.';

  @override
  String get creatorFormError =>
      'No pudimos enviar tu inscripción. Inténtalo de nuevo.';

  @override
  String get creatorFormAlreadyExists => 'Ya tienes una inscripción activa.';

  @override
  String get creatorSubmittedTitle => 'Inscripción enviada';

  @override
  String get creatorSubmittedBody =>
      'Gracias por inscribirte en Brawe Creator Network. Nuestro equipo revisará tu perfil y te avisaremos cuando haya novedades.';

  @override
  String get creatorSubmittedStep1 =>
      'Tu inscripción está pendiente de revisión.';

  @override
  String get creatorSubmittedStep2 =>
      'Podemos pedirte más información si es necesario.';

  @override
  String get creatorSubmittedStep3 =>
      'Puedes consultar el estado cuando quieras.';

  @override
  String get creatorSubmittedTrack => 'Ver estado';

  @override
  String get creatorSubmittedHome => 'Volver al Inicio';

  @override
  String get creatorStatusPendingTitle => 'Inscripción recibida';

  @override
  String get creatorStatusPendingBody =>
      'Tu inscripción ha sido recibida y está esperando revisión.';

  @override
  String get creatorStatusAnalysisTitle => 'En análisis';

  @override
  String get creatorStatusAnalysisBody =>
      'Nuestro equipo está revisando tu perfil de creador.';

  @override
  String get creatorStatusApprovedTitle => '¡Aprobado!';

  @override
  String get creatorStatusApprovedBody =>
      '¡Felicidades! Ya formas parte de Brawe Creator Network.';

  @override
  String get creatorStatusRejectedTitle => 'Inscripción no aprobada';

  @override
  String get creatorStatusRejectedBody =>
      'Tu inscripción no fue aprobada en este momento. Puedes mejorar tu perfil e intentarlo más tarde.';

  @override
  String get creatorStatusWaitlistTitle => 'Estás en la waitlist';

  @override
  String get creatorStatusWaitlistBody =>
      'Tu perfil tiene potencial y podemos invitarte pronto.';

  @override
  String get creatorStatusNeedsInfoTitle => 'Necesitamos más información';

  @override
  String get creatorStatusNeedsInfoBody =>
      'Actualiza tu inscripción con los detalles solicitados.';

  @override
  String get creatorStatusInvitedAmbassadorTitle => 'Invitación Ambassador';

  @override
  String get creatorStatusInvitedAmbassadorBody =>
      'Has sido invitado al programa Brawe Ambassadors.';

  @override
  String get creatorStatusInvitedFoundingTitle => 'Invitación Founding Creator';

  @override
  String get creatorStatusInvitedFoundingBody =>
      'Has sido invitado a ser Brawe Founding Creator.';

  @override
  String get creatorStatusUpdateApplication => 'Actualizar inscripción';

  @override
  String get creatorStatusContinue => 'Continuar';

  @override
  String get creatorStatusStartOnboarding => 'Empezar onboarding';

  @override
  String get creatorOnboardingTitle => 'Bienvenido a Brawe Creator Network';

  @override
  String get creatorOnboardingSubtitle =>
      'Vamos a configurar tu presencia y ayudar a que descubran tu contenido.';

  @override
  String get creatorOnboardingStart => 'Comenzar setup';

  @override
  String get creatorOnboardingSkip => 'Saltar por ahora';

  @override
  String creatorOnboardingProgress(int done, int total) {
    return '$done de $total completados';
  }

  @override
  String get creatorProfileTitle => 'Perfil de Creador';

  @override
  String get creatorProfileSubtitle => 'Personaliza cómo te ven como creador.';

  @override
  String get creatorProfileFieldDisplayName => 'Nombre público';

  @override
  String get creatorProfileFieldBio => 'Bio de creador';

  @override
  String get creatorProfileFieldCategory => 'Categoría de contenido';

  @override
  String get creatorProfileFieldSocial => 'Enlaces públicos';

  @override
  String get creatorProfileFieldBadgeVisibility => 'Mostrar badge en perfil';

  @override
  String get creatorProfileSave => 'Guardar cambios';

  @override
  String get creatorProfilePreview => 'Previsualizar perfil';

  @override
  String get creatorProfileSaved => 'Perfil de creador actualizado.';

  @override
  String get creatorProfileSaveError =>
      'No pudimos actualizar el perfil de creador.';

  @override
  String get creatorBadgeScreenTitle => 'Tu Badge de Creador';

  @override
  String get creatorBadgeScreenSubtitle =>
      'Tu badge ayuda a las personas a reconocer tu rol en Brawe Creator Network.';

  @override
  String get creatorBadgeLocked => 'Bloqueado';

  @override
  String get creatorBadgeUnlocked => 'Desbloqueado';

  @override
  String get creatorBadgeViewBenefits => 'Ver beneficios';

  @override
  String get creatorBadgeBack => 'Volver';

  @override
  String get creatorDashboardTitle => 'Panel del Creador';

  @override
  String get creatorDashboardSubtitle =>
      'Sigue tu crecimiento y gestiona tu presencia.';

  @override
  String get creatorDashboardCardViews => 'Vistas de perfil';

  @override
  String get creatorDashboardCardFollowers => 'Crecimiento de seguidores';

  @override
  String get creatorDashboardCardReach => 'Alcance del contenido';

  @override
  String get creatorDashboardCardLives => 'Actividad en lives';

  @override
  String get creatorDashboardCardStatus => 'Estado del creador';

  @override
  String get creatorDashboardQuickCreatePost => 'Crear post';

  @override
  String get creatorDashboardQuickGoLive => 'Entrar en vivo';

  @override
  String get creatorDashboardQuickEditProfile => 'Editar perfil';

  @override
  String get creatorDashboardQuickViewBadge => 'Ver badge';

  @override
  String get creatorDashboardQuickInsights => 'Ver insights';

  @override
  String get adminCreatorAppsTitle => 'Inscripciones de Creadores';

  @override
  String get adminCreatorAppsFilterAll => 'Todos';

  @override
  String get adminCreatorAppsFilterPending => 'Pendientes';

  @override
  String get adminCreatorAppsFilterAnalysis => 'En análisis';

  @override
  String get adminCreatorAppsFilterApproved => 'Aprobados';

  @override
  String get adminCreatorAppsFilterRejected => 'Rechazados';

  @override
  String get adminCreatorAppsFilterWaitlist => 'Waitlist';

  @override
  String get adminCreatorAppsFilterNeedsInfo => 'Necesita info';

  @override
  String get adminCreatorAppsReview => 'Revisar';

  @override
  String get adminCreatorAppsFilter => 'Filtros';

  @override
  String get adminCreatorAppsExport => 'Exportar';

  @override
  String get adminCreatorAppsSearchHint => 'Buscar nombre, username o correo';

  @override
  String get adminCreatorAppsEmpty => 'No se encontraron inscripciones.';

  @override
  String get adminCreatorAppsLoadError => 'Error al cargar inscripciones.';

  @override
  String get adminCreatorAppDetailTitle => 'Análisis de Inscripción';

  @override
  String get adminCreatorSectionInfo => 'Información del creador';

  @override
  String get adminCreatorSectionSocial => 'Redes sociales';

  @override
  String get adminCreatorSectionNiche => 'Nicho de contenido';

  @override
  String get adminCreatorSectionMotivation => 'Motivación';

  @override
  String get adminCreatorSectionGoals => 'Objetivos';

  @override
  String get adminCreatorSectionNotes => 'Notas internas';

  @override
  String get adminCreatorSectionSuggestedTier => 'Tier sugerido';

  @override
  String get adminCreatorActionApprove => 'Aprobar';

  @override
  String get adminCreatorActionReject => 'Rechazar';

  @override
  String get adminCreatorActionWaitlist => 'Mover a waitlist';

  @override
  String get adminCreatorActionRequestInfo => 'Pedir más información';

  @override
  String get adminCreatorActionInviteAmbassador => 'Invitar como Ambassador';

  @override
  String get adminCreatorActionInviteFounding =>
      'Invitar como Founding Creator';

  @override
  String get adminCreatorActionSaveNotes => 'Guardar notas';

  @override
  String get adminCreatorConfirmApprove =>
      '¿Seguro que quieres aprobar a este creador?';

  @override
  String get adminCreatorConfirmReject =>
      '¿Seguro que quieres rechazar esta inscripción?';

  @override
  String get adminCreatorConfirmRequestInfo =>
      'Dile al creador qué información falta.';

  @override
  String get adminCreatorReviewSuccess => 'Decisión registrada.';

  @override
  String get adminCreatorReviewError => 'No se pudo registrar la decisión.';

  @override
  String get adminCreatorsTitle => 'Gestión de Creadores';

  @override
  String get adminCreatorsFilterAll => 'Todos los creadores';

  @override
  String get adminCreatorsFilterRising => 'Rising';

  @override
  String get adminCreatorsFilterFeatured => 'Featured';

  @override
  String get adminCreatorsFilterLive => 'Live';

  @override
  String get adminCreatorsFilterAmbassadors => 'Ambassadors';

  @override
  String get adminCreatorsFilterFounding => 'Founding';

  @override
  String get adminCreatorsActionEdit => 'Editar creador';

  @override
  String get adminCreatorsActionChangeBadge => 'Cambiar badge';

  @override
  String get adminCreatorsActionFeature => 'Destacar';

  @override
  String get adminCreatorsActionDisable => 'Desactivar';

  @override
  String get creatorTimelineTitle => 'Cronología';

  @override
  String get creatorTimelineSubmitted => 'Solicitud enviada';

  @override
  String get creatorTimelineUnderReview => 'En análisis';

  @override
  String get creatorTimelineFinalDecision => 'Decisión final';

  @override
  String get creatorTimelineResult => 'Resultado';

  @override
  String get creatorYourApplication => 'Tu solicitud';

  @override
  String get creatorInfoName => 'Nombre';

  @override
  String get creatorInfoUsername => 'Usuario';

  @override
  String get creatorInfoCountry => 'País';

  @override
  String get creatorInfoNiche => 'Nicho';

  @override
  String get creatorInfoRequestedTier => 'Tier solicitado';

  @override
  String get creatorInfoFollowers => 'Seguidores';

  @override
  String get creatorInfoDoesLive => 'Hace lives';

  @override
  String get creatorQuickShortcuts => 'Accesos rápidos';

  @override
  String get creatorBadgeActive => 'ACTIVO';

  @override
  String get commonYes => 'Sí';

  @override
  String get commonNo => 'No';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get editProfileAccountTypeSection => 'TIPO DE CUENTA';

  @override
  String get editProfileAccountTypeCreator => 'Creador';

  @override
  String get editProfileAccountTypeMusician => 'Músico';

  @override
  String get editProfileAccountTypeBusiness => 'Empresa';

  @override
  String get editProfileMusicianBannerHint =>
      'Crea tu perfil de artista en Brawe Sounds y aparece en el catálogo.';

  @override
  String get editProfileMusicianArtistName => 'Nombre artístico';

  @override
  String get editProfileMusicianArtistNameHint =>
      'Cómo apareces en Brawe Sounds';

  @override
  String get editProfileMusicianCity => 'Ciudad';

  @override
  String get editProfileMusicianCityHint => 'Ej: Buenos Aires';

  @override
  String get editProfileMusicianSpotify => 'Spotify';

  @override
  String get editProfileMusicianAppleMusic => 'Apple Music';

  @override
  String get editProfileMusicianGenres => 'GÉNEROS';

  @override
  String get soundsGenreFunk => 'Funk';

  @override
  String get soundsGenreSertanejo => 'Sertanejo';

  @override
  String get soundsGenrePagode => 'Pagode';

  @override
  String get soundsGenreForro => 'Forró';

  @override
  String get soundsGenrePop => 'Pop';

  @override
  String get soundsGenreRap => 'Rap';

  @override
  String get soundsGenreElectro => 'Electrónico';

  @override
  String get soundsGenreGospel => 'Gospel';

  @override
  String get soundsGenreRock => 'Rock';

  @override
  String get soundsGenreMpb => 'MPB';

  @override
  String soundsArtistTracks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
    );
    return '$_temp0';
  }

  @override
  String soundsArtistPlays(Object count) {
    return '$count reproducciones';
  }

  @override
  String get soundsTitle => 'Brawe Sounds';

  @override
  String get soundsSubtitle => 'Descubre pistas increíbles';

  @override
  String get soundsTabTrending => 'Tendencias';

  @override
  String get soundsTabCatalog => 'Catálogo';

  @override
  String get soundsSearch => 'Buscar canciones o artistas...';

  @override
  String get soundsGenreAll => 'Todos';

  @override
  String get soundsEmptyTrending => 'Aún no hay canciones en tendencia';

  @override
  String get soundsEmptyCatalog => 'No se encontraron canciones';

  @override
  String soundsEmptySearch(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get soundsLoadMore => 'Cargar más';

  @override
  String soundsUsedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'usado $count veces',
      one: 'usado 1 vez',
    );
    return '$_temp0';
  }

  @override
  String get soundsSaved => 'Guardado';

  @override
  String get soundsSave => 'Guardar';

  @override
  String get soundsUse => 'Usar';

  @override
  String get soundsPlayerLoading => 'Cargando...';

  @override
  String get soundsPlayerError => 'Error al cargar audio';

  @override
  String get navSounds => 'Sounds';

  @override
  String get createSoundsTitle => 'Sounds';

  @override
  String get createSoundsSubtitle =>
      'Agrega una canción original a tu publicación';

  @override
  String postSoundLabel(String title) {
    return 'Sonido: $title';
  }

  @override
  String get postSoundRemove => 'Quitar sonido';

  @override
  String get contentSoundOriginalAudio => 'Audio original';

  @override
  String get contentSoundUseThis => 'Usar este sonido';

  @override
  String get contentSoundUnavailable => 'Sonido no disponible';

  @override
  String get contentSoundView => 'Ver sonido';

  @override
  String get contentSoundNowPlaying => 'Reproduciendo ahora';

  @override
  String contentSoundByArtist(String title, String artist) {
    return '$title · $artist';
  }

  @override
  String get soundTrimTitle => 'Cortar música';

  @override
  String get soundTrimSave => 'Listo';

  @override
  String get soundTrimCancel => 'Cancelar';

  @override
  String get soundTrimHint =>
      'Arrastra las asas para elegir el fragmento de la música';

  @override
  String soundTrimMaxDuration(int seconds) {
    return 'Máximo ${seconds}s para este contenido';
  }

  @override
  String soundTrimSelectedDuration(int seconds) {
    return '${seconds}s seleccionados';
  }

  @override
  String get soundTrimError => 'No se pudo procesar el fragmento seleccionado.';

  @override
  String get soundVolumeLabel => 'Volumen de la música';

  @override
  String get originalAudioVolumeLabel => 'Volumen del audio original';

  @override
  String get analyticsViewersTitle => 'Audiencia';

  @override
  String get analyticsViewersTotalViewers => 'Total de viewers';

  @override
  String get analyticsViewersAvgPerLive => 'Promedio/live';

  @override
  String get analyticsViewersChartTitle => 'Vistas por día';

  @override
  String get analyticsViewersLegendViewers => 'Viewers';

  @override
  String get analyticsViewersLegendPeak => 'Pico';

  @override
  String get analyticsViewersBestDays => 'Mejores días';

  @override
  String get analyticsViewersNoData => 'Sin datos';

  @override
  String get analyticsViewersUnit => ' viewers';

  @override
  String get analyticsFollowersTitle => 'Seguidores';

  @override
  String get analyticsFollowersCount => 'Seguidores';

  @override
  String get analyticsFollowersFollowing => 'Siguiendo';

  @override
  String get analyticsFollowersTrendTitle => 'Tendencia de participación';

  @override
  String get analyticsFollowersTrendSubtitle =>
      'Audiencia de lives — correlación directa con crecimiento';

  @override
  String get analyticsFollowersLegendEngagement => 'Participación';

  @override
  String get analyticsFollowersSummaryTitle => 'Resumen de cuenta';

  @override
  String get analyticsFollowersSummaryFollowers => 'Seguidores';

  @override
  String get analyticsFollowersSummaryFollowing => 'Siguiendo';

  @override
  String get analyticsFollowersSummaryLives => 'Lives realizados';

  @override
  String get analyticsFollowersSummaryRatio => 'Ratio seguidor/live';

  @override
  String get analyticsFollowersTipsTitle => 'Consejos para crecer';

  @override
  String get analyticsFollowersTip1Title => 'Haz lives regularmente';

  @override
  String get analyticsFollowersTip1Subtitle =>
      'La consistencia aumenta seguidores en +40%';

  @override
  String get analyticsFollowersTip2Title => 'Interactúa con tu audiencia';

  @override
  String get analyticsFollowersTip2Subtitle =>
      'Responder comentarios aumenta la retención';

  @override
  String get analyticsFollowersTip3Title => 'Comparte tu contenido';

  @override
  String get analyticsFollowersTip3Subtitle =>
      'Stories y posts aumentan el alcance';

  @override
  String get analyticsLivesTitle => 'Historial de Lives';

  @override
  String get analyticsLivesErrorLoad => 'Error al cargar lives';

  @override
  String get analyticsLivesRetry => 'Intentar de nuevo';

  @override
  String get analyticsLivesKpiTotal => 'Lives';

  @override
  String get analyticsLivesKpiAvgViewers => 'Viewers prom.';

  @override
  String get analyticsLivesKpiGifts => 'Gifts (USDT)';

  @override
  String analyticsLivesDuration(String min) {
    return '$min min';
  }

  @override
  String get analyticsLivesNoTitle => 'Live sin título';

  @override
  String get analyticsLivesMetricViewers => 'viewers';

  @override
  String get analyticsLivesMetricPeak => 'pico';

  @override
  String get analyticsLivesMetricUsdt => 'USDT';

  @override
  String get analyticsLivesReplayLabel => 'Replay';

  @override
  String get analyticsLivesReplayExpired => 'Replay no disponible';

  @override
  String get analyticsLivesReplayExpiredSub =>
      'El video puede haber expirado (>30 días)';

  @override
  String get analyticsLivesEmptyTitle => 'Aún no hay lives';

  @override
  String get analyticsLivesEmptySubtitle =>
      'Haz tu primer live y ve tus métricas aquí';

  @override
  String get analyticsLivesMonthsShort =>
      'Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic';

  @override
  String get analyticsReachTitle => 'Alcance y Monetización';

  @override
  String get analyticsReachKpiGifts => 'Gifts recibidos';

  @override
  String get analyticsReachKpiEarnings => 'Ganancias (USDT)';

  @override
  String get analyticsReachEarningsChartTitle => 'Ganancias por día';

  @override
  String get analyticsReachLegendEarnings => 'Ganancias USDT';

  @override
  String get analyticsReachLegendFee => 'Comisión plataforma';

  @override
  String get analyticsReachTopGiftsTitle => 'Top Gifts recibidos';

  @override
  String get analyticsReachNoGifts => 'Aún no has recibido gifts';

  @override
  String get analyticsReachMonetizationTitle => 'Monetización total';

  @override
  String get analyticsReachTotalEarned => 'Total ganado';

  @override
  String get analyticsReachTotalGifts => 'Gifts totales';

  @override
  String get analyticsReachEarningsPerLive => 'Ganancia/live';

  @override
  String get analyticsDashboardAvgViewers => 'prom./live';

  @override
  String get analyticsDashboardSeeGrowth => 'Ver crecimiento';

  @override
  String get analyticsDashboardGifts => 'gifts';

  @override
  String analyticsDashboardMinAvg(String min) {
    return '$min min prom.';
  }

  @override
  String shopVitrineTitle(String name) {
    return 'Vitrina de $name';
  }

  @override
  String get shopVitrineSearchTooltip => 'Buscar en la vitrina';

  @override
  String get shopVitrineFilterTooltip => 'Ordenar productos';

  @override
  String get shopVitrineViewModeTooltip => 'Cambiar vista';

  @override
  String get shopVitrineSortTitle => 'Ordenar por';

  @override
  String get shopVitrineSortCreatorChoice => 'Elección del creador';

  @override
  String get shopVitrineSortBestSelling => 'Más vendidos';

  @override
  String get shopVitrineSortNewest => 'Novedades';

  @override
  String get shopVitrineSortPriceAsc => 'Precio: menor a mayor';

  @override
  String get shopVitrineSortPriceDesc => 'Precio: mayor a menor';

  @override
  String shopVitrineSoldOnline(String count) {
    return '$count vendidos en línea';
  }

  @override
  String get shopVitrineFreeShipping => 'Envío gratis';

  @override
  String get shopProductPageTitle => 'Producto';

  @override
  String get shopProductPrice => 'Precio';

  @override
  String get shopProductOriginalPrice => 'Precio original';

  @override
  String get shopProductDiscount => 'Descuento';

  @override
  String get shopProductAddToCart => 'Agregar al carrito';

  @override
  String get shopProductBuyNow => 'Comprar ahora';

  @override
  String get shopProductDescription => 'Descripción';

  @override
  String get shopProductStore => 'Tienda';

  @override
  String get shopProductViewStore => 'Ver tienda';

  @override
  String get shopProductQuantity => 'Cantidad';

  @override
  String get shopProductRating => 'Calificación';

  @override
  String get shopProductReviews => 'reseñas';

  @override
  String get shopProductSold => 'vendidos';

  @override
  String get shopProductOutOfStock => 'Sin stock';

  @override
  String get shopProductNotFound => 'Producto no encontrado.';

  @override
  String get shopProductError => 'Error al cargar el producto.';

  @override
  String get shopProductAddedToCart => 'Producto agregado al carrito ✓';

  @override
  String get shopProductAddToCartError => 'No se pudo agregar al carrito.';

  @override
  String get shopProductCartTooltip => 'Carrito';

  @override
  String get shopProductSearchTooltip => 'Buscar productos';

  @override
  String get shopProductShareTooltip => 'Compartir';

  @override
  String get shopProductMoreTooltip => 'Más opciones';

  @override
  String get shopProductShareFail => 'No se pudo compartir el producto.';

  @override
  String get shopProductLinkCopied => '¡Enlace del producto copiado!';

  @override
  String get shopProductOptionShare => 'Compartir producto';

  @override
  String get shopProductOptionCopyLink => 'Copiar enlace';

  @override
  String get shopProductOptionReport => 'Denunciar producto';

  @override
  String get shopProductReportQuestion =>
      '¿Por qué estás denunciando este producto?';

  @override
  String get shopProductReportSent =>
      'Denuncia enviada. Gracias por ayudar a mantener Brawe seguro.';

  @override
  String get shopProductReportError =>
      'No se pudo enviar la denuncia. Inténtalo de nuevo.';

  @override
  String get shopProductFooterStore => 'Tienda';

  @override
  String get shopProductFooterChat => 'Chat';

  @override
  String get shopProductChatComingSoon => 'Chat con la tienda próximamente.';

  @override
  String get shopProductTabOverview => 'Resumen';

  @override
  String get shopProductTabReviews => 'Reseñas';

  @override
  String get shopProductTabDescription => 'Descripción';

  @override
  String get shopProductTabRecommendations => 'Recomendaciones';

  @override
  String get shopProductReviewsComingSoon =>
      'Reseñas de productos próximamente.';

  @override
  String get shopProductRecommendationsComingSoon =>
      'Recomendaciones de productos relacionados próximamente.';

  @override
  String get shopCartTitle => 'Carrito';

  @override
  String get shopCartClear => 'Vaciar carrito';

  @override
  String get shopCartClearConfirmTitle => '¿Vaciar carrito?';

  @override
  String get shopCartClearConfirmBody =>
      'Se eliminarán todos los artículos de tu carrito.';

  @override
  String get shopCartEmptyTitle => 'Tu carrito está vacío';

  @override
  String get shopCartEmptyBody =>
      'Explora la vitrina y encuentra productos increíbles.';

  @override
  String get shopCartViewShowcase => 'Ver vitrina';

  @override
  String get shopCartError => 'No se pudo cargar tu carrito.';

  @override
  String get shopCartRemoveItem => 'Eliminar artículo';

  @override
  String get shopCartSubtotal => 'Subtotal';

  @override
  String get shopCartTax => 'Impuestos';

  @override
  String get shopCartShipping => 'Envío';

  @override
  String get shopCartDiscount => 'Descuento';

  @override
  String get shopCartTotal => 'Total';

  @override
  String get shopCartContinueToCheckout => 'Continuar al pago';

  @override
  String get shopCartUpdateError => 'No se pudo actualizar el artículo.';

  @override
  String get shopCartRemoveError => 'No se pudo eliminar el artículo.';

  @override
  String get shopCartClearError => 'No se pudo vaciar el carrito.';

  @override
  String get shopCheckoutTitle => 'Finalizar compra';

  @override
  String get shopCheckoutAddressSection => 'Dirección de envío';

  @override
  String get shopCheckoutAddressEmpty => 'Aún no tienes direcciones guardadas.';

  @override
  String get shopCheckoutAddNewAddress => 'Usar otra dirección';

  @override
  String get shopCheckoutAddressLabel =>
      'Nombre de la dirección (ej.: Casa, Trabajo)';

  @override
  String get shopCheckoutAddressStreet => 'Calle';

  @override
  String get shopCheckoutAddressNumber => 'Número';

  @override
  String get shopCheckoutAddressComplement => 'Complemento (opcional)';

  @override
  String get shopCheckoutAddressNeighborhood => 'Barrio';

  @override
  String get shopCheckoutAddressCity => 'Ciudad';

  @override
  String get shopCheckoutAddressState => 'Estado';

  @override
  String get shopCheckoutAddressPostalCode => 'Código postal';

  @override
  String get shopCheckoutAddressSave => 'Guardar dirección';

  @override
  String get shopCheckoutAddressSaved => 'Dirección guardada ✓';

  @override
  String get shopCheckoutAddressSaveError => 'No se pudo guardar la dirección.';

  @override
  String get shopCheckoutAddressRequired =>
      'Selecciona o agrega una dirección de envío.';

  @override
  String get shopCheckoutCustomerSection => 'Datos del cliente';

  @override
  String get shopCheckoutCustomerName => 'Nombre completo';

  @override
  String get shopCheckoutCustomerEmail => 'Correo electrónico';

  @override
  String get shopCheckoutCustomerPhone => 'Teléfono (opcional)';

  @override
  String get shopCheckoutRecipientSection => 'Destinatario (para factura)';

  @override
  String get shopCheckoutRecipientHint =>
      'La tienda necesita estos datos para emitir la factura de tu pedido.';

  @override
  String get shopCheckoutRecipientName => 'Nombre completo del destinatario';

  @override
  String get shopCheckoutDocumentType => 'Tipo';

  @override
  String get shopCheckoutDocumentRequired =>
      'El CPF/CNPJ es obligatorio para emitir la factura.';

  @override
  String get shopCheckoutCpfInvalid => 'El CPF debe tener 11 dígitos.';

  @override
  String get shopCheckoutCnpjInvalid => 'El CNPJ debe tener 14 dígitos.';

  @override
  String get shopCheckoutNameRequired => 'Ingresa tu nombre completo.';

  @override
  String get shopCheckoutEmailRequired => 'Ingresa tu correo electrónico.';

  @override
  String get shopCheckoutEmailInvalid =>
      'Ingresa un correo electrónico válido.';

  @override
  String get shopCheckoutShippingSection => 'Método de envío';

  @override
  String get shopCheckoutShippingStandard => 'Estándar';

  @override
  String get shopCheckoutShippingExpress => 'Exprés';

  @override
  String get shopCheckoutPaymentSection => 'Método de pago';

  @override
  String get shopCheckoutPaymentPix => 'PIX';

  @override
  String get shopCheckoutPaymentCard => 'Tarjeta';

  @override
  String get shopCheckoutPaymentCrypto => 'Cripto';

  @override
  String get shopCheckoutSummarySection => 'Resumen del pedido';

  @override
  String get shopCheckoutSubtotal => 'Subtotal';

  @override
  String get shopCheckoutTotal => 'Total';

  @override
  String get shopCheckoutConfirmOrder => 'Confirmar pedido';

  @override
  String get shopCheckoutError =>
      'No se pudo completar el pedido. Inténtalo de nuevo.';

  @override
  String get shopCheckoutDiscount => 'Descuento';

  @override
  String get shopCheckoutFreeShipping => 'Gratis';

  @override
  String get shopCheckoutAddNote => 'Agregar nota';

  @override
  String shopCheckoutTotalItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'artículos',
      one: 'artículo',
    );
    return 'Total ($count $_temp0)';
  }

  @override
  String get shopCheckoutTermsPrefix => 'Al realizar el pedido, aceptas los ';

  @override
  String get shopCheckoutTermsLink => 'Términos de Uso';

  @override
  String get shopCheckoutTermsAnd => ' y la ';

  @override
  String get shopCheckoutPrivacyLink => 'Política de Privacidad';

  @override
  String get shopCheckoutTermsSuffix => ' de Brawe.';

  @override
  String get shopPaymentTitle => 'Pago';

  @override
  String shopPaymentOrderNumber(String number) {
    return 'Pedido #$number';
  }

  @override
  String get shopPaymentTotal => 'Total';

  @override
  String get shopPaymentPixTitle => 'Pagar con PIX';

  @override
  String get shopPaymentPixInstructions =>
      'Escanea el código QR en la app de tu banco para completar el pago.';

  @override
  String get shopPaymentAlreadyPaid => 'Ya pagué';

  @override
  String get shopPaymentCardTitle => 'Pago con tarjeta';

  @override
  String get shopPaymentCardComingSoon =>
      'Integración de tarjeta próximamente.';

  @override
  String get shopPaymentCryptoTitle => 'Pagar con criptomoneda';

  @override
  String get shopPaymentCryptoComingSoon =>
      'Dirección de billetera próximamente.';

  @override
  String get shopPaymentViewOrders => 'Ver mis pedidos';

  @override
  String get shopPaymentStatusPending => 'Esperando pago';

  @override
  String get shopPaymentStatusPaid => 'Pago confirmado ✓';

  @override
  String get shopPaymentStatusFailed => 'El pago falló';

  @override
  String get shopPaymentError => 'No se pudo verificar el estado del pago.';

  @override
  String get shopStoreProductsSection => 'Productos';

  @override
  String get shopStoreEmptyProducts =>
      'Esta tienda todavía no tiene productos.';

  @override
  String get shopStoreProductsError => 'No se pudieron cargar los productos.';

  @override
  String get shopStoreError => 'No se pudo cargar la tienda.';

  @override
  String get shopStoreNotFound => 'Tienda no encontrada.';

  @override
  String get shopStorePremiumBadge => 'Premium';

  @override
  String get shopStoreBravePassBadge => 'Brawe Pass';

  @override
  String shopStoreRatingCount(String count) {
    return '$count reseñas';
  }

  @override
  String get shopStoreReadMore => 'Ver más';

  @override
  String get shopStoreReadLess => 'Ver menos';

  @override
  String get shopStoreChatCta => 'Hablar con la tienda';

  @override
  String get shopStoreChatUnavailable =>
      'Esta tienda todavía no puede recibir mensajes.';

  @override
  String shopStoreChatError(String error) {
    return 'No se pudo abrir el chat: $error';
  }

  @override
  String get profileTooltipFindFriends => 'Encontrar amigos';

  @override
  String get findFriendsTitle => 'Encontrar amigos';

  @override
  String get findFriendsMyQrCode => 'Mi código QR';

  @override
  String get findFriendsQrHint =>
      'Otras personas pueden escanear este código para ver tu perfil o iniciar sesión al instante';

  @override
  String get findFriendsScanButton => 'Escanear código';

  @override
  String get findFriendsSuggestionsTitle => 'Sugerencias para ti';

  @override
  String get findFriendsSuggestionsEmpty => 'No hay sugerencias por ahora';

  @override
  String get findFriendsFollowButton => 'Seguir';

  @override
  String get findFriendsFollowingButton => 'Siguiendo';

  @override
  String get qrScannerTitle => 'Escanear código QR';

  @override
  String get qrScannerHint => 'Apunta la cámara a un código QR de Brawe';

  @override
  String get qrScannerCameraPermissionDenied =>
      'Permite el acceso a la cámara para escanear códigos QR.';

  @override
  String get qrScannerInvalidCode => 'Este código QR no es válido.';

  @override
  String get qrScannerLoginApproved => '¡Inicio de sesión aprobado!';

  @override
  String get qrScannerLoginConfirmTitle => 'Confirmar inicio de sesión';

  @override
  String get qrScannerLoginConfirmBody =>
      '¿Aprobar inicio de sesión en otro dispositivo con esta cuenta?';

  @override
  String qrScannerLoginError(String error) {
    return 'No se pudo aprobar el inicio de sesión: $error';
  }

  @override
  String get actionApprove => 'Aprobar';

  @override
  String get questsRewardCollected => '¡Recompensa recolectada!';

  @override
  String questsXpReceived(int xp) {
    return '$xp XP recibidos';
  }

  @override
  String questsCoinsReceived(int coins) {
    return '$coins monedas recibidas';
  }

  @override
  String get questsLevelUp => '¡Subida de nivel!';

  @override
  String get questsFailedToClaim => 'No se pudo recolectar la recompensa';

  @override
  String get questsAlreadyClaimed => 'Recompensa ya recolectada';
}
