#ifndef LDPF_BASE_H_INCLUDED
#define LDPF_BASE_H_INCLUDED

#include <stddef.h>

typedef struct lua_State lua_State;
typedef int (*lua_CFunction) (lua_State *L);

typedef struct {
    size_t               size;
    const unsigned char* bytes;
} LDPF_Data;

typedef struct {
    const char*         moduleName;
    const lua_CFunction openFunc;
} LDPF_LuaCModule;

typedef struct {
    const char*       moduleName;
    const LDPF_Data*  data;
} LDPF_LuaLSubModule;

typedef struct {
    const char*               moduleName;
    const LDPF_LuaLSubModule* subModules;
} LDPF_LuaLModule;


#endif // LDPF_BASE_H_INCLUDED
