#!/usr/bin/make -f
# Makefile for LDPF Plugins #
# ---------------------------------------------------------------------------------------------------------------------------------
#
# To be included from plugin Makefile
#
# Current directory must be directory of plugins's Makefile
# or be defined in variable LDPF_PLUGIN_DIR

# ---------------------------------------------------------------------------------------------------------------------------------

ifndef LDPF_PLUGIN_DIR
  LDPF_PLUGIN_DIR := .
endif 

# ---------------------------------------------------------------------------------------------------------------------------------

ifndef LDPF_ROOT_PATH
  $(error LDPF_ROOT_PATH must be defined)
endif

DPF_PATH            := $(LDPF_ROOT_PATH)/dpf
LDPF_PATH           := $(LDPF_ROOT_PATH)/ldpf
LDPF_ROOT_BUILD_DIR := $(LDPF_ROOT_PATH)/build
TARGET_DIR          := $(LDPF_ROOT_PATH)/bin

# ---------------------------------------------------------------------------------------------------------------------------------

# info.mk must define variable NAME, this variable is also
# used from $(DPF_PATH)/Makefile.plugins.mk

include $(LDPF_PLUGIN_DIR)/info.mk

PLUGIN_BUILD_DIR := $(LDPF_ROOT_BUILD_DIR)/$(NAME)
BUILD_DIR        := $(PLUGIN_BUILD_DIR)

# ---------------------------------------------------------------------------------------------------------------------------------

include $(LDPF_PATH)/Makefile.base.mk

# ---------------------------------------------------------------------------------------------------------------------------------

UI_TYPE             := external
DGL_FLAGS           := $(LDPF_UI_FLAGS) \
                       -D'DISTRHO_PLUGIN_HAS_UI=1' \
                       -D'DISTRHO_PLUGIN_HAS_EMBED_UI=1' \
                       -D'DISTRHO_PLUGIN_HAS_EXTERNAL_UI=1'
DGL_LIB             := $(LDPF_ROOT_BUILD_DIR)/libldpf.a 
DGL_LIBS            := 

# ---------------------------------------------------------------------------------------------------------------------------------

include  $(LDPF_PATH)/scripts/assigned-names.mk
include  $(LDPF_PATH)/scripts/component-infos.mk
$(call LDPF_EVALUATE_COMPONENT_INFOS,$(LDPF_COMPONENTS))

include $(LDPF_PATH)/scripts/plugin-component-infos.mk
$(call LDPF_EVALUATE_PLUGIN_COMPONENT_INFOS,$(DEPENDS))

# ---------------------------------------------------------------------------------------------------------------------------------

LDPF_OPENGL_FLAGS := $(OPENGL_FLAGS)
LDPF_OPENGL_LIBS  := $(OPENGL_LIBS)

LDPF_CAIRO_FLAGS := $(CAIRO_FLAGS)
LDPF_CAIRO_LIBS  := $(CAIRO_LIBS)

LDPF_XRENDER_FLAGS := 
LDPF_XRENDER_LIBS  := -lXext -lXrender

LDPF_CORE_VIDEO_FLAGS := 
LDPF_CORE_VIDEO_LIBS  := -framework CoreVideo

# ---------------------------------------------------------------------------------------------------------------------------------

DGL_FLAGS   += $(foreach f,$(LDPF_PLUGIN_SYSTEM_FEATURES),$(LDPF_$(f)_FLAGS))
DGL_LIBS    += $(foreach f,$(LDPF_PLUGIN_SYSTEM_FEATURES),$(LDPF_$(f)_LIBS))

ifeq ($(LINUX),true)
  DGL_LIBS += -lpthread -lX11
endif

ifeq ($(WINDOWS),true)
  DGL_LIBS += -lkernel32 -lgdi32 -luser32
endif

ifeq ($(MACOS),true)
  DGL_LIBS += -lpthread -framework Cocoa
endif

# ---------------------------------------------------------------------------------------------------------------------------------

LDPF_PLUGIN_LUA_SOURCES := $(sort $(patsubst ./%,%,$(shell cd $(LDPF_LUA_SOURCE_PATH) && find . -type f)))

LDPF_PLUGIN_LUA_SOURCE_FILES := $(foreach s,$(LDPF_PLUGIN_LUA_SOURCES),$(LDPF_LUA_SOURCE_PATH)/$s)

LDPF_GENERATED_FILES_STEMS := $(foreach s,$(LDPF_PLUGIN_LUA_SOURCES),generated_$(subst /,_,$(subst .,_,$s)))

# ---------------------------------------------------------------------------------------------------------------------------------

DGL_FLAGS += -D'LDPF_GENERATED_LUA_INIT_PARAMS_HPP="$(BUILD_DIR)/LDPF_GeneratedLuaUIInitParams.hpp"'  \
             $(LUA_CFLAGS)
                 
