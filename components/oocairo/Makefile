#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

oocairo_sources := oocairo.c

OBJS_oocairo := $(foreach s,$(oocairo_sources),$(COMPONENT_BUILD_DIR)/$(s).o)

# ---------------------------------------------------------------------------------------------------------------------

OOCAIRO_VERSION := master

# ---------------------------------------------------------------------------------------------------------------------

download:
	@if test -e $(THIRDPARTY_PATH)/oocairo; then \
	  echo -e "\n***\n*** Skipping download-oocairo ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; wget https://github.com/osch/oocairo/archive/$(OOCAIRO_VERSION).tar.gz; \
	                                   tar xzf $(OOCAIRO_VERSION).tar.gz ) && \
	  rm   -rf $(THIRDPARTY_PATH)/oocairo && \
	  mkdir -p $(THIRDPARTY_PATH)/oocairo && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/oocairo-$(OOCAIRO_VERSION)/* $(THIRDPARTY_PATH)/oocairo && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp; \
	fi
# ---------------------------------------------------------------------------------------------------------------------

$(COMPONENT_LIB): $(OBJS_oocairo)

$(COMPONENT_BUILD_DIR)/%.c.o: $(THIRDPARTY_PATH)/oocairo/%.c
	-@mkdir -p $(@D)
	@echo "Compiling $<"
	$(SILENT)$(CC) $< $(BUILD_C_FLAGS) $(CAIRO_FLAGS) -Wno-cast-function-type \
	-D'VERSION="scm-$(BUILD_DATE)"' \
	-Wno-return-type \
	-c -o $@

# ---------------------------------------------------------------------------------------------------------------------

-include $(OBJS_oocairo:%.o=%.d)
