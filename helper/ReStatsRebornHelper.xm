#import "ReStatsRebornHelper.h"

//Helper
RRCSHelperInitializer *helperController;

@implementation RRCSHelperInitializer
-(id)init {
	if((self = [super init])) {
		NSLog(@"Helper initialized");
	}
	return self;
}

- (void)getDataWithCompletion:(void (^)(BOOL success))completion {
	// I might not understand synchronous process properly...
	__block NSNumber *dataUsage = 0;
	__block NSString *callTime = 0;
	BOOL success = NO;
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		if([[%c(PSUIAppCellularUsageStatisticsCache) sharedInstance] respondsToSelector: @selector(fetchDataUsageStatistics:)]) {
			//iOS12
			NSLog(@"iOS12");
			[[%c(PSUIAppCellularUsageStatisticsCache) sharedInstance] fetchDataUsageStatistics];
			sleep(1);
			dataUsage = [NSNumber numberWithDouble:[[[%c(PSUIAppCellularUsageStatisticsCache) sharedInstance] totalUsage] totalBytesUsed]];
			callTime = [[[%c(PSUICellularController) alloc] init] callTimeDurationRestrictedToCurrentPeriod:YES];
		} else if ([[%c(PSDataUsageStatisticsCache) sharedInstance] respondsToSelector: @selector(fetchDeviceDataUsageWithCompletion:)]) {
			//iOS13
			NSLog(@"iOS13");
			[[%c(PSDataUsageStatisticsCache) sharedInstance] fetchDeviceDataUsageWithCompletion:^{
			         dataUsage = [NSNumber numberWithUnsignedLongLong:[[%c(PSDataUsageStatisticsCache) sharedInstance] totalCellularUsageForPeriod : 0]];
			         callTime = [[[%c(PSUICallTimeGroup) alloc] initWithListController:nil] callTimeDurationRestrictedToCurrentPeriod:YES];
			         dispatch_semaphore_signal(semaphore);
			 }
			];
		} else dispatch_semaphore_signal(semaphore); //Return NULL if on other iOS version
	});

	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

	CFPreferencesSetAppValue( CFSTR("lastDataUsage"), (CFPropertyListRef)dataUsage, CFSTR("jp.soh.ReStatsReborn"));
	CFPreferencesSetAppValue( CFSTR("lastCallTime"), (CFPropertyListRef)callTime, CFSTR("jp.soh.ReStatsReborn"));
	CFPreferencesAppSynchronize(CFSTR("jp.soh.ReStatsReborn"));

	if(dataUsage) success = YES;

	completion(success);
}

- (void)resetData {
	[self getDataWithCompletion:^(BOOL completed)
	 {
	         if ([[[%c(SettingsNetworkController) alloc] init] respondsToSelector: @selector(clearStats:)]) {
			 //iOS7-9 (by GreenyDev)
			 [[[%c(SettingsNetworkController) alloc] init] clearStats:nil];
		 } else if ([[[%c(PSUISettingsNetworkController) alloc] init] respondsToSelector:@selector(clearStats:)]) {
			 //iOS9-11
			 [[[%c(PSUISettingsNetworkController) alloc] init] clearStats:nil];
		 } else if ([[[%c(PSUICellularController) alloc] init] respondsToSelector:@selector(clearStats:)]) {
			 //iOS12 (by Soh Satoh)
			 [[[%c(PSUICellularController) alloc] init] clearStats:nil];
		 } else if ([[[%c(PSUIResetStatisticsGroup) alloc] init] respondsToSelector:@selector(clearStats:)]) {
			 //iOS13 (by Soh Satoh)
			 [[[%c(PSUIResetStatisticsGroup) alloc] init] clearStats:nil];
		 } else return;
	         NSLog(@"Successfully reset data");
	         CFNotificationCenterPostNotification ( CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("jp.soh.ReStatsReborn/success"), NULL, NULL, YES );
	 }
	];
}
@end

static void resetData() {
	[helperController resetData];
}

%ctor {
	helperController = [[RRCSHelperInitializer alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)resetData, CFSTR("jp.soh.ReStatsReborn/doIt"), NULL, YES);
}
