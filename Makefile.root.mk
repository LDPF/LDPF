#!/usr/bin/make -f
# To be included from toplevel Makefile for LDPF plugins #
# --------------------------------------------------------------
#

ifndef LDPF_ROOT_PATH
  $(error LDPF_ROOT_PATH must be defined)
endif
DPF_PATH            := $(LDPF_ROOT_PATH)/dpf
LDPF_PATH           := $(LDPF_ROOT_PATH)/ldpf
LDPF_ROOT_BUILD_DIR := $(LDPF_ROOT_PATH)/build

# --------------------------------------------------------------

include $(DPF_PATH)/Makefile.base.mk

# --------------------------------------------------------------

-include $(LDPF_ROOT_PATH)/sandbox-config.mk
include  $(LDPF_ROOT_PATH)/config.mk
include  $(LDPF_PATH)/scripts/assigned-names.mk
include  $(LDPF_PATH)/scripts/component-infos.mk
$(call LDPF_EVALUATE_COMPONENT_INFOS,$(LDPF_COMPONENTS))

include $(LDPF_PATH)/scripts/plugin-infos.mk
$(call LDPF_EVALUATE_PLUGIN_INFOS,$(LDPF_PLUGINS))


# --------------------------------------------------------------

LDPF_COMPONENT_CLEAN_TARGETS        := $(foreach c,$(LDPF_ALL_COMPONENT_NAMES),clean-$(c))
LDPF_COMPONENT_DOWNLOAD_TARGETS     := $(foreach c,$(LDPF_ALL_COMPONENT_NAMES),download-$(c))
LDPF_COMPONENT_DOWNLOAD_ALL_TARGETS := $(foreach c,$(LDPF_ALL_COMPONENT_NAMES),download-all-$(c))
LDPF_PLUGIN_CLEAN_TARGETS           := $(foreach p,$(LDPF_ALL_PLUGIN_NAMES),   clean-$(p))
LDPF_PLUGIN_DOWNLOAD_TARGETS        := $(foreach p,$(LDPF_ALL_PLUGIN_NAMES),   download-for-$(p))

LDPF_ALL_PHONY_TARGETS :=  all ldpf plugins components gen help \
                           $(LDPF_ALL_COMPONENT_NAMES) $(LDPF_ALL_PLUGIN_NAMES) \
                           download-components download-all-components download-lua \
                           $(LDPF_COMPONENT_DOWNLOAD_TARGETS) \
                           $(LDPF_COMPONENT_DOWNLOAD_ALL_TARGETS) \
                           $(LDPF_PLUGIN_DOWNLOAD_TARGETS) \
                           clean clean-components clean-plugins clean-ldpf clean-ldgl clean-lua \
                           $(LDPF_COMPONENT_CLEAN_TARGETS)     $(LDPF_PLUGIN_CLEAN_TARGETS)

.PHONY: $(LDPF_ALL_PHONY_TARGETS)

all: ldpf plugins gen

# --------------------------------------------------------------

download-lua:
	$(MAKE) download-lua -C $(LDPF_PATH)

# --------------------------------------------------------------

download-components: $(LDPF_PLUGIN_DOWNLOAD_TARGETS)

define LDPF_PLUGIN_DOWNLOAD_DEPENDS_RULE
download-for-$(1): $$(foreach c,$$(LDPF_PLUGIN_$(1)_DEPENDS),download-$$(c))
endef

$(foreach p,$(LDPF_ALL_PLUGIN_NAMES), \
  $(eval $(call LDPF_PLUGIN_DOWNLOAD_DEPENDS_RULE,$p)) \
 )

define LDPF_COMPONENT_DOWNLOAD_RULE
ifeq ($$(LDPF_COMPONENT_$(1)_AS_EXTERNAL_DEPENDENCY),true)
download-$1:
	@true
else
download-$1:
	$$(MAKE) download -C $$(LDPF_COMPONENT_$(1)_DIR)
endif
endef

