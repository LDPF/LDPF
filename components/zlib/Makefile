#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

MODULES := adler32 compress crc32 deflate gzclose gzlib gzread gzwrite infback inffast inflate \
           inftrees trees uncompr zutil

OBJS_zlib := $(foreach s,$(MODULES),$(COMPONENT_BUILD_DIR)/$(s).c.o)

COMPONENT_HEADERS := $(foreach h,zlib.h \
                                 zconf.h \
                                ,$(LDPF_ROOT_INC_DIR)/$(h))

# ---------------------------------------------------------------------------------------------------------------------

VERSION := 1.2.11

download:
	@if test -e $(THIRDPARTY_PATH)/zlib; then \
	  echo -e "\n***\n*** Skipping download-zlib ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; wget https://zlib.net/zlib-$(VERSION).tar.xz; \
	                                   unxz -d zlib-$(VERSION).tar.xz; \
                                           tar xf  zlib-$(VERSION).tar ) && \
	  rm   -rf $(THIRDPARTY_PATH)/zlib && \
	  mkdir -p $(THIRDPARTY_PATH)/zlib && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/zlib-$(VERSION)/* $(THIRDPARTY_PATH)/zlib && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp; \
	fi

# ---------------------------------------------------------------------------------------------------------------------

headers: $(COMPONENT_HEADERS) 

$(LDPF_ROOT_INC_DIR)/%: $(THIRDPARTY_PATH)/zlib/%
	@mkdir -p $(@D)
	cp $< $@

# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_zlib)

$(COMPONENT_BUILD_DIR)/%.c.o: $(THIRDPARTY_PATH)/zlib/%.c $(COMPONENT_HEADERS)
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) -w $< $(BUILD_C_FLAGS) \
	-c -o $@


# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_zlib:%.o=%.d)

# ---------------------------------------------------------------------------------------------------------------------
