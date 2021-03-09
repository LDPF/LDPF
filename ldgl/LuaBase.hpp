#ifndef LDGL_LUA_BASE_HPP_INCLUDED
#define LDGL_LUA_BASE_HPP_INCLUDED

#include "../../dpf/dgl/Base.hpp"

extern "C" {
    #include "ldgl_base.h"
}


// -----------------------------------------------------------------------
// Define namespace

#ifndef LDGL_NAMESPACE
# define LDGL_NAMESPACE LDGL
#endif

#define START_NAMESPACE_LDGL namespace LDGL_NAMESPACE {
#define END_NAMESPACE_LDGL }
#define USE_NAMESPACE_LDGL using namespace LDGL_NAMESPACE;

// -----------------------------------------------------------------------

// -----------------------------------------------------------------------
START_NAMESPACE_LDGL
// -----------------------------------------------------------------------

typedef LDGL_LuaData       LuaData;
typedef LDGL_LuaCModule    LuaCModule;
typedef LDGL_LuaLSubModule LuaLSubModule;
typedef LDGL_LuaLModule    LuaLModule;

// -----------------------------------------------------------------------

/**
 *  Initial parameters to be provided by PluginUI. 
 */
class LuaInitParams
{
public:
    /** 
     * See LuaInitParams.hpp for constructor.
     */
    LuaInitParams(const char* luaPath,
                  const char* luaPathEnvVar);

    const LuaCModule* const    cmodules;
    const LuaLModule* const    lmodules;
    const LuaLSubModule* const resources;
    
    /**
     * Lua modules path for overriding builtin Lua modules for debugging
     * purposes. NULL if source modules should not be loaded from file system.
     */
    const char* const luaPath;

    /**
     * Name of environment variable for Lua modules path for overriding builtin
     * Lua modules for debugging purposes. NULL if source modules should not be
     * loaded from file system.
     */
    const char* const luaPathEnvVar;
};

// -----------------------------------------------------------------------

/**
 *  This function has to be implemented by PluginUI.
 */
LuaInitParams* getLuaInitParams();

// -----------------------------------------------------------------------
END_NAMESPACE_LDGL
// -----------------------------------------------------------------------

#endif // LDGL_LUA_BASE_HPP_INCLUDED
