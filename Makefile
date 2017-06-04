include $(THEOS)/makefiles/common.mk
export SIMULATOR = 0

Twig_CFLAGS = -fobjc-arc

ifeq ($(SIMULATOR),1)
	export TARGET = simulator:clang:latest:10.0
	export ARCHS = x86_64
else
	export TARGET = iphone:latest:10.0
	export ARCHS = armv7 arm64
endif

TWEAK_NAME = Twig
Twig_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
