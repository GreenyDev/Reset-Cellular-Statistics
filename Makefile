ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang:latest:7.0
THEOS_BUILD_DIR = Packages
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ReStats ReStatsHelper
ReStats_FILES = Tweak.xm
ReStats_FRAMEWORKS = UIKit
ReStats__LDFLAGS = -lactivator

ReStatsHelper_FILES = ReStatsHelper.xm
ReStatsHelper_FRAMEWORKS = CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += rcsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
