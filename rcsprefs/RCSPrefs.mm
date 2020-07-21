#import <CoreFoundation/CoreFoundation.h>
#import <Flipswitch/Flipswitch.h>
#import <Preferences/PSEditableTableCell.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow.h>
#import <spawn.h>
#define DEBUG
#define DEBUG_PREFIX @"[RCS]"
#import "../DebugLog.h"
//#import <Cephei/HBSpinnerTableCell.h>

#define kTintColor                                                             \
  [UIColor colorWithRed:86.0 / 256.0                                           \
                  green:86.0 / 256.0                                           \
                   blue:92.0 / 256.0                                           \
                  alpha:1.0]
#define kTweetText                                                             \
  @"I'm using #ReStats by @GreenyDev to automatically reset my Cellular "      \
  @"Statisics!"

static int width = [[UIScreen mainScreen] bounds].size.width;

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;
@end

@interface RCSPrefsListController : PSListController {
}
@end

@interface RCSDatePickerCell : PSEditableTableCell {
  NSDateFormatter *formatter;
}
@end

@implementation RCSPrefsListController
- (id)specifiers {
  if (_specifiers == nil) {
    _specifiers = [[self loadSpecifiersFromPlistName:@"RCSPrefs"
                                              target:self] retain];
  }
  return _specifiers;
}
- (void)stopEditing {
  [self.view endEditing:YES];
}
- (void)donate {
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:
                         @"https://www.paypal.com/cgi-bin/"
                         @"webscr?cmd=_donations&business=9ZXVHGA5AW5CG&lc=AU&"
                         @"item_name=GreenyDev&currency_code=AUD&bn=PP%"
                         @"2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"]];
}
- (void)sourcelink {
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:@"https://github.com/GreenyDev/ReStats"]];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  [self.view endEditing:YES];
}
- (id)datePickerStringValue:(id)specifier {
  NSDate *date = (NSDate *)CFPreferencesCopyAppValue(
      CFSTR("resetDate"), CFSTR("com.greeny.ReStats"));
  // formatter for the user to see the calendar setting
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateStyle:NSDateFormatterMediumStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  return [formatter stringFromDate:date];
}
- (void)loadView {
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                           target:self
                           action:@selector(tweetSP:)];
  // self.navigationItem.rightBarButtonItem.tintColor = kTintColor;
  [super loadView];
  [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = kTintColor;
}

- (void)tweetSP:(id)sender {
  TWTweetComposeViewController *tweetController =
      [[TWTweetComposeViewController alloc] init];
  [tweetController setInitialText:kTweetText];
  [self.navigationController presentViewController:tweetController
                                          animated:YES
                                        completion:nil];
  [tweetController release];
}
- (void)resetPrefs {
  UIAlertView *prefsIsKill = [[UIAlertView alloc]
          initWithTitle:@"ReStats"
                message:@"Settings app will now close. This is not a crash."
               delegate:self
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil];
  [prefsIsKill show];
  [prefsIsKill setTag:1];
  [prefsIsKill release];
}

- (void)alertView:(UIAlertView *)alertView
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if ([alertView tag] == 1) {
    if (buttonIndex == 0) {
      NSString *prefsPath =
          @"/var/mobile/Library/Preferences/com.greeny.ReStats.plist";
      NSFileManager *manager = [NSFileManager new];
      [manager removeItemAtPath:prefsPath error:NULL];
      sleep(1);
      pid_t pid;
      const char *args[] = {"killall", "-9", "Preferences", NULL};
      posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args,
                  NULL);
    }
  }
}
@end

@interface RCSDevelopersListController : PSListController {
}
@end

@implementation RCSDevelopersListController
- (id)specifiers {
  if (_specifiers == nil) {
    _specifiers = [[self loadSpecifiersFromPlistName:@"RCSDevelopers"
                                              target:self] retain];
  }
  return _specifiers;
}
@end

