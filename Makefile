#!/usr/bin/make -f
# Makefile for LDPF #
# ----------------- #
# Initially created by falkTX
#

BUILD_DATE=$(shell date "+%Y-%m-%dT%H:%M:%S")

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH := ..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.base.mk

# ---------------------------------------------------------------------------------------------------------------------

BUILD_C_FLAGS   += $(LUA_CFLAGS)
BUILD_CXX_FLAGS += $(LUA_CFLAGS)

# ---------------------------------------------------------------------------------------------------------------------

BUILD_C_FLAGS   += $(LDGL_FLAGS) -I.
BUILD_CXX_FLAGS += $(LDGL_FLAGS) -I. -Wno-unused-parameter
LINK_FLAGS      += $(LDGL_LIBS)

ifeq ($(HAVE_CAIRO),true)
  BUILD_C_FLAGS   += $(CAIRO_FLAGS)
  BUILD_CXX_FLAGS += $(CAIRO_FLAGS)
endif

ifeq ($(HAVE_OPENGL),true)
  BUILD_C_FLAGS   += $(OPENGL_FLAGS)
  BUILD_CXX_FLAGS += $(OPENGL_FLAGS)
endif

# ifneq ($(MACOS_OLD),true)
# needed by sofd right now, fix later
# BUILD_CXX_FLAGS += -Wno-type-limits -fpermissive
# endif

ROOT_BUILD_DIR := $(LDPF_ROOT_BUILD_DIR)
ROOT_INC_DIR   := $(LDPF_ROOT_INC_DIR)
LDGL_BUILD_DIR := $(ROOT_BUILD_DIR)/ldgl
LUA_BUILD_DIR  := $(ROOT_BUILD_DIR)/lua
LUA_DIR        := lua
LUA_VERSION    := 5.4.3

# ---------------------------------------------------------------------------------------------------------------------

OBJS_ldgl = \
	$(LDGL_BUILD_DIR)/LuaUIExporter.cpp.o

ifeq ($(MACOS),true)
OBJS_ldgl += $(LDGL_BUILD_DIR)/macos_util.m.o
BUILD_CXX_FLAGS += -D LDPF_MACOS
endif
	
# ---------------------------------------------------------------------------------------------------------------------

lua_sources := lapi lcode lctype ldebug ldo ldump lfunc lgc llex lmem lobject lopcodes lparser \
               lstate lstring ltable ltm lundump lvm lzio \
               lauxlib lbaselib lcorolib ldblib liolib lmathlib loadlib loslib lstrlib ltablib \
               lutf8lib linit

lua_headers := luaconf.h lua.h lauxlib.h lua.hpp lualib.h

OBJS_lua := $(foreach s,$(lua_sources),$(LUA_BUILD_DIR)/$(s).o)

INCS_lua := $(foreach h,$(lua_headers),$(ROOT_INC_DIR)/$(h))

# ---------------------------------------------------------------------------------------------------------------------

POSSIBLE_PHONY_TARGETS := all clean clean-lua clean-ldgl download-lua help

.PHONY: $(POSSIBLE_PHONY_TARGETS)

# ---------------------------------------------------------------------------------------------------------------------

all: $(ROOT_BUILD_DIR)/libldgl.a \
     $(ROOT_BUILD_DIR)/liblua.a \
     $(LUA_BUILD_DIR)/lua

# ---------------------------------------------------------------------------------------------------------------------

help:
	@echo "Possible targets: $(POSSIBLE_PHONY_TARGETS)"

# ---------------------------------------------------------------------------------------------------------------------

download-lua:
	mkdir -p $(LUA_BUILD_DIR)/tmp && \
        ( cd $(LUA_BUILD_DIR)/tmp; wget https://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz; tar xzf lua-$(LUA_VERSION).tar.gz ) && \
        rm -rf $(LUA_DIR) && \
        mkdir -p $(LUA_DIR) && \
        mv $(LUA_BUILD_DIR)/tmp/lua-$(LUA_VERSION)/* $(LUA_DIR) && \
        rm -rf $(LUA_BUILD_DIR)/tmp  && \
        mv $(LUA_DIR)/src/luaconf.h $(LUA_DIR)/src/luaconf.h.original && \
        cp $(LUA_DIR)/src/luaconf.h.original \
           $(LUA_DIR)/src/lua.h \
           $(LUA_DIR)/src/lauxlib.h \
           $(LUA_DIR)/src/lua.hpp \
           $(LUA_DIR)/src/lualib.h \
           luainc


# ---------------------------------------------------------------------------------------------------------------------

$(ROOT_BUILD_DIR)/libldgl.a: $(OBJS_ldgl)
$(ROOT_BUILD_DIR)/liblua.a:  $(OBJS_lua)

$(ROOT_BUILD_DIR)/lib%.a: 
	-@mkdir -p $(@D)
	@echo "Creating $(@F)"
	$(SILENT)rm -f $@
	$(SILENT)$(AR) crs $@ $^

$(ROOT_INC_DIR)/%: luainc/%
	@mkdir -p $(@D)
	cp $< $@

# ---------------------------------------------------------------------------------------------------------------------

$(LDGL_BUILD_DIR)/%.cpp.o: ldgl/%.cpp  $(INCS_lua)
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CXX) $< $(BUILD_CXX_FLAGS) -c -o $@

$(LDGL_BUILD_DIR)/%.m.o: ldgl/%.m
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) $< $(BUILD_C_FLAGS) -c -o $@

$(LUA_BUILD_DIR)/%.o: $(LUA_DIR)/src/%.c $(INCS_lua)
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) -w $< $(BUILD_C_FLAGS) -D_GNU_SOURCE -c -o $@
	
$(LUA_BUILD_DIR)/lua: $(LUA_DIR)/src/lua.c $(ROOT_BUILD_DIR)/liblua.a $(INCS_lua)
	-@mkdir -p $(@D)
	@echo "Building Lua Interpreter"
	$(SILENT)$(CC) -w $(BUILD_C_FLAGS) -D_GNU_SOURCE \
	$(filter-out $(INCS_lua),$^)  $(LINK_FLAGS) -lm -o $@

# ---------------------------------------------------------------------------------------------------------------------

clean-lua:
	rm -rf $(LUA_BUILD_DIR) \
	       $(ROOT_BUILD_DIR)/liblua.a
clean-ldgl:
	rm -rf $(LDGL_BUILD_DIR) \
	       $(ROOT_BUILD_DIR)/libldgl.a

clean: clean-lua clean-ldgl
	
# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_ldgl:%.o=%.d)
-include $(OBJS_lua:%.o=%.d)

# ---------------------------------------------------------------------------------------------------------------------
