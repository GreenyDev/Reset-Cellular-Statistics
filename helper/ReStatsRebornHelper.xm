#import "ReStatsRebornHelper.h"

static void resetData() {
	[[%c(PSDataUsageStatisticsCache) sharedInstance] fetchDeviceDataUsageWithCompletion:^{
	         NSNumber *dataUsage = [NSNumber numberWithUnsignedInteger:[[%c(PSDataUsageStatisticsCache) sharedInstance] totalCellularUsageForPeriod:0]];
	         if(dataUsage == 0) dataUsage = [NSNumber numberWithUnsignedInteger:[[NSClassFromString(@"PSDataUsageStatisticsCache") sharedInstance] totalCellularUsageForPeriod:0]];
	         CFPreferencesSetAppValue( CFSTR("lastDataUsage"), (CFPropertyListRef)dataUsage, CFSTR("jp.soh.ReStatsReborn"));
	         CFPreferencesAppSynchronize(CFSTR("jp.soh.ReStatsReborn"));

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
		 }
	         else return;

	         CFNotificationCenterPostNotification ( CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("jp.soh.ReStatsReborn/success"), NULL, NULL, YES );
	 }];
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)resetData, CFSTR("jp.soh.ReStatsReborn/doIt"), NULL, YES);
}
