ifndef LDPF_ALL_ASSIGNED_NAMES
  $(error LDPF_ALL_ASSIGNED_NAMES must be defined)
endif 

# Param $1 : plugins's directory
define LDPF_READ_PLUGIN_INFO
  LDPF_TMP_NAME    := $$(NAME)
  LDPF_TMP_DEPENDS := $$(DEPENDS)
  NAME    :=
  DEPENDS :=
  include $1/info.mk
  ifeq ($$(NAME),)
    $$(error error in $1/info.mk: NAME not defined)
  endif
  ifneq ($$(filter $$(NAME),$$(LDPF_ALL_ASSIGNED_NAMES)),)
    $$(error error in $1/info.mk: name already assigned: $$(NAME))
  endif
  LDPF_ALL_ASSIGNED_NAMES      += $$(NAME)
  LDPF_ALL_PLUGIN_NAMES        += $$(NAME)
  LDPF_PLUGIN_$$(NAME)_DIR     := $1
  LDPF_PLUGIN_$$(NAME)_DEPENDS := $$(DEPENDS)
  
  NAME    := $$(LDPF_TMP_NAME)
  DEPENDS := $$(LDPF_TMP_DEPENDS)
endef

# Param $1: list of plugin directoris
define LDPF_READ_PLUGIN_INFOS
  LDPF_ALL_PLUGIN_NAMES :=
  $(foreach c,$1, \
    $(call LDPF_READ_PLUGIN_INFO,$(c)) \
  )
endef

# Param $1: list of plugin directoris
define LDPF_EVALUATE_PLUGIN_INFOS
  $(eval $(call LDPF_READ_PLUGIN_INFOS,$1))
endef