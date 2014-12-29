#import <CoreTelephony/CTRegistration.h>

static BOOL enabled;
static NSInteger resetDate;

static void loadPreferences() {
  CFPreferencesAppSynchronize(CFSTR("com.greeny.autostatisticsreset"));
      //In this case, you get the value for the key "enabled"
      //you could do the same thing for any other value, just cast it to id and use the conversion methods
      //if the value doesn't exist (i.e. the user hasn't changed their preferences), it is set to the value after the "?:" (in this case, YES and @"default", respectively
  enabled = [(__bridge NSNumber*)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.greeny.autostatisticsreset")) boolValue];
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  resetDate = [[formatter numberFromString:(__bridge NSString*)CFPreferencesCopyAppValue(CFSTR("resetDate"), CFSTR("com.greeny.autostatisticsreset"))] integerValue];
}

static BOOL shouldResetData() {
  NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar]; //current user calendar
  NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitDay) fromDate:[NSDate date]]; //separates NSDate into components
  if (resetDate == dateComponents.day) { //compare date from prefs to current date
    return TRUE; //dates match
  } else {
    return FALSE; //dates do not match
  }
}

static void resetData() { //call your method to reset data (there should be an instance of SettingsNetworkController that you can hook into here)
  //logic to reset data
  CTRegistrationDataCounterReset();
}

@interface RCSTimer : NSObject
{
  NSTimer *resetTimer;
}

+ (instancetype)sharedInstance;
- (void)startTimer;
- (void)resetTimer;
- (void)checkDates:(id)sender;
@end

@implementation RCSTimer 

+ (instancetype)sharedInstance {
  static dispatch_once_t pred;
  static RCSTimer *shared = nil;
   
  dispatch_once(&pred, ^{
    shared = [[RCSTimer alloc] init];
  });
  return shared;
}

- (void)startTimer {
  [self resetTimer];
  resetTimer = [NSTimer scheduledTimerWithTimeInterval:24.0 * 60.0 * 60.0 target:self selector:@selector(checkDates:) userInfo:nil repeats:YES];
}

- (void)resetTimer {
  if (resetTimer) {
    [resetTimer invalidate];
    resetTimer = nil;
  }
}

- (void)checkDates:(id)sender {
  if (shouldResetData()) { 
    resetData();
  }
}

@end

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                (CFNotificationCallback)loadPreferences,
                                CFSTR("com.greeny.autostatisticsreset/loadPreferences"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
  loadPreferences();

  BOOL invalidForStart = (!resetDate || resetDate == 0);
  if (!invalidForStart) {
    [[RCSTimer sharedInstance] startTimer];
  }
}

