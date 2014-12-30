ARCHS = armv7 arm64
TARGET = iphone:clang
THEOS_BUILD_DIR = Packages
GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

TWEAK_NAME = AutoStatisticsReset AutoStatisticsResetHelper
AutoStatisticsReset_FILES = Tweak.xm
AutoStatisticsReset_FRAMEWORKS = UIKit

AutoStatisticsResetHelper_FILES = AutoStatisticsResetHelper.xm
AutoStatisticsResetHelper_FRAMEWORKS = CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += rcsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
