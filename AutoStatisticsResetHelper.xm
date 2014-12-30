static void resetData() {
    [[[%c(SettingsNetworkController) alloc] init] clearStats:nil];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)resetData, CFSTR("com.greeny.autostatisticsreset/doIt"), NULL, YES);
}