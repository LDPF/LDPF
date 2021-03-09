
# Param $1: component's name
define LDPF_COLLECT_PLUGIN_COMPONENT_INFO
  ifeq ($$(LDPF_COMPONENT_$1_AS_EXTERNAL_DEPENDENCY),true)
     LDPF_PLUGIN_SYSTEM_FEATURES   += $$(LDPF_COMPONENT_$1_SYSTEM_FEATURES)
  else
    ifneq ($$(filter-out $$(LDPF_ALL_COMPONENT_NAMES),$1),)
      $$(error unknown component name $1)
    endif
    ifeq ($$(filter $1,$$(LDPF_PLUGIN_COMPONENT_NAMES)),)
      LDPF_PLUGIN_COMPONENT_NAMES += $1
      ifeq ($$(LDPF_COMPONENT_$1_TYPE),native-lua-module)
        LDPF_PLUGIN_LUA_CMODULES    += $$(LDPF_COMPONENT_$1_LUA_CMODULES)
        LDPF_PLUGIN_STATIC_LIBS     += $$(LDPF_COMPONENT_$1_STATIC_LIB)
      endif
      ifeq ($$(LDPF_COMPONENT_$1_TYPE),lua-module)
        LDPF_PLUGIN_LUA_LMODULES    += $$(LDPF_COMPONENT_$1_LUA_LMODULES)
        LDPF_PLUGIN_STATIC_LIBS     += $$(LDPF_COMPONENT_$1_STATIC_LIB)
      endif
      ifeq ($$(LDPF_COMPONENT_$1_TYPE),native-lib)
        LDPF_PLUGIN_STATIC_LIBS     += $$(LDPF_COMPONENT_$1_STATIC_LIB)
      endif
      LDPF_PLUGIN_SYSTEM_FEATURES   += $$(LDPF_COMPONENT_$1_SYSTEM_FEATURES)
      $$(foreach d,$$(LDPF_COMPONENT_$1_DEPENDS), \
        $$(eval $$(call LDPF_COLLECT_PLUGIN_COMPONENT_INFO,$$d)) \
      )
    endif
  endif
endef

define LDPF_COLLECT_PLUGIN_COMPONENT_INFOS
  LDPF_PLUGIN_COMPONENT_NAMES :=
  LDPF_PLUGIN_LUA_CMODULES    :=
  LDPF_PLUGIN_LUA_LMODULES    :=
  LDPF_PLUGIN_STATIC_LIBS     :=
  LDPF_PLUGIN_SYSTEM_FEATURES :=

  $(foreach c,$1, \
    $$(eval $$(call LDPF_COLLECT_PLUGIN_COMPONENT_INFO,$c)) \
  )
endef

# Param $1: list of component names for plugin
define LDPF_EVALUATE_PLUGIN_COMPONENT_INFOS
  $(eval $(call LDPF_COLLECT_PLUGIN_COMPONENT_INFOS,$1))
endef
