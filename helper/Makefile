ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang:latest:7.0
SYSROOT = /Users/soh/theos/sdks/iPhoneOS13.0.sdk
THEOS_BUILD_DIR = ../Packages
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ReStatsRebornHelper
ReStatsRebornHelper_FILES = ReStatsRebornHelper.xm
ReStatsRebornHelper_FRAMEWORKS = CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk