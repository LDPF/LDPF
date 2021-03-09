COMPONENT       := cairo
TYPE            := native-lib

ifndef LDPF_COMPONENT_cairo_AS_EXTERNAL_DEPENDENCY
  ifeq ($(LINUX),true)
    LDPF_COMPONENT_cairo_AS_EXTERNAL_DEPENDENCY := true
  else
    LDPF_COMPONENT_cairo_AS_EXTERNAL_DEPENDENCY := false
  endif
endif

ifeq ($(LDPF_COMPONENT_cairo_AS_EXTERNAL_DEPENDENCY),true)
  SYSTEM_FEATURES := CAIRO
else
  DEPENDS := pixman libpng zlib
  ifeq ($(LINUX),true)
    SYSTEM_FEATURES := XRENDER
  endif
endif
