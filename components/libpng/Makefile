#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

MODULES := png pngerror pngget pngmem pngpread \
           pngread pngrio pngrtran pngrutil pngset \
           pngtrans pngwio pngwrite pngwtran pngwutil

OBJS_libpng := $(foreach s,$(MODULES),$(COMPONENT_BUILD_DIR)/$(s).c.o)

COMPONENT_HEADERS := $(foreach h,png.h \
                                 pngconf.h \
                                 pnglibconf.h \
                                ,$(LDPF_ROOT_INC_DIR)/$(h))


# ---------------------------------------------------------------------------------------------------------------------

VERSION := 1.6.37

download:
	@if test -e $(THIRDPARTY_PATH)/libpng; then \
	  echo -e "\n***\n*** Skipping download-libpng ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; wget https://download.sourceforge.net/libpng/libpng-$(VERSION).tar.xz; \
	                                   unxz -d libpng-$(VERSION).tar.xz; \
  	                                   tar xf  libpng-$(VERSION).tar ) && \
	  rm   -rf $(THIRDPARTY_PATH)/libpng && \
	  mkdir -p $(THIRDPARTY_PATH)/libpng && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/libpng-$(VERSION)/* $(THIRDPARTY_PATH)/libpng && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp; \
	fi

# ---------------------------------------------------------------------------------------------------------------------

headers: $(COMPONENT_HEADERS) 

$(LDPF_ROOT_INC_DIR)/%: $(THIRDPARTY_PATH)/libpng/%
	@mkdir -p $(@D)
	cp $< $@

# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_libpng)

$(COMPONENT_BUILD_DIR)/%.c.o: $(THIRDPARTY_PATH)/libpng/%.c $(COMPONENT_HEADERS)
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) -w $< -I $(COMPONENT_BUILD_DIR) $(BUILD_C_FLAGS) \
	-c -o $@

$(LDPF_ROOT_INC_DIR)/pnglibconf.h: $(THIRDPARTY_PATH)/libpng/scripts/pnglibconf.h.prebuilt
	@mkdir -p $(@D)
	cp $< $@

# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_libpng:%.o=%.d)

# ---------------------------------------------------------------------------------------------------------------------
