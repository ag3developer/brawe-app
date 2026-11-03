// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Brawe';

  @override
  String get navHome => 'Home';

  @override
  String get navFeed => 'Feed';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get tabFollowing => 'Following';

  @override
  String get tabForYou => 'For You';

  @override
  String get actionFollow => 'Follow';

  @override
  String get actionUnfollow => 'Following';

  @override
  String get actionLike => 'Like';

  @override
  String get actionComment => 'Comment';

  @override
  String get actionShare => 'Share';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRepost => 'Repost';

  @override
  String get actionSend => 'Send';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionClose => 'Close';

  @override
  String get actionBack => 'Back';

  @override
  String get actionBlock => 'Block';

  @override
  String get actionUnblock => 'Unblock';

  @override
  String get actionReport => 'Report';

  @override
  String get actionCopy => 'Copy';

  @override
  String get feedEmptyTitle => 'No videos here yet.';

  @override
  String get feedEmptySubtitle => 'Follow creators or come back later.';

  @override
  String get feedFollowingEmptyTitle =>
      'Follow people to see their posts here.';

  @override
  String get feedLoadError => 'Could not load the feed.';

  @override
  String get feedNoMore => 'You\'re all caught up! 🎉';

  @override
  String get profileEditButton => 'Edit profile';

  @override
  String get profileFollowers => 'followers';

  @override
  String get profileFollowing => 'following';

  @override
  String get profileLives => 'lives';

  @override
  String get profileViews => 'views';

  @override
  String profileJoinedAt(String date) {
    return 'joined $date';
  }

  @override
  String get profileTabPosts => 'Posts';

  @override
  String get profileTabVideos => 'Videos';

  @override
  String get profileTabSaved => 'Saved';

  @override
  String get authLogin => 'Log in';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authLogout => 'Log out';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authWelcomeBack => 'Welcome back!';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get chatNewMessage => 'New message';

  @override
  String get chatPlaceholder => 'Message...';

  @override
  String get chatNoConversations => 'No conversations yet.';

  @override
  String chatBlockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String chatBlockedSuccess(String name) {
    return '$name has been blocked.';
  }

  @override
  String chatBlockError(String error) {
    return 'Failed to block: $error';
  }

  @override
  String chatImagePickError(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsPlaceholder => 'Add a comment...';

  @override
  String get commentsEmpty => 'No comments yet.\nBe the first!';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String notificationLiked(String user) {
    return '$user liked your post.';
  }

  @override
  String notificationFollowed(String user) {
    return '$user started following you.';
  }

  @override
  String notificationCommented(String user) {
    return '$user commented on your post.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Português · Español · English';

  @override
  String get settingsAppLanguage => 'App language';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotifLiveStart => 'Lives starting';

  @override
  String get settingsNotifLiveStartHint =>
      'Get notified when your favorite creators go live';

  @override
  String get settingsNotifGifts => 'Gifts received';

  @override
  String get settingsNotifGiftsHint => 'Notify when someone sends you a gift';

  @override
  String get settingsNotifFollowers => 'New followers';

  @override
  String get settingsNotifMessages => 'Direct messages';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyShowViewers => 'Show viewer count';

  @override
  String get settingsPrivacyShowViewersHint =>
      'Others can see how many people are watching your lives';

  @override
  String get settingsPrivacyShowEarnings => 'Show earnings publicly';

  @override
  String get settingsPrivacyShowEarningsHint =>
      'Display total coins/earnings on your profile';

  @override
  String get settingsSounds => 'Sounds';

  @override
  String get settingsSoundsEnabled => 'Sound effects';

  @override
  String get settingsSoundsHint =>
      'Sounds when receiving gifts, messages, etc.';

  @override
  String get settingsAbout => 'About & Legal';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get settingsLoadError => 'We couldn\'t load your settings.';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsTermsOfUse => 'Terms of Use';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get settingsHelpTitle => 'How can we help?';

  @override
  String get settingsSendSupportEmail => 'Email support';

  @override
  String get settingsNoMailApp => 'No email app configured.';

  @override
  String get settingsHelpCenterFaq => 'Help center / FAQ';

  @override
  String settingsSupportEmailSubject(String version) {
    return 'Brawe Support — App v$version';
  }

  @override
  String settingsCantOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get cpCurrentPassword => 'Current password';

  @override
  String get cpNewPassword => 'New password';

  @override
  String get cpConfirmNewPassword => 'Confirm new password';

  @override
  String get cpMin8Chars => 'Minimum 8 characters';

  @override
  String get cpSaveNewPassword => 'Save new password';

  @override
  String get cpEnterCurrentPassword => 'Enter your current password.';

  @override
  String get cpPasswordTooShort =>
      'The new password must be at least 8 characters long.';

  @override
  String get cpPasswordsDontMatch => 'The new passwords don\'t match.';

  @override
  String get cpChangedSuccess => 'Password changed successfully.';

  @override
  String get cpChangeError => 'Failed to change password.';

  @override
  String get delAccTitle => 'Delete account';

  @override
  String get delAccEnterPassword => 'Enter your password to confirm.';

  @override
  String get delAccAckRequired => 'Please confirm you understand the action.';

  @override
  String get delAccConfirmBody =>
      'This action is IRREVERSIBLE. Your account will be deactivated and your personal data anonymized (GDPR). Do you want to continue?';

  @override
  String get delAccConfirmButton => 'Delete account';

  @override
  String get delAccSuccess => 'Account deleted. Goodbye.';

  @override
  String get delAccError => 'Failed to delete account.';

  @override
  String get delAccWarningBanner =>
      'By deleting your account, you will permanently lose access to your live history, gifts, balance, conversations and followers. Pending balances may be lost.';

  @override
  String get delAccWhatHappens => 'What happens:';

  @override
  String get delAccBullet1 => 'Your account will be deactivated immediately.';

  @override
  String get delAccBullet2 =>
      'Your email and personal data will be anonymized.';

  @override
  String get delAccBullet3 => 'You will be signed out from all devices.';

  @override
  String get delAccBullet4 =>
      'Records will be kept for the legally required period.';

  @override
  String get delAccPasswordHelper => 'Confirm your identity';

  @override
  String get delAccAckCheckbox => 'I understand this action is irreversible.';

  @override
  String get delAccDeleteMyAccount => 'Delete my account';

  @override
  String get legalOpenInBrowser => 'Open in browser';

  @override
  String get legalLoadError => 'Could not load this page.';

  @override
  String get languagePickerTitle => 'Choose language';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'English';

  @override
  String get errorNetwork => 'No connection. Check your internet.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNotFound => 'Content not found.';

  @override
  String get errorUnauthorized => 'Session expired. Please log in again.';

  @override
  String get giftComingSoon => '🎁 Coming soon!';

  @override
  String get liveBadge => 'LIVE';

  @override
  String viewerCount(int count) {
    return '$count watching';
  }

  @override
  String get authLoginSubtitle => 'Sign in to your account to continue.';

  @override
  String get authWelcomeBackTitle => 'Welcome\nback.';

  @override
  String get authEmailHint => 'you@brawe.app';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authEmailLabel => 'EMAIL';

  @override
  String get authPasswordLabel => 'PASSWORD';

  @override
  String get authForgotPasswordShort => 'Forgot password';

  @override
  String get authLoggingIn => 'Signing in…';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authCreateNow => 'Sign up';

  @override
  String get authAcceptTermsAndPrivacy =>
      'By continuing you accept the Terms of Use\nand Privacy Policy.';

  @override
  String get authWelcomeBackSuccess => 'Welcome back.';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authEntrar => 'Sign in';

  @override
  String get welcomeTagline => 'Connect. Stream. Grow.';

  @override
  String get welcomeAlreadyHaveAccount => 'I already have an account';

  @override
  String get welcomeAcceptTerms => 'By continuing you accept the Terms of Use.';

  @override
  String get welcomeCreateAccount => 'Create account';

  @override
  String get signupTitle => 'Create your account.';

  @override
  String get signupSubtitle => 'It takes less than a minute to get started.';

  @override
  String get signupNameLabel => 'Full name';

  @override
  String get signupNameHint => 'What should we call you?';

  @override
  String get signupEmailLabel => 'Email';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupPasswordHint => 'minimum 8 characters';

  @override
  String get signupSponsorLabel => 'Sponsor code';

  @override
  String get signupSponsorHint => 'BRAWE-XXXX';

  @override
  String get signupHaveReferral => 'I have a referral code';

  @override
  String get signupCreatingAccount => 'Creating account…';

  @override
  String get signupCreateAccountButton => 'Create account';

  @override
  String get signupSuccess => 'Account created successfully.';

  @override
  String get signupHelp => 'Help';

  @override
  String signupCantOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get signupTermsPrefix => 'I have read and accept the ';

  @override
  String get signupTermsAnd => ' and the ';

  @override
  String get signupTermsSuffix => ' of Brawe.';

  @override
  String get pwStrengthWeak => 'Weak';

  @override
  String get pwStrengthMedium => 'Medium';

  @override
  String get pwStrengthGood => 'Good';

  @override
  String get pwStrengthStrong => 'Strong';

  @override
  String get forgotTitle => 'Recover password';

  @override
  String get forgotSubtitle =>
      'Enter your email and we\'ll send instructions to create a new password.';

  @override
  String get forgotEmailLabel => 'EMAIL';

  @override
  String get forgotEmailHint => 'you@example.com';

  @override
  String get forgotInvalidEmail => 'Please enter a valid email.';

  @override
  String get forgotSending => 'Sending...';

  @override
  String get forgotSendInstructions => 'Send instructions';

  @override
  String get forgotCannotSend => 'Could not send.';

  @override
  String get forgotBackToLogin => 'Back to sign in';

  @override
  String get forgotCheckEmail => 'Check your email';

  @override
  String forgotEmailSentBody(String email) {
    return 'If $email is registered, you will receive a link to create a new password in a few minutes.';
  }

  @override
  String get resetTitle => 'Create new password';

  @override
  String get resetSubtitle =>
      'Choose a strong password with at least 8 characters.';

  @override
  String get resetNewPasswordLabel => 'NEW PASSWORD';

  @override
  String get resetConfirmPasswordLabel => 'CONFIRM PASSWORD';

  @override
  String get resetPasswordTooShort => 'Password must be at least 8 characters.';

  @override
  String get resetPasswordsDontMatch => 'Passwords don\'t match.';

  @override
  String get resetSaving => 'Saving...';

  @override
  String get resetInvalidToken => 'Invalid or expired token.';

  @override
  String get navLives => 'Lives';

  @override
  String get createStoryTitle => 'Story';

  @override
  String get createStorySubtitle => 'Photo or video · disappears in 24h';

  @override
  String get createVideoTitle => 'Video';

  @override
  String get createVideoSubtitle => 'Reels · shows up in For You';

  @override
  String get createLiveTitle => 'Live';

  @override
  String get createLiveSubtitle => 'Stream now and receive gifts';

  @override
  String get createPostTitle => 'Post';

  @override
  String get createPostSubtitle => 'Text, photo or link on your feed';

  @override
  String get feedEmptyVideoTitle => 'No video or photo here yet.';

  @override
  String get feedEmptyVideoSubtitle =>
      'Follow creators or come back later.\nText posts are in the Feed tab.';

  @override
  String get liveJoining => 'Joining the live…';

  @override
  String get liveBadgeBattle => 'LIVE · BATTLE';

  @override
  String get liveBadgeShop => 'LIVE · SHOP';

  @override
  String get liveOfferNow => 'OFFER NOW';

  @override
  String get productFeatured => 'FEATURED';

  @override
  String get videoLoadError => 'Could not load video.';

  @override
  String get giftSendAnonymous => 'Send anonymously';

  @override
  String get giftAnonNameHidden => 'Your name will not be revealed';

  @override
  String get giftAnonNameVisible => 'Everyone will see it was you';

  @override
  String get giftSendButtonAnon => 'Send (anonymous)';

  @override
  String get giftSendButton => 'Send gift';

  @override
  String get giftSentAnon => 'Gift sent anonymously!';

  @override
  String get giftSent => 'Gift sent!';

  @override
  String get feedCannotLike => 'Could not like. Try again.';

  @override
  String get feedUseLiveChat => 'Use the live chat to talk.';

  @override
  String get feedCannotShare => 'Could not share.';

  @override
  String get feedCannotFollow => 'Could not update follow.';

  @override
  String get shareCheckBraweConnect => 'Check it out on Brawe Connect';

  @override
  String get homeStatFollowers => 'Followers';

  @override
  String get homeStatFollowing => 'Following';

  @override
  String get homeStatLives => 'Lives';

  @override
  String get profileViewFull => 'View full profile';

  @override
  String get createSheetTitle => 'Create';

  @override
  String get createSheetSubtitle => 'Share a moment, go live, or drop an idea.';

  @override
  String get productsDrawerTitle => 'Live shop';

  @override
  String productsDrawerItemCount(int count, String author) {
    return '$count items • $author';
  }

  @override
  String get giftMysteryTitle => 'Mystery Gift';

  @override
  String get giftMysterySubtitle =>
      'Surprise one of the streamers!\nThe recipient is chosen at random. 🎲';

  @override
  String get commentsErrorSend => 'Failed to send comment. Try again.';

  @override
  String get commentsErrorLoad => 'Failed to load comments.';

  @override
  String commentsReplyingTo(String username) {
    return 'Replying to @$username';
  }

  @override
  String get commentsHintReply => 'Reply...';

  @override
  String get commentsHintAdd => 'Add a comment...';

  @override
  String get commentsReplyAction => 'Reply';

  @override
  String get postPublish => 'Publish';

  @override
  String get postPublishedSuccess => 'Post published!';

  @override
  String get postPublishError => 'Failed to publish. Try again.';

  @override
  String get postHintWhatsHappening => 'What\'s happening?';

  @override
  String get audiencePickerTitle => 'Who can see?';

  @override
  String get audienceAll => 'Everyone';

  @override
  String get audienceFollowers => 'Followers';

  @override
  String get audienceOnlyMe => 'Only me';

  @override
  String get videoTooLarge => 'Video too large. Max 100 MB.';

  @override
  String get videoOpenError => 'Couldn\'t open the video.';

  @override
  String get videoPublishedSuccess => 'Video published! 🎬';

  @override
  String get videoPublishError => 'Failed to publish video. Try again.';

  @override
  String get videoSheetTitle => 'New video';

  @override
  String get videoSwapTooltip => 'Swap video';

  @override
  String get videoCaptionHint => 'Write a caption (optional)…';

  @override
  String get videoPublishButton => 'Publish video';

  @override
  String get videoSelect => 'Select video';

  @override
  String get videoFormatsHint =>
      'MP4 · MOV · WebM   ·   up to 3 min   ·   100 MB';

  @override
  String get storySheetTitle => 'New story';

  @override
  String get storyPublish => 'Publish';

  @override
  String get storyPublishedSuccess => 'Story published!';

  @override
  String get storyPublishError => 'Failed to publish story. Try again.';

  @override
  String get storyPrefetchError => 'Failed to load image from post.';

  @override
  String get storyPrefetchLoading => 'Loading image from post...';

  @override
  String get storyCaptionHint => 'Write a caption (optional)…';

  @override
  String get storySwapMedia => 'Swap media';

  @override
  String get storyPickerTitle => 'Select or record media';

  @override
  String get storyPickerSubtitle => 'Photo or video (up to 60s)';

  @override
  String get storyPickerSectionGallery => 'Gallery';

  @override
  String get storyPickerSectionCamera => 'Camera';

  @override
  String get storyPickerChipPhoto => 'Photo';

  @override
  String get storyPickerChipVideo => 'Video';

  @override
  String get storyPickerChipRecordVideo => 'Record video';

  @override
  String get storiesReload => 'Reload stories';

  @override
  String get storiesYour => 'Your story';

  @override
  String get storiesCreate => 'Create';

  @override
  String get storiesFallbackUser => 'user';

  @override
  String get storiesLiveBadge => 'LIVE';

  @override
  String get shareLoadError => 'Could not load contacts.';

  @override
  String shareSentSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent to $count people.',
      one: 'Sent to $count person.',
    );
    return '$_temp0';
  }

  @override
  String shareSentPartial(int sent, int failures) {
    return 'Sent to $sent. Failed for $failures.';
  }

  @override
  String get shareTitle => 'Send to...';

  @override
  String get sharePostFallback => 'Post';

  @override
  String get shareSearchHint => 'Search';

  @override
  String get shareErrorGeneric => 'Error';

  @override
  String get shareTryAgain => 'Try again';

  @override
  String get shareRecents => 'Recent';

  @override
  String get shareFollowers => 'Followers';

  @override
  String get shareUserFallback => 'User';

  @override
  String get shareNoContacts => 'No contacts found.';

  @override
  String get shareCommentHint => 'Add a comment…';

  @override
  String get shareOutsideBrawe => 'Outside Brawe';

  @override
  String get shareSend => 'Send';

  @override
  String shareSendWithCount(int count) {
    return 'Send ($count)';
  }

  @override
  String giftSendError(Object error) {
    return 'Could not send the gift: $error';
  }

  @override
  String giftLoadError(Object error) {
    return 'Could not load gifts.\n$error';
  }

  @override
  String get giftEmptyState => 'No gifts available right now.';

  @override
  String get giftSendTo => 'Send gift to';

  @override
  String get giftChoose => 'Choose a gift';

  @override
  String giftSendCta(int total) {
    return 'SEND · 💎 $total';
  }

  @override
  String get suggestedTitle => 'Suggestions for you';

  @override
  String get suggestedSeeAll => 'See all';

  @override
  String get suggestedFollow => 'Follow';

  @override
  String get suggestedFollowing => 'Following';

  @override
  String get suggestedLiveBadge => 'LIVE';

  @override
  String get composerMediaLoadError => 'Could not load media.';

  @override
  String get composerPhotoError => 'Failed to take photo.';

  @override
  String get composerRecordStartError => 'Failed to start recording.';

  @override
  String get composerRecordStopError => 'Failed to finish recording.';

  @override
  String get composerStoryPublished => 'Story published!';

  @override
  String composerMultipleStoriesPublished(int count) {
    return '$count stories published!';
  }

  @override
  String get composerPublishError => 'Failed to publish story.';

  @override
  String get composerPublishTimeoutMaybe =>
      'Slow connection — check your feed; if the story is there, it\'s published.';

  @override
  String get composerRetry => 'Try again';

  @override
  String get composerPreparing => 'Preparing to publish…';

  @override
  String get composerCreateStory => 'Create story';

  @override
  String get composerCaptureHint => 'Tap for photo • Hold for video';

  @override
  String get composerGallery => 'Gallery';

  @override
  String get composerTextOnly => 'Text only';

  @override
  String get composerFrameNone => 'No frame';

  @override
  String get composerFramePolaroid => 'Polaroid';

  @override
  String get composerFrameBrawe => 'Brawe';

  @override
  String get composerFrameHint => 'Double tap for frame';

  @override
  String composerFrameLabel(String style) {
    return 'Frame: $style';
  }

  @override
  String get composerCaptionHint => 'Add a caption...';

  @override
  String get composerYourStory => 'Your story';

  @override
  String get composerShare => 'Share';

  @override
  String get composerTapOutsideHint => 'Tap outside to finish';

  @override
  String get composerTextHint => 'Type something...';

  @override
  String get composerGuideTop => 'safe top';

  @override
  String get composerGuideBottom => 'safe bottom';

  @override
  String get composerSaveToDevice => 'Save to device';

  @override
  String get composerSavedToDevice => 'Saved to gallery';

  @override
  String get composerSavePermissionDenied => 'Gallery access denied.';

  @override
  String get composerSaveError => 'Could not save.';

  @override
  String get trimTitle => 'Trim video';

  @override
  String get trimSave => 'Done';

  @override
  String get trimCancel => 'Cancel';

  @override
  String get trimProcessing => 'Saving…';

  @override
  String trimDuration(String seconds) {
    return '${seconds}s';
  }

  @override
  String get trimError => 'Could not save trimmed video.';

  @override
  String get trimHint => 'Drag the handles to choose start and end';

  @override
  String get volumeMixerButtonLabel => 'Volumes';

  @override
  String get volumeMixerTitle => 'Volumes';

  @override
  String get volumeMixerSubtitle =>
      'Adjust the music volume and the video\'s original audio volume';

  @override
  String get volumeMixerMusicLabel => 'Music';

  @override
  String get volumeMixerOriginalLabel => 'Video\'s original audio';

  @override
  String get volumeMixerDone => 'Done';

  @override
  String get giftTierFree => 'Vault';

  @override
  String get giftTierBasic => 'Basic';

  @override
  String get giftTierPremium => 'Premium';

  @override
  String get giftTierLuxury => 'Luxury';

  @override
  String get giftTierLegendary => 'Legendary';

  @override
  String get viewerDeleteStory => 'Delete story';

  @override
  String get viewerUnfollow => 'Unfollow';

  @override
  String get viewerBlockUser => 'Block user';

  @override
  String get viewerReport => 'Report';

  @override
  String get viewerDeleteConfirm => 'This action cannot be undone.';

  @override
  String get viewerCancel => 'Cancel';

  @override
  String get viewerDelete => 'Delete';

  @override
  String get viewerBlock => 'Block';

  @override
  String get viewerStoryDeleted => 'Story deleted.';

  @override
  String viewerDeleteError(Object error) {
    return 'Could not delete the story. ($error)';
  }

  @override
  String viewerUnfollowed(String username) {
    return 'You unfollowed @$username.';
  }

  @override
  String get viewerUnfollowError => 'Could not unfollow.';

  @override
  String viewerBlockConfirm(String username) {
    return 'You won\'t see content from @$username anymore.';
  }

  @override
  String get viewerBlockError => 'Could not block.';

  @override
  String get viewerReportPrompt => 'Why are you reporting?';

  @override
  String get viewerReportSpam => 'Spam or misleading';

  @override
  String get viewerReportHarassment => 'Harassment or bullying';

  @override
  String get viewerReportInappropriate => 'Inappropriate or offensive content';

  @override
  String get viewerReportImpersonation => 'False identity';

  @override
  String get viewerReportOther => 'Other';

  @override
  String get viewerReportSent => 'Report sent. Thank you.';

  @override
  String get viewerReportError => 'Could not send the report.';

  @override
  String get viewerSeeOriginalPost => 'See original post';

  @override
  String get viewerReplySent => 'Reply sent.';

  @override
  String get viewerReplyError => 'Could not reply.';

  @override
  String get viewerReplyHint => 'Reply to story...';

  @override
  String viewerGiftSent(String giftName, int quantity, int credits) {
    return 'Sent $giftName x$quantity · 💎 $credits';
  }

  @override
  String get viewerLoadViewersError => 'Could not load viewers.';

  @override
  String get viewerTimeNow => 'now';

  @override
  String viewerTimeMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String viewerTimeHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String viewerTimeDays(int days) {
    return '${days}d ago';
  }

  @override
  String get viewerLoading => 'Loading...';

  @override
  String get viewerNoViewers => 'No one has viewed this story yet.';

  @override
  String viewerBlocked(String username) {
    return '@$username blocked.';
  }

  @override
  String viewerViewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count views',
      one: '1 view',
    );
    return '$_temp0';
  }

  @override
  String get feedTabForYou => 'For You';

  @override
  String get feedTabFollowing => 'Following';

  @override
  String get feedEmptyQuietTitle => 'The feed is quiet';

  @override
  String get feedEmptyQuietSubtitle =>
      'Be the first to post something brilliant today.';

  @override
  String get feedEmptyFollowingTitle => 'Nothing here yet';

  @override
  String get feedEmptyFollowingSubtitle =>
      'Follow people to see their posts here.';

  @override
  String get feedOfflineTitle => 'No connection here';

  @override
  String get feedOfflineSubtitle => 'Check your internet and try again.';

  @override
  String get feedRetry => 'Try again';

  @override
  String get feedSaved => 'Saved to your favorites';

  @override
  String get feedUnsaved => 'Removed from favorites';

  @override
  String get feedLinkCopied => 'Link copied!';

  @override
  String get feedDeletePostTitle => 'Delete post?';

  @override
  String get feedDeleteConfirm => 'This action cannot be undone.';

  @override
  String get feedCancel => 'Cancel';

  @override
  String get feedDelete => 'Delete';

  @override
  String get feedPostDeleted => 'Post deleted.';

  @override
  String get feedPostDeleteError => 'Could not delete the post.';

  @override
  String feedUnfollowed(String username) {
    return 'You unfollowed @$username.';
  }

  @override
  String get feedUnfollowError => 'Could not unfollow.';

  @override
  String get feedBlockUserTitle => 'Block user';

  @override
  String feedBlockConfirm(String username) {
    return 'You won\'t see content from @$username anymore. Continue?';
  }

  @override
  String get feedBlock => 'Block';

  @override
  String get feedBlockError => 'Could not block.';

  @override
  String get feedReportTitle => 'Report post';

  @override
  String get feedReportPrompt => 'Why are you reporting?';

  @override
  String get feedReportSpam => 'Spam or misleading';

  @override
  String get feedReportHarassment => 'Harassment or bullying';

  @override
  String get feedReportInappropriate => 'Inappropriate or offensive content';

  @override
  String get feedReportImpersonation => 'False identity';

  @override
  String get feedReportOther => 'Other';

  @override
  String get feedReportSent => 'Report sent. Thanks for letting us know.';

  @override
  String get feedReportError => 'Could not send the report.';

  @override
  String get feedRepostUndoConfirm => 'Undo repost?';

  @override
  String get feedRepostConfirm => 'Repost to your followers?';

  @override
  String get feedRepostUndo => 'Undo repost';

  @override
  String get feedRepost => 'Repost';

  @override
  String get feedReposted => 'Reposted to your followers';

  @override
  String get shareToFollowers => 'Send to followers';

  @override
  String feedRepostBanner(String name) {
    return '$name reposted';
  }

  @override
  String get feedQuotePost => 'Quote post';

  @override
  String get feedCopyLink => 'Copy link';

  @override
  String get feedShareAsStory => 'Share as Story';

  @override
  String get feedUnfollow => 'Unfollow';

  @override
  String get feedReport => 'Report';

  @override
  String get feedDeletePost => 'Delete post';

  @override
  String get feedSend => 'Send';

  @override
  String get feedTimeNow => 'now';

  @override
  String feedBlocked(String username) {
    return '@$username blocked.';
  }

  @override
  String get chatStatusOnline => 'Online';

  @override
  String get chatStatusAway => 'Away';

  @override
  String get chatStatusDnd => 'Do not disturb';

  @override
  String get chatStatusInvisible => 'Invisible';

  @override
  String get chatStatusSheetTitle => 'My Status';

  @override
  String get chatStatusSheetSubtitle => 'Choose how you appear to other users.';

  @override
  String get chatNewMessageTitle => 'New Message';

  @override
  String get chatSearchHint => 'Search people you follow…';

  @override
  String get chatFollowingLabel => 'Following';

  @override
  String chatStartConversationError(Object error) {
    return 'Error starting conversation: $error';
  }

  @override
  String chatLoadError(Object error) {
    return 'Loading error: $error';
  }

  @override
  String get chatLiveBadge => 'LIVE';

  @override
  String get chatFallbackName => 'Chat';

  @override
  String get chatEmptySearchTitle => 'No people found';

  @override
  String get chatEmptySearchSubtitle =>
      'Try searching by name or @username of someone you follow.';

  @override
  String get chatListTitle => 'Messages';

  @override
  String get chatListSearchHint => 'Search conversations, people…';

  @override
  String get chatListTabAll => 'All';

  @override
  String get chatListTabUnread => 'Unread';

  @override
  String get chatListTabArchived => 'Archived';

  @override
  String get chatListRetry => 'Try again';

  @override
  String get chatListNewTooltip => 'New conversation';

  @override
  String get chatListEmptyTitle => 'Start a conversation';

  @override
  String get chatListEmptySubtitle =>
      'Your messages with creators, friends and brawers will appear here.';

  @override
  String get chatListTapToTalk => 'Tap to chat';

  @override
  String get chatListArchive => 'Archive';

  @override
  String get chatListUnarchive => 'Unarchive';

  @override
  String get chatListDelete => 'Delete';

  @override
  String get chatListDeleteConfirmTitle => 'Delete conversation?';

  @override
  String get chatListDeleteConfirmBody =>
      'The conversation will be deleted only for you.';

  @override
  String get chatListCancel => 'Cancel';

  @override
  String get chatListTimeNow => 'now';

  @override
  String chatDetailPickImageError(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String chatDetailBlockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get chatDetailBlockBody =>
      'You won\'t be able to send or receive messages from this person anymore.';

  @override
  String get chatDetailCancel => 'Cancel';

  @override
  String get chatDetailBlock => 'Block';

  @override
  String chatDetailBlocked(String name) {
    return '$name has been blocked.';
  }

  @override
  String chatDetailBlockError(Object error) {
    return 'Error blocking: $error';
  }

  @override
  String get chatDetailViewProfile => 'View profile';

  @override
  String get chatDetailOpenProfileError =>
      'Could not open this contact\'s profile.';

  @override
  String get chatDetailMute => 'Mute notifications';

  @override
  String get chatDetailComingSoon => 'Coming soon';

  @override
  String get chatDetailSearchInChat => 'Search in chat';

  @override
  String chatDetailBlockMenu(String name) {
    return 'Block $name';
  }

  @override
  String get chatDetailReport => 'Report';

  @override
  String get chatDetailReportSent => 'Report sent. Thank you!';

  @override
  String get chatDetailStatusTyping => 'typing';

  @override
  String get chatDetailStatusOnline => 'Online';

  @override
  String chatDetailStatusSeen(String when) {
    return 'seen $when';
  }

  @override
  String get chatDetailStatusOffline => 'Offline';

  @override
  String get chatDetailDateToday => 'Today';

  @override
  String get chatDetailDateYesterday => 'Yesterday';

  @override
  String get chatDetailReply => 'Reply';

  @override
  String get chatDetailCopy => 'Copy';

  @override
  String get chatDetailDeleteForMe => 'Delete for me';

  @override
  String get chatDetailViewOnceBadge => 'View once';

  @override
  String get chatDetailViewOnceTitle => 'View once';

  @override
  String get chatDetailPhotoViewedOnce => 'Photo viewed once';

  @override
  String get chatDetailPhotoUnavailable => 'Photo is no longer available';

  @override
  String get chatDetailEmptyTitle => 'Say hello 👋';

  @override
  String get chatDetailEmptySubtitle =>
      'Send the first message to start the conversation.';

  @override
  String get chatDetailReplying => 'Replying';

  @override
  String get chatDetailReplyImagePreview => '📷 Photo';

  @override
  String get chatDetailMessageHint => 'Message';

  @override
  String get chatDetailVoiceTitle => 'Voice message';

  @override
  String get chatDetailVoiceSubtitle =>
      'Coming soon — recording with animated waveform';

  @override
  String get chatDetailClose => 'Close';

  @override
  String get chatDetailAttachGallery => 'Gallery';

  @override
  String get chatDetailAttachCamera => 'Camera';

  @override
  String get chatDetailAttachAudio => 'Audio';

  @override
  String get chatDetailAttachLocation => 'Location';

  @override
  String get chatDetailAttachFile => 'File';

  @override
  String get chatDetailAttachMystery => 'Mystery';

  @override
  String get chatDetailRelativeNow => 'now';

  @override
  String chatDetailRelativeMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String chatDetailRelativeHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String chatDetailRelativeDays(int days) {
    return '${days}d ago';
  }

  @override
  String get chatDetailViewPost => 'View post';

  @override
  String get chatDetailPostUnavailable => 'Post unavailable';

  @override
  String get chatDetailOpenPostSoon => 'Open post coming soon';

  @override
  String get chatDetailBurnedPreview => '🔥 Burned message';

  @override
  String get chatDetailStreamerFallback => 'Streamer';

  @override
  String get chatDetailLiveFallbackTitle => 'Live';

  @override
  String get chatDetailLiveTapToWatch => 'Tap to watch';

  @override
  String get chatDetailLiveSeeDetails => 'See details';

  @override
  String get chatDetailEmojiSmileys => 'Smileys';

  @override
  String get chatDetailEmojiGestures => 'Gestures';

  @override
  String get chatDetailEmojiHearts => 'Hearts';

  @override
  String get chatDetailEmojiAnimals => 'Animals';

  @override
  String get chatDetailEmojiFood => 'Food';

  @override
  String get chatDetailEmojiParty => 'Party';

  @override
  String get chatDetailEmojiObjects => 'Objects';

  @override
  String get profileTabGallery => 'Gallery';

  @override
  String get profileTabLives => 'Lives';

  @override
  String get profileTabShop => 'Shop';

  @override
  String get profileTooltipShop => 'Shop';

  @override
  String get profileTooltipQuests => 'Quests';

  @override
  String get profileTooltipNotifications => 'Notifications';

  @override
  String get profileTooltipWallet => 'Wallet';

  @override
  String get profileShareFail => 'Could not share.';

  @override
  String get profileLinkCopied => 'Link copied to clipboard';

  @override
  String get profileBlockedSuccess => 'User blocked.';

  @override
  String get profileBlockedError => 'Failed to block. Try again.';

  @override
  String get profileReportSent => 'Report sent. Thank you.';

  @override
  String get profileReportError => 'Failed to report. Try again.';

  @override
  String get profileBlockTitle => 'Block';

  @override
  String profileBlockBody(String name) {
    return 'Are you sure you want to block $name? You will no longer be able to exchange messages or see each other\'s content.';
  }

  @override
  String get profileFallbackUser => 'this user';

  @override
  String get profileReportQuestion => 'Why are you reporting?';

  @override
  String get profileReportReasonSpam => 'Spam';

  @override
  String get profileReportReasonHarassment => 'Harassment or bullying';

  @override
  String get profileReportReasonInappropriate => 'Inappropriate content';

  @override
  String get profileReportReasonImpersonation => 'Impersonation';

  @override
  String get profileReportReasonOther => 'Other reason';

  @override
  String get profileOptionShareProfile => 'Share profile';

  @override
  String get profileOptionCopyLink => 'Copy link';

  @override
  String get profileOptionReport => 'Report';

  @override
  String get profileOptionDailyQuests => 'Daily quests';

  @override
  String get profileOptionWallet => 'Wallet';

  @override
  String get profileOptionNotifications => 'Notifications';

  @override
  String get profileOptionSettings => 'Settings';

  @override
  String get profileOptionLogout => 'Log out';

  @override
  String get profileLogoutTitle => 'Log out?';

  @override
  String get profileLogoutBody =>
      'You will need to sign in again to access your arena.';

  @override
  String get profileLogoutConfirm => 'Log out';

  @override
  String get profileMessageButton => 'Message';

  @override
  String profileOpenConversationError(Object error) {
    return 'Error opening conversation: $error';
  }

  @override
  String get profileChatFallback => 'Chat';

  @override
  String get profileUserFallback => 'User';

  @override
  String get profileEditTooltip => 'Edit profile';

  @override
  String get profileStatFollowers => 'Followers';

  @override
  String get profileStatFollowing => 'Following';

  @override
  String get profileStatLives => 'Lives';

  @override
  String get profileStatViews => 'Views';

  @override
  String get profileLoadError => 'Could not load the profile';

  @override
  String get profileLoadErrorHint => 'Check your connection and try again.';

  @override
  String get profileRetry => 'Try again';

  @override
  String get profileSellerVerified => 'Verified partner';

  @override
  String get profileSellerSubtitle => 'Handpicked product selection';

  @override
  String shopVitrinePartnerItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get profileNoTextPosts => 'No text posts yet';

  @override
  String get profilePostsLoadError => 'Error loading posts';

  @override
  String get profileNoLives => 'No lives yet';

  @override
  String get profileLivesLoadError => 'Error loading lives';

  @override
  String get profileShopEmpty => 'Empty shop';

  @override
  String get profileShopFeatured => 'Featured';

  @override
  String get profileShopAllProducts => 'All products';

  @override
  String get profileShowcaseEmptyTitleMe => 'Your storefront is empty';

  @override
  String get profileShowcaseEmptyTitleOther => 'No products yet';

  @override
  String get profileShowcaseEmptySubtitleMe =>
      'Become a brand partner and showcase the products you recommend.';

  @override
  String get profileShowcaseEmptySubtitleOther =>
      'This creator hasn\'t added products to their storefront yet.';

  @override
  String get profileShowcaseJoinCreatorNetwork => 'Join the Creator Network';

  @override
  String get profileLiveBadge => 'LIVE';

  @override
  String get profileProductSoldOut => 'Sold out';

  @override
  String get profileProductSoldOutUppercase => 'SOLD OUT';

  @override
  String get profileProductAbout => 'About the product';

  @override
  String get profileProductUnavailable => 'Unavailable';

  @override
  String get profileProductBuyNow => 'Buy now';

  @override
  String get profileAddedToCart => '🛒 Added to cart!';

  @override
  String get profileGalleryLoadError => 'Error loading gallery';

  @override
  String get profileGalleryEmpty => 'Nothing here yet';

  @override
  String get profileGalleryRemoveTitle => 'Remove media?';

  @override
  String get profileGalleryRemoveBody => 'This action cannot be undone.';

  @override
  String get profileGalleryRemove => 'Remove';

  @override
  String get profileVideoDeleteTitle => 'Delete video?';

  @override
  String get profileVideoDelete => 'Delete';

  @override
  String get profileVideoDeleted => 'Video deleted';

  @override
  String get profileVideoDeleteError => 'Failed to delete video';

  @override
  String get profileVideoRepostStory => 'Repost to Stories';

  @override
  String get profileVideoDeleteAction => 'Delete video';

  @override
  String get profileVideoLoadError => 'Could not load the video.';

  @override
  String profileGalleryTabPhotos(int count, int max) {
    return 'Photos ($count/$max)';
  }

  @override
  String profileGalleryTabVideos(int count, int max) {
    return 'Videos ($count/$max)';
  }

  @override
  String get profileGalleryPhotoAdded => 'Photo added';

  @override
  String get profileGalleryPhotoError => 'Failed to upload photo';

  @override
  String get profileGalleryVideoAdded => 'Video added';

  @override
  String get profileGalleryVideoError => 'Failed to upload video';

  @override
  String get profileVideoDeleteBody =>
      'This action cannot be undone. The video will be removed from For You and your profile.';

  @override
  String profileProductLastStock(int count) {
    return 'Last $count';
  }

  @override
  String profileProductSoldCount(int count) {
    return '$count sold';
  }

  @override
  String profileProductLowStock(int count) {
    return 'Only $count left';
  }

  @override
  String profileProductInStock(int count) {
    return '$count in stock';
  }

  @override
  String get profileProductDescription =>
      'Exclusive product from the official store. Ships within 3 business days. 30-day guarantee and free exchange.';

  @override
  String profilePriceBRL(String amount) {
    return 'R\\\$ $amount';
  }

  @override
  String get profileVideosLoadError => 'Error loading videos';

  @override
  String get profileVideosEmpty => 'No videos posted yet';

  @override
  String get profileVideoSwipeHint => 'Swipe';

  @override
  String get notificationsMarkAll => 'Mark all';

  @override
  String get notificationsEmptyTitle => 'All caught up!';

  @override
  String get notificationsEmptySubtitle =>
      'You don\'t have any new notifications.';

  @override
  String get notificationsLoadError => 'Couldn\'t load your notifications.';

  @override
  String get notificationsTryAgain => 'Try again';

  @override
  String get notificationsTimeNow => 'now';

  @override
  String notificationsTimeMinutes(int n) {
    return '${n}m ago';
  }

  @override
  String notificationsTimeHours(int n) {
    return '${n}h ago';
  }

  @override
  String notificationsTimeDays(int n) {
    return '${n}d ago';
  }

  @override
  String get followsTitle => 'People';

  @override
  String get followsTabFollowers => 'Followers';

  @override
  String get followsTabFollowing => 'Following';

  @override
  String get followsSearchHint => 'Search...';

  @override
  String get followsLoadError => 'Loading error';

  @override
  String get followsTryAgain => 'Try again';

  @override
  String followsNoResults(String q) {
    return 'No results for \"$q\"';
  }

  @override
  String get followsEmptyFollowers => 'No followers yet';

  @override
  String get followsEmptyFollowing => 'Not following anyone yet';

  @override
  String get followsUserFallback => 'User';

  @override
  String get followsLiveBadge => 'LIVE';

  @override
  String get questsTitle => 'Daily Quests';

  @override
  String questsClaimAll(int count) {
    return 'Claim all ($count)';
  }

  @override
  String questsClaimedReward(int n) {
    return '$n reward(s) collected!';
  }

  @override
  String get questsNothingToClaim => 'Nothing to claim right now.';

  @override
  String questsClaimSuccess(int xp, int coins) {
    return '+$xp XP · +$coins coins';
  }

  @override
  String get questsClaimError => 'Failed to claim. Try again.';

  @override
  String get questsEmpty => 'No quests for now.\nCome back later!';

  @override
  String questsLevel(int level) {
    return 'Level $level';
  }

  @override
  String questsXpProgress(int current, int total) {
    return '$current / $total XP';
  }

  @override
  String get questsSummaryCompleted => 'Completed';

  @override
  String get questsSummaryXpToday => 'XP today';

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
    return '+$coins coins';
  }

  @override
  String get questsStatusClaimed => 'Claimed ✓';

  @override
  String get questsStatusInProgress => 'In progress';

  @override
  String get questsActionClaim => 'Claim';

  @override
  String get questsLoadError => 'Couldn\'t load quests.';

  @override
  String get questsTryAgain => 'Try again';

  @override
  String questsSummaryCompletedValue(int done, int total) {
    return '$done/$total';
  }

  @override
  String get walletTitle => 'Brawe Coins';

  @override
  String get walletAvailableBalance => 'Coin balance';

  @override
  String get walletCoins => 'coins';

  @override
  String get walletSectionBuyTitle => 'Buy coins';

  @override
  String get walletSectionBuySubtitle =>
      'Use coins to send virtual gifts to creators in lives';

  @override
  String get walletSectionHistoryTitle => 'Gift history';

  @override
  String get walletSectionHistorySubtitle => 'Gifts sent and received in lives';

  @override
  String get giftersTabReceived => 'Received';

  @override
  String get giftersTabSent => 'Sent';

  @override
  String get giftersEmptyReceivedTitle => 'No one has gifted you yet';

  @override
  String get giftersEmptyReceivedBody =>
      'When someone sends you gifts in lives, they\'ll be grouped by person here.';

  @override
  String get giftersEmptySentTitle => 'You haven\'t sent any gifts';

  @override
  String get giftersEmptySentBody =>
      'The creators you support in lives will appear here, grouped by person.';

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
      other: '$n gifts',
      one: '1 gift',
    );
    return '$_temp0';
  }

  @override
  String get giftersActionThank => 'Thank';

  @override
  String get giftersActionMessage => 'Message';

  @override
  String get giftersActionFollow => 'Follow';

  @override
  String get giftersActionFollowing => 'Following';

  @override
  String get giftersDetailTotalReceived => 'Total received';

  @override
  String get giftersDetailTotalSent => 'Total sent';

  @override
  String get giftersDetailGiftsTitle => 'Gifts';

  @override
  String get giftersBadgeFollowsYou => 'Follows you';

  @override
  String get giftersLoadError => 'Couldn\'t load';

  @override
  String get giftersFollowError => 'Couldn\'t follow. Try again.';

  @override
  String walletPackageCoins(String n) {
    return '$n coins';
  }

  @override
  String walletPriceBRL(String value) {
    return 'R\$ $value';
  }

  @override
  String get walletPurchaseInfo =>
      'In-app payments coming soon. For now, buy coins via browser at brawe.app/coins.';

  @override
  String get walletPurchaseUnderstood => 'Got it';

  @override
  String get walletInfoTitle => 'How coins work';

  @override
  String get walletInfoQuestsTitle => 'Daily missions';

  @override
  String get walletInfoQuestsBody =>
      'Complete missions and earn coins + XP every day.';

  @override
  String get walletInfoGiftsTitle => 'Receive gifts';

  @override
  String get walletInfoGiftsBody =>
      'Your followers can send virtual gifts during your lives.';

  @override
  String get walletInfoUseTitle => 'Send gifts';

  @override
  String get walletInfoUseBody =>
      'Use coins to send virtual gifts to your favorite creators.';

  @override
  String get walletLoadError => 'Couldn\'t load your coins.';

  @override
  String get walletTryAgain => 'Try again';

  @override
  String get walletActionAdd => 'Add';

  @override
  String get walletActionSend => 'Send gift';

  @override
  String get walletActionStatement => 'History';

  @override
  String get walletComingSoon => 'Coming soon.';

  @override
  String get walletTxLoadError => 'Couldn\'t load history.';

  @override
  String get walletTxEmpty => 'No gifts yet.';

  @override
  String get walletTxTo => 'To';

  @override
  String get walletTxFrom => 'From';

  @override
  String get walletIapInfo =>
      'Purchase processed by the official store (Google Play / App Store). Coins are credited automatically after payment. Coins are non-redeemable virtual items used only to send gifts in lives.';

  @override
  String walletIapBuyFor(String price) {
    return 'Buy for $price';
  }

  @override
  String get walletIapProcessing => 'Processing…';

  @override
  String get walletIapUnavailable => 'Unavailable';

  @override
  String get walletIapPackageUnavailable =>
      'Pack unavailable in the store. Try again soon.';

  @override
  String get walletIapNotSupported =>
      'This platform does not support in-app purchases.';

  @override
  String get walletIapStoreUnavailable =>
      'In-app purchases unavailable on this device. Make sure your Google/Apple account is set up.';

  @override
  String get walletIapPaymentPending =>
      'Payment is processing. Coins will be credited once the store confirms it.';

  @override
  String get walletIapPaymentError =>
      'Failed to process the purchase. Please try again.';

  @override
  String walletIapSuccess(String coins) {
    return 'Coins credited successfully! (+$coins)';
  }

  @override
  String get earningsTitle => 'Creator Rewards';

  @override
  String get earningsCurrency => 'Display currency';

  @override
  String get earningsCoinsBalance => 'Available coins';

  @override
  String get earningsDiamondsBalance => 'Diamonds from Creator Program';

  @override
  String get earningsDiamonds => 'diamonds';

  @override
  String get earningsTotalSpent => 'Coins spent on gifts';

  @override
  String get earningsTotalEarned => 'Diamonds received from gifts';

  @override
  String get earningsAccountNumber => 'Brawe ID';

  @override
  String get earningsPurchaseHistoryTitle => 'Purchase history';

  @override
  String get earningsPurchaseHistorySubtitle =>
      'Coin purchases via App Store / Google Play';

  @override
  String get earningsGiftHistoryTitle => 'Received gifts';

  @override
  String get earningsGiftHistorySubtitle =>
      'Source of your Creator Program diamonds';

  @override
  String get earningsNoPurchases => 'You haven\'t bought coins yet.';

  @override
  String get earningsNoGifts => 'You haven\'t received gifts yet.';

  @override
  String get earningsLoadError => 'Couldn\'t load your rewards.';

  @override
  String get earningsStatusCompleted => 'Completed';

  @override
  String get earningsStatusPending => 'Pending';

  @override
  String get earningsStatusFailed => 'Failed';

  @override
  String get earningsStatusRefunded => 'Refunded';

  @override
  String get earningsDisclaimerTitle => 'About Coins and Diamonds';

  @override
  String get earningsDisclaimerBody =>
      'Brawe Coins and Diamonds are non-redeemable virtual items used exclusively to send gifts during live streams. They are not investments, securities, or e-money. USD/BRL/EUR values shown are for reference only and do not represent a right to withdraw or convert to cash.';

  @override
  String get earningsReferenceValueOnly => 'Reference value';

  @override
  String get postDetailTitle => 'Post';

  @override
  String get postDetailNotFound =>
      'We couldn\'t load this post. It may have been removed.';

  @override
  String get postDetailGoHome => 'Go to Home';

  @override
  String get postLikersTitle => 'Likes';

  @override
  String get postLikersEmpty => 'No one has liked this post yet.';

  @override
  String get postLikersLoadError => 'Couldn\'t load likes.';

  @override
  String postLikersTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
      zero: 'No likes',
    );
    return '$_temp0';
  }

  @override
  String get reactionLike => 'Like';

  @override
  String get reactionLove => 'Love';

  @override
  String get reactionFire => 'Fire';

  @override
  String get reactionLaugh => 'Haha';

  @override
  String get reactionWow => 'Wow';

  @override
  String get reactionSad => 'Sad';

  @override
  String get exploreSearchHint => 'Search streamers, lives, categories…';

  @override
  String get exploreTabTrending => 'Trending';

  @override
  String get exploreTabCategories => 'Categories';

  @override
  String get exploreTabRecommended => 'For you';

  @override
  String get exploreSectionLives => 'Live now';

  @override
  String get exploreSectionTrendingStreamers => 'Trending streamers';

  @override
  String get exploreSectionRecommendedLives => 'Recommended lives';

  @override
  String get exploreSectionRecommendedStreamers => 'Streamers you may like';

  @override
  String get exploreEmptyTrending => 'Nothing trending right now';

  @override
  String get exploreEmptyCategories => 'No categories available.';

  @override
  String get exploreEmptyRecommended =>
      'Follow some streamers to get personalized recommendations!';

  @override
  String get exploreEmptySearch => 'No results.';

  @override
  String get exploreCategoryGeneral => 'General';

  @override
  String exploreFollowersCount(int count) {
    return '$count followers';
  }

  @override
  String exploreCategoryLiveCount(int count) {
    return '$count live';
  }

  @override
  String get exploreLoadError => 'Loading error. Pull down to try again.';

  @override
  String exploreLiveSubtitle(String streamer, String category) {
    return '$streamer • $category';
  }

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileLoadError => 'Failed to load profile';

  @override
  String get editProfileSaved => 'Profile updated';

  @override
  String get editProfileSavedUsernameFailed =>
      'Profile saved, but failed to update username';

  @override
  String get editProfileSectionInfo => 'Information';

  @override
  String get editProfileSectionSocial => 'Social links';

  @override
  String get editProfileFieldName => 'Display name';

  @override
  String get editProfileFieldNameRequired => 'Required';

  @override
  String get editProfileFieldBio => 'Bio';

  @override
  String get editProfileFieldBioHint => 'Tell us a bit about you...';

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
  String get editProfileSocialUserHint => '@user';

  @override
  String get editProfileSocialChannelHint => 'channel';

  @override
  String get editProfileSocialUrlHint => 'https://...';

  @override
  String get editProfileBannerAdd => 'Add banner';

  @override
  String get editProfileBannerPosition => 'Position banner';

  @override
  String get editProfileAvatarPosition => 'Position photo';

  @override
  String get editProfileUsernameLabel => 'Username';

  @override
  String get editProfileUsernameHint => '@yourname';

  @override
  String get editProfileUsernameAvailable => 'Available';

  @override
  String get editProfileUsernameTooShort => 'Minimum 3 characters';

  @override
  String get editProfileUsernameInvalid =>
      'Only letters, numbers and _ (must start with a letter)';

  @override
  String get editProfileImageProcessError => 'Could not process the image.';

  @override
  String get editProfileImageDone => 'Done';

  @override
  String get editProfileImageHint => 'Drag to reposition · Pinch to zoom';

  @override
  String get editProfileErrorSaveFailed => 'Could not save. Please try again.';

  @override
  String get editProfileErrorUsernameCheck => 'Failed to verify';

  @override
  String get editProfileErrorUsernameInUse => 'This username is already taken';

  @override
  String get editProfileErrorUsernameSaveFailed =>
      'Could not save username. Please try again.';

  @override
  String get editProfileErrorAvatarUpload => 'Failed to upload avatar.';

  @override
  String get editProfileErrorBannerUpload => 'Failed to upload banner.';

  @override
  String get editProfileErrorAvatarRemove => 'Failed to remove avatar.';

  @override
  String get editProfileErrorBannerRemove => 'Failed to remove banner.';

  @override
  String get startLivePermissionDenied =>
      'We need camera and microphone access to start.';

  @override
  String get startLiveNoCamera => 'No camera found on this device.';

  @override
  String startLiveCameraInitError(String error) {
    return 'Error initializing camera: $error';
  }

  @override
  String get startLiveCameraInitFailed => 'Failed to initialize camera.';

  @override
  String get startLiveThumbCaptured => 'Cover captured from camera ✨';

  @override
  String get startLiveThumbCaptureFailed => 'Could not capture the cover.';

  @override
  String get startLiveThumbUpdated => 'Cover updated.';

  @override
  String get startLiveThumbCaptureNow => 'Capture now';

  @override
  String get startLiveThumbCaptureNowSubtitle =>
      'Uses the current camera frame';

  @override
  String get startLiveThumbPickGallery => 'Choose from gallery';

  @override
  String get startLiveThumbRemove => 'Remove cover';

  @override
  String get startLiveRoomDataError => 'Could not get live data.';

  @override
  String get startLiveRetry => 'Try again';

  @override
  String get startLiveTitleHint => 'Tell us what your live is about...';

  @override
  String get startLiveCategoryLabel => 'Category';

  @override
  String get startLiveNotifyFollowers => 'Notify my followers';

  @override
  String get startLiveGoLive => 'GO LIVE';

  @override
  String get startLiveSuggestions => 'Suggestions';

  @override
  String get startLiveErrorTitleTooShort =>
      'The title must be at least 3 characters.';

  @override
  String get startLiveErrorCategoryRequired =>
      'Select a category for your live.';

  @override
  String get liveCategoryShopping => 'Shopping';

  @override
  String get liveCategoryGaming => 'Gaming';

  @override
  String get liveCategoryTalkShow => 'Talk Show';

  @override
  String get liveCategoryMusic => 'Music';

  @override
  String get liveCategoryEducation => 'Education';

  @override
  String get liveCategoryFitness => 'Fitness';

  @override
  String get liveCategoryCooking => 'Cooking';

  @override
  String get liveCategoryBeauty => 'Beauty';

  @override
  String get liveCategoryTech => 'Technology';

  @override
  String get liveCategorySports => 'Sports';

  @override
  String get liveCategoryEntertainment => 'Entertainment';

  @override
  String get liveCategoryOther => 'Other';

  @override
  String get liveVisibilityPublic => 'Public';

  @override
  String get liveVisibilityFollowers => 'Followers';

  @override
  String get liveVisibilityPrivate => 'Private';

  @override
  String get liveVisibilityPublicDesc => 'Anyone can join and discover';

  @override
  String get liveVisibilityFollowersDesc => 'Only your followers can join';

  @override
  String get liveVisibilityPrivateDesc => 'Only people with the link invited';

  @override
  String get warmupHeading => 'Warming up the crowd';

  @override
  String get warmupSubheading => 'Notifying your followers...';

  @override
  String warmupOpensInSeconds(int count, String plural) {
    return 'Live opens in $count second$plural';
  }

  @override
  String get warmupGoNow => 'Go live now';

  @override
  String get warmupCancel => 'Cancel warmup';

  @override
  String get vibeNetworkWifi => 'Wi-Fi';

  @override
  String get vibeNetworkMobile => '4G/5G';

  @override
  String get vibeNetworkEthernet => 'Ethernet';

  @override
  String get vibeNetworkNone => 'No network';

  @override
  String get vibeStatusGood => 'All set to go live';

  @override
  String get vibeStatusWarning => 'Works, but may be unstable';

  @override
  String get vibeStatusBad => 'Heads up before starting';

  @override
  String vibeNetworkLabel(String label) {
    return 'Network: $label';
  }

  @override
  String vibeBatteryLabel(int level) {
    return 'Battery: $level%';
  }

  @override
  String get shareLiveLoginNeeded => 'Log in to share';

  @override
  String get shareLiveLoadFollowersError => 'Could not load your followers.';

  @override
  String shareLiveSentToCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString people',
      one: '$countString person',
    );
    return 'Live sent to $_temp0 🎉';
  }

  @override
  String get shareLiveSendFailed => 'Failed to share the live';

  @override
  String get shareLiveTitle => 'Share live';

  @override
  String get shareLiveBadge => 'LIVE';

  @override
  String get shareLiveSearchHint => 'Search followers';

  @override
  String get shareLiveErrorGeneric => 'Error';

  @override
  String get shareLiveRetry => 'Try again';

  @override
  String get shareLiveEmptyFollowers => 'No followers found.';

  @override
  String get shareLiveDefaultUser => 'User';

  @override
  String get shareLiveNoteHint => 'Add a message (optional)…';

  @override
  String shareLiveSendTo(int count) {
    return 'Send to $count';
  }

  @override
  String get shareLiveSelectContacts => 'Select contacts';

  @override
  String get broadcasterPermissionDenied =>
      'We need camera and microphone access for you to go live.';

  @override
  String get broadcasterNoCamera => 'No camera found on this device.';

  @override
  String get broadcasterInitCameraFailed => 'Failed to initialize the camera.';

  @override
  String broadcasterInitCameraError(String error) {
    return 'Error initializing the camera: $error';
  }

  @override
  String broadcasterRoomUpdateFailed(String error) {
    return 'Could not update the live: $error';
  }

  @override
  String get broadcasterMissingStreamCreds =>
      'Could not start: RTMP URL or stream key missing.';

  @override
  String get broadcasterConnectedLive => 'Connected! You\'re live. 🔴';

  @override
  String broadcasterStreamStartError(String error) {
    return 'Error starting broadcast: $error';
  }

  @override
  String get broadcasterLiveResumed => 'Live resumed — you\'re back on air.';

  @override
  String get broadcasterLivePaused => 'Live paused (BRB).';

  @override
  String broadcasterPauseToggleError(String error) {
    return 'Error pausing/resuming: $error';
  }

  @override
  String get broadcasterDiscardTitle => 'Discard live?';

  @override
  String get broadcasterDiscardMessage =>
      'You created a live but haven\'t started broadcasting. Discard it?';

  @override
  String get broadcasterCancel => 'Cancel';

  @override
  String get broadcasterDiscard => 'Discard';

  @override
  String get broadcasterEndTitle => 'End live?';

  @override
  String get broadcasterEndMessage =>
      'Are you sure you want to end the broadcast? Your viewers will be disconnected.';

  @override
  String get broadcasterContinueLive => 'Stay live';

  @override
  String get broadcasterEnd => 'End';

  @override
  String get liveSummaryTitle => 'Live summary';

  @override
  String get liveSummaryDuration => 'Duration';

  @override
  String get liveSummaryPeakViewers => 'Peak viewers';

  @override
  String get liveSummaryTotalViewers => 'Unique viewers';

  @override
  String get liveSummaryGiftsValue => 'Gifts received';

  @override
  String get liveSummaryMysteryGifts => 'Mystery gifts revealed';

  @override
  String get liveSummaryDone => 'Done';

  @override
  String get liveSummaryUnavailable =>
      'Your live has ended. We couldn\'t load the full summary right now.';

  @override
  String get broadcasterMoreResumeLive => 'Resume live';

  @override
  String get broadcasterMorePauseBrb => 'Pause (BRB)';

  @override
  String get broadcasterMoreResumeSubtitle =>
      'Go back on air and continue broadcasting';

  @override
  String get broadcasterMorePauseSubtitle =>
      'Pause the broadcast without ending it';

  @override
  String get broadcasterMoreSwitchCamera => 'Switch camera';

  @override
  String get broadcasterMoreSwitchCameraSubtitle =>
      'Toggle between front and back';

  @override
  String get broadcasterMoreShareLive => 'Share live';

  @override
  String get broadcasterMoreShareLiveSubtitle =>
      'Send a live preview to your followers';

  @override
  String get broadcasterMoreEndLive => 'End live';

  @override
  String get broadcasterMoreEndLiveSubtitle =>
      'Ends the broadcast for everyone';

  @override
  String get broadcasterBadgePaused => 'PAUSED';

  @override
  String get broadcasterBadgeLive => 'LIVE';

  @override
  String get broadcasterTooltipResume => 'Resume';

  @override
  String get broadcasterTooltipPause => 'Pause';

  @override
  String get broadcasterTooltipMore => 'More';

  @override
  String get broadcasterTooltipEnd => 'End';

  @override
  String broadcasterViewerJoined(String name) {
    return '$name joined';
  }

  @override
  String get suggestTimeDawn => 'Late night';

  @override
  String get suggestTimeMorning => 'Good morning';

  @override
  String get suggestTimeAfternoon => 'Good afternoon';

  @override
  String get suggestTimeEvening => 'Good evening';

  @override
  String suggestModa1(String time) {
    return '$time fashion — what to wear?';
  }

  @override
  String get suggestModa2 => 'OOTD live';

  @override
  String get suggestModa3 => 'Online fitting room — help me choose';

  @override
  String suggestBeleza1(String time) {
    return '$time doing makeup live';
  }

  @override
  String get suggestBeleza2 => 'Skincare routine — together';

  @override
  String get suggestBeleza3 => 'New product review';

  @override
  String get suggestJogos1 => 'Let\'s play — who\'s in?';

  @override
  String suggestJogos2(String time) {
    return 'Rank up live • $time';
  }

  @override
  String get suggestJogos3 => 'Warmup before ranked';

  @override
  String suggestMusica1(String time) {
    return '$time music — taking requests';
  }

  @override
  String get suggestMusica2 => 'Playing live — come hang';

  @override
  String get suggestMusica3 => 'Playlist + chat';

  @override
  String get suggestEsportes1 => 'Commenting the game live';

  @override
  String suggestEsportes2(String time) {
    return '$time sports — chat with me';
  }

  @override
  String get suggestEsportes3 => 'Workout + chat';

  @override
  String suggestComida1(String time) {
    return '$time in the kitchen — cook with me';
  }

  @override
  String get suggestComida2 => 'Recipe live';

  @override
  String get suggestComida3 => 'Trying a new recipe';

  @override
  String suggestGeneric1(String time) {
    return '$time with the crew';
  }

  @override
  String get suggestGeneric2 => 'Come hang, let\'s chat';

  @override
  String get suggestGeneric3 => 'Open live — drop in';

  @override
  String get liveCommentsHint => 'Say something...';

  @override
  String get liveCommentsSending => '  Sending...';

  @override
  String giftsSent(String name) {
    return 'Sent $name!';
  }

  @override
  String get giftsTitle => 'Send a Gift';

  @override
  String get giftsEmpty => 'No gifts available';

  @override
  String get giftsSendButton => 'SEND';

  @override
  String giftsError(String error) {
    return 'Error loading gifts: $error';
  }

  @override
  String giftsCreditsLabel(int count) {
    return '$count Credits';
  }

  @override
  String giftsPriceLabel(int price) {
    return '$price pts';
  }

  @override
  String get liveFeedEmptyForYou => 'No lives in For You right now.';

  @override
  String get liveFeedEmptyAll => 'No active lives at the moment.';

  @override
  String get liveFeedEmptyHint => 'Check back later or try refreshing.';

  @override
  String get liveFeedRefresh => 'Refresh';

  @override
  String get liveFeedRetry => 'Retry';

  @override
  String liveFeedError(String error) {
    return 'Error: $error';
  }

  @override
  String get liveFeedCategoryForYou => 'For You';

  @override
  String get liveFeedCategoryAll => 'All Lives';

  @override
  String liveFeedShareMessage(String title, String url) {
    return 'Check out this live on Brawe: $title\n$url';
  }

  @override
  String get liveFeedBadgeLive => 'LIVE';

  @override
  String liveFeedBadgeLiveWithCount(int count) {
    return 'LIVE $count';
  }

  @override
  String get liveFeedGift => 'Gift';

  @override
  String get liveFeedShare => 'Share';

  @override
  String get livePlayerInputHint => 'Say something nice...';

  @override
  String get livePlayerTooltipRose => 'Send rose';

  @override
  String get livePlayerTooltipGifts => 'Gifts';

  @override
  String get livePlayerTooltipLike => 'Like';

  @override
  String get livePlayerTooltipSend => 'Send';

  @override
  String get livePlayerGiftSentVerb => ' sent ';

  @override
  String get livePlayerShareTitle => 'Share with followers';

  @override
  String get livePlayerShareSubtitle => 'Send this live in a conversation';

  @override
  String get livePlayerReportTitle => 'Report live';

  @override
  String get livePlayerReportSubtitle =>
      'Let our team know about something wrong';

  @override
  String get livePlayerReportSubmitted => 'Report registered. Thank you.';

  @override
  String get liveCurrentUser => 'You';

  @override
  String get commonFollow => 'FOLLOW';

  @override
  String get liveBadgeLive => 'LIVE';

  @override
  String get homeSectionLiveBattles => 'LIVE STREAM BATTLES';

  @override
  String get homeSectionTopStreamers => 'TOP STREAMERS';

  @override
  String get homeSectionCategories => 'CATEGORIES';

  @override
  String get homeSectionStreamCard => 'STREAM CARD';

  @override
  String get homeSectionLiveCommerce => 'LIVE COMMERCE SHOW';

  @override
  String get homeSectionRecentLives => 'Recent Lives';

  @override
  String get homeErrorLoadingStats => 'Error loading stats';

  @override
  String get homeErrorLoadingLives => 'Error loading lives';

  @override
  String get homeEmptyPastLives => 'No past lives found';

  @override
  String get homeEmptyStreamers => 'No streamers yet';

  @override
  String get homeBattleWatchBet => 'WATCH & BET';

  @override
  String get homeBattleLabel => 'PK battle';

  @override
  String get commonError => 'Error';

  @override
  String get videoTooltipRepostStory => 'Repost to Stories';

  @override
  String get liveBattleTapToWatch => 'Tap to watch live';

  @override
  String get liveBattleMysteryGift => 'Mystery Gift';

  @override
  String get livePeekWatchLive => 'Watch Live';

  @override
  String get productSoldOut => 'Sold out';

  @override
  String get productBuy => 'Buy';

  @override
  String productLowStock(int count) {
    return 'Only $count left';
  }

  @override
  String productSoldCount(int count) {
    return '$count sold';
  }

  @override
  String get emojiCatSmileys => 'Smileys';

  @override
  String get emojiCatGestures => 'Gestures';

  @override
  String get emojiCatHearts => 'Hearts';

  @override
  String get emojiCatAnimals => 'Animals';

  @override
  String get emojiCatFood => 'Food';

  @override
  String get emojiCatParty => 'Party';

  @override
  String get emojiCatObjects => 'Objects';

  @override
  String get battleVs => 'VS';

  @override
  String get battleTimer => 'Time remaining';

  @override
  String get battleSendGift => 'Send gift';

  @override
  String get battleSupport => 'Support';

  @override
  String get battleWinner => 'Winner';

  @override
  String get battleDraw => 'Draw';

  @override
  String get battleEnded => 'Battle ended';

  @override
  String get battleResultTitle => 'Battle result';

  @override
  String get battleResultShare => 'Share result';

  @override
  String get battleResultWatchAgain => 'Watch another battle';

  @override
  String battleScoreLabel(String score) {
    return '$score pts';
  }

  @override
  String get battleTopSupporters => 'Top supporters';

  @override
  String battleYouScore(String score) {
    return 'You: $score';
  }

  @override
  String battleRivalScore(String score) {
    return 'Rival: $score';
  }

  @override
  String battleCountdownStarting(int count) {
    return 'Starting in $count';
  }

  @override
  String battleInviteReceived(String name) {
    return '$name challenged you to a battle!';
  }

  @override
  String get battleAccept => 'Accept';

  @override
  String get battleDecline => 'Decline';

  @override
  String get battleLoading => 'Loading battle...';

  @override
  String get battleError => 'Error loading battle';

  @override
  String battleGiftReceived(String sender, String gift) {
    return '$sender sent $gift';
  }

  @override
  String get battleMomentum => 'ON FIRE';

  @override
  String get battleLeadChange => 'LEAD CHANGE!';

  @override
  String get battleFinalStretch => 'FINAL STRETCH';

  @override
  String get battleSendToWin => 'Send gifts to decide it!';

  @override
  String get battleMvp => 'MVP';

  @override
  String get sharedPostReactionApplied => 'Reaction sent ✨';

  @override
  String sharedPostMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String sharedPostHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String sharedPostDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get topUpTitle => 'Recharge coins';

  @override
  String get topUpSubtitle => 'Buy directly through your phone\'s store';

  @override
  String get topUpReasonGift => 'Not enough balance for this gift';

  @override
  String get topUpReasonBattle => 'Stay in the battle! Recharge now';

  @override
  String get topUpStoreDisclaimer =>
      'Secure payment via Play Store / App Store';

  @override
  String get earningsNoPurchasesHint =>
      'When you buy coins via App Store or Google Play, they\'ll show up here.';

  @override
  String get earningsNoGiftsHint =>
      'Creator Program diamonds come from gifts you receive during live streams.';

  @override
  String get creatorProgramTitle => 'Brawe Creator Network';

  @override
  String get creatorProgramSubtitle =>
      'Grow your audience. Build your community. Become part of Brawe.';

  @override
  String get creatorProgramDescription =>
      'Brawe Creator Network is the official program for creators who want to grow, gain visibility and build community inside Brawe.';

  @override
  String get creatorActionApplyNow => 'Apply Now';

  @override
  String get creatorActionViewLevels => 'View Creator Levels';

  @override
  String get creatorActionCheckStatus => 'Check Application Status';

  @override
  String get creatorBenefitsHeader => 'What you get';

  @override
  String get creatorBenefit1 => 'Get discovered by new audiences';

  @override
  String get creatorBenefit2 => 'Build your creator identity';

  @override
  String get creatorBenefit3 => 'Unlock official creator badges';

  @override
  String get creatorBenefit4 => 'Grow through lives and content';

  @override
  String get creatorBenefit5 => 'Join a premium creator community';

  @override
  String creatorTotalCreators(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n creators in the network',
      one: '1 creator in the network',
    );
    return '$_temp0';
  }

  @override
  String get creatorLevelsTitle => 'Creator Levels';

  @override
  String get creatorLevelsSubtitle =>
      'Each level represents a moment in your journey.';

  @override
  String get creatorTierRisingTitle => 'Rising Creator';

  @override
  String get creatorTierRisingBody =>
      'For creators who are growing and ready to be discovered.';

  @override
  String get creatorTierFeaturedTitle => 'Featured Creator';

  @override
  String get creatorTierFeaturedBody =>
      'For active creators with strong content and community potential.';

  @override
  String get creatorTierLiveTitle => 'Live Creator';

  @override
  String get creatorTierLiveBody =>
      'For streamers, hosts and creators focused on live content.';

  @override
  String get creatorTierAmbassadorTitle => 'Ambassador';

  @override
  String get creatorTierAmbassadorBody =>
      'For recognized creators who represent the Brawe vision.';

  @override
  String get creatorTierFoundingTitle => 'Founding Creator';

  @override
  String get creatorTierFoundingBody =>
      'For selected creators helping shape the future of Brawe.';

  @override
  String get creatorTierApplyCta => 'Apply as Creator';

  @override
  String get creatorFormTitle => 'Apply to Brawe Creator Network';

  @override
  String get creatorFormSubtitle => 'Tell us more about your creator journey.';

  @override
  String get creatorFormDescription =>
      'We review every application carefully to understand your content, goals and potential inside Brawe.';

  @override
  String get creatorFormSectionIdentity => 'Identity';

  @override
  String get creatorFormSectionContent => 'Content';

  @override
  String get creatorFormSectionSocial => 'Social media';

  @override
  String get creatorFormSectionAbout => 'About you';

  @override
  String get creatorFormFullName => 'Full name';

  @override
  String get creatorFormUsername => 'Username';

  @override
  String get creatorFormEmail => 'Email address';

  @override
  String get creatorFormPhone => 'Phone';

  @override
  String get creatorFormCountry => 'Country';

  @override
  String get creatorFormCity => 'City';

  @override
  String get creatorFormLanguage => 'Main language';

  @override
  String get creatorFormNiche => 'Content niche';

  @override
  String get creatorFormNichePlaceholder =>
      'Example: lifestyle, music, games, education...';

  @override
  String get creatorFormCategory => 'Creator category';

  @override
  String get creatorFormSocialLinks => 'Social links';

  @override
  String get creatorFormSocialPlaceholder =>
      'Paste your Instagram, TikTok, YouTube...';

  @override
  String get creatorFormFollowers => 'Approximate followers';

  @override
  String get creatorFormDoesLive => 'Do you create live content?';

  @override
  String get creatorFormBio => 'Tell us about you';

  @override
  String get creatorFormBioPlaceholder => 'Who are you as a creator?';

  @override
  String get creatorFormMotivation => 'Your motivation';

  @override
  String get creatorFormMotivationPlaceholder =>
      'Why do you want to grow with Brawe?';

  @override
  String get creatorFormGoals => 'Your goals';

  @override
  String get creatorFormGoalsPlaceholder =>
      'What do you want to achieve as a creator?';

  @override
  String get creatorFormPortfolio => 'Portfolio (optional)';

  @override
  String get creatorFormSubmit => 'Submit Application';

  @override
  String get creatorFormSaveDraft => 'Save Draft';

  @override
  String get creatorFormCancel => 'Cancel';

  @override
  String get creatorFormTermsPrefix => 'I have read and accept the ';

  @override
  String get creatorFormTermsLink => 'Brawe Creator Network Terms';

  @override
  String get creatorFormTermsSuffix => '.';

  @override
  String get creatorFormTermsMustAccept =>
      'You must accept the Terms to apply.';

  @override
  String get creatorFormTermsOpen => 'Open Terms';

  @override
  String get creatorFormTermsClose => 'Close';

  @override
  String creatorFormTermsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get creatorFormValidationRequired => 'Required field';

  @override
  String get creatorFormValidationEmail => 'Invalid email';

  @override
  String get creatorFormValidationSocial => 'Add at least one social link';

  @override
  String get creatorFormSubmitting => 'Submitting your application...';

  @override
  String get creatorFormSuccess => 'Application submitted successfully.';

  @override
  String get creatorFormError =>
      'We couldn\'t submit your application. Please try again.';

  @override
  String get creatorFormAlreadyExists =>
      'You already have an active application.';

  @override
  String get creatorSubmittedTitle => 'Application submitted';

  @override
  String get creatorSubmittedBody =>
      'Thank you for applying to Brawe Creator Network. Our team will review your profile and notify you when there is an update.';

  @override
  String get creatorSubmittedStep1 => 'Your application is now pending review.';

  @override
  String get creatorSubmittedStep2 =>
      'We may ask for more information if needed.';

  @override
  String get creatorSubmittedStep3 => 'You can track your status anytime.';

  @override
  String get creatorSubmittedTrack => 'Track Application';

  @override
  String get creatorSubmittedHome => 'Back to Home';

  @override
  String get creatorStatusPendingTitle => 'Application received';

  @override
  String get creatorStatusPendingBody =>
      'Your application has been received and is waiting for review.';

  @override
  String get creatorStatusAnalysisTitle => 'Under analysis';

  @override
  String get creatorStatusAnalysisBody =>
      'Our team is reviewing your creator profile.';

  @override
  String get creatorStatusApprovedTitle => 'You\'re approved!';

  @override
  String get creatorStatusApprovedBody =>
      'Congratulations! You are now part of Brawe Creator Network.';

  @override
  String get creatorStatusRejectedTitle => 'Application not approved';

  @override
  String get creatorStatusRejectedBody =>
      'Your application was not approved at this moment. You can improve your profile and try again later.';

  @override
  String get creatorStatusWaitlistTitle => 'You\'re on the waitlist';

  @override
  String get creatorStatusWaitlistBody =>
      'Your profile has potential, and we may invite you soon.';

  @override
  String get creatorStatusNeedsInfoTitle => 'We need more information';

  @override
  String get creatorStatusNeedsInfoBody =>
      'Please update your application with the requested details.';

  @override
  String get creatorStatusInvitedAmbassadorTitle => 'Ambassador invitation';

  @override
  String get creatorStatusInvitedAmbassadorBody =>
      'You\'ve been invited to join Brawe Ambassadors.';

  @override
  String get creatorStatusInvitedFoundingTitle => 'Founding Creator invitation';

  @override
  String get creatorStatusInvitedFoundingBody =>
      'You\'ve been invited to become a Brawe Founding Creator.';

  @override
  String get creatorStatusUpdateApplication => 'Update Application';

  @override
  String get creatorStatusContinue => 'Continue';

  @override
  String get creatorStatusStartOnboarding => 'Start Onboarding';

  @override
  String get creatorOnboardingTitle => 'Welcome to Brawe Creator Network';

  @override
  String get creatorOnboardingSubtitle =>
      'Let\'s set up your creator presence and help people discover your content.';

  @override
  String get creatorOnboardingStart => 'Start setup';

  @override
  String get creatorOnboardingSkip => 'Skip for now';

  @override
  String creatorOnboardingProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get creatorProfileTitle => 'Creator Profile';

  @override
  String get creatorProfileSubtitle =>
      'Customize how people see you as a creator.';

  @override
  String get creatorProfileFieldDisplayName => 'Creator display name';

  @override
  String get creatorProfileFieldBio => 'Creator bio';

  @override
  String get creatorProfileFieldCategory => 'Content category';

  @override
  String get creatorProfileFieldSocial => 'Public social links';

  @override
  String get creatorProfileFieldBadgeVisibility => 'Show badge on profile';

  @override
  String get creatorProfileSave => 'Save Changes';

  @override
  String get creatorProfilePreview => 'Preview Profile';

  @override
  String get creatorProfileSaved => 'Creator profile updated.';

  @override
  String get creatorProfileSaveError => 'Could not update creator profile.';

  @override
  String get creatorBadgeScreenTitle => 'Your Creator Badge';

  @override
  String get creatorBadgeScreenSubtitle =>
      'Your badge helps people recognize your role inside Brawe Creator Network.';

  @override
  String get creatorBadgeLocked => 'Locked';

  @override
  String get creatorBadgeUnlocked => 'Unlocked';

  @override
  String get creatorBadgeViewBenefits => 'View Benefits';

  @override
  String get creatorBadgeBack => 'Back';

  @override
  String get creatorDashboardTitle => 'Creator Dashboard';

  @override
  String get creatorDashboardSubtitle =>
      'Track your growth and manage your creator presence.';

  @override
  String get creatorDashboardCardViews => 'Profile views';

  @override
  String get creatorDashboardCardFollowers => 'Followers growth';

  @override
  String get creatorDashboardCardReach => 'Content reach';

  @override
  String get creatorDashboardCardLives => 'Live activity';

  @override
  String get creatorDashboardCardStatus => 'Creator status';

  @override
  String get creatorDashboardQuickCreatePost => 'Create Post';

  @override
  String get creatorDashboardQuickGoLive => 'Go Live';

  @override
  String get creatorDashboardQuickEditProfile => 'Edit Creator Profile';

  @override
  String get creatorDashboardQuickViewBadge => 'View Badge';

  @override
  String get creatorDashboardQuickInsights => 'Check Insights';

  @override
  String get adminCreatorAppsTitle => 'Creator Applications';

  @override
  String get adminCreatorAppsFilterAll => 'All';

  @override
  String get adminCreatorAppsFilterPending => 'Pending';

  @override
  String get adminCreatorAppsFilterAnalysis => 'Under Analysis';

  @override
  String get adminCreatorAppsFilterApproved => 'Approved';

  @override
  String get adminCreatorAppsFilterRejected => 'Rejected';

  @override
  String get adminCreatorAppsFilterWaitlist => 'Waitlist';

  @override
  String get adminCreatorAppsFilterNeedsInfo => 'Needs Info';

  @override
  String get adminCreatorAppsReview => 'Review';

  @override
  String get adminCreatorAppsFilter => 'Filters';

  @override
  String get adminCreatorAppsExport => 'Export';

  @override
  String get adminCreatorAppsSearchHint => 'Search name, username or email';

  @override
  String get adminCreatorAppsEmpty => 'No applications found.';

  @override
  String get adminCreatorAppsLoadError => 'Error loading applications.';

  @override
  String get adminCreatorAppDetailTitle => 'Application Review';

  @override
  String get adminCreatorSectionInfo => 'Creator Information';

  @override
  String get adminCreatorSectionSocial => 'Social Links';

  @override
  String get adminCreatorSectionNiche => 'Content Niche';

  @override
  String get adminCreatorSectionMotivation => 'Motivation';

  @override
  String get adminCreatorSectionGoals => 'Goals';

  @override
  String get adminCreatorSectionNotes => 'Internal Notes';

  @override
  String get adminCreatorSectionSuggestedTier => 'Suggested Tier';

  @override
  String get adminCreatorActionApprove => 'Approve';

  @override
  String get adminCreatorActionReject => 'Reject';

  @override
  String get adminCreatorActionWaitlist => 'Move to Waitlist';

  @override
  String get adminCreatorActionRequestInfo => 'Request More Info';

  @override
  String get adminCreatorActionInviteAmbassador => 'Invite as Ambassador';

  @override
  String get adminCreatorActionInviteFounding => 'Invite as Founding Creator';

  @override
  String get adminCreatorActionSaveNotes => 'Save Notes';

  @override
  String get adminCreatorConfirmApprove =>
      'Are you sure you want to approve this creator?';

  @override
  String get adminCreatorConfirmReject =>
      'Are you sure you want to reject this application?';

  @override
  String get adminCreatorConfirmRequestInfo =>
      'Tell the creator what information is missing.';

  @override
  String get adminCreatorReviewSuccess => 'Decision recorded.';

  @override
  String get adminCreatorReviewError => 'Could not record the decision.';

  @override
  String get adminCreatorsTitle => 'Creators Management';

  @override
  String get adminCreatorsFilterAll => 'All Creators';

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
  String get adminCreatorsActionEdit => 'Edit Creator';

  @override
  String get adminCreatorsActionChangeBadge => 'Change Badge';

  @override
  String get adminCreatorsActionFeature => 'Feature Creator';

  @override
  String get adminCreatorsActionDisable => 'Disable Creator';

  @override
  String get creatorTimelineTitle => 'Timeline';

  @override
  String get creatorTimelineSubmitted => 'Application submitted';

  @override
  String get creatorTimelineUnderReview => 'Under review';

  @override
  String get creatorTimelineFinalDecision => 'Final decision';

  @override
  String get creatorTimelineResult => 'Result';

  @override
  String get creatorYourApplication => 'Your application';

  @override
  String get creatorInfoName => 'Name';

  @override
  String get creatorInfoUsername => 'Username';

  @override
  String get creatorInfoCountry => 'Country';

  @override
  String get creatorInfoNiche => 'Niche';

  @override
  String get creatorInfoRequestedTier => 'Requested tier';

  @override
  String get creatorInfoFollowers => 'Followers';

  @override
  String get creatorInfoDoesLive => 'Goes live';

  @override
  String get creatorQuickShortcuts => 'Quick shortcuts';

  @override
  String get creatorBadgeActive => 'ACTIVE';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonRetry => 'Try again';

  @override
  String get editProfileAccountTypeSection => 'ACCOUNT TYPE';

  @override
  String get editProfileAccountTypeCreator => 'Creator';

  @override
  String get editProfileAccountTypeMusician => 'Musician';

  @override
  String get editProfileAccountTypeBusiness => 'Business';

  @override
  String get editProfileMusicianBannerHint =>
      'Create your artist profile on Brawe Sounds and appear in the catalog.';

  @override
  String get editProfileMusicianArtistName => 'Artist name';

  @override
  String get editProfileMusicianArtistNameHint =>
      'How you appear on Brawe Sounds';

  @override
  String get editProfileMusicianCity => 'City';

  @override
  String get editProfileMusicianCityHint => 'e.g. New York, NY';

  @override
  String get editProfileMusicianSpotify => 'Spotify';

  @override
  String get editProfileMusicianAppleMusic => 'Apple Music';

  @override
  String get editProfileMusicianGenres => 'GENRES';

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
  String get soundsGenreElectro => 'Electronic';

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
      other: '$count tracks',
      one: '1 track',
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
  String get soundsSubtitle => 'Discover amazing tracks';

  @override
  String get soundsTabTrending => 'Trending';

  @override
  String get soundsTabCatalog => 'Catalog';

  @override
  String get soundsSearch => 'Search tracks or artists...';

  @override
  String get soundsGenreAll => 'All';

  @override
  String get soundsEmptyTrending => 'No trending tracks yet';

  @override
  String get soundsEmptyCatalog => 'No tracks found';

  @override
  String soundsEmptySearch(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get soundsLoadMore => 'Load more';

  @override
  String soundsUsedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'used $count times',
      one: 'used 1 time',
    );
    return '$_temp0';
  }

  @override
  String get soundsSaved => 'Saved';

  @override
  String get soundsSave => 'Save';

  @override
  String get soundsUse => 'Use';

  @override
  String get soundsPlayerLoading => 'Loading...';

  @override
  String get soundsPlayerError => 'Failed to load audio';

  @override
  String get navSounds => 'Sounds';

  @override
  String get createSoundsTitle => 'Sounds';

  @override
  String get createSoundsSubtitle => 'Add an original track to your post';

  @override
  String postSoundLabel(String title) {
    return 'Sound: $title';
  }

  @override
  String get postSoundRemove => 'Remove sound';

  @override
  String get contentSoundOriginalAudio => 'Original audio';

  @override
  String get contentSoundUseThis => 'Use this sound';

  @override
  String get contentSoundUnavailable => 'Sound unavailable';

  @override
  String get contentSoundView => 'View sound';

  @override
  String get contentSoundNowPlaying => 'Now playing';

  @override
  String contentSoundByArtist(String title, String artist) {
    return '$title · $artist';
  }

  @override
  String get soundTrimTitle => 'Trim music';

  @override
  String get soundTrimSave => 'Done';

  @override
  String get soundTrimCancel => 'Cancel';

  @override
  String get soundTrimHint => 'Drag the handles to choose the music segment';

  @override
  String soundTrimMaxDuration(int seconds) {
    return 'Maximum ${seconds}s for this content';
  }

  @override
  String soundTrimSelectedDuration(int seconds) {
    return '${seconds}s selected';
  }

  @override
  String get soundTrimError => 'Could not process the selected segment.';

  @override
  String get soundVolumeLabel => 'Music volume';

  @override
  String get originalAudioVolumeLabel => 'Original audio volume';

  @override
  String get analyticsViewersTitle => 'Audience';

  @override
  String get analyticsViewersTotalViewers => 'Total viewers';

  @override
  String get analyticsViewersAvgPerLive => 'Avg/live';

  @override
  String get analyticsViewersChartTitle => 'Views per day';

  @override
  String get analyticsViewersLegendViewers => 'Viewers';

  @override
  String get analyticsViewersLegendPeak => 'Peak';

  @override
  String get analyticsViewersBestDays => 'Best days';

  @override
  String get analyticsViewersNoData => 'No data';

  @override
  String get analyticsViewersUnit => ' viewers';

  @override
  String get analyticsFollowersTitle => 'Followers';

  @override
  String get analyticsFollowersCount => 'Followers';

  @override
  String get analyticsFollowersFollowing => 'Following';

  @override
  String get analyticsFollowersTrendTitle => 'Engagement trend';

  @override
  String get analyticsFollowersTrendSubtitle =>
      'Live audience — directly correlated with growth';

  @override
  String get analyticsFollowersLegendEngagement => 'Engagement';

  @override
  String get analyticsFollowersSummaryTitle => 'Account summary';

  @override
  String get analyticsFollowersSummaryFollowers => 'Followers';

  @override
  String get analyticsFollowersSummaryFollowing => 'Following';

  @override
  String get analyticsFollowersSummaryLives => 'Lives done';

  @override
  String get analyticsFollowersSummaryRatio => 'Followers/live ratio';

  @override
  String get analyticsFollowersTipsTitle => 'Growth tips';

  @override
  String get analyticsFollowersTip1Title => 'Go live regularly';

  @override
  String get analyticsFollowersTip1Subtitle =>
      'Consistency increases followers by +40%';

  @override
  String get analyticsFollowersTip2Title => 'Engage with your audience';

  @override
  String get analyticsFollowersTip2Subtitle =>
      'Replying to comments increases retention';

  @override
  String get analyticsFollowersTip3Title => 'Share your content';

  @override
  String get analyticsFollowersTip3Subtitle =>
      'Stories and posts increase reach';

  @override
  String get analyticsLivesTitle => 'Live History';

  @override
  String get analyticsLivesErrorLoad => 'Error loading lives';

  @override
  String get analyticsLivesRetry => 'Try again';

  @override
  String get analyticsLivesKpiTotal => 'Lives';

  @override
  String get analyticsLivesKpiAvgViewers => 'Avg viewers';

  @override
  String get analyticsLivesKpiGifts => 'Gifts (USDT)';

  @override
  String analyticsLivesDuration(String min) {
    return '$min min';
  }

  @override
  String get analyticsLivesNoTitle => 'Live without title';

  @override
  String get analyticsLivesMetricViewers => 'viewers';

  @override
  String get analyticsLivesMetricPeak => 'peak';

  @override
  String get analyticsLivesMetricUsdt => 'USDT';

  @override
  String get analyticsLivesReplayLabel => 'Replay';

  @override
  String get analyticsLivesReplayExpired => 'Replay not available';

  @override
  String get analyticsLivesReplayExpiredSub =>
      'Video may have expired (>30 days)';

  @override
  String get analyticsLivesEmptyTitle => 'No lives yet';

  @override
  String get analyticsLivesEmptySubtitle => 'Go live and see your metrics here';

  @override
  String get analyticsLivesMonthsShort =>
      'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  String get analyticsReachTitle => 'Reach & Monetization';

  @override
  String get analyticsReachKpiGifts => 'Gifts received';

  @override
  String get analyticsReachKpiEarnings => 'Earnings (USDT)';

  @override
  String get analyticsReachEarningsChartTitle => 'Earnings per day';

  @override
  String get analyticsReachLegendEarnings => 'Earnings USDT';

  @override
  String get analyticsReachLegendFee => 'Platform fee';

  @override
  String get analyticsReachTopGiftsTitle => 'Top gifts received';

  @override
  String get analyticsReachNoGifts => 'No gifts received yet';

  @override
  String get analyticsReachMonetizationTitle => 'Total monetization';

  @override
  String get analyticsReachTotalEarned => 'Total earned';

  @override
  String get analyticsReachTotalGifts => 'Total gifts';

  @override
  String get analyticsReachEarningsPerLive => 'Earnings/live';

  @override
  String get analyticsDashboardAvgViewers => 'avg/live';

  @override
  String get analyticsDashboardSeeGrowth => 'See growth';

  @override
  String get analyticsDashboardGifts => 'gifts';

  @override
  String analyticsDashboardMinAvg(String min) {
    return '$min min avg.';
  }

  @override
  String shopVitrineTitle(String name) {
    return '$name\'s storefront';
  }

  @override
  String get shopVitrineSearchTooltip => 'Search storefront';

  @override
  String get shopVitrineFilterTooltip => 'Sort products';

  @override
  String get shopVitrineViewModeTooltip => 'Change view';

  @override
  String get shopVitrineSortTitle => 'Sort by';

  @override
  String get shopVitrineSortCreatorChoice => 'Creator\'s choice';

  @override
  String get shopVitrineSortBestSelling => 'Best selling';

  @override
  String get shopVitrineSortNewest => 'Newest';

  @override
  String get shopVitrineSortPriceAsc => 'Price: low to high';

  @override
  String get shopVitrineSortPriceDesc => 'Price: high to low';

  @override
  String shopVitrineSoldOnline(String count) {
    return '$count sold online';
  }

  @override
  String get shopVitrineFreeShipping => 'Free shipping';

  @override
  String get shopProductPageTitle => 'Product';

  @override
  String get shopProductPrice => 'Price';

  @override
  String get shopProductOriginalPrice => 'Original price';

  @override
  String get shopProductDiscount => 'Discount';

  @override
  String get shopProductAddToCart => 'Add to cart';

  @override
  String get shopProductBuyNow => 'Buy now';

  @override
  String get shopProductDescription => 'Description';

  @override
  String get shopProductStore => 'Store';

  @override
  String get shopProductViewStore => 'View store';

  @override
  String get shopProductQuantity => 'Quantity';

  @override
  String get shopProductRating => 'Rating';

  @override
  String get shopProductReviews => 'reviews';

  @override
  String get shopProductSold => 'sold';

  @override
  String get shopProductOutOfStock => 'Out of stock';

  @override
  String get shopProductNotFound => 'Product not found.';

  @override
  String get shopProductError => 'Failed to load product.';

  @override
  String get shopProductAddedToCart => 'Product added to cart ✓';

  @override
  String get shopProductAddToCartError => 'Failed to add to cart.';

  @override
  String get shopProductCartTooltip => 'Cart';

  @override
  String get shopProductSearchTooltip => 'Search products';

  @override
  String get shopProductShareTooltip => 'Share';

  @override
  String get shopProductMoreTooltip => 'More options';

  @override
  String get shopProductShareFail => 'Couldn\'t share this product.';

  @override
  String get shopProductLinkCopied => 'Product link copied!';

  @override
  String get shopProductOptionShare => 'Share product';

  @override
  String get shopProductOptionCopyLink => 'Copy link';

  @override
  String get shopProductOptionReport => 'Report product';

  @override
  String get shopProductReportQuestion => 'Why are you reporting this product?';

  @override
  String get shopProductReportSent =>
      'Report sent. Thanks for helping keep Brawe safe.';

  @override
  String get shopProductReportError =>
      'Couldn\'t send the report. Please try again.';

  @override
  String get shopProductFooterStore => 'Store';

  @override
  String get shopProductFooterChat => 'Chat';

  @override
  String get shopProductChatComingSoon => 'Store chat coming soon.';

  @override
  String get shopProductTabOverview => 'Overview';

  @override
  String get shopProductTabReviews => 'Reviews';

  @override
  String get shopProductTabDescription => 'Description';

  @override
  String get shopProductTabRecommendations => 'Recommendations';

  @override
  String get shopProductReviewsComingSoon => 'Product reviews coming soon.';

  @override
  String get shopProductRecommendationsComingSoon =>
      'Related product recommendations coming soon.';

  @override
  String get shopCartTitle => 'Cart';

  @override
  String get shopCartClear => 'Clear cart';

  @override
  String get shopCartClearConfirmTitle => 'Clear cart?';

  @override
  String get shopCartClearConfirmBody =>
      'All items will be removed from your cart.';

  @override
  String get shopCartEmptyTitle => 'Your cart is empty';

  @override
  String get shopCartEmptyBody =>
      'Browse the showcase and find amazing products.';

  @override
  String get shopCartViewShowcase => 'View showcase';

  @override
  String get shopCartError => 'Failed to load your cart.';

  @override
  String get shopCartRemoveItem => 'Remove item';

  @override
  String get shopCartSubtotal => 'Subtotal';

  @override
  String get shopCartTax => 'Tax';

  @override
  String get shopCartShipping => 'Shipping';

  @override
  String get shopCartDiscount => 'Discount';

  @override
  String get shopCartTotal => 'Total';

  @override
  String get shopCartContinueToCheckout => 'Continue to checkout';

  @override
  String get shopCartUpdateError => 'Failed to update item.';

  @override
  String get shopCartRemoveError => 'Failed to remove item.';

  @override
  String get shopCartClearError => 'Failed to clear cart.';

  @override
  String get shopCheckoutTitle => 'Checkout';

  @override
  String get shopCheckoutAddressSection => 'Shipping address';

  @override
  String get shopCheckoutAddressEmpty =>
      'You don\'t have any saved addresses yet.';

  @override
  String get shopCheckoutAddNewAddress => 'Use another address';

  @override
  String get shopCheckoutAddressLabel => 'Address name (e.g., Home, Work)';

  @override
  String get shopCheckoutAddressStreet => 'Street';

  @override
  String get shopCheckoutAddressNumber => 'Number';

  @override
  String get shopCheckoutAddressComplement => 'Complement (optional)';

  @override
  String get shopCheckoutAddressNeighborhood => 'Neighborhood';

  @override
  String get shopCheckoutAddressCity => 'City';

  @override
  String get shopCheckoutAddressState => 'State';

  @override
  String get shopCheckoutAddressPostalCode => 'Postal code';

  @override
  String get shopCheckoutAddressSave => 'Save address';

  @override
  String get shopCheckoutAddressSaved => 'Address saved ✓';

  @override
  String get shopCheckoutAddressSaveError => 'Failed to save address.';

  @override
  String get shopCheckoutAddressRequired => 'Select or add a shipping address.';

  @override
  String get shopCheckoutCustomerSection => 'Customer details';

  @override
  String get shopCheckoutCustomerName => 'Full name';

  @override
  String get shopCheckoutCustomerEmail => 'Email';

  @override
  String get shopCheckoutCustomerPhone => 'Phone (optional)';

  @override
  String get shopCheckoutRecipientSection => 'Recipient (for tax invoice)';

  @override
  String get shopCheckoutRecipientHint =>
      'The store needs this info to issue the invoice for your order.';

  @override
  String get shopCheckoutRecipientName => 'Recipient\'s full name';

  @override
  String get shopCheckoutDocumentType => 'Type';

  @override
  String get shopCheckoutDocumentRequired =>
      'Tax ID is required to issue the invoice.';

  @override
  String get shopCheckoutCpfInvalid => 'CPF must have 11 digits.';

  @override
  String get shopCheckoutCnpjInvalid => 'CNPJ must have 14 digits.';

  @override
  String get shopCheckoutNameRequired => 'Enter your full name.';

  @override
  String get shopCheckoutEmailRequired => 'Enter your email.';

  @override
  String get shopCheckoutEmailInvalid => 'Enter a valid email address.';

  @override
  String get shopCheckoutShippingSection => 'Shipping method';

  @override
  String get shopCheckoutShippingStandard => 'Standard';

  @override
  String get shopCheckoutShippingExpress => 'Express';

  @override
  String get shopCheckoutPaymentSection => 'Payment method';

  @override
  String get shopCheckoutPaymentPix => 'PIX';

  @override
  String get shopCheckoutPaymentCard => 'Card';

  @override
  String get shopCheckoutPaymentCrypto => 'Crypto';

  @override
  String get shopCheckoutSummarySection => 'Order summary';

  @override
  String get shopCheckoutSubtotal => 'Subtotal';

  @override
  String get shopCheckoutTotal => 'Total';

  @override
  String get shopCheckoutConfirmOrder => 'Confirm order';

  @override
  String get shopCheckoutError =>
      'Failed to complete your order. Please try again.';

  @override
  String get shopCheckoutDiscount => 'Discount';

  @override
  String get shopCheckoutFreeShipping => 'Free';

  @override
  String get shopCheckoutAddNote => 'Add note';

  @override
  String shopCheckoutTotalItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return 'Total ($count $_temp0)';
  }

  @override
  String get shopCheckoutTermsPrefix =>
      'By placing your order, you agree to Brawe\'s ';

  @override
  String get shopCheckoutTermsLink => 'Terms of Use';

  @override
  String get shopCheckoutTermsAnd => ' and ';

  @override
  String get shopCheckoutPrivacyLink => 'Privacy Policy';

  @override
  String get shopCheckoutTermsSuffix => '.';

  @override
  String get shopPaymentTitle => 'Payment';

  @override
  String shopPaymentOrderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String get shopPaymentTotal => 'Total';

  @override
  String get shopPaymentPixTitle => 'Pay with PIX';

  @override
  String get shopPaymentPixInstructions =>
      'Scan the QR code in your bank app to complete the payment.';

  @override
  String get shopPaymentAlreadyPaid => 'I already paid';

  @override
  String get shopPaymentCardTitle => 'Card payment';

  @override
  String get shopPaymentCardComingSoon => 'Card integration coming soon.';

  @override
  String get shopPaymentCryptoTitle => 'Pay with crypto';

  @override
  String get shopPaymentCryptoComingSoon => 'Wallet address coming soon.';

  @override
  String get shopPaymentViewOrders => 'View my orders';

  @override
  String get shopPaymentStatusPending => 'Awaiting payment';

  @override
  String get shopPaymentStatusPaid => 'Payment confirmed ✓';

  @override
  String get shopPaymentStatusFailed => 'Payment failed';

  @override
  String get shopPaymentError => 'Failed to check payment status.';

  @override
  String get shopStoreProductsSection => 'Products';

  @override
  String get shopStoreEmptyProducts =>
      'This store doesn\'t have any products yet.';

  @override
  String get shopStoreProductsError => 'Failed to load products.';

  @override
  String get shopStoreError => 'Failed to load store.';

  @override
  String get shopStoreNotFound => 'Store not found.';

  @override
  String get shopStorePremiumBadge => 'Premium';

  @override
  String get shopStoreBravePassBadge => 'Brawe Pass';

  @override
  String shopStoreRatingCount(String count) {
    return '$count reviews';
  }

  @override
  String get shopStoreReadMore => 'Read more';

  @override
  String get shopStoreReadLess => 'Read less';

  @override
  String get shopStoreChatCta => 'Message the store';

  @override
  String get shopStoreChatUnavailable =>
      'This store can\'t receive messages yet.';

  @override
  String shopStoreChatError(String error) {
    return 'Couldn\'t open the chat: $error';
  }

  @override
  String get profileTooltipFindFriends => 'Find friends';

  @override
  String get findFriendsTitle => 'Find friends';

  @override
  String get findFriendsMyQrCode => 'My QR code';

  @override
  String get findFriendsQrHint =>
      'Others can scan this code to view your profile or log in instantly';

  @override
  String get findFriendsScanButton => 'Scan code';

  @override
  String get findFriendsSuggestionsTitle => 'Suggested for you';

  @override
  String get findFriendsSuggestionsEmpty => 'No suggestions right now';

  @override
  String get findFriendsFollowButton => 'Follow';

  @override
  String get findFriendsFollowingButton => 'Following';

  @override
  String get qrScannerTitle => 'Scan QR code';

  @override
  String get qrScannerHint => 'Point your camera at a Brawe QR code';

  @override
  String get qrScannerCameraPermissionDenied =>
      'Allow camera access to scan QR codes.';

  @override
  String get qrScannerInvalidCode => 'This QR code isn\'t valid.';

  @override
  String get qrScannerLoginApproved => 'Login approved successfully!';

  @override
  String get qrScannerLoginConfirmTitle => 'Confirm login';

  @override
  String get qrScannerLoginConfirmBody =>
      'Approve login on another device using this account?';

  @override
  String qrScannerLoginError(String error) {
    return 'Couldn\'t approve login: $error';
  }

  @override
  String get actionApprove => 'Approve';

  @override
  String get questsRewardCollected => 'Reward collected!';

  @override
  String questsXpReceived(int xp) {
    return '$xp XP received';
  }

  @override
  String questsCoinsReceived(int coins) {
    return '$coins coins received';
  }

  @override
  String get questsLevelUp => 'Level up!';

  @override
  String get questsFailedToClaim => 'Failed to claim the reward';

  @override
  String get questsAlreadyClaimed => 'Reward already claimed';

  @override
  String get shareSheetTitle => 'Share';

  @override
  String get shareSentBadge => 'Sent';

  @override
  String get shareRetry => 'Retry';

  @override
  String get shareActionStories => 'Stories';

  @override
  String get shareActionRepost => 'Repost';

  @override
  String get shareActionCopyLink => 'Copy link';

  @override
  String get shareActionMore => 'More';

  @override
  String get composerToolText => 'Text';

  @override
  String get composerToolMusic => 'Music';

  @override
  String get composerToolTrim => 'Trim';

  @override
  String get composerToolSave => 'Save';

  @override
  String get composerToolFrame => 'Frame';

  @override
  String get composerToolResetZoom => 'Reset zoom';

  @override
  String get composerToolBackground => 'Background';

  @override
  String get composerDone => 'Done';

  @override
  String get composerClose => 'Close';

  @override
  String get composerTextAlignTooltip => 'Alignment';

  @override
  String get composerTextBackgroundTooltip => 'Text background';

  @override
  String get composerFontClassic => 'Classic';

  @override
  String get composerFontModern => 'Modern';

  @override
  String get composerFontSerif => 'Serif';

  @override
  String get composerFontTypewriter => 'Typewriter';

  @override
  String get composerFontNeon => 'Neon';

  @override
  String get composerDiscardTitle => 'Discard story?';

  @override
  String get composerDiscardMessage => 'Your edits will be lost.';

  @override
  String get composerDiscard => 'Discard';

  @override
  String get composerKeepEditing => 'Keep editing';

  @override
  String get composerVolumeMix => 'Volume mix';

  @override
  String get composerOverlayError => 'Couldn\'t apply the text to the video.';

  @override
  String get composerModeStory => 'Story';

  @override
  String get composerModeText => 'Text';

  @override
  String get composerFlipCamera => 'Flip camera';

  @override
  String get composerFlash => 'Flash';

  @override
  String get composerCameraPermissionTitle => 'Allow camera access';

  @override
  String get composerCameraPermissionBody =>
      'To create photo and video stories, Brawe needs your camera and microphone.';

  @override
  String get composerOpenSettings => 'Open settings';

  @override
  String get composerNoCamera => 'Camera unavailable';

  @override
  String feedViewsCount(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted views',
      one: '1 view',
    );
    return '$_temp0';
  }

  @override
  String get feedRepostUndone => 'Repost removed';

  @override
  String get profileTabReposts => 'Reposts';

  @override
  String get profileNoReposts => 'No reposts yet';

  @override
  String get liveEndedTitle => 'Live ended';

  @override
  String liveEndedByStreamer(String name) {
    return 'Thanks for watching!';
  }

  @override
  String liveEndedAlready(String name) {
    return 'You arrived after it ended.';
  }

  @override
  String liveEndedLasted(String duration) {
    return 'Lasted $duration';
  }

  @override
  String get liveEndedFollow => 'Follow';

  @override
  String get liveEndedFollowing => 'Following';

  @override
  String liveEndedFollowHint(String name) {
    return 'Follow to know when $name goes live again.';
  }

  @override
  String get liveEndedNextLive => 'Next live';

  @override
  String get liveEndedWatchNow => 'Watch';

  @override
  String liveEndedGoingIn(int seconds) {
    return 'Going to the next live in ${seconds}s';
  }

  @override
  String get liveEndedStay => 'Stay here';

  @override
  String get liveEndedNoOther => 'No other live right now.';

  @override
  String get liveEndedBackHome => 'Back to home';

  @override
  String liveEndedWatching(String count) {
    return '$count watching';
  }

  @override
  String get livePausedTitle => 'Be right back';

  @override
  String livePausedBy(String name) {
    return '$name paused the live';
  }

  @override
  String livePausedBackIn(String time) {
    return 'Back within $time';
  }

  @override
  String get livePausedResuming => 'Coming back…';

  @override
  String get livePausedResumingHint => 'The stream is coming back in a moment';

  @override
  String get broadcasterPausedTitle => 'Live paused';

  @override
  String get broadcasterPausedHint =>
      'Camera and microphone are off. Your viewers see the pause notice.';

  @override
  String broadcasterResumeIn(String time) {
    return 'Resume within $time';
  }

  @override
  String get broadcasterResumeButton => 'Resume live';

  @override
  String get broadcasterResumingTitle => 'Going back live…';

  @override
  String get broadcasterResumingHint =>
      'Your viewers will see you again in a few seconds.';

  @override
  String get broadcasterBackLive => 'You\'re live';

  @override
  String get relHidePosts => 'Hide posts';

  @override
  String get relShowPosts => 'Show posts';

  @override
  String relHiddenSnack(String name) {
    return 'You won\'t see posts from $name anymore.';
  }

  @override
  String relShownSnack(String name) {
    return 'Posts from $name are visible again.';
  }

  @override
  String get relActionError => 'Couldn\'t complete that. Please try again.';

  @override
  String get profileBlockedState => 'You blocked this user';

  @override
  String get profileBlockedStateHint =>
      'Unblock to see their profile and posts.';

  @override
  String get profileUnblock => 'Unblock';

  @override
  String get profileUnblocked => 'User unblocked.';

  @override
  String get profileUnavailable => 'Profile unavailable';

  @override
  String get profileUnavailableHint => 'This content isn\'t available to you.';

  @override
  String get liveOwnTitle => 'You\'re live';

  @override
  String get liveOwnBody =>
      'This is your own live, streaming from another device. To watch as a viewer, sign in with another account.';

  @override
  String get liveOwnBack => 'Go back';

  @override
  String get liveConnecting => 'Connecting to the live…';

  @override
  String get rankingTitle => 'Top Gifters';

  @override
  String get rankingTabLive => 'This live';

  @override
  String get rankingTabWeek => 'Creator\'s week';

  @override
  String rankingRoomTotal(String points) {
    return 'Live total: $points coins';
  }

  @override
  String get rankingEmpty => 'No gifts yet';

  @override
  String get rankingEmptyHint => 'Be the first to send a gift!';

  @override
  String rankingGiftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gifts',
      one: '1 gift',
    );
    return '$_temp0';
  }

  @override
  String get rankingYouBadge => 'You';

  @override
  String rankingFooterGap(int rank, String gap, String name) {
    return 'You are #$rank · $gap more to pass $name';
  }

  @override
  String get rankingFooterLeader => 'You are #1 · leading the ranking';

  @override
  String rankingFooterOnly(int rank) {
    return 'You are #$rank';
  }

  @override
  String get rankingFooterJoin => 'Send a gift to join the ranking';

  @override
  String overtakenMessage(String name, String gap, int rank) {
    return '$name passed you! $gap coins to get #$rank back';
  }

  @override
  String get overtakenRetake => 'Retake';

  @override
  String newTopGifterBanner(String name) {
    return 'New #1 of the live: $name';
  }

  @override
  String giftsNeedHint(String gap) {
    return '$gap coins to retake your position';
  }

  @override
  String giftsNeedHintNone(String gap) {
    return 'Pick a gift worth at least $gap coins to retake your position';
  }

  @override
  String liveEntranceJoined(String name) {
    return '$name joined the live';
  }

  @override
  String get liveEntranceTopOne => 'The live\'s #1 just arrived';

  @override
  String get liveLevelUpTitle => 'Level up!';

  @override
  String liveLevelUpLevel(int level) {
    return 'Level $level';
  }

  @override
  String liveLevelUpPublic(String name, int level) {
    return '$name reached level $level';
  }

  @override
  String get liveGoalDefaultTitle => 'Live goal';

  @override
  String get liveGoalReached => 'Goal reached!';

  @override
  String get liveGoalOption => 'Live goal';

  @override
  String get liveGoalOptionSubtitle => 'Set a coin goal for this live';

  @override
  String get liveGoalSheetTitle => 'Live goal';

  @override
  String get liveGoalPointsLabel => 'Goal (coins)';

  @override
  String get liveGoalTitleLabel => 'Short title (e.g. Prize giveaway)';

  @override
  String get liveGoalSave => 'Set goal';

  @override
  String get liveGoalClear => 'Remove goal';

  @override
  String get liveGoalSaved => 'Goal updated';

  @override
  String get liveGoalError => 'Could not update the goal';

  @override
  String get liveGoalInvalid => 'Enter a goal greater than zero';

  @override
  String get questLiveTag => 'LIVE';

  @override
  String get questWatchLive => 'Watch lives';

  @override
  String get questSendLiveGift => 'Send gifts in a live';

  @override
  String get questLiveChat => 'Chat in a live';

  @override
  String get rankingSheetTitle => 'Live ranking';

  @override
  String get rankingTabGifts => 'Gifts';

  @override
  String get rankingTabLikes => 'Likes';

  @override
  String likesRoomTotal(String likes, int people) {
    String _temp0 = intl.Intl.pluralLogic(
      people,
      locale: localeName,
      other: '$people people',
      one: '1 person',
    );
    return '$likes likes · $_temp0';
  }

  @override
  String likesFooterGap(int rank, String gap, String name) {
    return 'You\'re #$rank · $gap likes to pass $name';
  }

  @override
  String get likesFooterLeader => 'You\'re #1 · top liker of this live';

  @override
  String likesFooterOnly(int rank) {
    return 'You\'re #$rank';
  }

  @override
  String get likesFooterJoin => 'Like the live to join the ranking';

  @override
  String get likesEmpty => 'No likes yet';

  @override
  String get likesEmptyHint => 'Be the first to like!';

  @override
  String get likesNote => 'Likes don\'t count toward the gift ranking';

  @override
  String get rankingSendGift => 'Send gift';

  @override
  String get rankingLikeNow => 'Like';

  @override
  String likeMilestoneBanner(String count) {
    return 'The live reached $count likes!';
  }

  @override
  String get questLiveLike => 'Like lives';

  @override
  String noticeOvertakenTitle(String name) {
    return '$name passed you!';
  }

  @override
  String noticeOvertakenBody(String gap, int rank) {
    return '$gap coins to take back #$rank';
  }

  @override
  String noticeLevelUpBody(int level) {
    return 'You reached level $level';
  }

  @override
  String get noticeNewTopTitle => 'New #1 of the live';

  @override
  String get goalsTitle => 'Live goals';

  @override
  String get goalsButton => 'Goals';

  @override
  String get goalTypeGift => 'Gift';

  @override
  String get goalTypeLikes => 'Likes';

  @override
  String goalLikesLabel(String count) {
    return '$count likes';
  }

  @override
  String goalProgress(String progress, String target) {
    return '$progress of $target';
  }

  @override
  String get goalReached => 'Goal reached';

  @override
  String goalReachedChat(String goal) {
    return 'Goal reached: $goal';
  }

  @override
  String get goalSendGift => 'Send';

  @override
  String get goalLike => 'Like';

  @override
  String get goalsViewerHint =>
      'Tap Send to open the gift bag on the goal\'s gift.';

  @override
  String get goalsEmptyCreator =>
      'Pick a gift and an amount, or a likes goal. Up to 3 goals.';

  @override
  String get goalPickGift => 'Pick a gift';

  @override
  String goalAddGift(String count, String gift) {
    return 'Add $count $gift';
  }

  @override
  String goalAddLikes(String count) {
    return 'Add $count likes';
  }

  @override
  String get goalsSave => 'Save goals';

  @override
  String get goalsRemoveAll => 'Remove goals';

  @override
  String get goalsSaveError => 'Couldn\'t save the goals';

  @override
  String giftTickerText(String sender, String gift, String streamer) {
    return '$sender sent $gift to $streamer';
  }

  @override
  String get videoFullscreen => 'Full screen';

  @override
  String get liveOwnEnd => 'End this live';

  @override
  String get liveOwnEndConfirmTitle => 'End the live?';

  @override
  String get liveOwnEndConfirmBody =>
      'The live ends for everyone, including on the other device.';

  @override
  String get liveOwnEnded => 'Live ended';

  @override
  String get liveOwnEndError => 'Couldn\'t end the live';

  @override
  String get liveWaitingSignal =>
      'No signal from the creator right now.\nTrying again…';

  @override
  String get commentsHintAddMention => 'Add a comment... use @ to tag';

  @override
  String get commentsMentionFollowing => 'Following';

  @override
  String eventChipEndsIn(String time) {
    return 'ends in $time';
  }

  @override
  String get rankingTabEvent => 'Event';

  @override
  String rankingPrizeFirst(String prize) {
    return '1st place prize: $prize';
  }

  @override
  String get awardGrantedTitle => 'You won an award!';

  @override
  String get profileAwardsTitle => 'Awards';

  @override
  String profileAwardUntil(String date) {
    return 'until $date';
  }

  @override
  String get chatErrorNotSent => 'Message not sent';

  @override
  String get chatErrorLink => 'Links are not allowed in chat';

  @override
  String get chatErrorPhone => 'Phone numbers are not allowed in chat';

  @override
  String chatErrorMutedUntil(String time) {
    return 'You were muted until $time';
  }

  @override
  String get chatErrorMutedLiveEnd =>
      'You were muted until the end of the live';

  @override
  String chatErrorSlowWait(int seconds) {
    return 'Slow mode: wait $seconds s';
  }

  @override
  String get chatErrorSlowGeneric => 'Slow mode: wait a moment';

  @override
  String chatSlowModeHint(int seconds) {
    return 'Slow mode: $seconds s';
  }

  @override
  String get chatPinnedUnpin => 'Unpin';

  @override
  String get chatModeratorBadge => 'Moderator';

  @override
  String get modMute5 => 'Mute 5 min';

  @override
  String get modMute60 => 'Mute 1 h';

  @override
  String get modMuteRest => 'Mute until the end of the live';

  @override
  String get modPinMessage => 'Pin message';

  @override
  String get modMakeModerator => 'Make moderator';

  @override
  String get modRemoveModerator => 'Remove moderator';

  @override
  String modMutedToast(String name) {
    return '$name was muted';
  }

  @override
  String get modPinnedToast => 'Message pinned';

  @override
  String get modUnpinnedToast => 'Message unpinned';

  @override
  String modMadeModeratorToast(String name) {
    return '$name is now a moderator';
  }

  @override
  String modRemovedModeratorToast(String name) {
    return '$name is no longer a moderator';
  }

  @override
  String get modActionFailed => 'Could not complete the action';

  @override
  String get modNotAllowed => 'You are not allowed to do that';

  @override
  String get modModeratorsTitle => 'Moderators';

  @override
  String get modModeratorsSubtitle =>
      'People who help look after your live chat';

  @override
  String get modModeratorsEmpty =>
      'You have no moderators yet. Tap someone\'s name in the chat to promote them.';

  @override
  String get modModeratorsLoadFailed => 'Could not load moderators';

  @override
  String get modRemoveConfirm => 'Remove';

  @override
  String get battleDurationLabel => 'Duration';

  @override
  String battleDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String battleDurationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get questFrequencyWeekly => 'Weekly';

  @override
  String get questFrequencyEvent => 'Event';

  @override
  String get questFrequencyDaily => 'Daily';

  @override
  String get reportReasonChildSafety => 'Child sexual abuse or exploitation';

  @override
  String get reportChildSafetyNote =>
      'If a child is in immediate danger, contact your local authorities.';

  @override
  String get liveReport => 'Report live';

  @override
  String get settingsSendFeedback => 'Send feedback';

  @override
  String get settingsChildSafety => 'Child Safety Standards';

  @override
  String get feedbackIntro =>
      'Tell us what happened. Your message goes straight to our team, without leaving the app.';

  @override
  String get feedbackTypeBug => 'App problem';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackTypeChildSafety => 'Child safety';

  @override
  String get feedbackHint => 'Describe it here…';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackSent => 'Feedback sent. Thank you!';

  @override
  String get feedbackError => 'Couldn\'t send. Please try again.';

  @override
  String get feedbackTooShort => 'Please write at least 10 characters.';

  @override
  String get suspendedTitle => 'Account suspended';

  @override
  String get suspendedBody =>
      'Your Brawe Connect account has been suspended for violating our Community Guidelines.';

  @override
  String get suspendedReasonLabel => 'Reason';

  @override
  String suspendedUntil(String date) {
    return 'The suspension ends on $date.';
  }

  @override
  String get suspendedPermanent => 'This suspension is permanent.';

  @override
  String get suspendedAppeal =>
      'If you believe this is a mistake, contact our support team.';

  @override
  String get suspendedContact => 'Contact support';

  @override
  String get suspendedRetry => 'Check again';

  @override
  String get suspendedStillActive => 'Your account is still suspended.';
}
