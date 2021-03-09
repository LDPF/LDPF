#!/usr/bin/make -f
# Makefile for LDPF #
# ----------------- #

LDPF_MAKEFILE_BASE_INCLUDED := true

# disable builtin rules
.SUFFIXES:

# --------------------------------------------------------------
# the vars DPF_PATH, LDPF_PATH and LDPF_ROOT_BUILD_DIR must be defined

ifndef LDPF_ROOT_PATH
  $(error LDPF_ROOT_PATH must be defined)
endif
DPF_PATH            := $(LDPF_ROOT_PATH)/dpf
LDPF_PATH           := $(LDPF_ROOT_PATH)/ldpf
LDPF_ROOT_BUILD_DIR := $(LDPF_ROOT_PATH)/build
LDPF_ROOT_INC_DIR   := $(LDPF_ROOT_PATH)/build/include
THIRDPARTY_PATH     := $(LDPF_ROOT_PATH)/thirdparty

ifndef PKG_CONFIG
  ifneq ($(shell type pkg-config 2>/dev/null 1>&2 && echo true),true)
    PKG_CONFIG := false
  endif
endif

ifneq ($(DPF_MAKEFILE_BASE_INCLUDED),true)
  include $(DPF_PATH)/Makefile.base.mk
endif

# --------------------------------------------------------------

LUA_CFLAGS :=

ifeq ($(LINUX),true)
  LUA_CFLAGS := -DLUA_USE_LINUX
endif

ifeq ($(WINDOWS),true)
  LUA_CFLAGS := -DLUA_USE_WINDOWS
endif

ifeq ($(MACOS),true)
  LUA_CFLAGS := -DLUA_USE_MACOSX
endif

ifneq ($(LUA_CFLAGS),)
  LUA_CFLAGS += -I$(LDPF_ROOT_INC_DIR)
else
  $(error unsupported platform)
endif

