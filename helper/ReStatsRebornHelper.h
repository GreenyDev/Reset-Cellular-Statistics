@interface SettingsNetworkController
- (void)clearStats:(id)arg1;
@end

//SettingsCellular
@interface PSDataUsageStatisticsCache
+ (id)sharedInstance;
- (NSUInteger)totalCellularUsageForPeriod:(NSUInteger)arg1;
- (void)fetchDeviceDataUsageWithCompletion:(/*^block*/ id)arg1;
@end