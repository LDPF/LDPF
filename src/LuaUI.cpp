#include <stdio.h>
#include <stdlib.h>

#include <lua.hpp>

#include "LuaUI.hpp"

#ifdef LDPF_MACOS
   #include "ldpf_macos_util.h"
#endif

// -----------------------------------------------------------------------
START_NAMESPACE_LDPF
// -----------------------------------------------------------------------

extern "C" {

struct ldpf_luadata
{
    ldpf_luadata(LuaUI* luaUI)
        : active(true),
          parentWinId(luaUI->getParentWindowHandle()),
          luaUI(luaUI),
          ldpf_ref(0),
          lmods_ref(0)
    {}
    bool          active;
    intptr_t      parentWinId;
    LuaUI*        luaUI;
    
    int           ldpf_ref;
    int           lmods_ref;
    int           lres_ref;
};

// -----------------------------------------------------------------------

/*
** Message handler used to run all chunks
*/
static int ldpf_msghandler(lua_State* L) 
{
  const char* msg = lua_tostring(L, 1);
  if (msg == NULL) {  /* is error object not a string? */
    if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
        lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
      return 1;  /* that is the message */
    else
      msg = lua_pushfstring(L, "(error object is a %s value)",
                               luaL_typename(L, 1));
  }
  luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
  return 1;  /* return the traceback */
}

// -----------------------------------------------------------------------

static int ldpf_callSetParam(lua_State* L)
{
    ldpf_luadata* luadata = (ldpf_luadata*)lua_touserdata(L, lua_upvalueindex(1));
    luaL_checkinteger(L, 1);
    luaL_checknumber(L, 2);
    try {
         if (luadata && luadata->active) {
            uint32_t index = lua_tointeger(L, 1);
            float    value = lua_tonumber(L, 2);
            luadata->luaUI->setParameterValue(index, value);
         }
        return 0;
    } catch (...) {
        return luaL_error(L, "Unexpected C++ exception while calling 'setParameterValue'");
    }
}

// -----------------------------------------------------------------------

static int ldpf_callSetSize(lua_State* L)
{
    ldpf_luadata* luadata = (ldpf_luadata*)lua_touserdata(L, lua_upvalueindex(1));
    luaL_checknumber(L, 1);
    luaL_checknumber(L, 2);
    try {
         if (luadata && luadata->active) {
            int  width  = floor(lua_tonumber(L, 1)+0.5);
            int  height = floor(lua_tonumber(L, 2)+0.5);
            luadata->luaUI->setSize(width, height);
         }
        return 0;
    } catch (...) {
        return luaL_error(L, "Unexpected C++ exception while calling 'setParameterValue'");
    }
}
// -----------------------------------------------------------------------

static int ldpf_callClose(lua_State* L)
{
    ldpf_luadata* luadata = (ldpf_luadata*)lua_touserdata(L, lua_upvalueindex(1));
    try {
        if (luadata && luadata->active) {
            luadata->luaUI->close();
        }
        return 0;
    } catch (...) {
        return luaL_error(L, "Unexpected C++ exception while calling 'close'");
    }
}

// -----------------------------------------------------------------------

static int ldpf_package_searcher(lua_State* L)
{
    ldpf_luadata* luadata = (ldpf_luadata*)lua_touserdata(L, lua_upvalueindex(1));
    lua_rawgeti(L, LUA_REGISTRYINDEX, luadata->lmods_ref);                    // -> lmods
    lua_pushvalue(L, 1);                                                      // -> lmods, modName 
    if (lua_rawget(L, -2) == LUA_TLIGHTUSERDATA) {                            // -> lmods, s
        const LuaLSubModule* s = (const LuaLSubModule*)lua_touserdata(L, -1); // -> lmods, s
        luaL_loadbuffer(L, (const char*)s->data->bytes, 
                                        s->data->size, s->moduleName);        // -> lmods, s, loader
        return 1;
    } else {
        return 0;
    }
}

// -----------------------------------------------------------------------

static int ldpf_callGetResource(lua_State* L)
{
    ldpf_luadata* luadata = (ldpf_luadata*)lua_touserdata(L, lua_upvalueindex(1));
    if (luadata && luadata->active) {
        luaL_checkstring(L, 1);
        lua_rawgeti(L, LUA_REGISTRYINDEX, luadata->lres_ref);                     // -> lres
        lua_pushvalue(L, 1);                                                      // -> lres, resName 
        if (lua_rawget(L, -2) == LUA_TLIGHTUSERDATA) {                            // -> lres, res
            const LuaLSubModule* r = (const LuaLSubModule*)lua_touserdata(L, -1); // -> lres, res
            lua_pushlightuserdata(L, (void*)r->data->bytes);                      // -> lres, res, bytes
            lua_pushinteger(L, r->data->size);                                    // -> lres, res, bytes, size
            return 2;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}
// -----------------------------------------------------------------------

static int ldpf_init_lmod(lua_State* L)
{
    lua_newtable(L); // -> ldpf
    return 1;
}

// -----------------------------------------------------------------------

static int ldpf_init(lua_State* L)
{
    ldpf_luadata*             luadata    = (ldpf_luadata*)lua_touserdata(L, 1);
    const LuaUI::InitParams*  initParams = (LuaUI::InitParams*)lua_touserdata(L, 2);
    
    const char* luaPath = initParams->luaPath;
    if (initParams->luaPathEnvVar) {
        const char* pathFromEnv = getenv(initParams->luaPathEnvVar);
        if (pathFromEnv) {
            luaPath = pathFromEnv;
        }
    }

    lua_newtable(L);                                            // -> lmods
    if (initParams->lmodules) {
        const LuaLModule* m0 = initParams->lmodules;
        const LuaLModule* m  = m0; 
        while (m->moduleName) ++m;  // reverse order
        while (m > m0) {
            --m;
            const LuaLSubModule* s0 = m->subModules;
            const LuaLSubModule* s  = s0;
            while (s->moduleName) ++s;  // reverse order
            while (s > s0) {
                --s;
                lua_pushlightuserdata(L, (void*)s);             // -> lmods, s
                lua_setfield(L, -2, s->moduleName);             // -> lmods
            }
        }
    }                                                           // -> lmods
    luadata->lmods_ref = luaL_ref(L, LUA_REGISTRYINDEX);        // -> 

    lua_newtable(L);                                            // -> lres
    if (initParams->lmodules) {
        const LuaLSubModule* r = initParams->resources;
        while (r->moduleName) {
            lua_pushlightuserdata(L, (void*)r);                 // -> lres, s
            lua_setfield(L, -2, r->moduleName);                 // -> lres
            ++r;
        }
    }                                                           // -> lres
    luadata->lres_ref = luaL_ref(L, LUA_REGISTRYINDEX);         // -> 

    luaL_requiref(L, LUA_LOADLIBNAME, luaopen_package, true);   // -> package
    lua_getfield(L, -1, "preload");                             // -> package, preload

    for (const LuaCModule* m = initParams->cmodules; m && m->moduleName; ++m) {
        lua_pushcfunction(L, m->openFunc);                      // -> package, preload, openFunc
        lua_setfield(L, -2,  m->moduleName);                    // -> package, preload
    }                                                           // -> package, preload
    lua_pop(L, 1);                                              // -> package
    lua_getfield(L, -1, "searchers");                           // -> package, searchers
    int searcherIndex;
    if (luaPath) {
        searcherIndex = 3;
        lua_pushnil(L);                                         // -> package, searchers, nil
        lua_rawseti(L, -2, 4);                                  // -> package, searchers, 
    } else {
        searcherIndex = 2;
        lua_pushnil(L);                                         // -> package, searchers, nil
        lua_rawseti(L, -2, 3);                                  // -> package, searchers, 
    }
    lua_pushlightuserdata(L, luadata);                          // -> package, searchers, luadata
    lua_pushcclosure(L, ldpf_package_searcher, 1);              // -> package, searchers, searcher
    lua_rawseti(L, -2, searcherIndex);                          // -> package, searchers
    lua_pop(L, 1);                                              // -> package
    if (luaPath) {
        lua_pushstring(L, luaPath);                             // -> package, newPath
        lua_setfield(L, -2, "path");                            // -> package
    }
    lua_pop(L, 1);                                              // ->
    
    luaL_requiref(L, "ldpf", ldpf_init_lmod, false);            // -> ldpf
    if (luadata->parentWinId) {
        lua_pushlightuserdata(L, (void*) luadata->parentWinId); // -> ldpf, parentWinId
        lua_setfield(L, -2, "parentWindowId");                  // -> ldpf
    }                                                           // -> ldpf
    lua_pushlightuserdata(L, luadata);                          // -> ldpf, luadata
    lua_pushcclosure(L, ldpf_callSetParam, 1);                  // -> ldpf, setParam
    lua_setfield(L, -2, "setParameterValue");                   // -> ldpf
                                                                // -> ldpf
    lua_pushlightuserdata(L, luadata);                          // -> ldpf, luadata
    lua_pushcclosure(L, ldpf_callSetSize, 1);                   // -> ldpf, setSize
    lua_setfield(L, -2, "setSize");                             // -> ldpf
                                                                // -> ldpf
    lua_pushlightuserdata(L, luadata);                          // -> ldpf, luadata
    lua_pushcclosure(L, ldpf_callGetResource, 1);               // -> ldpf, getResource
    lua_setfield(L, -2, "getResource");                         // -> ldpf
                                                                // -> ldpf
    lua_pushlightuserdata(L, luadata);                          // -> ldpf, luadata
    lua_pushcclosure(L, ldpf_callClose, 1);                     // -> ldpf, getResource
    lua_setfield(L, -2, "close");                               // -> ldpf
                                                                // -> ldpf
    luadata->ldpf_ref = luaL_ref(L, LUA_REGISTRYINDEX);         // -> 
    
    // invoke plugin main module
    lua_getglobal(L, "require");                                // -> require
    lua_pushstring(L, "main");                                  // -> require, "main"
    lua_call(L, 1, 0);                                          // -> 

    return 0;
}

} // extern "C"


class LuaUI::Internal
{
public:
    Internal(const InitParams* initParams, LuaUI* luaUI)
             
        : initParams(initParams),
          luaUI(luaUI),
          luadata(luaUI),
          windowSizeScaleFactor(1),
          initialized(false),
          L(NULL)
    {
    #ifdef LDPF_MACOS
        // We are always operating in unscaled pixels but for
        // MacOS the windows sizes have to be normalized.
        windowSizeScaleFactor = LDPF_getScreenScaleFactor();
    #endif
        assureInitialized();
    }
    
    bool assureInitialized() {
        if (!initialized) {
            initialized = true;
            L = luaL_newstate();
            if (L) {
                luaL_openlibs(L);
                lua_pushcfunction(L, ldpf_msghandler);        // -> msgh
                int msgh = lua_gettop(L);
                lua_pushcfunction(L, &ldpf_init);             // -> msgh, initFunc
                int argc = 0;
                lua_pushlightuserdata(L, &luadata); ++argc;  // -> msgh, initFunc, args..
                lua_pushlightuserdata(L, (void*)initParams); ++argc;
                int rc = lua_pcall(L, argc, 0, msgh);         // -> msgh, ?
                if (rc != LUA_OK) {                           // -> msgh, err
                    fprintf(stderr, "Error while initializing Lua plugin gui: %s\n",
                                     lua_tostring(L, -1));
                    lua_close(L);
                    L = NULL;
                    return false;
                }                                             // -> msgh
                lua_pop(L, 1);                                // -> 
                return true;
            }
            else {
                fprintf(stderr, "Severe error while initializing Lua plugin gui.\n");
                return false;
            }
        } else {
            return L != NULL;
        }
    }

    int call(const char* funcName, int nargs = 0) {                              // -> args...
        if (lua_rawgeti(L, LUA_REGISTRYINDEX, luadata.ldpf_ref) == LUA_TTABLE) { // -> args..., ldpf
            lua_insert(L, -(nargs+1));                                           // -> ldpf, args...
            lua_pushcfunction(L, ldpf_msghandler);                               // -> ldpf, args..., msgh
            lua_insert(L, -(nargs+1));                                           // -> ldpf, msgh, args...
            if (lua_getfield(L, -(nargs+2), funcName) == LUA_TFUNCTION) {        // -> ldpf, msgh, args..., func
                lua_insert(L, -(nargs+1));                                       // -> ldpf, msgh, func, args...
                int msgh = -(nargs+2);                                           // -> ldpf, msgh, func, args...
                int rc = lua_pcall(L, nargs, 1, msgh);                           // -> ldpf, msgh, ?
                if (rc != LUA_OK) {                                              // -> ldpf, msgh, err
                    fprintf(stderr, "Error while calling ldpf.%s(): %s\n",
                                     funcName, lua_tostring(L, -1));
                    lua_pop(L, 3);
                    return 0;                 
                }                   // -> ldpf, msgh, rslt
                lua_replace(L, -3); // -> rslt, msgh
                lua_pop(L, 1);      // -> rslt
                return 1;
            } else {                  // -> ldpf, msgh, args..., ?
                lua_pop(L, 3+nargs);  // -> 
                return 0;
            }
        } else {             // -> ?
            lua_pop(L, 1);   // ->
            return 0;
        }
    }
    

    uintptr_t getNativeWindowHandle() {
        if (!L) return 0;
        int numberResults = call("getNativeWindowHandle");
        if (numberResults > 0) {
            void* rslt = lua_touserdata(L, -1);
            lua_pop(L, numberResults);
            return (uintptr_t) rslt;
        } else {
            return 0;
        }
    }
    
    void parameterChanged(uint32_t index, float value) {
        if (!L) return;
        lua_pushinteger(L, index);
        lua_pushnumber(L, value);
        int numberResults = call("parameterChanged", 2);
        lua_pop(L, numberResults);
    }

    // false for termination
    void idle() {
        if (!L) return;
        if (lua_rawgeti(L, LUA_REGISTRYINDEX, luadata.ldpf_ref) == LUA_TTABLE) { // -> ldpf
            lua_pushcfunction(L, ldpf_msghandler);                               // -> ldpf, msgh
            int msgh = lua_gettop(L);
            if (lua_getfield(L, -2, "idle") == LUA_TFUNCTION) {                  // -> ldpf, msgh, idle
                int rc = lua_pcall(L, 0, 1, msgh);                               // -> ldpf, msgh, ?
                if (rc != LUA_OK) {                                              // -> ldpf, msgh, err
                    fprintf(stderr, "Error while calling ldpf.idle(): %s\n",
                                     lua_tostring(L, -1));
                }                                                                // -> ldpf, msgh, rslt
            }                                                                    // -> ldpf, msgh, ?
            lua_pop(L, 3);   // -> 
        } else {             // -> ?
            lua_pop(L, 1);   // ->
        }
    }
    
    ~Internal() 
    {
        if (L) {
            lua_close(L);
            L = NULL;
        }
        initialized = false;
    }
    
private:
    const InitParams* const initParams;
    LuaUI* const            luaUI;
    
    ldpf_luadata         luadata;

    double windowSizeScaleFactor;

    bool initialized;
 
    lua_State* L;
};

// -----------------------------------------------------------------------

LuaUI::LuaUI(const LuaUI::InitParams* initParams)
    : UI(1, 1),
      internal(new Internal(initParams, this))
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
//    setSize(100,50);
}

// -----------------------------------------------------------------------

LuaUI::~LuaUI()
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
    delete internal;
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
}

