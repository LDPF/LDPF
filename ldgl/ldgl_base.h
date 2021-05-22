#ifndef LDGL_BASE_H_INCLUDED
#define LDGL_BASE_H_INCLUDED

#include <stddef.h>

typedef struct lua_State lua_State;
typedef int (*lua_CFunction) (lua_State *L);

typedef struct {
    size_t               size;
    const unsigned char* bytes;
} LDGL_Data;

typedef struct {
    const char*         moduleName;
    const lua_CFunction openFunc;
} LDGL_LuaCModule;

typedef struct {
    const char*       moduleName;
    const LDGL_Data*  data;
} LDGL_LuaLSubModule;

typedef struct {
    const char*               moduleName;
    const LDGL_LuaLSubModule* subModules;
} LDGL_LuaLModule;


#endif // LDGL_BASE_H_INCLUDED
