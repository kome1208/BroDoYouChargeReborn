TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard
SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk
# THEOS_PACKAGE_SCHEME=rootless
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BroDoYouChargeReborn
$(TWEAK_NAME)_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
