#!/usr/bin/make -f
# Makefile for LDPF Components #
# --------------------------------------------------------------
#
# To be included from component Makefile
# Current directory must be directory of component's Makefile

# --------------------------------------------------------------
# the vars DPF_PATH, LDPF_PATH and LDPF_ROOT_BUILD_DIR must be defined

ifndef LDPF_ROOT_PATH
  $(error LDPF_ROOT_PATH must be defined)
endif
DPF_PATH            := $(LDPF_ROOT_PATH)/dpf
LDPF_PATH           := $(LDPF_ROOT_PATH)/ldpf
LDPF_ROOT_BUILD_DIR := $(LDPF_ROOT_PATH)/build
THIRDPARTY_PATH     := $(LDPF_ROOT_PATH)/thirdparty

# --------------------------------------------------------------

include $(LDPF_PATH)/Makefile.base.mk

# --------------------------------------------------------------

include info.mk

COMPONENT_BUILD_DIR := $(LDPF_ROOT_BUILD_DIR)/$(COMPONENT)
COMPONENT_LIB       := $(LDPF_ROOT_BUILD_DIR)/lib$(COMPONENT).a
COMPONENT_HEADERS   ?= 

# --------------------------------------------------------------

BUILD_C_FLAGS   += $(LUA_CFLAGS)
BUILD_CXX_FLAGS += $(LUA_CFLAGS)

# --------------------------------------------------------------

ifeq ($(filter-out lua-module native-lua-module, $(TYPE)),)
  IS_LUA_COMPONENT := true
else
  IS_LUA_COMPONENT := false
endif

# --------------------------------------------------------------

ifdef LDPF_LUA_SOURCE_PATH
LDPF_COMPONENT_LUA_SOURCES := $(sort $(patsubst ./%,%,$(shell cd $(LDPF_LUA_SOURCE_PATH) && find . -name "*.lua")))
endif

LDPF_COMPONENT_LUA_SOURCE_FILES := $(foreach s,$(LDPF_COMPONENT_LUA_SOURCES),$(LDPF_LUA_SOURCE_PATH)/$s)

LDPF_GENERATED_FILES_STEMS := $(foreach s,$(LDPF_COMPONENT_LUA_SOURCES),generated_$(subst /,_,$(subst .,_,$(COMPONENT)_$s)))

# --------------------------------------------------------------

.PHONY: all headers clean download


all: headers $(COMPONENT_LIB)


clean:
	rm -rf $(COMPONENT_BUILD_DIR) \
	rm -rf $(COMPONENT_LIB) \
	rm -rf $(COMPONENT_HEADERS)


# ---------------------------------------------------------------------------------------------------------------------

ifeq ($(IS_LUA_COMPONENT),true)
COMPONENT_OBJS := $(COMPONENT_BUILD_DIR)/generated-main-$(COMPONENT).c.o \
                  $(patsubst %, $(COMPONENT_BUILD_DIR)/%.c.o, $(LDPF_GENERATED_FILES_STEMS))
else
COMPONENT_OBJS := 
endif

$(COMPONENT_LIB): $(COMPONENT_OBJS)
	-@mkdir -p $(@D)
	@echo "Creating $(@F)"
	$(SILENT)rm -f $@
	$(SILENT)$(AR) crs $@ $^

define GENERATE_RULE
$(COMPONENT_BUILD_DIR)/$1.c: $(LDPF_LUA_SOURCE_PATH)/$2 \
                             $(LDPF_PATH)/scripts/generateLuaLModule.lua
	@mkdir -p "$$(@D)"
	@echo "Generating $$(@F)"
	$$(SILENT)$(LDPF_ROOT_BUILD_DIR)/lua/lua $(LDPF_PATH)/scripts/generateLuaLModule.lua $(COMPONENT) $$< $1 > $$@.tmp;
	$$(SILENT)mv $$@.tmp $$@
endef

$(foreach s,$(LDPF_COMPONENT_LUA_SOURCES), \
  $(eval $(call GENERATE_RULE,generated_$(subst /,_,$(subst .,_,$(COMPONENT)_$s)),$s)) \
)

ifeq ($(IS_LUA_COMPONENT),true)
$(COMPONENT_BUILD_DIR)/%.c.o: $(COMPONENT_BUILD_DIR)/%.c
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) $< $(BUILD_C_FLAGS) \
	-c -o $@
endif

ifeq ($(IS_LUA_COMPONENT),true)
$(COMPONENT_BUILD_DIR)/generated-main-$(COMPONENT).c: $(LDPF_PATH)/scripts/generateLuaLModules.lua \
                                                      $(LDPF_COMPONENT_DEFINITION_DEPENDENCIES) \
                                                      $(LDPF_COMPONENT_LUA_SOURCE_FILES)
	-@mkdir -p $(@D)
	@echo "Generating $(@F)"
	$(SILENT)$(LDPF_ROOT_BUILD_DIR)/lua/lua $(LDPF_PATH)/scripts/generateLuaLModules.lua $(COMPONENT) $(LDPF_LUA_SOURCE_PATH)/ \
	$(LDPF_COMPONENT_LUA_SOURCE_FILES) > $@.tmp;
	$(SILENT)mv $@.tmp $@
endif

-include $(COMPONENT_OBJS:%.o=%.d)
