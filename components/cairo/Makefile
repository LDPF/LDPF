#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

ifeq ($(shell test -e $(THIRDPARTY_PATH)/cairo/src && echo true),true)
include $(THIRDPARTY_PATH)/cairo/src/Makefile.sources
endif

ifeq ($(LINUX),true)
  cairo_sources += $(cairo_xlib_sources)

  cairo_headers += $(cairo_xlib_headers) \
                   $(cairo_xlib_xrender_headers)
                   
  BUILD_C_FLAGS += -D'CAIRO_HAS_PTHREAD=1' -D'HAS_PIXMAN_GLYPHS=1' -D'CAIRO_HAS_INTERPRETER=1'
endif

ifeq ($(WINDOWS),true)
  cairo_sources += $(cairo_win32_sources) \
                   $(cairo_win32_font_sources)

  cairo_headers += $(cairo_win32_headers)
endif

ifeq ($(MACOS),true)
  cairo_sources += $(cairo_quartz_sources) \
                   $(cairo_quartz_image_sources) \
                   $(cairo_quartz_font_sources)

  cairo_headers += $(cairo_quartz_headers) \
                   $(cairo_quartz_image_headers)
  
  BUILD_C_FLAGS += -D'CAIRO_HAS_PTHREAD=1'
endif

OBJS_cairo := $(foreach s,$(cairo_sources) \
                          $(cairo_ps_sources) \
                          $(cairo_png_sources) \
                          $(cairo_svg_sources) \
                          $(cairo_pdf_sources) \
                          $(cairo_script_sources) \
                         ,$(COMPONENT_BUILD_DIR)/$(s).o)


header_files := cairo.h cairo-version.h

COMPONENT_HEADERS := $(foreach h,$(cairo_headers) \
                                 $(cairo_ps_headers) \
                                 $(cairo_pdf_headers) \
                                 $(cairo_svg_headers) \
                                 $(cairo_script_headers) \
                                 cairo-features.h \
                                 cairo-version.h \
                                ,$(LDPF_ROOT_INC_DIR)/$(h))

# ---------------------------------------------------------------------------------------------------------------------

VERSION := 1.17.4

download:
	@if test -e $(THIRDPARTY_PATH)/cairo; then \
	  echo -e "\n***\n*** Skipping download-cairo ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; wget https://cairographics.org/snapshots/cairo-$(VERSION).tar.xz; \
	                                   unxz -d cairo-$(VERSION).tar.xz;\
	                                   tar  xf cairo-$(VERSION).tar ) && \
	  rm   -rf $(THIRDPARTY_PATH)/cairo && \
	  mkdir -p $(THIRDPARTY_PATH)/cairo && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/cairo-$(VERSION)/* $(THIRDPARTY_PATH)/cairo && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp; \
	fi

# ---------------------------------------------------------------------------------------------------------------------

headers: $(COMPONENT_HEADERS) 

$(LDPF_ROOT_INC_DIR)/%: $(THIRDPARTY_PATH)/cairo/src/%
	@mkdir -p $(@D)
	cp $< $@

ifeq ($(LINUX),true)
$(LDPF_ROOT_INC_DIR)/%.h: %-linux.h
	@mkdir -p $(@D)
	cp $< $@
endif

ifeq ($(WINDOWS),true)
$(LDPF_ROOT_INC_DIR)/%.h: %-mingw.h
	@mkdir -p $(@D)
	cp $< $@
endif

ifeq ($(MACOS),true)
$(LDPF_ROOT_INC_DIR)/%.h: %-macos.h
	@mkdir -p $(@D)
	cp $< $@
endif

# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_cairo)

$(COMPONENT_BUILD_DIR)/%.c.o: $(THIRDPARTY_PATH)/cairo/src/%.c $(COMPONENT_HEADERS)
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) -w $< $(BUILD_C_FLAGS)  -I . -I $(THIRDPARTY_PATH)/cairo/src/ \
	-D'HAVE_STDINT_H' -D'HAVE_INTTYPES_H' -D'HAVE_UINT64_T' \
	-c -o $@



# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_cairo:%.o=%.d)

# ---------------------------------------------------------------------------------------------------------------------