DGL_LIB   += $(foreach lib,$(LDPF_PLUGIN_STATIC_LIBS), $(LDPF_ROOT_BUILD_DIR)/lib$(lib).a) \
             $(LDPF_ROOT_BUILD_DIR)/liblua.a

FILES_UI += LuaUI.cpp \
            generated-main.c \
            $(patsubst %, %.c, $(LDPF_GENERATED_FILES_STEMS))

# ---------------------------------------------------------------------------------------------------------------------------------

override DPF_PATH   := $(DPF_PATH)
override TARGET_DIR := $(TARGET_DIR)
override BUILD_DIR  := $(PLUGIN_BUILD_DIR)

include $(DPF_PATH)/Makefile.plugins.mk

# ---------------------------------------------------------------------------------------------------------------------------------

all: $(BUILD_DIR)/LDPF_GeneratedLuaUIInitParams.hpp 

$(BUILD_DIR)/LDPF_GeneratedLuaUIInitParams.hpp: $(LDPF_PLUGIN_DIR)/info.mk
	-@mkdir -p $(@D)
	@echo "Generating $(@F)"
	$(SILENT)echo 'extern "C" {' > $@; \
	         $(foreach m,$(LDPF_PLUGIN_LUA_CMODULES), echo '    int luaopen_$(subst .,_,$(m))(lua_State* L);' >> $@; ) \
	         echo '} // extern "C"' >> $@; \
	         echo '' >> $@; \
	         echo 'static const LDPF::LuaCModule LDPF_generatedLuaCModules[] = {' >> $@; \
	         $(foreach m,$(LDPF_PLUGIN_LUA_CMODULES), echo '    { "$(LDPF_COMPONENT_$(m)_LMOD_NAME)", luaopen_$(subst .,_,$(m)) },' >> $@; ) \
	         echo '    { NULL, NULL }' >> $@; \
	         echo '};' >> $@; \
	         echo '' >> $@; \
	         echo 'extern const LDPF::LuaLSubModule LDPF_generatedMainModuleResources[];' >> $@; \
	         echo 'extern const LDPF::LuaLSubModule LDPF_generatedMainModulePackages[];' >> $@; \
	         $(foreach m,$(LDPF_PLUGIN_LUA_LMODULES), echo 'extern const LDPF::LuaLSubModule LDPF_generatedModulePackages_$(m)[];' >> $@; ) \
	         echo '' >> $@; \
	         echo 'static const LDPF::LuaLModule LDPF_generatedLuaLModules[] = {' >> $@; \
	         echo '    { "", LDPF_generatedMainModulePackages },' >> $@; \
	         $(foreach m,$(LDPF_PLUGIN_LUA_LMODULES), echo '    { "$(m)", LDPF_generatedModulePackages_$(m) },' >> $@; ) \
	         echo '    { NULL, NULL }' >> $@; \
	         echo '};' >> $@; \

$(BUILD_DIR)/%.c.o: $(BUILD_DIR)/%.c
	@echo "Compiling $<"
	$(SILENT)$(CC) $< $(BUILD_C_FLAGS) -c -o $@

$(BUILD_DIR)/%.cpp.o: $(LDPF_PATH)/src/%.cpp
	@echo "Compiling $<"
	$(SILENT)$(CXX) $< $(BUILD_CXX_FLAGS) -c -o $@

define GENERATE_RULE
$(BUILD_DIR)/$1.c: $(LDPF_LUA_SOURCE_PATH)/$2 \
                   $(LDPF_PATH)/scripts/generateLuaLModule.lua
	@mkdir -p "$$(@D)"
	@echo "Generating $$(@F)"
	$$(SILENT)$(LDPF_ROOT_BUILD_DIR)/lua/lua $(LDPF_PATH)/scripts/generateLuaLModule.lua '' $$< $1 > $$@.tmp;
	$$(SILENT)mv $$@.tmp $$@
endef

$(foreach s,$(LDPF_PLUGIN_LUA_SOURCES), \
  $(eval $(call GENERATE_RULE,generated_$(subst /,_,$(subst .,_,$s)),$s)) \
)

$(BUILD_DIR)/generated-main.c:$(LDPF_PATH)/scripts/generateLuaLModules.lua \
                              $(LDPF_PLUGIN_DIR)/info.mk \
                              $(LDPF_PLUGIN_LUA_SOURCE_FILES)
	-@mkdir -p $(@D)
	@echo "Generating $(@F)"
	$(SILENT)$(LDPF_ROOT_BUILD_DIR)/lua/lua $(LDPF_PATH)/scripts/generateLuaLModules.lua '' $(LDPF_LUA_SOURCE_PATH)/ \
	$(LDPF_PLUGIN_LUA_SOURCE_FILES) > $@.tmp;
	$(SILENT)mv $@.tmp $@
	
# ---------------------------------------------------------------------------------------------------------------------------------