@interface GreenyDev : PSTableCell {
  UIImageView *_background;
  UILabel *devName;
  UILabel *devRealName;
  UILabel *jobSubtitle;
}
@end

@implementation GreenyDev
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    UIImage *bkIm = [[UIImage alloc]
        initWithContentsOfFile:
            @"/Library/PreferenceBundles/RCSPrefs.bundle/GreenyDevTwitter.png"];
    _background = [[UIImageView alloc] initWithImage:bkIm];
    _background.frame = CGRectMake(10, 15, 70, 70);
    _background.layer.cornerRadius = _background.frame.size.height / 2;
    _background.layer.masksToBounds = YES;
    _background.layer.borderWidth = 0;
    [self addSubview:_background];

    CGRect frame = [self frame];

    devName = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 10,
                                 frame.size.width, frame.size.height)];
    [devName setText:@"GreenyDev"];
    [devName setBackgroundColor:[UIColor clearColor]];
    [devName setTextColor:kTintColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
    else
      [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:23]];

    [self addSubview:devName];

    devRealName = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 30,
                                 frame.size.width, frame.size.height)];
    [devRealName setText:@"@GreenyDev on Twitter"];
    [devRealName setTextColor:kTintColor];
    [devRealName setBackgroundColor:[UIColor clearColor]];
    [devRealName setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];

    [self addSubview:devRealName];

    jobSubtitle = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 50,
                                 frame.size.width, frame.size.height)];
    [jobSubtitle setText:@"Developer"];
    [jobSubtitle setTextColor:kTintColor];
    [jobSubtitle setBackgroundColor:[UIColor clearColor]];
    [jobSubtitle setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];

    [self addSubview:jobSubtitle];
  }
  return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  return 70.f;
}

@end

@interface GreenyTwitter : PSListController {
}
@end

@implementation GreenyTwitter
- (id)specifiers {
  NSString *user = @"GreenyDev";
  if ([[UIApplication sharedApplication]
          canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/"
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name="
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"tweetings:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name="
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"twitter:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"twitter://user?screen_name="
                                         stringByAppendingString:user]]];

  else
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/"
                                         stringByAppendingString:user]]];
  return 0;
}

- (void)viewDidAppear:(BOOL)arg1 {
  UINavigationController *navController = self.navigationController;
  [navController popViewControllerAnimated:YES];
}
@end

@interface SHIVADOC : PSTableCell {
  UIImageView *_background;
  UILabel *devName;
  UILabel *devRealName;
  UILabel *jobSubtitle;
}
@end

@implementation SHIVADOC

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    UIImage *bkIm = [[UIImage alloc]
        initWithContentsOfFile:
            @"/Library/PreferenceBundles/RCSPrefs.bundle/SHIVADOC.png"];
    _background = [[UIImageView alloc] initWithImage:bkIm];
    _background.frame = CGRectMake(10, 15, 70, 70);
    _background.layer.cornerRadius = _background.frame.size.height / 2;
    _background.layer.masksToBounds = YES;
    _background.layer.borderWidth = 0;
    [self addSubview:_background];

    CGRect frame = [self frame];

    devName = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 10,
                                 frame.size.width, frame.size.height)];
    [devName setText:@"SHIVADOC"];
    [devName setBackgroundColor:[UIColor clearColor]];
    [devName setTextColor:kTintColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
    else
      [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:23]];

    [self addSubview:devName];

    devRealName = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 30,
                                 frame.size.width, frame.size.height)];
    [devRealName setText:@"/u/SHIVADOC on Reddit"];
    [devRealName setTextColor:kTintColor];
    [devRealName setBackgroundColor:[UIColor clearColor]];
    [devRealName setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];

    [self addSubview:devRealName];

    jobSubtitle = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 50,
                                 frame.size.width, frame.size.height)];
    [jobSubtitle setText:@"Assisted with Development "];
    [jobSubtitle setTextColor:kTintColor];
    [jobSubtitle setBackgroundColor:[UIColor clearColor]];
    [jobSubtitle setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];

    [self addSubview:jobSubtitle];
  }
  return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  return 80.f;
}
@end

