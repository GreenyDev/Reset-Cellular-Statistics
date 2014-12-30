#import <UIKit/UIKit.h>
#import <SpringBoard/SBApplication.h>
#import "CoreTelephony/CoreTelephony.h"
#define DEBUG
#define DEBUG_PREFIX @"[RCS]"
#import "DebugLog.h"
#define MONTH_TYPE 0
#define WEEK_TYPE 1
#define DAY_TYPE 2

@interface RCSTimerInitializer : NSObject <UIAlertViewDelegate>
{
    BOOL enabled;
    NSTimer *resetTimer;
    NSDate *fireDate;
    BOOL didFinish;
    int cycleType;
}
- (id)init;
- (void)loadPreferences;
- (void)setupTimer;
- (void)resetData:(id)sender;
- (void)newTimer;
@end

RCSTimerInitializer *timerController;

@implementation RCSTimerInitializer

-(id)init {
    if (self=[super init]) {
        [self loadPreferences];
        didFinish = NO;
    }
    return self;
}

-(void)loadPreferences {
    CFPreferencesAppSynchronize(CFSTR("com.greeny.autostatisticsreset"));
    enabled = YES;//[(NSNumber*)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.greeny.autostatisticsreset")) boolValue]; //I haven't done this part yet :/
    fireDate = (NSDate*)CFPreferencesCopyAppValue(CFSTR("resetDate"), CFSTR("com.greeny.autostatisticsreset"));
    didFinish = [(NSNumber*)CFPreferencesCopyAppValue(CFSTR("didFinish"), CFSTR("com.greeny.autostatisticsreset")) boolValue];
    cycleType = [(NSNumber*)CFPreferencesCopyAppValue(CFSTR("cycleType"), CFSTR("com.greeny.autostatisticsreset")) intValue]; //nil will result in 0, and 0 is default :)
    DebugLogC(@"enabled: %d, fireDate: %@, didFinish: %d, cycleType: %d", enabled, fireDate, didFinish, cycleType);
    if ((!fireDate || enabled) && resetTimer) {
        [resetTimer invalidate];
        resetTimer = nil;
    }
    [self setupTimer];
}

-(void)setupTimer {
    if (!fireDate || !enabled) return;
    NSTimeInterval fireTime = [fireDate timeIntervalSinceNow];
    if (fireTime>0) {
        DebugLogC(@"Setting timer for %f seconds", fireTime);
        resetTimer = [NSTimer scheduledTimerWithTimeInterval:fireTime target:self selector:@selector(resetData:) userInfo:nil repeats:NO];
    } else if (!didFinish) {
        [self resetData:nil]; //if the phone was off or something when it was supposed to fire, do it now.
    }
}

- (void)resetData:(NSTimer *)sender {
    DebugLogC(@"We have been called!");
    didFinish = YES; //say we finished
    CFPreferencesSetAppValue( CFSTR("didFinish"), kCFBooleanTrue, CFSTR("com.greeny.autostatisticsreset") ); //set it as a preference for preservation over resprings/reboots
    
    [[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.Preferences" suspended:YES]; //launch the settings app in the background so the helper will load
    [self performSelector:@selector(postNotification) withObject:nil afterDelay:1.0f]; //post the notification after a second (probably not the best way to do this, but whatever
    if (resetTimer) {
        [resetTimer invalidate];
        resetTimer = nil;
    }
    [self newTimer];
}

-(void)postNotification {
    CFNotificationCenterPostNotification ( CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.greeny.autostatisticsreset/doIt"), NULL, NULL, YES );
}

-(void)newTimer {
    //Set up the next timer, for exactly one month, week, or day later
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    if (cycleType == MONTH_TYPE) {
        [components setMonth:1];
    } else if (cycleType == WEEK_TYPE) {
        [components setWeekOfYear:1];
    } else if (cycleType == DAY_TYPE) {
        [components setDay:1];
    }
    fireDate = [calendar dateByAddingComponents:components toDate:now options:0];
    CFPreferencesSetAppValue ( CFSTR("resetDate"), fireDate, CFSTR("com.greeny.autostatisticsreset") );
    [self setupTimer];
}
@end

static void loadPreferences() {
    [timerController loadPreferences];
}

%ctor {
    timerController = [[RCSTimerInitializer alloc] init];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPreferences, CFSTR("com.greeny.autostatisticsreset/prefsChanged"), NULL, YES);
}