$(foreach c,$(LDPF_ALL_COMPONENT_NAMES), \
  $(eval $(call LDPF_COMPONENT_DOWNLOAD_RULE,$c)) \
 )
	
define LDPF_COMPONENT_DOWNLOAD_DEPENDS_RULE
ifneq ($$(LDPF_COMPONENT_$(1)_AS_EXTERNAL_DEPENDENCY),true)
download-$(1): $$(foreach d,$$(LDPF_COMPONENT_$(1)_DEPENDS),download-$$(d))
endif
endef

$(foreach c,$(LDPF_ALL_COMPONENT_NAMES), \
  $(eval $(call LDPF_COMPONENT_DOWNLOAD_DEPENDS_RULE,$c)) \
 )

# --------------------------------------------------------------

download-all-components: $(LDPF_COMPONENT_DOWNLOAD_ALL_TARGETS)

$(LDPF_COMPONENT_DOWNLOAD_ALL_TARGETS): download-all-%:
	$(MAKE) download -C $(LDPF_COMPONENT_$*_DIR)


# --------------------------------------------------------------

ldpf:
	$(MAKE) -C $(LDPF_PATH)

# --------------------------------------------------------------

components: $(LDPF_ALL_COMPONENT_NAMES)
	
define LDPF_COMPONENT_RULE
ifeq ($$(LDPF_COMPONENT_$(1)_AS_EXTERNAL_DEPENDENCY),true)
$1:
	@true
else
$1:  ldpf $$(LDPF_COMPONENT_$(1)_DEPENDS)
	$$(MAKE) -C $$(LDPF_COMPONENT_$(1)_DIR)
endif
endef

$(foreach c,$(LDPF_ALL_COMPONENT_NAMES), \
  $(eval $(call LDPF_COMPONENT_RULE,$c)) \
 )

# --------------------------------------------------------------

plugins: $(LDPF_ALL_PLUGIN_NAMES)

$(LDPF_ALL_PLUGIN_NAMES): %: ldpf 
	$(MAKE) all -C $(LDPF_PLUGIN_$*_DIR)


define LDPF_PLUGIN_DEPENDS_RULE
$1: $$(LDPF_PLUGIN_$(1)_DEPENDS)
endef

$(foreach p,$(LDPF_ALL_PLUGIN_NAMES), \
  $(eval $(call LDPF_PLUGIN_DEPENDS_RULE,$p)) \
 )

# --------------------------------------------------------------

ifneq ($(CROSS_COMPILING),true)
gen: plugins dpf/utils/lv2_ttl_generator
	@$(CURDIR)/dpf/utils/generate-ttl.sh
ifeq ($(MACOS),true)
	@$(CURDIR)/dpf/utils/generate-vst-bundles.sh
endif

dpf/utils/lv2_ttl_generator:
	$(MAKE) -C dpf/utils/lv2-ttl-generator
else
gen:
endif

# --------------------------------------------------------------

clean-plugins: $(LDPF_PLUGIN_CLEAN_TARGETS)

$(LDPF_PLUGIN_CLEAN_TARGETS): clean-%:
	$(MAKE) clean -C $(LDPF_PLUGIN_$*_DIR)

# --------------------------------------------------------------

clean-components: $(LDPF_COMPONENT_CLEAN_TARGETS)

$(LDPF_COMPONENT_CLEAN_TARGETS): clean-%:
	$(MAKE) clean -C $(LDPF_COMPONENT_$*_DIR)

# --------------------------------------------------------------

clean-ldgl:
	$(MAKE) clean-ldgl -C $(LDPF_PATH)

clean-lua:
	$(MAKE) clean-lua -C $(LDPF_PATH) 

clean-ldpf:
	$(MAKE) clean -C $(LDPF_PATH) 

clean: clean-ldpf \
       clean-components \
       clean-plugins
	$(MAKE) clean -C $(DPF_PATH)/utils/lv2-ttl-generator
	rm -rf bin $(LDPF_ROOT_BUILD_DIR)

# --------------------------------------------------------------