uintptr_t LuaUI::getNativeWindowHandle() const noexcept
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
    return internal->getNativeWindowHandle();
}

void LuaUI::sizeChanged(uint width, uint height)
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
}

void LuaUI::focus()
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
}



void LuaUI::parameterChanged(uint32_t index, float value)
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
    printf("is resizable %d\n", isResizable());
    internal->parameterChanged(index, value);
}


#if DISTRHO_PLUGIN_WANT_PROGRAMS
void LuaUI::programLoaded(uint32_t index) 
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
}
#endif

#if DISTRHO_PLUGIN_WANT_STATE
void LuaUI::stateChanged(const char* key, const char* value)
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
}
#endif

void LuaUI::sampleRateChanged(double newSampleRate)
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
}

void LuaUI::uiIdle()
{
//    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
    internal->idle();
}

void LuaUI::uiScaleFactorChanged(double scaleFactor)
{
    printf("----------------- LuaUI line %d ----------------\n", __LINE__);
}

// -----------------------------------------------------------------------
END_NAMESPACE_LDPF
// -----------------------------------------------------------------------


// -----------------------------------------------------------------------
START_NAMESPACE_DISTRHO
UI* createUI()
{
    return LDPF_NAMESPACE::createLuaUI();
}
END_NAMESPACE_DISTRHO
// -----------------------------------------------------------------------
