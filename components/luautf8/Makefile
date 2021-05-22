#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

luautf8_sources := lutf8lib.c

OBJS_luautf8 := $(foreach s,$(luautf8_sources),$(COMPONENT_BUILD_DIR)/$(s).o)

# ---------------------------------------------------------------------------------------------------------------------

LUAUTF8_VERSION  := 0.1.3

# ---------------------------------------------------------------------------------------------------------------------

download:
	@if test -e $(THIRDPARTY_PATH)/luautf8; then \
	  echo -e "\n***\n*** Skipping download-luautf8 ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; wget https://github.com/starwing/luautf8/archive/$(LUAUTF8_VERSION).tar.gz; \
	                                   tar xzf $(LUAUTF8_VERSION).tar.gz ) && \
	  rm   -rf $(THIRDPARTY_PATH)/luautf8 && \
	  mkdir -p $(THIRDPARTY_PATH)/luautf8 && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/luautf8-$(LUAUTF8_VERSION)/* $(THIRDPARTY_PATH)/luautf8 && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp; \
	fi
# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_luautf8)

$(COMPONENT_BUILD_DIR)/%.c.o: $(THIRDPARTY_PATH)/luautf8/%.c
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) $< $(BUILD_C_FLAGS) $(CAIRO_FLAGS) \
	               -Dluaopen_utf8=luaopen_luautf8 \
	               -Wno-implicit-fallthrough \
	               -Wno-unused-but-set-variable \
	               -Wno-maybe-uninitialized \
	-c -o $@

# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_luautf8:%.o=%.d)