@interface WithHelpFromCell : PSTableCell <PreferencesTableCustomView> {
  UILabel *llLbl;
}

@end

@implementation WithHelpFromCell

- (id)initWithSpecifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:@"Cell"
                    specifier:specifier];
  if (self) {

    int width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = CGRectMake(0, -15, width, 20);

    llLbl = [[UILabel alloc] initWithFrame:frame];
    [llLbl setLineBreakMode:UILineBreakModeWordWrap];
    [llLbl setNumberOfLines:1];
    [llLbl setText:@"With help from"];
    [llLbl setBackgroundColor:[UIColor clearColor]];
    [llLbl setTextAlignment:UITextAlignmentCenter];
    llLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    llLbl.textColor = kTintColor;

    [self addSubview:llLbl];
    [llLbl release];
  }
  return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  return 1.5f;
}

@end

@interface BrandonMartin : PSTableCell {
  UIImageView *_background;
  UILabel *devName;
  UILabel *devRealName;
  UILabel *jobSubtitle;
}
@end

@implementation BrandonMartin
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    UIImage *bkIm = [[UIImage alloc]
        initWithContentsOfFile:@"/Library/PreferenceBundles/RCSPrefs.bundle/"
                               @"BrandonMartinTwitter.png"];
    _background = [[UIImageView alloc] initWithImage:bkIm];
    _background.frame = CGRectMake(10, 15, 70, 70);
    _background.layer.cornerRadius = _background.frame.size.height / 2;
    _background.layer.masksToBounds = YES;
    _background.layer.borderWidth = 0;
    [self addSubview:_background];

    CGRect frame = [self frame];

    devName = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 10,
                                 frame.size.width, frame.size.height)];
    [devName setText:@"Brandon Martin"];
    [devName setBackgroundColor:[UIColor clearColor]];
    [devName setTextColor:kTintColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
    else
      [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:23]];

    [self addSubview:devName];

    devRealName = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 30,
                                 frame.size.width, frame.size.height)];
    [devRealName setText:@"@BrandonMStudios on Twitter"];
    [devRealName setTextColor:kTintColor];
    [devRealName setBackgroundColor:[UIColor clearColor]];
    [devRealName setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];

    [self addSubview:devRealName];

    jobSubtitle = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 50,
                                 frame.size.width, frame.size.height)];
    [jobSubtitle setText:@"Icon Designer"];
    [jobSubtitle setTextColor:kTintColor];
    [jobSubtitle setBackgroundColor:[UIColor clearColor]];
    [jobSubtitle setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];

    [self addSubview:jobSubtitle];
  }
  return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  return 80.f;
}

@end

@interface BrandonMartinTwitter : PSListController {
}
@end

@implementation BrandonMartinTwitter
- (id)specifiers {
  NSString *user = @"BrandonMStudios";
  if ([[UIApplication sharedApplication]
          canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/"
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name="
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"tweetings:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name="
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"twitter:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"twitter://user?screen_name="
                                         stringByAppendingString:user]]];

  else
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/"
                                         stringByAppendingString:user]]];
  return 0;
}

- (void)viewDidAppear:(BOOL)arg1 {
  UINavigationController *navController = self.navigationController;
  [navController popViewControllerAnimated:YES];
}
@end

@interface SHIVADOCReddit : PSListController {
}
@end

@implementation SHIVADOCReddit
- (id)specifiers {
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:@"http://www.reddit.com/user/shivadoc"]];
  return 0;
}

- (void)viewDidAppear:(BOOL)arg1 {
  UINavigationController *navController = self.navigationController;
  [navController popViewControllerAnimated:YES];
}
@end

