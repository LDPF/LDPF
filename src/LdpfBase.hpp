#ifndef LDPF_LUA_BASE_HPP_INCLUDED
#define LDPF_LUA_BASE_HPP_INCLUDED

#include "../../dpf/dgl/Base.hpp"

extern "C" {
    #include "ldpf_base.h"
}


// -----------------------------------------------------------------------
// Define namespace

#ifndef LDPF_NAMESPACE
# define LDPF_NAMESPACE LDPF
#endif

#define START_NAMESPACE_LDPF namespace LDPF_NAMESPACE {
#define END_NAMESPACE_LDPF }
#define USE_NAMESPACE_LDPF using namespace LDPF_NAMESPACE;

// -----------------------------------------------------------------------

// -----------------------------------------------------------------------
START_NAMESPACE_LDPF
// -----------------------------------------------------------------------

typedef LDPF_Data          LuaData;
typedef LDPF_LuaCModule    LuaCModule;
typedef LDPF_LuaLSubModule LuaLSubModule;
typedef LDPF_LuaLModule    LuaLModule;

// -----------------------------------------------------------------------
END_NAMESPACE_LDPF
// -----------------------------------------------------------------------

#endif // LDPF_LUA_BASE_HPP_INCLUDED
