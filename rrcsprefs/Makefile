GO_EASY_ON_ME = 1
ARCHS = armv7 arm64 arm64e

include $(THEOS)/makefiles/common.mk
TARGET = iphone:clang:latest:7.0
SYSROOT = /Users/soh/theos/sdks/iPhoneOS13.0.sdk

BUNDLE_NAME = RRCSPrefs
RRCSPrefs_FILES = RRCSPrefs.mm
RRCSPrefs_INSTALL_PATH = /Library/PreferenceBundles
RRCSPrefs_FRAMEWORKS = UIKit Twitter
RRCSPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/RRCSPrefs.plist$(ECHO_END)
