COMPONENT       := lpugl
TYPE            := native-lua-module
DEPENDS         := 
SYSTEM_FEATURES :=

ifeq ($(MACOS),true)
SYSTEM_FEATURES += CORE_VIDEO
endif
