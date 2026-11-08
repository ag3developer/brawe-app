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
  String get settingsThemeAuto => 'Automatic';

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
  String get liveStoryBattleBadge => 'BATTLE';

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
  String get postAddPoll => 'Poll';

  @override
  String get postAddLocation => 'Location';

  @override
  String get pollEditorTitle => 'Poll';

  @override
  String pollOptionHint(int n) {
    return 'Option $n';
  }

  @override
  String get pollAddOption => 'Add option';

  @override
  String get pollRemoveOption => 'Remove option';

  @override
  String get pollRemove => 'Remove poll';

  @override
  String get pollDurationLabel => 'Duration';

  @override
  String pollDurationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get pollRulesHint =>
      'All options are required: 2 to 4, up to 60 characters, no repeats. Votes can\'t be changed.';

  @override
  String get pollErrorEmpty => 'Fill in this option';

  @override
  String get pollErrorDuplicate => 'Repeated option';

  @override
  String get pollNeedsQuestion => 'Write the question in the post text';

  @override
  String get pollBlockedByImage =>
      'A poll and a photo can\'t be used together. Remove the photo to create a poll.';

  @override
  String get imageBlockedByPoll =>
      'A poll and a photo can\'t be used together. Remove the poll to attach a photo.';

  @override
  String pollVotesCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String pollEndsInDays(int count) {
    return 'ends in $count d';
  }

  @override
  String pollEndsInHours(int count) {
    return 'ends in $count h';
  }

  @override
  String pollEndsInMinutes(int count) {
    return 'ends in $count min';
  }

  @override
  String get pollEnded => 'Ended';

  @override
  String get pollVoteToSee => 'Vote to see the results';

  @override
  String get pollVoteError => 'Couldn\'t register your vote. Try again.';

  @override
  String get pollAlreadyVoted => 'You already voted in this poll.';

  @override
  String get pollEndedMessage => 'This poll has already ended.';

  @override
  String get pollMyVoteSemantics => 'Your vote';

  @override
  String get postLocationRemove => 'Remove location';

  @override
  String get postLocationLoading => 'Getting your city...';

  @override
  String get postLocationDenied =>
      'Location permission denied. Allow it in Settings to tag your city.';

  @override
  String get postLocationServiceOff =>
      'Location services are turned off on this device.';

  @override
  String get postLocationFailed => 'Couldn\'t find your city.';

  @override
  String get postLocationOpenSettings => 'Open Settings';

  @override
  String get audiencePickerTitle => 'Who can see?';

  @override
  String get audienceAll => 'Everyone';

  @override
  String get audienceFollowers => 'Followers';

  @override
  String get audienceOnlyMe => 'Only me';

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
  String get videoCaptionHint => 'Write a caption…';

  @override
  String get videoPublishButton => 'Publish video';

  @override
  String get videoSelect => 'Select video';

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
      'Purchase processed by your phone\'s official app store. Coins are credited automatically after payment. Coins are non-redeemable virtual items used inside the app.';

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
      'In-app purchases aren\'t available on this device. Check that your store account is set up.';

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
      'Coin purchases through the app store';

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
  String get battleTopSupporters => 'Top supporters';

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
  String get battleMomentum => 'ON FIRE';

  @override
  String get battleLeadChange => 'LEAD CHANGE!';

  @override
  String get battleFinalStretch => 'FINAL STRETCH';

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
      'Secure payment through your phone\'s app store';

  @override
  String get topUpStoreDisclaimerApple =>
      'Secure payment through the App Store';

  @override
  String get topUpStoreDisclaimerGoogle => 'Secure payment through Google Play';

  @override
  String get earningsNoPurchasesHint =>
      'When you buy coins through the app store, they\'ll show up here.';

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
  String get analyticsLivesKpiGifts => 'Gifts (USD)';

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
  String get analyticsLivesMetricUsdt => 'USD';

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
  String get analyticsReachKpiEarnings => 'Earnings (USD)';

  @override
  String get analyticsReachEarningsChartTitle => 'Earnings per day';

  @override
  String get analyticsReachLegendEarnings => 'Earnings USD';

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

  @override
  String get questsTabMissions => 'Missions';

  @override
  String get questsTabAchievements => 'Achievements';

  @override
  String get questsTabJourney => 'Journey';

  @override
  String questsResetsIn(String time) {
    return 'New missions in $time';
  }

  @override
  String questsDayProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get questsSectionDaily => 'Daily missions';

  @override
  String get questsSectionWeekly => 'Weekly missions';

  @override
  String get questsSectionEvent => 'Event missions';

  @override
  String get questsAllDoneMascot =>
      'You completed all of today\'s missions! Come back tomorrow to keep your streak.';

  @override
  String questsStreakMascot(int days) {
    return '$days-day streak! Keep it up!';
  }

  @override
  String get questsStartMascot =>
      'Complete all of today\'s missions to start a streak and earn badges.';

  @override
  String questsNextBadge(int days) {
    return 'Next badge in $days days';
  }

  @override
  String questsStreakBonus(String label) {
    return 'Streak bonus $label';
  }

  @override
  String get questsLevelUpTitle => 'Level up!';

  @override
  String questsLevelUpBody(int level) {
    return 'You reached level $level';
  }

  @override
  String get questsBadgeUnlockedTitle => 'Badge unlocked!';

  @override
  String get questsContinue => 'Continue';

  @override
  String get questsStatsTitle => 'Your stats';

  @override
  String get questsStatQuests => 'Missions completed';

  @override
  String get questsStatXp => 'Total XP';

  @override
  String get questsStatCoins => 'Coins earned';

  @override
  String get questsStatBestStreak => 'Best streak';

  @override
  String get questsBadgesTitle => 'Badges';

  @override
  String questsBadgesCount(int unlocked, int total) {
    return '$unlocked of $total';
  }

  @override
  String get questsBadgeLocked => 'Locked';

  @override
  String get questsBadgeEarned => 'Earned';

  @override
  String questsBadgeEarnedOn(String date) {
    return 'Earned on $date';
  }

  @override
  String questsBadgeRequirement(int days) {
    return 'Complete all daily missions for $days days in a row.';
  }

  @override
  String questsBadgeProgress(int current, int target) {
    return '$current of $target days';
  }

  @override
  String get questBadgeStreak3 => 'Dedicated Rookie';

  @override
  String get questBadgeStreak7 => 'Weekly Warrior';

  @override
  String get questBadgeStreak14 => 'Veteran';

  @override
  String get questBadgeStreak30 => 'Legend of the Month';

  @override
  String get questBadgeStreak60 => 'Master of Consistency';

  @override
  String get questBadgeStreak100 => 'Brawe Icon';

  @override
  String get questsAwardsTitle => 'Awards received';

  @override
  String get questsAwardsEmpty =>
      'You haven\'t received any awards yet. Join lives, events and battles to win.';

  @override
  String get questsAwardActive => 'Active';

  @override
  String get questsAwardExpired => 'Expired';

  @override
  String get questsAwardRevoked => 'Revoked';

  @override
  String get questsAwardScheduled => 'Upcoming';

  @override
  String questsAwardValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String questsAwardEndedOn(String date) {
    return 'Ended on $date';
  }

  @override
  String questsAwardStartsOn(String date) {
    return 'Starts on $date';
  }

  @override
  String get questsAwardSourceEvent => 'Event';

  @override
  String get questsAwardSourceCreatorWeek => 'Creator week';

  @override
  String get questsAwardSourceLive => 'Live';

  @override
  String get questsAwardSourceBattle => 'Battle';

  @override
  String questsAwardRank(int rank) {
    return '#$rank place';
  }

  @override
  String questsAwardCoins(int coins) {
    return '+$coins coins';
  }

  @override
  String get questsAwardFrame => 'Frame';

  @override
  String get questsAwardEntry => 'Special entrance';

  @override
  String get questsTimelineEmpty =>
      'Your journey starts now. Complete missions to see your achievements here.';

  @override
  String get questsTimelineToday => 'Today';

  @override
  String get questsTimelineYesterday => 'Yesterday';

  @override
  String get questsTimelineQuest => 'Mission completed';

  @override
  String get questsTimelineAward => 'Award received';

  @override
  String get questsTimelineBadge => 'Badge earned';

  @override
  String questsTimelineLevel(int level) {
    return 'Reached level $level';
  }

  @override
  String get questsJourneyError => 'Couldn\'t load your journey.';

  @override
  String questsLevelShort(int level) {
    return 'Lv. $level';
  }

  @override
  String get findFriendsSearchHint => 'Search by name or @username';

  @override
  String findFriendsSearchNoResults(String query) {
    return 'No one found for \"$query\"';
  }

  @override
  String get findFriendsSearchError =>
      'Couldn\'t search right now. Check your connection.';

  @override
  String get findFriendsSuggestionsError => 'Couldn\'t load suggestions.';

  @override
  String get findFriendsRetry => 'Try again';

  @override
  String get creatorGuideTitle => 'Creator Guide';

  @override
  String get creatorGuideIntro =>
      'Everything you need to know to grow on Brawe.';

  @override
  String get creatorGuideToc => 'Contents';

  @override
  String get creatorGuideSecWhat => 'What it is';

  @override
  String get creatorGuideSecBenefits => 'Benefits';

  @override
  String get creatorGuideSecLevels => 'Levels';

  @override
  String get creatorGuideSecHow => 'How to join';

  @override
  String get creatorGuideSecRules => 'Guidelines';

  @override
  String get creatorGuideSecFaq => 'FAQ';

  @override
  String get creatorGuideWhatBody =>
      'Brawe\'s official program for people who create content and want to grow, get discovered and build a community.';

  @override
  String get creatorGuideWhatPoint1 => 'Free to apply';

  @override
  String get creatorGuideWhatPoint2 => 'Reviewed by people';

  @override
  String get creatorGuideWhatPoint3 => 'Grow through levels';

  @override
  String get creatorGuideHowStep1 => 'Fill in the application';

  @override
  String get creatorGuideHowStep2 => 'Our team reviews your profile';

  @override
  String get creatorGuideHowStep3 => 'You get the answer in the app';

  @override
  String get creatorGuideHowStep4 =>
      'Once approved, activate your creator profile';

  @override
  String get creatorGuideRule1 => 'Original content or properly credited';

  @override
  String get creatorGuideRule2 =>
      'Respect the community, no hate or harassment';

  @override
  String get creatorGuideRule3 => 'No fake followers or bought engagement';

  @override
  String get creatorGuideRule4 => 'Child safety always comes first';

  @override
  String get creatorGuideRule5 => 'Follow the Terms and Privacy Policy';

  @override
  String get creatorGuideFaq1Q => 'How much does it cost?';

  @override
  String get creatorGuideFaq1A =>
      'Nothing. Applying and being in the network is free.';

  @override
  String get creatorGuideFaq2Q => 'How long does the review take?';

  @override
  String get creatorGuideFaq2A =>
      'We\'ll let you know as soon as there\'s news. Track the status in the app.';

  @override
  String get creatorGuideFaq3Q => 'Do I need many followers?';

  @override
  String get creatorGuideFaq3A =>
      'No. We look at consistency, quality and potential, not just numbers.';

  @override
  String get creatorGuideFaq4Q => 'Can I reapply if I\'m declined?';

  @override
  String get creatorGuideFaq4A =>
      'Yes. Improve your profile and apply again later.';

  @override
  String get creatorGuideCtaTerms => 'Read the terms';

  @override
  String get creatorApplyTypeTitle => 'Creator type';

  @override
  String get creatorApplyTypeHint => 'Pick what best describes your content.';

  @override
  String get creatorApplyNicheLifestyle => 'Lifestyle';

  @override
  String get creatorApplyNicheGames => 'Gaming';

  @override
  String get creatorApplyNicheMusic => 'Music';

  @override
  String get creatorApplyNicheFashion => 'Fashion';

  @override
  String get creatorApplyNicheBeauty => 'Beauty';

  @override
  String get creatorApplyNicheFitness => 'Fitness';

  @override
  String get creatorApplyNicheComedy => 'Comedy';

  @override
  String get creatorApplyNicheBusiness => 'Business';

  @override
  String get creatorApplyNicheTech => 'Tech';

  @override
  String get creatorApplyNicheEducation => 'Education';

  @override
  String get creatorApplyNicheTravel => 'Travel';

  @override
  String get creatorApplyNicheEntertainment => 'Entertainment';

  @override
  String get creatorApplyNicheSports => 'Sports';

  @override
  String get creatorApplyNicheCooking => 'Cooking';

  @override
  String get creatorApplyNicheOther => 'Other';

  @override
  String get creatorApplyTermsAnd => ' and the ';

  @override
  String get creatorApplyTermsUse => 'Terms of Use';

  @override
  String get creatorApplyAcceptButton => 'I have read and accept';

  @override
  String get creatorApplyErrUsername => 'At least 2 characters';

  @override
  String get creatorApplyErrName => 'Enter first and last name';

  @override
  String get creatorApplyErrUrl => 'Enter a valid link (https://...)';

  @override
  String get creatorApplyErrCountry => 'Select your country';

  @override
  String get creatorApplyErrPhone => 'Invalid phone number';

  @override
  String get creatorApplyErrFollowers => 'Enter a valid number';

  @override
  String get creatorApplyErrNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get creatorApplyErrServer =>
      'Server unavailable right now. Try again shortly.';

  @override
  String get creatorApplyErrSession =>
      'Your session expired. Sign in again to apply.';

  @override
  String creatorApplyErrFields(String fields) {
    return 'Some data was not accepted. Review the form: $fields.';
  }

  @override
  String get creatorApplyOptional => 'optional';

  @override
  String get creatorApplyInstagramHint => 'username (no @)';

  @override
  String get creatorApplyCategoryHint => 'Optional: the level you aim for.';

  @override
  String get rewardsTabReceived => 'Received';

  @override
  String get rewardsTabSent => 'Sent';

  @override
  String get rewardsPeriodToday => 'Today';

  @override
  String get rewardsPeriod7d => '7 days';

  @override
  String get rewardsPeriod30d => '30 days';

  @override
  String get rewardsPeriodAll => 'All';

  @override
  String get rewardsHistoryTitle => 'Gift history';

  @override
  String get rewardsHistorySubtitle => 'Gifts you received and sent';

  @override
  String get rewardsNoSent => 'You haven\'t sent any gifts yet.';

  @override
  String get rewardsNoSentHint => 'Gifts you send in lives will show up here.';

  @override
  String get rewardsNoPeriod => 'Nothing in this period.';

  @override
  String get rewardsNoPeriodHint => 'Try another period to see more items.';

  @override
  String get rewardsPeriodTotalReceived => 'Total received in period';

  @override
  String get rewardsPeriodTotalSent => 'Total sent in period';

  @override
  String rewardsGiftsCount(int n) {
    return '$n gifts';
  }

  @override
  String rewardsFromTo(String label, String name) {
    return '$label $name';
  }

  @override
  String get rewardsPurchaseDisabled => 'Buying coins will be available soon.';

  @override
  String get liveTopUpAction => 'Top up';

  @override
  String get rewardsToggleCoins => 'Coins';

  @override
  String get rewardsToggleDiamonds => 'Diamonds';

  @override
  String get rewardsDiamondsAvailable => 'Available diamonds';

  @override
  String get rewardsPeriodLabel => 'Period';

  @override
  String creatorDashSince(String date) {
    return 'Creator since $date';
  }

  @override
  String get creatorDashCurrentLevel => 'Your level';

  @override
  String creatorDashOverallProgress(int percent, String tier) {
    return '$percent% of the way to $tier';
  }

  @override
  String get creatorDashInviteNext =>
      'The next level is by invitation from the Brawe team. Keep creating and shining!';

  @override
  String get creatorDashTopLevel =>
      'You reached the top of the journey. Thank you for building Brawe!';

  @override
  String get creatorDashTrailTitle => 'Your path';

  @override
  String get creatorDashTrailHere => 'You are here';

  @override
  String get creatorDashTrailLocked => 'Locked';

  @override
  String get creatorDashTrailInviteOnly => 'By invitation';

  @override
  String creatorDashTrailSince(String date) {
    return 'Since $date';
  }

  @override
  String creatorDashGoalsTitle(String tier) {
    return 'Goals for $tier';
  }

  @override
  String get creatorDashGoalsHint =>
      'Complete the goals and show the team you are ready.';

  @override
  String get creatorDashGoalsAllDone =>
      'Goals complete! The Brawe team will review your profile for the next level.';

  @override
  String creatorDashGoalOf(String current, String target) {
    return '$current of $target';
  }

  @override
  String get creatorDashGoalDone => 'Goal complete';

  @override
  String get creatorJourneyMetricFollowers => 'Followers';

  @override
  String get creatorJourneyMetricLives => 'Lives hosted';

  @override
  String get creatorJourneyMetricLiveMinutes => 'Minutes live';

  @override
  String get creatorJourneyMetricPosts => 'Posts published';

  @override
  String get creatorJourneyMetricGiftCredits => 'Gifts received';

  @override
  String get creatorJourneyMetricActiveDays => 'Days as a creator';

  @override
  String get creatorJourneyMetricViewers => 'Live viewers';

  @override
  String creatorJourneyRemainingFollowers(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n followers to go',
      one: '1 follower to go',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingLives(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lives to go',
      one: '1 live to go',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingLiveMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes live to go',
      one: '1 minute live to go',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingPosts(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n posts to go',
      one: '1 post to go',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingGiftCredits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n gift credits to go',
      one: '1 gift credit to go',
    );
    return '$_temp0';
  }

  @override
  String creatorJourneyRemainingActiveDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days to go',
      one: '1 day to go',
    );
    return '$_temp0';
  }

  @override
  String get creatorDashWeekTitle => 'Your week';

  @override
  String get creatorDashWeekSubtitle =>
      'Last 7 days compared to the previous 7';

  @override
  String get creatorDashWeekNewFollowers => 'New followers';

  @override
  String creatorDashWeekUp(String n) {
    return '$n more than last week';
  }

  @override
  String creatorDashWeekDown(String n) {
    return '$n fewer than last week';
  }

  @override
  String get creatorDashWeekSame => 'Same as last week';

  @override
  String get creatorDashWeekSeeMore => 'See analysis';

  @override
  String get creatorDashBenefitsTitle => 'Your benefits';

  @override
  String creatorDashBenefitsNextTitle(String tier) {
    return 'Unlocks at $tier';
  }

  @override
  String get creatorDashBenefitActive => 'Active';

  @override
  String get creatorDashShortcutAnalytics => 'Analytics';

  @override
  String get creatorDashShortcutSettings => 'Settings';

  @override
  String get creatorDashErrorTitle =>
      'We could not load your journey. Pull to try again.';

  @override
  String get creatorJourneyBadgeGeneric => 'Creator badge';

  @override
  String creatorJourneyBadgeEarnedOn(String date) {
    return 'Earned on $date';
  }

  @override
  String get creatorJourneyBadgeBenefitsTitle => 'Active benefits';

  @override
  String get creatorJourneyBadgeNextTitle => 'Next level';

  @override
  String get creatorJourneyBadgeAllTitle => 'Your badges';

  @override
  String get creatorJourneyBadgeOpenDashboard => 'Open creator dashboard';

  @override
  String get creatorJourneyBenefitRisingBadgeTitle => 'Rising badge';

  @override
  String get creatorJourneyBenefitRisingBadgeDesc =>
      'Your official creator badge shows on your profile, lives and comments.';

  @override
  String get creatorJourneyBenefitCreatorProfileTitle => 'Creator profile';

  @override
  String get creatorJourneyBenefitCreatorProfileDesc =>
      'A profile with its own identity in Brawe\'s creator network.';

  @override
  String get creatorJourneyBenefitDiscoverySuggestionsTitle =>
      'Discovery suggestions';

  @override
  String get creatorJourneyBenefitDiscoverySuggestionsDesc =>
      'Your content can be suggested to people who do not follow you yet.';

  @override
  String get creatorJourneyBenefitAnalyticsTitle => 'Detailed analytics';

  @override
  String get creatorJourneyBenefitAnalyticsDesc =>
      'Track followers, reach and lives with real charts and numbers.';

  @override
  String get creatorJourneyBenefitFeaturedBadgeTitle => 'Featured badge';

  @override
  String get creatorJourneyBenefitFeaturedBadgeDesc =>
      'A highlight badge showing you are a consistent creator.';

  @override
  String get creatorJourneyBenefitEditorialHighlightTitle =>
      'Editorial spotlight';

  @override
  String get creatorJourneyBenefitEditorialHighlightDesc =>
      'A chance to appear in showcases curated by the Brawe team.';

  @override
  String get creatorJourneyBenefitMoreReachTitle => 'More organic reach';

  @override
  String get creatorJourneyBenefitMoreReachDesc =>
      'Your content gets a boost in discovery and reaches more people.';

  @override
  String get creatorJourneyBenefitLiveBadgeTitle => 'Live badge';

  @override
  String get creatorJourneyBenefitLiveBadgeDesc =>
      'An exclusive badge for those who build community live.';

  @override
  String get creatorJourneyBenefitAdvancedLiveTitle => 'Advanced live tools';

  @override
  String get creatorJourneyBenefitAdvancedLiveDesc =>
      'Extra tools to make more professional lives.';

  @override
  String get creatorJourneyBenefitLiveBattlesTitle => 'Live battles';

  @override
  String get creatorJourneyBenefitLiveBattlesDesc =>
      'Join battles and compete for gifts against other creators.';

  @override
  String get creatorJourneyBenefitLiveRankingTitle => 'Live Creators ranking';

  @override
  String get creatorJourneyBenefitLiveRankingDesc =>
      'Show up in the public ranking of the brightest live creators.';

  @override
  String get creatorJourneyBenefitAmbassadorBadgeTitle => 'Ambassador badge';

  @override
  String get creatorJourneyBenefitAmbassadorBadgeDesc =>
      'The badge of those who represent Brawe with official recognition.';

  @override
  String get creatorJourneyBenefitAmbassadorPageTitle => 'Ambassador page';

  @override
  String get creatorJourneyBenefitAmbassadorPageDesc =>
      'An official page to tell your story and achievements.';

  @override
  String get creatorJourneyBenefitOfficialCampaignsTitle =>
      'Official campaigns';

  @override
  String get creatorJourneyBenefitOfficialCampaignsDesc =>
      'Invitations to join Brawe brand campaigns and activations.';

  @override
  String get creatorJourneyBenefitPremiumHighlightTitle => 'Premium spotlight';

  @override
  String get creatorJourneyBenefitPremiumHighlightDesc =>
      'A privileged spot in the platform highlights.';

  @override
  String get creatorJourneyBenefitFoundingBadgeTitle => 'Founding badge';

  @override
  String get creatorJourneyBenefitFoundingBadgeDesc =>
      'The rarest badge: for those building Brawe from the start.';

  @override
  String get creatorJourneyBenefitFoundingSealTitle => 'Founder seal';

  @override
  String get creatorJourneyBenefitFoundingSealDesc =>
      'Permanent recognition as part of Brawe\'s story.';

  @override
  String get creatorJourneyBenefitEarlyAccessTitle => 'Early access';

  @override
  String get creatorJourneyBenefitEarlyAccessDesc =>
      'Try new features before everyone else.';

  @override
  String get creatorJourneyBenefitRoadmapVoiceTitle => 'A voice in the roadmap';

  @override
  String get creatorJourneyBenefitRoadmapVoiceDesc =>
      'Your feedback helps decide what Brawe builds next.';

  @override
  String get creatorDashShowAll => 'Show all';

  @override
  String get creatorDashShowLess => 'Show less';

  @override
  String get analyticsPreviousPeriod => 'Previous period';

  @override
  String get analyticsNoDataTitle => 'No data for this period';

  @override
  String get analyticsNoDataSubtitle =>
      'Try another period or come back after new activity.';

  @override
  String get analyticsPeriod7d => '7D';

  @override
  String get analyticsPeriod30d => '30D';

  @override
  String get analyticsPeriod90d => '3M';

  @override
  String get analyticsPeriod365d => '1Y';

  @override
  String get analyticsVsPrevious => 'vs. previous period';

  @override
  String get analyticsCompare => 'Compare';

  @override
  String get analyticsErrorTitle => 'Couldn\'t load data';

  @override
  String get analyticsRetry => 'Try again';

  @override
  String get analyticsTopGiftsTitle => 'Top gifts';

  @override
  String get analyticsTopGiftsSubtitle => 'Most received in the period';

  @override
  String get analyticsTopGiftsEmpty => 'No gifts received in this period';

  @override
  String get analyticsTopGiftsBest => 'Most valuable';

  @override
  String analyticsTopGiftsReceived(String count) {
    return '$count received';
  }

  @override
  String get analyticsEarningsLabel => 'Earnings';

  @override
  String get analyticsGiftsLabel => 'Gifts';

  @override
  String get analyticsAvgPerGift => 'Average per gift';

  @override
  String get analyticsEarningsChartTitle => 'Earnings per day';

  @override
  String get analyticsGiftsChartTitle => 'Gifts per day';

  @override
  String get analyticsFollowersNew => 'New followers';

  @override
  String get analyticsFollowersChartTotal => 'Total followers';

  @override
  String get analyticsFollowersChartNew => 'New per day';

  @override
  String get analyticsViewersKpiPeak => 'Peak audience';

  @override
  String analyticsWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get analyticsLivesMinutesLabel => 'Time live';

  @override
  String get analyticsLivesChartLives => 'Lives per day';

  @override
  String get analyticsLivesChartMinutes => 'Minutes live';

  @override
  String get analyticsLivesHistoryTitle => 'Live history';

  @override
  String get analyticsLivesMetricEarned => 'in gifts';

  @override
  String analyticsMinutesShort(String n) {
    return '$n min';
  }

  @override
  String analyticsHoursMinutes(String h, String m) {
    return '${h}h ${m}min';
  }

  @override
  String get analyticsRange7d => 'in the last 7 days';

  @override
  String get analyticsRange30d => 'in the last 30 days';

  @override
  String get analyticsRange90d => 'in the last 3 months';

  @override
  String get analyticsRange365d => 'in the last year';

  @override
  String analyticsEmptyFollowersNew(String range) {
    return 'No new followers $range';
  }

  @override
  String get analyticsEmptyFollowersTotal => 'You don\'t have followers yet';

  @override
  String analyticsEmptyEarnings(String range) {
    return 'No earnings $range';
  }

  @override
  String analyticsEmptyGifts(String range) {
    return 'No gifts received $range';
  }

  @override
  String analyticsEmptyViewers(String range) {
    return 'No viewers $range';
  }

  @override
  String analyticsEmptyLives(String range) {
    return 'No lives $range';
  }

  @override
  String analyticsEmptyMinutes(String range) {
    return 'No minutes live $range';
  }

  @override
  String get analyticsHubTitle => 'Analytics';

  @override
  String get analyticsTabOverview => 'Overview';

  @override
  String get analyticsTabFollowers => 'Followers';

  @override
  String get analyticsTabAudience => 'Audience';

  @override
  String get analyticsTabLives => 'Lives';

  @override
  String get analyticsTabEarnings => 'Earnings';

  @override
  String get analyticsOverviewTopGift => 'Featured gift';

  @override
  String get analyticsOverviewSeeDetails => 'Tap a metric to see details';

  @override
  String get gifterLevelTitle => 'My level';

  @override
  String gifterLevelLevel(int level) {
    return 'Level $level';
  }

  @override
  String gifterLevelXpProgress(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String gifterLevelXpMissing(String xp, int level) {
    return '$xp XP to level $level';
  }

  @override
  String get gifterLevelMaxReached => 'Max level reached';

  @override
  String get gifterLevelNextTier => 'Next tier';

  @override
  String gifterLevelNextTierLine(String name, int level, String xp) {
    return '$name · level $level · $xp XP to go';
  }

  @override
  String get gifterLevelHowToEarn => 'How to earn XP';

  @override
  String gifterLevelRuleGiftPerCoin(int xp, String cap) {
    return 'Send gifts · $xp XP per coin (up to $cap per send)';
  }

  @override
  String gifterLevelRuleGiftPerCoinNoCap(int xp) {
    return 'Send gifts · $xp XP per coin';
  }

  @override
  String gifterLevelRuleGiftFlat(int xp) {
    return 'Send gifts · +$xp XP per gift';
  }

  @override
  String gifterLevelRuleWatch(int xp, int cap) {
    return 'Watch lives · $xp XP per minute (up to $cap min)';
  }

  @override
  String gifterLevelRuleWatchNoCap(int xp) {
    return 'Watch lives · $xp XP per minute';
  }

  @override
  String gifterLevelRuleJoin(int xp) {
    return 'Join a live · +$xp XP';
  }

  @override
  String gifterLevelRuleChat(int xp) {
    return 'Chat comment · +$xp XP';
  }

  @override
  String get gifterLevelTiers => 'Tiers';

  @override
  String gifterLevelRange(int from, int to) {
    return 'Level $from–$to';
  }

  @override
  String gifterLevelRangeOpen(int from) {
    return 'Level $from';
  }

  @override
  String gifterLevelXpRequired(String xp) {
    return '$xp XP';
  }

  @override
  String get gifterLevelBenefitVip => 'VIP entry';

  @override
  String get gifterLevelBenefitEntryEffect => 'Entry effect';

  @override
  String get gifterLevelBenefitAnnounce => 'Level-up announcement';

  @override
  String get gifterLevelYouAreHere => 'You are here';

  @override
  String gifterLevelTierXpMissing(String xp) {
    return '$xp XP to go';
  }

  @override
  String get gifterLevelLoadError => 'Couldn\'t load your level.';

  @override
  String get gifterLevelRetry => 'Try again';

  @override
  String get gifterLevelSeeLevels => 'See levels';

  @override
  String get gifterLevelStatusAchieved => 'Unlocked';

  @override
  String get gifterLevelStatusCurrent => 'Current tier';

  @override
  String get gifterLevelStatusLocked => 'Locked';

  @override
  String get gifterLevelBackToCurrent => 'Back to my level';

  @override
  String get gifterLevelBenefits => 'Perks';

  @override
  String get gifterLevelNoBenefits => 'Exclusive chat badge';

  @override
  String get gifterLevelSwipeHint => 'Swipe to see every tier';

  @override
  String gifterLevelUnlockedAt(String xp) {
    return 'Unlocked at $xp XP';
  }

  @override
  String gifterLevelTierProgress(String current, String total) {
    return 'You have $current of $total XP';
  }

  @override
  String gifterLevelTiersCount(int done, int total) {
    return '$done of $total tiers';
  }

  @override
  String get menuSectionProgress => 'My progress';

  @override
  String get menuSectionMoney => 'Coins & gifts';

  @override
  String get menuSectionCreator => 'Creator';

  @override
  String get menuSectionAccount => 'Account';

  @override
  String get menuSectionProfile => 'Profile';

  @override
  String get menuSectionPrivacy => 'Privacy and safety';

  @override
  String get menuQuestsSubtitle => 'Missions, achievements and journey';

  @override
  String get menuLevelSubtitle => 'Tiers, badges and XP';

  @override
  String get menuWalletSubtitle => 'Your coins for gifting';

  @override
  String get menuCreatorSubtitleMember => 'Dashboard, earnings and analytics';

  @override
  String get menuCreatorSubtitleJoin => 'Learn how to earn with your lives';

  @override
  String get menuSettingsSubtitle => 'Privacy, notifications and more';

  @override
  String get creatorShortcutEarnings => 'Earnings';

  @override
  String get notifFilterAll => 'All';

  @override
  String get notifFilterLives => 'Lives';

  @override
  String get notifFilterSocial => 'Social';

  @override
  String get notifFilterMissions => 'Missions';

  @override
  String get notifFilterGifts => 'Gifts';

  @override
  String get notifFilterOther => 'System';

  @override
  String get notifGroupToday => 'Today';

  @override
  String get notifGroupYesterday => 'Yesterday';

  @override
  String get notifGroupWeek => 'This week';

  @override
  String get notifGroupOlder => 'Earlier';

  @override
  String get notifFilterEmpty => 'Nothing here in this category';

  @override
  String get notifMarkAllTooltip => 'Mark all as read';

  @override
  String get linkSharedPost => '📎 Shared post';

  @override
  String get chatViewOncePhoto => 'Photo';

  @override
  String get chatViewOnceTapToOpen => 'Tap to open · view once';

  @override
  String get chatViewOnceSent => 'View once · sent';

  @override
  String get chatViewOnceOpened => 'Opened';

  @override
  String get chatCopied => 'Message copied';

  @override
  String get chatEmojiKeyboard => 'Keyboard';

  @override
  String get chatDeleteForEveryone => 'Delete for everyone';

  @override
  String get chatDeleteForEveryoneTitle => 'Delete for everyone?';

  @override
  String get chatDeleteForEveryoneBody =>
      'The message will disappear for you and the other person.';

  @override
  String get chatMessageDeleted => 'Message deleted';

  @override
  String get chatErrLoadMessages => 'Couldn\'t load messages.';

  @override
  String get chatErrSend => 'Couldn\'t send the message.';

  @override
  String get chatErrReact => 'Couldn\'t react to the message.';

  @override
  String get chatErrAudio => 'Couldn\'t send the audio.';

  @override
  String get chatErrImage => 'Couldn\'t send the image.';

  @override
  String get chatErrDelete => 'Couldn\'t delete the message.';

  @override
  String get chatErrLoadConversations => 'Couldn\'t load conversations.';

  @override
  String get chatErrArchive => 'Couldn\'t archive the conversation.';

  @override
  String get chatErrUnarchive => 'Couldn\'t unarchive the conversation.';

  @override
  String get chatErrDeleteConversation => 'Couldn\'t delete the conversation.';

  @override
  String get chatErrStart => 'Couldn\'t start the conversation.';

  @override
  String get chatMicDenied => 'Microphone permission denied';

  @override
  String get chatErrEdit => 'Couldn\'t edit the message.';

  @override
  String get chatErrOpenGift => 'Couldn\'t open the vault. Try again.';

  @override
  String get chatErrFile => 'Couldn\'t send the file.';

  @override
  String get chatEdit => 'Edit';

  @override
  String get chatEditTitle => 'Edit message';

  @override
  String get chatEditSave => 'Save';

  @override
  String get chatEdited => 'edited';

  @override
  String get chatForward => 'Forward';

  @override
  String get chatForwarded => 'Forwarded';

  @override
  String get chatForwardTitle => 'Forward to';

  @override
  String get chatForwardSent => 'Message forwarded';

  @override
  String get chatForwardEmpty => 'You don\'t have other conversations yet';

  @override
  String get chatMsgSearchHint => 'Search messages';

  @override
  String get chatSearchEmpty => 'No messages found';

  @override
  String get chatSearchMinChars => 'Type at least 2 characters';

  @override
  String get chatUnmute => 'Turn on notifications';

  @override
  String get chatMutedToast => 'Conversation muted';

  @override
  String get chatUnmutedToast => 'Notifications on';

  @override
  String get chatPin => 'Pin conversation';

  @override
  String get chatUnpin => 'Unpin conversation';

  @override
  String get chatPinnedToast => 'Conversation pinned';

  @override
  String get chatUnpinnedToast => 'Conversation unpinned';

  @override
  String get chatPinLimit => 'You can pin up to 5 conversations';

  @override
  String get chatLocationTitle => 'Location';

  @override
  String get chatLocationOpen => 'Open in maps';

  @override
  String get chatLocationDenied =>
      'Allow location access in Settings to send it.';

  @override
  String get chatLocationGetting => 'Getting your location…';

  @override
  String get chatLocationError => 'Couldn\'t get your location.';

  @override
  String get chatLocationConfirmTitle => 'Send your current location?';

  @override
  String get chatLocationConfirmBody =>
      'The other person will see where you are now.';

  @override
  String get chatSend => 'Send';

  @override
  String get chatFileOpen => 'Tap to open';

  @override
  String get chatStoryReacted => 'Reacted to your story';

  @override
  String get chatStoryReactedMine => 'You reacted to their story';

  @override
  String get chatStoryReplied => 'Replied to your story';

  @override
  String get chatStoryRepliedMine => 'You replied to their story';

  @override
  String get chatStoryUnavailable => 'Story unavailable';

  @override
  String get chatVaultReceived => 'You got a vault!';

  @override
  String get chatVaultFromStory => 'Gift from your story';

  @override
  String get chatVaultTapToOpen => 'Tap to open';

  @override
  String get chatVaultSentMine => 'You sent a vault';

  @override
  String get chatVaultWaiting => 'Waiting to be opened';

  @override
  String get chatVaultOpenedBy => 'Vault opened';

  @override
  String get chatVaultYouGot => 'You got';

  @override
  String chatVaultEarnings(String value) {
    return '+$value added to your creator rewards';
  }

  @override
  String get chatVaultCollect => 'Collect';

  @override
  String get chatVaultSeeRewards => 'See rewards';

  @override
  String get chatVaultTapHint => 'Tap the vault!';

  @override
  String get chatVaultTierCommon => 'Common';

  @override
  String get chatVaultTierRare => 'Rare';

  @override
  String get chatVaultTierEpic => 'Epic';

  @override
  String get chatVaultTierLegendary => 'Legendary';

  @override
  String get chatVaultReplay => 'Play again';

  @override
  String onbStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onbContinue => 'Continue';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbSignOut => 'Sign out';

  @override
  String get onbError => 'Something went wrong. Try again.';

  @override
  String get onbBirthTitle => 'When were you born?';

  @override
  String get onbBirthSubtitle =>
      'We need to confirm your age. It won\'t appear on your profile.';

  @override
  String get onbUnderageTitle => 'Brawe is for people 18 and older';

  @override
  String get onbUnderageBody =>
      'For the safety of our community, accounts for people under 18 are not allowed.';

  @override
  String get onbUsernameTitle => 'Choose your @';

  @override
  String get onbUsernameSubtitle =>
      'This is how people will find and mention you.';

  @override
  String get onbUsernameRules =>
      '3 to 30 characters: letters, numbers, dot and _';

  @override
  String get onbUsernameChecking => 'Checking…';

  @override
  String get onbUsernameAvailable => 'Available';

  @override
  String get onbPhotoTitle => 'Add a photo';

  @override
  String get onbPhotoSubtitle =>
      'People trust profiles with a photo more. It\'s required to use Brawe.';

  @override
  String get onbPhotoGallery => 'Choose from library';

  @override
  String get onbPhotoCamera => 'Take a photo';

  @override
  String get onbPhotoChange => 'Change photo';

  @override
  String get onbPhotoPosition => 'Adjust your photo';

  @override
  String get onbPhotoError => 'Couldn\'t upload the photo. Try again.';

  @override
  String get onbBioTitle => 'Tell us a bit about you';

  @override
  String get onbBioSubtitle =>
      'A short line for your bio. You can change it later.';

  @override
  String get onbBioHint => 'E.g.: Music, games and lives every Friday 🎮';

  @override
  String get onbFollowTitle => 'Follow people';

  @override
  String get onbFollowSubtitle =>
      'Follow at least 3 people to see content in your feed.';

  @override
  String get onbFollow => 'Follow';

  @override
  String get onbFollowing => 'Following';

  @override
  String get onbFollowAll => 'Follow all';

  @override
  String onbFollowers(String count) {
    return '$count followers';
  }

  @override
  String get onbFollowEmpty =>
      'No suggestions yet. You can find people later in \"Find friends\".';

  @override
  String get onbFinish => 'Get started';

  @override
  String get onbInterestsTitle => 'What are you into?';

  @override
  String get onbInterestsSubtitle =>
      'Pick the topics you want to see. We use this to suggest people and content.';

  @override
  String onbInterestsCount(int count) {
    return '$count selected';
  }

  @override
  String get videoPubTrim => 'Trim';

  @override
  String get videoPubCover => 'Cover';

  @override
  String get videoPubCoverAuto => 'Automatic cover';

  @override
  String get videoPubCoverCustom => 'Custom cover';

  @override
  String get videoPubCoverFrame => 'Video frame';

  @override
  String get videoPubCoverGallery => 'Gallery image';

  @override
  String get videoPubCoverRemove => 'Use automatic cover';

  @override
  String get videoPubCoverTitle => 'Choose cover';

  @override
  String get videoPubCoverFrameHint => 'Drag to choose the cover frame';

  @override
  String get videoPubCoverUse => 'Use this cover';

  @override
  String get videoPubCoverCrop => 'Adjust cover';

  @override
  String get videoPubCoverError =>
      'Could not create the cover. Try another frame or image.';

  @override
  String get videoPubStepVideo => 'Uploading video...';

  @override
  String get videoPubStepCover => 'Uploading cover...';

  @override
  String get videoPubStepPost => 'Publishing...';

  @override
  String get videoPubCoverUploadError =>
      'Failed to upload the cover. Check your connection and try again.';

  @override
  String get videoPubTrimPrepareError =>
      'Could not prepare the trimmed video. Please try again.';

  @override
  String get signupErrName => 'Enter your name (at least 2 letters).';

  @override
  String get signupErrEmail => 'Enter a valid email.';

  @override
  String get signupErrPassword => 'Password must be at least 8 characters.';

  @override
  String get signupErrTerms =>
      'You need to accept the Terms and Privacy Policy.';

  @override
  String get signupErrEmailTaken =>
      'This email already has an account. Sign in or reset your password.';

  @override
  String get signupSendingCode => 'Sending code…';

  @override
  String get codeTitle => 'Confirm your email';

  @override
  String codeSubtitle(String email) {
    return 'We sent a 6-digit code to\n$email';
  }

  @override
  String get codeVerifying => 'Verifying…';

  @override
  String codeInvalid(int count) {
    return 'Wrong code. $count attempts left.';
  }

  @override
  String get codeInvalidSimple => 'Wrong code.';

  @override
  String get codeExpired => 'The code expired. Request a new one.';

  @override
  String get codeTooMany => 'Too many attempts. Request a new code.';

  @override
  String get codeResend => 'Resend code';

  @override
  String codeResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get codeResent => 'We sent a new code.';

  @override
  String get codeChangeEmail => 'Change email';

  @override
  String get codeSpamHint =>
      'Didn\'t get it? Check your spam or promotions folder.';

  @override
  String get codeError => 'Couldn\'t send the code. Try again.';

  @override
  String get codeTooManyRequests =>
      'Too many attempts from this network. Try again in a few minutes.';

  @override
  String get settingsThemeAutoHint =>
      'Follows your phone\'s light/dark mode. If your phone switches automatically, it changes at sunset and sunrise.';

  @override
  String get battleYou => 'You';

  @override
  String get battleMuteOpponent => 'Mute opponent';

  @override
  String get battleUnmuteOpponent => 'Listen to opponent';

  @override
  String battleListenTo(String name) {
    return 'Listen to $name';
  }

  @override
  String get battleRematch => 'Request rematch';

  @override
  String get battleRematchSent => 'Rematch invite sent';

  @override
  String get battleClose => 'Close';

  @override
  String get battleFollowing => 'Following';

  @override
  String get battleLeaveTitle => 'Leave the battle?';

  @override
  String get battleLeaveConfirm => 'Leave';

  @override
  String get battleCancel => 'Cancel';

  @override
  String get battleLeave => 'Leave battle';

  @override
  String get battleActionLabel => 'Battle';

  @override
  String get battleActionActive => 'In battle';

  @override
  String get battleErrNetwork => 'No connection. Check your internet.';

  @override
  String get battleErrGeneric => 'Something went wrong. Please try again.';

  @override
  String battleErrCooldown(int seconds) {
    return 'Wait ${seconds}s before inviting this creator again.';
  }

  @override
  String get battleErrBlocked => 'You can\'t invite this creator.';

  @override
  String get battleErrBusy => 'This creator is busy in another battle.';

  @override
  String get battleErrExpired => 'This invite has expired.';

  @override
  String get battleErrAnswered => 'This invite was already answered.';

  @override
  String get battleErrNotEligible => 'You can\'t start battles yet.';

  @override
  String get battleErrSendInvite => 'Couldn\'t send the invite.';

  @override
  String get battleErrAccept => 'Couldn\'t accept the battle.';

  @override
  String get battleErrRematch => 'Couldn\'t request the rematch.';

  @override
  String get battleErrEnd => 'Couldn\'t leave the battle.';

  @override
  String battleInviteExpiresIn(int seconds) {
    return 'Expires in ${seconds}s';
  }

  @override
  String battleInviteAccepted(String name) {
    return '$name accepted! Get ready';
  }

  @override
  String battleInviteDeclined(String name) {
    return '$name declined the invite';
  }

  @override
  String battleInviteNoReply(String name) {
    return '$name didn\'t reply in time';
  }

  @override
  String get battleInviteExpired => 'The battle invite expired';

  @override
  String get battleInviteCancelled => 'The battle invite was cancelled';

  @override
  String get battleCancelledMsg => 'The battle was cancelled';

  @override
  String get battleInviteNoAnswer => 'No reply to the battle invite';

  @override
  String get battleInviteWait => 'Wait for the current invite or cancel it';

  @override
  String get battleOpponentFallback => 'The opponent';

  @override
  String get battleSomeCreator => 'A creator';

  @override
  String get battleRtcConnecting => 'Connecting to your opponent…';

  @override
  String get battleRtcFallback =>
      'No real-time link: the battle continues in normal mode.';

  @override
  String get battleOpponentCamera => 'Waiting for opponent\'s camera';

  @override
  String get battleStartTitle => 'Start Battle';

  @override
  String get battleSheetSubtitle => 'Live creators available now';

  @override
  String get battleSearchHint => 'Search live creator...';

  @override
  String get battleLoadCandidatesFailed => 'Couldn\'t load live creators';

  @override
  String get battleRetry => 'Try again';

  @override
  String battleNoCreatorQuery(String query) {
    return 'No creator available for \"$query\"';
  }

  @override
  String get battleNoCreator =>
      'No creator available for a battle right now.\nPull to refresh.';

  @override
  String battleInviteCreator(String name) {
    return 'Invite $name';
  }

  @override
  String get battleSelectCreator => 'Select a creator';

  @override
  String get battleLiveBadge => 'LIVE';

  @override
  String battleViewLive(String name) {
    return 'Watch $name\'s live';
  }

  @override
  String battleWaitingAccept(String name, int seconds) {
    return 'Waiting for $name to accept… ${seconds}s';
  }

  @override
  String get linkConnect => 'Connect';

  @override
  String get linkDisconnect => 'Disconnect';

  @override
  String get linkStartTitle => 'Connect with a creator';

  @override
  String linkInviteCreator(String name) {
    return 'Connect with $name';
  }

  @override
  String linkInviteReceived(String name) {
    return '$name wants to connect with you';
  }

  @override
  String get linkInviteWithBattle => 'With battle';

  @override
  String linkInviteAccepted(String name) {
    return '$name accepted the connection';
  }

  @override
  String get linkEnded => 'The connection ended';

  @override
  String get linkDisconnectTitle => 'Disconnect?';

  @override
  String linkDisconnectBody(String name) {
    return 'Your connection with $name will end. If a battle is in progress, you forfeit it.';
  }

  @override
  String get linkFollowAction => '+ Follow';

  @override
  String get linkErrDisconnect => 'Couldn\'t disconnect.';

  @override
  String get linkErrInvite => 'Couldn\'t send the connection invite.';

  @override
  String get linkErrAccept => 'Couldn\'t accept the connection.';

  @override
  String battleFlashChallenge(int count, String gift, String time) {
    return 'Send $count $gift · $time';
  }

  @override
  String battleFlashProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String battleFlashBoost(String mult, String time) {
    return '${mult}X active · $time';
  }

  @override
  String get battleSealWin => 'VICTORY';

  @override
  String get battleSealLose => 'DEFEAT';

  @override
  String get battleSealDraw => 'DRAW';

  @override
  String get battleEndLabel => 'END';

  @override
  String battleMvpPill(String name, String score) {
    return 'MVP $name · $score';
  }

  @override
  String get battleRuleHint => 'Send gifts to score';

  @override
  String get viewLiveAction => 'Watch live';

  @override
  String eventPageGiftsWorth(String mult) {
    return 'Gifts are worth $mult points';
  }

  @override
  String eventPageEndsIn(String time) {
    return 'Ends in $time';
  }

  @override
  String get eventPageYourPosition => 'Your position';

  @override
  String eventPageRankPoints(int rank, String points) {
    return '#$rank · $points pts';
  }

  @override
  String eventPageToTop10(String points) {
    return '$points to reach the top 10';
  }

  @override
  String get eventPageInTop10 => 'You are in the top 10';

  @override
  String get eventPageNoRank => 'You haven\'t scored yet';

  @override
  String get eventPagePrizes => 'Prizes';

  @override
  String get eventPageRanking => 'Event ranking';

  @override
  String get eventPageSeeFull => 'See full ranking';

  @override
  String get eventPageGifts => 'Event gifts';

  @override
  String get eventPageSend => 'Send gift';

  @override
  String get eventPageHow => 'How it works';

  @override
  String eventPagePrizeRank(int from, int to) {
    return '$from–$to';
  }

  @override
  String eventPagePrizeOne(int rank) {
    return '$rank';
  }

  @override
  String get battleEndedTitle => 'BATTLE ENDED';

  @override
  String battleEndedLeft(String name) {
    return '$name left the battle';
  }

  @override
  String battleEndedLive(String name) {
    return '$name\'s live dropped';
  }

  @override
  String get battleEndedRtc => 'The connection dropped';

  @override
  String battleLeaveBodyStreak(int n) {
    return 'If you leave now, nobody wins and you lose your $n-win streak.';
  }

  @override
  String get battleLeaveBodyNoStreak => 'If you leave now, nobody wins.';

  @override
  String battleMutedLine(String name) {
    return 'You and your audience can\'t hear $name';
  }

  @override
  String battleMutedByLine(String name) {
    return '$name muted you';
  }

  @override
  String get battlePauseUnavailable =>
      'Pause isn\'t available during a connection or battle';

  @override
  String get battleEndedLeftAnon => 'A creator left the battle';

  @override
  String get battleEndedLiveAnon => 'A creator\'s live dropped';

  @override
  String get battleNarrStart => 'The battle is on! Every gift counts';

  @override
  String battleNarrLeadOwn(String team) {
    return 'TURNAROUND! $team took the lead';
  }

  @override
  String battleNarrLeadOther(String team) {
    return '$team took the lead. Time to turn it around!';
  }

  @override
  String battleNarrMomentum(String team) {
    return '$team is on fire';
  }

  @override
  String battleNarrFlashStart(String pontos, String nome, String tempo) {
    return 'Flash challenge: send $pontos $nome in $tempo';
  }

  @override
  String battleNarrFlashDone(String mult, String tempo) {
    return 'Challenge done! $mult for $tempo';
  }

  @override
  String battleNarrFinal10(String mult) {
    return 'Last 10 seconds! Every gift is worth $mult';
  }

  @override
  String battleNarrVictory(String team) {
    return '$team WINS!';
  }

  @override
  String battleNarrDefeat(String team) {
    return 'It\'s over! $team won this time';
  }

  @override
  String get battleNarrDraw => 'DRAW!';

  @override
  String get battleNarrEnded => 'Battle ended';

  @override
  String get agencyTitle => 'My agency';

  @override
  String agencyPendingInvites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invites',
      one: '1 invite',
    );
    return '$_temp0';
  }

  @override
  String get agencyEmptyBody =>
      'Agencies help creators grow: they follow your results, organize events and support your live routine.';

  @override
  String get agencyInfoEarningsBody =>
      'Brawe keeps paying your earnings directly to you. The agency commission is paid by Brawe and never deducted from you.';

  @override
  String get agencyInfoOneBody =>
      'You can only be in one agency. When you accept an invite, the other pending ones are cancelled.';

  @override
  String get agencyOpenBody =>
      'Agencies can find you in the creators directory and send invites. You decide whether to accept.';

  @override
  String get agencyInvitesTitle => 'Pending invites';

  @override
  String get agencyInviteTitle => 'Agency invite';

  @override
  String agencyContractMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String agencyContractOf(String duration) {
    return '$duration contract';
  }

  @override
  String get agencyContractLength => 'Contract length';

  @override
  String get agencyInvitedByTitle => 'Invited by';

  @override
  String get agencyRoleOwner => 'Agency owner';

  @override
  String get agencyRoleManager => 'Agency manager (recruiter)';

  @override
  String get agencyRoleAnalyst => 'Agency team';

  @override
  String get agencyRoleUnknown => 'Agency representative';

  @override
  String agencyInvitedOn(String date) {
    return 'Invite sent on $date';
  }

  @override
  String get agencyMessageTitle => 'Message from the agency';

  @override
  String get agencyWhatChangesTitle => 'What changes for you';

  @override
  String get agencyTermsTitle => 'Terms and conditions';

  @override
  String agencyTermsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get agencyTermsStandard => 'Brawe standard terms';

  @override
  String get agencyTermsAddendum => 'Agency addendum';

  @override
  String get agencyTermsEmpty => 'Terms unavailable right now.';

  @override
  String agencyAcceptCheckbox(String version) {
    return 'I have read and accept the terms and conditions (version $version)';
  }

  @override
  String get agencyAcceptButton => 'Accept invite';

  @override
  String get agencyDeclineButton => 'Decline';

  @override
  String agencyAcceptConfirmTitle(String name) {
    return 'Join $name?';
  }

  @override
  String get agencyAcceptConfirmBody =>
      'Your link starts today. Before the contract ends, leaving is done by agreement with the agency.';

  @override
  String get agencyDeclineConfirmTitle => 'Decline invite?';

  @override
  String get agencyDeclineConfirmBody =>
      'Declining has no effect on your account. The agency will see that the invite was declined.';

  @override
  String agencyAcceptedSnack(String name) {
    return 'You are now part of $name';
  }

  @override
  String get agencyDeclinedSnack => 'Invite declined';

  @override
  String get agencyLeftSnack => 'You left the agency';

  @override
  String get agencyInviteUnavailable => 'This invite is no longer available.';

  @override
  String agencyCreatorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count creators',
      one: '1 creator',
    );
    return '$_temp0';
  }

  @override
  String agencyPartnerSince(String date) {
    return 'Partner since $date';
  }

  @override
  String get agencyTrialBadge => 'On trial';

  @override
  String get agencyContractTitle => 'Contract';

  @override
  String agencyContractPeriod(String start, String end) {
    return '$start to $end';
  }

  @override
  String agencyDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
      zero: 'Ends today',
    );
    return '$_temp0';
  }

  @override
  String agencyContractProgress(int percent) {
    return '$percent% of the contract';
  }

  @override
  String get agencyHours => 'Live hours';

  @override
  String get agencyDaysLive => 'Days with live';

  @override
  String get agencyDiamonds => 'Diamonds';

  @override
  String get agencyFollowers => 'Followers';

  @override
  String agencyRankValue(int rank, int total) {
    return '#$rank of $total';
  }

  @override
  String get agencyGuidelinesNotMet =>
      'Some goals are still missing this month';

  @override
  String agencyMissingHours(String value) {
    return '$value h to go';
  }

  @override
  String agencyMissingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days to go',
      one: '1 day to go',
    );
    return '$_temp0';
  }

  @override
  String get agencyNoIncidents => 'No incidents';

  @override
  String get agencyIncidentWarning => 'Warning';

  @override
  String get agencyIncidentSuspension => 'Suspension';

  @override
  String get agencyIncidentBan => 'Ban';

  @override
  String get agencyIncidentFraud => 'Fraud';

  @override
  String get agencyEventsHow => 'Go live during the event period to take part.';

  @override
  String get agencyEventLive => 'Live now';

  @override
  String get agencyEventScheduled => 'Upcoming';

  @override
  String get agencyEventEnded => 'Ended';

  @override
  String agencyEventMultiplier(String value) {
    return 'Multiplier x$value';
  }

  @override
  String get agencyLeaveTitle => 'Leave the agency';

  @override
  String get agencyLeaveAllowed =>
      'You can leave now, with no penalty. Your earnings and account do not change.';

  @override
  String get agencyLeaveButton => 'Leave the agency';

  @override
  String agencyLeaveConfirmTitle(String name) {
    return 'Leave $name?';
  }

  @override
  String get agencyLeaveConfirmBody =>
      'The link will end. This cannot be undone: to come back you will need a new invite.';

  @override
  String get agencyLeaveConfirmAction => 'Leave now';

  @override
  String get agencyExitRuleFree =>
      'When the contract ends you can leave freely, in the app.';

  @override
  String get agencyExitRuleAbuse =>
      'In case of abuse (fees, payments outside Brawe, pressure), ask Brawe for a review.';

  @override
  String get agencyLeaveSectionTitle => 'Leaving the agency';

  @override
  String agencyLeaveRequestBody(String date) {
    return 'Your contract runs until $date. To leave earlier, request it by agreement with the agency. If it does not answer in time, you are automatically free.';
  }

  @override
  String get agencyLeaveRequestBodyNoDate =>
      'To leave before the contract ends, request it by agreement with the agency. If it does not answer in time, you are automatically free.';

  @override
  String get agencyLeaveRequestButton => 'Ask the agency to release me';

  @override
  String get agencyLeaveRequestSheetTitle => 'Request to leave';

  @override
  String get agencyLeaveRequestSheetBody =>
      'The agency receives your request and answers. If it approves, the link ends right away. If it does not answer in time, you are automatically free.';

  @override
  String get agencyLeaveReasonLabel => 'Reason';

  @override
  String get agencyLeaveReasonHint => 'Tell the agency why you want to leave';

  @override
  String get agencyLeaveRequestSend => 'Send request';

  @override
  String get agencyLeaveRequestSentSnack => 'Request sent to the agency.';

  @override
  String get agencyLeavePendingTitle => 'Leave request sent';

  @override
  String agencyLeavePendingSent(String date) {
    return 'Sent on $date. Waiting for the agency to answer.';
  }

  @override
  String agencyLeavePendingDue(String date) {
    return 'If the agency does not answer by $date, you are automatically free.';
  }

  @override
  String get agencyLeavePendingBrawe => 'Your request is under Brawe review.';

  @override
  String get agencyReviewPendingTitle => 'Brawe review requested';

  @override
  String get agencyLeaveCancel => 'Cancel request';

  @override
  String get agencyLeaveCancelledSnack => 'Request cancelled.';

  @override
  String get agencyLeaveDeclinedTitle => 'Request declined';

  @override
  String get agencyLeaveDeclinedBody =>
      'The agency did not approve your leaving for now.';

  @override
  String get agencyLeaveAgencyAnswer => 'Agency\'s answer';

  @override
  String agencyLeaveRetryAt(String date) {
    return 'You can ask again from $date.';
  }

  @override
  String get agencyReviewLink => 'Ask Brawe for a review';

  @override
  String get agencyReviewSheetTitle => 'Ask Brawe for a review';

  @override
  String get agencyReviewSheetBody =>
      'Use only in case of abuse. Brawe reviews it directly, without going through the agency, and may end the link.';

  @override
  String get agencyReviewCategoryLabel => 'What is happening?';

  @override
  String get agencyReviewCatMoney => 'The agency charges me money';

  @override
  String get agencyReviewCatOffplatform =>
      'They ask for payments outside Brawe';

  @override
  String get agencyReviewCatPressure => 'Pressure or harassment';

  @override
  String get agencyReviewCatSuspended => 'The agency was suspended or banned';

  @override
  String get agencyReviewCatOther => 'Something else';

  @override
  String get agencyReviewDetailLabel => 'Details';

  @override
  String get agencyReviewSend => 'Send to Brawe';

  @override
  String get agencyReviewSentSnack => 'Request sent. Brawe will review it.';

  @override
  String get agencyErrLeaveRequiresAgreement =>
      'Before the contract ends, ask the agency to release you.';

  @override
  String get agencyErrLeaveRequestOpen => 'You already have an open request.';

  @override
  String agencyErrLeaveCooldown(String date) {
    return 'You can ask again from $date.';
  }

  @override
  String get agencyErrLeaveCooldownNoDate =>
      'Please wait a bit before asking again.';

  @override
  String get agencyErrLeaveNotOpen =>
      'This request was already answered or cancelled.';

  @override
  String get agencyErrReasonTooLong => 'The text is over 500 characters.';

  @override
  String get agencyReasonMinHint => 'At least 10 characters';

  @override
  String get agencyErrReasonTooShort => 'Write at least 10 characters.';

  @override
  String get agencyErrReasonRequired => 'Write the reason.';

  @override
  String get agencyErrLeaveIsFree =>
      'The contract has ended: you can leave directly.';

  @override
  String get agencyLoadError => 'Could not load your agency';

  @override
  String get agencyErrTermsMismatch =>
      'The terms were updated. Read the current version and try again.';

  @override
  String agencyErrCannotLeaveYet(String date) {
    return 'You cannot leave yet. Available on $date.';
  }

  @override
  String get agencyErrCannotLeaveYetNoDate =>
      'You cannot leave the agency yet.';

  @override
  String get agencyErrAlreadyInAgency => 'You are already in an agency.';

  @override
  String get agencyErrNotApproved => 'This agency is not available right now.';

  @override
  String get agencyErrNotEligible => 'Your creator profile is not active.';

  @override
  String get agencyErrNotFound => 'Invite not found.';

  @override
  String get agencyErrNotInAgency => 'You are not in an agency.';

  @override
  String get agencyErrNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get agencyErrGeneric => 'Something went wrong. Please try again.';

  @override
  String get agencyChatInvitedYou => 'invited you to the agency';

  @override
  String get agencyChatInviteSent => 'Invite sent to the creator';

  @override
  String get agencyChatOpen => 'Open invite';

  @override
  String get agencyChatPreview => 'Agency invite';

  @override
  String get creatorPanelTabHome => 'Home';

  @override
  String get creatorPanelTabPerformance => 'Performance';

  @override
  String get creatorPanelTabAgency => 'Agency';

  @override
  String get creatorPanelTabBenefits => 'Benefits';

  @override
  String get creatorPanelEarnings30 => 'Earnings, last 30 days';

  @override
  String get creatorPanelNextLevel => 'Next level';

  @override
  String get creatorPanelAgenciesRow => 'Agencies';

  @override
  String get creatorPanelAgenciesOpen => 'Open to invitations';

  @override
  String get creatorPanelHowItWorks => 'How it works';

  @override
  String get creatorPanelHowTitle => 'How agencies work';

  @override
  String get creatorPanelAnalyticsTitle => 'Full analytics';

  @override
  String get creatorPanelAnalyticsBody =>
      'Earnings, audience, followers and lives';

  @override
  String get creatorPanelProfileFallback => 'Creator';

  @override
  String get creatorPanelOpenError => 'Could not save. Try again.';

  @override
  String agencySince(String date) {
    return 'With the agency since $date';
  }

  @override
  String get agencyTalk => 'Message';

  @override
  String get agencyTalkError => 'Could not open the conversation.';

  @override
  String get agencySubSummary => 'Summary';

  @override
  String get agencySubGoals => 'Goals';

  @override
  String get agencySubEvents => 'Events';

  @override
  String get agencySubContract => 'Contract';

  @override
  String get agencyPeriodThisMonth => 'This month';

  @override
  String get agencyPeriodLabel => 'Period';

  @override
  String agencyRankUp(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Up $n places',
      one: 'Up 1 place',
    );
    return '$_temp0';
  }

  @override
  String agencyRankDown(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Down $n places',
      one: 'Down 1 place',
    );
    return '$_temp0';
  }

  @override
  String get agencyRankSame => 'Same place as last month';

  @override
  String get agencyPositionLabel => 'Place in the agency';

  @override
  String get agencyMonthGoalTitle => 'Monthly goal';

  @override
  String agencyMonthGoalPercent(String percent) {
    return '$percent% of the goal';
  }

  @override
  String get agencyMonthGoalMet => 'Goal reached';

  @override
  String get agencyMonthGoalNone => 'No goal set for this month';

  @override
  String get agencyChartTitle => 'Last 6 months';

  @override
  String get agencyChartEmpty => 'No data in recent months';

  @override
  String get agencyPerfError => 'Could not load performance';

  @override
  String get agencyGoalDone => 'Goal reached';

  @override
  String agencyGoalHoursValue(String have, String need) {
    return '$have of $need h';
  }

  @override
  String agencyGoalDaysValue(String have, String need) {
    return '$have of $need days';
  }

  @override
  String get agencyIncFilterMonth => 'This month';

  @override
  String get agencyIncFilter90 => 'Last 90 days';

  @override
  String agencyIncidentPoints(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String get agencyEventsFilterUpcoming => 'Upcoming';

  @override
  String get agencyEventsFilterLive => 'In progress';

  @override
  String get agencyEventsFilterEnded => 'Ended';

  @override
  String get agencyEventsEmptyUpcoming => 'No upcoming events.';

  @override
  String get agencyEventsEmptyLive => 'No events in progress right now.';

  @override
  String get agencyEventsEmptyEnded => 'No ended events.';

  @override
  String get agencyContractViewTerms => 'View terms';

  @override
  String get agencyContractUnknown => 'Contract with no end date';

  @override
  String get agencyLeaveRequestConfirmTitle => 'Send leave request?';

  @override
  String get agencyLeaveRequestConfirmBody =>
      'The agency has to approve it. If it does not answer in time, you are automatically free.';

  @override
  String get agencyReviewConfirmTitle => 'Ask Brawe to review?';

  @override
  String get agencyReviewConfirmBody =>
      'Use only in case of abuse. Brawe reviews it directly, without the agency.';

  @override
  String agencyLeaveSentOn(String date) {
    return 'Sent on $date';
  }

  @override
  String agencyInvitesBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count agency invitations',
      one: 'You have 1 agency invitation',
    );
    return '$_temp0';
  }

  @override
  String get agencyInvitesView => 'View';

  @override
  String agencyInviteRowBy(String name, String role) {
    return '$name · $role';
  }

  @override
  String get agencyInvitesEmpty => 'No pending invitations.';

  @override
  String get agencyPerkEarnings => 'Earnings paid by Brawe';

  @override
  String get agencyPerkNoCharges => 'No charges';

  @override
  String get agencyPerkAccount => 'You keep your account';

  @override
  String get agencyPerkExit =>
      'Leave at contract end or by agreement; if the agency does not answer in time, you are free';

  @override
  String get agencyTermsRead => 'Read full terms';

  @override
  String get agencyTermsExpand => 'Terms and conditions';

  @override
  String get agencyIncidentsTitleShort => 'Incidents';

  @override
  String get creatorDashWeekSameShort => 'Same';

  @override
  String get agencyAcceptedLabel => 'Accepted on';

  @override
  String get agencyExitRuleAgreement =>
      'Before the end, leaving is by agreement with the agency. If it does not answer in time (15 days), you are free and can join another agency.';

  @override
  String get creatorApplyBack => 'Back';

  @override
  String get creatorApplyNext => 'Continue';

  @override
  String get creatorApplyAsAccount => 'We will use your Brawe account details.';

  @override
  String get creatorApplyStepContent => 'Your content';

  @override
  String get creatorApplyStepNetwork => 'Your network';

  @override
  String get creatorApplyStepAbout => 'About you';

  @override
  String creatorApplyStepOf(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get creatorApplyPlatformLabel => 'Main network';

  @override
  String get creatorApplyHandleLabel => 'Your username on that network';

  @override
  String get creatorApplyHandleWhy =>
      'We need your profile on a social network to review your content and audience. Only the approval team sees it.';

  @override
  String get creatorApplyErrHandle =>
      'Use only letters, numbers, dot, hyphen or underscore (min. 2)';

  @override
  String creatorApplyErrMotivation(int min) {
    return 'Write at least $min characters';
  }

  @override
  String get creatorApplyErrFollowersMin =>
      'Enter how many followers you have (minimum 1)';

  @override
  String get editProfileCreatorBadgeTitle => 'Show creator badge';

  @override
  String get editProfileCreatorBadgeHint =>
      'Shows the Creator Network badge on your profile.';

  @override
  String get editProfileCreatorBadgeSaveFailed =>
      'Could not save badge visibility.';

  @override
  String get videoPubSound => 'Sound';

  @override
  String videoPubCoverAt(String time) {
    return 'Cover at $time';
  }

  @override
  String get videoUpQueued => 'Queued…';

  @override
  String videoUpUploading(int percent) {
    return 'Publishing… $percent%';
  }

  @override
  String get videoUpProcessing => 'Processing…';

  @override
  String get videoUpFailed => 'Upload failed';

  @override
  String get videoUpRetry => 'Try again';

  @override
  String get videoUpDone => 'Video published';

  @override
  String get videoUpView => 'View';

  @override
  String get videoUpCancel => 'Cancel upload';

  @override
  String get videoUpDismiss => 'Dismiss';

  @override
  String get chatSystemReadOnlyNote => 'Official Brawe messages';

  @override
  String get chatSystemOfficialLabel => 'Official account';

  @override
  String navChatUnreadSemantics(int count) {
    return 'Chat, $count unread conversations';
  }

  @override
  String get gifSearchHint => 'Search GIFs';

  @override
  String get gifClearSearch => 'Clear search';

  @override
  String get gifPoweredBy => 'Powered by GIPHY';

  @override
  String get gifUnavailable => 'GIFs are unavailable right now';

  @override
  String get gifErrorGeneric => 'Couldn\'t load GIFs.';

  @override
  String get gifRetry => 'Try again';

  @override
  String get gifEmptyTitle => 'No GIFs found';

  @override
  String get gifEmptyHint => 'Try another word.';

  @override
  String get gifSemantics => 'GIF';

  @override
  String get gifTapToPause => 'Tap to pause';

  @override
  String get gifTapToPlay => 'Tap to play';

  @override
  String get gifButtonSemantics => 'Send a GIF';

  @override
  String get notifFilterLikes => 'Likes';

  @override
  String get notifFilterComments => 'Comments';

  @override
  String get notifFilterFollowers => 'Followers';

  @override
  String get notifFilterMentions => 'Mentions';

  @override
  String get notifFilterBrawe => 'Brawe';

  @override
  String notifActorsTwo(String a, String b) {
    return '$a and $b';
  }

  @override
  String notifActorsThree(String a, String b, String c) {
    return '$a, $b and $c';
  }

  @override
  String notifActorsMore(String a, String b, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'others',
      one: 'other',
    );
    return '$a, $b and $n $_temp0';
  }

  @override
  String notifVerbLike(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'liked your post',
      one: 'liked your post',
    );
    return '$_temp0';
  }

  @override
  String notifVerbComment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'commented on your post',
      one: 'commented on your post',
    );
    return '$_temp0';
  }

  @override
  String notifVerbReply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'replied to your comment',
      one: 'replied to your comment',
    );
    return '$_temp0';
  }

  @override
  String notifVerbFollow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'started following you',
      one: 'started following you',
    );
    return '$_temp0';
  }

  @override
  String notifVerbGift(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sent gifts in your live',
      one: 'sent gifts in your live',
    );
    return '$_temp0';
  }

  @override
  String notifVerbMention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mentioned you in comments',
      one: 'mentioned you in a comment',
    );
    return '$_temp0';
  }

  @override
  String notifVerbStoryReaction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'reacted to your story',
      one: 'reacted to your story',
    );
    return '$_temp0';
  }

  @override
  String notifGiftDiamonds(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '($value diamonds)',
      one: '($value diamond)',
    );
    return '$_temp0';
  }

  @override
  String get notifNewFollowersTitle => 'New followers';

  @override
  String get notifNewFollowersEmpty => 'No new followers to show';

  @override
  String get notifUnreadLabel => 'Unread';

  @override
  String get storyGiftSend => 'Send';

  @override
  String storyGiftConfirmTitle(String gift, String price) {
    return 'Send $gift for $price?';
  }

  @override
  String storyGiftBalance(String balance) {
    return 'Balance: $balance';
  }

  @override
  String storyUpUploading(int percent) {
    return 'Posting story… $percent%';
  }

  @override
  String get storyUpProcessing => 'Posting story…';

  @override
  String get storyUpDone => 'Story posted';

  @override
  String get storyUpFailed => 'Failed to post the story';

  @override
  String get sessionEndedMessage =>
      'Your session was ended. Please sign in again.';

  @override
  String get stepUpTitle => 'Confirm it\'s you';

  @override
  String stepUpSubtitle(String email) {
    return 'We sent a code to $email';
  }

  @override
  String get stepUpHint =>
      'We noticed a sign-in from a new device. Enter the code to continue.';

  @override
  String get stepUpBack => 'Back to sign in';

  @override
  String stepUpTooMany(String time) {
    return 'Too many attempts. Try again in $time.';
  }

  @override
  String get secTitle => 'Security';

  @override
  String get secSettingsEntrySub =>
      'Connected devices, sign-in history and account protection';

  @override
  String get secTabDevices => 'Devices';

  @override
  String get secTabHistory => 'History';

  @override
  String get secTabProtect => 'Protection';

  @override
  String get secDevicesTitle => 'Connected devices';

  @override
  String get secDevicesSubtitle =>
      'These devices are signed in to your account.';

  @override
  String get secThisDevice => 'This device';

  @override
  String get secActiveNow => 'Active now';

  @override
  String secLastActive(String time) {
    return 'Active $time';
  }

  @override
  String secTimeMinutes(int n) {
    return '$n min ago';
  }

  @override
  String secTimeHours(int n) {
    return '$n h ago';
  }

  @override
  String secTimeDays(int n) {
    return '$n d ago';
  }

  @override
  String get secEndSession => 'End session';

  @override
  String get secEndSessionTitle => 'End the session on this device?';

  @override
  String secEndSessionBody(String device) {
    return '$device will be signed out and will need to sign in again.';
  }

  @override
  String get secEndedOk => 'Session ended.';

  @override
  String get secSignOutOthers => 'Sign out of all other devices';

  @override
  String get secSignOutOthersTitle => 'Sign out of other devices?';

  @override
  String get secSignOutOthersBody =>
      'Every device except this one will be signed out.';

  @override
  String get secSignedOutOthersOk => 'Other devices were signed out.';

  @override
  String get secNoOtherDevices => 'No other devices connected.';

  @override
  String get secDevicesEmpty => 'No active sessions found.';

  @override
  String get secLoadError => 'Could not load right now.';

  @override
  String get secUnavailable =>
      'This feature is not available yet. Please try again soon.';

  @override
  String get secActionError => 'Could not complete. Please try again.';

  @override
  String get secClientApp => 'Brawe app';

  @override
  String get secClientPartners => 'Brawe Partners';

  @override
  String get secClientWeb => 'Browser';

  @override
  String secAppVersion(String v) {
    return 'version $v';
  }

  @override
  String get secUnknownDevice => 'Unknown device';

  @override
  String get secUnknownPlace => 'Unknown location';

  @override
  String get secHistoryTitle => 'Sign-in history';

  @override
  String get secFilterAll => 'All';

  @override
  String get secFilterLogins => 'Sign-ins';

  @override
  String get secFilterFailures => 'Failures';

  @override
  String get secFilterChanges => 'Changes';

  @override
  String get secHistoryEmpty => 'No events for this filter.';

  @override
  String get secLoadMore => 'Load more';

  @override
  String get secEvLogin => 'Sign-in';

  @override
  String get secEvLoginFailed => 'Sign-in attempt failed';

  @override
  String get secEvLoginBlocked => 'Sign-in blocked';

  @override
  String get secEvLogout => 'Signed out';

  @override
  String get secEvSessionRevoked => 'Session ended';

  @override
  String get secEvSessionsRevokedAll => 'Other devices signed out';

  @override
  String get secEvPasswordChanged => 'Password changed';

  @override
  String get secEvPasswordResetRequested => 'Password reset requested';

  @override
  String get secEvPasswordReset => 'Password reset';

  @override
  String get secEvQrLogin => 'QR code sign-in';

  @override
  String get secEvLoginCode => 'Code sign-in';

  @override
  String get secEvStepUpRequired => 'Verification requested';

  @override
  String get secEvStepUpPassed => 'Verification passed';

  @override
  String get secEvNewDeviceAlert => 'New device alert';

  @override
  String get secEvUnknown => 'Security event';

  @override
  String get secProtectTitle => 'Don\'t recognize a sign-in?';

  @override
  String get secProtectBody =>
      'If something looks off, protect your account now: we sign out every other device and you set a new password.';

  @override
  String get secProtectButton => 'Protect my account';

  @override
  String get secProtectSheetTitle => 'Protect your account';

  @override
  String get secProtectSheetIntro => 'We will do two things now:';

  @override
  String get secProtectStep1 =>
      'Sign out of every other device. You stay signed in here.';

  @override
  String get secProtectStep2 =>
      'Ask you to create a new password. This step is required.';

  @override
  String get secProtectConfirm => 'Protect now';

  @override
  String get secCancel => 'Cancel';

  @override
  String get secRetry => 'Try again';

  @override
  String get secProtectError =>
      'Could not protect the account. Please try again.';

  @override
  String get secChangePasswordSub => 'Choose a new, strong password';

  @override
  String get secPasswordRequired =>
      'For your security, set a new password to continue.';

  @override
  String get secGeoAttribution => 'IP Geolocation by DB-IP';

  @override
  String get secSettingsEntry => 'Security';

  @override
  String get payoutBalanceAvailable => 'Available to withdraw';

  @override
  String payoutBalanceApprox(String value) {
    return 'About $value';
  }

  @override
  String get payoutBalanceNoRate =>
      'Value in local currency unavailable right now';

  @override
  String get payoutBalanceHolding => 'Awaiting release';

  @override
  String get payoutBalanceInProgress => 'Being withdrawn';

  @override
  String get payoutBalanceWithdrawn => 'Withdrawn';

  @override
  String payoutBalanceReleaseNote(String date, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return 'Each gift is reviewed for $_temp0. Next release: $date.';
  }

  @override
  String get payoutBalanceWithdraw => 'Withdraw';

  @override
  String get payoutBalanceAddAccountFirst => 'Add an account to withdraw';

  @override
  String payoutBalanceMinimum(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days business days',
      one: '$days business day',
    );
    return 'Minimum withdrawal of $amount. Paid within $_temp0.';
  }

  @override
  String get payoutBalanceHowTitle => 'How we got this amount';

  @override
  String get payoutBalanceReceived => 'Received in gifts';

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
    return 'Other $value';
  }

  @override
  String payoutBalanceHoldingHint(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return 'Each gift is reviewed for $_temp0 before release.';
  }

  @override
  String get payoutBalanceInProgressHint => 'Requests awaiting payment.';

  @override
  String get payoutBalanceAvailableShort => 'Available';

  @override
  String get payoutSoonTitle => 'Withdrawals coming soon';

  @override
  String get payoutSoonSubtitle =>
      'Your diamonds are already adding up. We will let you know when withdrawals open.';

  @override
  String get payoutOpenTitle => 'Withdrawal in progress';

  @override
  String payoutOpenDiamonds(String diamonds) {
    return '$diamonds diamonds';
  }

  @override
  String payoutOpenRequestedNote(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days business days',
      one: '$days business day',
    );
    return 'We are reviewing your request. Payment goes out within $_temp0 after approval.';
  }

  @override
  String payoutOpenApprovedNote(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days business days',
      one: '$days business day',
    );
    return 'Request approved. Payment goes out within $_temp0.';
  }

  @override
  String payoutOpenRequestedAt(String date) {
    return 'Requested on $date';
  }

  @override
  String get payoutOpenCancelConfirm =>
      'Cancel this withdrawal? The diamonds return to your balance.';

  @override
  String get payoutOpenKeep => 'Keep it';

  @override
  String get payoutOpenCancelYes => 'Cancel withdrawal';

  @override
  String get payoutOpenCancel => 'Cancel withdrawal';

  @override
  String get payoutStatusRequested => 'Under review';

  @override
  String get payoutStatusApproved => 'Approved';

  @override
  String get payoutStatusPaid => 'Paid';

  @override
  String get payoutStatusRejected => 'Rejected';

  @override
  String get payoutStatusCanceled => 'Canceled';

  @override
  String get payoutAccountTitle => 'Payout account';

  @override
  String get payoutAccountStatusPendingReview => 'Being verified';

  @override
  String get payoutAccountStatusVerified => 'Verified';

  @override
  String get payoutAccountStatusRejected => 'Rejected';

  @override
  String get payoutAccountPendingNote =>
      'We verify the account on the first payment. You can already request a withdrawal.';

  @override
  String payoutAccountRejectedNote(String reason) {
    return 'Reason: $reason. Add another account to withdraw.';
  }

  @override
  String get payoutAccountNoReason => 'not provided';

  @override
  String get payoutAccountChange => 'Change account';

  @override
  String get payoutAccountEmpty =>
      'Add the account where you want to be paid. It must be in your own name.';

  @override
  String get payoutAccountAdd => 'Add account';

  @override
  String get payoutAccountFormTitle => 'Payout account';

  @override
  String get payoutAccountFormIntro =>
      'Tell us where to pay you. The account must be yours: full legal name and tax ID of the holder.';

  @override
  String get payoutAccountSelect => 'Select';

  @override
  String get payoutAccountOtherCountry => 'Other country';

  @override
  String get payoutAccountPaidInBrl =>
      'Paid in Brazilian reais (R\$) at the Central Bank PTAX rate.';

  @override
  String get payoutAccountPaidInUsd => 'Paid in US dollars (US\$).';

  @override
  String get payoutAccountDocBr => 'Holder CPF or CNPJ';

  @override
  String get payoutAccountDocOther => 'Holder tax ID';

  @override
  String get payoutAccountHolderTitle => 'Account holder';

  @override
  String get payoutAccountHolderHint =>
      'Must be the same person who creates the content on Brawe.';

  @override
  String get payoutAccountHolderNamePlaceholder =>
      'Full legal name, as on your ID';

  @override
  String get payoutAccountSecurityNote =>
      'Your bank details are stored encrypted and only shown masked. We will email you a security notice when they change.';

  @override
  String get payoutAccountReviewNote =>
      'The account stays under verification and Brawe checks it on the first payment.';

  @override
  String get payoutAccountSave => 'Save account';

  @override
  String get payoutFieldsCountry => 'Account country';

  @override
  String get payoutFieldsMethod => 'Payout method';

  @override
  String get payoutFieldsHolderName => 'Holder full name';

  @override
  String get payoutFieldsHolderTaxId => 'Holder tax ID';

  @override
  String get payoutFieldsKeyType => 'Pix key type';

  @override
  String get payoutFieldsKey => 'Pix key';

  @override
  String get payoutFieldsBankCode => 'Bank code';

  @override
  String get payoutFieldsBranch => 'Branch';

  @override
  String get payoutFieldsAccount => 'Account';

  @override
  String get payoutFieldsAccountDigit => 'Account digit';

  @override
  String get payoutFieldsIban => 'IBAN';

  @override
  String get payoutFieldsRoutingNumber => 'Routing number (ABA)';

  @override
  String get payoutFieldsAccountNumber => 'Account number';

  @override
  String get payoutFieldsAccountType => 'Account type';

  @override
  String get payoutFieldsSwift => 'SWIFT/BIC';

  @override
  String get payoutFieldsBankName => 'Bank name';

  @override
  String get payoutFieldsBankAddress => 'Bank address';

  @override
  String get payoutFieldsTaxRegime => 'Company tax regime';

  @override
  String get payoutMethodsPix => 'Pix';

  @override
  String get payoutMethodsBankBr => 'Bank account';

  @override
  String get payoutMethodsIban => 'IBAN';

  @override
  String get payoutMethodsUsAch => 'ACH (US)';

  @override
  String get payoutMethodsSwift => 'SWIFT transfer';

  @override
  String get payoutPixKeyTypesCpf => 'CPF';

  @override
  String get payoutPixKeyTypesCnpj => 'CNPJ';

  @override
  String get payoutPixKeyTypesEmail => 'Email';

  @override
  String get payoutPixKeyTypesPhone => 'Mobile phone';

  @override
  String get payoutPixKeyTypesRandom => 'Random key';

  @override
  String get payoutAccountTypesChecking => 'Checking';

  @override
  String get payoutAccountTypesSavings => 'Savings';

  @override
  String get payoutKeyPlaceholderCpf => '000.000.000-00';

  @override
  String get payoutKeyPlaceholderCnpj => '00.000.000/0000-00';

  @override
  String get payoutKeyPlaceholderEmail => 'you@email.com';

  @override
  String get payoutKeyPlaceholderPhone => '(11) 91234-5678';

  @override
  String get payoutKeyPlaceholderRandom => 'Random key';

  @override
  String get payoutKeyPlaceholderNone => 'Pix key';

  @override
  String get payoutHistoryTitle => 'Withdrawal history';

  @override
  String get payoutHistoryEmpty => 'You have not made any withdrawals yet.';

  @override
  String payoutHistoryRejectedNote(String reason) {
    return 'Reason: $reason. The diamonds returned to your balance.';
  }

  @override
  String payoutHistoryReference(String ref) {
    return 'Receipt: $ref';
  }

  @override
  String payoutHistoryTotalReceived(String amount) {
    return 'Total received so far: $amount';
  }

  @override
  String get payoutWithdrawTitle => 'Withdraw';

  @override
  String payoutWithdrawStepOf(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get payoutWithdrawAmountTitle => 'How much do you want to withdraw?';

  @override
  String payoutWithdrawAmountSubtitle(String available) {
    return 'You have $available diamonds available.';
  }

  @override
  String get payoutWithdrawDiamondsLabel => 'Diamonds';

  @override
  String get payoutWithdrawAll => 'All';

  @override
  String payoutWithdrawMinHint(String amount, String diamonds) {
    return 'Minimum of $diamonds diamonds ($amount).';
  }

  @override
  String get payoutWithdrawTypeToQuote =>
      'Enter an amount to see what you will receive.';

  @override
  String get payoutWithdrawCalculating => 'Calculating…';

  @override
  String get payoutWithdrawYouReceive => 'You receive';

  @override
  String payoutWithdrawAfterRetentions(String gross, String tax) {
    return '$gross minus $tax in withholdings';
  }

  @override
  String get payoutWithdrawContinue => 'Continue';

  @override
  String get payoutWithdrawReviewTitle => 'Review your withdrawal';

  @override
  String get payoutWithdrawReviewSubtitle =>
      'See the full breakdown before confirming.';

  @override
  String get payoutWithdrawDiamonds => 'Diamonds';

  @override
  String payoutWithdrawPtax(String date) {
    return 'PTAX rate of $date';
  }

  @override
  String get payoutWithdrawValueUsd => 'Value in US dollars';

  @override
  String get payoutWithdrawGross => 'Gross amount';

  @override
  String get payoutWithdrawRetentions => 'Withholdings';

  @override
  String get payoutWithdrawNoRetentions => 'None';

  @override
  String get payoutWithdrawNet => 'You receive';

  @override
  String payoutWithdrawPtaxNote(String bulletin, String side) {
    return '$side rate from the $bulletin (Central Bank of Brazil), latest closing bulletin.';
  }

  @override
  String get payoutWithdrawPaidTo => 'Paid to';

  @override
  String payoutWithdrawSla(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days business days',
      one: '$days business day',
    );
    return 'Paid within $_temp0 after approval.';
  }

  @override
  String get payoutWithdrawFirstPaymentCheck =>
      'Since this is your first payment, Brawe checks the account before paying.';

  @override
  String get payoutWithdrawSendCode => 'Send code by email';

  @override
  String payoutWithdrawMonthPrior(String amount) {
    return 'Withholdings take into account the withdrawals you already made this month ($amount).';
  }

  @override
  String get payoutWithdrawRetentionsHelp =>
      'Withholdings required by law, paid by Brawe on your behalf. You receive the income statement.';

  @override
  String get payoutCodeTitle => 'Confirm with the code';

  @override
  String payoutCodeSubtitle(String email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String get payoutCodeLabel => '6-digit code';

  @override
  String get payoutCodeConfirm => 'Confirm withdrawal';

  @override
  String get payoutCodeResend => 'Resend code';

  @override
  String payoutCodeResendIn(String seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String payoutCodeResent(String email) {
    return 'New code sent to $email.';
  }

  @override
  String get payoutDoneTitle => 'Request sent';

  @override
  String payoutDoneSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days business days',
      one: '$days business day',
    );
    return 'Your withdrawal is under review. Payment goes out within $_temp0 after approval, and you can follow the status here.';
  }

  @override
  String get payoutDoneStatus => 'Status';

  @override
  String get payoutDoneBack => 'Back to Earnings';

  @override
  String get payoutErrorsNetwork =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get payoutErrorsDisabled => 'Withdrawals are not open yet.';

  @override
  String get payoutErrorsAccountRequired =>
      'Add your payout account to withdraw.';

  @override
  String get payoutErrorsAccountRejected =>
      'Your payout account was rejected. Add another account.';

  @override
  String get payoutErrorsInProgress =>
      'Wait for the withdrawal in progress to finish before changing the account.';

  @override
  String get payoutErrorsOpenLimit =>
      'You already have a withdrawal in progress. Wait for it to finish or cancel it.';

  @override
  String get payoutErrorsConflict =>
      'Your balance changed. Refresh the page and try again.';

  @override
  String get payoutErrorsFxUnavailable =>
      'The dollar rate is unavailable right now. Try again in a moment.';

  @override
  String get payoutErrorsNetNotPositive =>
      'After withholdings the net amount would be zero. Choose a larger amount.';

  @override
  String get payoutErrorsInvalidAmount => 'Enter a valid number of diamonds.';

  @override
  String payoutErrorsBelowMinimum(String amount, String diamonds) {
    return 'The minimum withdrawal is $diamonds diamonds ($amount).';
  }

  @override
  String payoutErrorsInsufficient(String available) {
    return 'Insufficient balance. You have $available diamonds available.';
  }

  @override
  String get payoutErrorsTooMany =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get payoutErrorsSendFailed =>
      'We couldn\'t send the email right now. Try again.';

  @override
  String payoutErrorsResendTooSoon(String seconds) {
    return 'Wait ${seconds}s to resend the code.';
  }

  @override
  String payoutErrorsCodeInvalid(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left attempts left',
      one: '$left attempt left',
    );
    return 'Wrong code. $_temp0.';
  }

  @override
  String get payoutErrorsCodeExpired =>
      'This code has expired. Tap “Resend code”.';

  @override
  String get payoutErrorsTooManyAttempts =>
      'Too many wrong attempts. Go back and request a new code.';

  @override
  String get payoutErrorsHolderMismatch =>
      'The Pix key (CPF/CNPJ) must belong to the account holder.';

  @override
  String get payoutErrorsInvalidMethod =>
      'This payout method is not available for the selected country.';

  @override
  String payoutErrorsInvalidField(String field) {
    return 'Check the “$field” field.';
  }

  @override
  String get payoutErrorsInvalidData => 'Check the information provided.';

  @override
  String get payoutErrorsGeneric =>
      'We couldn\'t finish that right now. Try again.';

  @override
  String get payoutErrorsFillAll =>
      'Fill in every field, with the holder\'s full name.';

  @override
  String get payoutErrorsPickMethod => 'Choose a payout method.';

  @override
  String get payoutTaxRegimesSimples => 'Simples Nacional or MEI';

  @override
  String get payoutTaxRegimesNormal => 'Lucro Presumido or Real';

  @override
  String get payoutHolderTypesPf => 'Individual';

  @override
  String get payoutHolderTypesPj => 'Company';

  @override
  String get payoutHolderTypesPjSimples => 'Company (Simples/MEI)';

  @override
  String get creatorPanelTabMonetization => 'Monetization';

  @override
  String get payoutOnlyGiftsNote =>
      'Only diamonds from gifts received in lives and stories can be withdrawn. Purchased Coins are for use inside Brawe and can\'t be withdrawn.';

  @override
  String get payoutLoadError => 'Couldn\'t load monetization.';

  @override
  String get payoutCancelTitle => 'Cancel withdrawal?';

  @override
  String get payoutDoneBackMonetization => 'Back to Monetization';

  @override
  String get payoutCountryBR => 'Brazil';

  @override
  String get payoutCountryUS => 'United States';

  @override
  String get payoutCountryPT => 'Portugal';

  @override
  String get payoutCountryAR => 'Argentina';

  @override
  String get payoutCountryCL => 'Chile';

  @override
  String get payoutCountryCO => 'Colombia';

  @override
  String get payoutCountryMX => 'Mexico';

  @override
  String get payoutCountryPE => 'Peru';

  @override
  String get payoutCountryUY => 'Uruguay';

  @override
  String get payoutCountryES => 'Spain';

  @override
  String get payoutSeeMonetization => 'Withdraw in Monetization';

  @override
  String get adsSponsored => 'Sponsored';

  @override
  String get adsWhy => 'Why am I seeing this?';

  @override
  String adsWhyAdvertiser(String name) {
    return 'This ad is from $name.';
  }

  @override
  String get adsWhyFooter =>
      'Ads on Brawe never use your messages and are never shown to people under 18.';

  @override
  String get adsHide => 'Hide this ad';

  @override
  String adsLessFrom(String name) {
    return 'See less from $name';
  }

  @override
  String get adsReport => 'Report ad';

  @override
  String get adsHidden => 'Ad hidden';

  @override
  String get adsReportThanks => 'Thanks. The Brawe team will review this ad.';

  @override
  String get adsReasonMisleading => 'Misleading or scam';

  @override
  String get adsReasonOffensive => 'Offensive';

  @override
  String get adsReasonAdult => 'Adult content';

  @override
  String get adsReasonProhibited => 'Prohibited product';

  @override
  String get adsReasonRepetitive => 'Shows too often';

  @override
  String get adsReasonOther => 'Other reason';

  @override
  String get adsSeeProfile => 'See profile';

  @override
  String get adsWatchLive => 'Watch live';

  @override
  String get postBoost => 'Boost';

  @override
  String get postBoostHint => 'Show it to more people';

  @override
  String get boostTitle => 'Boost post';

  @override
  String get boostStepAudience => 'Audience';

  @override
  String get boostStepBudget => 'Budget';

  @override
  String get boostStepReview => 'Review';

  @override
  String get boostAuto => 'Automatic';

  @override
  String get boostAutoHint =>
      'Brawe picks the people most likely to be interested, across Brazil.';

  @override
  String get boostCustom => 'Customize';

  @override
  String get boostCustomHint => 'Choose where, age and interests.';

  @override
  String get boostLocation => 'Location';

  @override
  String get boostAllBrazil => 'All of Brazil';

  @override
  String get boostPlaces => 'Cities';

  @override
  String get boostRadius => 'Radius';

  @override
  String get boostSearchCity => 'Search city';

  @override
  String get boostNoCity => 'No city found';

  @override
  String get boostUseMyLocation => 'Use my location';

  @override
  String get boostCenter => 'Radius center';

  @override
  String boostKm(String km) {
    return '$km km';
  }

  @override
  String get boostAge => 'Age';

  @override
  String boostAgeRange(String from, String to) {
    return '$from to $to years';
  }

  @override
  String get boostInterests => 'Interests';

  @override
  String get boostAnyInterest => 'Any interest';

  @override
  String get boostPerDay => 'Per day';

  @override
  String get boostDuration => 'Duration';

  @override
  String boostDaysN(String n) {
    return '$n days';
  }

  @override
  String get boostTotal => 'Total';

  @override
  String boostCoins(String n) {
    return '$n Coins';
  }

  @override
  String boostBalance(String n) {
    return 'Your balance: $n Coins';
  }

  @override
  String get boostInsufficient => 'Not enough balance for this budget.';

  @override
  String get boostTopUp => 'Top up Coins';

  @override
  String get boostEstimate => 'Estimated audience';

  @override
  String get boostNext => 'Continue';

  @override
  String boostPay(String n) {
    return 'Boost · $n Coins';
  }

  @override
  String get boostTerms =>
      'By boosting, you confirm the post follows Brawe ad rules. Anything not spent comes back to you.';

  @override
  String get boostDoneTitle => 'Your post is being boosted';

  @override
  String get boostDoneHint => 'Follow reach, clicks and spend in My ads.';

  @override
  String get boostSeeCampaigns => 'See my ads';

  @override
  String get boostError => 'Could not boost. Try again.';

  @override
  String boostCitiesInRadius(String n) {
    return '≈ $n cities in radius';
  }

  @override
  String get myAdsTitle => 'My ads';

  @override
  String get myAdsEmpty => 'You haven\'t boosted any post yet.';

  @override
  String get myAdsEmptyHint => 'Tap Boost on one of your posts to start.';

  @override
  String get myAdsStatusDraft => 'Draft';

  @override
  String get myAdsStatusReview => 'In review';

  @override
  String get myAdsStatusActive => 'Live';

  @override
  String get myAdsStatusPaused => 'Paused';

  @override
  String get myAdsStatusEnded => 'Ended';

  @override
  String get myAdsStatusRejected => 'Rejected';

  @override
  String get myAdsImpressions => 'Impressions';

  @override
  String get myAdsReach => 'Reach';

  @override
  String get myAdsClicks => 'Clicks';

  @override
  String get myAdsViews => 'Views';

  @override
  String get myAdsNewFollowers => 'New followers';

  @override
  String get myAdsProfileVisits => 'Profile visits';

  @override
  String get myAdsSpent => 'Spent';

  @override
  String myAdsOf(String total) {
    return 'of $total';
  }

  @override
  String myAdsEndsOn(String date) {
    return 'Ends on $date';
  }

  @override
  String get myAdsPause => 'Pause';

  @override
  String get myAdsResume => 'Resume';

  @override
  String get myAdsCancel => 'End';

  @override
  String get myAdsCancelConfirm =>
      'End the ad now? Coins not spent come back to you.';

  @override
  String get myAdsIncreaseDaily => 'Increase per day';

  @override
  String myAdsIncreaseCost(String days, String coins) {
    return '$days days left: $coins more Coins';
  }

  @override
  String get myAdsOnlyUp => 'The daily amount can only go up.';

  @override
  String get myAdsEditAudience => 'Edit audience';

  @override
  String get myAdsAudienceSaved => 'Audience updated';

  @override
  String get myAdsPausedByTeam => 'Paused by the Brawe team.';

  @override
  String get myAdsSave => 'Save';

  @override
  String get boostTapMap => 'Tap the map to move the center.';

  @override
  String get boostInterestsNarrow =>
      'Interests make the audience smaller. If reach is low, remove a few.';

  @override
  String get boostRetry => 'Try again';

  @override
  String get boostPerDayShort => 'per day';

  @override
  String get boostFinish => 'Done';

  @override
  String get myAdsAtMax => 'You\'re already at the maximum per day.';

  @override
  String get myAdsEntry => 'Ads and boosts';

  @override
  String get adsRepEmpty =>
      'Results show up here as soon as your ad starts running.';

  @override
  String get adsRepPeople => 'people';

  @override
  String get adsRepFrequency => 'Frequency';

  @override
  String get adsRepCtr => 'Click rate';

  @override
  String get adsRepCpm => 'Cost per thousand';

  @override
  String get adsRepOverTime => 'Over time';

  @override
  String get adsRepVideo => 'Video';

  @override
  String adsRepAvgWatch(String s) {
    return 'Avg. watch: $s s';
  }

  @override
  String get adsRepWatched25 => 'Watched 25%';

  @override
  String get adsRepWatched50 => 'Watched half';

  @override
  String get adsRepWatched100 => 'Watched to the end';

  @override
  String get adsRepAudience => 'Who saw it';

  @override
  String get adsRepAge => 'Age';

  @override
  String get adsRepCities => 'Cities';

  @override
  String get adsRepStates => 'States';

  @override
  String get adsRepRegions => 'Regions';

  @override
  String get adsRepInterests => 'Interests';

  @override
  String get adsRepOthers => 'Others';

  @override
  String get adsRepUnknown => 'Not provided';

  @override
  String get adsRepNoData => 'No data yet';

  @override
  String get adsRepPrivacy =>
      'Totals only. Small groups are counted as \"Others\" so no one can be identified.';

  @override
  String adsRepLoggedOut(String n) {
    return '$n people saw it while logged out';
  }

  @override
  String get adsRepHours => 'Best times';

  @override
  String adsRepBestHour(String h) {
    return 'Most seen at ${h}h';
  }

  @override
  String get adsRepWhere => 'Where it showed';

  @override
  String get adsRepPlatforms => 'Devices';

  @override
  String get adsRepPlForyou => 'For you';

  @override
  String get adsRepPlFollowing => 'Following';

  @override
  String get adsRepPlStories => 'Stories';

  @override
  String get adsRepPlLives => 'Lives';

  @override
  String get adsRepPlExplore => 'Explore';

  @override
  String get adsRepPlWeb => 'Website home';

  @override
  String get adsRepLive => 'Live';

  @override
  String get adsRepLiveFromAd => 'Joined from the ad';

  @override
  String get adsRepLivePeak => 'Peak viewers';

  @override
  String get adsRepLiveGifts => 'Gifts';

  @override
  String get adsRepLiveMinutes => 'Minutes watched';

  @override
  String get adsRepCoins => 'Coins';

  @override
  String get adsRepCoinsPaid => 'Paid';

  @override
  String get adsRepCoinsUsed => 'Used';

  @override
  String get adsRepCoinsRefunded => 'Refunded';

  @override
  String get adsRepChanges => 'Changes';

  @override
  String get adsRepChangeDaily => 'Daily amount';

  @override
  String get adsRepChangeTotal => 'Total budget';

  @override
  String get adsRepChangeEnd => 'End date';

  @override
  String get adsRepResults => 'Results';

  @override
  String get boostStepGoal => 'Goal';

  @override
  String get boostGoalTitle => 'What do you want from this boost?';

  @override
  String get boostGoalViews => 'More views';

  @override
  String get boostGoalViewsHint => 'Show your post to more people.';

  @override
  String get boostGoalFollowers => 'More followers';

  @override
  String get boostGoalFollowersHint =>
      'People who see it discover your profile and can follow you.';

  @override
  String get boostGoalProfile => 'Profile visits';

  @override
  String get boostGoalProfileHint => 'More people opening your profile.';

  @override
  String get boostGoalContacts => 'Get messages';

  @override
  String get boostGoalContactsHint => 'A button for people to talk to you.';

  @override
  String get boostContactVia => 'Where do you want to get messages?';

  @override
  String get boostContactChat => 'Brawe chat';

  @override
  String get boostContactChatHint =>
      'Conversations arrive in your Chat, right here in the app. Each message counts as a contact in the report.';

  @override
  String get boostContactWhatsapp => 'WhatsApp';

  @override
  String get boostContactWhatsappHint =>
      'The button opens your WhatsApp with a ready message. Each tap counts as a contact in the report.';

  @override
  String get boostWhatsappPhone => 'Your WhatsApp with area code';

  @override
  String get boostWhatsappMessage => 'Ready message';

  @override
  String get boostWhatsappMessageDefault =>
      'Hi! I saw your post on Brawe and want to know more.';

  @override
  String get boostPreview => 'Preview';

  @override
  String get boostPreviewHint =>
      'This is how your post shows in each place of the app. Swipe to see.';

  @override
  String get boostPlForYou => 'For you';

  @override
  String get boostPlFeed => 'Feed';

  @override
  String get boostPlStories => 'Stories';

  @override
  String get boostPlTiles => 'Lives and Explore';

  @override
  String get boostAlreadyTitle => 'This post is already being boosted';

  @override
  String get boostAlreadyHint =>
      'To reach more people, raise the daily amount or edit the audience of the existing campaign (made in the app or on the website).';

  @override
  String get boostSeeCampaign => 'See campaign';

  @override
  String get adsCtaMessage => 'Send message';

  @override
  String get adsCtaWhatsapp => 'Message on WhatsApp';

  @override
  String get myAdsKindBrand => 'Brand ad';

  @override
  String get myAdsKindBoost => 'Boost';

  @override
  String get myAdsLeadsChat =>
      'Messages from people who saw the ad arrive in your Chat.';

  @override
  String get myAdsLeadsWhatsapp =>
      'Contacts from people who saw the ad arrive on your WhatsApp.';

  @override
  String get myAdsOpenChat => 'Open chat';

  @override
  String get myAdsBrandEditOnWeb =>
      'Brand ad: creative and audience are edited in the ads panel, on a computer.';

  @override
  String get adsRepContacts => 'Contacts received';

  @override
  String get adsFollow => 'Follow';

  @override
  String get adsFollowingNow => 'Following';

  @override
  String get adsSeePost => 'See post';

  @override
  String get adsWatchVideo => 'Watch video';

  @override
  String get adsLearnMore => 'Learn more';

  @override
  String get settingsGroupPreferences => 'Preferences';

  @override
  String get settingsGroupHelp => 'Help';

  @override
  String get settingsGroupAbout => 'About';

  @override
  String artistProfSaveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String get artistProfRequired => 'Required';

  @override
  String get artistProfSectionIdentity => 'Artist identity';

  @override
  String get artistProfArtistName => 'Artist name';

  @override
  String get artistProfArtistNameHint => 'How you are known';

  @override
  String get artistProfBio => 'Artist bio';

  @override
  String get artistProfBioHint => 'Tell your music story...';

  @override
  String get artistProfSectionLocation => 'Location';

  @override
  String get artistProfCountry => 'Country';

  @override
  String get artistProfCountryHint => 'Select your country';

  @override
  String get artistProfCity => 'City';

  @override
  String get artistProfCityHint => 'Your city';

  @override
  String get artistProfLanguage => 'Native language';

  @override
  String get artistProfLanguageHint => 'Main language';

  @override
  String get artistProfSectionGenres => 'Music genres';

  @override
  String get artistProfGenresHint => 'Select up to 5 genres';

  @override
  String get artistProfSectionPlatforms => 'Streaming platforms';

  @override
  String get artistProfCountryBR => 'Brazil';

  @override
  String get artistProfCountryPT => 'Portugal';

  @override
  String get artistProfCountryUS => 'United States';

  @override
  String get artistProfCountryAR => 'Argentina';

  @override
  String get artistProfCountryMX => 'Mexico';

  @override
  String get artistProfCountryCO => 'Colombia';

  @override
  String get artistProfCountryCL => 'Chile';

  @override
  String get artistProfCountryPE => 'Peru';

  @override
  String get artistProfCountryUY => 'Uruguay';

  @override
  String get artistProfCountryPY => 'Paraguay';

  @override
  String get artistProfCountryBO => 'Bolivia';

  @override
  String get artistProfCountryEC => 'Ecuador';

  @override
  String get artistProfCountryVE => 'Venezuela';

  @override
  String get artistProfCountryES => 'Spain';

  @override
  String get artistProfCountryFR => 'France';

  @override
  String get artistProfCountryDE => 'Germany';

  @override
  String get artistProfCountryIT => 'Italy';

  @override
  String get artistProfCountryGB => 'United Kingdom';

  @override
  String get artistProfCountryJP => 'Japan';

  @override
  String get artistProfCountryKR => 'South Korea';

  @override
  String get artistProfCountryNG => 'Nigeria';

  @override
  String get artistProfCountryGH => 'Ghana';

  @override
  String get artistProfCountryZA => 'South Africa';

  @override
  String get artistProfCountryAO => 'Angola';

  @override
  String get artistProfCountryMZ => 'Mozambique';

  @override
  String get artistProfCountryCV => 'Cape Verde';

  @override
  String bizProfSaveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String get bizProfRequired => 'Required';

  @override
  String get bizProfSectionCompany => 'Company / Brand';

  @override
  String get bizProfCompanyName => 'Company or brand name';

  @override
  String get bizProfCompanyNameHint => 'E.g. My Company Inc.';

  @override
  String get bizProfAbout => 'About the company';

  @override
  String get bizProfAboutHint => 'Describe your company or brand...';

  @override
  String get bizProfSector => 'Industry';

  @override
  String get bizProfSectorHint => 'Select an industry';

  @override
  String get bizProfSectionLocation => 'Location';

  @override
  String get bizProfCountry => 'Country of operation';

  @override
  String get bizProfCountryHint => 'Select the country';

  @override
  String get bizProfCity => 'City';

  @override
  String get bizProfCityHint => 'Headquarters city';

  @override
  String get bizProfLanguage => 'Main language';

  @override
  String get bizProfLanguageHint => 'Operating language';

  @override
  String get bizProfSectionFiscal => 'Tax information';

  @override
  String get bizProfFiscalRow => 'Tax information and CNPJ';

  @override
  String get bizProfFiscalRowHint => 'Submit for verification';

  @override
  String get bizProfSectionLinks => 'Links';

  @override
  String get bizProfWebsite => 'Website';

  @override
  String get bizProfWebsiteHint => 'https://yourcompany.com';

  @override
  String get bizProfInstagramHint => '@yourcompany';

  @override
  String get bizProfWhatsappHint => '+55 11 99999-9999';

  @override
  String get bizProfSectorFashionBeauty => 'Fashion & Beauty';

  @override
  String get bizProfSectorTech => 'Technology';

  @override
  String get bizProfSectorFood => 'Food & Beverages';

  @override
  String get bizProfSectorEntertainment => 'Entertainment';

  @override
  String get bizProfSectorEducation => 'Education';

  @override
  String get bizProfSectorHealth => 'Health & Wellness';

  @override
  String get bizProfSectorFinance => 'Finance & Investments';

  @override
  String get bizProfSectorRetail => 'Retail & E-commerce';

  @override
  String get bizProfSectorMusic => 'Music & Audio';

  @override
  String get bizProfSectorGames => 'Games';

  @override
  String get bizProfSectorSports => 'Sports';

  @override
  String get bizProfSectorRealEstate => 'Real estate';

  @override
  String get bizProfSectorAgro => 'Agro & Sustainability';

  @override
  String get bizProfSectorServices => 'Professional services';

  @override
  String get bizProfSectorNgo => 'NGO & Social';

  @override
  String get bizProfSectorOther => 'Other';

  @override
  String get bizProfCountryBR => 'Brazil';

  @override
  String get bizProfCountryPT => 'Portugal';

  @override
  String get bizProfCountryUS => 'United States';

  @override
  String get bizProfCountryAR => 'Argentina';

  @override
  String get bizProfCountryMX => 'Mexico';

  @override
  String get bizProfCountryCO => 'Colombia';

  @override
  String get bizProfCountryCL => 'Chile';

  @override
  String get bizProfCountryES => 'Spain';

  @override
  String get bizProfCountryDE => 'Germany';

  @override
  String get bizProfCountryGB => 'United Kingdom';

  @override
  String get bizProfCountryAO => 'Angola';

  @override
  String get bizProfCountryMZ => 'Mozambique';

  @override
  String get acctTitle => 'Account type';

  @override
  String get acctPersonal => 'Personal';

  @override
  String get acctPersonalHint => 'To follow, watch, chat and post.';

  @override
  String get acctCreator => 'Creator';

  @override
  String get acctCreatorHint =>
      'For people who go live and create content to grow and earn.';

  @override
  String get acctArtist => 'Artist';

  @override
  String get acctArtistHint =>
      'Musicians, bands and DJs: an artist profile with your music links.';

  @override
  String get acctBusiness => 'Business';

  @override
  String get acctBusinessHint =>
      'Brands and businesses. Requires verified identity and an approved company ID.';

  @override
  String get acctFooter =>
      'You can switch between Personal, Creator and Artist anytime. Your posts, followers and Coins stay the same.';

  @override
  String acctConfirmTitle(String name) {
    return 'Switch to $name?';
  }

  @override
  String get acctConfirmBody =>
      'Your profile will show this account type. You can switch back later.';

  @override
  String get acctConfirmAction => 'Switch';

  @override
  String acctChanged(String name) {
    return 'Your account is now $name';
  }

  @override
  String get acctChangeFailed => 'Couldn\'t change the account type.';

  @override
  String get acctBusinessStepsTitle => 'To become a Business';

  @override
  String get acctBusinessStepsBody =>
      'To protect buyers and advertisers, business accounts go through two steps.';

  @override
  String get acctStepIdentity => 'Verify your identity';

  @override
  String get acctStepBusiness => 'Send company ID and tax data';

  @override
  String get acctStepIdentityAction => 'Verify identity';

  @override
  String get acctStepBusinessAction => 'Send company data';

  @override
  String get editProfileCreatorPanel => 'Creator dashboard';

  @override
  String get editProfileArtistPage => 'Artist profile';

  @override
  String get editProfileBusinessPage => 'Business profile';

  @override
  String get editProfileWebsite => 'Website';

  @override
  String get kycTitle => 'Verification';

  @override
  String get kycApproved => 'Verified';

  @override
  String get kycInReview => 'In review';

  @override
  String get kycRejected => 'Rejected';

  @override
  String get kycNotStarted => 'Not verified';

  @override
  String get kycLoadError => 'Couldn\'t load verification.';

  @override
  String get kycError => 'Something went wrong. Try again.';

  @override
  String get kycHeaderTitle => 'Verify your account';

  @override
  String get kycHeaderDone => 'Your account is verified';

  @override
  String get kycHeaderBody =>
      'Verified accounts get the blue badge, more trust from followers, and can become a Business.';

  @override
  String get kycIdentityCaption => 'Identity';

  @override
  String get kycIdentityRow => 'Verify identity';

  @override
  String get kycIdentityRowHint => 'Document + quick video';

  @override
  String get kycIdentityFooter =>
      'Takes about 2 minutes. Brazil: today\'s digital driver\'s license. Other countries: passport.';

  @override
  String kycRejectedReason(String reason) {
    return 'Rejected: $reason. You can send it again.';
  }

  @override
  String get kycBusinessCaption => 'Business';

  @override
  String get kycBusinessRow => 'Company data';

  @override
  String get kycBusinessRowHint => 'Company ID and tax data';

  @override
  String get kycBusinessFooter =>
      'Once the company ID is approved, your account becomes a Business.';

  @override
  String get kycBusinessLocked => 'Available after your identity is verified.';

  @override
  String get kycPrivacy =>
      'Your documents and video are encrypted, only the verification team sees them, and they are deleted as soon as the review ends.';

  @override
  String get kycStepDocument => 'Document';

  @override
  String get kycStepLiveness => 'Video';

  @override
  String get kycStepSend => 'Send';

  @override
  String get kycCountry => 'Document country';

  @override
  String get kycCountrySearch => 'Search country';

  @override
  String get kycCountryChoose => 'Choose country';

  @override
  String get kycDocument => 'Document';

  @override
  String get kycDocCnh => 'Digital driver\'s license (CNH)';

  @override
  String get kycDocCnhHint => 'PDF exported today in the CNH do Brasil app';

  @override
  String get kycDocPassport => 'Passport';

  @override
  String get kycDocPassportHint => 'Photo page, readable and not expired';

  @override
  String get kycCnhHowTo =>
      'In the CNH do Brasil app (gov.br): open your license, tap Share › Export and save the PDF. It must be generated today.';

  @override
  String get kycPassportHowTo =>
      'Send the page with your photo, without glare and with all four corners visible.';

  @override
  String get kycPickFile => 'Choose file';

  @override
  String get kycChangeFile => 'Tap to change';

  @override
  String get kycTakePhoto => 'Take a photo of the passport';

  @override
  String get kycLivenessIntro =>
      'Now a short video to show it\'s really you. The front camera opens and shows what to say.';

  @override
  String get kycTipLight => 'Stay in a well-lit place';

  @override
  String get kycTipFace => 'Face uncovered: no sunglasses, cap or mask';

  @override
  String get kycTipTurn =>
      'Slowly turn your face to one side and then the other';

  @override
  String get kycTipSpeak => 'Say out loud the text shown on screen';

  @override
  String get kycRecord => 'Record video';

  @override
  String get kycRecorded => 'Video recorded';

  @override
  String get kycRecordAgain => 'Tap to record again';

  @override
  String get kycReview => 'Review';

  @override
  String get kycConsent =>
      'I authorize Brawe to use this document and video only to verify my identity, under data protection law (LGPD).';

  @override
  String get kycSubmit => 'Send for review';

  @override
  String get kycSentTitle => 'Sent for review';

  @override
  String get kycSentBody =>
      'Our team reviews it within 2 business days. Once approved, the blue badge shows on your profile.';

  @override
  String get kycBizSentBody =>
      'Our team reviews it within 2 business days. Once approved, your account becomes a Business.';

  @override
  String get kycSay => 'Say out loud:';

  @override
  String kycScript(String name, String date, String time, String code) {
    return 'My name is $name. Today is $date, $time. Code $code.';
  }

  @override
  String get kycCamReady => 'Fit your face and tap to record';

  @override
  String get kycCamLook => 'Look at the camera';

  @override
  String get kycCamLeft => 'Slowly turn left';

  @override
  String get kycCamRight => 'Now to the right';

  @override
  String get kycCamSpeak => 'Say the text and tap to stop';

  @override
  String get kycCamError =>
      'Couldn\'t open the camera. Allow camera and microphone access in Settings.';

  @override
  String get kycTooShort => 'Record at least 5 seconds';

  @override
  String get kycBizCompany => 'Company';

  @override
  String get kycBizCnpjHint =>
      'Type the CNPJ: name and address come from the Federal Revenue.';

  @override
  String kycBizSituation(String status) {
    return 'Federal Revenue status: $status';
  }

  @override
  String get kycBizLegalName => 'Legal name';

  @override
  String get kycBizTradeName => 'Trade name';

  @override
  String get kycBizTax => 'Tax';

  @override
  String get kycBizRegime => 'Tax regime';

  @override
  String get kycRegimeSimples => 'Simples Nacional';

  @override
  String get kycRegimePresumido => 'Presumed profit';

  @override
  String get kycRegimeReal => 'Actual profit';

  @override
  String get kycBizIe => 'State registration';

  @override
  String get kycBizIeExempt => 'Exempt from state registration';

  @override
  String get kycBizAddress => 'Address';

  @override
  String get kycBizZip => 'ZIP code';

  @override
  String get kycBizStreet => 'Street';

  @override
  String get kycBizNumber => 'Number';

  @override
  String get kycBizDistrict => 'District';

  @override
  String get kycBizCity => 'City';

  @override
  String get kycBizCard => 'CNPJ card';

  @override
  String get kycBizCardHint =>
      'Download the registration proof from the Federal Revenue website (PDF) or send a clear photo.';

  @override
  String onbInterestsPickMin(String n) {
    return 'Pick at least $n';
  }

  @override
  String get onbAboutTitle => 'About you';

  @override
  String get onbAboutSubtitle =>
      'Helps us show people, lives and offers from your area.';

  @override
  String get onbGender => 'Gender';

  @override
  String get onbGenderFemale => 'Female';

  @override
  String get onbGenderMale => 'Male';

  @override
  String get onbGenderOther => 'Other';

  @override
  String get onbGenderUndisclosed => 'Prefer not to say';

  @override
  String get onbWhereYouLive => 'Where you live';

  @override
  String get onbCityHint => 'Your city';

  @override
  String get onbAboutPrivacy =>
      'We don\'t show your gender or city on your profile. We only use them to personalize what you see.';

  @override
  String get editProfileAbout => 'About you';

  @override
  String get boostGenderAll => 'Everyone';

  @override
  String get boostGenderFemale => 'Women';

  @override
  String get boostGenderMale => 'Men';

  @override
  String get adsRepGenderOther => 'Other / not said';

  @override
  String videoFormatsHintLimits(String duration, String size) {
    return 'MP4 · MOV · WebM   ·   up to $duration   ·   $size';
  }

  @override
  String videoIssueTooBig(String size, String max) {
    return 'This video is $size. The limit is $max. Pick a shorter video or trim it.';
  }

  @override
  String videoIssueTooLong(String duration, String max) {
    return 'This video is $duration long. The limit is $max. Trim it to publish.';
  }

  @override
  String get videoIssueUnsupported =>
      'This format isn\'t supported. Use an MP4, MOV or WebM video.';

  @override
  String get videoIssueCannotOpen =>
      'We couldn\'t open this video. It may be corrupted or still downloading from iCloud. Try another.';

  @override
  String get videoIssueTrim => 'Trim video';

  @override
  String get videoIssuePickOther => 'Pick another';

  @override
  String get videoUpDiscard => 'Discard';

  @override
  String get videoErrNoConnection =>
      'No internet connection. Your video is still saved: tap Try again when you\'re back online.';

  @override
  String get videoErrTimeout =>
      'The connection is slow and the upload took too long. Try again, preferably on Wi-Fi.';

  @override
  String videoErrTooLargeServer(String max) {
    return 'The video is over the $max limit. Pick a shorter video or trim it.';
  }

  @override
  String videoErrTooLongServer(String max) {
    return 'The video is longer than $max. Trim it and publish again.';
  }

  @override
  String get videoErrUnsupported =>
      'This video format isn\'t supported. Use MP4, MOV or WebM.';

  @override
  String get videoErrServer =>
      'Our server had a problem. Try again in a moment.';

  @override
  String get videoErrSession =>
      'Your session expired. Sign in again and try publishing once more.';

  @override
  String get videoErrProcessing =>
      'We couldn\'t process this video. Try again or pick another file.';

  @override
  String get videoErrUnknown =>
      'Something went wrong while publishing. Try again.';

  @override
  String get postBoostedSeeResults => 'Boosted · see results';

  @override
  String get navCreate => 'Create';

  @override
  String get profileTabGrid => 'Posts';

  @override
  String get profileTabTexts => 'Text posts';

  @override
  String get profileEmptyMeGrid =>
      'Your grid is empty. Share a photo or video.';

  @override
  String get profileEmptyOtherGrid => 'No posts yet';

  @override
  String get profileEmptyMeVideos => 'You haven\'t posted any videos yet';

  @override
  String get profileEmptyMeTexts => 'You haven\'t posted any text yet';

  @override
  String get profileEmptyMeAction => 'Post';

  @override
  String profileShareText(String name, String url) {
    return 'Check out $name on Brawe Connect: $url';
  }

  @override
  String get chatxStop => 'Stop';

  @override
  String get chatxListen => 'Listen';

  @override
  String get livexEligCheckFailTitle => 'Could not verify';

  @override
  String get livexEligCheckFailSub => 'Check your connection and try again.';

  @override
  String get livexNeedAvatarTitle => 'Add a profile photo';

  @override
  String get livexNeedAvatarSub =>
      'Only users with a profile photo can start a live.';

  @override
  String get livexNeedAvatarCta => 'Add photo now';

  @override
  String get livexNeedCreatorTitle => 'Live is exclusive to Creator Network';

  @override
  String get livexNeedCreatorSub =>
      'Live streaming is unlocked after approval in the program. It is free and takes a few minutes.';

  @override
  String get livexNeedCreatorCta => 'Join the program';

  @override
  String get livexCheckingPerms => 'Checking permissions…';

  @override
  String get livexNotNow => 'Not now';

  @override
  String get livexAddSound => 'Add sound';

  @override
  String get livexFlip => 'Flip';

  @override
  String get livexBeauty => 'Beauty';

  @override
  String get livexFilters => 'Filters';

  @override
  String get livexShare => 'Share';

  @override
  String get livexCover => 'Cover';

  @override
  String get livexChange => 'Change';

  @override
  String get livexBattle => 'Battle';

  @override
  String get livexGifts => 'Gifts';

  @override
  String get livexNotify => 'Notify';

  @override
  String get livexGuests => 'Guests';

  @override
  String get livexPromote => 'Promote';

  @override
  String get livexPublicLive => 'Public live';

  @override
  String get livexModeCamera => 'Camera';

  @override
  String get livexModeTemplate => 'Template';

  @override
  String get livexShareMax => 'You can send to up to 50 people at a time';

  @override
  String get livexShareOtherApps => 'Other apps';

  @override
  String livexShareText(String who, String title, String url) {
    return '$who is live on Brawe: $title\n$url';
  }

  @override
  String livexShareTextSelf(String title, String url) {
    return 'I am live on Brawe: $title\n$url';
  }

  @override
  String get livexAudioTitle => 'Audio';

  @override
  String get livexAudioGain => 'Gain';

  @override
  String get livexAudioLimiter => 'Limiter';

  @override
  String get livexCompLight => 'Light';

  @override
  String get livexCompMedium => 'Medium';

  @override
  String get livexCompAggressive => 'Strong';

  @override
  String get livexCompShort => 'Comp';

  @override
  String get livexAudioProcessor => 'Audio processor';

  @override
  String livexAudioProcessorSub(String preset) {
    return 'Equalizer + compressor — $preset';
  }

  @override
  String get livexAudioNoiseOn => 'Noise reduction on';

  @override
  String get livexAudioQualityOn => 'Quality mode on';

  @override
  String get livexAudioModeQuality => 'Audio: Quality';

  @override
  String get livexAudioModeVoice => 'Audio: Noise reduction';

  @override
  String get livexAudioModeQualitySub =>
      'Full-range 44.1kHz — best for music. Tap to turn on noise reduction.';

  @override
  String get livexAudioModeVoiceSub =>
      'AEC + noise suppression — best for talking. Tap to go back to quality.';

  @override
  String get livexRose => 'Rose';

  @override
  String get livexViewProduct => 'View product';

  @override
  String get livexProductSoon =>
      'Open the product in the storefront — coming soon.';

  @override
  String get livexQualityTitle => 'Video quality';

  @override
  String get livexQualityFpsNote => 'FPS: set by the streamer (usually 30fps)';

  @override
  String get livexPauseExpired =>
      'The pause went past 5 minutes and the live was ended.';

  @override
  String get livexPauseOneMinute =>
      '1 minute left: resume the live or it will end.';

  @override
  String get livexCameraSwitchDropped =>
      'The stream dropped while switching cameras. Tap Resume.';

  @override
  String get livexQualityAutoDesc => 'Adjusts automatically to your connection';

  @override
  String get livexQuality480Desc => 'Lowest data usage';

  @override
  String get livexQuality720Desc => 'Good quality, recommended';

  @override
  String get livexQuality1080Desc => 'Best quality, needs a good connection';

  @override
  String get livexRoseSendFailed => 'Could not send the rose';

  @override
  String get livexLevelMax => 'Max level reached';

  @override
  String livexXpToNext(String xp) {
    return '$xp more XP to level up';
  }

  @override
  String get livexSentVerb => 'sent';

  @override
  String get livexSwitchCameraFailed => 'Could not switch the camera';

  @override
  String get notifGroupMonth => 'This month';

  @override
  String get notifFollowBack => 'Follow back';

  @override
  String get notifActionView => 'View';

  @override
  String get moneyLivesViewReplay => 'View replay';

  @override
  String get moneyLivesReplayFetchError =>
      'Couldn\'t fetch the replay. Try again.';

  @override
  String get moneyLivesDownloadTitle => 'Download live';

  @override
  String get moneyLivesUntitled => 'Untitled live';

  @override
  String get moneyLiveUnavailable => 'This live isn\'t available.';

  @override
  String get moneyCheckoutCepInvalid =>
      'Invalid postal code. Enter all 8 digits.';

  @override
  String get moneyCheckoutCepFilled => 'Address filled from postal code';

  @override
  String get moneyCheckoutCepLookupError =>
      'Couldn\'t look up the postal code. Check the digits or fill in the address by hand.';

  @override
  String get moneyPayPixError =>
      'Couldn\'t generate the Pix payment right now. Your order was created normally: please try again.';

  @override
  String get moneyPayConfirmedToast => 'Payment confirmed!';

  @override
  String get moneyPayTitle => 'Payment';

  @override
  String get moneyPayPreparing => 'Preparing payment...';

  @override
  String get moneyPayErrorTitle => 'Couldn\'t generate payment';

  @override
  String get moneyPayTryLater => 'Please try again later.';

  @override
  String get moneyPayCodeCopied => 'Pix code copied!';

  @override
  String get moneyPayStatusPaid => 'Payment confirmed';

  @override
  String get moneyPayStatusWaiting => 'Waiting for payment';

  @override
  String get moneyPayTotal => 'Total to pay';

  @override
  String get moneyPayScanHint => 'Scan with your bank app';

  @override
  String get moneyPayCopyTitle => 'Or copy the Pix code';

  @override
  String moneyPayValidUntil(String time) {
    return 'Valid until $time';
  }

  @override
  String get moneyPaySoon => 'soon';

  @override
  String get moneyPayStep1 => 'Open your bank app or Pix wallet';

  @override
  String get moneyPayStep2 => 'Scan the QR code or paste the copied code';

  @override
  String get moneyPayStep3 => 'Confirm the payment';

  @override
  String get moneyPayStep4 => 'Your order is released automatically';

  @override
  String get moneyPayHowTo => 'How to pay';

  @override
  String get moneyPayChecking => 'Checking payment...';

  @override
  String get moneyPayConfirmed => 'Payment confirmed!';

  @override
  String get moneyPayRedirecting => 'Taking you to your order...';

  @override
  String get walletPurchaseSourceStore => 'App store';

  @override
  String get adsRepPlatformOtherPhones => 'Other phones';

  @override
  String get mediaRepostedToast => 'Reposted';

  @override
  String get mediaUndo => 'Undo';

  @override
  String get mediaStoryLabel => 'Story';

  @override
  String get mediaRepostStoryTooltip => 'Repost to story';

  @override
  String cmtTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get cmtSortTooltip => 'Sort comments';

  @override
  String get cmtSortTop => 'Most relevant';

  @override
  String get cmtSortRecent => 'Most recent';

  @override
  String cmtViewReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'View $count replies',
      one: 'View 1 reply',
    );
    return '$_temp0';
  }

  @override
  String get cmtHideReplies => 'Hide';

  @override
  String get cmtAddHint => 'Add comment...';

  @override
  String get cmtEmptyTitle => 'No comments yet';

  @override
  String get cmtEmptyBody => 'Start the conversation: be the first to comment.';

  @override
  String get cmtCopyText => 'Copy text';

  @override
  String get cmtCopied => 'Text copied';

  @override
  String get cmtDelete => 'Delete comment';

  @override
  String get cmtDeleteFail => 'Could not delete the comment.';

  @override
  String get cmtMentionTooltip => 'Mention someone';

  @override
  String get cmtEmojiTooltip => 'Emoji';

  @override
  String get cmtSendTooltip => 'Send comment';

  @override
  String get cmtShareComment => 'Share comment';

  @override
  String get cmtShareTitle => 'Send to';

  @override
  String get cmtShareSearchHint => 'Search people';

  @override
  String cmtShareSendCount(int count) {
    return 'Send ($count)';
  }

  @override
  String get cmtShareNoteHint => 'Write a message...';

  @override
  String cmtShareSentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent to $count people',
      one: 'Sent to 1 person',
    );
    return '$_temp0';
  }

  @override
  String get cmtShareSendFail => 'Could not send to some people. Try again.';

  @override
  String get cmtShareWhatsapp => 'WhatsApp';

  @override
  String get cmtShareAddStory => 'Add to Story';

  @override
  String get cmtShareNoResults => 'No one found.';

  @override
  String get cmtShareOpenFail => 'Could not open the app.';

  @override
  String cmtShareCommentText(String username, String text, String url) {
    return 'Comment by @$username on Brawe: “$text”\n$url';
  }
}
