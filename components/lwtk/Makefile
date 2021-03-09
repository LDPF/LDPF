#!/usr/bin/make -f
# Makefile for LDPF Component #
# --------------------------- #
#

# ---------------------------------------------------------------------------------------------------------------------

LDPF_ROOT_PATH   := ../../..

THIS_MAKEFILE := ./Makefile

LDPF_LUA_SOURCE_PATH                   := $(LDPF_ROOT_PATH)/thirdparty/lwtk/src/lwtk
LDPF_COMPONENT_DEFINITION_DEPENDENCIES := $(THIS_MAKEFILE)

# ---------------------------------------------------------------------------------------------------------------------

include $(LDPF_ROOT_PATH)/ldpf/Makefile.components.mk

# ---------------------------------------------------------------------------------------------------------------------

download:
	@if test -e $(THIRDPARTY_PATH)/lwtk; then \
	  echo -e "\n***\n*** Skipping download-lwtk ***\n***\n"; \
	else \
	  mkdir -p $(COMPONENT_BUILD_DIR)/tmp && \
	  ( cd $(COMPONENT_BUILD_DIR)/tmp; wget https://github.com/osch/lua-lwtk/archive/master.zip; \
	                                   unzip master.zip; rm master.zip ) && \
	  rm   -rf $(THIRDPARTY_PATH)/lwtk && \
	  mkdir -p $(THIRDPARTY_PATH)/lwtk && \
	  mv $(COMPONENT_BUILD_DIR)/tmp/lua-lwtk-master/* $(THIRDPARTY_PATH)/lwtk && \
	  rm -rf $(COMPONENT_BUILD_DIR)/tmp; \
	fi

# ---------------------------------------------------------------------------------------------------------------------


