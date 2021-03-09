#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

ifeq ($(shell test -e $(THIRDPARTY_PATH)/pixman/pixman && echo true),true)
include $(THIRDPARTY_PATH)/pixman/pixman/Makefile.sources
endif


libpixman_sources += pixman-mmx.c \
                     pixman-sse2.c \
                     pixman-ssse3.c

OBJS_pixman := $(foreach s,$(libpixman_sources),$(COMPONENT_BUILD_DIR)/$(s).o)


header_files := pixman.h pixman-version.h

COMPONENT_HEADERS := $(foreach h,$(header_files),$(LDPF_ROOT_INC_DIR)/$(h))

ifeq ($(LINUX),true)
  BUILD_C_FLAGS += -D'HAVE_PTHREADS'
endif

ifeq ($(MACOS),true)
  BUILD_C_FLAGS += -D'HAVE_PTHREADS'
endif

# ---------------------------------------------------------------------------------------------------------------------

VERSION := 0.40.0

download:
	@if test -e $(THIRDPARTY_PATH)/pixman; then \
	  echo -e "\n***\n*** Skipping download-pixman ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; wget https://cairographics.org/releases/pixman-$(VERSION).tar.gz; \
	                                   tar xzf pixman-$(VERSION).tar.gz ) && \
	  rm   -rf $(THIRDPARTY_PATH)/pixman && \
	  mkdir -p $(THIRDPARTY_PATH)/pixman && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/pixman-$(VERSION)/* $(THIRDPARTY_PATH)/pixman && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp && \
	  cp $(THIRDPARTY_PATH)/pixman/pixman/pixman-compiler.h pixman-compiler.original.h; \
	fi

# ---------------------------------------------------------------------------------------------------------------------

headers: $(COMPONENT_HEADERS) 

$(LDPF_ROOT_INC_DIR)/%: $(THIRDPARTY_PATH)/pixman/pixman/%
	@mkdir -p $(@D)
	cp $< $@
	
HEADER_OVERRIDES := $(COMPONENT_BUILD_DIR)/include/config.h \
                    $(COMPONENT_BUILD_DIR)/include/pixman-compiler.h \
                    $(COMPONENT_BUILD_DIR)/include/pixman-private.h

$(COMPONENT_BUILD_DIR)/include/%.h: %.h
	@mkdir -p $(@D)
	cp $< $@

$(COMPONENT_BUILD_DIR)/include/%.h: $(THIRDPARTY_PATH)/pixman/pixman/%.h
	@mkdir -p $(@D)
	cp $< $@

# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_pixman)

$(COMPONENT_BUILD_DIR)/%.c.o: $(THIRDPARTY_PATH)/pixman/pixman/%.c $(HEADER_OVERRIDES) $(COMPONENT_HEADERS) 
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) -w $< -I $(COMPONENT_BUILD_DIR)/include/ $(BUILD_C_FLAGS) \
	-msse2 -mssse3 -DHAVE_CONFIG_H -DPIXMAN_EXPORT='' \
	-include $(COMPONENT_BUILD_DIR)/include/config.h \
	-include $(COMPONENT_BUILD_DIR)/include/pixman-private.h  \
	-c -o $@


# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_zlib:%.o=%.d)

# ---------------------------------------------------------------------------------------------------------------------
