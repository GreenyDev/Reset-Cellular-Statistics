GO_EASY_ON_ME = 1
ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = RCSPrefs
RCSPrefs_FILES = RCSPrefs.mm
RCSPrefs_INSTALL_PATH = /Library/PreferenceBundles
RCSPrefs_FRAMEWORKS = UIKit
RCSPrefs_PRIVATE_FRAMEWORKS = Preferences
RCSPrefs_LIBRARIES = flipswitch

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/RCSPrefs.plist$(ECHO_END)
