
static BOOL enabled;
static NSInteger *resetDate;
static NSTimer *resetTimer;

static void loadPreferences() {
  CFPreferencesAppSynchronize(CFSTR("com.greeny.autostatisticsreset"));
      //In this case, you get the value for the key "enabled"
      //you could do the same thing for any other value, just cast it to id and use the conversion methods
      //if the value doesn't exist (i.e. the user hasn't changed their preferences), it is set to the value after the "?:" (in this case, YES and @"default", respectively
  enabled = [(NSNumber*)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.greeny.autostatisticsreset")) boolValue];
  resetDate = [[NSNumber numberWithString:(NSString*)CFPreferencesCopyAppValue(CFSTR("resetDate"), CFSTR("com.greeny.autostatisticsreset"))] integerValue];
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
}

//method should reset data usage
%hook SettingsNetworkController 
-(void)loadView {
   if (resetTimer) {
    [resetTimer invalidate];
    resetTimer = nil;
  }

  resetTimer = [NSTimer scheduledTimerWithTimeInterval:24.0 * 60.0 * 60.0 target:self selector:@selector(checkDates:) userInfo:nil repeats:YES];
  %orig;
}

%new 
- (void)checkDates:(id)sender {
  if (shouldResetData()) { 
    resetData();
  }
}

-(void)clearStats:(id)totalDataUsageForSpecifier {
  %orig;
}
%end

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationSuspensionBehaviorDeliverImmediately);
  loadPreferences();
}

/*
You need to put this somewhere where it runs every day. This will check if the current date is the reset date and then run your reset logic if it is.

if (shouldResetData()) { 
  resetData();
}

*/