@interface MD : PSTableCell {
  UIImageView *_background;
  UILabel *devName;
  UILabel *devRealName;
  UILabel *jobSubtitle;
}
@end

@implementation MD
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    UIImage *bkIm = [[UIImage alloc]
        initWithContentsOfFile:
            @"/Library/PreferenceBundles/RCSPrefs.bundle/MD.png"];
    _background = [[UIImageView alloc] initWithImage:bkIm];
    _background.frame = CGRectMake(10, 15, 70, 70);
    _background.layer.cornerRadius = _background.frame.size.height / 2;
    _background.layer.masksToBounds = YES;
    _background.layer.borderWidth = 0;
    [self addSubview:_background];

    CGRect frame = [self frame];

    devName = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 10,
                                 frame.size.width, frame.size.height)];
    [devName setText:@"Milo Darling"];
    [devName setBackgroundColor:[UIColor clearColor]];
    [devName setTextColor:kTintColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
    else
      [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:23]];

    [self addSubview:devName];

    devRealName = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 30,
                                 frame.size.width, frame.size.height)];
    [devRealName setText:@"@JamesIscNeutron on Twitter"];
    [devRealName setTextColor:kTintColor];
    [devRealName setBackgroundColor:[UIColor clearColor]];
    [devRealName setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];

    [self addSubview:devRealName];

    jobSubtitle = [[UILabel alloc]
        initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 50,
                                 frame.size.width, frame.size.height)];
    [jobSubtitle setText:@"Assisted with Development"];
    [jobSubtitle setTextColor:kTintColor];
    [jobSubtitle setBackgroundColor:[UIColor clearColor]];
    [jobSubtitle setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];

    [self addSubview:jobSubtitle];
  }
  return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  return 80.f;
}

@end

@interface MDTwitter : PSListController {
}
@end

@implementation MDTwitter
- (id)specifiers {
  NSString *user = @"JamesIscNeutron";
  if ([[UIApplication sharedApplication]
          canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/"
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name="
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"tweetings:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name="
                                         stringByAppendingString:user]]];

  else if ([[UIApplication sharedApplication]
               canOpenURL:[NSURL URLWithString:@"twitter:"]])
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"twitter://user?screen_name="
                                         stringByAppendingString:user]]];

  else
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/"
                                         stringByAppendingString:user]]];
  return 0;
}

- (void)viewDidAppear:(BOOL)arg1 {
  UINavigationController *navController = self.navigationController;
  [navController popViewControllerAnimated:YES];
}
@end

@implementation RCSDatePickerCell

- (void)layoutSubviews {
  [super layoutSubviews];
  /// date picker like the keyboard
  UIDatePicker *datePicker = [[UIDatePicker alloc] init];
  datePicker.minimumDate = [NSDate date];
  [datePicker addTarget:self
                 action:@selector(updateTextField:)
       forControlEvents:UIControlEventValueChanged];
  // formatter for the user to see the calendar setting
  formatter = [[NSDateFormatter alloc] init];
  [formatter setDateStyle:NSDateFormatterMediumStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];

  [[self textField]
      setInputView:datePicker]; // change from keyboard to date picker
  [[self textField]
      setTintColor:[UIColor clearColor]]; // makes the cursor invisible, looks
                                          // cleaner
}

- (void)updateTextField:(UIDatePicker *)sender {
  NSString *newVal = [formatter stringFromDate:sender.date];
  [self setValue:newVal];
}

- (void)endEditingAndSave {
  [super endEditingAndSave];
  NSDate *date = [formatter dateFromString:[self value]];
  if ([date timeIntervalSinceDate:[NSDate date]] > 0) {
    // manually set the value and post the notification because the other way
    // wasn't working
    CFPreferencesSetAppValue(CFSTR("resetDate"), date,
                             CFSTR("com.greeny.ReStats"));
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.greeny.ReStats/prefsChanged"), NULL, NULL, YES);
  }
}

@end

// vim:ft=objc
