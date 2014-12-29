ARCHS = armv7 arm64
TARGET = iphone:clang:latest:latest
THEOS_BUILD_DIR = Packages
GO_EASY_ON_ME = 1
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = AutoStatisticsReset
AutoStatisticsReset_FILES = Tweak.xm
AutoStatisticsReset_FRAMEWORKS = Foundation CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += rcsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
