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
  String get settingsThemeAuto => 'Automático';

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
  String get signupTermsSuffix => ' da Brawe.';

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
  String get liveStoryBattleBadge => 'BATALHA';

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
  String get postAddPoll => 'Enquete';

  @override
  String get postAddLocation => 'Localização';

  @override
  String get pollEditorTitle => 'Enquete';

  @override
  String pollOptionHint(int n) {
    return 'Opção $n';
  }

  @override
  String get pollAddOption => 'Adicionar opção';

  @override
  String get pollRemoveOption => 'Remover opção';

  @override
  String get pollRemove => 'Remover enquete';

  @override
  String get pollDurationLabel => 'Duração';

  @override
  String pollDurationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get pollRulesHint =>
      'Todas as opções são obrigatórias: de 2 a 4, até 60 caracteres, sem repetir. O voto não pode ser alterado.';

  @override
  String get pollErrorEmpty => 'Preencha esta opção';

  @override
  String get pollErrorDuplicate => 'Opção repetida';

  @override
  String get pollNeedsQuestion => 'Escreva a pergunta no texto do post';

  @override
  String get pollBlockedByImage =>
      'Enquete e foto não podem ser usadas juntas. Remova a foto para criar uma enquete.';

  @override
  String get imageBlockedByPoll =>
      'Enquete e foto não podem ser usadas juntas. Remova a enquete para anexar uma foto.';

  @override
  String pollVotesCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String pollEndsInDays(int count) {
    return 'termina em $count d';
  }

  @override
  String pollEndsInHours(int count) {
    return 'termina em $count h';
  }

  @override
  String pollEndsInMinutes(int count) {
    return 'termina em $count min';
  }

  @override
  String get pollEnded => 'Encerrada';

  @override
  String get pollVoteToSee => 'Vote para ver os resultados';

  @override
  String get pollVoteError =>
      'Não foi possível registrar seu voto. Tente de novo.';

  @override
  String get pollAlreadyVoted => 'Você já votou nesta enquete.';

  @override
  String get pollEndedMessage => 'Esta enquete já foi encerrada.';

  @override
  String get pollMyVoteSemantics => 'Seu voto';

  @override
  String get postLocationRemove => 'Remover localização';

  @override
  String get postLocationLoading => 'Obtendo sua cidade...';

  @override
  String get postLocationDenied =>
      'Sem permissão de localização. Libere nos Ajustes para marcar sua cidade.';

  @override
  String get postLocationServiceOff =>
      'A localização do aparelho está desligada.';

  @override
  String get postLocationFailed => 'Não foi possível descobrir sua cidade.';

  @override
  String get postLocationOpenSettings => 'Abrir Ajustes';

  @override
  String get audiencePickerTitle => 'Quem pode ver?';

  @override
  String get audienceAll => 'Todos';

  @override
  String get audienceFollowers => 'Seguidores';

  @override
  String get audienceOnlyMe => 'Apenas eu';

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
  String get videoCaptionHint => 'Escreva uma legenda…';

  @override
  String get videoPublishButton => 'Publicar vídeo';

  @override
  String get videoSelect => 'Selecionar vídeo';

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
  String get shareOutsideBrawe => 'Fora da Brawe';

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
  String get composerPublishTimeoutMaybe =>
      'Conexão lenta — verifique seu feed; se o story já estiver lá, está publicado.';

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
  String get composerYourStory => 'Seu story';

  @override
  String get composerShare => 'Compartilhar';

  @override
  String get composerTapOutsideHint => 'Toque fora para concluir';

  @override
  String get composerTextHint => 'Digite algo...';

  @override
  String get composerGuideTop => 'topo seguro';

  @override
  String get composerGuideBottom => 'base segura';

  @override
  String get composerSaveToDevice => 'Salvar no dispositivo';

  @override
  String get composerSavedToDevice => 'Salvo na galeria';

  @override
  String get composerSavePermissionDenied =>
      'Permissão de acesso à galeria negada.';

  @override
  String get composerSaveError => 'Não foi possível salvar.';

  @override
  String get trimTitle => 'Cortar vídeo';

  @override
  String get trimSave => 'Concluir';

  @override
  String get trimCancel => 'Cancelar';

  @override
  String get trimProcessing => 'Salvando…';

  @override
  String trimDuration(String seconds) {
    return '${seconds}s';
  }

  @override
  String get trimError => 'Não foi possível salvar o vídeo cortado.';

  @override
  String get trimHint => 'Arraste as alças para escolher início e fim';

  @override
  String get volumeMixerButtonLabel => 'Volumes';

  @override
  String get volumeMixerTitle => 'Volumes';

  @override
  String get volumeMixerSubtitle =>
      'Ajuste o volume da música e do áudio original do vídeo';

  @override
  String get volumeMixerMusicLabel => 'Música';

  @override
  String get volumeMixerOriginalLabel => 'Áudio original do vídeo';

  @override
  String get volumeMixerDone => 'Concluir';

  @override
  String get giftTierFree => 'Cofre';

  @override
  String get giftTierBasic => 'Básico';

  @override
  String get giftTierPremium => 'Premium';

  @override
  String get giftTierLuxury => 'Luxo';

  @override
  String get giftTierLegendary => 'Lendário';

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
  String get feedReposted => 'Repostado para seus seguidores';

  @override
  String get shareToFollowers => 'Enviar para seguidores';

  @override
  String feedRepostBanner(String name) {
    return '$name repostou';
  }

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
  String get profileSellerVerified => 'Parceiro verificado';

  @override
  String get profileSellerSubtitle => 'Produtos selecionados com curadoria';

  @override
  String shopVitrinePartnerItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

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
  String get profileShowcaseEmptyTitleMe => 'Sua vitrine está vazia';

  @override
  String get profileShowcaseEmptyTitleOther => 'Nenhum produto ainda';

  @override
  String get profileShowcaseEmptySubtitleMe =>
      'Torne-se parceiro de marcas e mostre os produtos que você recomenda na sua vitrine.';

  @override
  String get profileShowcaseEmptySubtitleOther =>
      'Este criador ainda não adicionou produtos à vitrine.';

  @override
  String get profileShowcaseJoinCreatorNetwork => 'Aderir ao Creator Network';

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
  String get walletTitle => 'Moedas Brawe';

  @override
  String get walletAvailableBalance => 'Saldo de moedas';

  @override
  String get walletCoins => 'moedas';

  @override
  String get walletSectionBuyTitle => 'Comprar moedas';

  @override
  String get walletSectionBuySubtitle =>
      'Use moedas para enviar presentes virtuais aos criadores nas lives';

  @override
  String get walletSectionHistoryTitle => 'Histórico de presentes';

  @override
  String get walletSectionHistorySubtitle =>
      'Presentes enviados e recebidos em lives';

  @override
  String get giftersTabReceived => 'Recebidos';

  @override
  String get giftersTabSent => 'Enviados';

  @override
  String get giftersEmptyReceivedTitle => 'Ainda ninguém te presenteou';

  @override
  String get giftersEmptyReceivedBody =>
      'Quando alguém te enviar gifts nas lives, eles vão aparecer agrupados por pessoa aqui.';

  @override
  String get giftersEmptySentTitle => 'Você ainda não enviou gifts';

  @override
  String get giftersEmptySentBody =>
      'Os criadores que você apoiar nas lives vão aparecer agrupados aqui.';

  @override
  String giftersInLives(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lives',
      one: '1 live',
    );
    return '$_temp0';
  }

  @override
  String giftersGiftsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n presentes',
      one: '1 presente',
    );
    return '$_temp0';
  }

  @override
  String get giftersActionThank => 'Agradecer';

  @override
  String get giftersActionMessage => 'Mensagem';

  @override
  String get giftersActionFollow => 'Seguir';

  @override
  String get giftersActionFollowing => 'Seguindo';

  @override
  String get giftersDetailTotalReceived => 'Total recebido';

  @override
  String get giftersDetailTotalSent => 'Total enviado';

  @override
  String get giftersDetailGiftsTitle => 'Presentes';

  @override
  String get giftersBadgeFollowsYou => 'Te segue';

  @override
  String get giftersLoadError => 'Não foi possível carregar';

  @override
  String get giftersFollowError => 'Erro ao seguir. Tente novamente.';

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
  String get walletInfoQuestsTitle => 'Missões diárias';

  @override
  String get walletInfoQuestsBody =>
      'Complete missões e ganhe moedas + XP todos os dias.';

  @override
  String get walletInfoGiftsTitle => 'Receba presentes';

  @override
  String get walletInfoGiftsBody =>
      'Seus seguidores podem enviar presentes virtuais durante suas lives.';

  @override
  String get walletInfoUseTitle => 'Envie presentes';

  @override
  String get walletInfoUseBody =>
      'Use moedas para enviar presentes virtuais aos criadores favoritos.';

  @override
  String get walletLoadError => 'Não consegui carregar suas moedas.';

  @override
  String get walletTryAgain => 'Tentar novamente';

  @override
  String get walletActionAdd => 'Adicionar';

  @override
  String get walletActionSend => 'Enviar presente';

  @override
  String get walletActionStatement => 'Histórico';

  @override
  String get walletComingSoon => 'Em breve.';

  @override
  String get walletTxLoadError => 'Não foi possível carregar o histórico.';

  @override
  String get walletTxEmpty => 'Sem presentes ainda.';

  @override
  String get walletTxTo => 'Para';

  @override
  String get walletTxFrom => 'De';

  @override
  String get walletIapInfo =>
      'Compra processada pela loja oficial (Google Play / App Store). As moedas são creditadas automaticamente após o pagamento. Moedas são itens virtuais não-resgatáveis usados apenas para enviar presentes em lives.';

  @override
  String walletIapBuyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get walletIapProcessing => 'Processando…';

  @override
  String get walletIapUnavailable => 'Indisponível';

  @override
  String get walletIapPackageUnavailable =>
      'Pacote indisponível na loja. Tente novamente em breve.';

  @override
  String get walletIapNotSupported => 'Plataforma não suporta compras no app.';

  @override
  String get walletIapStoreUnavailable =>
      'Compras no app indisponíveis neste dispositivo. Verifique se sua conta Google/Apple está configurada.';

  @override
  String get walletIapPaymentPending =>
      'Pagamento em processamento. Você receberá as moedas assim que for confirmado pela loja.';

  @override
  String get walletIapPaymentError =>
      'Falha ao processar a compra. Tente novamente.';

  @override
  String walletIapSuccess(String coins) {
    return 'Moedas creditadas com sucesso! (+$coins)';
  }

  @override
  String get earningsTitle => 'Recompensas de Criador';

  @override
  String get earningsCurrency => 'Moeda de exibição';

  @override
  String get earningsCoinsBalance => 'Moedas disponíveis';

  @override
  String get earningsDiamondsBalance => 'Diamantes do Programa de Criador';

  @override
  String get earningsDiamonds => 'diamantes';

  @override
  String get earningsTotalSpent => 'Moedas gastas em presentes';

  @override
  String get earningsTotalEarned => 'Diamantes recebidos de presentes';

  @override
  String get earningsAccountNumber => 'Brawe ID';

  @override
  String get earningsPurchaseHistoryTitle => 'Histórico de compras';

  @override
  String get earningsPurchaseHistorySubtitle =>
      'Compras de moedas via App Store / Google Play';

  @override
  String get earningsGiftHistoryTitle => 'Presentes recebidos';

  @override
  String get earningsGiftHistorySubtitle =>
      'Origem dos seus diamantes do Programa de Criador';

  @override
  String get earningsNoPurchases => 'Você ainda não comprou moedas.';

  @override
  String get earningsNoGifts => 'Você ainda não recebeu presentes.';

  @override
  String get earningsLoadError => 'Não foi possível carregar suas recompensas.';

  @override
  String get earningsStatusCompleted => 'Concluído';

  @override
  String get earningsStatusPending => 'Pendente';

  @override
  String get earningsStatusFailed => 'Falhou';

  @override
  String get earningsStatusRefunded => 'Estornado';

  @override
  String get earningsDisclaimerTitle => 'Sobre Moedas e Diamantes';

  @override
  String get earningsDisclaimerBody =>
      'Moedas Brawe e Diamantes são itens virtuais não-resgatáveis usados exclusivamente para enviar presentes em lives. Não constituem investimento, valor mobiliário ou moeda eletrônica. Valores em USD/BRL/EUR são meramente informativos e não representam direito a saque ou conversão em dinheiro.';

  @override
  String get earningsReferenceValueOnly => 'Valor de referência';

  @override
  String get postDetailTitle => 'Publicação';

  @override
  String get postDetailNotFound =>
      'Não conseguimos carregar esta publicação. Talvez ela tenha sido removida.';

  @override
  String get postDetailGoHome => 'Ir para Início';

  @override
  String get postLikersTitle => 'Curtidas';

  @override
  String get postLikersEmpty => 'Ainda ninguém curtiu esta publicação.';

  @override
  String get postLikersLoadError => 'Não foi possível carregar as curtidas.';

  @override
  String postLikersTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curtidas',
      one: '1 curtida',
      zero: 'Nenhuma curtida',
    );
    return '$_temp0';
  }

  @override
  String get reactionLike => 'Curtir';

  @override
  String get reactionLove => 'Amei';

  @override
  String get reactionFire => 'Top';

  @override
  String get reactionLaugh => 'Haha';

  @override
  String get reactionWow => 'Uau';

  @override
  String get reactionSad => 'Triste';

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
  String get liveSummaryTitle => 'Resumo da live';

  @override
  String get liveSummaryDuration => 'Duração';

  @override
  String get liveSummaryPeakViewers => 'Pico de audiência';

  @override
  String get liveSummaryTotalViewers => 'Espectadores únicos';

  @override
  String get liveSummaryGiftsValue => 'Presentes recebidos';

  @override
  String get liveSummaryMysteryGifts => 'Presentes misteriosos revelados';

  @override
  String get liveSummaryDone => 'Concluir';

  @override
  String get liveSummaryUnavailable =>
      'Sua live foi encerrada. Não foi possível carregar o resumo completo agora.';

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
    return 'Confira esta live na Brawe: $title\n$url';
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
  String get battleTopSupporters => 'Top apoiadores';

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
  String get battleMomentum => 'PEGANDO FOGO';

  @override
  String get battleLeadChange => 'VIROU!';

  @override
  String get battleFinalStretch => 'RETA FINAL';

  @override
  String get sharedPostReactionApplied => 'Reação enviada ✨';

  @override
  String sharedPostMinutesAgo(int count) {
    return 'há $count min';
  }

  @override
  String sharedPostHoursAgo(int count) {
    return 'há $count h';
  }

  @override
  String sharedPostDaysAgo(int count) {
    return 'há $count d';
  }

  @override
  String get topUpTitle => 'Recarregar coins';

  @override
  String get topUpSubtitle => 'Compre direto pela loja do seu celular';

  @override
  String get topUpReasonGift => 'Saldo insuficiente para este presente';

  @override
  String get topUpReasonBattle => 'Continue na batalha! Recarregue agora';

  @override
  String get topUpStoreDisclaimer =>
      'Pagamento seguro via Play Store / App Store';

  @override
  String get topUpStoreDisclaimerApple => 'Pagamento seguro pela App Store';

  @override
  String get topUpStoreDisclaimerGoogle => 'Pagamento seguro pelo Google Play';

  @override
  String get earningsNoPurchasesHint =>
      'Quando você comprar coins pela App Store ou Google Play elas aparecerão aqui.';

  @override
  String get earningsNoGiftsHint =>
      'Os diamantes do Creator Program vêm dos gifts que você recebe em lives.';

  @override
  String get creatorProgramTitle => 'Brawe Creator Network';

  @override
  String get creatorProgramSubtitle =>
      'Cresça sua audiência. Construa sua comunidade. Faça parte da Brawe.';

  @override
  String get creatorProgramDescription =>
      'A Rede de Criadores Brawe é o programa oficial para criadores que querem crescer, ganhar visibilidade e construir uma comunidade dentro da Brawe.';

  @override
  String get creatorActionApplyNow => 'Quero me inscrever';

  @override
  String get creatorActionViewLevels => 'Ver níveis de creator';

  @override
  String get creatorActionCheckStatus => 'Acompanhar inscrição';

  @override
  String get creatorBenefitsHeader => 'O que você ganha';

  @override
  String get creatorBenefit1 => 'Seja descoberto por novas audiências';

  @override
  String get creatorBenefit2 => 'Construa sua identidade de creator';

  @override
  String get creatorBenefit3 => 'Desbloqueie badges oficiais';

  @override
  String get creatorBenefit4 => 'Cresça com lives e conteúdo';

  @override
  String get creatorBenefit5 => 'Faça parte de uma comunidade premium';

  @override
  String creatorTotalCreators(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n creators na rede',
      one: '1 creator na rede',
    );
    return '$_temp0';
  }

  @override
  String get creatorLevelsTitle => 'Níveis de Creator';

  @override
  String get creatorLevelsSubtitle =>
      'Cada nível representa um momento da sua jornada.';

  @override
  String get creatorTierRisingTitle => 'Rising Creator';

  @override
  String get creatorTierRisingBody =>
      'Para creators em crescimento que querem oportunidade real de alcance.';

  @override
  String get creatorTierFeaturedTitle => 'Featured Creator';

  @override
  String get creatorTierFeaturedBody =>
      'Para creators ativos com conteúdo consistente e potencial editorial.';

  @override
  String get creatorTierLiveTitle => 'Live Creator';

  @override
  String get creatorTierLiveBody =>
      'Para streamers, hosts e creators focados em lives e batalhas.';

  @override
  String get creatorTierAmbassadorTitle => 'Ambassador';

  @override
  String get creatorTierAmbassadorBody =>
      'Para creators reconhecidos que representam a visão da Brawe.';

  @override
  String get creatorTierFoundingTitle => 'Founding Creator';

  @override
  String get creatorTierFoundingBody =>
      'Para creators selecionados que ajudam a moldar o futuro da Brawe.';

  @override
  String get creatorTierApplyCta => 'Inscrever-se como creator';

  @override
  String get creatorFormTitle => 'Inscrever-se na Rede';

  @override
  String get creatorFormSubtitle =>
      'Conte mais sobre sua jornada como creator.';

  @override
  String get creatorFormDescription =>
      'Analisamos cada inscrição com cuidado para entender seu conteúdo, objetivos e potencial dentro da Brawe.';

  @override
  String get creatorFormSectionIdentity => 'Identidade';

  @override
  String get creatorFormSectionContent => 'Conteúdo';

  @override
  String get creatorFormSectionSocial => 'Redes sociais';

  @override
  String get creatorFormSectionAbout => 'Sobre você';

  @override
  String get creatorFormFullName => 'Nome completo';

  @override
  String get creatorFormUsername => 'Username';

  @override
  String get creatorFormEmail => 'E-mail';

  @override
  String get creatorFormPhone => 'Telefone';

  @override
  String get creatorFormCountry => 'País';

  @override
  String get creatorFormCity => 'Cidade';

  @override
  String get creatorFormLanguage => 'Idioma principal';

  @override
  String get creatorFormNiche => 'Nicho de conteúdo';

  @override
  String get creatorFormNichePlaceholder =>
      'Ex: lifestyle, música, games, educação...';

  @override
  String get creatorFormCategory => 'Categoria de creator';

  @override
  String get creatorFormSocialLinks => 'Links de redes sociais';

  @override
  String get creatorFormSocialPlaceholder =>
      'Cole seu Instagram, TikTok, YouTube...';

  @override
  String get creatorFormFollowers => 'Seguidores aproximados';

  @override
  String get creatorFormDoesLive => 'Você faz lives atualmente?';

  @override
  String get creatorFormBio => 'Conte sua história';

  @override
  String get creatorFormBioPlaceholder => 'Conte quem é você como creator';

  @override
  String get creatorFormMotivation => 'Sua motivação';

  @override
  String get creatorFormMotivationPlaceholder =>
      'Por que quer crescer com a Brawe?';

  @override
  String get creatorFormGoals => 'Seus objetivos';

  @override
  String get creatorFormGoalsPlaceholder => 'O que quer alcançar como creator?';

  @override
  String get creatorFormPortfolio => 'Portfólio (opcional)';

  @override
  String get creatorFormSubmit => 'Enviar inscrição';

  @override
  String get creatorFormSaveDraft => 'Salvar rascunho';

  @override
  String get creatorFormCancel => 'Cancelar';

  @override
  String get creatorFormTermsPrefix => 'Li e aceito os ';

  @override
  String get creatorFormTermsLink => 'Termos do Brawe Creator Network';

  @override
  String get creatorFormTermsSuffix => '.';

  @override
  String get creatorFormTermsMustAccept =>
      'Você precisa aceitar os Termos para se inscrever.';

  @override
  String get creatorFormTermsOpen => 'Abrir Termos';

  @override
  String get creatorFormTermsClose => 'Fechar';

  @override
  String creatorFormTermsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get creatorFormValidationRequired => 'Campo obrigatório';

  @override
  String get creatorFormValidationEmail => 'E-mail inválido';

  @override
  String get creatorFormValidationSocial =>
      'Adicione pelo menos uma rede social';

  @override
  String get creatorFormSubmitting => 'Enviando sua inscrição...';

  @override
  String get creatorFormSuccess => 'Inscrição enviada com sucesso.';

  @override
  String get creatorFormError =>
      'Não foi possível enviar sua inscrição. Tente novamente.';

  @override
  String get creatorFormAlreadyExists => 'Você já tem uma inscrição ativa.';

  @override
  String get creatorSubmittedTitle => 'Inscrição enviada';

  @override
  String get creatorSubmittedBody =>
      'Obrigado por se inscrever na Brawe Creator Network. Nossa equipe vai revisar seu perfil e avisaremos quando houver atualização.';

  @override
  String get creatorSubmittedStep1 => 'Sua inscrição está aguardando revisão.';

  @override
  String get creatorSubmittedStep2 =>
      'Podemos pedir mais informações se necessário.';

  @override
  String get creatorSubmittedStep3 =>
      'Você pode acompanhar o status quando quiser.';

  @override
  String get creatorSubmittedTrack => 'Acompanhar inscrição';

  @override
  String get creatorSubmittedHome => 'Voltar pro Início';

  @override
  String get creatorStatusPendingTitle => 'Inscrição recebida';

  @override
  String get creatorStatusPendingBody =>
      'Sua inscrição foi recebida e está aguardando revisão.';

  @override
  String get creatorStatusAnalysisTitle => 'Em análise';

  @override
  String get creatorStatusAnalysisBody =>
      'Nossa equipe está revisando seu perfil de creator.';

  @override
  String get creatorStatusApprovedTitle => 'Você foi aprovado!';

  @override
  String get creatorStatusApprovedBody =>
      'Parabéns! Você agora faz parte da Brawe Creator Network.';

  @override
  String get creatorStatusRejectedTitle => 'Inscrição não aprovada';

  @override
  String get creatorStatusRejectedBody =>
      'Sua inscrição não foi aprovada neste momento. Você pode melhorar seu perfil e tentar novamente mais tarde.';

  @override
  String get creatorStatusWaitlistTitle => 'Você está na waitlist';

  @override
  String get creatorStatusWaitlistBody =>
      'Seu perfil tem potencial e podemos convidá-lo em breve.';

  @override
  String get creatorStatusNeedsInfoTitle => 'Precisamos de mais informações';

  @override
  String get creatorStatusNeedsInfoBody =>
      'Atualize sua inscrição com os detalhes solicitados.';

  @override
  String get creatorStatusInvitedAmbassadorTitle => 'Convite Ambassador';

  @override
  String get creatorStatusInvitedAmbassadorBody =>
      'Você foi convidado para o programa Brawe Ambassadors.';

  @override
  String get creatorStatusInvitedFoundingTitle => 'Convite Founding Creator';

  @override
  String get creatorStatusInvitedFoundingBody =>
      'Você foi convidado para ser Brawe Founding Creator.';

  @override
  String get creatorStatusUpdateApplication => 'Atualizar inscrição';

  @override
  String get creatorStatusContinue => 'Continuar';

  @override
  String get creatorStatusStartOnboarding => 'Começar onboarding';

  @override
  String get creatorOnboardingTitle => 'Bem-vindo à Brawe Creator Network';

  @override
  String get creatorOnboardingSubtitle =>
      'Vamos configurar sua presença e ajudar pessoas a descobrirem seu conteúdo.';

  @override
  String get creatorOnboardingStart => 'Começar setup';

  @override
  String get creatorOnboardingSkip => 'Pular por enquanto';

  @override
  String creatorOnboardingProgress(int done, int total) {
    return '$done de $total concluído';
  }

  @override
  String get creatorProfileTitle => 'Perfil de Creator';

  @override
  String get creatorProfileSubtitle =>
      'Personalize como você aparece como creator.';

  @override
  String get creatorProfileFieldDisplayName => 'Nome público';

  @override
  String get creatorProfileFieldBio => 'Bio de creator';

  @override
  String get creatorProfileFieldCategory => 'Categoria de conteúdo';

  @override
  String get creatorProfileFieldSocial => 'Links públicos';

  @override
  String get creatorProfileFieldBadgeVisibility => 'Mostrar badge no perfil';

  @override
  String get creatorProfileSave => 'Salvar alterações';

  @override
  String get creatorProfilePreview => 'Visualizar perfil';

  @override
  String get creatorProfileSaved => 'Perfil de creator atualizado.';

  @override
  String get creatorProfileSaveError =>
      'Não foi possível atualizar o perfil de creator.';

  @override
  String get creatorBadgeScreenTitle => 'Seu Badge de Creator';

  @override
  String get creatorBadgeScreenSubtitle =>
      'Seu badge ajuda as pessoas a reconhecerem seu papel dentro da Brawe Creator Network.';

  @override
  String get creatorBadgeLocked => 'Bloqueado';

  @override
  String get creatorBadgeUnlocked => 'Desbloqueado';

  @override
  String get creatorBadgeViewBenefits => 'Ver benefícios';

  @override
  String get creatorBadgeBack => 'Voltar';

  @override
  String get creatorDashboardTitle => 'Painel do Creator';

  @override
  String get creatorDashboardSubtitle =>
      'Acompanhe seu crescimento e gerencie sua presença.';

  @override
  String get creatorDashboardCardViews => 'Visualizações de perfil';

  @override
  String get creatorDashboardCardFollowers => 'Crescimento de seguidores';

  @override
  String get creatorDashboardCardReach => 'Alcance de conteúdo';

  @override
  String get creatorDashboardCardLives => 'Atividade em lives';

  @override
  String get creatorDashboardCardStatus => 'Status de creator';

  @override
  String get creatorDashboardQuickCreatePost => 'Criar post';

  @override
  String get creatorDashboardQuickGoLive => 'Entrar ao vivo';

  @override
  String get creatorDashboardQuickEditProfile => 'Editar perfil';

  @override
  String get creatorDashboardQuickViewBadge => 'Ver badge';

  @override
  String get creatorDashboardQuickInsights => 'Ver insights';

  @override
  String get adminCreatorAppsTitle => 'Inscrições de Creators';

  @override
  String get adminCreatorAppsFilterAll => 'Todos';

  @override
  String get adminCreatorAppsFilterPending => 'Pendentes';

  @override
  String get adminCreatorAppsFilterAnalysis => 'Em análise';

  @override
  String get adminCreatorAppsFilterApproved => 'Aprovados';

  @override
  String get adminCreatorAppsFilterRejected => 'Rejeitados';

  @override
  String get adminCreatorAppsFilterWaitlist => 'Waitlist';

  @override
  String get adminCreatorAppsFilterNeedsInfo => 'Precisa info';

  @override
  String get adminCreatorAppsReview => 'Revisar';

  @override
  String get adminCreatorAppsFilter => 'Filtros';

  @override
  String get adminCreatorAppsExport => 'Exportar';

  @override
  String get adminCreatorAppsSearchHint => 'Buscar nome, username ou e-mail';

  @override
  String get adminCreatorAppsEmpty => 'Nenhuma inscrição encontrada.';

  @override
  String get adminCreatorAppsLoadError => 'Erro ao carregar inscrições.';

  @override
  String get adminCreatorAppDetailTitle => 'Análise da Inscrição';

  @override
  String get adminCreatorSectionInfo => 'Informações do creator';

  @override
  String get adminCreatorSectionSocial => 'Redes sociais';

  @override
  String get adminCreatorSectionNiche => 'Nicho de conteúdo';

  @override
  String get adminCreatorSectionMotivation => 'Motivação';

  @override
  String get adminCreatorSectionGoals => 'Objetivos';

  @override
  String get adminCreatorSectionNotes => 'Notas internas';

  @override
  String get adminCreatorSectionSuggestedTier => 'Tier sugerido';

  @override
  String get adminCreatorActionApprove => 'Aprovar';

  @override
  String get adminCreatorActionReject => 'Rejeitar';

  @override
  String get adminCreatorActionWaitlist => 'Mover para waitlist';

  @override
  String get adminCreatorActionRequestInfo => 'Pedir mais informações';

  @override
  String get adminCreatorActionInviteAmbassador => 'Convidar como Ambassador';

  @override
  String get adminCreatorActionInviteFounding =>
      'Convidar como Founding Creator';

  @override
  String get adminCreatorActionSaveNotes => 'Salvar notas';

  @override
  String get adminCreatorConfirmApprove =>
      'Tem certeza que quer aprovar este creator?';

  @override
  String get adminCreatorConfirmReject =>
      'Tem certeza que quer rejeitar esta inscrição?';

  @override
  String get adminCreatorConfirmRequestInfo =>
      'Diga ao creator quais informações estão faltando.';

  @override
  String get adminCreatorReviewSuccess => 'Decisão registrada.';

  @override
  String get adminCreatorReviewError => 'Não foi possível registrar a decisão.';

  @override
  String get adminCreatorsTitle => 'Gerenciar Creators';

  @override
  String get adminCreatorsFilterAll => 'Todos os creators';

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
  String get adminCreatorsActionEdit => 'Editar creator';

  @override
  String get adminCreatorsActionChangeBadge => 'Mudar badge';

  @override
  String get adminCreatorsActionFeature => 'Destacar';

  @override
  String get adminCreatorsActionDisable => 'Desativar';

  @override
  String get creatorTimelineTitle => 'Linha do tempo';

  @override
  String get creatorTimelineSubmitted => 'Inscrição enviada';

  @override
  String get creatorTimelineUnderReview => 'Em análise';

  @override
  String get creatorTimelineFinalDecision => 'Decisão final';

  @override
  String get creatorTimelineResult => 'Resultado';

  @override
  String get creatorYourApplication => 'Sua inscrição';

  @override
  String get creatorInfoName => 'Nome';

  @override
  String get creatorInfoUsername => 'Username';

  @override
  String get creatorInfoCountry => 'País';

  @override
  String get creatorInfoNiche => 'Nicho';

  @override
  String get creatorInfoRequestedTier => 'Tier solicitado';

  @override
  String get creatorInfoFollowers => 'Seguidores';

  @override
  String get creatorInfoDoesLive => 'Faz lives';

  @override
  String get creatorQuickShortcuts => 'Atalhos rápidos';

  @override
  String get creatorBadgeActive => 'ATIVO';

  @override
  String get commonYes => 'Sim';

  @override
  String get commonNo => 'Não';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get editProfileAccountTypeSection => 'TIPO DE CONTA';

  @override
  String get editProfileAccountTypeCreator => 'Criador';

  @override
  String get editProfileAccountTypeMusician => 'Músico';

  @override
  String get editProfileAccountTypeBusiness => 'Empresa';

  @override
  String get editProfileMusicianBannerHint =>
      'Crie seu perfil de artista no Brawe Sounds e apareça no catálogo.';

  @override
  String get editProfileMusicianArtistName => 'Nome artístico';

  @override
  String get editProfileMusicianArtistNameHint =>
      'Como aparece no Brawe Sounds';

  @override
  String get editProfileMusicianCity => 'Cidade';

  @override
  String get editProfileMusicianCityHint => 'Ex: São Paulo, SP';

  @override
  String get editProfileMusicianSpotify => 'Spotify';

  @override
  String get editProfileMusicianAppleMusic => 'Apple Music';

  @override
  String get editProfileMusicianGenres => 'GÊNEROS';

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
  String get soundsGenreElectro => 'Eletrônico';

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
      other: '$count faixas',
      one: '1 faixa',
    );
    return '$_temp0';
  }

  @override
  String soundsArtistPlays(Object count) {
    return '$count plays';
  }

  @override
  String get soundsTitle => 'Brawe Sounds';

  @override
  String get soundsSubtitle => 'Descubra trilhas incríveis';

  @override
  String get soundsTabTrending => 'Em alta';

  @override
  String get soundsTabCatalog => 'Catálogo';

  @override
  String get soundsSearch => 'Buscar músicas ou artistas...';

  @override
  String get soundsGenreAll => 'Todos';

  @override
  String get soundsEmptyTrending => 'Nenhuma música em alta ainda';

  @override
  String get soundsEmptyCatalog => 'Nenhuma música encontrada';

  @override
  String soundsEmptySearch(String query) {
    return 'Sem resultados para \"$query\"';
  }

  @override
  String get soundsLoadMore => 'Carregar mais';

  @override
  String soundsUsedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'usado $count vezes',
      one: 'usado 1 vez',
    );
    return '$_temp0';
  }

  @override
  String get soundsSaved => 'Salvo';

  @override
  String get soundsSave => 'Salvar';

  @override
  String get soundsUse => 'Usar';

  @override
  String get soundsPlayerLoading => 'Carregando...';

  @override
  String get soundsPlayerError => 'Erro ao carregar áudio';

  @override
  String get navSounds => 'Sounds';

  @override
  String get createSoundsTitle => 'Sounds';

  @override
  String get createSoundsSubtitle => 'Adicione uma música original ao seu post';

  @override
  String postSoundLabel(String title) {
    return 'Som: $title';
  }

  @override
  String get postSoundRemove => 'Remover som';

  @override
  String get contentSoundOriginalAudio => 'Áudio original';

  @override
  String get contentSoundUseThis => 'Usar esta música';

  @override
  String get contentSoundUnavailable => 'Música indisponível';

  @override
  String get contentSoundView => 'Ver música';

  @override
  String get contentSoundNowPlaying => 'Tocando agora';

  @override
  String contentSoundByArtist(String title, String artist) {
    return '$title · $artist';
  }

  @override
  String get soundTrimTitle => 'Cortar música';

  @override
  String get soundTrimSave => 'Concluir';

  @override
  String get soundTrimCancel => 'Cancelar';

  @override
  String get soundTrimHint =>
      'Arraste as alças para escolher o trecho da música';

  @override
  String soundTrimMaxDuration(int seconds) {
    return 'Máximo de ${seconds}s para este conteúdo';
  }

  @override
  String soundTrimSelectedDuration(int seconds) {
    return '${seconds}s selecionados';
  }

  @override
  String get soundTrimError =>
      'Não foi possível processar o trecho selecionado.';

  @override
  String get soundVolumeLabel => 'Volume da música';

  @override
  String get originalAudioVolumeLabel => 'Volume do áudio original';

  @override
  String get analyticsViewersTitle => 'Audiência';

  @override
  String get analyticsViewersTotalViewers => 'Total de viewers';

  @override
  String get analyticsViewersAvgPerLive => 'Média/live';

  @override
  String get analyticsViewersChartTitle => 'Visualizações por dia';

  @override
  String get analyticsViewersLegendViewers => 'Viewers';

  @override
  String get analyticsViewersLegendPeak => 'Pico';

  @override
  String get analyticsViewersBestDays => 'Melhores dias';

  @override
  String get analyticsViewersNoData => 'Sem dados';

  @override
  String get analyticsViewersUnit => ' viewers';

  @override
  String get analyticsFollowersTitle => 'Seguidores';

  @override
  String get analyticsFollowersCount => 'Seguidores';

  @override
  String get analyticsFollowersFollowing => 'Seguindo';

  @override
  String get analyticsFollowersTrendTitle => 'Tendência de engajamento';

  @override
  String get analyticsFollowersTrendSubtitle =>
      'Audiência das lives — correlação direta com crescimento';

  @override
  String get analyticsFollowersLegendEngagement => 'Engajamento';

  @override
  String get analyticsFollowersSummaryTitle => 'Resumo da conta';

  @override
  String get analyticsFollowersSummaryFollowers => 'Seguidores';

  @override
  String get analyticsFollowersSummaryFollowing => 'Seguindo';

  @override
  String get analyticsFollowersSummaryLives => 'Lives realizadas';

  @override
  String get analyticsFollowersSummaryRatio => 'Taxa seguidor/live';

  @override
  String get analyticsFollowersTipsTitle => 'Dicas para crescer';

  @override
  String get analyticsFollowersTip1Title => 'Faça lives regularmente';

  @override
  String get analyticsFollowersTip1Subtitle =>
      'Consistência aumenta seguidores em +40%';

  @override
  String get analyticsFollowersTip2Title => 'Interaja com a audiência';

  @override
  String get analyticsFollowersTip2Subtitle =>
      'Responder comentários aumenta retenção';

  @override
  String get analyticsFollowersTip3Title => 'Compartilhe seus conteúdos';

  @override
  String get analyticsFollowersTip3Subtitle =>
      'Stories e posts aumentam o alcance';

  @override
  String get analyticsLivesTitle => 'Histórico de Lives';

  @override
  String get analyticsLivesErrorLoad => 'Erro ao carregar lives';

  @override
  String get analyticsLivesRetry => 'Tentar novamente';

  @override
  String get analyticsLivesKpiTotal => 'Lives';

  @override
  String get analyticsLivesKpiAvgViewers => 'Viewers méd.';

  @override
  String get analyticsLivesKpiGifts => 'Gifts (USD)';

  @override
  String analyticsLivesDuration(String min) {
    return '$min min';
  }

  @override
  String get analyticsLivesNoTitle => 'Live sem título';

  @override
  String get analyticsLivesMetricViewers => 'viewers';

  @override
  String get analyticsLivesMetricPeak => 'pico';

  @override
  String get analyticsLivesMetricUsdt => 'USD';

  @override
  String get analyticsLivesReplayLabel => 'Replay';

  @override
  String get analyticsLivesReplayExpired => 'Replay não disponível';

  @override
  String get analyticsLivesReplayExpiredSub =>
      'O vídeo pode ter expirado (>30 dias)';

  @override
  String get analyticsLivesEmptyTitle => 'Nenhuma live realizada ainda';

  @override
  String get analyticsLivesEmptySubtitle =>
      'Faça sua primeira live e veja as métricas aqui';

  @override
  String get analyticsLivesMonthsShort =>
      'Jan,Fev,Mar,Abr,Mai,Jun,Jul,Ago,Set,Out,Nov,Dez';

  @override
  String get analyticsReachTitle => 'Alcance e Monetização';

  @override
  String get analyticsReachKpiGifts => 'Gifts recebidos';

  @override
  String get analyticsReachKpiEarnings => 'Ganhos (USD)';

  @override
  String get analyticsReachEarningsChartTitle => 'Ganhos por dia';

  @override
  String get analyticsReachLegendEarnings => 'Ganhos USD';

  @override
  String get analyticsReachLegendFee => 'Taxa plataforma';

  @override
  String get analyticsReachTopGiftsTitle => 'Top Gifts recebidos';

  @override
  String get analyticsReachNoGifts => 'Nenhum gift recebido ainda';

  @override
  String get analyticsReachMonetizationTitle => 'Monetização total';

  @override
  String get analyticsReachTotalEarned => 'Total ganho';

  @override
  String get analyticsReachTotalGifts => 'Gifts totais';

  @override
  String get analyticsReachEarningsPerLive => 'Ganho/live';

  @override
  String get analyticsDashboardAvgViewers => 'méd./live';

  @override
  String get analyticsDashboardSeeGrowth => 'Ver crescimento';

  @override
  String get analyticsDashboardGifts => 'gifts';

  @override
  String analyticsDashboardMinAvg(String min) {
    return '$min min méd.';
  }

  @override
  String shopVitrineTitle(String name) {
    return 'Vitrine de $name';
  }

  @override
  String get shopVitrineSearchTooltip => 'Buscar na vitrine';

  @override
  String get shopVitrineFilterTooltip => 'Classificar produtos';

  @override
  String get shopVitrineViewModeTooltip => 'Mudar visualização';

  @override
  String get shopVitrineSortTitle => 'Classificar por';

  @override
  String get shopVitrineSortCreatorChoice => 'Escolha do criador';

  @override
  String get shopVitrineSortBestSelling => 'Mais vendidos';

  @override
  String get shopVitrineSortNewest => 'Novidades';

  @override
  String get shopVitrineSortPriceAsc => 'Preço: menor para maior';

  @override
  String get shopVitrineSortPriceDesc => 'Preço: maior para menor';

  @override
  String shopVitrineSoldOnline(String count) {
    return '$count vendidos online';
  }

  @override
  String get shopVitrineFreeShipping => 'Frete grátis';

  @override
  String get shopProductPageTitle => 'Produto';

  @override
  String get shopProductPrice => 'Preço';

  @override
  String get shopProductOriginalPrice => 'Preço original';

  @override
  String get shopProductDiscount => 'Desconto';

  @override
  String get shopProductAddToCart => 'Adicionar ao carrinho';

  @override
  String get shopProductBuyNow => 'Comprar agora';

  @override
  String get shopProductDescription => 'Descrição';

  @override
  String get shopProductStore => 'Loja';

  @override
  String get shopProductViewStore => 'Ver loja';

  @override
  String get shopProductQuantity => 'Quantidade';

  @override
  String get shopProductRating => 'Avaliação';

  @override
  String get shopProductReviews => 'avaliações';

  @override
  String get shopProductSold => 'vendidos';

  @override
  String get shopProductOutOfStock => 'Fora de estoque';

  @override
  String get shopProductNotFound => 'Produto não encontrado.';

  @override
  String get shopProductError => 'Não foi possível carregar o produto.';

  @override
  String get shopProductAddedToCart => 'Produto adicionado ao carrinho ✓';

  @override
  String get shopProductAddToCartError =>
      'Não foi possível adicionar ao carrinho.';

  @override
  String get shopProductCartTooltip => 'Carrinho';

  @override
  String get shopProductSearchTooltip => 'Buscar produtos';

  @override
  String get shopProductShareTooltip => 'Compartilhar';

  @override
  String get shopProductMoreTooltip => 'Mais opções';

  @override
  String get shopProductShareFail => 'Não foi possível compartilhar o produto.';

  @override
  String get shopProductLinkCopied => 'Link do produto copiado!';

  @override
  String get shopProductOptionShare => 'Compartilhar produto';

  @override
  String get shopProductOptionCopyLink => 'Copiar link';

  @override
  String get shopProductOptionReport => 'Denunciar produto';

  @override
  String get shopProductReportQuestion =>
      'Por que você está denunciando este produto?';

  @override
  String get shopProductReportSent =>
      'Denúncia enviada. Obrigado por ajudar a manter a Brawe segura.';

  @override
  String get shopProductReportError =>
      'Não foi possível enviar a denúncia. Tente novamente.';

  @override
  String get shopProductFooterStore => 'Loja';

  @override
  String get shopProductFooterChat => 'Chat';

  @override
  String get shopProductChatComingSoon => 'Chat com a loja em breve.';

  @override
  String get shopProductTabOverview => 'Visão geral';

  @override
  String get shopProductTabReviews => 'Avaliações';

  @override
  String get shopProductTabDescription => 'Descrição';

  @override
  String get shopProductTabRecommendations => 'Recomendações';

  @override
  String get shopProductReviewsComingSoon => 'Avaliações de produtos em breve.';

  @override
  String get shopProductRecommendationsComingSoon =>
      'Recomendações de outros produtos em breve.';

  @override
  String get shopCartTitle => 'Carrinho';

  @override
  String get shopCartClear => 'Limpar carrinho';

  @override
  String get shopCartClearConfirmTitle => 'Limpar carrinho?';

  @override
  String get shopCartClearConfirmBody =>
      'Todos os itens serão removidos do seu carrinho.';

  @override
  String get shopCartEmptyTitle => 'Seu carrinho está vazio';

  @override
  String get shopCartEmptyBody =>
      'Explore a vitrine e encontre produtos incríveis.';

  @override
  String get shopCartViewShowcase => 'Ver vitrine';

  @override
  String get shopCartError => 'Não foi possível carregar o carrinho.';

  @override
  String get shopCartRemoveItem => 'Remover item';

  @override
  String get shopCartSubtotal => 'Subtotal';

  @override
  String get shopCartTax => 'Taxas';

  @override
  String get shopCartShipping => 'Frete';

  @override
  String get shopCartDiscount => 'Desconto';

  @override
  String get shopCartTotal => 'Total';

  @override
  String get shopCartContinueToCheckout => 'Continuar para checkout';

  @override
  String get shopCartUpdateError => 'Não foi possível atualizar o item.';

  @override
  String get shopCartRemoveError => 'Não foi possível remover o item.';

  @override
  String get shopCartClearError => 'Não foi possível limpar o carrinho.';

  @override
  String get shopCheckoutTitle => 'Finalizar compra';

  @override
  String get shopCheckoutAddressSection => 'Endereço de entrega';

  @override
  String get shopCheckoutAddressEmpty => 'Você ainda não tem endereços salvos.';

  @override
  String get shopCheckoutAddNewAddress => 'Usar outro endereço';

  @override
  String get shopCheckoutAddressLabel =>
      'Nome do endereço (ex.: Casa, Trabalho)';

  @override
  String get shopCheckoutAddressStreet => 'Rua';

  @override
  String get shopCheckoutAddressNumber => 'Número';

  @override
  String get shopCheckoutAddressComplement => 'Complemento (opcional)';

  @override
  String get shopCheckoutAddressNeighborhood => 'Bairro';

  @override
  String get shopCheckoutAddressCity => 'Cidade';

  @override
  String get shopCheckoutAddressState => 'Estado';

  @override
  String get shopCheckoutAddressPostalCode => 'CEP';

  @override
  String get shopCheckoutAddressSave => 'Salvar endereço';

  @override
  String get shopCheckoutAddressSaved => 'Endereço salvo ✓';

  @override
  String get shopCheckoutAddressSaveError =>
      'Não foi possível salvar o endereço.';

  @override
  String get shopCheckoutAddressRequired =>
      'Selecione ou cadastre um endereço de entrega.';

  @override
  String get shopCheckoutCustomerSection => 'Dados do cliente';

  @override
  String get shopCheckoutCustomerName => 'Nome completo';

  @override
  String get shopCheckoutCustomerEmail => 'E-mail';

  @override
  String get shopCheckoutCustomerPhone => 'Telefone (opcional)';

  @override
  String get shopCheckoutRecipientSection => 'Destinatário (para nota fiscal)';

  @override
  String get shopCheckoutRecipientHint =>
      'A loja precisa desses dados para emitir a nota fiscal do seu pedido.';

  @override
  String get shopCheckoutRecipientName => 'Nome completo do destinatário';

  @override
  String get shopCheckoutDocumentType => 'Tipo';

  @override
  String get shopCheckoutDocumentRequired =>
      'CPF/CNPJ é obrigatório para emissão de NF.';

  @override
  String get shopCheckoutCpfInvalid => 'CPF deve ter 11 dígitos.';

  @override
  String get shopCheckoutCnpjInvalid => 'CNPJ deve ter 14 dígitos.';

  @override
  String get shopCheckoutNameRequired => 'Informe seu nome completo.';

  @override
  String get shopCheckoutEmailRequired => 'Informe seu e-mail.';

  @override
  String get shopCheckoutEmailInvalid => 'Informe um e-mail válido.';

  @override
  String get shopCheckoutShippingSection => 'Método de envio';

  @override
  String get shopCheckoutShippingStandard => 'Padrão';

  @override
  String get shopCheckoutShippingExpress => 'Expresso';

  @override
  String get shopCheckoutPaymentSection => 'Método de pagamento';

  @override
  String get shopCheckoutPaymentPix => 'PIX';

  @override
  String get shopCheckoutPaymentCard => 'Cartão';

  @override
  String get shopCheckoutPaymentCrypto => 'Cripto';

  @override
  String get shopCheckoutSummarySection => 'Resumo do pedido';

  @override
  String get shopCheckoutSubtotal => 'Subtotal';

  @override
  String get shopCheckoutTotal => 'Total';

  @override
  String get shopCheckoutConfirmOrder => 'Confirmar pedido';

  @override
  String get shopCheckoutError =>
      'Não foi possível concluir o pedido. Tente novamente.';

  @override
  String get shopCheckoutDiscount => 'Desconto';

  @override
  String get shopCheckoutFreeShipping => 'Grátis';

  @override
  String get shopCheckoutAddNote => 'Adicionar nota';

  @override
  String shopCheckoutTotalItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'itens',
      one: 'item',
    );
    return 'Total ($count $_temp0)';
  }

  @override
  String get shopCheckoutTermsPrefix =>
      'Ao concluir o pedido, você concorda com os ';

  @override
  String get shopCheckoutTermsLink => 'Termos de Uso';

  @override
  String get shopCheckoutTermsAnd => ' e a ';

  @override
  String get shopCheckoutPrivacyLink => 'Política de Privacidade';

  @override
  String get shopCheckoutTermsSuffix => ' da Brawe.';

  @override
  String get shopPaymentTitle => 'Pagamento';

  @override
  String shopPaymentOrderNumber(String number) {
    return 'Pedido #$number';
  }

  @override
  String get shopPaymentTotal => 'Total';

  @override
  String get shopPaymentPixTitle => 'Pague com PIX';

  @override
  String get shopPaymentPixInstructions =>
      'Escaneie o QR code no app do seu banco para concluir o pagamento.';

  @override
  String get shopPaymentAlreadyPaid => 'Já paguei';

  @override
  String get shopPaymentCardTitle => 'Pagamento com cartão';

  @override
  String get shopPaymentCardComingSoon => 'Integração de cartão em breve.';

  @override
  String get shopPaymentCryptoTitle => 'Pague com criptomoeda';

  @override
  String get shopPaymentCryptoComingSoon => 'Endereço de carteira em breve.';

  @override
  String get shopPaymentViewOrders => 'Ver meus pedidos';

  @override
  String get shopPaymentStatusPending => 'Aguardando pagamento';

  @override
  String get shopPaymentStatusPaid => 'Pagamento confirmado ✓';

  @override
  String get shopPaymentStatusFailed => 'Pagamento falhou';

  @override
  String get shopPaymentError =>
      'Não foi possível verificar o status do pagamento.';

  @override
  String get shopStoreProductsSection => 'Produtos';

  @override
  String get shopStoreEmptyProducts => 'Esta loja ainda não tem produtos.';

  @override
  String get shopStoreProductsError => 'Não foi possível carregar os produtos.';

  @override
  String get shopStoreError => 'Não foi possível carregar a loja.';

  @override
  String get shopStoreNotFound => 'Loja não encontrada.';

  @override
  String get shopStorePremiumBadge => 'Premium';

  @override
  String get shopStoreBravePassBadge => 'Brawe Pass';

  @override
  String shopStoreRatingCount(String count) {
    return '$count avaliações';
  }

  @override
  String get shopStoreReadMore => 'Ver mais';

  @override
  String get shopStoreReadLess => 'Ver menos';

  @override
  String get shopStoreChatCta => 'Falar com a loja';

  @override
  String get shopStoreChatUnavailable =>
      'Esta loja ainda não pode receber mensagens.';

  @override
  String shopStoreChatError(String error) {
    return 'Não foi possível abrir o chat: $error';
  }

  @override
  String get profileTooltipFindFriends => 'Encontrar amigos';

  @override
  String get findFriendsTitle => 'Encontrar amigos';

  @override
  String get findFriendsMyQrCode => 'Meu código QR';

  @override
  String get findFriendsQrHint =>
      'Outras pessoas podem escanear este código para ver seu perfil ou fazer login rapidamente';

  @override
  String get findFriendsScanButton => 'Escanear código';

  @override
  String get findFriendsSuggestionsTitle => 'Sugestões para você';

  @override
  String get findFriendsSuggestionsEmpty => 'Nenhuma sugestão por agora';

  @override
  String get findFriendsFollowButton => 'Seguir';

  @override
  String get findFriendsFollowingButton => 'Seguindo';

  @override
  String get qrScannerTitle => 'Escanear código QR';

  @override
  String get qrScannerHint => 'Aponte a câmera para um QR code da Brawe';

  @override
  String get qrScannerCameraPermissionDenied =>
      'Permita o acesso à câmera para escanear códigos QR.';

  @override
  String get qrScannerInvalidCode => 'Este código QR não é válido.';

  @override
  String get qrScannerLoginApproved => 'Login aprovado com sucesso!';

  @override
  String get qrScannerLoginConfirmTitle => 'Confirmar login';

  @override
  String get qrScannerLoginConfirmBody =>
      'Aprovar login em outro dispositivo usando esta conta?';

  @override
  String qrScannerLoginError(String error) {
    return 'Não foi possível aprovar o login: $error';
  }

  @override
  String get actionApprove => 'Aprovar';

  @override
  String get questsRewardCollected => 'Recompensa coletada!';

  @override
  String questsXpReceived(int xp) {
    return '$xp XP recebido';
  }

  @override
  String questsCoinsReceived(int coins) {
    return '$coins moedas recebidas';
  }

  @override
  String get questsLevelUp => 'Nível alcançado!';

  @override
  String get questsFailedToClaim => 'Não foi possível coletar a recompensa';

  @override
  String get questsAlreadyClaimed => 'Recompensa já coletada';

  @override
  String get shareSheetTitle => 'Compartilhar';

  @override
  String get shareSentBadge => 'Enviado';

  @override
  String get shareRetry => 'Tentar de novo';

  @override
  String get shareActionStories => 'Stories';

  @override
  String get shareActionRepost => 'Repostar';

  @override
  String get shareActionCopyLink => 'Copiar link';

  @override
  String get shareActionMore => 'Mais';

  @override
  String get composerToolText => 'Texto';

  @override
  String get composerToolMusic => 'Música';

  @override
  String get composerToolTrim => 'Cortar';

  @override
  String get composerToolSave => 'Salvar';

  @override
  String get composerToolFrame => 'Moldura';

  @override
  String get composerToolResetZoom => 'Reajustar';

  @override
  String get composerToolBackground => 'Fundo';

  @override
  String get composerDone => 'Concluir';

  @override
  String get composerClose => 'Fechar';

  @override
  String get composerTextAlignTooltip => 'Alinhamento';

  @override
  String get composerTextBackgroundTooltip => 'Fundo do texto';

  @override
  String get composerFontClassic => 'Clássico';

  @override
  String get composerFontModern => 'Moderno';

  @override
  String get composerFontSerif => 'Serif';

  @override
  String get composerFontTypewriter => 'Máquina';

  @override
  String get composerFontNeon => 'Neon';

  @override
  String get composerDiscardTitle => 'Descartar story?';

  @override
  String get composerDiscardMessage => 'Suas edições serão perdidas.';

  @override
  String get composerDiscard => 'Descartar';

  @override
  String get composerKeepEditing => 'Continuar editando';

  @override
  String get composerVolumeMix => 'Volumes';

  @override
  String get composerOverlayError =>
      'Não foi possível aplicar o texto ao vídeo.';

  @override
  String get composerModeStory => 'Story';

  @override
  String get composerModeText => 'Texto';

  @override
  String get composerFlipCamera => 'Virar câmera';

  @override
  String get composerFlash => 'Flash';

  @override
  String get composerCameraPermissionTitle => 'Permita o acesso à câmera';

  @override
  String get composerCameraPermissionBody =>
      'Para criar stories com foto e vídeo, a Brawe precisa da câmera e do microfone.';

  @override
  String get composerOpenSettings => 'Abrir ajustes';

  @override
  String get composerNoCamera => 'Câmera indisponível';

  @override
  String feedViewsCount(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted visualizações',
      one: '1 visualização',
    );
    return '$_temp0';
  }

  @override
  String get feedRepostUndone => 'Repost desfeito';

  @override
  String get profileTabReposts => 'Reposts';

  @override
  String get profileNoReposts => 'Nenhum repost ainda';

  @override
  String get liveEndedTitle => 'Live encerrada';

  @override
  String liveEndedByStreamer(String name) {
    return 'Obrigado por assistir!';
  }

  @override
  String liveEndedAlready(String name) {
    return 'Você chegou depois que ela terminou.';
  }

  @override
  String liveEndedLasted(String duration) {
    return 'Durou $duration';
  }

  @override
  String get liveEndedFollow => 'Seguir';

  @override
  String get liveEndedFollowing => 'Seguindo';

  @override
  String liveEndedFollowHint(String name) {
    return 'Siga para saber quando $name entrar ao vivo de novo.';
  }

  @override
  String get liveEndedNextLive => 'Próxima live';

  @override
  String get liveEndedWatchNow => 'Assistir';

  @override
  String liveEndedGoingIn(int seconds) {
    return 'Indo para a próxima live em ${seconds}s';
  }

  @override
  String get liveEndedStay => 'Ficar aqui';

  @override
  String get liveEndedNoOther => 'Nenhuma outra live no ar agora.';

  @override
  String get liveEndedBackHome => 'Voltar ao início';

  @override
  String liveEndedWatching(String count) {
    return '$count assistindo';
  }

  @override
  String get livePausedTitle => 'Volto já';

  @override
  String livePausedBy(String name) {
    return '$name pausou a live';
  }

  @override
  String livePausedBackIn(String time) {
    return 'Volta em até $time';
  }

  @override
  String get livePausedResuming => 'Voltando…';

  @override
  String get livePausedResumingHint => 'A transmissão volta em instantes';

  @override
  String get broadcasterPausedTitle => 'Live pausada';

  @override
  String get broadcasterPausedHint =>
      'Câmera e microfone desligados. Seus espectadores veem o aviso de pausa.';

  @override
  String broadcasterResumeIn(String time) {
    return 'Retome em $time';
  }

  @override
  String get broadcasterResumeButton => 'Retomar live';

  @override
  String get broadcasterResumingTitle => 'Voltando ao ar…';

  @override
  String get broadcasterResumingHint =>
      'Seus espectadores voltam a te ver em alguns segundos.';

  @override
  String get broadcasterBackLive => 'Você está ao vivo';

  @override
  String get relHidePosts => 'Ocultar publicações';

  @override
  String get relShowPosts => 'Mostrar publicações';

  @override
  String relHiddenSnack(String name) {
    return 'Você não verá mais as publicações de $name.';
  }

  @override
  String relShownSnack(String name) {
    return 'As publicações de $name voltaram a aparecer.';
  }

  @override
  String get relActionError => 'Não foi possível concluir. Tente de novo.';

  @override
  String get profileBlockedState => 'Você bloqueou este usuário';

  @override
  String get profileBlockedStateHint =>
      'Desbloqueie para ver o perfil e as publicações.';

  @override
  String get profileUnblock => 'Desbloquear';

  @override
  String get profileUnblocked => 'Usuário desbloqueado.';

  @override
  String get profileUnavailable => 'Perfil indisponível';

  @override
  String get profileUnavailableHint =>
      'Este conteúdo não está disponível para você.';

  @override
  String get liveOwnTitle => 'Você está ao vivo';

  @override
  String get liveOwnBody =>
      'Esta é a sua live, transmitida em outro aparelho. Para assistir como espectador, entre com outra conta.';

  @override
  String get liveOwnBack => 'Voltar';

  @override
  String get liveConnecting => 'Conectando à live…';

  @override
  String get rankingTitle => 'Top Presenteadores';

  @override
  String get rankingTabLive => 'Esta live';

  @override
  String get rankingTabWeek => 'Semana do criador';

  @override
  String rankingRoomTotal(String points) {
    return 'Total da live: $points moedas';
  }

  @override
  String get rankingEmpty => 'Nenhum presente ainda';

  @override
  String get rankingEmptyHint => 'Seja o primeiro a presentear!';

  @override
  String rankingGiftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presentes',
      one: '1 presente',
    );
    return '$_temp0';
  }

  @override
  String get rankingYouBadge => 'Você';

  @override
  String rankingFooterGap(int rank, String gap, String name) {
    return 'Você está em #$rank · faltam $gap para passar $name';
  }

  @override
  String get rankingFooterLeader => 'Você está em #1 · lidera o ranking';

  @override
  String rankingFooterOnly(int rank) {
    return 'Você está em #$rank';
  }

  @override
  String get rankingFooterJoin => 'Envie um presente para entrar no ranking';

  @override
  String overtakenMessage(String name, String gap, int rank) {
    return '$name passou você! Faltam $gap moedas para retomar o #$rank';
  }

  @override
  String get overtakenRetake => 'Retomar';

  @override
  String newTopGifterBanner(String name) {
    return 'Novo #1 da live: $name';
  }

  @override
  String giftsNeedHint(String gap) {
    return 'Faltam $gap moedas para retomar sua posição';
  }

  @override
  String giftsNeedHintNone(String gap) {
    return 'Escolha um presente de pelo menos $gap moedas para retomar sua posição';
  }

  @override
  String liveEntranceJoined(String name) {
    return '$name entrou na live';
  }

  @override
  String get liveEntranceTopOne => 'O #1 da live chegou';

  @override
  String get liveLevelUpTitle => 'Subiu de nível!';

  @override
  String liveLevelUpLevel(int level) {
    return 'Nível $level';
  }

  @override
  String liveLevelUpPublic(String name, int level) {
    return '$name subiu para o nível $level';
  }

  @override
  String get liveGoalDefaultTitle => 'Meta da live';

  @override
  String get liveGoalReached => 'Meta batida!';

  @override
  String get liveGoalOption => 'Meta da live';

  @override
  String get liveGoalOptionSubtitle => 'Defina uma meta de moedas para a live';

  @override
  String get liveGoalSheetTitle => 'Meta da live';

  @override
  String get liveGoalPointsLabel => 'Meta (moedas)';

  @override
  String get liveGoalTitleLabel => 'Título curto (ex.: Sorteio de um prêmio)';

  @override
  String get liveGoalSave => 'Definir meta';

  @override
  String get liveGoalClear => 'Remover meta';

  @override
  String get liveGoalSaved => 'Meta atualizada';

  @override
  String get liveGoalError => 'Não foi possível atualizar a meta';

  @override
  String get liveGoalInvalid => 'Informe uma meta maior que zero';

  @override
  String get questLiveTag => 'NA LIVE';

  @override
  String get questWatchLive => 'Assista lives';

  @override
  String get questSendLiveGift => 'Envie presentes na live';

  @override
  String get questLiveChat => 'Converse na live';

  @override
  String get rankingSheetTitle => 'Ranking da live';

  @override
  String get rankingTabGifts => 'Presentes';

  @override
  String get rankingTabLikes => 'Curtidas';

  @override
  String likesRoomTotal(String likes, int people) {
    String _temp0 = intl.Intl.pluralLogic(
      people,
      locale: localeName,
      other: '$people pessoas',
      one: '1 pessoa',
    );
    return '$likes curtidas · $_temp0';
  }

  @override
  String likesFooterGap(int rank, String gap, String name) {
    return 'Você está em #$rank · faltam $gap curtidas para passar $name';
  }

  @override
  String get likesFooterLeader => 'Você está em #1 · quem mais curtiu a live';

  @override
  String likesFooterOnly(int rank) {
    return 'Você está em #$rank';
  }

  @override
  String get likesFooterJoin => 'Curta a live para entrar no ranking';

  @override
  String get likesEmpty => 'Ninguém curtiu ainda';

  @override
  String get likesEmptyHint => 'Seja o primeiro a curtir!';

  @override
  String get likesNote => 'Curtidas não somam no ranking de presentes';

  @override
  String get rankingSendGift => 'Presentear';

  @override
  String get rankingLikeNow => 'Curtir';

  @override
  String likeMilestoneBanner(String count) {
    return 'A live chegou a $count curtidas!';
  }

  @override
  String get questLiveLike => 'Curtir lives';

  @override
  String noticeOvertakenTitle(String name) {
    return '$name passou você!';
  }

  @override
  String noticeOvertakenBody(String gap, int rank) {
    return 'Faltam $gap moedas para retomar o #$rank';
  }

  @override
  String noticeLevelUpBody(int level) {
    return 'Você chegou ao nível $level';
  }

  @override
  String get noticeNewTopTitle => 'Novo #1 da live';

  @override
  String get goalsTitle => 'Metas da live';

  @override
  String get goalsButton => 'Metas';

  @override
  String get goalTypeGift => 'Presente';

  @override
  String get goalTypeLikes => 'Curtidas';

  @override
  String goalLikesLabel(String count) {
    return '$count curtidas';
  }

  @override
  String goalProgress(String progress, String target) {
    return '$progress de $target';
  }

  @override
  String get goalReached => 'Meta batida';

  @override
  String goalReachedChat(String goal) {
    return 'Meta batida: $goal';
  }

  @override
  String get goalSendGift => 'Enviar';

  @override
  String get goalLike => 'Curtir';

  @override
  String get goalsViewerHint =>
      'Toque em Enviar para abrir a sacola já no presente da meta.';

  @override
  String get goalsEmptyCreator =>
      'Escolha um presente e a quantidade, ou uma meta de curtidas. Até 3 metas.';

  @override
  String get goalPickGift => 'Escolha um presente';

  @override
  String goalAddGift(String count, String gift) {
    return 'Adicionar $count $gift';
  }

  @override
  String goalAddLikes(String count) {
    return 'Adicionar $count curtidas';
  }

  @override
  String get goalsSave => 'Salvar metas';

  @override
  String get goalsRemoveAll => 'Remover metas';

  @override
  String get goalsSaveError => 'Não foi possível salvar as metas';

  @override
  String giftTickerText(String sender, String gift, String streamer) {
    return '$sender enviou $gift para $streamer';
  }

  @override
  String get videoFullscreen => 'Tela cheia';

  @override
  String get liveOwnEnd => 'Encerrar esta live';

  @override
  String get liveOwnEndConfirmTitle => 'Encerrar a live?';

  @override
  String get liveOwnEndConfirmBody =>
      'A live termina para todos, inclusive no outro aparelho.';

  @override
  String get liveOwnEnded => 'Live encerrada';

  @override
  String get liveOwnEndError => 'Não foi possível encerrar a live';

  @override
  String get liveWaitingSignal =>
      'Sem sinal do criador no momento.\nTentando de novo…';

  @override
  String get commentsHintAddMention =>
      'Adicionar comentário... use @ para marcar';

  @override
  String get commentsMentionFollowing => 'Seguindo';

  @override
  String eventChipEndsIn(String time) {
    return 'termina em $time';
  }

  @override
  String get rankingTabEvent => 'Evento';

  @override
  String rankingPrizeFirst(String prize) {
    return 'Prêmio do 1º lugar: $prize';
  }

  @override
  String get awardGrantedTitle => 'Você ganhou um prêmio!';

  @override
  String get profileAwardsTitle => 'Prêmios';

  @override
  String profileAwardUntil(String date) {
    return 'até $date';
  }

  @override
  String get chatErrorNotSent => 'Mensagem não enviada';

  @override
  String get chatErrorLink => 'Links não são permitidos no chat';

  @override
  String get chatErrorPhone => 'Telefones não são permitidos no chat';

  @override
  String chatErrorMutedUntil(String time) {
    return 'Você foi silenciado até $time';
  }

  @override
  String get chatErrorMutedLiveEnd => 'Você foi silenciado até o fim da live';

  @override
  String chatErrorSlowWait(int seconds) {
    return 'Modo lento: aguarde $seconds s';
  }

  @override
  String get chatErrorSlowGeneric => 'Modo lento: aguarde um instante';

  @override
  String chatSlowModeHint(int seconds) {
    return 'Modo lento: $seconds s';
  }

  @override
  String get chatPinnedUnpin => 'Desafixar';

  @override
  String get chatModeratorBadge => 'Moderador';

  @override
  String get modMute5 => 'Silenciar 5 min';

  @override
  String get modMute60 => 'Silenciar 1 h';

  @override
  String get modMuteRest => 'Silenciar até o fim da live';

  @override
  String get modPinMessage => 'Fixar mensagem';

  @override
  String get modMakeModerator => 'Tornar moderador';

  @override
  String get modRemoveModerator => 'Remover moderador';

  @override
  String modMutedToast(String name) {
    return '$name foi silenciado';
  }

  @override
  String get modPinnedToast => 'Mensagem fixada';

  @override
  String get modUnpinnedToast => 'Mensagem desafixada';

  @override
  String modMadeModeratorToast(String name) {
    return '$name agora é moderador';
  }

  @override
  String modRemovedModeratorToast(String name) {
    return '$name não é mais moderador';
  }

  @override
  String get modActionFailed => 'Não foi possível concluir a ação';

  @override
  String get modNotAllowed => 'Você não tem permissão para isso';

  @override
  String get modModeratorsTitle => 'Moderadores';

  @override
  String get modModeratorsSubtitle => 'Quem ajuda a cuidar do chat da sua live';

  @override
  String get modModeratorsEmpty =>
      'Você ainda não tem moderadores. Toque no nome de alguém no chat para promovê-lo.';

  @override
  String get modModeratorsLoadFailed =>
      'Não foi possível carregar os moderadores';

  @override
  String get modRemoveConfirm => 'Remover';

  @override
  String get battleDurationLabel => 'Duração';

  @override
  String battleDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String battleDurationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get questFrequencyWeekly => 'Semanal';

  @override
  String get questFrequencyEvent => 'Evento';

  @override
  String get questFrequencyDaily => 'Diária';

  @override
  String get reportReasonChildSafety => 'Abuso ou exploração de menores';

  @override
  String get reportChildSafetyNote =>
      'Se uma criança estiver em perigo imediato, procure as autoridades (no Brasil: Disque 100 ou 190).';

  @override
  String get liveReport => 'Denunciar live';

  @override
  String get settingsSendFeedback => 'Enviar feedback';

  @override
  String get settingsChildSafety => 'Normas de Segurança Infantil';

  @override
  String get feedbackIntro =>
      'Conte o que aconteceu. Sua mensagem vai direto para a nossa equipe, sem sair do app.';

  @override
  String get feedbackTypeBug => 'Problema no app';

  @override
  String get feedbackTypeSuggestion => 'Sugestão';

  @override
  String get feedbackTypeChildSafety => 'Segurança infantil';

  @override
  String get feedbackHint => 'Descreva aqui…';

  @override
  String get feedbackSend => 'Enviar';

  @override
  String get feedbackSent => 'Feedback enviado. Obrigado!';

  @override
  String get feedbackError => 'Não foi possível enviar. Tente novamente.';

  @override
  String get feedbackTooShort => 'Escreva pelo menos 10 caracteres.';

  @override
  String get suspendedTitle => 'Conta suspensa';

  @override
  String get suspendedBody =>
      'Sua conta no Brawe Connect foi suspensa por violar as nossas Diretrizes da Comunidade.';

  @override
  String get suspendedReasonLabel => 'Motivo';

  @override
  String suspendedUntil(String date) {
    return 'A suspensão termina em $date.';
  }

  @override
  String get suspendedPermanent => 'Esta suspensão é permanente.';

  @override
  String get suspendedAppeal =>
      'Se você acredita que foi um engano, fale com o nosso suporte.';

  @override
  String get suspendedContact => 'Falar com o suporte';

  @override
  String get suspendedRetry => 'Verificar novamente';

  @override
  String get suspendedStillActive => 'Sua conta continua suspensa.';

  @override
  String get questsTabMissions => 'Missões';

  @override
  String get questsTabAchievements => 'Conquistas';

  @override
  String get questsTabJourney => 'Jornada';

  @override
  String questsResetsIn(String time) {
    return 'Novas missões em $time';
  }

  @override
  String questsDayProgress(int done, int total) {
    return '$done de $total concluídas';
  }

  @override
  String get questsSectionDaily => 'Missões diárias';

  @override
  String get questsSectionWeekly => 'Missões da semana';

  @override
  String get questsSectionEvent => 'Missões de evento';

  @override
  String get questsAllDoneMascot =>
      'Você completou todas as missões de hoje! Volte amanhã para manter a sequência.';

  @override
  String questsStreakMascot(int days) {
    return 'Sequência de $days dias! Continue assim!';
  }

  @override
  String get questsStartMascot =>
      'Complete todas as missões de hoje para começar uma sequência e ganhar emblemas.';

  @override
  String questsNextBadge(int days) {
    return 'Próximo emblema em $days dias';
  }

  @override
  String questsStreakBonus(String label) {
    return 'Bônus de sequência $label';
  }

  @override
  String get questsLevelUpTitle => 'Subiu de nível!';

  @override
  String questsLevelUpBody(int level) {
    return 'Você chegou ao nível $level';
  }

  @override
  String get questsBadgeUnlockedTitle => 'Emblema desbloqueado!';

  @override
  String get questsContinue => 'Continuar';

  @override
  String get questsStatsTitle => 'Seus números';

  @override
  String get questsStatQuests => 'Missões concluídas';

  @override
  String get questsStatXp => 'XP total';

  @override
  String get questsStatCoins => 'Moedas ganhas';

  @override
  String get questsStatBestStreak => 'Maior sequência';

  @override
  String get questsBadgesTitle => 'Emblemas';

  @override
  String questsBadgesCount(int unlocked, int total) {
    return '$unlocked de $total';
  }

  @override
  String get questsBadgeLocked => 'Bloqueado';

  @override
  String get questsBadgeEarned => 'Conquistado';

  @override
  String questsBadgeEarnedOn(String date) {
    return 'Conquistado em $date';
  }

  @override
  String questsBadgeRequirement(int days) {
    return 'Complete todas as missões do dia por $days dias seguidos.';
  }

  @override
  String questsBadgeProgress(int current, int target) {
    return '$current de $target dias';
  }

  @override
  String get questBadgeStreak3 => 'Iniciante Dedicado';

  @override
  String get questBadgeStreak7 => 'Guerreiro Semanal';

  @override
  String get questBadgeStreak14 => 'Veterano';

  @override
  String get questBadgeStreak30 => 'Lenda do Mês';

  @override
  String get questBadgeStreak60 => 'Mestre da Consistência';

  @override
  String get questBadgeStreak100 => 'Ícone Brawe';

  @override
  String get questsAwardsTitle => 'Prêmios recebidos';

  @override
  String get questsAwardsEmpty =>
      'Você ainda não recebeu prêmios. Participe de lives, eventos e batalhas para ganhar.';

  @override
  String get questsAwardActive => 'Ativo';

  @override
  String get questsAwardExpired => 'Expirado';

  @override
  String get questsAwardRevoked => 'Revogado';

  @override
  String get questsAwardScheduled => 'Em breve';

  @override
  String questsAwardValidUntil(String date) {
    return 'Válido até $date';
  }

  @override
  String questsAwardEndedOn(String date) {
    return 'Encerrado em $date';
  }

  @override
  String questsAwardStartsOn(String date) {
    return 'Começa em $date';
  }

  @override
  String get questsAwardSourceEvent => 'Evento';

  @override
  String get questsAwardSourceCreatorWeek => 'Semana do criador';

  @override
  String get questsAwardSourceLive => 'Live';

  @override
  String get questsAwardSourceBattle => 'Batalha';

  @override
  String questsAwardRank(int rank) {
    return '$rankº lugar';
  }

  @override
  String questsAwardCoins(int coins) {
    return '+$coins moedas';
  }

  @override
  String get questsAwardFrame => 'Moldura';

  @override
  String get questsAwardEntry => 'Entrada especial';

  @override
  String get questsTimelineEmpty =>
      'Sua jornada começa agora. Conclua missões para ver suas conquistas aqui.';

  @override
  String get questsTimelineToday => 'Hoje';

  @override
  String get questsTimelineYesterday => 'Ontem';

  @override
  String get questsTimelineQuest => 'Missão concluída';

  @override
  String get questsTimelineAward => 'Prêmio recebido';

  @override
  String get questsTimelineBadge => 'Emblema conquistado';

  @override
  String questsTimelineLevel(int level) {
    return 'Nível $level alcançado';
  }

  @override
  String get questsJourneyError => 'Não foi possível carregar sua jornada.';

  @override
  String questsLevelShort(int level) {
    return 'Nv. $level';
  }

  @override
  String get findFriendsSearchHint => 'Buscar por nome ou @usuário';

  @override
  String findFriendsSearchNoResults(String query) {
    return 'Nenhuma pessoa encontrada para \"$query\"';
  }

  @override
  String get findFriendsSearchError =>
      'Não foi possível buscar agora. Verifique sua conexão.';

  @override
  String get findFriendsSuggestionsError =>
      'Não foi possível carregar as sugestões.';

  @override
  String get findFriendsRetry => 'Tentar de novo';

  @override
  String get creatorGuideTitle => 'Guia do Criador';

  @override
  String get creatorGuideIntro =>
      'Tudo o que você precisa saber para crescer na Brawe.';

  @override
  String get creatorGuideToc => 'Sumário';

  @override
  String get creatorGuideSecWhat => 'O que é';

  @override
  String get creatorGuideSecBenefits => 'Benefícios';

  @override
  String get creatorGuideSecLevels => 'Níveis';

  @override
  String get creatorGuideSecHow => 'Como entrar';

  @override
  String get creatorGuideSecRules => 'Diretrizes';

  @override
  String get creatorGuideSecFaq => 'Perguntas frequentes';

  @override
  String get creatorGuideWhatBody =>
      'Programa oficial da Brawe para quem cria conteúdo e quer crescer, ser descoberto e construir comunidade.';

  @override
  String get creatorGuideWhatPoint1 => 'Gratuito para se inscrever';

  @override
  String get creatorGuideWhatPoint2 => 'Análise feita por pessoas';

  @override
  String get creatorGuideWhatPoint3 => 'Cresça por níveis';

  @override
  String get creatorGuideHowStep1 => 'Preencha a inscrição';

  @override
  String get creatorGuideHowStep2 => 'Nossa equipe analisa seu perfil';

  @override
  String get creatorGuideHowStep3 => 'Você recebe a resposta no app';

  @override
  String get creatorGuideHowStep4 => 'Aprovado, ative seu perfil de creator';

  @override
  String get creatorGuideRule1 => 'Conteúdo original ou com créditos';

  @override
  String get creatorGuideRule2 => 'Respeito à comunidade, sem ódio ou assédio';

  @override
  String get creatorGuideRule3 =>
      'Nada de seguidores falsos ou compra de engajamento';

  @override
  String get creatorGuideRule4 =>
      'Segurança de menores sempre em primeiro lugar';

  @override
  String get creatorGuideRule5 => 'Siga os Termos e a Política de Privacidade';

  @override
  String get creatorGuideFaq1Q => 'Quanto custa participar?';

  @override
  String get creatorGuideFaq1A =>
      'Nada. A inscrição e a participação na rede são gratuitas.';

  @override
  String get creatorGuideFaq2Q => 'Quanto tempo leva a análise?';

  @override
  String get creatorGuideFaq2A =>
      'Avisamos você assim que houver novidade. Acompanhe o status no app.';

  @override
  String get creatorGuideFaq3Q => 'Preciso de muitos seguidores?';

  @override
  String get creatorGuideFaq3A =>
      'Não. Avaliamos consistência, qualidade e potencial, não só números.';

  @override
  String get creatorGuideFaq4Q => 'Posso me inscrever de novo se for recusado?';

  @override
  String get creatorGuideFaq4A =>
      'Sim. Melhore seu perfil e envie uma nova inscrição depois.';

  @override
  String get creatorGuideCtaTerms => 'Ler os termos';

  @override
  String get creatorApplyTypeTitle => 'Tipo de criador';

  @override
  String get creatorApplyTypeHint =>
      'Escolha o que melhor descreve seu conteúdo.';

  @override
  String get creatorApplyNicheLifestyle => 'Lifestyle';

  @override
  String get creatorApplyNicheGames => 'Games';

  @override
  String get creatorApplyNicheMusic => 'Música';

  @override
  String get creatorApplyNicheFashion => 'Moda';

  @override
  String get creatorApplyNicheBeauty => 'Beleza';

  @override
  String get creatorApplyNicheFitness => 'Fitness';

  @override
  String get creatorApplyNicheComedy => 'Comédia';

  @override
  String get creatorApplyNicheBusiness => 'Negócios';

  @override
  String get creatorApplyNicheTech => 'Tecnologia';

  @override
  String get creatorApplyNicheEducation => 'Educação';

  @override
  String get creatorApplyNicheTravel => 'Viagens';

  @override
  String get creatorApplyNicheEntertainment => 'Entretenimento';

  @override
  String get creatorApplyNicheSports => 'Esportes';

  @override
  String get creatorApplyNicheCooking => 'Culinária';

  @override
  String get creatorApplyNicheOther => 'Outro';

  @override
  String get creatorApplyTermsAnd => ' e a ';

  @override
  String get creatorApplyTermsUse => 'Termos de Uso';

  @override
  String get creatorApplyAcceptButton => 'Li e aceito';

  @override
  String get creatorApplyErrUsername => 'Mínimo de 2 caracteres';

  @override
  String get creatorApplyErrName => 'Informe nome e sobrenome';

  @override
  String get creatorApplyErrUrl => 'Informe um link válido (https://...)';

  @override
  String get creatorApplyErrCountry => 'Selecione seu país';

  @override
  String get creatorApplyErrPhone => 'Telefone inválido';

  @override
  String get creatorApplyErrFollowers => 'Informe um número válido';

  @override
  String get creatorApplyErrNetwork =>
      'Sem conexão. Verifique sua internet e tente novamente.';

  @override
  String get creatorApplyErrServer =>
      'Servidor indisponível no momento. Tente novamente em instantes.';

  @override
  String get creatorApplyErrSession =>
      'Sua sessão expirou. Entre novamente para se inscrever.';

  @override
  String creatorApplyErrFields(String fields) {
    return 'Alguns dados não foram aceitos. Revise o formulário: $fields.';
  }

  @override
  String get creatorApplyOptional => 'opcional';

  @override
  String get creatorApplyInstagramHint => 'usuario (sem @)';

  @override
  String get creatorApplyCategoryHint =>
      'Opcional: o nível que você pretende alcançar.';

  @override
  String get rewardsTabReceived => 'Recebidos';

  @override
  String get rewardsTabSent => 'Enviados';

  @override
  String get rewardsPeriodToday => 'Hoje';

  @override
  String get rewardsPeriod7d => '7 dias';

  @override
  String get rewardsPeriod30d => '30 dias';

  @override
  String get rewardsPeriodAll => 'Tudo';

  @override
  String get rewardsHistoryTitle => 'Histórico de presentes';

  @override
  String get rewardsHistorySubtitle => 'Presentes que você recebeu e enviou';

  @override
  String get rewardsNoSent => 'Você ainda não enviou presentes.';

  @override
  String get rewardsNoSentHint =>
      'Os presentes que você enviar em lives aparecerão aqui.';

  @override
  String get rewardsNoPeriod => 'Nada neste período.';

  @override
  String get rewardsNoPeriodHint => 'Tente outro período para ver mais itens.';

  @override
  String get rewardsPeriodTotalReceived => 'Total recebido no período';

  @override
  String get rewardsPeriodTotalSent => 'Total enviado no período';

  @override
  String rewardsGiftsCount(int n) {
    return '$n presentes';
  }

  @override
  String rewardsFromTo(String label, String name) {
    return '$label $name';
  }

  @override
  String get rewardsPurchaseDisabled =>
      'A compra de moedas estará disponível em breve.';

  @override
  String get liveTopUpAction => 'Recarregar';

  @override
  String get rewardsToggleCoins => 'Moedas';

  @override
  String get rewardsToggleDiamonds => 'Diamantes';

  @override
  String get rewardsDiamondsAvailable => 'Diamantes disponíveis';

  @override
  String get rewardsPeriodLabel => 'Período';

  @override
  String creatorDashSince(String date) {
    return 'Creator desde $date';
  }

  @override
  String get creatorDashCurrentLevel => 'Seu nível';

  @override
  String creatorDashOverallProgress(int percent, String tier) {
    return '$percent% do caminho até $tier';
  }

  @override
  String get creatorDashInviteNext =>
      'O próximo nível é por convite da equipe Brawe. Continue criando e brilhando!';

  @override
  String get creatorDashTopLevel =>
      'Você chegou ao topo da jornada. Obrigado por construir a Brawe!';

  @override
  String get creatorDashTrailTitle => 'Sua trilha';

  @override
  String get creatorDashTrailHere => 'Você está aqui';

  @override
  String get creatorDashTrailLocked => 'Bloqueado';

  @override
  String get creatorDashTrailInviteOnly => 'Por convite';

  @override
  String creatorDashTrailSince(String date) {
    return 'Desde $date';
  }

  @override
  String creatorDashGoalsTitle(String tier) {
    return 'Metas para $tier';
  }

  @override
  String get creatorDashGoalsHint =>
      'Cumpra as metas e mostre à equipe que você está pronto.';

  @override
  String get creatorDashGoalsAllDone =>
      'Metas cumpridas! A equipe Brawe vai avaliar seu perfil para o próximo nível.';

  @override
  String creatorDashGoalOf(String current, String target) {
    return '$current de $target';
  }

  @override
  String get creatorDashGoalDone => 'Meta cumprida';

  @override
  String get creatorJourneyMetricFollowers => 'Seguidores';

  @override
  String get creatorJourneyMetricLives => 'Lives realizadas';

  @override
  String get creatorJourneyMetricLiveMinutes => 'Minutos ao vivo';

  @override
  String get creatorJourneyMetricPosts => 'Posts publicados';

  @override
  String get creatorJourneyMetricGiftCredits => 'Presentes recebidos';

  @override
  String get creatorJourneyMetricActiveDays => 'Dias como creator';

  @override
  String get creatorJourneyMetricViewers => 'Espectadores nas lives';

  @override
  String creatorJourneyRemainingFollowers(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n seguidores',
      one: 'Falta 1 seguidor',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingLives(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n lives',
      one: 'Falta 1 live',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingLiveMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n minutos ao vivo',
      one: 'Falta 1 minuto ao vivo',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingPosts(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n posts',
      one: 'Falta 1 post',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingGiftCredits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n créditos em presentes',
      one: 'Falta 1 crédito em presentes',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingActiveDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n dias',
      one: 'Falta 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get creatorDashWeekTitle => 'Sua semana';

  @override
  String get creatorDashWeekSubtitle =>
      'Últimos 7 dias comparados aos 7 anteriores';

  @override
  String get creatorDashWeekNewFollowers => 'Novos seguidores';

  @override
  String creatorDashWeekUp(String n) {
    return '$n a mais que na semana passada';
  }

  @override
  String creatorDashWeekDown(String n) {
    return '$n a menos que na semana passada';
  }

  @override
  String get creatorDashWeekSame => 'Igual à semana passada';

  @override
  String get creatorDashWeekSeeMore => 'Ver análise';

  @override
  String get creatorDashBenefitsTitle => 'Seus benefícios';

  @override
  String creatorDashBenefitsNextTitle(String tier) {
    return 'Libera em $tier';
  }

  @override
  String get creatorDashBenefitActive => 'Ativo';

  @override
  String get creatorDashShortcutAnalytics => 'Análises';

  @override
  String get creatorDashShortcutSettings => 'Configurações';

  @override
  String get creatorDashErrorTitle =>
      'Não conseguimos carregar sua jornada. Puxe para tentar de novo.';

  @override
  String get creatorJourneyBadgeGeneric => 'Badge de creator';

  @override
  String creatorJourneyBadgeEarnedOn(String date) {
    return 'Conquistado em $date';
  }

  @override
  String get creatorJourneyBadgeBenefitsTitle => 'Benefícios ativos';

  @override
  String get creatorJourneyBadgeNextTitle => 'Próximo nível';

  @override
  String get creatorJourneyBadgeAllTitle => 'Seus badges';

  @override
  String get creatorJourneyBadgeOpenDashboard => 'Abrir painel do creator';

  @override
  String get creatorJourneyBenefitRisingBadgeTitle => 'Badge Rising';

  @override
  String get creatorJourneyBenefitRisingBadgeDesc =>
      'Seu selo oficial de creator aparece no perfil, nas lives e nos comentários.';

  @override
  String get creatorJourneyBenefitCreatorProfileTitle => 'Perfil de Creator';

  @override
  String get creatorJourneyBenefitCreatorProfileDesc =>
      'Perfil com identidade própria na rede de creators da Brawe.';

  @override
  String get creatorJourneyBenefitDiscoverySuggestionsTitle =>
      'Sugestões de descoberta';

  @override
  String get creatorJourneyBenefitDiscoverySuggestionsDesc =>
      'Seu conteúdo pode ser sugerido a pessoas que ainda não te seguem.';

  @override
  String get creatorJourneyBenefitAnalyticsTitle => 'Análises detalhadas';

  @override
  String get creatorJourneyBenefitAnalyticsDesc =>
      'Acompanhe seguidores, alcance e lives com gráficos e números reais.';

  @override
  String get creatorJourneyBenefitFeaturedBadgeTitle => 'Badge Featured';

  @override
  String get creatorJourneyBenefitFeaturedBadgeDesc =>
      'Selo de destaque que mostra que você é um creator consistente.';

  @override
  String get creatorJourneyBenefitEditorialHighlightTitle =>
      'Destaque editorial';

  @override
  String get creatorJourneyBenefitEditorialHighlightDesc =>
      'Chance de aparecer nas vitrines selecionadas pela equipe Brawe.';

  @override
  String get creatorJourneyBenefitMoreReachTitle => 'Mais alcance orgânico';

  @override
  String get creatorJourneyBenefitMoreReachDesc =>
      'Seu conteúdo ganha mais força na descoberta e chega a mais gente.';

  @override
  String get creatorJourneyBenefitLiveBadgeTitle => 'Badge Live';

  @override
  String get creatorJourneyBenefitLiveBadgeDesc =>
      'Selo exclusivo para quem constrói comunidade ao vivo.';

  @override
  String get creatorJourneyBenefitAdvancedLiveTitle =>
      'Recursos avançados de live';

  @override
  String get creatorJourneyBenefitAdvancedLiveDesc =>
      'Ferramentas extras para fazer lives mais profissionais.';

  @override
  String get creatorJourneyBenefitLiveBattlesTitle => 'Batalhas ao vivo';

  @override
  String get creatorJourneyBenefitLiveBattlesDesc =>
      'Participe de batalhas e dispute presentes com outros creators.';

  @override
  String get creatorJourneyBenefitLiveRankingTitle =>
      'Ranking de Live Creators';

  @override
  String get creatorJourneyBenefitLiveRankingDesc =>
      'Apareça no ranking público dos creators que mais brilham nas lives.';

  @override
  String get creatorJourneyBenefitAmbassadorBadgeTitle => 'Badge Ambassador';

  @override
  String get creatorJourneyBenefitAmbassadorBadgeDesc =>
      'Selo de quem representa a Brawe com reconhecimento oficial.';

  @override
  String get creatorJourneyBenefitAmbassadorPageTitle => 'Página de embaixador';

  @override
  String get creatorJourneyBenefitAmbassadorPageDesc =>
      'Uma página oficial para contar sua história e suas conquistas.';

  @override
  String get creatorJourneyBenefitOfficialCampaignsTitle =>
      'Campanhas oficiais';

  @override
  String get creatorJourneyBenefitOfficialCampaignsDesc =>
      'Convites para participar de campanhas e ações da marca Brawe.';

  @override
  String get creatorJourneyBenefitPremiumHighlightTitle => 'Destaque premium';

  @override
  String get creatorJourneyBenefitPremiumHighlightDesc =>
      'Posição privilegiada nos destaques da plataforma.';

  @override
  String get creatorJourneyBenefitFoundingBadgeTitle => 'Badge Founding';

  @override
  String get creatorJourneyBenefitFoundingBadgeDesc =>
      'O selo mais raro: para quem constrói a Brawe desde o início.';

  @override
  String get creatorJourneyBenefitFoundingSealTitle => 'Selo de Fundador';

  @override
  String get creatorJourneyBenefitFoundingSealDesc =>
      'Reconhecimento permanente como parte da história da Brawe.';

  @override
  String get creatorJourneyBenefitEarlyAccessTitle => 'Acesso antecipado';

  @override
  String get creatorJourneyBenefitEarlyAccessDesc =>
      'Teste novos recursos antes de todo mundo.';

  @override
  String get creatorJourneyBenefitRoadmapVoiceTitle => 'Voz no roadmap';

  @override
  String get creatorJourneyBenefitRoadmapVoiceDesc =>
      'Sua opinião ajuda a decidir o que a Brawe vai construir.';

  @override
  String get creatorDashShowAll => 'Ver todos';

  @override
  String get creatorDashShowLess => 'Ver menos';

  @override
  String get analyticsPreviousPeriod => 'Período anterior';

  @override
  String get analyticsNoDataTitle => 'Sem dados no período';

  @override
  String get analyticsNoDataSubtitle =>
      'Tente outro período ou volte após novas atividades.';

  @override
  String get analyticsPeriod7d => '7D';

  @override
  String get analyticsPeriod30d => '30D';

  @override
  String get analyticsPeriod90d => '3M';

  @override
  String get analyticsPeriod365d => '1A';

  @override
  String get analyticsVsPrevious => 'vs. período anterior';

  @override
  String get analyticsCompare => 'Comparar';

  @override
  String get analyticsErrorTitle => 'Não foi possível carregar';

  @override
  String get analyticsRetry => 'Tentar novamente';

  @override
  String get analyticsTopGiftsTitle => 'Top presentes';

  @override
  String get analyticsTopGiftsSubtitle => 'Os mais recebidos no período';

  @override
  String get analyticsTopGiftsEmpty => 'Nenhum presente recebido neste período';

  @override
  String get analyticsTopGiftsBest => 'Mais valioso';

  @override
  String analyticsTopGiftsReceived(String count) {
    return '$count recebidos';
  }

  @override
  String get analyticsEarningsLabel => 'Ganhos';

  @override
  String get analyticsGiftsLabel => 'Presentes';

  @override
  String get analyticsAvgPerGift => 'Média por presente';

  @override
  String get analyticsEarningsChartTitle => 'Ganhos por dia';

  @override
  String get analyticsGiftsChartTitle => 'Presentes por dia';

  @override
  String get analyticsFollowersNew => 'Novos seguidores';

  @override
  String get analyticsFollowersChartTotal => 'Seguidores acumulados';

  @override
  String get analyticsFollowersChartNew => 'Novos por dia';

  @override
  String get analyticsViewersKpiPeak => 'Pico de audiência';

  @override
  String analyticsWeekOf(String date) {
    return 'Semana de $date';
  }

  @override
  String get analyticsLivesMinutesLabel => 'Tempo ao vivo';

  @override
  String get analyticsLivesChartLives => 'Lives por dia';

  @override
  String get analyticsLivesChartMinutes => 'Minutos ao vivo';

  @override
  String get analyticsLivesHistoryTitle => 'Histórico de lives';

  @override
  String get analyticsLivesMetricEarned => 'em presentes';

  @override
  String analyticsMinutesShort(String n) {
    return '$n min';
  }

  @override
  String analyticsHoursMinutes(String h, String m) {
    return '${h}h ${m}min';
  }

  @override
  String get analyticsRange7d => 'nos últimos 7 dias';

  @override
  String get analyticsRange30d => 'nos últimos 30 dias';

  @override
  String get analyticsRange90d => 'nos últimos 3 meses';

  @override
  String get analyticsRange365d => 'no último ano';

  @override
  String analyticsEmptyFollowersNew(String range) {
    return 'Nenhum seguidor novo $range';
  }

  @override
  String get analyticsEmptyFollowersTotal => 'Você ainda não tem seguidores';

  @override
  String analyticsEmptyEarnings(String range) {
    return 'Nenhum ganho $range';
  }

  @override
  String analyticsEmptyGifts(String range) {
    return 'Nenhum presente recebido $range';
  }

  @override
  String analyticsEmptyViewers(String range) {
    return 'Nenhum espectador $range';
  }

  @override
  String analyticsEmptyLives(String range) {
    return 'Nenhuma live $range';
  }

  @override
  String analyticsEmptyMinutes(String range) {
    return 'Nenhum minuto ao vivo $range';
  }

  @override
  String get analyticsHubTitle => 'Análises';

  @override
  String get analyticsTabOverview => 'Visão geral';

  @override
  String get analyticsTabFollowers => 'Seguidores';

  @override
  String get analyticsTabAudience => 'Audiência';

  @override
  String get analyticsTabLives => 'Lives';

  @override
  String get analyticsTabEarnings => 'Ganhos';

  @override
  String get analyticsOverviewTopGift => 'Presente em destaque';

  @override
  String get analyticsOverviewSeeDetails =>
      'Toque num indicador para ver os detalhes';

  @override
  String get gifterLevelTitle => 'Meu nível';

  @override
  String gifterLevelLevel(int level) {
    return 'Nível $level';
  }

  @override
  String gifterLevelXpProgress(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String gifterLevelXpMissing(String xp, int level) {
    return 'Faltam $xp XP para o nível $level';
  }

  @override
  String get gifterLevelMaxReached => 'Nível máximo alcançado';

  @override
  String get gifterLevelNextTier => 'Próxima faixa';

  @override
  String gifterLevelNextTierLine(String name, int level, String xp) {
    return '$name · nível $level · faltam $xp XP';
  }

  @override
  String get gifterLevelHowToEarn => 'Como ganhar XP';

  @override
  String gifterLevelRuleGiftPerCoin(int xp, String cap) {
    return 'Enviar presentes · $xp XP por moeda (até $cap por envio)';
  }

  @override
  String gifterLevelRuleGiftPerCoinNoCap(int xp) {
    return 'Enviar presentes · $xp XP por moeda';
  }

  @override
  String gifterLevelRuleGiftFlat(int xp) {
    return 'Enviar presentes · +$xp XP por presente';
  }

  @override
  String gifterLevelRuleWatch(int xp, int cap) {
    return 'Assistir lives · $xp XP por minuto (até $cap min)';
  }

  @override
  String gifterLevelRuleWatchNoCap(int xp) {
    return 'Assistir lives · $xp XP por minuto';
  }

  @override
  String gifterLevelRuleJoin(int xp) {
    return 'Entrar numa live · +$xp XP';
  }

  @override
  String gifterLevelRuleChat(int xp) {
    return 'Comentar no chat · +$xp XP';
  }

  @override
  String get gifterLevelTiers => 'Faixas';

  @override
  String gifterLevelRange(int from, int to) {
    return 'Nível $from–$to';
  }

  @override
  String gifterLevelRangeOpen(int from) {
    return 'Nível $from';
  }

  @override
  String gifterLevelXpRequired(String xp) {
    return '$xp XP';
  }

  @override
  String get gifterLevelBenefitVip => 'Entrada VIP';

  @override
  String get gifterLevelBenefitEntryEffect => 'Efeito de entrada';

  @override
  String get gifterLevelBenefitAnnounce => 'Anúncio ao subir de nível';

  @override
  String get gifterLevelYouAreHere => 'Você está aqui';

  @override
  String gifterLevelTierXpMissing(String xp) {
    return 'Faltam $xp XP';
  }

  @override
  String get gifterLevelLoadError => 'Não foi possível carregar seu nível.';

  @override
  String get gifterLevelRetry => 'Tentar de novo';

  @override
  String get gifterLevelSeeLevels => 'Ver níveis';

  @override
  String get gifterLevelStatusAchieved => 'Conquistada';

  @override
  String get gifterLevelStatusCurrent => 'Faixa atual';

  @override
  String get gifterLevelStatusLocked => 'Bloqueada';

  @override
  String get gifterLevelBackToCurrent => 'Voltar ao meu nível';

  @override
  String get gifterLevelBenefits => 'Benefícios';

  @override
  String get gifterLevelNoBenefits => 'Emblema exclusivo no chat';

  @override
  String get gifterLevelSwipeHint => 'Deslize para ver todas as faixas';

  @override
  String gifterLevelUnlockedAt(String xp) {
    return 'Conquistada ao chegar em $xp XP';
  }

  @override
  String gifterLevelTierProgress(String current, String total) {
    return 'Você tem $current de $total XP';
  }

  @override
  String gifterLevelTiersCount(int done, int total) {
    return '$done de $total faixas';
  }

  @override
  String get menuSectionProgress => 'Meu progresso';

  @override
  String get menuSectionMoney => 'Moedas e presentes';

  @override
  String get menuSectionCreator => 'Criador';

  @override
  String get menuSectionAccount => 'Conta';

  @override
  String get menuSectionProfile => 'Perfil';

  @override
  String get menuSectionPrivacy => 'Privacidade e segurança';

  @override
  String get menuQuestsSubtitle => 'Missões, conquistas e jornada';

  @override
  String get menuLevelSubtitle => 'Faixas, emblemas e XP';

  @override
  String get menuWalletSubtitle => 'Suas moedas para presentear';

  @override
  String get menuCreatorSubtitleMember => 'Painel, ganhos e análises';

  @override
  String get menuCreatorSubtitleJoin => 'Saiba como ganhar com suas lives';

  @override
  String get menuSettingsSubtitle => 'Privacidade, notificações e mais';

  @override
  String get creatorShortcutEarnings => 'Ganhos';

  @override
  String get notifFilterAll => 'Tudo';

  @override
  String get notifFilterLives => 'Lives';

  @override
  String get notifFilterSocial => 'Social';

  @override
  String get notifFilterMissions => 'Missões';

  @override
  String get notifFilterGifts => 'Presentes';

  @override
  String get notifFilterOther => 'Sistema';

  @override
  String get notifGroupToday => 'Hoje';

  @override
  String get notifGroupYesterday => 'Ontem';

  @override
  String get notifGroupWeek => 'Esta semana';

  @override
  String get notifGroupOlder => 'Anteriores';

  @override
  String get notifFilterEmpty => 'Nada por aqui nesta categoria';

  @override
  String get notifMarkAllTooltip => 'Marcar todas como lidas';

  @override
  String get linkSharedPost => '📎 Publicação compartilhada';

  @override
  String get chatViewOncePhoto => 'Foto';

  @override
  String get chatViewOnceTapToOpen => 'Toque para abrir · visualização única';

  @override
  String get chatViewOnceSent => 'Visualização única · enviada';

  @override
  String get chatViewOnceOpened => 'Aberta';

  @override
  String get chatCopied => 'Mensagem copiada';

  @override
  String get chatEmojiKeyboard => 'Teclado';

  @override
  String get chatDeleteForEveryone => 'Apagar para todos';

  @override
  String get chatDeleteForEveryoneTitle => 'Apagar para todos?';

  @override
  String get chatDeleteForEveryoneBody =>
      'A mensagem some para você e para a outra pessoa.';

  @override
  String get chatMessageDeleted => 'Mensagem apagada';

  @override
  String get chatErrLoadMessages => 'Não foi possível carregar as mensagens.';

  @override
  String get chatErrSend => 'Não foi possível enviar a mensagem.';

  @override
  String get chatErrReact => 'Não foi possível reagir à mensagem.';

  @override
  String get chatErrAudio => 'Não foi possível enviar o áudio.';

  @override
  String get chatErrImage => 'Não foi possível enviar a imagem.';

  @override
  String get chatErrDelete => 'Não foi possível apagar a mensagem.';

  @override
  String get chatErrLoadConversations =>
      'Não foi possível carregar as conversas.';

  @override
  String get chatErrArchive => 'Não foi possível arquivar a conversa.';

  @override
  String get chatErrUnarchive => 'Não foi possível desarquivar a conversa.';

  @override
  String get chatErrDeleteConversation => 'Não foi possível apagar a conversa.';

  @override
  String get chatErrStart => 'Não foi possível iniciar a conversa.';

  @override
  String get chatMicDenied => 'Permissão de microfone negada';

  @override
  String get chatErrEdit => 'Não foi possível editar a mensagem.';

  @override
  String get chatErrOpenGift =>
      'Não foi possível abrir o cofre. Tente de novo.';

  @override
  String get chatErrFile => 'Não foi possível enviar o arquivo.';

  @override
  String get chatEdit => 'Editar';

  @override
  String get chatEditTitle => 'Editar mensagem';

  @override
  String get chatEditSave => 'Salvar';

  @override
  String get chatEdited => 'editada';

  @override
  String get chatForward => 'Encaminhar';

  @override
  String get chatForwarded => 'Encaminhada';

  @override
  String get chatForwardTitle => 'Encaminhar para';

  @override
  String get chatForwardSent => 'Mensagem encaminhada';

  @override
  String get chatForwardEmpty => 'Você ainda não tem outras conversas';

  @override
  String get chatMsgSearchHint => 'Buscar mensagens';

  @override
  String get chatSearchEmpty => 'Nenhuma mensagem encontrada';

  @override
  String get chatSearchMinChars => 'Digite pelo menos 2 letras';

  @override
  String get chatUnmute => 'Ativar notificações';

  @override
  String get chatMutedToast => 'Conversa silenciada';

  @override
  String get chatUnmutedToast => 'Notificações ativadas';

  @override
  String get chatPin => 'Fixar conversa';

  @override
  String get chatUnpin => 'Desafixar conversa';

  @override
  String get chatPinnedToast => 'Conversa fixada no topo';

  @override
  String get chatUnpinnedToast => 'Conversa desafixada';

  @override
  String get chatPinLimit => 'Você pode fixar até 5 conversas';

  @override
  String get chatLocationTitle => 'Localização';

  @override
  String get chatLocationOpen => 'Abrir no mapa';

  @override
  String get chatLocationDenied =>
      'Permita o acesso à localização nos Ajustes para enviar.';

  @override
  String get chatLocationGetting => 'Obtendo sua localização…';

  @override
  String get chatLocationError => 'Não foi possível obter sua localização.';

  @override
  String get chatLocationConfirmTitle => 'Enviar sua localização atual?';

  @override
  String get chatLocationConfirmBody =>
      'A outra pessoa verá onde você está agora.';

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatFileOpen => 'Toque para abrir';

  @override
  String get chatStoryReacted => 'Reagiu ao seu story';

  @override
  String get chatStoryReactedMine => 'Você reagiu ao story';

  @override
  String get chatStoryReplied => 'Respondeu ao seu story';

  @override
  String get chatStoryRepliedMine => 'Você respondeu ao story';

  @override
  String get chatStoryUnavailable => 'Story não disponível';

  @override
  String get chatVaultReceived => 'Você recebeu um cofre!';

  @override
  String get chatVaultFromStory => 'Presente do seu story';

  @override
  String get chatVaultTapToOpen => 'Toque para abrir';

  @override
  String get chatVaultSentMine => 'Você enviou um cofre';

  @override
  String get chatVaultWaiting => 'Aguardando ser aberto';

  @override
  String get chatVaultOpenedBy => 'Cofre aberto';

  @override
  String get chatVaultYouGot => 'Você ganhou';

  @override
  String chatVaultEarnings(String value) {
    return '+$value nas suas recompensas de criador';
  }

  @override
  String get chatVaultCollect => 'Guardar';

  @override
  String get chatVaultSeeRewards => 'Ver recompensas';

  @override
  String get chatVaultTapHint => 'Toque no cofre!';

  @override
  String get chatVaultTierCommon => 'Comum';

  @override
  String get chatVaultTierRare => 'Raro';

  @override
  String get chatVaultTierEpic => 'Épico';

  @override
  String get chatVaultTierLegendary => 'Lendário';

  @override
  String get chatVaultReplay => 'Ver de novo';

  @override
  String onbStepOf(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get onbContinue => 'Continuar';

  @override
  String get onbSkip => 'Pular';

  @override
  String get onbSignOut => 'Sair da conta';

  @override
  String get onbError => 'Algo deu errado. Tente de novo.';

  @override
  String get onbBirthTitle => 'Quando você nasceu?';

  @override
  String get onbBirthSubtitle =>
      'Precisamos confirmar sua idade. Ela não aparece no seu perfil.';

  @override
  String get onbUnderageTitle => 'A Brawe é para maiores de 18 anos';

  @override
  String get onbUnderageBody =>
      'Pela segurança da comunidade, contas de menores de 18 anos não são permitidas.';

  @override
  String get onbUsernameTitle => 'Escolha seu @';

  @override
  String get onbUsernameSubtitle =>
      'É assim que as pessoas vão te encontrar e te marcar.';

  @override
  String get onbUsernameRules =>
      '3 a 30 caracteres: letras, números, ponto e _';

  @override
  String get onbUsernameChecking => 'Verificando…';

  @override
  String get onbUsernameAvailable => 'Disponível';

  @override
  String get onbPhotoTitle => 'Adicione uma foto';

  @override
  String get onbPhotoSubtitle =>
      'As pessoas confiam mais em perfis com foto. Ela é necessária para usar a Brawe.';

  @override
  String get onbPhotoGallery => 'Escolher da galeria';

  @override
  String get onbPhotoCamera => 'Tirar foto';

  @override
  String get onbPhotoChange => 'Trocar foto';

  @override
  String get onbPhotoPosition => 'Ajuste sua foto';

  @override
  String get onbPhotoError => 'Não foi possível enviar a foto. Tente de novo.';

  @override
  String get onbBioTitle => 'Conte um pouco sobre você';

  @override
  String get onbBioSubtitle =>
      'Uma frase curta para a sua bio. Dá para mudar depois.';

  @override
  String get onbBioHint => 'Ex.: Música, games e live toda sexta 🎮';

  @override
  String get onbFollowTitle => 'Siga pessoas';

  @override
  String get onbFollowSubtitle =>
      'Siga pelo menos 3 pessoas para ver conteúdo no seu feed.';

  @override
  String get onbFollow => 'Seguir';

  @override
  String get onbFollowing => 'Seguindo';

  @override
  String get onbFollowAll => 'Seguir todos';

  @override
  String onbFollowers(String count) {
    return '$count seguidores';
  }

  @override
  String get onbFollowEmpty =>
      'Ainda não temos sugestões. Você pode encontrar pessoas depois em \"Encontrar amigos\".';

  @override
  String get onbFinish => 'Começar';

  @override
  String get onbInterestsTitle => 'O que você curte?';

  @override
  String get onbInterestsSubtitle =>
      'Escolha os assuntos que você quer ver. Usamos isso para sugerir pessoas e conteúdos.';

  @override
  String onbInterestsCount(int count) {
    return '$count selecionados';
  }

  @override
  String get videoPubTrim => 'Cortar';

  @override
  String get videoPubCover => 'Capa';

  @override
  String get videoPubCoverAuto => 'Capa automática';

  @override
  String get videoPubCoverCustom => 'Capa personalizada';

  @override
  String get videoPubCoverFrame => 'Quadro do vídeo';

  @override
  String get videoPubCoverGallery => 'Imagem da galeria';

  @override
  String get videoPubCoverRemove => 'Usar capa automática';

  @override
  String get videoPubCoverTitle => 'Escolher capa';

  @override
  String get videoPubCoverFrameHint => 'Arraste para escolher o quadro da capa';

  @override
  String get videoPubCoverUse => 'Usar esta capa';

  @override
  String get videoPubCoverCrop => 'Ajustar capa';

  @override
  String get videoPubCoverError =>
      'Não foi possível gerar a capa. Tente outro quadro ou imagem.';

  @override
  String get videoPubStepVideo => 'Enviando vídeo...';

  @override
  String get videoPubStepCover => 'Enviando capa...';

  @override
  String get videoPubStepPost => 'Publicando...';

  @override
  String get videoPubCoverUploadError =>
      'Falha ao enviar a capa. Verifique sua conexão e tente de novo.';

  @override
  String get videoPubTrimPrepareError =>
      'Não foi possível preparar o vídeo cortado. Tente novamente.';

  @override
  String get signupErrName => 'Digite seu nome (mínimo 2 letras).';

  @override
  String get signupErrEmail => 'Digite um e-mail válido.';

  @override
  String get signupErrPassword =>
      'A senha precisa ter pelo menos 8 caracteres.';

  @override
  String get signupErrTerms =>
      'Você precisa aceitar os Termos e a Política de Privacidade.';

  @override
  String get signupErrEmailTaken =>
      'Este e-mail já tem conta. Entre com ele ou recupere a senha.';

  @override
  String get signupSendingCode => 'Enviando código…';

  @override
  String get codeTitle => 'Confirme seu e-mail';

  @override
  String codeSubtitle(String email) {
    return 'Enviamos um código de 6 dígitos para\n$email';
  }

  @override
  String get codeVerifying => 'Verificando…';

  @override
  String codeInvalid(int count) {
    return 'Código incorreto. Restam $count tentativas.';
  }

  @override
  String get codeInvalidSimple => 'Código incorreto.';

  @override
  String get codeExpired => 'O código expirou. Peça um novo.';

  @override
  String get codeTooMany => 'Muitas tentativas. Peça um novo código.';

  @override
  String get codeResend => 'Reenviar código';

  @override
  String codeResendIn(int seconds) {
    return 'Reenviar em ${seconds}s';
  }

  @override
  String get codeResent => 'Enviamos um novo código.';

  @override
  String get codeChangeEmail => 'Trocar e-mail';

  @override
  String get codeSpamHint =>
      'Não chegou? Confira a caixa de spam ou promoções.';

  @override
  String get codeError => 'Não foi possível enviar o código. Tente de novo.';

  @override
  String get codeTooManyRequests =>
      'Muitas tentativas a partir desta rede. Tente de novo em alguns minutos.';

  @override
  String get settingsThemeAutoHint =>
      'Segue o modo claro/escuro do seu celular. Com a troca automática do celular ligada, muda sozinho ao anoitecer e ao amanhecer.';

  @override
  String get battleYou => 'Você';

  @override
  String get battleMuteOpponent => 'Silenciar adversário';

  @override
  String get battleUnmuteOpponent => 'Ouvir adversário';

  @override
  String battleListenTo(String name) {
    return 'Ouvir $name';
  }

  @override
  String get battleRematch => 'Pedir revanche';

  @override
  String get battleRematchSent => 'Convite de revanche enviado';

  @override
  String get battleClose => 'Fechar';

  @override
  String get battleFollowing => 'Seguindo';

  @override
  String get battleLeaveTitle => 'Sair da batalha?';

  @override
  String get battleLeaveConfirm => 'Sair';

  @override
  String get battleCancel => 'Cancelar';

  @override
  String get battleLeave => 'Sair da batalha';

  @override
  String get battleActionLabel => 'Batalha';

  @override
  String get battleActionActive => 'Em batalha';

  @override
  String get battleErrNetwork => 'Sem conexão. Verifique sua internet.';

  @override
  String get battleErrGeneric => 'Não foi possível concluir. Tente novamente.';

  @override
  String battleErrCooldown(int seconds) {
    return 'Aguarde ${seconds}s para convidar este criador de novo.';
  }

  @override
  String get battleErrBlocked => 'Não é possível convidar este criador.';

  @override
  String get battleErrBusy => 'Este criador está ocupado em outra batalha.';

  @override
  String get battleErrExpired => 'Este convite expirou.';

  @override
  String get battleErrAnswered => 'Este convite já foi respondido.';

  @override
  String get battleErrNotEligible => 'Você ainda não pode iniciar batalhas.';

  @override
  String get battleErrSendInvite => 'Não foi possível enviar o convite.';

  @override
  String get battleErrAccept => 'Não foi possível aceitar a batalha.';

  @override
  String get battleErrRematch => 'Não foi possível pedir a revanche.';

  @override
  String get battleErrEnd => 'Não foi possível sair da batalha.';

  @override
  String battleInviteExpiresIn(int seconds) {
    return 'Expira em ${seconds}s';
  }

  @override
  String battleInviteAccepted(String name) {
    return '$name aceitou! Prepare-se';
  }

  @override
  String battleInviteDeclined(String name) {
    return '$name recusou o convite';
  }

  @override
  String battleInviteNoReply(String name) {
    return '$name não respondeu a tempo';
  }

  @override
  String get battleInviteExpired => 'O convite de batalha expirou';

  @override
  String get battleInviteCancelled => 'O convite de batalha foi cancelado';

  @override
  String get battleCancelledMsg => 'A batalha foi cancelada';

  @override
  String get battleInviteNoAnswer => 'Sem resposta ao convite de batalha';

  @override
  String get battleInviteWait =>
      'Aguarde a resposta do convite atual ou cancele-o';

  @override
  String get battleOpponentFallback => 'O oponente';

  @override
  String get battleSomeCreator => 'Um criador';

  @override
  String get battleRtcConnecting => 'Conectando com o adversário…';

  @override
  String get battleRtcFallback =>
      'Sem tempo real: a batalha segue em modo normal.';

  @override
  String get battleOpponentCamera => 'Aguardando câmera do adversário';

  @override
  String get battleStartTitle => 'Iniciar Batalha';

  @override
  String get battleSheetSubtitle => 'Criadores ao vivo disponíveis agora';

  @override
  String get battleSearchHint => 'Buscar criador ao vivo...';

  @override
  String get battleLoadCandidatesFailed =>
      'Não foi possível carregar criadores ao vivo';

  @override
  String get battleRetry => 'Tentar novamente';

  @override
  String battleNoCreatorQuery(String query) {
    return 'Nenhum criador disponível com \"$query\"';
  }

  @override
  String get battleNoCreator =>
      'Nenhum criador disponível para batalha agora.\nPuxe para atualizar.';

  @override
  String battleInviteCreator(String name) {
    return 'Convidar $name';
  }

  @override
  String get battleSelectCreator => 'Selecione um criador';

  @override
  String get battleLiveBadge => 'AO VIVO';

  @override
  String battleViewLive(String name) {
    return 'Ver a live de $name';
  }

  @override
  String battleWaitingAccept(String name, int seconds) {
    return 'Aguardando $name aceitar… ${seconds}s';
  }

  @override
  String get linkConnect => 'Conectar';

  @override
  String get linkDisconnect => 'Desconectar';

  @override
  String get linkStartTitle => 'Conectar com um criador';

  @override
  String linkInviteCreator(String name) {
    return 'Conectar com $name';
  }

  @override
  String linkInviteReceived(String name) {
    return '$name quer se conectar com você';
  }

  @override
  String get linkInviteWithBattle => 'Com batalha';

  @override
  String linkInviteAccepted(String name) {
    return '$name aceitou a conexão';
  }

  @override
  String get linkEnded => 'A conexão foi encerrada';

  @override
  String get linkDisconnectTitle => 'Desconectar?';

  @override
  String linkDisconnectBody(String name) {
    return 'A conexão com $name será encerrada. Se houver uma batalha em andamento, você desiste dela.';
  }

  @override
  String get linkFollowAction => '+ Seguir';

  @override
  String get linkErrDisconnect => 'Não foi possível desconectar.';

  @override
  String get linkErrInvite => 'Não foi possível enviar o convite de conexão.';

  @override
  String get linkErrAccept => 'Não foi possível aceitar a conexão.';

  @override
  String battleFlashChallenge(int count, String gift, String time) {
    return 'Envie $count $gift · $time';
  }

  @override
  String battleFlashProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String battleFlashBoost(String mult, String time) {
    return '${mult}X ativo · $time';
  }

  @override
  String get battleSealWin => 'VITÓRIA';

  @override
  String get battleSealLose => 'DERROTA';

  @override
  String get battleSealDraw => 'EMPATE';

  @override
  String get battleEndLabel => 'FIM';

  @override
  String battleMvpPill(String name, String score) {
    return 'MVP $name · $score';
  }

  @override
  String get battleRuleHint => 'Envie presentes para pontuar';

  @override
  String get viewLiveAction => 'Ver a live';

  @override
  String eventPageGiftsWorth(String mult) {
    return 'Presentes valem $mult pontos';
  }

  @override
  String eventPageEndsIn(String time) {
    return 'Termina em $time';
  }

  @override
  String get eventPageYourPosition => 'Sua posição';

  @override
  String eventPageRankPoints(int rank, String points) {
    return '#$rank · $points pts';
  }

  @override
  String eventPageToTop10(String points) {
    return 'faltam $points para o top 10';
  }

  @override
  String get eventPageInTop10 => 'Você está no top 10';

  @override
  String get eventPageNoRank => 'Você ainda não pontuou';

  @override
  String get eventPagePrizes => 'Prêmios';

  @override
  String get eventPageRanking => 'Ranking do evento';

  @override
  String get eventPageSeeFull => 'Ver ranking completo';

  @override
  String get eventPageGifts => 'Presentes do evento';

  @override
  String get eventPageSend => 'Enviar presente';

  @override
  String get eventPageHow => 'Como funciona';

  @override
  String eventPagePrizeRank(int from, int to) {
    return '$fromº–$toº';
  }

  @override
  String eventPagePrizeOne(int rank) {
    return '$rankº';
  }

  @override
  String get battleEndedTitle => 'BATALHA ENCERRADA';

  @override
  String battleEndedLeft(String name) {
    return '$name saiu da batalha';
  }

  @override
  String battleEndedLive(String name) {
    return 'A live de $name caiu';
  }

  @override
  String get battleEndedRtc => 'A conexão caiu';

  @override
  String battleLeaveBodyStreak(int n) {
    return 'Se você sair agora, ninguém vence e você perde sua sequência de $n vitórias.';
  }

  @override
  String get battleLeaveBodyNoStreak => 'Se você sair agora, ninguém vence.';

  @override
  String battleMutedLine(String name) {
    return 'Você e seu público não ouvem $name';
  }

  @override
  String battleMutedByLine(String name) {
    return '$name silenciou você';
  }

  @override
  String get battlePauseUnavailable =>
      'Pausar não está disponível durante a conexão ou a batalha';

  @override
  String get battleEndedLeftAnon => 'Um criador saiu da batalha';

  @override
  String get battleEndedLiveAnon => 'A live de um criador caiu';

  @override
  String get battleNarrStart => 'A batalha começou! Cada presente conta';

  @override
  String battleNarrLeadOwn(String team) {
    return 'VIROU! $team passou na frente';
  }

  @override
  String battleNarrLeadOther(String team) {
    return '$team passou na frente. Bora virar!';
  }

  @override
  String battleNarrMomentum(String team) {
    return '$team está pegando fogo';
  }

  @override
  String battleNarrFlashStart(String pontos, String nome, String tempo) {
    return 'Desafio relâmpago: envie $pontos $nome em $tempo';
  }

  @override
  String battleNarrFlashDone(String mult, String tempo) {
    return 'Desafio feito! $mult por $tempo';
  }

  @override
  String battleNarrFinal10(String mult) {
    return 'Últimos 10 segundos! Cada presente vale $mult';
  }

  @override
  String battleNarrVictory(String team) {
    return 'VITÓRIA de $team!';
  }

  @override
  String battleNarrDefeat(String team) {
    return 'Fim! $team venceu desta vez';
  }

  @override
  String get battleNarrDraw => 'EMPATE!';

  @override
  String get battleNarrEnded => 'Batalha encerrada';

  @override
  String get agencyTitle => 'Minha agência';

  @override
  String agencyPendingInvites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count convites',
      one: '1 convite',
    );
    return '$_temp0';
  }

  @override
  String get agencyEmptyBody =>
      'Agências ajudam criadores a crescer: acompanham seus resultados, organizam eventos e apoiam sua rotina de lives.';

  @override
  String get agencyInfoEarningsBody =>
      'A Brawe continua pagando seus ganhos diretamente a você. A comissão da agência é paga pela Brawe, nunca descontada de você.';

  @override
  String get agencyInfoOneBody =>
      'Você só pode estar em uma agência. Ao aceitar um convite, os outros pendentes são cancelados.';

  @override
  String get agencyOpenBody =>
      'Agências podem encontrar você no diretório de criadores e enviar convites. Você decide se aceita.';

  @override
  String get agencyInvitesTitle => 'Convites pendentes';

  @override
  String get agencyInviteTitle => 'Convite de agência';

  @override
  String agencyContractMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mês',
    );
    return '$_temp0';
  }

  @override
  String agencyContractOf(String duration) {
    return 'Contrato de $duration';
  }

  @override
  String get agencyContractLength => 'Duração do contrato';

  @override
  String get agencyInvitedByTitle => 'Quem convidou';

  @override
  String get agencyRoleOwner => 'Dono da agência';

  @override
  String get agencyRoleManager => 'Gerente da agência (recrutador)';

  @override
  String get agencyRoleAnalyst => 'Equipe da agência';

  @override
  String get agencyRoleUnknown => 'Representante da agência';

  @override
  String agencyInvitedOn(String date) {
    return 'Convite enviado em $date';
  }

  @override
  String get agencyMessageTitle => 'Mensagem da agência';

  @override
  String get agencyWhatChangesTitle => 'O que muda para você';

  @override
  String get agencyTermsTitle => 'Termos e condições';

  @override
  String agencyTermsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get agencyTermsStandard => 'Termos padrão Brawe';

  @override
  String get agencyTermsAddendum => 'Adendo da agência';

  @override
  String get agencyTermsEmpty => 'Termos indisponíveis no momento.';

  @override
  String agencyAcceptCheckbox(String version) {
    return 'Li e aceito os termos e condições (versão $version)';
  }

  @override
  String get agencyAcceptButton => 'Aceitar convite';

  @override
  String get agencyDeclineButton => 'Recusar';

  @override
  String agencyAcceptConfirmTitle(String name) {
    return 'Entrar na $name?';
  }

  @override
  String get agencyAcceptConfirmBody =>
      'Seu vínculo começa hoje. Antes do fim do contrato, a saída é feita em acordo com a agência.';

  @override
  String get agencyDeclineConfirmTitle => 'Recusar convite?';

  @override
  String get agencyDeclineConfirmBody =>
      'Recusar não tem nenhum efeito na sua conta. A agência verá que o convite foi recusado.';

  @override
  String agencyAcceptedSnack(String name) {
    return 'Você agora faz parte de $name';
  }

  @override
  String get agencyDeclinedSnack => 'Convite recusado';

  @override
  String get agencyLeftSnack => 'Você saiu da agência';

  @override
  String get agencyInviteUnavailable =>
      'Este convite não está mais disponível.';

  @override
  String agencyCreatorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count criadores',
      one: '1 criador',
    );
    return '$_temp0';
  }

  @override
  String agencyPartnerSince(String date) {
    return 'Parceira desde $date';
  }

  @override
  String get agencyTrialBadge => 'Em teste';

  @override
  String get agencyContractTitle => 'Contrato';

  @override
  String agencyContractPeriod(String start, String end) {
    return '$start a $end';
  }

  @override
  String agencyDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltam $days dias',
      one: 'Falta 1 dia',
      zero: 'Termina hoje',
    );
    return '$_temp0';
  }

  @override
  String agencyContractProgress(int percent) {
    return '$percent% do contrato';
  }

  @override
  String get agencyHours => 'Horas ao vivo';

  @override
  String get agencyDaysLive => 'Dias com live';

  @override
  String get agencyDiamonds => 'Diamantes';

  @override
  String get agencyFollowers => 'Seguidores';

  @override
  String agencyRankValue(int rank, int total) {
    return '#$rank de $total';
  }

  @override
  String get agencyGuidelinesNotMet => 'Ainda faltam metas neste mês';

  @override
  String agencyMissingHours(String value) {
    return 'Faltam $value h';
  }

  @override
  String agencyMissingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltam $days dias',
      one: 'Falta 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get agencyNoIncidents => 'Nenhuma ocorrência';

  @override
  String get agencyIncidentWarning => 'Advertência';

  @override
  String get agencyIncidentSuspension => 'Suspensão';

  @override
  String get agencyIncidentBan => 'Banimento';

  @override
  String get agencyIncidentFraud => 'Fraude';

  @override
  String get agencyEventsHow =>
      'Entre ao vivo durante o período do evento para participar.';

  @override
  String get agencyEventLive => 'Ao vivo';

  @override
  String get agencyEventScheduled => 'Em breve';

  @override
  String get agencyEventEnded => 'Encerrado';

  @override
  String agencyEventMultiplier(String value) {
    return 'Multiplicador x$value';
  }

  @override
  String get agencyLeaveTitle => 'Sair da agência';

  @override
  String get agencyLeaveAllowed =>
      'Você pode sair agora, sem multa. Seus ganhos e sua conta não mudam.';

  @override
  String get agencyLeaveButton => 'Sair da agência';

  @override
  String agencyLeaveConfirmTitle(String name) {
    return 'Sair de $name?';
  }

  @override
  String get agencyLeaveConfirmBody =>
      'O vínculo será encerrado. Isso não pode ser desfeito: para voltar, você precisará receber um novo convite.';

  @override
  String get agencyLeaveConfirmAction => 'Sair agora';

  @override
  String get agencyExitRuleFree =>
      'No fim do contrato você sai livremente, pelo app.';

  @override
  String get agencyExitRuleAbuse =>
      'Em caso de abuso (cobranças, pagamentos fora da Brawe, pressão), peça uma análise da Brawe.';

  @override
  String get agencyLeaveSectionTitle => 'Saída da agência';

  @override
  String agencyLeaveRequestBody(String date) {
    return 'Seu contrato vai até $date. Para sair antes, você pede o desligamento em acordo com a agência. Se ela não responder no prazo, você fica livre automaticamente.';
  }

  @override
  String get agencyLeaveRequestBodyNoDate =>
      'Para sair antes do fim do contrato, você pede o desligamento em acordo com a agência. Se ela não responder no prazo, você fica livre automaticamente.';

  @override
  String get agencyLeaveRequestButton => 'Pedir desligamento à agência';

  @override
  String get agencyLeaveRequestSheetTitle => 'Pedir desligamento';

  @override
  String get agencyLeaveRequestSheetBody =>
      'A agência recebe seu pedido e responde. Se aprovar, o vínculo termina na hora. Se não responder no prazo, você fica livre automaticamente.';

  @override
  String get agencyLeaveReasonLabel => 'Motivo';

  @override
  String get agencyLeaveReasonHint => 'Conte à agência por que quer sair';

  @override
  String get agencyLeaveRequestSend => 'Enviar pedido';

  @override
  String get agencyLeaveRequestSentSnack => 'Pedido enviado à agência.';

  @override
  String get agencyLeavePendingTitle => 'Pedido de desligamento enviado';

  @override
  String agencyLeavePendingSent(String date) {
    return 'Enviado em $date. Aguardando a resposta da agência.';
  }

  @override
  String agencyLeavePendingDue(String date) {
    return 'Se a agência não responder até $date, você fica livre automaticamente.';
  }

  @override
  String get agencyLeavePendingBrawe => 'Seu pedido está em análise da Brawe.';

  @override
  String get agencyReviewPendingTitle => 'Análise da Brawe solicitada';

  @override
  String get agencyLeaveCancel => 'Cancelar pedido';

  @override
  String get agencyLeaveCancelledSnack => 'Pedido cancelado.';

  @override
  String get agencyLeaveDeclinedTitle => 'Pedido recusado';

  @override
  String get agencyLeaveDeclinedBody =>
      'A agência não aprovou a sua saída por enquanto.';

  @override
  String get agencyLeaveAgencyAnswer => 'Resposta da agência';

  @override
  String agencyLeaveRetryAt(String date) {
    return 'Você poderá pedir de novo a partir de $date.';
  }

  @override
  String get agencyReviewLink => 'Pedir análise da Brawe';

  @override
  String get agencyReviewSheetTitle => 'Pedir análise da Brawe';

  @override
  String get agencyReviewSheetBody =>
      'Use só se houver abuso. A Brawe analisa direto, sem passar pela agência, e pode encerrar o vínculo.';

  @override
  String get agencyReviewCategoryLabel => 'O que está acontecendo?';

  @override
  String get agencyReviewCatMoney => 'A agência cobra dinheiro de mim';

  @override
  String get agencyReviewCatOffplatform => 'Pedem pagamentos fora da Brawe';

  @override
  String get agencyReviewCatPressure => 'Pressão ou assédio';

  @override
  String get agencyReviewCatSuspended => 'A agência foi suspensa ou banida';

  @override
  String get agencyReviewCatOther => 'Outro motivo';

  @override
  String get agencyReviewDetailLabel => 'Detalhes';

  @override
  String get agencyReviewSend => 'Enviar à Brawe';

  @override
  String get agencyReviewSentSnack => 'Pedido enviado. A Brawe vai analisar.';

  @override
  String get agencyErrLeaveRequiresAgreement =>
      'Antes do fim do contrato, peça o desligamento à agência.';

  @override
  String get agencyErrLeaveRequestOpen => 'Você já tem um pedido em aberto.';

  @override
  String agencyErrLeaveCooldown(String date) {
    return 'Você poderá pedir de novo a partir de $date.';
  }

  @override
  String get agencyErrLeaveCooldownNoDate =>
      'Aguarde um pouco para pedir de novo.';

  @override
  String get agencyErrLeaveNotOpen =>
      'Este pedido já foi respondido ou cancelado.';

  @override
  String get agencyErrReasonTooLong => 'O texto passa de 500 caracteres.';

  @override
  String get agencyReasonMinHint => 'Mínimo de 10 caracteres';

  @override
  String get agencyErrReasonTooShort => 'Escreva pelo menos 10 caracteres.';

  @override
  String get agencyErrReasonRequired => 'Escreva o motivo.';

  @override
  String get agencyErrLeaveIsFree =>
      'O contrato terminou: você já pode sair direto.';

  @override
  String get agencyLoadError => 'Não foi possível carregar sua agência';

  @override
  String get agencyErrTermsMismatch =>
      'Os termos foram atualizados. Leia a versão atual e tente de novo.';

  @override
  String agencyErrCannotLeaveYet(String date) {
    return 'Você ainda não pode sair. Liberado em $date.';
  }

  @override
  String get agencyErrCannotLeaveYetNoDate =>
      'Você ainda não pode sair da agência.';

  @override
  String get agencyErrAlreadyInAgency => 'Você já está em uma agência.';

  @override
  String get agencyErrNotApproved =>
      'Esta agência não está disponível no momento.';

  @override
  String get agencyErrNotEligible => 'Seu perfil de criador não está ativo.';

  @override
  String get agencyErrNotFound => 'Convite não encontrado.';

  @override
  String get agencyErrNotInAgency => 'Você não está em uma agência.';

  @override
  String get agencyErrNetwork =>
      'Sem conexão. Verifique sua internet e tente de novo.';

  @override
  String get agencyErrGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String get agencyChatInvitedYou => 'convidou você para a agência';

  @override
  String get agencyChatInviteSent => 'Convite enviado ao criador';

  @override
  String get agencyChatOpen => 'Abrir convite';

  @override
  String get agencyChatPreview => 'Convite de agência';

  @override
  String get creatorPanelTabHome => 'Início';

  @override
  String get creatorPanelTabPerformance => 'Desempenho';

  @override
  String get creatorPanelTabAgency => 'Agência';

  @override
  String get creatorPanelTabBenefits => 'Benefícios';

  @override
  String get creatorPanelEarnings30 => 'Ganhos em 30 dias';

  @override
  String get creatorPanelNextLevel => 'Próximo nível';

  @override
  String get creatorPanelAgenciesRow => 'Agências';

  @override
  String get creatorPanelAgenciesOpen => 'Aberto a convites';

  @override
  String get creatorPanelHowItWorks => 'Como funciona';

  @override
  String get creatorPanelHowTitle => 'Como funcionam as agências';

  @override
  String get creatorPanelAnalyticsTitle => 'Análises completas';

  @override
  String get creatorPanelAnalyticsBody => 'Ganhos, público, seguidores e lives';

  @override
  String get creatorPanelProfileFallback => 'Criador';

  @override
  String get creatorPanelOpenError => 'Não foi possível salvar. Tente de novo.';

  @override
  String agencySince(String date) {
    return 'Agenciado desde $date';
  }

  @override
  String get agencyTalk => 'Falar';

  @override
  String get agencyTalkError => 'Não foi possível abrir a conversa.';

  @override
  String get agencySubSummary => 'Resumo';

  @override
  String get agencySubGoals => 'Metas';

  @override
  String get agencySubEvents => 'Eventos';

  @override
  String get agencySubContract => 'Contrato';

  @override
  String get agencyPeriodThisMonth => 'Este mês';

  @override
  String get agencyPeriodLabel => 'Período';

  @override
  String agencyRankUp(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Subiu $n posições',
      one: 'Subiu 1 posição',
    );
    return '$_temp0';
  }

  @override
  String agencyRankDown(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Caiu $n posições',
      one: 'Caiu 1 posição',
    );
    return '$_temp0';
  }

  @override
  String get agencyRankSame => 'Mesma posição do mês anterior';

  @override
  String get agencyPositionLabel => 'Posição na agência';

  @override
  String get agencyMonthGoalTitle => 'Meta do mês';

  @override
  String agencyMonthGoalPercent(String percent) {
    return '$percent% da meta';
  }

  @override
  String get agencyMonthGoalMet => 'Meta batida';

  @override
  String get agencyMonthGoalNone => 'Sem meta definida para este mês';

  @override
  String get agencyChartTitle => 'Últimos 6 meses';

  @override
  String get agencyChartEmpty => 'Sem dados nos últimos meses';

  @override
  String get agencyPerfError => 'Não foi possível carregar o desempenho';

  @override
  String get agencyGoalDone => 'Meta cumprida';

  @override
  String agencyGoalHoursValue(String have, String need) {
    return '$have de $need h';
  }

  @override
  String agencyGoalDaysValue(String have, String need) {
    return '$have de $need dias';
  }

  @override
  String get agencyIncFilterMonth => 'Do mês';

  @override
  String get agencyIncFilter90 => 'Últimos 90 dias';

  @override
  String agencyIncidentPoints(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points pontos',
      one: '1 ponto',
    );
    return '$_temp0';
  }

  @override
  String get agencyEventsFilterUpcoming => 'Próximos';

  @override
  String get agencyEventsFilterLive => 'Em andamento';

  @override
  String get agencyEventsFilterEnded => 'Encerrados';

  @override
  String get agencyEventsEmptyUpcoming => 'Nenhum evento agendado.';

  @override
  String get agencyEventsEmptyLive => 'Nenhum evento em andamento agora.';

  @override
  String get agencyEventsEmptyEnded => 'Nenhum evento encerrado.';

  @override
  String get agencyContractViewTerms => 'Ver termos';

  @override
  String get agencyContractUnknown => 'Contrato sem data de término';

  @override
  String get agencyLeaveRequestConfirmTitle => 'Enviar pedido de desligamento?';

  @override
  String get agencyLeaveRequestConfirmBody =>
      'A agência precisa aprovar. Se ela não responder no prazo, você fica livre automaticamente.';

  @override
  String get agencyReviewConfirmTitle => 'Pedir análise da Brawe?';

  @override
  String get agencyReviewConfirmBody =>
      'Use apenas em caso de abuso. A Brawe analisa direto, sem passar pela agência.';

  @override
  String agencyLeaveSentOn(String date) {
    return 'Enviado em $date';
  }

  @override
  String agencyInvitesBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você tem $count convites de agência',
      one: 'Você tem 1 convite de agência',
    );
    return '$_temp0';
  }

  @override
  String get agencyInvitesView => 'Ver';

  @override
  String agencyInviteRowBy(String name, String role) {
    return '$name · $role';
  }

  @override
  String get agencyInvitesEmpty => 'Nenhum convite pendente.';

  @override
  String get agencyPerkEarnings => 'Ganhos pagos pela Brawe';

  @override
  String get agencyPerkNoCharges => 'Nenhuma cobrança';

  @override
  String get agencyPerkAccount => 'Você mantém sua conta';

  @override
  String get agencyPerkExit =>
      'Saída no fim do contrato ou em acordo; sem resposta da agência no prazo, você fica livre';

  @override
  String get agencyTermsRead => 'Ler termos completos';

  @override
  String get agencyTermsExpand => 'Termos e condições';

  @override
  String get agencyIncidentsTitleShort => 'Ocorrências';

  @override
  String get creatorDashWeekSameShort => 'Igual';

  @override
  String get agencyAcceptedLabel => 'Aceito em';

  @override
  String get agencyExitRuleAgreement =>
      'Antes do fim, a saída é em acordo com a agência. Se ela não responder no prazo (15 dias), você fica livre e pode entrar em outra agência.';

  @override
  String get creatorApplyBack => 'Voltar';

  @override
  String get creatorApplyNext => 'Continuar';

  @override
  String get creatorApplyAsAccount => 'Vamos usar os dados da sua conta Brawe.';

  @override
  String get creatorApplyStepContent => 'Seu conteúdo';

  @override
  String get creatorApplyStepNetwork => 'Sua rede';

  @override
  String get creatorApplyStepAbout => 'Sobre você';

  @override
  String creatorApplyStepOf(int n, int total) {
    return 'Etapa $n de $total';
  }

  @override
  String get creatorApplyPlatformLabel => 'Rede principal';

  @override
  String get creatorApplyHandleLabel => 'Seu usuário nessa rede';

  @override
  String get creatorApplyHandleWhy =>
      'Precisamos do seu perfil em uma rede social para analisar seu conteúdo e sua audiência. Só a equipe de aprovação vê.';

  @override
  String get creatorApplyErrHandle =>
      'Use apenas letras, números, ponto, hífen ou sublinhado (mín. 2)';

  @override
  String creatorApplyErrMotivation(int min) {
    return 'Escreva pelo menos $min caracteres';
  }

  @override
  String get creatorApplyErrFollowersMin =>
      'Informe quantos seguidores você tem (mínimo 1)';

  @override
  String get editProfileCreatorBadgeTitle => 'Mostrar selo de creator';

  @override
  String get editProfileCreatorBadgeHint =>
      'Exibe o selo da Creator Network no seu perfil.';

  @override
  String get editProfileCreatorBadgeSaveFailed =>
      'Não foi possível salvar a visibilidade do selo.';

  @override
  String get videoPubSound => 'Som';

  @override
  String videoPubCoverAt(String time) {
    return 'Capa em $time';
  }

  @override
  String get videoUpQueued => 'Na fila…';

  @override
  String videoUpUploading(int percent) {
    return 'Publicando… $percent%';
  }

  @override
  String get videoUpProcessing => 'Processando…';

  @override
  String get videoUpFailed => 'Falhou no envio';

  @override
  String get videoUpRetry => 'Tentar de novo';

  @override
  String get videoUpDone => 'Vídeo publicado';

  @override
  String get videoUpView => 'Ver';

  @override
  String get videoUpCancel => 'Cancelar envio';

  @override
  String get videoUpDismiss => 'Fechar';

  @override
  String get chatSystemReadOnlyNote => 'Mensagens oficiais da Brawe';

  @override
  String get chatSystemOfficialLabel => 'Conta oficial';

  @override
  String navChatUnreadSemantics(int count) {
    return 'Chat, $count conversas não lidas';
  }

  @override
  String get gifSearchHint => 'Buscar GIFs';

  @override
  String get gifClearSearch => 'Limpar busca';

  @override
  String get gifPoweredBy => 'Powered by GIPHY';

  @override
  String get gifUnavailable => 'GIFs indisponíveis no momento';

  @override
  String get gifErrorGeneric => 'Não foi possível carregar os GIFs.';

  @override
  String get gifRetry => 'Tentar de novo';

  @override
  String get gifEmptyTitle => 'Nenhum GIF encontrado';

  @override
  String get gifEmptyHint => 'Tente outra palavra.';

  @override
  String get gifSemantics => 'GIF';

  @override
  String get gifTapToPause => 'Toque para pausar';

  @override
  String get gifTapToPlay => 'Toque para reproduzir';

  @override
  String get gifButtonSemantics => 'Enviar um GIF';

  @override
  String get notifFilterLikes => 'Curtidas';

  @override
  String get notifFilterComments => 'Comentários';

  @override
  String get notifFilterFollowers => 'Seguidores';

  @override
  String get notifFilterMentions => 'Menções';

  @override
  String get notifFilterBrawe => 'Brawe';

  @override
  String notifActorsTwo(String a, String b) {
    return '$a e $b';
  }

  @override
  String notifActorsThree(String a, String b, String c) {
    return '$a, $b e $c';
  }

  @override
  String notifActorsMore(String a, String b, int n) {
    return '$a, $b e mais $n';
  }

  @override
  String notifVerbLike(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'curtiram seu post',
      one: 'curtiu seu post',
    );
    return '$_temp0';
  }

  @override
  String notifVerbComment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'comentaram no seu post',
      one: 'comentou no seu post',
    );
    return '$_temp0';
  }

  @override
  String notifVerbReply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'responderam seu comentário',
      one: 'respondeu seu comentário',
    );
    return '$_temp0';
  }

  @override
  String notifVerbFollow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'começaram a seguir você',
      one: 'começou a seguir você',
    );
    return '$_temp0';
  }

  @override
  String notifVerbGift(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'enviaram presentes na sua live',
      one: 'enviou presentes na sua live',
    );
    return '$_temp0';
  }

  @override
  String notifVerbMention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'marcaram você em comentários',
      one: 'marcou você num comentário',
    );
    return '$_temp0';
  }

  @override
  String notifVerbStoryReaction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'reagiram ao seu story',
      one: 'reagiu ao seu story',
    );
    return '$_temp0';
  }

  @override
  String notifGiftDiamonds(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '($value diamantes)',
      one: '($value diamante)',
    );
    return '$_temp0';
  }

  @override
  String get notifNewFollowersTitle => 'Novos seguidores';

  @override
  String get notifNewFollowersEmpty => 'Nenhum seguidor novo para mostrar';

  @override
  String get notifUnreadLabel => 'Não lida';

  @override
  String get storyGiftSend => 'Enviar';

  @override
  String storyGiftConfirmTitle(String gift, String price) {
    return 'Enviar $gift por $price?';
  }

  @override
  String storyGiftBalance(String balance) {
    return 'Saldo: $balance';
  }

  @override
  String storyUpUploading(int percent) {
    return 'Publicando story… $percent%';
  }

  @override
  String get storyUpProcessing => 'Publicando story…';

  @override
  String get storyUpDone => 'Story publicado';

  @override
  String get storyUpFailed => 'Falhou ao publicar o story';

  @override
  String get sessionEndedMessage =>
      'Sua sessão foi encerrada. Entre novamente.';

  @override
  String get stepUpTitle => 'Confirme que é você';

  @override
  String stepUpSubtitle(String email) {
    return 'Enviamos um código para $email';
  }

  @override
  String get stepUpHint =>
      'Detectamos um acesso de um aparelho novo. Digite o código para entrar.';

  @override
  String get stepUpBack => 'Voltar ao login';

  @override
  String stepUpTooMany(String time) {
    return 'Muitas tentativas. Tente de novo em $time.';
  }

  @override
  String get secTitle => 'Segurança';

  @override
  String get secSettingsEntrySub =>
      'Aparelhos conectados, histórico de acessos e proteção da conta';

  @override
  String get secTabDevices => 'Aparelhos';

  @override
  String get secTabHistory => 'Histórico';

  @override
  String get secTabProtect => 'Proteção';

  @override
  String get secDevicesTitle => 'Aparelhos conectados';

  @override
  String get secDevicesSubtitle =>
      'Estes aparelhos estão com a sua conta aberta.';

  @override
  String get secThisDevice => 'Este aparelho';

  @override
  String get secActiveNow => 'Ativo agora';

  @override
  String secLastActive(String time) {
    return 'Ativo $time';
  }

  @override
  String secTimeMinutes(int n) {
    return 'há $n min';
  }

  @override
  String secTimeHours(int n) {
    return 'há $n h';
  }

  @override
  String secTimeDays(int n) {
    return 'há $n d';
  }

  @override
  String get secEndSession => 'Encerrar sessão';

  @override
  String get secEndSessionTitle => 'Encerrar a sessão neste aparelho?';

  @override
  String secEndSessionBody(String device) {
    return '$device será desconectado e precisará entrar de novo.';
  }

  @override
  String get secEndedOk => 'Sessão encerrada.';

  @override
  String get secSignOutOthers => 'Sair de todos os outros aparelhos';

  @override
  String get secSignOutOthersTitle => 'Sair dos outros aparelhos?';

  @override
  String get secSignOutOthersBody =>
      'Todos os aparelhos, menos este, serão desconectados.';

  @override
  String get secSignedOutOthersOk => 'Os outros aparelhos foram desconectados.';

  @override
  String get secNoOtherDevices => 'Nenhum outro aparelho conectado.';

  @override
  String get secDevicesEmpty => 'Nenhuma sessão ativa encontrada.';

  @override
  String get secLoadError => 'Não foi possível carregar agora.';

  @override
  String get secUnavailable =>
      'Este recurso ainda não está disponível. Tente novamente em breve.';

  @override
  String get secActionError => 'Não foi possível concluir. Tente de novo.';

  @override
  String get secClientApp => 'App Brawe';

  @override
  String get secClientPartners => 'Brawe Partners';

  @override
  String get secClientWeb => 'Navegador';

  @override
  String secAppVersion(String v) {
    return 'versão $v';
  }

  @override
  String get secUnknownDevice => 'Aparelho desconhecido';

  @override
  String get secUnknownPlace => 'Local não identificado';

  @override
  String get secHistoryTitle => 'Histórico de acessos';

  @override
  String get secFilterAll => 'Todos';

  @override
  String get secFilterLogins => 'Logins';

  @override
  String get secFilterFailures => 'Falhas';

  @override
  String get secFilterChanges => 'Alterações';

  @override
  String get secHistoryEmpty => 'Nenhum evento neste filtro.';

  @override
  String get secLoadMore => 'Carregar mais';

  @override
  String get secEvLogin => 'Login';

  @override
  String get secEvLoginFailed => 'Tentativa de login falhou';

  @override
  String get secEvLoginBlocked => 'Login bloqueado';

  @override
  String get secEvLogout => 'Saída da conta';

  @override
  String get secEvSessionRevoked => 'Sessão encerrada';

  @override
  String get secEvSessionsRevokedAll => 'Outros aparelhos desconectados';

  @override
  String get secEvPasswordChanged => 'Senha alterada';

  @override
  String get secEvPasswordResetRequested => 'Redefinição de senha solicitada';

  @override
  String get secEvPasswordReset => 'Senha redefinida';

  @override
  String get secEvQrLogin => 'Login por QR code';

  @override
  String get secEvLoginCode => 'Login por código';

  @override
  String get secEvStepUpRequired => 'Verificação pedida';

  @override
  String get secEvStepUpPassed => 'Verificação concluída';

  @override
  String get secEvNewDeviceAlert => 'Alerta de aparelho novo';

  @override
  String get secEvUnknown => 'Evento de segurança';

  @override
  String get secProtectTitle => 'Não reconhece um acesso?';

  @override
  String get secProtectBody =>
      'Se viu algo estranho, proteja sua conta agora: saímos de todos os outros aparelhos e você define uma senha nova.';

  @override
  String get secProtectButton => 'Proteger minha conta';

  @override
  String get secProtectSheetTitle => 'Proteger sua conta';

  @override
  String get secProtectSheetIntro => 'Vamos fazer duas coisas agora:';

  @override
  String get secProtectStep1 =>
      'Sair de todos os outros aparelhos. Você continua conectado aqui.';

  @override
  String get secProtectStep2 =>
      'Pedir que você crie uma senha nova. Essa etapa é obrigatória.';

  @override
  String get secProtectConfirm => 'Proteger agora';

  @override
  String get secCancel => 'Cancelar';

  @override
  String get secRetry => 'Tentar novamente';

  @override
  String get secProtectError =>
      'Não foi possível proteger a conta. Tente de novo.';

  @override
  String get secChangePasswordSub => 'Escolha uma senha nova e forte';

  @override
  String get secPasswordRequired =>
      'Por segurança, defina uma senha nova para continuar.';

  @override
  String get secGeoAttribution => 'IP Geolocation by DB-IP';

  @override
  String get secSettingsEntry => 'Segurança';

  @override
  String get payoutBalanceAvailable => 'Disponível para saque';

  @override
  String payoutBalanceApprox(String value) {
    return 'Aproximadamente $value';
  }

  @override
  String get payoutBalanceNoRate => 'Valor em reais indisponível agora';

  @override
  String get payoutBalanceHolding => 'Aguardando liberação';

  @override
  String get payoutBalanceInProgress => 'Em saque';

  @override
  String get payoutBalanceWithdrawn => 'Já sacado';

  @override
  String payoutBalanceReleaseNote(String date, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '$days dia',
    );
    return 'Cada presente fica $_temp0 em análise. Próxima liberação: $date.';
  }

  @override
  String get payoutBalanceWithdraw => 'Sacar';

  @override
  String get payoutBalanceAddAccountFirst => 'Cadastrar conta para sacar';

  @override
  String payoutBalanceMinimum(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias úteis',
      one: '$days dia útil',
    );
    return 'Saque mínimo de $amount. Pagamento em até $_temp0.';
  }

  @override
  String get payoutBalanceHowTitle => 'Como chegamos nesse valor';

  @override
  String get payoutBalanceReceived => 'Recebido em presentes';

  @override
  String payoutBalanceFromLive(String value) {
    return 'Lives $value';
  }

  @override
  String payoutBalanceFromStory(String value) {
    return 'Stories $value';
  }

  @override
  String payoutBalanceFromOther(String value) {
    return 'Outros $value';
  }

  @override
  String payoutBalanceHoldingHint(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '$days dia',
    );
    return 'Cada presente fica $_temp0 em análise antes de liberar.';
  }

  @override
  String get payoutBalanceInProgressHint => 'Pedidos aguardando pagamento.';

  @override
  String get payoutBalanceAvailableShort => 'Disponível';

  @override
  String get payoutSoonTitle => 'Saques em breve';

  @override
  String get payoutSoonSubtitle =>
      'Seus diamantes já estão acumulando. Avisaremos quando os saques forem liberados.';

  @override
  String get payoutOpenTitle => 'Saque em andamento';

  @override
  String payoutOpenDiamonds(String diamonds) {
    return '$diamonds diamantes';
  }

  @override
  String payoutOpenRequestedNote(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias úteis',
      one: '$days dia útil',
    );
    return 'Estamos analisando seu pedido. O pagamento sai em até $_temp0 após a aprovação.';
  }

  @override
  String payoutOpenApprovedNote(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias úteis',
      one: '$days dia útil',
    );
    return 'Pedido aprovado. O pagamento sai em até $_temp0.';
  }

  @override
  String payoutOpenRequestedAt(String date) {
    return 'Pedido em $date';
  }

  @override
  String get payoutOpenCancelConfirm =>
      'Cancelar este saque? Os diamantes voltam para o seu saldo.';

  @override
  String get payoutOpenKeep => 'Manter';

  @override
  String get payoutOpenCancelYes => 'Cancelar saque';

  @override
  String get payoutOpenCancel => 'Cancelar saque';

  @override
  String get payoutStatusRequested => 'Em análise';

  @override
  String get payoutStatusApproved => 'Aprovado';

  @override
  String get payoutStatusPaid => 'Pago';

  @override
  String get payoutStatusRejected => 'Recusado';

  @override
  String get payoutStatusCanceled => 'Cancelado';

  @override
  String get payoutAccountTitle => 'Conta de recebimento';

  @override
  String get payoutAccountStatusPendingReview => 'Em verificação';

  @override
  String get payoutAccountStatusVerified => 'Verificada';

  @override
  String get payoutAccountStatusRejected => 'Recusada';

  @override
  String get payoutAccountPendingNote =>
      'Verificamos a conta no primeiro pagamento. Você já pode pedir saque.';

  @override
  String payoutAccountRejectedNote(String reason) {
    return 'Motivo: $reason. Cadastre outra conta para sacar.';
  }

  @override
  String get payoutAccountNoReason => 'não informado';

  @override
  String get payoutAccountChange => 'Trocar conta';

  @override
  String get payoutAccountEmpty =>
      'Cadastre a conta onde você quer receber. Ela precisa estar no seu nome.';

  @override
  String get payoutAccountAdd => 'Cadastrar conta';

  @override
  String get payoutAccountFormTitle => 'Conta de recebimento';

  @override
  String get payoutAccountFormIntro =>
      'Informe onde quer receber. A conta precisa ser sua: nome completo e documento do titular.';

  @override
  String get payoutAccountSelect => 'Selecione';

  @override
  String get payoutAccountOtherCountry => 'Outro país';

  @override
  String get payoutAccountPaidInBrl =>
      'Pagamento em reais (R\$), pela cotação PTAX do Banco Central.';

  @override
  String get payoutAccountPaidInUsd => 'Pagamento em dólares (US\$).';

  @override
  String get payoutAccountDocBr => 'CPF ou CNPJ do titular';

  @override
  String get payoutAccountDocOther =>
      'Documento de identificação fiscal do titular';

  @override
  String get payoutAccountHolderTitle => 'Titular da conta';

  @override
  String get payoutAccountHolderHint =>
      'Deve ser a mesma pessoa que cria os conteúdos na Brawe.';

  @override
  String get payoutAccountHolderNamePlaceholder =>
      'Nome completo, como no documento';

  @override
  String get payoutAccountSecurityNote =>
      'Seus dados bancários são guardados criptografados e só aparecem mascarados. Enviaremos um e-mail de segurança avisando da alteração.';

  @override
  String get payoutAccountReviewNote =>
      'A conta fica em verificação e é conferida pela Brawe no primeiro pagamento.';

  @override
  String get payoutAccountSave => 'Salvar conta';

  @override
  String get payoutFieldsCountry => 'País da conta';

  @override
  String get payoutFieldsMethod => 'Forma de recebimento';

  @override
  String get payoutFieldsHolderName => 'Nome completo do titular';

  @override
  String get payoutFieldsHolderTaxId => 'Documento do titular';

  @override
  String get payoutFieldsKeyType => 'Tipo de chave Pix';

  @override
  String get payoutFieldsKey => 'Chave Pix';

  @override
  String get payoutFieldsBankCode => 'Código do banco';

  @override
  String get payoutFieldsBranch => 'Agência';

  @override
  String get payoutFieldsAccount => 'Conta';

  @override
  String get payoutFieldsAccountDigit => 'Dígito da conta';

  @override
  String get payoutFieldsIban => 'IBAN';

  @override
  String get payoutFieldsRoutingNumber => 'Routing number (ABA)';

  @override
  String get payoutFieldsAccountNumber => 'Número da conta';

  @override
  String get payoutFieldsAccountType => 'Tipo de conta';

  @override
  String get payoutFieldsSwift => 'SWIFT/BIC';

  @override
  String get payoutFieldsBankName => 'Nome do banco';

  @override
  String get payoutFieldsBankAddress => 'Endereço do banco';

  @override
  String get payoutFieldsTaxRegime => 'Regime tributário da empresa';

  @override
  String get payoutMethodsPix => 'Pix';

  @override
  String get payoutMethodsBankBr => 'Conta bancária';

  @override
  String get payoutMethodsIban => 'IBAN';

  @override
  String get payoutMethodsUsAch => 'ACH (EUA)';

  @override
  String get payoutMethodsSwift => 'Transferência SWIFT';

  @override
  String get payoutPixKeyTypesCpf => 'CPF';

  @override
  String get payoutPixKeyTypesCnpj => 'CNPJ';

  @override
  String get payoutPixKeyTypesEmail => 'E-mail';

  @override
  String get payoutPixKeyTypesPhone => 'Celular';

  @override
  String get payoutPixKeyTypesRandom => 'Chave aleatória';

  @override
  String get payoutAccountTypesChecking => 'Conta corrente (checking)';

  @override
  String get payoutAccountTypesSavings => 'Poupança (savings)';

  @override
  String get payoutKeyPlaceholderCpf => '000.000.000-00';

  @override
  String get payoutKeyPlaceholderCnpj => '00.000.000/0000-00';

  @override
  String get payoutKeyPlaceholderEmail => 'voce@email.com';

  @override
  String get payoutKeyPlaceholderPhone => '(11) 91234-5678';

  @override
  String get payoutKeyPlaceholderRandom => 'Chave aleatória';

  @override
  String get payoutKeyPlaceholderNone => 'Chave Pix';

  @override
  String get payoutHistoryTitle => 'Histórico de saques';

  @override
  String get payoutHistoryEmpty => 'Você ainda não fez nenhum saque.';

  @override
  String payoutHistoryRejectedNote(String reason) {
    return 'Motivo: $reason. Os diamantes voltaram para o seu saldo.';
  }

  @override
  String payoutHistoryReference(String ref) {
    return 'Comprovante: $ref';
  }

  @override
  String payoutHistoryTotalReceived(String amount) {
    return 'Total já recebido: $amount';
  }

  @override
  String get payoutWithdrawTitle => 'Sacar';

  @override
  String payoutWithdrawStepOf(String current, String total) {
    return 'Etapa $current de $total';
  }

  @override
  String get payoutWithdrawAmountTitle => 'Quanto você quer sacar?';

  @override
  String payoutWithdrawAmountSubtitle(String available) {
    return 'Você tem $available diamantes disponíveis.';
  }

  @override
  String get payoutWithdrawDiamondsLabel => 'Diamantes';

  @override
  String get payoutWithdrawAll => 'Tudo';

  @override
  String payoutWithdrawMinHint(String amount, String diamonds) {
    return 'Mínimo de $diamonds diamantes ($amount).';
  }

  @override
  String get payoutWithdrawTypeToQuote =>
      'Digite a quantidade para ver quanto você recebe.';

  @override
  String get payoutWithdrawCalculating => 'Calculando…';

  @override
  String get payoutWithdrawYouReceive => 'Você recebe';

  @override
  String payoutWithdrawAfterRetentions(String gross, String tax) {
    return '$gross menos $tax de retenções';
  }

  @override
  String get payoutWithdrawContinue => 'Continuar';

  @override
  String get payoutWithdrawReviewTitle => 'Confira o saque';

  @override
  String get payoutWithdrawReviewSubtitle =>
      'Veja o cálculo completo antes de confirmar.';

  @override
  String get payoutWithdrawDiamonds => 'Diamantes';

  @override
  String payoutWithdrawPtax(String date) {
    return 'Cotação PTAX de $date';
  }

  @override
  String get payoutWithdrawValueUsd => 'Valor em dólares';

  @override
  String get payoutWithdrawGross => 'Valor bruto';

  @override
  String get payoutWithdrawRetentions => 'Retenções';

  @override
  String get payoutWithdrawNoRetentions => 'Nenhuma';

  @override
  String get payoutWithdrawNet => 'Você recebe';

  @override
  String payoutWithdrawPtaxNote(String bulletin, String side) {
    return 'Cotação de $side do $bulletin (Banco Central), do último boletim de fechamento.';
  }

  @override
  String get payoutWithdrawPaidTo => 'Pagamento para';

  @override
  String payoutWithdrawSla(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias úteis',
      one: '$days dia útil',
    );
    return 'Pagamento em até $_temp0 após a aprovação.';
  }

  @override
  String get payoutWithdrawFirstPaymentCheck =>
      'Como é seu primeiro pagamento, a Brawe confere a conta antes de pagar.';

  @override
  String get payoutWithdrawSendCode => 'Enviar código por e-mail';

  @override
  String payoutWithdrawMonthPrior(String amount) {
    return 'As retenções consideram os saques que você já fez este mês ($amount).';
  }

  @override
  String get payoutWithdrawRetentionsHelp =>
      'Retenções exigidas por lei, recolhidas pela Brawe em seu nome. Você recebe o informe de rendimentos.';

  @override
  String get payoutCodeTitle => 'Confirme com o código';

  @override
  String payoutCodeSubtitle(String email) {
    return 'Enviamos um código de 6 dígitos para $email.';
  }

  @override
  String get payoutCodeLabel => 'Código de 6 dígitos';

  @override
  String get payoutCodeConfirm => 'Confirmar saque';

  @override
  String get payoutCodeResend => 'Reenviar código';

  @override
  String payoutCodeResendIn(String seconds) {
    return 'Reenviar código em ${seconds}s';
  }

  @override
  String payoutCodeResent(String email) {
    return 'Novo código enviado para $email.';
  }

  @override
  String get payoutDoneTitle => 'Pedido enviado';

  @override
  String payoutDoneSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias úteis',
      one: '$days dia útil',
    );
    return 'Seu saque está em análise. O pagamento sai em até $_temp0 após a aprovação, e você acompanha o status aqui.';
  }

  @override
  String get payoutDoneStatus => 'Situação';

  @override
  String get payoutDoneBack => 'Voltar para Ganhos';

  @override
  String get payoutErrorsNetwork =>
      'Sem conexão com o servidor. Confira sua internet e tente de novo.';

  @override
  String get payoutErrorsDisabled => 'Os saques ainda não estão liberados.';

  @override
  String get payoutErrorsAccountRequired =>
      'Cadastre sua conta de recebimento para sacar.';

  @override
  String get payoutErrorsAccountRejected =>
      'Sua conta de recebimento foi recusada. Cadastre outra conta.';

  @override
  String get payoutErrorsInProgress =>
      'Espere o saque em andamento terminar para trocar a conta.';

  @override
  String get payoutErrorsOpenLimit =>
      'Você já tem um saque em andamento. Espere ele terminar ou cancele.';

  @override
  String get payoutErrorsConflict =>
      'Seu saldo mudou. Atualize a página e tente de novo.';

  @override
  String get payoutErrorsFxUnavailable =>
      'A cotação do dólar está indisponível agora. Tente de novo em instantes.';

  @override
  String get payoutErrorsNetNotPositive =>
      'Depois das retenções, o valor líquido ficaria zerado. Escolha uma quantia maior.';

  @override
  String get payoutErrorsInvalidAmount =>
      'Informe uma quantidade de diamantes válida.';

  @override
  String payoutErrorsBelowMinimum(String amount, String diamonds) {
    return 'O saque mínimo é de $diamonds diamantes ($amount).';
  }

  @override
  String payoutErrorsInsufficient(String available) {
    return 'Saldo insuficiente. Você tem $available diamantes disponíveis.';
  }

  @override
  String get payoutErrorsTooMany =>
      'Muitas tentativas. Espere um pouco e tente de novo.';

  @override
  String get payoutErrorsSendFailed =>
      'Não conseguimos enviar o e-mail agora. Tente de novo.';

  @override
  String payoutErrorsResendTooSoon(String seconds) {
    return 'Aguarde ${seconds}s para reenviar o código.';
  }

  @override
  String payoutErrorsCodeInvalid(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Restam $left tentativas',
      one: 'Resta $left tentativa',
    );
    return 'Código incorreto. $_temp0.';
  }

  @override
  String get payoutErrorsCodeExpired =>
      'Este código expirou. Toque em “Reenviar código”.';

  @override
  String get payoutErrorsTooManyAttempts =>
      'Muitas tentativas erradas. Volte e peça um novo código.';

  @override
  String get payoutErrorsHolderMismatch =>
      'A chave Pix (CPF/CNPJ) precisa ser do próprio titular da conta.';

  @override
  String get payoutErrorsInvalidMethod =>
      'Esta forma de recebimento não está disponível para o país escolhido.';

  @override
  String payoutErrorsInvalidField(String field) {
    return 'Confira o campo “$field”.';
  }

  @override
  String get payoutErrorsInvalidData => 'Confira os dados informados.';

  @override
  String get payoutErrorsGeneric =>
      'Não foi possível concluir agora. Tente de novo.';

  @override
  String get payoutErrorsFillAll =>
      'Preencha todos os campos, com o nome completo do titular.';

  @override
  String get payoutErrorsPickMethod => 'Escolha a forma de recebimento.';

  @override
  String get payoutTaxRegimesSimples => 'Simples Nacional ou MEI';

  @override
  String get payoutTaxRegimesNormal => 'Lucro Presumido ou Real';

  @override
  String get payoutHolderTypesPf => 'Pessoa física';

  @override
  String get payoutHolderTypesPj => 'Empresa';

  @override
  String get payoutHolderTypesPjSimples => 'Empresa (Simples/MEI)';

  @override
  String get creatorPanelTabMonetization => 'Monetização';

  @override
  String get payoutOnlyGiftsNote =>
      'Só os diamantes de presentes recebidos em lives e stories podem ser sacados. Coins compradas servem para usar dentro da Brawe e não são sacáveis.';

  @override
  String get payoutLoadError => 'Não foi possível carregar a monetização.';

  @override
  String get payoutCancelTitle => 'Cancelar saque?';

  @override
  String get payoutDoneBackMonetization => 'Voltar para Monetização';

  @override
  String get payoutCountryBR => 'Brasil';

  @override
  String get payoutCountryUS => 'Estados Unidos';

  @override
  String get payoutCountryPT => 'Portugal';

  @override
  String get payoutCountryAR => 'Argentina';

  @override
  String get payoutCountryCL => 'Chile';

  @override
  String get payoutCountryCO => 'Colômbia';

  @override
  String get payoutCountryMX => 'México';

  @override
  String get payoutCountryPE => 'Peru';

  @override
  String get payoutCountryUY => 'Uruguai';

  @override
  String get payoutCountryES => 'Espanha';

  @override
  String get payoutSeeMonetization => 'Sacar em Monetização';

  @override
  String get adsSponsored => 'Patrocinado';

  @override
  String get adsWhy => 'Por que estou vendo isto?';

  @override
  String adsWhyAdvertiser(String name) {
    return 'Este anúncio é de $name.';
  }

  @override
  String get adsWhyFooter =>
      'Anúncios na Brawe nunca usam suas mensagens nem aparecem para menores de 18 anos.';

  @override
  String get adsHide => 'Ocultar este anúncio';

  @override
  String adsLessFrom(String name) {
    return 'Ver menos de $name';
  }

  @override
  String get adsReport => 'Denunciar anúncio';

  @override
  String get adsHidden => 'Anúncio ocultado';

  @override
  String get adsReportThanks =>
      'Obrigado. A equipe da Brawe vai revisar este anúncio.';

  @override
  String get adsReasonMisleading => 'Enganoso ou golpe';

  @override
  String get adsReasonOffensive => 'Ofensivo';

  @override
  String get adsReasonAdult => 'Conteúdo adulto';

  @override
  String get adsReasonProhibited => 'Produto proibido';

  @override
  String get adsReasonRepetitive => 'Aparece demais';

  @override
  String get adsReasonOther => 'Outro motivo';

  @override
  String get adsSeeProfile => 'Ver perfil';

  @override
  String get adsWatchLive => 'Assistir à live';

  @override
  String get postBoost => 'Impulsionar';

  @override
  String get postBoostHint => 'Mostre para mais pessoas';

  @override
  String get boostTitle => 'Impulsionar post';

  @override
  String get boostStepAudience => 'Público';

  @override
  String get boostStepBudget => 'Orçamento';

  @override
  String get boostStepReview => 'Revisar';

  @override
  String get boostAuto => 'Automático';

  @override
  String get boostAutoHint =>
      'A Brawe escolhe quem tem mais chance de se interessar, em todo o Brasil.';

  @override
  String get boostCustom => 'Personalizar';

  @override
  String get boostCustomHint => 'Escolha onde, idade e interesses.';

  @override
  String get boostLocation => 'Localização';

  @override
  String get boostAllBrazil => 'Brasil inteiro';

  @override
  String get boostPlaces => 'Cidades';

  @override
  String get boostRadius => 'Raio';

  @override
  String get boostSearchCity => 'Buscar cidade';

  @override
  String get boostNoCity => 'Nenhuma cidade encontrada';

  @override
  String get boostUseMyLocation => 'Usar minha localização';

  @override
  String get boostCenter => 'Centro do raio';

  @override
  String boostKm(String km) {
    return '$km km';
  }

  @override
  String get boostAge => 'Idade';

  @override
  String boostAgeRange(String from, String to) {
    return '$from a $to anos';
  }

  @override
  String get boostInterests => 'Interesses';

  @override
  String get boostAnyInterest => 'Qualquer interesse';

  @override
  String get boostPerDay => 'Por dia';

  @override
  String get boostDuration => 'Duração';

  @override
  String boostDaysN(String n) {
    return '$n dias';
  }

  @override
  String get boostTotal => 'Total';

  @override
  String boostCoins(String n) {
    return '$n Coins';
  }

  @override
  String boostBalance(String n) {
    return 'Seu saldo: $n Coins';
  }

  @override
  String get boostInsufficient => 'Saldo insuficiente para este orçamento.';

  @override
  String get boostTopUp => 'Recarregar Coins';

  @override
  String get boostEstimate => 'Público estimado';

  @override
  String get boostNext => 'Continuar';

  @override
  String boostPay(String n) {
    return 'Impulsionar · $n Coins';
  }

  @override
  String get boostTerms =>
      'Ao impulsionar, você confirma que o post segue as regras de anúncios da Brawe. O que não for gasto volta para você.';

  @override
  String get boostDoneTitle => 'Seu post está sendo impulsionado';

  @override
  String get boostDoneHint =>
      'Acompanhe alcance, cliques e gastos em Meus anúncios.';

  @override
  String get boostSeeCampaigns => 'Ver meus anúncios';

  @override
  String get boostError => 'Não foi possível impulsionar. Tente de novo.';

  @override
  String boostCitiesInRadius(String n) {
    return '≈ $n cidades no raio';
  }

  @override
  String get myAdsTitle => 'Meus anúncios';

  @override
  String get myAdsEmpty => 'Você ainda não impulsionou nenhum post.';

  @override
  String get myAdsEmptyHint =>
      'Toque em Impulsionar em um post seu para começar.';

  @override
  String get myAdsStatusDraft => 'Rascunho';

  @override
  String get myAdsStatusReview => 'Em revisão';

  @override
  String get myAdsStatusActive => 'No ar';

  @override
  String get myAdsStatusPaused => 'Pausada';

  @override
  String get myAdsStatusEnded => 'Encerrada';

  @override
  String get myAdsStatusRejected => 'Recusada';

  @override
  String get myAdsImpressions => 'Impressões';

  @override
  String get myAdsReach => 'Alcance';

  @override
  String get myAdsClicks => 'Cliques';

  @override
  String get myAdsViews => 'Visualizações';

  @override
  String get myAdsNewFollowers => 'Novos seguidores';

  @override
  String get myAdsProfileVisits => 'Visitas ao perfil';

  @override
  String get myAdsSpent => 'Gasto';

  @override
  String myAdsOf(String total) {
    return 'de $total';
  }

  @override
  String myAdsEndsOn(String date) {
    return 'Termina em $date';
  }

  @override
  String get myAdsPause => 'Pausar';

  @override
  String get myAdsResume => 'Retomar';

  @override
  String get myAdsCancel => 'Encerrar';

  @override
  String get myAdsCancelConfirm =>
      'Encerrar o anúncio agora? As Coins do que não foi gasto voltam para você.';

  @override
  String get myAdsIncreaseDaily => 'Aumentar por dia';

  @override
  String myAdsIncreaseCost(String days, String coins) {
    return 'Faltam $days dias: $coins Coins a mais';
  }

  @override
  String get myAdsOnlyUp => 'O valor por dia só pode aumentar.';

  @override
  String get myAdsEditAudience => 'Editar público';

  @override
  String get myAdsAudienceSaved => 'Público atualizado';

  @override
  String get myAdsPausedByTeam => 'Pausado pela equipe da Brawe.';

  @override
  String get myAdsSave => 'Salvar';

  @override
  String get boostTapMap => 'Toque no mapa para mudar o centro.';

  @override
  String get boostInterestsNarrow =>
      'Interesses deixam o público menor. Se o alcance ficar baixo, tire alguns.';

  @override
  String get boostRetry => 'Tentar de novo';

  @override
  String get boostPerDayShort => 'por dia';

  @override
  String get boostFinish => 'Concluir';

  @override
  String get myAdsAtMax => 'Você já está no valor máximo por dia.';

  @override
  String get myAdsEntry => 'Anúncios e impulsionamentos';

  @override
  String get adsRepEmpty =>
      'Os resultados aparecem aqui assim que o anúncio começar a ser exibido.';

  @override
  String get adsRepPeople => 'pessoas';

  @override
  String get adsRepFrequency => 'Frequência';

  @override
  String get adsRepCtr => 'Taxa de cliques';

  @override
  String get adsRepCpm => 'Custo por mil';

  @override
  String get adsRepOverTime => 'Ao longo dos dias';

  @override
  String get adsRepVideo => 'Vídeo';

  @override
  String adsRepAvgWatch(String s) {
    return 'Tempo médio: $s s';
  }

  @override
  String get adsRepWatched25 => 'Assistiram 25%';

  @override
  String get adsRepWatched50 => 'Assistiram metade';

  @override
  String get adsRepWatched100 => 'Assistiram até o fim';

  @override
  String get adsRepAudience => 'Quem viu';

  @override
  String get adsRepAge => 'Idade';

  @override
  String get adsRepCities => 'Cidades';

  @override
  String get adsRepStates => 'Estados';

  @override
  String get adsRepRegions => 'Regiões';

  @override
  String get adsRepInterests => 'Interesses';

  @override
  String get adsRepOthers => 'Outros';

  @override
  String get adsRepUnknown => 'Não informada';

  @override
  String get adsRepNoData => 'Sem dados ainda';

  @override
  String get adsRepPrivacy =>
      'Só números somados. Grupos com poucas pessoas entram em \"Outros\" para ninguém ser identificado.';

  @override
  String adsRepLoggedOut(String n) {
    return '$n pessoas viram sem estar logadas';
  }

  @override
  String get adsRepHours => 'Melhores horários';

  @override
  String adsRepBestHour(String h) {
    return 'Mais visto às ${h}h';
  }

  @override
  String get adsRepWhere => 'Onde apareceu';

  @override
  String get adsRepPlatforms => 'Aparelhos';

  @override
  String get adsRepPlForyou => 'Para você';

  @override
  String get adsRepPlFollowing => 'Seguindo';

  @override
  String get adsRepPlStories => 'Stories';

  @override
  String get adsRepPlLives => 'Lives';

  @override
  String get adsRepPlExplore => 'Explorar';

  @override
  String get adsRepPlWeb => 'Início do site';

  @override
  String get adsRepLive => 'Live';

  @override
  String get adsRepLiveFromAd => 'Entraram pelo anúncio';

  @override
  String get adsRepLivePeak => 'Pico de espectadores';

  @override
  String get adsRepLiveGifts => 'Presentes';

  @override
  String get adsRepLiveMinutes => 'Minutos assistidos';

  @override
  String get adsRepCoins => 'Coins';

  @override
  String get adsRepCoinsPaid => 'Pagas';

  @override
  String get adsRepCoinsUsed => 'Usadas';

  @override
  String get adsRepCoinsRefunded => 'Devolvidas';

  @override
  String get adsRepChanges => 'Alterações';

  @override
  String get adsRepChangeDaily => 'Valor por dia';

  @override
  String get adsRepChangeTotal => 'Orçamento total';

  @override
  String get adsRepChangeEnd => 'Data de término';

  @override
  String get adsRepResults => 'Resultados';

  @override
  String get boostStepGoal => 'Objetivo';

  @override
  String get boostGoalTitle => 'O que você quer com esse impulsionamento?';

  @override
  String get boostGoalViews => 'Mais visualizações';

  @override
  String get boostGoalViewsHint => 'Mostra o post para mais gente.';

  @override
  String get boostGoalFollowers => 'Mais seguidores';

  @override
  String get boostGoalFollowersHint =>
      'Quem vê conhece seu perfil e pode seguir você.';

  @override
  String get boostGoalProfile => 'Visitas ao perfil';

  @override
  String get boostGoalProfileHint => 'Mais pessoas abrindo o seu perfil.';

  @override
  String get boostGoalContacts => 'Receber mensagens';

  @override
  String get boostGoalContactsHint =>
      'Um botão para as pessoas falarem com você.';

  @override
  String get boostContactVia => 'Onde você quer receber as mensagens?';

  @override
  String get boostContactChat => 'Chat da Brawe';

  @override
  String get boostContactChatHint =>
      'As conversas chegam no seu Chat, aqui no app. Cada mensagem conta como contato no relatório.';

  @override
  String get boostContactWhatsapp => 'WhatsApp';

  @override
  String get boostContactWhatsappHint =>
      'O botão abre o seu WhatsApp com a mensagem pronta. Cada toque conta como contato no relatório.';

  @override
  String get boostWhatsappPhone => 'Seu WhatsApp com DDD';

  @override
  String get boostWhatsappMessage => 'Mensagem pronta';

  @override
  String get boostWhatsappMessageDefault =>
      'Olá! Vi seu post na Brawe e quero saber mais.';

  @override
  String get boostPreview => 'Prévia';

  @override
  String get boostPreviewHint =>
      'Assim o seu post aparece em cada lugar do app. Deslize para ver.';

  @override
  String get boostPlForYou => 'Para você';

  @override
  String get boostPlFeed => 'Feed';

  @override
  String get boostPlStories => 'Stories';

  @override
  String get boostPlTiles => 'Lives e Explorar';

  @override
  String get boostAlreadyTitle => 'Este post já está sendo impulsionado';

  @override
  String get boostAlreadyHint =>
      'Para alcançar mais pessoas, aumente o valor por dia ou edite o público da campanha que já existe (feita no app ou no site).';

  @override
  String get boostSeeCampaign => 'Ver campanha';

  @override
  String get adsCtaMessage => 'Enviar mensagem';

  @override
  String get adsCtaWhatsapp => 'Chamar no WhatsApp';

  @override
  String get myAdsKindBrand => 'Anúncio da marca';

  @override
  String get myAdsKindBoost => 'Impulsionamento';

  @override
  String get myAdsLeadsChat =>
      'As mensagens de quem viu o anúncio chegam no seu Chat.';

  @override
  String get myAdsLeadsWhatsapp =>
      'Os contatos de quem viu o anúncio chegam no seu WhatsApp.';

  @override
  String get myAdsOpenChat => 'Abrir chat';

  @override
  String get myAdsBrandEditOnWeb =>
      'Anúncio da marca: o criativo e o público se editam no painel de anúncios, pelo computador.';

  @override
  String get adsRepContacts => 'Contatos recebidos';

  @override
  String get adsFollow => 'Seguir';

  @override
  String get adsFollowingNow => 'Seguindo';

  @override
  String get adsSeePost => 'Ver publicação';

  @override
  String get adsWatchVideo => 'Assistir vídeo';

  @override
  String get adsLearnMore => 'Saiba mais';

  @override
  String get settingsGroupPreferences => 'Preferências';

  @override
  String get settingsGroupHelp => 'Ajuda';

  @override
  String get settingsGroupAbout => 'Sobre';

  @override
  String artistProfSaveError(String error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get artistProfRequired => 'Obrigatório';

  @override
  String get artistProfSectionIdentity => 'Identidade artística';

  @override
  String get artistProfArtistName => 'Nome artístico';

  @override
  String get artistProfArtistNameHint => 'Como você é conhecido';

  @override
  String get artistProfBio => 'Bio do artista';

  @override
  String get artistProfBioHint => 'Conte sua história musical...';

  @override
  String get artistProfSectionLocation => 'Localização';

  @override
  String get artistProfCountry => 'País';

  @override
  String get artistProfCountryHint => 'Selecione seu país';

  @override
  String get artistProfCity => 'Cidade';

  @override
  String get artistProfCityHint => 'Sua cidade';

  @override
  String get artistProfLanguage => 'Idioma nativo';

  @override
  String get artistProfLanguageHint => 'Idioma principal';

  @override
  String get artistProfSectionGenres => 'Gêneros musicais';

  @override
  String get artistProfGenresHint => 'Selecione até 5 gêneros';

  @override
  String get artistProfSectionPlatforms => 'Plataformas de streaming';

  @override
  String get artistProfCountryBR => 'Brasil';

  @override
  String get artistProfCountryPT => 'Portugal';

  @override
  String get artistProfCountryUS => 'Estados Unidos';

  @override
  String get artistProfCountryAR => 'Argentina';

  @override
  String get artistProfCountryMX => 'México';

  @override
  String get artistProfCountryCO => 'Colômbia';

  @override
  String get artistProfCountryCL => 'Chile';

  @override
  String get artistProfCountryPE => 'Peru';

  @override
  String get artistProfCountryUY => 'Uruguai';

  @override
  String get artistProfCountryPY => 'Paraguai';

  @override
  String get artistProfCountryBO => 'Bolívia';

  @override
  String get artistProfCountryEC => 'Equador';

  @override
  String get artistProfCountryVE => 'Venezuela';

  @override
  String get artistProfCountryES => 'Espanha';

  @override
  String get artistProfCountryFR => 'França';

  @override
  String get artistProfCountryDE => 'Alemanha';

  @override
  String get artistProfCountryIT => 'Itália';

  @override
  String get artistProfCountryGB => 'Reino Unido';

  @override
  String get artistProfCountryJP => 'Japão';

  @override
  String get artistProfCountryKR => 'Coreia do Sul';

  @override
  String get artistProfCountryNG => 'Nigéria';

  @override
  String get artistProfCountryGH => 'Gana';

  @override
  String get artistProfCountryZA => 'África do Sul';

  @override
  String get artistProfCountryAO => 'Angola';

  @override
  String get artistProfCountryMZ => 'Moçambique';

  @override
  String get artistProfCountryCV => 'Cabo Verde';

  @override
  String bizProfSaveError(String error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get bizProfRequired => 'Obrigatório';

  @override
  String get bizProfSectionCompany => 'Empresa / Marca';

  @override
  String get bizProfCompanyName => 'Nome da empresa ou marca';

  @override
  String get bizProfCompanyNameHint => 'Ex: Minha Empresa S.A.';

  @override
  String get bizProfAbout => 'Sobre a empresa';

  @override
  String get bizProfAboutHint => 'Descreva sua empresa ou marca...';

  @override
  String get bizProfSector => 'Setor de atuação';

  @override
  String get bizProfSectorHint => 'Selecione um setor';

  @override
  String get bizProfSectionLocation => 'Localização';

  @override
  String get bizProfCountry => 'País de operação';

  @override
  String get bizProfCountryHint => 'Selecione o país';

  @override
  String get bizProfCity => 'Cidade';

  @override
  String get bizProfCityHint => 'Cidade sede';

  @override
  String get bizProfLanguage => 'Idioma principal';

  @override
  String get bizProfLanguageHint => 'Idioma de operação';

  @override
  String get bizProfSectionFiscal => 'Dados fiscais';

  @override
  String get bizProfFiscalRow => 'Dados fiscais e CNPJ';

  @override
  String get bizProfFiscalRowHint => 'Enviar para verificação';

  @override
  String get bizProfSectionLinks => 'Links';

  @override
  String get bizProfWebsite => 'Website';

  @override
  String get bizProfWebsiteHint => 'https://suaempresa.com';

  @override
  String get bizProfInstagramHint => '@suaempresa';

  @override
  String get bizProfWhatsappHint => '+55 11 99999-9999';

  @override
  String get bizProfSectorFashionBeauty => 'Moda & Beleza';

  @override
  String get bizProfSectorTech => 'Tecnologia';

  @override
  String get bizProfSectorFood => 'Alimentação & Bebidas';

  @override
  String get bizProfSectorEntertainment => 'Entretenimento';

  @override
  String get bizProfSectorEducation => 'Educação';

  @override
  String get bizProfSectorHealth => 'Saúde & Bem-estar';

  @override
  String get bizProfSectorFinance => 'Finanças & Investimentos';

  @override
  String get bizProfSectorRetail => 'Varejo & E-commerce';

  @override
  String get bizProfSectorMusic => 'Música & Áudio';

  @override
  String get bizProfSectorGames => 'Games';

  @override
  String get bizProfSectorSports => 'Esportes';

  @override
  String get bizProfSectorRealEstate => 'Imóveis';

  @override
  String get bizProfSectorAgro => 'Agro & Sustentabilidade';

  @override
  String get bizProfSectorServices => 'Serviços Profissionais';

  @override
  String get bizProfSectorNgo => 'ONG & Social';

  @override
  String get bizProfSectorOther => 'Outro';

  @override
  String get bizProfCountryBR => 'Brasil';

  @override
  String get bizProfCountryPT => 'Portugal';

  @override
  String get bizProfCountryUS => 'Estados Unidos';

  @override
  String get bizProfCountryAR => 'Argentina';

  @override
  String get bizProfCountryMX => 'México';

  @override
  String get bizProfCountryCO => 'Colômbia';

  @override
  String get bizProfCountryCL => 'Chile';

  @override
  String get bizProfCountryES => 'Espanha';

  @override
  String get bizProfCountryDE => 'Alemanha';

  @override
  String get bizProfCountryGB => 'Reino Unido';

  @override
  String get bizProfCountryAO => 'Angola';

  @override
  String get bizProfCountryMZ => 'Moçambique';

  @override
  String get acctTitle => 'Tipo de conta';

  @override
  String get acctPersonal => 'Pessoal';

  @override
  String get acctPersonalHint => 'Para seguir, assistir, conversar e publicar.';

  @override
  String get acctCreator => 'Criador';

  @override
  String get acctCreatorHint =>
      'Para quem faz lives e conteúdo e quer crescer e ganhar com isso.';

  @override
  String get acctArtist => 'Artista';

  @override
  String get acctArtistHint =>
      'Músicos, bandas e DJs: perfil artístico com seus links de música.';

  @override
  String get acctBusiness => 'Empresa';

  @override
  String get acctBusinessHint =>
      'Marcas e negócios. Exige identidade verificada e CNPJ aprovado.';

  @override
  String get acctFooter =>
      'Você pode trocar entre Pessoal, Criador e Artista quando quiser. Seus posts, seguidores e Coins continuam iguais.';

  @override
  String acctConfirmTitle(String name) {
    return 'Mudar para $name?';
  }

  @override
  String get acctConfirmBody =>
      'Seu perfil passa a mostrar este tipo de conta. Dá para voltar depois.';

  @override
  String get acctConfirmAction => 'Mudar';

  @override
  String acctChanged(String name) {
    return 'Agora sua conta é $name';
  }

  @override
  String get acctChangeFailed => 'Não foi possível trocar o tipo de conta.';

  @override
  String get acctBusinessStepsTitle => 'Para virar Empresa';

  @override
  String get acctBusinessStepsBody =>
      'Para proteger quem compra e anuncia, contas de empresa passam por dois passos.';

  @override
  String get acctStepIdentity => 'Verificar sua identidade';

  @override
  String get acctStepBusiness => 'Enviar CNPJ e dados fiscais';

  @override
  String get acctStepIdentityAction => 'Verificar identidade';

  @override
  String get acctStepBusinessAction => 'Enviar dados da empresa';

  @override
  String get editProfileCreatorPanel => 'Painel do criador';

  @override
  String get editProfileArtistPage => 'Perfil de artista';

  @override
  String get editProfileBusinessPage => 'Perfil da empresa';

  @override
  String get editProfileWebsite => 'Site';

  @override
  String get kycTitle => 'Verificação';

  @override
  String get kycApproved => 'Verificada';

  @override
  String get kycInReview => 'Em análise';

  @override
  String get kycRejected => 'Recusada';

  @override
  String get kycNotStarted => 'Não verificada';

  @override
  String get kycLoadError => 'Não foi possível carregar a verificação.';

  @override
  String get kycError => 'Algo deu errado. Tente de novo.';

  @override
  String get kycHeaderTitle => 'Verifique sua conta';

  @override
  String get kycHeaderDone => 'Sua conta é verificada';

  @override
  String get kycHeaderBody =>
      'Conta verificada ganha o selo azul, mais confiança de quem te segue e pode virar Empresa.';

  @override
  String get kycIdentityCaption => 'Identidade';

  @override
  String get kycIdentityRow => 'Verificar identidade';

  @override
  String get kycIdentityRowHint => 'Documento + vídeo rápido';

  @override
  String get kycIdentityFooter =>
      'Leva uns 2 minutos. No Brasil: CNH Digital do dia. Outros países: passaporte.';

  @override
  String kycRejectedReason(String reason) {
    return 'Recusada: $reason. Você pode enviar de novo.';
  }

  @override
  String get kycBusinessCaption => 'Empresa';

  @override
  String get kycBusinessRow => 'Dados da empresa';

  @override
  String get kycBusinessRowHint => 'CNPJ e dados fiscais';

  @override
  String get kycBusinessFooter =>
      'Com o CNPJ aprovado, sua conta vira Empresa.';

  @override
  String get kycBusinessLocked => 'Disponível depois da identidade verificada.';

  @override
  String get kycPrivacy =>
      'Seus documentos e o vídeo ficam cifrados, só a equipe de verificação vê, e são apagados assim que a análise termina.';

  @override
  String get kycStepDocument => 'Documento';

  @override
  String get kycStepLiveness => 'Vídeo';

  @override
  String get kycStepSend => 'Enviar';

  @override
  String get kycCountry => 'País do documento';

  @override
  String get kycCountrySearch => 'Buscar país';

  @override
  String get kycCountryChoose => 'Escolher país';

  @override
  String get kycDocument => 'Documento';

  @override
  String get kycDocCnh => 'CNH Digital';

  @override
  String get kycDocCnhHint => 'PDF exportado hoje no app CNH do Brasil';

  @override
  String get kycDocPassport => 'Passaporte';

  @override
  String get kycDocPassportHint =>
      'Página com foto, legível e dentro da validade';

  @override
  String get kycCnhHowTo =>
      'No app CNH do Brasil (gov.br): abra sua CNH, toque em Compartilhar › Exportar e salve o PDF. Precisa ser gerado hoje.';

  @override
  String get kycPassportHowTo =>
      'Envie a página com sua foto, sem reflexos e com os quatro cantos visíveis.';

  @override
  String get kycPickFile => 'Escolher arquivo';

  @override
  String get kycChangeFile => 'Toque para trocar';

  @override
  String get kycTakePhoto => 'Tirar foto do passaporte';

  @override
  String get kycLivenessIntro =>
      'Agora um vídeo curto para mostrar que é você mesmo. A câmera da frente abre e mostra o que você vai falar.';

  @override
  String get kycTipLight => 'Fique num lugar bem iluminado';

  @override
  String get kycTipFace => 'Rosto livre: sem óculos escuros, boné ou máscara';

  @override
  String get kycTipTurn => 'Vire devagar o rosto para um lado e para o outro';

  @override
  String get kycTipSpeak => 'Fale em voz alta o texto que aparece na tela';

  @override
  String get kycRecord => 'Gravar vídeo';

  @override
  String get kycRecorded => 'Vídeo gravado';

  @override
  String get kycRecordAgain => 'Toque para gravar de novo';

  @override
  String get kycReview => 'Confira';

  @override
  String get kycConsent =>
      'Autorizo a Brawe a usar este documento e o vídeo apenas para verificar minha identidade, conforme a LGPD.';

  @override
  String get kycSubmit => 'Enviar para análise';

  @override
  String get kycSentTitle => 'Enviado para análise';

  @override
  String get kycSentBody =>
      'Nossa equipe confere em até 2 dias úteis. Quando aprovar, o selo azul aparece no seu perfil.';

  @override
  String get kycBizSentBody =>
      'Nossa equipe confere em até 2 dias úteis. Quando aprovar, sua conta vira Empresa.';

  @override
  String get kycSay => 'Fale em voz alta:';

  @override
  String kycScript(String name, String date, String time, String code) {
    return 'Meu nome é $name. Hoje é $date, $time. Código $code.';
  }

  @override
  String get kycCamReady => 'Encaixe o rosto e toque para gravar';

  @override
  String get kycCamLook => 'Olhe para a câmera';

  @override
  String get kycCamLeft => 'Vire devagar para a esquerda';

  @override
  String get kycCamRight => 'Agora para a direita';

  @override
  String get kycCamSpeak => 'Fale o texto e toque para parar';

  @override
  String get kycCamError =>
      'Não foi possível abrir a câmera. Permita o acesso à câmera e ao microfone nos Ajustes.';

  @override
  String get kycTooShort => 'Grave pelo menos 5 segundos';

  @override
  String get kycBizCompany => 'Empresa';

  @override
  String get kycBizCnpjHint =>
      'Digite o CNPJ: nome e endereço vêm da Receita Federal.';

  @override
  String kycBizSituation(String status) {
    return 'Situação na Receita: $status';
  }

  @override
  String get kycBizLegalName => 'Razão social';

  @override
  String get kycBizTradeName => 'Nome fantasia';

  @override
  String get kycBizTax => 'Fiscal';

  @override
  String get kycBizRegime => 'Regime tributário';

  @override
  String get kycRegimeSimples => 'Simples Nacional';

  @override
  String get kycRegimePresumido => 'Lucro Presumido';

  @override
  String get kycRegimeReal => 'Lucro Real';

  @override
  String get kycBizIe => 'Inscrição estadual';

  @override
  String get kycBizIeExempt => 'Isento de inscrição estadual';

  @override
  String get kycBizAddress => 'Endereço';

  @override
  String get kycBizZip => 'CEP';

  @override
  String get kycBizStreet => 'Rua';

  @override
  String get kycBizNumber => 'Número';

  @override
  String get kycBizDistrict => 'Bairro';

  @override
  String get kycBizCity => 'Cidade';

  @override
  String get kycBizCard => 'Cartão CNPJ';

  @override
  String get kycBizCardHint =>
      'Baixe o comprovante de inscrição no site da Receita Federal (PDF) ou envie uma foto nítida.';

  @override
  String onbInterestsPickMin(String n) {
    return 'Escolha pelo menos $n';
  }

  @override
  String get onbAboutTitle => 'Sobre você';

  @override
  String get onbAboutSubtitle =>
      'Ajuda a mostrar pessoas, lives e ofertas da sua região.';

  @override
  String get onbGender => 'Gênero';

  @override
  String get onbGenderFemale => 'Feminino';

  @override
  String get onbGenderMale => 'Masculino';

  @override
  String get onbGenderOther => 'Outro';

  @override
  String get onbGenderUndisclosed => 'Prefiro não dizer';

  @override
  String get onbWhereYouLive => 'Onde você mora';

  @override
  String get onbCityHint => 'Sua cidade';

  @override
  String get onbAboutPrivacy =>
      'Não mostramos seu gênero nem sua cidade no perfil. Usamos só para personalizar o que você vê.';

  @override
  String get editProfileAbout => 'Sobre você';

  @override
  String get boostGenderAll => 'Todos';

  @override
  String get boostGenderFemale => 'Mulheres';

  @override
  String get boostGenderMale => 'Homens';

  @override
  String get adsRepGenderOther => 'Outro / não disse';

  @override
  String videoFormatsHintLimits(String duration, String size) {
    return 'MP4 · MOV · WebM   ·   até $duration   ·   $size';
  }

  @override
  String videoIssueTooBig(String size, String max) {
    return 'Este vídeo tem $size. O limite é $max. Escolha um vídeo mais curto ou corte o trecho.';
  }

  @override
  String videoIssueTooLong(String duration, String max) {
    return 'Este vídeo tem $duration. O limite é $max. Corte o trecho para publicar.';
  }

  @override
  String get videoIssueUnsupported =>
      'Esse formato não é aceito. Use um vídeo MP4, MOV ou WebM.';

  @override
  String get videoIssueCannotOpen =>
      'Não conseguimos abrir esse vídeo. Ele pode estar corrompido ou ainda baixando do iCloud. Tente outro.';

  @override
  String get videoIssueTrim => 'Cortar trecho';

  @override
  String get videoIssuePickOther => 'Escolher outro';

  @override
  String get videoUpDiscard => 'Descartar';

  @override
  String get videoErrNoConnection =>
      'Sem conexão com a internet. Seu vídeo continua guardado: toque em Tentar de novo quando a conexão voltar.';

  @override
  String get videoErrTimeout =>
      'A conexão está lenta e o envio demorou demais. Tente de novo, de preferência no Wi-Fi.';

  @override
  String videoErrTooLargeServer(String max) {
    return 'O vídeo passou do limite de $max. Escolha um vídeo mais curto ou corte o trecho.';
  }

  @override
  String videoErrTooLongServer(String max) {
    return 'O vídeo passou de $max. Corte o trecho e publique de novo.';
  }

  @override
  String get videoErrUnsupported =>
      'Esse formato de vídeo não é aceito. Use MP4, MOV ou WebM.';

  @override
  String get videoErrServer =>
      'Nosso servidor teve um problema. Tente de novo em instantes.';

  @override
  String get videoErrSession =>
      'Sua sessão expirou. Entre de novo e tente publicar outra vez.';

  @override
  String get videoErrProcessing =>
      'Não conseguimos processar esse vídeo. Tente de novo ou escolha outro arquivo.';

  @override
  String get videoErrUnknown => 'Algo deu errado ao publicar. Tente de novo.';
}
