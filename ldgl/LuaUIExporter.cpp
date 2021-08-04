#include <stdio.h>
#include <stdlib.h>

#include <lua.hpp>

#include "LuaUIExporter.hpp"

#ifdef LDPF_MACOS
   #include "macos_util.h"
#endif

// -----------------------------------------------------------------------
START_NAMESPACE_LDGL
// -----------------------------------------------------------------------

extern "C" {

struct ldgl_luadata
{
    ldgl_luadata(intptr_t     parentWinId,
                 uint32_t     parameterOffset,
                 void*        callbacksPtr,
                 setParamFunc setParamCall)
        : active(true),
          parentWinId(parentWinId),
          parameterOffset(parameterOffset),
          callbacksPtr(callbacksPtr),
          setParamCall(setParamCall),
          ldpf_ref(0),
          lmods_ref(0),
          idleCallback(NULL),
          idleCallback_ref(0)
    {}
    bool          active;
    intptr_t      parentWinId;
    uint32_t      parameterOffset;
    void*         callbacksPtr;
    setParamFunc  setParamCall;
    
    int           ldpf_ref;
    int           lmods_ref;
    int           lres_ref;
    IdleCallback* idleCallback;
    int           idleCallback_ref;
};

// -----------------------------------------------------------------------

/*
** Message handler used to run all chunks
*/
static int ldgl_msghandler(lua_State* L) 
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

static int ldgl_callSetParam(lua_State* L)
{
    ldgl_luadata* luadata = (ldgl_luadata*)lua_touserdata(L, lua_upvalueindex(1));
    luaL_checkinteger(L, 1);
    luaL_checknumber(L, 2);
    try {
         if (luadata->active) {
            uint32_t index = lua_tointeger(L, 1);
            float    value = lua_tonumber(L, 2);
            luadata->setParamCall(luadata->callbacksPtr, index + luadata->parameterOffset, value);
         }
        return 0;
    } catch (...) {
        return luaL_error(L, "Unexpected C++ exception while calling setParameterValue");
    }
}

// -----------------------------------------------------------------------

static int ldgl_callIdleCallback(lua_State* L)
{
    ldgl_luadata* luadata = (ldgl_luadata*)lua_touserdata(L, lua_upvalueindex(1));
    try {
         if (luadata->idleCallback) {
            luadata->idleCallback->idleCallback();
         }
        return 0;
    } catch (...) {
        return luaL_error(L, "Unexpected C++ exception while calling idleCallback");
    }
}

// -----------------------------------------------------------------------

static int ldpf_package_searcher(lua_State* L)
{
    ldgl_luadata* luadata = (ldgl_luadata*)lua_touserdata(L, lua_upvalueindex(1));
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

static int ldgl_callGetResource(lua_State* L)
{
    ldgl_luadata* luadata = (ldgl_luadata*)lua_touserdata(L, lua_upvalueindex(1));
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
}
// -----------------------------------------------------------------------

static int ldpf_init(lua_State* L)
{
    lua_newtable(L); // -> ldpf
    return 1;
}

// -----------------------------------------------------------------------

static int ldgl_init(lua_State* L)
{
    ldgl_luadata*   luadata    = (ldgl_luadata*)lua_touserdata(L, 1);
    LuaInitParams*  initParams = (LuaInitParams*)lua_touserdata(L, 2);
    
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
    
    luaL_requiref(L, "ldpf", ldpf_init, false);                 // -> ldpf
    if (luadata->parentWinId) {
        lua_pushlightuserdata(L, (void*) luadata->parentWinId); // -> ldpf, parentWinId
        lua_setfield(L, -2, "parentWindowId");                  // -> ldpf
    }                                                           // -> ldpf
    lua_pushlightuserdata(L, luadata);                          // -> ldpf, luadata
    lua_pushcclosure(L, ldgl_callSetParam, 1);                  // -> ldpf, setParam
    lua_setfield(L, -2, "setParameterValue");                   // -> ldpf
                                                                // -> ldpf
    lua_pushlightuserdata(L, luadata);                          // -> ldpf, luadata
    lua_pushcclosure(L, ldgl_callGetResource, 1);               // -> ldpf, getResource
    lua_setfield(L, -2, "getResource");                         // -> ldpf
                                                                // -> ldpf
    luadata->ldpf_ref = luaL_ref(L, LUA_REGISTRYINDEX);         // -> 
    
    // invoke plugin main module
    lua_getglobal(L, "require");                                // -> require
    lua_pushstring(L, "main");                                  // -> require, "main"
    lua_call(L, 1, 0);                                          // -> 

    return 0;
}

} // extern "C"


class LuaUIExporter::Internal
{
public:
    Internal(intptr_t     parentWinId,
             uint32_t     parameterOffset,
             void*        callbacksPtr,
             setParamFunc setParamCall)
             
        : initParams(getLuaInitParams()),
          luadata(parentWinId,
                  parameterOffset,
                  callbacksPtr,
                  setParamCall),
          screenScale(1),
          initialized(false),
          isInExec(false),
          L(NULL)
    {
    #ifdef LDPF_MACOS
        screenScale = LDGL_getScreenScaleFactor();
    #endif
        assureInitialized();
    }
    
    bool assureInitialized() {
        if (!initialized) {
            initialized = true;
            L = luaL_newstate();
            if (L) {
                luaL_openlibs(L);
                lua_pushcfunction(L, ldgl_msghandler);        // -> msgh
                int msgh = lua_gettop(L);
                lua_pushcfunction(L, &ldgl_init);             // -> msgh, initFunc
                int argc = 0;
                lua_pushlightuserdata(L, &luadata); ++argc;  // -> msgh, initFunc, args..
                lua_pushlightuserdata(L, initParams); ++argc;
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
            lua_pushcfunction(L, ldgl_msghandler);                               // -> ldpf, args..., msgh
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
    
    void exec(IdleCallback* const cb) {
        if (!L || isInExec) return;
        isInExec = true;
        if (!luadata.idleCallback_ref) {
            lua_pushlightuserdata(L, &luadata);                          // -> luadata
            lua_pushcclosure(L, ldgl_callIdleCallback, 1);               // -> idleCallback
            luadata.idleCallback_ref = luaL_ref(L, LUA_REGISTRYINDEX);   // -> 
        }
        lua_rawgeti(L, LUA_REGISTRYINDEX, luadata.idleCallback_ref);    // -> idleCallback
        luadata.idleCallback = cb;                                      // -> idleCallback
        int numberResults = call("exec", 1);                            // -> rslts...
        lua_pop(L, numberResults);                                      // -> 
        luadata.idleCallback = NULL;
        isInExec = false;
    }
    

    uint getWidth() {
        if (!L) return 0;
        int numberResults = call("getWidth");
        if (numberResults > 0) {
            uint rslt = lua_tointeger(L, -1);
            lua_pop(L, numberResults);
            return rslt/screenScale;
        } else {
            return 0;
        }
    }

    uint getHeight() {
        if (!L) return 0;
        int numberResults = call("getHeight");
        if (numberResults > 0) {
            uint rslt = lua_tointeger(L, -1);
            lua_pop(L, numberResults);
            return rslt/screenScale;
        } else {
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

    void close() {
        if (!L) return;
        int numberResults = call("close");
        lua_pop(L, numberResults);
    }
    
    // false for termination
    bool idle() {
        if (!L) return false;
        if (lua_rawgeti(L, LUA_REGISTRYINDEX, luadata.ldpf_ref) == LUA_TTABLE) { // -> ldpf
            lua_pushcfunction(L, ldgl_msghandler);                               // -> ldpf, msgh
            int msgh = lua_gettop(L);
            if (lua_getfield(L, -2, "idle") == LUA_TFUNCTION) {                  // -> ldpf, msgh, idle
                int rc = lua_pcall(L, 0, 1, msgh);                               // -> ldpf, msgh, ?
                if (rc != LUA_OK) {                                              // -> ldpf, msgh, err
                    fprintf(stderr, "Error while calling ldpf.idle(): %s\n",
                                     lua_tostring(L, -1));
                    lua_pop(L, 3);
                    return 0;                 
                } // -> ldpf, msgh, rslt
                bool continueFlag = lua_toboolean(L, -1);
                lua_pop(L, 3);
                return continueFlag;
            } else {            // -> ldpf, msgh, ?
                lua_pop(L, 3);  // -> 
                return true;
            }
        } else {             // -> ?
            lua_pop(L, 1);   // ->
            return false;
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
    LuaInitParams* const initParams;
    ldgl_luadata         luadata;

    double screenScale;

    bool initialized;
    bool isInExec;
 
    lua_State* L;
};

// -----------------------------------------------------------------------

LuaUIExporter::LuaUIExporter(uint32_t parameterOffset,
                             void* const callbacksPtr,
                             const uintptr_t winId,
                             const double sampleRate,
                             const editParamFunc editParamCall,
                             const setParamFunc setParamCall,
                             const setStateFunc setStateCall,
                             const sendNoteFunc sendNoteCall,
                             const setSizeFunc setSizeCall,
                             const fileRequestFunc fileRequestCall,
                             const char* const bundlePath,
                             void* const dspPtr,
                             const double scaleFactor,
                             const uint32_t bgColor,
                             const uint32_t fgColor)
    : parameterOffset(parameterOffset),
      internal(new Internal(winId,
                            parameterOffset,
                            callbacksPtr,
                            setParamCall))
{
    (void)editParamCall;
    (void)setStateCall;
    (void)sendNoteCall;
    (void)setSizeCall;
    (void)scaleFactor;
    (void)dspPtr;
    (void)bundlePath;
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
}

// -----------------------------------------------------------------------

LuaUIExporter::~LuaUIExporter()
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    delete internal;
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
}

// -----------------------------------------------------------------------

void LuaUIExporter::setWindowTransientWinId(const uintptr_t winId)
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
}

void LuaUIExporter::setWindowTitle(const char* const uiTitle)
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
}

void LuaUIExporter::setWindowSize(const uint width, const uint height, const bool updateUI)
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    (void)width;
    (void)height;
    (void)updateUI;
}

bool LuaUIExporter::setWindowVisible(const bool yesNo)
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    (void)yesNo;
    return true;
}

void LuaUIExporter::focus()
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
}

bool LuaUIExporter::isVisible() const noexcept {
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    return true;
}
uint LuaUIExporter::getWidth() const noexcept 
{
    return internal->getWidth();
}
uint LuaUIExporter::getHeight() const noexcept 
{
    return internal->getHeight();
}
uintptr_t LuaUIExporter::getNativeWindowHandle() const noexcept 
{
    return internal->getNativeWindowHandle();
}

void LuaUIExporter::setSampleRate(const double sampleRate, const bool doCallback)
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    (void)sampleRate;
    (void)doCallback;
}

void LuaUIExporter::stateChanged(const char* const key, const char* const value)
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    (void)key;
    (void)value;
}

void LuaUIExporter::parameterChanged(const uint32_t index, const float value)
{
    printf("----------------- LuaUIExporter line %d ---------------- parameter changed %d : %f\n", __LINE__, index, value);
    internal->parameterChanged(index, value);
}


void LuaUIExporter::programLoaded(const uint32_t index)
{
    (void)index;
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
}


void LuaUIExporter::exec(IdleCallback* const cb)
{
    internal->exec(cb);
}


void LuaUIExporter::exec_idle()
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
}

bool LuaUIExporter::plugin_idle()
{
//    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    return internal->idle();
}


void LuaUIExporter::quit()
{
    internal->close();
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
}


bool LuaUIExporter::handlePluginKeyboard(const bool press, const uint key, const uint16_t mods)
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    return false;
}

bool LuaUIExporter::handlePluginSpecial(const bool press, const DGL_NAMESPACE::Key key, const uint16_t mods)
{
    printf("----------------- LuaUIExporter line %d ----------------\n", __LINE__);
    return false;
}



// -----------------------------------------------------------------------
END_NAMESPACE_LDGL
// -----------------------------------------------------------------------
