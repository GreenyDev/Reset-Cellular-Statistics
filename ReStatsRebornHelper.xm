static void resetData() {
	if ([[[%c(SettingsNetworkController) alloc] init] respondsToSelector: @selector(clearStats:)]) {
		//iOS7-9 (by GreenyDev)
		[[[%c(SettingsNetworkController) alloc] init] clearStats:nil];
	} else if ([[[%c(PSUISettingsNetworkController) alloc] init] respondsToSelector:@selector(clearStats:)]) {
		//iOS9-11 (by CokePokes)
		[[[%c(PSUISettingsNetworkController) alloc] init] clearStats:nil];
	} else if ([[[%c(PSUICellularController) alloc] init] respondsToSelector:@selector(clearStats:)]) {
		//iOS12 (by Soh Satoh)
		[[[%c(PSUICellularController) alloc] init] clearStats:nil];
	} else if ([[[%c(PSUIResetStatisticsGroup) alloc] init] respondsToSelector:@selector(clearStats:)]) {
		//iOS13 (by Soh Satoh)
		[[[%c(PSUIResetStatisticsGroup) alloc] init] clearStats:nil];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)resetData, CFSTR("jp.soh.ReStatsReborn/doIt"), NULL, YES);
}