#import "Tweak.h"

#define MONTH_TYPE 0
#define WEEK_TYPE 1
#define DAY_TYPE 2

extern dispatch_queue_t __BBServerQueue;
static BBServer *bbServer = nil;

@interface RRCSTimerInitializer: NSObject <UIAlertViewDelegate>
{
	BOOL enabled;
	BOOL notifyOnTrigger;
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

RRCSTimerInitializer *timerController;

@implementation RRCSTimerInitializer

-(id)init {
	if (self=[super init]) {
		[self loadPreferences];
		didFinish = NO;
	}
	return self;
}

-(void)loadPreferences {
	CFPreferencesAppSynchronize(CFSTR("jp.soh.ReStatsReborn"));
	enabled = [(NSNumber*)CFPreferencesCopyAppValue (CFSTR("enabled"), CFSTR("jp.soh.ReStatsReborn"))boolValue];
	notifyOnTrigger = [(NSNumber*)CFPreferencesCopyAppValue (CFSTR("notifyOnTrigger"), CFSTR("jp.soh.ReStatsReborn"))boolValue];
	fireDate = (NSDate*)CFPreferencesCopyAppValue(CFSTR("resetDate"), CFSTR("jp.soh.ReStatsReborn"));
	didFinish = [(NSNumber*)CFPreferencesCopyAppValue (CFSTR("didFinish"), CFSTR("jp.soh.ReStatsReborn"))boolValue];
	cycleType = [(NSNumber*)CFPreferencesCopyAppValue (CFSTR("cycleType"), CFSTR("jp.soh.ReStatsReborn"))intValue]; //nil will result in 0, and 0 is default :)
	HBLogDebug(@"enabled: %d, fireDate: %@, didFinish: %d, cycleType: %d", enabled, fireDate, didFinish, cycleType);
	if (resetTimer) {
		[resetTimer invalidate];
		resetTimer = nil;
	}
	[self setupTimer];
}

-(void)setupTimer {
	if (!fireDate || !enabled) return;
	NSTimeInterval fireTime = [fireDate timeIntervalSinceNow];
	if (fireTime>0) {
		HBLogDebug(@"Setting timer for %f seconds", fireTime);
		resetTimer = [NSTimer scheduledTimerWithTimeInterval:fireTime target:self selector:@selector(resetData:) userInfo:nil repeats:NO];
	} else if (!didFinish) {
		[self resetData:nil]; //if the phone was off or something when it was supposed to fire, do it now.
	}
}

- (void)resetData:(NSTimer *)sender {
	HBLogDebug(@"We have been called!");
	didFinish = YES; //say we finished
	CFPreferencesSetAppValue( CFSTR("didFinish"), kCFBooleanTrue, CFSTR("jp.soh.ReStatsReborn") ); //set it as a preference for preservation over resprings/reboots

	[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.Preferences" suspended:YES]; //launch the settings app in the background so the helper will load
	[self performSelector:@selector(postNotification) withObject:nil afterDelay:1.0f]; //post the notification after a second (probably not the best way to do this, but whatever
	if (resetTimer) {
		[resetTimer invalidate];
		resetTimer = nil;
	}
	[self newTimer];
}

-(void)postNotification {
	CFNotificationCenterPostNotification ( CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("jp.soh.ReStatsReborn/doIt"), NULL, NULL, YES );
	[self sendNotification];
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
	CFPreferencesSetAppValue ( CFSTR("resetDate"), fireDate, CFSTR("jp.soh.ReStatsReborn") );
	[self setupTimer];
}

-(void)sendNotification {
	if(bbServer) {
		NSLog(@"BBServer found");
		dispatch_sync(__BBServerQueue, ^{
			BBBulletinRequest *notification = [[%c(BBBulletinRequest) alloc] init];
			[notification setDefaultAction: [%c(BBAction) actionWithLaunchBundleID: @"com.apple.Preferences"]];
			notification.title = @"ReStats Reborn";
			notification.message = @"Successfully reset the cellular statistics";
			notification.sectionID = @"com.apple.Preferences";
			notification.recordID = @"jp.soh.ReStatsReborn.notification";
			notification.publisherBulletinID = @"jp.soh.ReStatsReborn.notification";
			notification.clearable = YES;
			notification.showsMessagePreview = YES;
			notification.date = [NSDate date];
			notification.publicationDate = [NSDate date];
			notification.lastInterruptDate = [NSDate date];

			if ([bbServer respondsToSelector:@selector(publishBulletinRequest:destinations:alwaysToLockScreen:)]) {
				[bbServer publishBulletinRequest:notification destinations:15 alwaysToLockScreen:NO];
			} else if([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]) {
				[bbServer publishBulletin:notification destinations:15 alwaysToLockScreen:NO];
			} else if([bbServer respondsToSelector:@selector(_publishBulletinRequest:forSectionID:forDestinations:)]) {
				[bbServer _publishBulletinRequest:notification forSectionID:notification.sectionID forDestinations:15];
			} else if([bbServer respondsToSelector:@selector(_publishBulletinRequest:forSectionID:forDestinations:alwaysToLockScreen:)]) {
				[bbServer _publishBulletinRequest:notification forSectionID:notification.sectionID forDestinations:15 alwaysToLockScreen:NO];
			}
		});
	}
}
@end


////Notification
%hook BBServer
-(id)initWithQueue: (id)arg1 {
	bbServer = %orig;
	return bbServer;
}

-(id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
	bbServer = %orig;
	return bbServer;
}

- (void)dealloc {
	if (bbServer == self) {
		bbServer = nil;
	}
	%orig;
}
%end

static void loadPreferences() {
	[timerController loadPreferences];
}

%ctor {
	timerController = [[RRCSTimerInitializer alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPreferences, CFSTR("jp.soh.ReStatsReborn/prefsChanged"), NULL, YES);
}