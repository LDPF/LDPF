COMPONENT       := lpugl_cairo
TYPE            := native-lua-module
DEPENDS         := lpugl oocairo cairo

ifeq ($(MACOS),true)
SYSTEM_FEATURES += OPENGL
endif
