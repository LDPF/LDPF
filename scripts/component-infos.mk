ifndef LDPF_ALL_ASSIGNED_NAMES
  $(error LDPF_ALL_ASSIGNED_NAMES must be defined)
endif 

# Param $1 : component's directory
define LDPF_READ_COMPONENT_INFO

  LDPF_TMP_COMPONENT        := $$(COMPONENT)
  LDPF_TMP_TYPE             := $$(TYPE)
  LDPF_TMP_SUBMODULES       := $$(SUBMODULES)
  LDPF_TMP_DEPENDS          := $$(DEPENDS)
  LDPF_TMP_SYSTEM_FEATURES  := $$(SYSTEM_FEATURES)
  LDPF_TMP_LMOD_NAME        := $$(LMOD_NAME)
  
  COMPONENT       :=
  TYPE            := 
  SUBMODULES      :=
  DEPENDS         := 
  SYSTEM_FEATURES :=
  LMOD_NAME       :=

  include $1/info.mk

  ifneq ($$(filter $$(COMPONENT),$$(LDPF_ALL_ASSIGNED_NAMES)),)
    $$(error error in $1/info.mk: component name already assigned: $$(COMPONENT))
  endif
  ifneq ($$(filter $$(SUBMODULES),$$(LDPF_ALL_ASSIGNED_NAMES)),)
    $$(error error in $1/info.mk: component submodule(s) $$(filter $$(SUBMODULES),$$(LDPF_ALL_ASSIGNED_NAMES)) already assigned: $$(COMPONENT))
  endif
  LDPF_ALL_ASSIGNED_NAMES              += $$(COMPONENT)
  LDPF_ALL_ASSIGNED_NAMES              += $$(SUBMODULES)
  LDPF_ALL_COMPONENT_NAMES             += $$(COMPONENT)
  LDPF_ALL_COMPONENT_NAMES2            += $$(COMPONENT) $$(DEPENDS)
  LDPF_ALL_SYSTEM_FEATURES             += $$(SYSTEM_FEATURES)
  
  ifeq ($$(LMOD_NAME),)
    LMOD_NAME := $$(COMPONENT)
  endif

  LDPF_COMPONENT_$$(COMPONENT)_DIR             := $1
  LDPF_COMPONENT_$$(COMPONENT)_TYPE            := $$(TYPE)
  LDPF_COMPONENT_$$(COMPONENT)_DEPENDS         := $$(DEPENDS)
  LDPF_COMPONENT_$$(COMPONENT)_SYSTEM_FEATURES := $$(SYSTEM_FEATURES)
  LDPF_COMPONENT_$$(COMPONENT)_LMOD_NAME       := $$(LMOD_NAME)
  
  $$(foreach s,$$(SUBMODULES), \
    $$(eval LDPF_COMPONENT_$$(s)_LMOD_NAME := $$(s)) \
  )
  ifeq ($$(TYPE),native-lua-module)
    LDPF_ALL_LUA_CMODULES += $$(COMPONENT) $$(SUBMODULES)
    LDPF_ALL_STATIC_LIBS  += $$(COMPONENT)
    LDPF_COMPONENT_$$(COMPONENT)_LUA_CMODULES := $$(COMPONENT) $$(SUBMODULES)
    LDPF_COMPONENT_$$(COMPONENT)_STATIC_LIB   := $$(COMPONENT)
  endif
  ifeq ($$(TYPE),lua-module)
    LDPF_ALL_LUA_LMODULES += $$(COMPONENT)
    LDPF_ALL_STATIC_LIBS  += $$(COMPONENT)
    LDPF_COMPONENT_$$(COMPONENT)_LUA_LMODULES := $$(COMPONENT)
    LDPF_COMPONENT_$$(COMPONENT)_STATIC_LIB   := $$(COMPONENT)
  endif
  ifeq ($$(TYPE),native-lib)
    LDPF_ALL_STATIC_LIBS  += $$(COMPONENT)
    LDPF_COMPONENT_$$(COMPONENT)_STATIC_LIB   := $$(COMPONENT)
  endif

  COMPONENT       := $$(LDPF_TMP_COMPONENT)
  TYPE            := $$(LDPF_TMP_TYPE)
  SUBMODULES      := $$(LDPF_TMP_SUBMODULES)
  DEPENDS         := $$(LDPF_TMP_DEPENDS)
  SYSTEM_FEATURES := $$(LDPF_TMP_SYSTEM_FEATURES)
  LMOD_NAME       := $$(LDPF_TMP_LMOD_NAME)
endef

# Param $1: list of component directoris
define LDPF_READ_COMPONENT_INFOS
  LDPF_ALL_COMPONENT_NAMES :=
  LDPF_ALL_COMPONENT_NAMES2:=
  LDPF_ALL_LUA_CMODULES    :=
  LDPF_ALL_LUA_LMODULES    :=
  LDPF_ALL_SYSTEM_FEATURES :=
  LDPF_ALL_STATIC_LIBS     := 
  
  $(foreach c,$1, \
    $(call LDPF_READ_COMPONENT_INFO,$(c)) \
  )
  # filter out duplicates
  LDPF_ALL_COMPONENT_NAMES := $$(sort $$(LDPF_ALL_COMPONENT_NAMES))
  LDPF_ALL_COMPONENT_NAMES2:= $$(sort $$(LDPF_ALL_COMPONENT_NAMES2))
  LDPF_ALL_SYSTEM_FEATURES := $$(sort $$(LDPF_ALL_SYSTEM_FEATURES))
  LDPF_ALL_LUA_CMODULES    := $$(sort $$(LDPF_ALL_LUA_CMODULES))
  LDPF_ALL_LUA_LMODULES    := $$(sort $$(LDPF_ALL_LUA_LMODULES))
  
  LDPF_MISSING_COMPONENT_NAMES := $$(filter-out $$(LDPF_ALL_COMPONENT_NAMES), $$(LDPF_ALL_COMPONENT_NAMES2))
  
  ifneq ($$(LDPF_MISSING_COMPONENT_NAMES),)
    $$(error missing component dependencies: $$(LDPF_MISSING_COMPONENT_NAMES))
  endif
  
endef


# Param $1: list of component directoris
define LDPF_EVALUATE_COMPONENT_INFOS
  $(eval $(call LDPF_READ_COMPONENT_INFOS,$1))
endef
