#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

BUILD_DATE=$(shell date "+%Y-%m-%dT%H:%M:%S")

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

lpugl_sources := async_util.c util.c world.c view.c error.c lpugl_compat.c \
                 lpugl.c

ifeq ($(MACOS),true)
lpugl_sources += pugl.m
else
lpugl_sources += pugl.c
endif

OBJS_lpugl := $(foreach s,$(lpugl_sources),$(COMPONENT_BUILD_DIR)/$(s).o)


# ---------------------------------------------------------------------------------------------------------------------

download:
	@if test -e $(THIRDPARTY_PATH)/lpugl; then \
	  echo -e "\n***\n*** Skipping download-lpugl ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; wget https://github.com/osch/lua-lpugl/archive/master.zip; \
	                                   unzip master.zip; rm master.zip ) && \
	  rm   -rf $(THIRDPARTY_PATH)/lpugl && \
	  mkdir -p $(THIRDPARTY_PATH)/lpugl && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/lua-lpugl-master/* $(THIRDPARTY_PATH)/lpugl && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp; \
	fi

# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_lpugl)

$(COMPONENT_BUILD_DIR)/%.c.o: $(THIRDPARTY_PATH)/lpugl/src/%.c
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) $< $(BUILD_C_FLAGS) -I $(THIRDPARTY_PATH)/lpugl/pugl-repo/include -I $(THIRDPARTY_PATH)/lpugl \
	$(CAIRO_FLAGS) \
	-DLPUGL_VERSION="scm" -DLPUGL_BUILD_DATE="$(BUILD_DATE)" -D'LPUGL_BUILDING_DLL=0' \
	-c -o $@

$(COMPONENT_BUILD_DIR)/%.m.o: $(THIRDPARTY_PATH)/lpugl/src/%.m
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) $< $(BUILD_C_FLAGS) -I $(THIRDPARTY_PATH)/lpugl/pugl-repo/include -I $(THIRDPARTY_PATH)/lpugl \
	$(CAIRO_FLAGS) \
	-DLPUGL_VERSION="scm" -DLPUGL_BUILD_DATE="$(BUILD_DATE)" -D'LPUGL_BUILDING_DLL=0' \
	-Wno-deprecated-declarations \
	-DLPUGL_MACOS_CLASS_SUFFIX="`uuidgen|sed s/-/_/g`" \
	-c -o $@

# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_lpugl:%.o=%.d)
