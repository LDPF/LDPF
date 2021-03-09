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

lpugl_cairo_sources := lpugl_cairo.c

ifeq ($(MACOS),true)
lpugl_cairo_sources += pugl_cairo.m
else
lpugl_cairo_sources += pugl_cairo.c
endif

OBJS_lpugl_cairo := $(foreach s,$(lpugl_cairo_sources),$(COMPONENT_BUILD_DIR)/$(s).o)

# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_lpugl_cairo)

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

-include $(OBJS_lpugl_cairo:%.o=%.d)
