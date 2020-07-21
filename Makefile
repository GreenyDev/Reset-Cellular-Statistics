ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang:latest:7.0
THEOS_BUILD_DIR = Packages
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ReStatsReborn ReStatsRebornHelper
ReStatsReborn_FILES = Tweak.xm
ReStatsReborn_FRAMEWORKS = UIKit
ReStatsReborn__LDFLAGS = -lactivator

ReStatsRebornHelper_FILES = ReStatsRebornHelper.xm
ReStatsRebornHelper_FRAMEWORKS = CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += rrcsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
