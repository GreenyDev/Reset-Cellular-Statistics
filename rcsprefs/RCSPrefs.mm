#import <Preferences/PSListController.h>

@interface RCSPrefsListController: PSListController {
}
@end

@implementation RCSPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"RCSPrefs" target:self];
	}
	return _specifiers;
}
@end
