//Helper
@interface RRCSHelperInitializer : NSObject
- (id)init;
- (void)getDataWithCompletion:(void (^)(BOOL success))completion;
- (void)resetData;
@end

//Clear Stats
@interface SettingsNetworkController
- (void)clearStats:(id)arg1;
@end

//Usage
@interface PSDataUsageStatisticsCache
+ (id)sharedInstance;
- (unsigned long long)totalCellularUsageForPeriod:(unsigned long long)arg1;
- (void)_clearCache;
- (void)fetchDeviceDataUsageWithCompletion:(/*^block*/ id)arg1;
@end

@interface PSCellularUsage
- (double)totalBytesUsed;
- (double)bytesUsedThisCycle;
- (double)bytesUsedLastCycle;
@end

@interface PSUIAppCellularUsageStatisticsCache
+ (id)sharedInstance;
- (void)fetchDataUsageStatistics;
- (PSCellularUsage *)totalUsage;
@end

@interface PSUICellularController
- (NSString *)callTimeDurationRestrictedToCurrentPeriod:(BOOL)arg1;
@end

@interface PSUICallTimeGroup
- (id)initWithListController:(id)arg1;
- (NSString *)callTimeDurationRestrictedToCurrentPeriod:(BOOL)arg1;
@end