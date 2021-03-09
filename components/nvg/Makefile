#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

nvg_sources := lua-nanovg.c nanovg/src/nanovg.c

OBJS_nvg := $(foreach s,$(nvg_sources),$(COMPONENT_BUILD_DIR)/$(s).o)

# ---------------------------------------------------------------------------------------------------------------------

download:
	@if test -e $(THIRDPARTY_PATH)/nvg; then \
	  echo -e "\n***\n*** Skipping download-nvg ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; git clone --recurse-submodules https://github.com/osch/lua-nanovg.git ) && \
	  rm   -rf $(THIRDPARTY_PATH)/nvg && \
	  mkdir -p $(THIRDPARTY_PATH)/nvg && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/lua-nanovg/* $(THIRDPARTY_PATH)/nvg && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp; \
	fi

# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_nvg)

$(COMPONENT_BUILD_DIR)/%.c.o: $(THIRDPARTY_PATH)/nvg/%.c
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) $< $(BUILD_C_FLAGS) -DLBLIB_API='' \
	-Wno-misleading-indentation -Wno-unused-parameter -Wno-sign-compare \
	-Wno-shift-negative-value -Wno-implicit-fallthrough \
	-I $(THIRDPARTY_PATH)/nvg -c -o $@

# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_nvg:%.o=%.d)
