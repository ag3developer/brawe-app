// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Brawe';

  @override
  String get navHome => 'Início';

  @override
  String get navFeed => 'Feed';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get tabFollowing => 'Seguindo';

  @override
  String get tabForYou => 'Para Você';

  @override
  String get actionFollow => 'Seguir';

  @override
  String get actionUnfollow => 'Seguindo';

  @override
  String get actionLike => 'Curtir';

  @override
  String get actionComment => 'Comentar';

  @override
  String get actionShare => 'Compartilhar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionRepost => 'Repostar';

  @override
  String get actionSend => 'Enviar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionRefresh => 'Atualizar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionBlock => 'Bloquear';

  @override
  String get actionUnblock => 'Desbloquear';

  @override
  String get actionReport => 'Denunciar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get feedEmptyTitle => 'Nenhum vídeo por aqui ainda.';

  @override
  String get feedEmptySubtitle => 'Siga creators ou volte mais tarde.';

  @override
  String get feedFollowingEmptyTitle =>
      'Siga pessoas para ver os posts delas aqui.';

  @override
  String get feedLoadError => 'Não foi possível carregar o feed.';

  @override
  String get feedNoMore => 'Você está em dia! 🎉';

  @override
  String get profileEditButton => 'Editar perfil';

  @override
  String get profileFollowers => 'seguidores';

  @override
  String get profileFollowing => 'seguindo';

  @override
  String get profileLives => 'lives';

  @override
  String get profileViews => 'views';

  @override
  String profileJoinedAt(String date) {
    return 'entrou em $date';
  }

  @override
  String get profileTabPosts => 'Posts';

  @override
  String get profileTabVideos => 'Vídeos';

  @override
  String get profileTabSaved => 'Salvos';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authRegister => 'Cadastrar';

  @override
  String get authLogout => 'Sair';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Senha';

  @override
  String get authForgotPassword => 'Esqueceu a senha?';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta!';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get chatNewMessage => 'Nova mensagem';

  @override
  String get chatPlaceholder => 'Mensagem...';

  @override
  String get chatNoConversations => 'Nenhuma conversa ainda.';

  @override
  String chatBlockTitle(String name) {
    return 'Bloquear $name?';
  }

  @override
  String chatBlockedSuccess(String name) {
    return '$name foi bloqueado(a).';
  }

  @override
  String chatBlockError(String error) {
    return 'Erro ao bloquear: $error';
  }

  @override
  String chatImagePickError(String error) {
    return 'Erro ao escolher imagem: $error';
  }

  @override
  String get commentsTitle => 'Comentários';

  @override
  String get commentsPlaceholder => 'Adicione um comentário...';

  @override
  String get commentsEmpty => 'Nenhum comentário ainda.\nSeja o primeiro!';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsEmpty => 'Nenhuma notificação ainda.';

  @override
  String notificationLiked(String user) {
    return '$user curtiu seu post.';
  }

  @override
  String notificationFollowed(String user) {
    return '$user começou a te seguir.';
  }

  @override
  String notificationCommented(String user) {
    return '$user comentou no seu post.';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Português · Español · English';

  @override
  String get settingsAppLanguage => 'Idioma do app';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotifLiveStart => 'Lives começando';

  @override
  String get settingsNotifLiveStartHint =>
      'Receba aviso quando seus creators favoritos forem ao vivo';

  @override
  String get settingsNotifGifts => 'Presentes recebidos';

  @override
  String get settingsNotifGiftsHint => 'Avisar quando alguém te enviar um gift';

  @override
  String get settingsNotifFollowers => 'Novos seguidores';

  @override
  String get settingsNotifMessages => 'Mensagens diretas';

  @override
  String get settingsPrivacy => 'Privacidade';

  @override
  String get settingsPrivacyShowViewers => 'Mostrar nº de espectadores';

  @override
  String get settingsPrivacyShowViewersHint =>
      'Outros podem ver quantas pessoas assistem suas lives';

  @override
  String get settingsPrivacyShowEarnings => 'Mostrar ganhos publicamente';

  @override
  String get settingsPrivacyShowEarningsHint =>
      'Exibir total de coins/ganhos no seu perfil';

  @override
  String get settingsSounds => 'Sons';

  @override
  String get settingsSoundsEnabled => 'Efeitos sonoros';

  @override
  String get settingsSoundsHint => 'Sons ao receber gifts, mensagens etc.';

  @override
  String get settingsAbout => 'Sobre & Legal';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get settingsLogout => 'Sair da conta';

  @override
  String get settingsLoadError =>
      'Não conseguimos carregar suas configurações.';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsTermsOfUse => 'Termos de Uso';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidade';

  @override
  String get settingsSupport => 'Suporte';

  @override
  String get settingsVersion => 'Versão';

  @override
  String get settingsChangePassword => 'Alterar senha';

  @override
  String get settingsDeleteAccount => 'Excluir conta';

  @override
  String get settingsLogoutConfirm =>
      'Tem certeza que deseja sair da sua conta?';

  @override
  String get settingsHelpTitle => 'Como podemos ajudar?';

  @override
  String get settingsSendSupportEmail => 'Enviar e-mail ao suporte';

  @override
  String get settingsNoMailApp => 'Nenhum app de e-mail configurado.';

  @override
  String get settingsHelpCenterFaq => 'Central de ajuda / FAQ';

  @override
  String settingsSupportEmailSubject(String version) {
    return 'Suporte Brawe — App v$version';
  }

  @override
  String settingsCantOpenUrl(String url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String get cpCurrentPassword => 'Senha atual';

  @override
  String get cpNewPassword => 'Nova senha';

  @override
  String get cpConfirmNewPassword => 'Confirmar nova senha';

  @override
  String get cpMin8Chars => 'Mínimo 8 caracteres';

  @override
  String get cpSaveNewPassword => 'Salvar nova senha';

  @override
  String get cpEnterCurrentPassword => 'Informe sua senha atual.';

  @override
  String get cpPasswordTooShort =>
      'A nova senha deve ter pelo menos 8 caracteres.';

  @override
  String get cpPasswordsDontMatch => 'As novas senhas não coincidem.';

  @override
  String get cpChangedSuccess => 'Senha alterada com sucesso.';

  @override
  String get cpChangeError => 'Falha ao alterar senha.';

  @override
  String get delAccTitle => 'Excluir conta';

  @override
  String get delAccEnterPassword => 'Informe sua senha para confirmar.';

  @override
  String get delAccAckRequired => 'Confirme que entende a ação.';

  @override
  String get delAccConfirmBody =>
      'Esta ação é IRREVERSÍVEL. Sua conta será desativada e seus dados pessoais anonimizados (LGPD). Deseja continuar?';

  @override
  String get delAccConfirmButton => 'Excluir conta';

  @override
  String get delAccSuccess => 'Conta excluída. Até logo.';

  @override
  String get delAccError => 'Falha ao excluir conta.';

  @override
  String get delAccWarningBanner =>
      'Ao excluir sua conta, você perderá acesso permanente ao histórico de lives, gifts, saldo, conversas e seguidores. Saldos pendentes podem ser perdidos.';

  @override
  String get delAccWhatHappens => 'O que acontece:';

  @override
  String get delAccBullet1 => 'Sua conta será desativada imediatamente.';

  @override
  String get delAccBullet2 => 'Seu email e dados pessoais serão anonimizados.';

  @override
  String get delAccBullet3 =>
      'Você será desconectado de todos os dispositivos.';

  @override
  String get delAccBullet4 => 'Registros mantidos pelo prazo legal exigido.';

  @override
  String get delAccPasswordHelper => 'Confirme sua identidade';

  @override
  String get delAccAckCheckbox => 'Entendo que esta ação é irreversível.';

  @override
  String get delAccDeleteMyAccount => 'Excluir minha conta';

  @override
  String get legalOpenInBrowser => 'Abrir no navegador';

  @override
  String get legalLoadError => 'Não foi possível carregar esta página.';

  @override
  String get languagePickerTitle => 'Escolha o idioma';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'English';

  @override
  String get errorNetwork => 'Sem conexão. Verifique sua internet.';

  @override
  String get errorGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String get errorNotFound => 'Conteúdo não encontrado.';

  @override
  String get errorUnauthorized => 'Sessão expirada. Faça login novamente.';

  @override
  String get giftComingSoon => '🎁 Em breve!';

  @override
  String get liveBadge => 'AO VIVO';

  @override
  String viewerCount(int count) {
    return '$count assistindo';
  }

  @override
  String get authLoginSubtitle => 'Entre na sua conta para continuar.';

  @override
  String get authWelcomeBackTitle => 'Bem-vindo\nde volta.';

  @override
  String get authEmailHint => 'voce@brawe.app';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authEmailLabel => 'E-MAIL';

  @override
  String get authPasswordLabel => 'SENHA';

  @override
  String get authForgotPasswordShort => 'Esqueci minha senha';

  @override
  String get authLoggingIn => 'Entrando…';

  @override
  String get authNoAccount => 'Não tem conta?';

  @override
  String get authCreateNow => 'Criar agora';

  @override
  String get authAcceptTermsAndPrivacy =>
      'Ao continuar você aceita os Termos de Uso\ne a Política de Privacidade.';

  @override
  String get authWelcomeBackSuccess => 'Bem-vindo de volta.';

  @override
  String get authAlreadyHaveAccount => 'Já tem conta?';

  @override
  String get authEntrar => 'Entrar';

  @override
  String get welcomeTagline => 'Conecte. Transmita. Cresça.';

  @override
  String get welcomeAlreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get welcomeAcceptTerms => 'Ao continuar você aceita os Termos de Uso.';

  @override
  String get welcomeCreateAccount => 'Criar conta';

  @override
  String get signupTitle => 'Crie sua conta.';

  @override
  String get signupSubtitle => 'Leva menos de um minuto para começar.';

  @override
  String get signupNameLabel => 'Nome completo';

  @override
  String get signupNameHint => 'Como devemos te chamar?';

  @override
  String get signupEmailLabel => 'E-mail';

  @override
  String get signupPasswordLabel => 'Senha';

  @override
  String get signupPasswordHint => 'mínimo 8 caracteres';

  @override
  String get signupSponsorLabel => 'Código do patrocinador';

  @override
  String get signupSponsorHint => 'BRAWE-XXXX';

  @override
  String get signupHaveReferral => 'Tenho um código de indicação';

  @override
  String get signupCreatingAccount => 'Criando conta…';

  @override
  String get signupCreateAccountButton => 'Criar conta';

  @override
  String get signupSuccess => 'Conta criada com sucesso.';

  @override
  String get signupHelp => 'Ajuda';

  @override
  String signupCantOpenUrl(String url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String get signupTermsPrefix => 'Li e aceito os ';

  @override
  String get signupTermsAnd => ' e a ';

  @override
  String get signupTermsSuffix => ' do Brawe.';

  @override
  String get pwStrengthWeak => 'Fraca';

  @override
  String get pwStrengthMedium => 'Média';

  @override
  String get pwStrengthGood => 'Boa';

  @override
  String get pwStrengthStrong => 'Forte';

  @override
  String get forgotTitle => 'Recuperar senha';

  @override
  String get forgotSubtitle =>
      'Informe seu email e enviaremos instruções para criar uma nova senha.';

  @override
  String get forgotEmailLabel => 'EMAIL';

  @override
  String get forgotEmailHint => 'voce@exemplo.com';

  @override
  String get forgotInvalidEmail => 'Informe um email válido.';

  @override
  String get forgotSending => 'Enviando...';

  @override
  String get forgotSendInstructions => 'Enviar instruções';

  @override
  String get forgotCannotSend => 'Não foi possível enviar.';

  @override
  String get forgotBackToLogin => 'Voltar para login';

  @override
  String get forgotCheckEmail => 'Verifique seu email';

  @override
  String forgotEmailSentBody(String email) {
    return 'Se $email estiver cadastrado, você receberá um link para criar uma nova senha em alguns minutos.';
  }

  @override
  String get resetTitle => 'Criar nova senha';

  @override
  String get resetSubtitle =>
      'Escolha uma senha forte de pelo menos 8 caracteres.';

  @override
  String get resetNewPasswordLabel => 'NOVA SENHA';

  @override
  String get resetConfirmPasswordLabel => 'CONFIRMAR SENHA';

  @override
  String get resetPasswordTooShort =>
      'A senha deve ter pelo menos 8 caracteres.';

  @override
  String get resetPasswordsDontMatch => 'As senhas não coincidem.';

  @override
  String get resetSaving => 'Salvando...';

  @override
  String get resetInvalidToken => 'Token inválido ou expirado.';

  @override
  String get navLives => 'Lives';

  @override
  String get createStoryTitle => 'Story';

  @override
  String get createStorySubtitle => 'Foto ou vídeo · some em 24h';

  @override
  String get createVideoTitle => 'Vídeo';

  @override
  String get createVideoSubtitle => 'Reels · aparece em Para Você';

  @override
  String get createLiveTitle => 'Live';

  @override
  String get createLiveSubtitle => 'Transmita agora e receba gifts';

  @override
  String get createPostTitle => 'Post';

  @override
  String get createPostSubtitle => 'Texto, foto ou link no seu feed';

  @override
  String get feedEmptyVideoTitle => 'Nenhum vídeo ou foto por aqui ainda.';

  @override
  String get feedEmptyVideoSubtitle =>
      'Siga creators ou volte mais tarde.\nPosts de texto estão na aba Feed.';

  @override
  String get liveJoining => 'Entrando na live…';

  @override
  String get liveBadgeBattle => 'AO VIVO · BATALHA';

  @override
  String get liveBadgeShop => 'AO VIVO · SHOP';

  @override
  String get liveOfferNow => 'OFERTA AGORA';

  @override
  String get productFeatured => 'EM DESTAQUE';

  @override
  String get videoLoadError => 'Não foi possível carregar o vídeo.';

  @override
  String get giftSendAnonymous => 'Enviar anonimamente';

  @override
  String get giftAnonNameHidden => 'Seu nome não será revelado';

  @override
  String get giftAnonNameVisible => 'Todos verão que foi você';

  @override
  String get giftSendButtonAnon => 'Enviar (anônimo)';

  @override
  String get giftSendButton => 'Enviar presente';

  @override
  String get giftSentAnon => 'Presente enviado anonimamente!';

  @override
  String get giftSent => 'Presente enviado!';

  @override
  String get feedCannotLike => 'Não foi possível curtir. Tente novamente.';

  @override
  String get feedUseLiveChat => 'Use o chat ao vivo para conversar.';

  @override
  String get feedCannotShare => 'Não foi possível compartilhar.';

  @override
  String get feedCannotFollow => 'Não foi possível atualizar o follow.';

  @override
  String get shareCheckBraweConnect => 'Confira no Brawe Connect';

  @override
  String get homeStatFollowers => 'Seguidores';

  @override
  String get homeStatFollowing => 'Seguindo';

  @override
  String get homeStatLives => 'Lives';

  @override
  String get profileViewFull => 'Ver perfil completo';

  @override
  String get createSheetTitle => 'Criar';

  @override
  String get createSheetSubtitle =>
      'Compartilhe um momento, abra uma live ou solte uma ideia.';

  @override
  String get productsDrawerTitle => 'Loja ao vivo';

  @override
  String productsDrawerItemCount(int count, String author) {
    return '$count itens • $author';
  }

  @override
  String get giftMysteryTitle => 'Presente Misterioso';

  @override
  String get giftMysterySubtitle =>
      'Surpreenda um dos streamers!\nO destino é escolhido aleatoriamente. 🎲';

  @override
  String get commentsErrorSend => 'Erro ao enviar comentário. Tente novamente.';

  @override
  String get commentsErrorLoad => 'Erro ao carregar comentários.';

  @override
  String commentsReplyingTo(String username) {
    return 'Respondendo a @$username';
  }

  @override
  String get commentsHintReply => 'Responder...';

  @override
  String get commentsHintAdd => 'Adicionar comentário...';

  @override
  String get commentsReplyAction => 'Responder';

  @override
  String get postPublish => 'Publicar';

  @override
  String get postPublishedSuccess => 'Post publicado!';

  @override
  String get postPublishError => 'Erro ao publicar. Tente novamente.';

  @override
  String get postHintWhatsHappening => 'O que está acontecendo?';

  @override
  String get audiencePickerTitle => 'Quem pode ver?';

  @override
  String get audienceAll => 'Todos';

  @override
  String get audienceFollowers => 'Seguidores';

  @override
  String get audienceOnlyMe => 'Apenas eu';

  @override
  String get videoTooLarge => 'Vídeo muito grande. Máximo 100 MB.';

  @override
  String get videoOpenError => 'Não foi possível abrir o vídeo.';

  @override
  String get videoPublishedSuccess => 'Vídeo publicado! 🎬';

  @override
  String get videoPublishError => 'Erro ao publicar vídeo. Tente novamente.';

  @override
  String get videoSheetTitle => 'Novo vídeo';

  @override
  String get videoSwapTooltip => 'Trocar vídeo';

  @override
  String get videoCaptionHint => 'Escreva uma legenda (opcional)…';

  @override
  String get videoPublishButton => 'Publicar vídeo';

  @override
  String get videoSelect => 'Selecionar vídeo';

  @override
  String get videoFormatsHint =>
      'MP4 · MOV · WebM   ·   até 3 min   ·   100 MB';

  @override
  String get storySheetTitle => 'Novo story';

  @override
  String get storyPublish => 'Publicar';

  @override
  String get storyPublishedSuccess => 'Story publicado!';

  @override
  String get storyPublishError => 'Erro ao publicar story. Tente novamente.';

  @override
  String get storyPrefetchError => 'Falha ao carregar imagem do post.';

  @override
  String get storyPrefetchLoading => 'Carregando imagem do post...';

  @override
  String get storyCaptionHint => 'Escreva uma legenda (opcional)…';

  @override
  String get storySwapMedia => 'Trocar mídia';

  @override
  String get storyPickerTitle => 'Selecione ou grave uma mídia';

  @override
  String get storyPickerSubtitle => 'Foto ou vídeo (até 60s)';

  @override
  String get storyPickerSectionGallery => 'Galeria';

  @override
  String get storyPickerSectionCamera => 'Câmera';

  @override
  String get storyPickerChipPhoto => 'Foto';

  @override
  String get storyPickerChipVideo => 'Vídeo';

  @override
  String get storyPickerChipRecordVideo => 'Gravar vídeo';

  @override
  String get storiesReload => 'Recarregar stories';

  @override
  String get storiesYour => 'Seu story';

  @override
  String get storiesCreate => 'Criar';

  @override
  String get storiesFallbackUser => 'usuário';

  @override
  String get storiesLiveBadge => 'LIVE';

  @override
  String get shareLoadError => 'Não foi possível carregar contatos.';

  @override
  String shareSentSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado para $count pessoas.',
      one: 'Enviado para $count pessoa.',
    );
    return '$_temp0';
  }

  @override
  String shareSentPartial(int sent, int failures) {
    return 'Enviado para $sent. Falha em $failures.';
  }

  @override
  String get shareTitle => 'Enviar para...';

  @override
  String get sharePostFallback => 'Publicação';

  @override
  String get shareSearchHint => 'Buscar';

  @override
  String get shareErrorGeneric => 'Erro';

  @override
  String get shareTryAgain => 'Tentar de novo';

  @override
  String get shareRecents => 'Recentes';

  @override
  String get shareFollowers => 'Seguidores';

  @override
  String get shareUserFallback => 'Usuário';

  @override
  String get shareNoContacts => 'Nenhum contato encontrado.';

  @override
  String get shareCommentHint => 'Adicione um comentário…';

  @override
  String get shareOutsideBrawe => 'Fora do Brawe';

  @override
  String get shareSend => 'Enviar';

  @override
  String shareSendWithCount(int count) {
    return 'Enviar ($count)';
  }

  @override
  String giftSendError(Object error) {
    return 'Não foi possível enviar o presente: $error';
  }

  @override
  String giftLoadError(Object error) {
    return 'Não foi possível carregar os presentes.\n$error';
  }

  @override
  String get giftEmptyState => 'Nenhum presente disponível agora.';

  @override
  String get giftSendTo => 'Enviar presente pra';

  @override
  String get giftChoose => 'Escolha um presente';

  @override
  String giftSendCta(int total) {
    return 'ENVIAR · 💎 $total';
  }

  @override
  String get suggestedTitle => 'Sugestões para você';

  @override
  String get suggestedSeeAll => 'Ver todos';

  @override
  String get suggestedFollow => 'Seguir';

  @override
  String get suggestedFollowing => 'Seguindo';

  @override
  String get suggestedLiveBadge => 'AO VIVO';

  @override
  String get composerMediaLoadError => 'Não foi possível carregar a mídia.';

  @override
  String get composerPhotoError => 'Falha ao tirar foto.';

  @override
  String get composerRecordStartError => 'Falha ao iniciar gravação.';

  @override
  String get composerRecordStopError => 'Falha ao finalizar gravação.';

  @override
  String get composerStoryPublished => 'Story publicado!';

  @override
  String composerMultipleStoriesPublished(int count) {
    return '$count stories publicados!';
  }

  @override
  String get composerPublishError => 'Falha ao publicar story.';

  @override
  String get composerRetry => 'Tentar novamente';

  @override
  String get composerPreparing => 'Preparando publicação…';

  @override
  String get composerCreateStory => 'Criar story';

  @override
  String get composerCaptureHint => 'Toque para foto • Segure para vídeo';

  @override
  String get composerGallery => 'Galeria';

  @override
  String get composerTextOnly => 'Só texto';

  @override
  String get composerFrameNone => 'Sem moldura';

  @override
  String get composerFramePolaroid => 'Polaroid';

  @override
  String get composerFrameBrawe => 'Brawe';

  @override
  String get composerFrameHint => 'Toque 2x para moldura';

  @override
  String composerFrameLabel(String style) {
    return 'Moldura: $style';
  }

  @override
  String get composerCaptionHint => 'Adicione uma legenda...';

  @override
  String get composerTapOutsideHint => 'Toque fora para concluir';

  @override
  String get composerTextHint => 'Digite algo...';

  @override
  String get composerGuideTop => 'topo seguro';

  @override
  String get composerGuideBottom => 'base segura';

  @override
  String get viewerDeleteStory => 'Excluir story';

  @override
  String get viewerUnfollow => 'Deixar de seguir';

  @override
  String get viewerBlockUser => 'Bloquear usuário';

  @override
  String get viewerReport => 'Denunciar';

  @override
  String get viewerDeleteConfirm => 'Esta ação não pode ser desfeita.';

  @override
  String get viewerCancel => 'Cancelar';

  @override
  String get viewerDelete => 'Excluir';

  @override
  String get viewerBlock => 'Bloquear';

  @override
  String get viewerStoryDeleted => 'Story excluído.';

  @override
  String viewerDeleteError(Object error) {
    return 'Não foi possível excluir o story. ($error)';
  }

  @override
  String viewerUnfollowed(String username) {
    return 'Você deixou de seguir @$username.';
  }

  @override
  String get viewerUnfollowError => 'Não foi possível deixar de seguir.';

  @override
  String viewerBlockConfirm(String username) {
    return 'Você não verá mais conteúdo de @$username.';
  }

  @override
  String get viewerBlockError => 'Não foi possível bloquear.';

  @override
  String get viewerReportPrompt => 'Por que você está denunciando?';

  @override
  String get viewerReportSpam => 'Spam ou enganoso';

  @override
  String get viewerReportHarassment => 'Assédio ou bullying';

  @override
  String get viewerReportInappropriate => 'Conteúdo impróprio ou ofensivo';

  @override
  String get viewerReportImpersonation => 'Falsa identidade';

  @override
  String get viewerReportOther => 'Outro';

  @override
  String get viewerReportSent => 'Denúncia enviada. Obrigado.';

  @override
  String get viewerReportError => 'Não foi possível enviar a denúncia.';

  @override
  String get viewerSeeOriginalPost => 'Ver post original';

  @override
  String get viewerReplySent => 'Resposta enviada.';

  @override
  String get viewerReplyError => 'Não foi possível responder.';

  @override
  String get viewerReplyHint => 'Responder ao story...';

  @override
  String viewerGiftSent(String giftName, int quantity, int credits) {
    return 'Enviou $giftName x$quantity · 💎 $credits';
  }

  @override
  String get viewerLoadViewersError =>
      'Não foi possível carregar visualizadores.';

  @override
  String get viewerTimeNow => 'agora';

  @override
  String viewerTimeMinutes(int minutes) {
    return 'há ${minutes}m';
  }

  @override
  String viewerTimeHours(int hours) {
    return 'há ${hours}h';
  }

  @override
  String viewerTimeDays(int days) {
    return 'há ${days}d';
  }

  @override
  String get viewerLoading => 'Carregando...';

  @override
  String get viewerNoViewers => 'Ainda ninguém viu este story.';

  @override
  String viewerBlocked(String username) {
    return '@$username bloqueado.';
  }

  @override
  String viewerViewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visualizações',
      one: '1 visualização',
    );
    return '$_temp0';
  }

  @override
  String get feedTabForYou => 'Para Você';

  @override
  String get feedTabFollowing => 'Seguindo';

  @override
  String get feedEmptyQuietTitle => 'O feed está quietinho';

  @override
  String get feedEmptyQuietSubtitle =>
      'Seja o primeiro a postar algo brilhante hoje.';

  @override
  String get feedEmptyFollowingTitle => 'Nada por aqui ainda';

  @override
  String get feedEmptyFollowingSubtitle =>
      'Siga pessoas para ver os posts delas aqui.';

  @override
  String get feedOfflineTitle => 'Sem conexão por aqui';

  @override
  String get feedOfflineSubtitle => 'Verifique sua internet e tente de novo.';

  @override
  String get feedRetry => 'Tentar de novo';

  @override
  String get feedSaved => 'Salvo nos seus favoritos';

  @override
  String get feedUnsaved => 'Removido dos favoritos';

  @override
  String get feedLinkCopied => 'Link copiado!';

  @override
  String get feedDeletePostTitle => 'Excluir post?';

  @override
  String get feedDeleteConfirm => 'Esta ação não pode ser desfeita.';

  @override
  String get feedCancel => 'Cancelar';

  @override
  String get feedDelete => 'Excluir';

  @override
  String get feedPostDeleted => 'Post excluído.';

  @override
  String get feedPostDeleteError => 'Não foi possível excluir o post.';

  @override
  String feedUnfollowed(String username) {
    return 'Você deixou de seguir @$username.';
  }

  @override
  String get feedUnfollowError => 'Não foi possível deixar de seguir.';

  @override
  String get feedBlockUserTitle => 'Bloquear usuário';

  @override
  String feedBlockConfirm(String username) {
    return 'Você não verá mais conteúdo de @$username. Deseja continuar?';
  }

  @override
  String get feedBlock => 'Bloquear';

  @override
  String get feedBlockError => 'Não foi possível bloquear.';

  @override
  String get feedReportTitle => 'Denunciar post';

  @override
  String get feedReportPrompt => 'Por que você está denunciando?';

  @override
  String get feedReportSpam => 'Spam ou enganoso';

  @override
  String get feedReportHarassment => 'Assédio ou bullying';

  @override
  String get feedReportInappropriate => 'Conteúdo impróprio ou ofensivo';

  @override
  String get feedReportImpersonation => 'Falsa identidade';

  @override
  String get feedReportOther => 'Outro';

  @override
  String get feedReportSent => 'Denúncia enviada. Obrigado por nos avisar.';

  @override
  String get feedReportError => 'Não foi possível enviar a denúncia.';

  @override
  String get feedRepostUndoConfirm => 'Desfazer repost?';

  @override
  String get feedRepostConfirm => 'Repostar para seus seguidores?';

  @override
  String get feedRepostUndo => 'Desfazer repost';

  @override
  String get feedRepost => 'Repostar';

  @override
  String get feedQuotePost => 'Citar post';

  @override
  String get feedCopyLink => 'Copiar link';

  @override
  String get feedShareAsStory => 'Compartilhar como Story';

  @override
  String get feedUnfollow => 'Deixar de seguir';

  @override
  String get feedReport => 'Denunciar';

  @override
  String get feedDeletePost => 'Excluir post';

  @override
  String get feedSend => 'Enviar';

  @override
  String get feedTimeNow => 'agora';

  @override
  String feedBlocked(String username) {
    return '@$username bloqueado.';
  }

  @override
  String get chatStatusOnline => 'Online';

  @override
  String get chatStatusAway => 'Ausente';

  @override
  String get chatStatusDnd => 'Não perturbe';

  @override
  String get chatStatusInvisible => 'Invisível';

  @override
  String get chatStatusSheetTitle => 'Meu Status';

  @override
  String get chatStatusSheetSubtitle =>
      'Escolha como você aparece para outros usuários.';

  @override
  String get chatNewMessageTitle => 'Nova Mensagem';

  @override
  String get chatSearchHint => 'Buscar pessoas que você segue…';

  @override
  String get chatFollowingLabel => 'Seguindo';

  @override
  String chatStartConversationError(Object error) {
    return 'Erro ao iniciar conversa: $error';
  }

  @override
  String chatLoadError(Object error) {
    return 'Erro ao carregar: $error';
  }

  @override
  String get chatLiveBadge => 'AO VIVO';

  @override
  String get chatFallbackName => 'Chat';

  @override
  String get chatEmptySearchTitle => 'Nenhuma pessoa encontrada';

  @override
  String get chatEmptySearchSubtitle =>
      'Tente pesquisar por nome ou @username de alguém que você segue.';

  @override
  String get chatListTitle => 'Mensagens';

  @override
  String get chatListSearchHint => 'Pesquisar conversas, pessoas…';

  @override
  String get chatListTabAll => 'Todas';

  @override
  String get chatListTabUnread => 'Não lidas';

  @override
  String get chatListTabArchived => 'Arquivadas';

  @override
  String get chatListRetry => 'Tentar de novo';

  @override
  String get chatListNewTooltip => 'Nova conversa';

  @override
  String get chatListEmptyTitle => 'Comece uma conversa';

  @override
  String get chatListEmptySubtitle =>
      'Suas mensagens com creators, amigos e brawers vão aparecer aqui.';

  @override
  String get chatListTapToTalk => 'Toque para conversar';

  @override
  String get chatListArchive => 'Arquivar';

  @override
  String get chatListUnarchive => 'Desarquivar';

  @override
  String get chatListDelete => 'Apagar';

  @override
  String get chatListDeleteConfirmTitle => 'Apagar conversa?';

  @override
  String get chatListDeleteConfirmBody =>
      'A conversa será apagada apenas para você.';

  @override
  String get chatListCancel => 'Cancelar';

  @override
  String get chatListTimeNow => 'agora';

  @override
  String chatDetailPickImageError(Object error) {
    return 'Erro ao escolher imagem: $error';
  }

  @override
  String chatDetailBlockTitle(String name) {
    return 'Bloquear $name?';
  }

  @override
  String get chatDetailBlockBody =>
      'Você não poderá mais enviar ou receber mensagens desta pessoa.';

  @override
  String get chatDetailCancel => 'Cancelar';

  @override
  String get chatDetailBlock => 'Bloquear';

  @override
  String chatDetailBlocked(String name) {
    return '$name foi bloqueado(a).';
  }

  @override
  String chatDetailBlockError(Object error) {
    return 'Erro ao bloquear: $error';
  }

  @override
  String get chatDetailViewProfile => 'Ver perfil';

  @override
  String get chatDetailOpenProfileError =>
      'Não foi possível abrir o perfil deste contato.';

  @override
  String get chatDetailMute => 'Silenciar notificações';

  @override
  String get chatDetailComingSoon => 'Em breve';

  @override
  String get chatDetailSearchInChat => 'Buscar na conversa';

  @override
  String chatDetailBlockMenu(String name) {
    return 'Bloquear $name';
  }

  @override
  String get chatDetailReport => 'Denunciar';

  @override
  String get chatDetailReportSent => 'Denúncia enviada. Obrigado!';

  @override
  String get chatDetailStatusTyping => 'digitando';

  @override
  String get chatDetailStatusOnline => 'Online';

  @override
  String chatDetailStatusSeen(String when) {
    return 'visto $when';
  }

  @override
  String get chatDetailStatusOffline => 'Offline';

  @override
  String get chatDetailDateToday => 'Hoje';

  @override
  String get chatDetailDateYesterday => 'Ontem';

  @override
  String get chatDetailReply => 'Responder';

  @override
  String get chatDetailCopy => 'Copiar';

  @override
  String get chatDetailDeleteForMe => 'Apagar para mim';

  @override
  String get chatDetailViewOnceBadge => 'Ver 1x';

  @override
  String get chatDetailViewOnceTitle => 'Visualização única';

  @override
  String get chatDetailPhotoViewedOnce => 'Foto vista por 1 vez';

  @override
  String get chatDetailPhotoUnavailable => 'Foto não está mais disponível';

  @override
  String get chatDetailEmptyTitle => 'Diga olá 👋';

  @override
  String get chatDetailEmptySubtitle =>
      'Envie a primeira mensagem para começar a conversa.';

  @override
  String get chatDetailReplying => 'Respondendo';

  @override
  String get chatDetailReplyImagePreview => '📷 Foto';

  @override
  String get chatDetailMessageHint => 'Mensagem';

  @override
  String get chatDetailVoiceTitle => 'Mensagem de voz';

  @override
  String get chatDetailVoiceSubtitle =>
      'Em breve — gravação com waveform animado';

  @override
  String get chatDetailClose => 'Fechar';

  @override
  String get chatDetailAttachGallery => 'Galeria';

  @override
  String get chatDetailAttachCamera => 'Câmera';

  @override
  String get chatDetailAttachAudio => 'Áudio';

  @override
  String get chatDetailAttachLocation => 'Local';

  @override
  String get chatDetailAttachFile => 'Arquivo';

  @override
  String get chatDetailAttachMystery => 'Mistério';

  @override
  String get chatDetailRelativeNow => 'agora';

  @override
  String chatDetailRelativeMinutes(int minutes) {
    return 'há ${minutes}m';
  }

  @override
  String chatDetailRelativeHours(int hours) {
    return 'há ${hours}h';
  }

  @override
  String chatDetailRelativeDays(int days) {
    return 'há ${days}d';
  }

  @override
  String get chatDetailViewPost => 'Ver publicação';

  @override
  String get chatDetailPostUnavailable => 'Publicação indisponível';

  @override
  String get chatDetailOpenPostSoon => 'Abrir publicação em breve';

  @override
  String get chatDetailBurnedPreview => '🔥 Mensagem queimada';

  @override
  String get chatDetailStreamerFallback => 'Streamer';

  @override
  String get chatDetailLiveFallbackTitle => 'Live';

  @override
  String get chatDetailLiveTapToWatch => 'Toque para assistir';

  @override
  String get chatDetailLiveSeeDetails => 'Ver detalhes';

  @override
  String get chatDetailEmojiSmileys => 'Smileys';

  @override
  String get chatDetailEmojiGestures => 'Gestos';

  @override
  String get chatDetailEmojiHearts => 'Coração';

  @override
  String get chatDetailEmojiAnimals => 'Animais';

  @override
  String get chatDetailEmojiFood => 'Comida';

  @override
  String get chatDetailEmojiParty => 'Festa';

  @override
  String get chatDetailEmojiObjects => 'Objetos';

  @override
  String get profileTabGallery => 'Galeria';

  @override
  String get profileTabLives => 'Lives';

  @override
  String get profileTabShop => 'Loja';

  @override
  String get profileTooltipShop => 'Loja';

  @override
  String get profileTooltipQuests => 'Quests';

  @override
  String get profileTooltipNotifications => 'Notificações';

  @override
  String get profileTooltipWallet => 'Carteira';

  @override
  String get profileShareFail => 'Não foi possível compartilhar.';

  @override
  String get profileLinkCopied => 'Link copiado para a área de transferência';

  @override
  String get profileBlockedSuccess => 'Usuário bloqueado.';

  @override
  String get profileBlockedError => 'Falha ao bloquear. Tente novamente.';

  @override
  String get profileReportSent => 'Denúncia enviada. Obrigado.';

  @override
  String get profileReportError => 'Falha ao denunciar. Tente novamente.';

  @override
  String get profileBlockTitle => 'Bloquear';

  @override
  String profileBlockBody(String name) {
    return 'Tem certeza que deseja bloquear $name? Vocês não poderão mais trocar mensagens nem ver conteúdo um do outro.';
  }

  @override
  String get profileFallbackUser => 'este usuário';

  @override
  String get profileReportQuestion => 'Por que está denunciando?';

  @override
  String get profileReportReasonSpam => 'Spam';

  @override
  String get profileReportReasonHarassment => 'Assédio ou bullying';

  @override
  String get profileReportReasonInappropriate => 'Conteúdo impróprio';

  @override
  String get profileReportReasonImpersonation => 'Falsa identidade';

  @override
  String get profileReportReasonOther => 'Outro motivo';

  @override
  String get profileOptionShareProfile => 'Compartilhar perfil';

  @override
  String get profileOptionCopyLink => 'Copiar link';

  @override
  String get profileOptionReport => 'Denunciar';

  @override
  String get profileOptionDailyQuests => 'Quests diárias';

  @override
  String get profileOptionWallet => 'Carteira';

  @override
  String get profileOptionNotifications => 'Notificações';

  @override
  String get profileOptionSettings => 'Configurações';

  @override
  String get profileOptionLogout => 'Sair da conta';

  @override
  String get profileLogoutTitle => 'Sair da conta?';

  @override
  String get profileLogoutBody =>
      'Você precisará entrar novamente para acessar sua arena.';

  @override
  String get profileLogoutConfirm => 'Sair';

  @override
  String get profileMessageButton => 'Mensagem';

  @override
  String profileOpenConversationError(Object error) {
    return 'Erro ao abrir conversa: $error';
  }

  @override
  String get profileChatFallback => 'Chat';

  @override
  String get profileUserFallback => 'Usuário';

  @override
  String get profileEditTooltip => 'Editar perfil';

  @override
  String get profileStatFollowers => 'Seguidores';

  @override
  String get profileStatFollowing => 'Seguindo';

  @override
  String get profileStatLives => 'Lives';

  @override
  String get profileStatViews => 'Views';

  @override
  String get profileLoadError => 'Não foi possível carregar o perfil';

  @override
  String get profileLoadErrorHint => 'Verifique sua conexão e tente novamente.';

  @override
  String get profileRetry => 'Tentar novamente';

  @override
  String get profileSellerVerified => 'Vendedor verificado';

  @override
  String get profileSellerSubtitle => 'Confira a vitrine de produtos';

  @override
  String get profileNoTextPosts => 'Nenhum post de texto ainda';

  @override
  String get profilePostsLoadError => 'Erro ao carregar posts';

  @override
  String get profileNoLives => 'Nenhuma live ainda';

  @override
  String get profileLivesLoadError => 'Erro ao carregar lives';

  @override
  String get profileShopEmpty => 'Loja vazia';

  @override
  String get profileShopFeatured => 'Destaques';

  @override
  String get profileShopAllProducts => 'Todos os produtos';

  @override
  String get profileLiveBadge => 'LIVE';

  @override
  String get profileProductSoldOut => 'Esgotado';

  @override
  String get profileProductSoldOutUppercase => 'ESGOTADO';

  @override
  String get profileProductAbout => 'Sobre o produto';

  @override
  String get profileProductUnavailable => 'Indisponível';

  @override
  String get profileProductBuyNow => 'Comprar agora';

  @override
  String get profileAddedToCart => '🛒 Adicionado ao carrinho!';

  @override
  String get profileGalleryLoadError => 'Erro ao carregar galeria';

  @override
  String get profileGalleryEmpty => 'Nada por aqui ainda';

  @override
  String get profileGalleryRemoveTitle => 'Remover mídia?';

  @override
  String get profileGalleryRemoveBody => 'Essa ação não pode ser desfeita.';

  @override
  String get profileGalleryRemove => 'Remover';

  @override
  String get profileVideoDeleteTitle => 'Apagar vídeo?';

  @override
  String get profileVideoDelete => 'Apagar';

  @override
  String get profileVideoDeleted => 'Vídeo apagado';

  @override
  String get profileVideoDeleteError => 'Falha ao apagar vídeo';

  @override
  String get profileVideoRepostStory => 'Repostar no Stories';

  @override
  String get profileVideoDeleteAction => 'Apagar vídeo';

  @override
  String get profileVideoLoadError => 'Não foi possível carregar o vídeo.';

  @override
  String profileGalleryTabPhotos(int count, int max) {
    return 'Fotos ($count/$max)';
  }

  @override
  String profileGalleryTabVideos(int count, int max) {
    return 'Vídeos ($count/$max)';
  }

  @override
  String get profileGalleryPhotoAdded => 'Foto adicionada';

  @override
  String get profileGalleryPhotoError => 'Falha ao enviar foto';

  @override
  String get profileGalleryVideoAdded => 'Vídeo adicionado';

  @override
  String get profileGalleryVideoError => 'Falha ao enviar vídeo';

  @override
  String get profileVideoDeleteBody =>
      'Essa ação não pode ser desfeita. O vídeo sairá do Para Você e do seu perfil.';

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
    return 'Apenas $count restantes';
  }

  @override
  String profileProductInStock(int count) {
    return '$count em estoque';
  }

  @override
  String get profileProductDescription =>
      'Produto exclusivo da loja oficial. Envio em até 3 dias úteis. Garantia de 30 dias e troca grátis.';

  @override
  String profilePriceBRL(String amount) {
    return 'R\\\$ $amount';
  }

  @override
  String get profileVideosLoadError => 'Erro ao carregar vídeos';

  @override
  String get profileVideosEmpty => 'Nenhum vídeo publicado ainda';

  @override
  String get profileVideoSwipeHint => 'Deslize';

  @override
  String get notificationsMarkAll => 'Marcar todas';

  @override
  String get notificationsEmptyTitle => 'Tudo em dia!';

  @override
  String get notificationsEmptySubtitle => 'Você não tem notificações novas.';

  @override
  String get notificationsLoadError =>
      'Não consegui carregar suas notificações.';

  @override
  String get notificationsTryAgain => 'Tentar novamente';

  @override
  String get notificationsTimeNow => 'agora';

  @override
  String notificationsTimeMinutes(int n) {
    return '${n}m atrás';
  }

  @override
  String notificationsTimeHours(int n) {
    return '${n}h atrás';
  }

  @override
  String notificationsTimeDays(int n) {
    return '${n}d atrás';
  }

  @override
  String get followsTitle => 'Pessoas';

  @override
  String get followsTabFollowers => 'Seguidores';

  @override
  String get followsTabFollowing => 'Seguindo';

  @override
  String get followsSearchHint => 'Buscar...';

  @override
  String get followsLoadError => 'Erro ao carregar';

  @override
  String get followsTryAgain => 'Tentar de novo';

  @override
  String followsNoResults(String q) {
    return 'Nenhum resultado para \"$q\"';
  }

  @override
  String get followsEmptyFollowers => 'Ainda sem seguidores';

  @override
  String get followsEmptyFollowing => 'Ainda não segue ninguém';

  @override
  String get followsUserFallback => 'Usuário';

  @override
  String get followsLiveBadge => 'LIVE';

  @override
  String get questsTitle => 'Quests Diárias';

  @override
  String questsClaimAll(int count) {
    return 'Coletar tudo ($count)';
  }

  @override
  String questsClaimedReward(int n) {
    return '$n recompensa(s) coletada(s)!';
  }

  @override
  String get questsNothingToClaim => 'Nada para coletar agora.';

  @override
  String questsClaimSuccess(int xp, int coins) {
    return '+$xp XP · +$coins moedas';
  }

  @override
  String get questsClaimError => 'Falha ao resgatar. Tente novamente.';

  @override
  String get questsEmpty => 'Sem quests por enquanto.\nVolte mais tarde!';

  @override
  String questsLevel(int level) {
    return 'Nível $level';
  }

  @override
  String questsXpProgress(int current, int total) {
    return '$current / $total XP';
  }

  @override
  String get questsSummaryCompleted => 'Concluídas';

  @override
  String get questsSummaryXpToday => 'XP hoje';

  @override
  String get questsSummaryStreak => 'Streak';

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
    return '+$coins moedas';
  }

  @override
  String get questsStatusClaimed => 'Coletado ✓';

  @override
  String get questsStatusInProgress => 'Em progresso';

  @override
  String get questsActionClaim => 'Coletar';

  @override
  String get questsLoadError => 'Não consegui carregar as quests.';

  @override
  String get questsTryAgain => 'Tentar novamente';

  @override
  String questsSummaryCompletedValue(int done, int total) {
    return '$done/$total';
  }

  @override
  String get walletTitle => 'Carteira';

  @override
  String get walletAvailableBalance => 'Saldo disponível';

  @override
  String get walletCoins => 'moedas';

  @override
  String get walletSectionBuyTitle => 'Comprar moedas';

  @override
  String get walletSectionBuySubtitle =>
      'Use moedas para enviar gifts em lives';

  @override
  String get walletSectionHistoryTitle => 'Histórico';

  @override
  String get walletSectionHistorySubtitle => 'Suas últimas movimentações';

  @override
  String walletPackageCoins(String n) {
    return '$n moedas';
  }

  @override
  String walletPriceBRL(String value) {
    return 'R\$ $value';
  }

  @override
  String get walletPurchaseInfo =>
      'Pagamentos in-app chegando em breve. Por enquanto, compre moedas pelo navegador em brawe.app/coins.';

  @override
  String get walletPurchaseUnderstood => 'Entendi';

  @override
  String get walletInfoTitle => 'Como funcionam as moedas';

  @override
  String get walletInfoQuestsTitle => 'Quests diárias';

  @override
  String get walletInfoQuestsBody =>
      'Complete missões e ganhe moedas + XP todos os dias.';

  @override
  String get walletInfoGiftsTitle => 'Receba gifts';

  @override
  String get walletInfoGiftsBody =>
      'Suas lives recebem gifts dos seus seguidores.';

  @override
  String get walletInfoUseTitle => 'Use em lives';

  @override
  String get walletInfoUseBody =>
      'Envie gifts para creators favoritos durante lives.';

  @override
  String get walletLoadError => 'Não consegui carregar sua carteira.';

  @override
  String get walletTryAgain => 'Tentar novamente';

  @override
  String get walletActionAdd => 'Adicionar';

  @override
  String get walletActionSend => 'Enviar';

  @override
  String get walletActionStatement => 'Extrato';

  @override
  String get walletComingSoon => 'Em breve.';

  @override
  String get walletTxLoadError => 'Não foi possível carregar o histórico.';

  @override
  String get walletTxEmpty => 'Sem movimentações ainda.';

  @override
  String get walletTxTo => 'Para';

  @override
  String get walletTxFrom => 'De';

  @override
  String get exploreSearchHint => 'Buscar streamers, lives, categorias…';

  @override
  String get exploreTabTrending => 'Em alta';

  @override
  String get exploreTabCategories => 'Categorias';

  @override
  String get exploreTabRecommended => 'Para você';

  @override
  String get exploreSectionLives => 'Lives ao vivo';

  @override
  String get exploreSectionTrendingStreamers => 'Streamers em alta';

  @override
  String get exploreSectionRecommendedLives => 'Lives recomendadas';

  @override
  String get exploreSectionRecommendedStreamers =>
      'Streamers que você pode gostar';

  @override
  String get exploreEmptyTrending => 'Nada em alta agora';

  @override
  String get exploreEmptyCategories => 'Nenhuma categoria disponível.';

  @override
  String get exploreEmptyRecommended =>
      'Siga alguns streamers para receber recomendações personalizadas!';

  @override
  String get exploreEmptySearch => 'Nenhum resultado.';

  @override
  String get exploreCategoryGeneral => 'Geral';

  @override
  String exploreFollowersCount(int count) {
    return '$count seguidores';
  }

  @override
  String exploreCategoryLiveCount(int count) {
    return '$count ao vivo';
  }

  @override
  String get exploreLoadError =>
      'Erro ao carregar. Puxe para baixo para tentar novamente.';

  @override
  String exploreLiveSubtitle(String streamer, String category) {
    return '$streamer • $category';
  }

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get editProfileSave => 'Salvar';

  @override
  String get editProfileLoadError => 'Erro ao carregar perfil';

  @override
  String get editProfileSaved => 'Perfil atualizado';

  @override
  String get editProfileSavedUsernameFailed =>
      'Perfil salvo, mas falhou ao atualizar o username';

  @override
  String get editProfileSectionInfo => 'Informações';

  @override
  String get editProfileSectionSocial => 'Links sociais';

  @override
  String get editProfileFieldName => 'Nome de exibição';

  @override
  String get editProfileFieldNameRequired => 'Obrigatório';

  @override
  String get editProfileFieldBio => 'Bio';

  @override
  String get editProfileFieldBioHint => 'Conte um pouco sobre você...';

  @override
  String get editProfileSocialInstagram => 'Instagram';

  @override
  String get editProfileSocialTikTok => 'TikTok';

  @override
  String get editProfileSocialTwitter => 'X / Twitter';

  @override
  String get editProfileSocialYouTube => 'YouTube';

  @override
  String get editProfileSocialWebsite => 'Website';

  @override
  String get editProfileSocialUserHint => '@usuario';

  @override
  String get editProfileSocialChannelHint => 'canal';

  @override
  String get editProfileSocialUrlHint => 'https://...';

  @override
  String get editProfileBannerAdd => 'Adicionar banner';

  @override
  String get editProfileBannerPosition => 'Posicionar banner';

  @override
  String get editProfileAvatarPosition => 'Posicionar foto';

  @override
  String get editProfileUsernameLabel => 'Username';

  @override
  String get editProfileUsernameHint => '@seunome';

  @override
  String get editProfileUsernameAvailable => 'Disponível';

  @override
  String get editProfileUsernameTooShort => 'Mínimo 3 caracteres';

  @override
  String get editProfileUsernameInvalid =>
      'Apenas letras, números e _ (deve começar com letra)';

  @override
  String get editProfileImageProcessError =>
      'Não foi possível processar a imagem.';

  @override
  String get editProfileImageDone => 'Concluir';

  @override
  String get editProfileImageHint =>
      'Arraste para reposicionar · Pinch para dar zoom';

  @override
  String get editProfileErrorSaveFailed =>
      'Não foi possível salvar. Tente de novo.';

  @override
  String get editProfileErrorUsernameCheck => 'Erro ao verificar';

  @override
  String get editProfileErrorUsernameInUse => 'Este username já está em uso';

  @override
  String get editProfileErrorUsernameSaveFailed =>
      'Não foi possível salvar o username. Tente de novo.';

  @override
  String get editProfileErrorAvatarUpload => 'Falha ao enviar avatar.';

  @override
  String get editProfileErrorBannerUpload => 'Falha ao enviar banner.';

  @override
  String get editProfileErrorAvatarRemove => 'Falha ao remover avatar.';

  @override
  String get editProfileErrorBannerRemove => 'Falha ao remover banner.';

  @override
  String get startLivePermissionDenied =>
      'Precisamos de acesso à câmera e ao microfone para iniciar.';

  @override
  String get startLiveNoCamera =>
      'Nenhuma câmera encontrada neste dispositivo.';

  @override
  String startLiveCameraInitError(String error) {
    return 'Erro ao inicializar a câmera: $error';
  }

  @override
  String get startLiveCameraInitFailed => 'Falha ao inicializar a câmera.';

  @override
  String get startLiveThumbCaptured => 'Capa capturada da câmera ✨';

  @override
  String get startLiveThumbCaptureFailed => 'Não foi possível capturar a capa.';

  @override
  String get startLiveThumbUpdated => 'Capa atualizada.';

  @override
  String get startLiveThumbCaptureNow => 'Capturar agora';

  @override
  String get startLiveThumbCaptureNowSubtitle => 'Usa o frame atual da câmera';

  @override
  String get startLiveThumbPickGallery => 'Escolher da galeria';

  @override
  String get startLiveThumbRemove => 'Remover capa';

  @override
  String get startLiveRoomDataError =>
      'Não foi possível obter os dados da live.';

  @override
  String get startLiveRetry => 'Tentar novamente';

  @override
  String get startLiveTitleHint => 'Diga sobre o que é sua live...';

  @override
  String get startLiveCategoryLabel => 'Categoria';

  @override
  String get startLiveNotifyFollowers => 'Avisar meus seguidores';

  @override
  String get startLiveGoLive => 'ENTRAR AO VIVO';

  @override
  String get startLiveSuggestions => 'Sugestões';

  @override
  String get startLiveErrorTitleTooShort =>
      'O título precisa ter pelo menos 3 caracteres.';

  @override
  String get startLiveErrorCategoryRequired =>
      'Selecione uma categoria para sua live.';

  @override
  String get liveCategoryShopping => 'Shopping';

  @override
  String get liveCategoryGaming => 'Gaming';

  @override
  String get liveCategoryTalkShow => 'Talk Show';

  @override
  String get liveCategoryMusic => 'Música';

  @override
  String get liveCategoryEducation => 'Educação';

  @override
  String get liveCategoryFitness => 'Fitness';

  @override
  String get liveCategoryCooking => 'Culinária';

  @override
  String get liveCategoryBeauty => 'Beleza';

  @override
  String get liveCategoryTech => 'Tecnologia';

  @override
  String get liveCategorySports => 'Esportes';

  @override
  String get liveCategoryEntertainment => 'Entretenimento';

  @override
  String get liveCategoryOther => 'Outro';

  @override
  String get liveVisibilityPublic => 'Público';

  @override
  String get liveVisibilityFollowers => 'Seguidores';

  @override
  String get liveVisibilityPrivate => 'Privada';

  @override
  String get liveVisibilityPublicDesc =>
      'Qualquer pessoa pode entrar e descobrir';

  @override
  String get liveVisibilityFollowersDesc => 'Apenas quem te segue pode entrar';

  @override
  String get liveVisibilityPrivateDesc => 'Apenas pessoas com link convidadas';

  @override
  String get warmupHeading => 'Aquecendo o público';

  @override
  String get warmupSubheading => 'Avisando seus seguidores...';

  @override
  String warmupOpensInSeconds(int count, String plural) {
    return 'A live abre em $count segundo$plural';
  }

  @override
  String get warmupGoNow => 'Entrar ao vivo agora';

  @override
  String get warmupCancel => 'Cancelar aquecimento';

  @override
  String get vibeNetworkWifi => 'Wi-Fi';

  @override
  String get vibeNetworkMobile => '4G/5G';

  @override
  String get vibeNetworkEthernet => 'Ethernet';

  @override
  String get vibeNetworkNone => 'Sem rede';

  @override
  String get vibeStatusGood => 'Tudo certo para entrar ao vivo';

  @override
  String get vibeStatusWarning => 'Funciona, mas pode oscilar';

  @override
  String get vibeStatusBad => 'Atenção antes de começar';

  @override
  String vibeNetworkLabel(String label) {
    return 'Rede: $label';
  }

  @override
  String vibeBatteryLabel(int level) {
    return 'Bateria: $level%';
  }

  @override
  String get shareLiveLoginNeeded => 'Faça login para compartilhar';

  @override
  String get shareLiveLoadFollowersError =>
      'Não foi possível carregar seus seguidores.';

  @override
  String shareLiveSentToCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pessoas',
      one: '$countString pessoa',
    );
    return 'Live enviada para $_temp0 🎉';
  }

  @override
  String get shareLiveSendFailed => 'Falha ao compartilhar a live';

  @override
  String get shareLiveTitle => 'Compartilhar live';

  @override
  String get shareLiveBadge => 'LIVE';

  @override
  String get shareLiveSearchHint => 'Buscar seguidores';

  @override
  String get shareLiveErrorGeneric => 'Erro';

  @override
  String get shareLiveRetry => 'Tentar de novo';

  @override
  String get shareLiveEmptyFollowers => 'Nenhum seguidor encontrado.';

  @override
  String get shareLiveDefaultUser => 'Usuário';

  @override
  String get shareLiveNoteHint => 'Adicione uma mensagem (opcional)…';

  @override
  String shareLiveSendTo(int count) {
    return 'Enviar para $count';
  }

  @override
  String get shareLiveSelectContacts => 'Selecione contatos';

  @override
  String get broadcasterPermissionDenied =>
      'Precisamos de acesso à câmera e ao microfone para você entrar ao vivo.';

  @override
  String get broadcasterNoCamera =>
      'Nenhuma câmera encontrada neste dispositivo.';

  @override
  String get broadcasterInitCameraFailed => 'Falha ao inicializar a câmera.';

  @override
  String broadcasterInitCameraError(String error) {
    return 'Erro ao inicializar a câmera: $error';
  }

  @override
  String broadcasterRoomUpdateFailed(String error) {
    return 'Não foi possível atualizar a live: $error';
  }

  @override
  String get broadcasterMissingStreamCreds =>
      'Não foi possível iniciar: URL RTMP ou chave de transmissão ausente.';

  @override
  String get broadcasterConnectedLive => 'Conectado! Você está ao vivo. 🔴';

  @override
  String broadcasterStreamStartError(String error) {
    return 'Erro ao iniciar transmissão: $error';
  }

  @override
  String get broadcasterLiveResumed => 'Live retomada — você está ao vivo.';

  @override
  String get broadcasterLivePaused => 'Live pausada (BRB).';

  @override
  String broadcasterPauseToggleError(String error) {
    return 'Erro ao pausar/retomar: $error';
  }

  @override
  String get broadcasterDiscardTitle => 'Descartar live?';

  @override
  String get broadcasterDiscardMessage =>
      'Você criou uma live mas ainda não começou a transmitir. Deseja descartá-la?';

  @override
  String get broadcasterCancel => 'Cancelar';

  @override
  String get broadcasterDiscard => 'Descartar';

  @override
  String get broadcasterEndTitle => 'Encerrar live?';

  @override
  String get broadcasterEndMessage =>
      'Tem certeza que deseja finalizar a transmissão? Seus viewers serão desconectados.';

  @override
  String get broadcasterContinueLive => 'Continuar ao vivo';

  @override
  String get broadcasterEnd => 'Encerrar';

  @override
  String get broadcasterMoreResumeLive => 'Retomar live';

  @override
  String get broadcasterMorePauseBrb => 'Pausar (BRB)';

  @override
  String get broadcasterMoreResumeSubtitle =>
      'Volta ao ar e continua a transmissão';

  @override
  String get broadcasterMorePauseSubtitle => 'Pausa a transmissão sem encerrar';

  @override
  String get broadcasterMoreSwitchCamera => 'Trocar câmera';

  @override
  String get broadcasterMoreSwitchCameraSubtitle =>
      'Alterna entre frontal e traseira';

  @override
  String get broadcasterMoreShareLive => 'Compartilhar live';

  @override
  String get broadcasterMoreShareLiveSubtitle =>
      'Enviar preview da live aos seus seguidores';

  @override
  String get broadcasterMoreEndLive => 'Encerrar live';

  @override
  String get broadcasterMoreEndLiveSubtitle =>
      'Finaliza a transmissão para todos';

  @override
  String get broadcasterBadgePaused => 'PAUSED';

  @override
  String get broadcasterBadgeLive => 'LIVE';

  @override
  String get broadcasterTooltipResume => 'Retomar';

  @override
  String get broadcasterTooltipPause => 'Pausar';

  @override
  String get broadcasterTooltipMore => 'Mais';

  @override
  String get broadcasterTooltipEnd => 'Encerrar';

  @override
  String broadcasterViewerJoined(String name) {
    return '$name entrou';
  }

  @override
  String get suggestTimeDawn => 'Madrugada';

  @override
  String get suggestTimeMorning => 'Bom dia';

  @override
  String get suggestTimeAfternoon => 'Boa tarde';

  @override
  String get suggestTimeEvening => 'Boa noite';

  @override
  String suggestModa1(String time) {
    return '$time de moda — what to wear?';
  }

  @override
  String get suggestModa2 => 'Look do dia ao vivo';

  @override
  String get suggestModa3 => 'Provador online — me ajuda a escolher';

  @override
  String suggestBeleza1(String time) {
    return '$time fazendo make ao vivo';
  }

  @override
  String get suggestBeleza2 => 'Skincare routine — bora juntos';

  @override
  String get suggestBeleza3 => 'Resenha de produto novo';

  @override
  String get suggestJogos1 => 'Bora jogar — quem entra?';

  @override
  String suggestJogos2(String time) {
    return 'Rank up live • $time';
  }

  @override
  String get suggestJogos3 => 'Aquecimento antes do ranqueada';

  @override
  String suggestMusica1(String time) {
    return '$time musical — pedidos abertos';
  }

  @override
  String get suggestMusica2 => 'Tocando ao vivo — chega aí';

  @override
  String get suggestMusica3 => 'Playlist + papo';

  @override
  String get suggestEsportes1 => 'Comentando o jogo ao vivo';

  @override
  String suggestEsportes2(String time) {
    return '$time esportiva — vamos comentar';
  }

  @override
  String get suggestEsportes3 => 'Treino + papo';

  @override
  String suggestComida1(String time) {
    return '$time na cozinha — bora cozinhar';
  }

  @override
  String get suggestComida2 => 'Receita ao vivo';

  @override
  String get suggestComida3 => 'Testando uma receita nova';

  @override
  String suggestGeneric1(String time) {
    return '$time com a galera';
  }

  @override
  String get suggestGeneric2 => 'Chega aí, vamos conversar';

  @override
  String get suggestGeneric3 => 'Live aberta — pode chegar';

  @override
  String get liveCommentsHint => 'Diga algo...';

  @override
  String get liveCommentsSending => '  Enviando...';

  @override
  String giftsSent(String name) {
    return 'Enviou $name!';
  }

  @override
  String get giftsTitle => 'Enviar um presente';

  @override
  String get giftsEmpty => 'Nenhum presente disponível';

  @override
  String get giftsSendButton => 'ENVIAR';

  @override
  String giftsError(String error) {
    return 'Erro ao carregar presentes: $error';
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
  String get liveFeedEmptyForYou => 'Nenhuma live no Para Você agora.';

  @override
  String get liveFeedEmptyAll => 'Nenhuma live ativa no momento.';

  @override
  String get liveFeedEmptyHint => 'Volte mais tarde ou puxe para atualizar.';

  @override
  String get liveFeedRefresh => 'Atualizar';

  @override
  String get liveFeedRetry => 'Tentar novamente';

  @override
  String liveFeedError(String error) {
    return 'Erro: $error';
  }

  @override
  String get liveFeedCategoryForYou => 'Para Você';

  @override
  String get liveFeedCategoryAll => 'Todas as Lives';

  @override
  String liveFeedShareMessage(String title, String url) {
    return 'Confira esta live no Brawe: $title\n$url';
  }

  @override
  String get liveFeedBadgeLive => 'AO VIVO';

  @override
  String liveFeedBadgeLiveWithCount(int count) {
    return 'AO VIVO $count';
  }

  @override
  String get liveFeedGift => 'Presente';

  @override
  String get liveFeedShare => 'Compartilhar';

  @override
  String get livePlayerInputHint => 'Diga algo legal...';

  @override
  String get livePlayerTooltipRose => 'Enviar rosa';

  @override
  String get livePlayerTooltipGifts => 'Presentes';

  @override
  String get livePlayerTooltipLike => 'Curtir';

  @override
  String get livePlayerTooltipSend => 'Enviar';

  @override
  String get livePlayerGiftSentVerb => ' enviou ';

  @override
  String get livePlayerShareTitle => 'Compartilhar com seguidores';

  @override
  String get livePlayerShareSubtitle => 'Envia esta live numa conversa';

  @override
  String get livePlayerReportTitle => 'Denunciar live';

  @override
  String get livePlayerReportSubtitle =>
      'Avisar nossa equipe sobre algo errado';

  @override
  String get livePlayerReportSubmitted => 'Denúncia registrada. Obrigado.';

  @override
  String get liveCurrentUser => 'Você';

  @override
  String get commonFollow => 'SEGUIR';

  @override
  String get liveBadgeLive => 'AO VIVO';

  @override
  String get homeSectionLiveBattles => 'BATALHAS DE LIVE STREAM';

  @override
  String get homeSectionTopStreamers => 'TOP STREAMERS';

  @override
  String get homeSectionCategories => 'CATEGORIAS';

  @override
  String get homeSectionStreamCard => 'CARTÃO DE STREAM';

  @override
  String get homeSectionLiveCommerce => 'LIVE COMMERCE SHOW';

  @override
  String get homeSectionRecentLives => 'Lives recentes';

  @override
  String get homeErrorLoadingStats => 'Erro ao carregar estatísticas';

  @override
  String get homeErrorLoadingLives => 'Erro ao carregar lives';

  @override
  String get homeEmptyPastLives => 'Nenhuma live anterior encontrada';

  @override
  String get homeEmptyStreamers => 'Nenhum streamer ainda';

  @override
  String get homeBattleWatchBet => 'ASSISTIR E APOSTAR';

  @override
  String get homeBattleLabel => 'Batalha PK';

  @override
  String get commonError => 'Erro';

  @override
  String get videoTooltipRepostStory => 'Repostar nos Stories';

  @override
  String get liveBattleTapToWatch => 'Toque para assistir ao vivo';

  @override
  String get liveBattleMysteryGift => 'Presente Misterioso';

  @override
  String get livePeekWatchLive => 'Assistir ao vivo';

  @override
  String get productSoldOut => 'Esgotado';

  @override
  String get productBuy => 'Comprar';

  @override
  String productLowStock(int count) {
    return 'Apenas $count restantes';
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
  String get emojiCatHearts => 'Coração';

  @override
  String get emojiCatAnimals => 'Animais';

  @override
  String get emojiCatFood => 'Comida';

  @override
  String get emojiCatParty => 'Festa';

  @override
  String get emojiCatObjects => 'Objetos';

  @override
  String get battleVs => 'VS';

  @override
  String get battleTimer => 'Tempo restante';

  @override
  String get battleSendGift => 'Enviar presente';

  @override
  String get battleSupport => 'Apoiar';

  @override
  String get battleWinner => 'Vencedor';

  @override
  String get battleDraw => 'Empate';

  @override
  String get battleEnded => 'Batalha encerrada';

  @override
  String get battleResultTitle => 'Resultado da batalha';

  @override
  String get battleResultShare => 'Compartilhar resultado';

  @override
  String get battleResultWatchAgain => 'Assistir outra batalha';

  @override
  String battleScoreLabel(String score) {
    return '$score pts';
  }

  @override
  String get battleTopSupporters => 'Top apoiadores';

  @override
  String battleYouScore(String score) {
    return 'Você: $score';
  }

  @override
  String battleRivalScore(String score) {
    return 'Rival: $score';
  }

  @override
  String battleCountdownStarting(int count) {
    return 'Começando em $count';
  }

  @override
  String battleInviteReceived(String name) {
    return '$name te desafiou para uma batalha!';
  }

  @override
  String get battleAccept => 'Aceitar';

  @override
  String get battleDecline => 'Recusar';

  @override
  String get battleLoading => 'Carregando batalha...';

  @override
  String get battleError => 'Erro ao carregar batalha';

  @override
  String battleGiftReceived(String sender, String gift) {
    return '$sender enviou $gift';
  }
}
