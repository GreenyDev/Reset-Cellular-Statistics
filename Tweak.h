#import <UIKit/UIKit.h>
#import <SpringBoard/SBApplication.h>

//Timer
@interface RRCSTimerInitializer : NSObject
{
    BOOL enabled;
    BOOL notifyOnTrigger;
    NSTimer *resetTimer;
    NSDate *fireDate;
    BOOL didFinish;
    int cycleType;
    int customCycle;
}
- (id)init;
- (void)loadPreferences;
- (void)setupTimer;
- (void)resetData:(id)sender;
- (void)newTimer;
- (void)prepareNotificationAndSetNewTimer;
@end

//Notification
@interface BBAction : NSObject
+ (id)action;
+ (id)actionWithLaunchBundleID:(NSString *)bundleID;
@end

@interface BBBulletin : NSObject <NSCopying, NSCoding>
@property(copy, nonatomic) NSSet *alertSuppressionAppIDs_deprecated; // @synthesize alertSuppressionAppIDs_deprecated;
@property(nonatomic) unsigned int realertCount_deprecated;           // @synthesize realertCount_deprecated;
@property(retain, nonatomic) NSDate *lastInterruptDate;              // @synthesize lastInterruptDate=_lastInterruptDate;
@property(copy, nonatomic) NSString *bulletinID;                     // @synthesize bulletinID=_bulletinID;
@property(retain, nonatomic) NSDate *expirationDate;                 // @synthesize expirationDate=_expirationDate;
@property(retain, nonatomic) NSDictionary *context;                  // @synthesize context=_context;
@property(nonatomic) BOOL expiresOnPublisherDeath;                   // @synthesize expiresOnPublisherDeath=_expiresOnPublisherDeath;
@property(copy, nonatomic) NSArray *buttons;                         // @synthesize buttons=_buttons;
@property(retain, nonatomic) NSMutableDictionary *actions;           // @synthesize actions=_actions;
@property(copy, nonatomic) NSString *unlockActionLabelOverride;      // @synthesize unlockActionLabelOverride=_unlockActionLabelOverride;
@property(nonatomic) BOOL clearable;                                 // @synthesize clearable=_clearable;
@property(nonatomic) int accessoryStyle;                             // @synthesize accessoryStyle=_accessoryStyle;
@property(retain, nonatomic) NSTimeZone *timeZone;                   // @synthesize timeZone=_timeZone;
@property(nonatomic) BOOL dateIsAllDay;                              // @synthesize dateIsAllDay=_dateIsAllDay;
@property(nonatomic) int dateFormatStyle;                            // @synthesize dateFormatStyle=_dateFormatStyle;
@property(retain, nonatomic) NSDate *recencyDate;                    // @synthesize recencyDate=_recencyDate;
@property(retain, nonatomic) NSDate *endDate;                        // @synthesize endDate=_endDate;
@property(retain, nonatomic) NSDate *date;                           // @synthesize date=_date;
@property(nonatomic) int sectionSubtype;                             // @synthesize sectionSubtype=_sectionSubtype;
@property(nonatomic) int addressBookRecordID;                        // @synthesize addressBookRecordID=_addressBookRecordID;
@property(copy, nonatomic) NSString *publisherBulletinID;            // @synthesize publisherBulletinID=_publisherBulletinID;
@property(copy, nonatomic) NSString *recordID;                       // @synthesize recordID=_publisherRecordID;
@property(copy, nonatomic) NSString *sectionID;                      // @synthesize sectionID=_sectionID;
@property(readonly, nonatomic) int primaryAttachmentType;
@property(copy, nonatomic) NSString *section;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *subtitle;
@property(copy, nonatomic) NSString *title;
@property(nonatomic) BOOL showsMessagePreview;
@property(retain, nonatomic) NSDate *publicationDate;
- (void)setDefaultAction:(BBAction *)arg1;
@end

@interface BBBulletinRequest : BBBulletin
@property(nonatomic) BOOL tentative;
@property(nonatomic) BOOL showsUnreadIndicator;
@property(nonatomic) unsigned int realertCount;
@property(nonatomic) int primaryAttachmentType; // @dynamic primaryAttachmentType;
@end

@interface BBServer : NSObject
- (void)_publishBulletinRequest:(id)arg1 forSectionID:(id)arg2 forDestinations:(unsigned long long)arg3 alwaysToLockScreen:(BOOL)arg4;
- (void)_publishBulletinRequest:(id)arg1 forSectionID:(id)arg2 forDestinations:(unsigned long long)arg3;

- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
- (void)publishBulletinRequest:(id)arg1 destinations:(unsigned long long)arg2;
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2 alwaysToLockScreen:(bool)arg3;
- (void)publishBulletinRequest:(id)arg1 destinations:(unsigned long long)arg2 alwaysToLockScreen:(bool)arg3;
@end

@interface UIApplication (Private)
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end
