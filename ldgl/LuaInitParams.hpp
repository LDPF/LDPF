#ifndef LDGL_LUA_INIT_PARAMS_HPP_INCLUDED
#define LDGL_LUA_INIT_PARAMS_HPP_INCLUDED

#include "LuaBase.hpp"

#include LDPF_GENERATED_LUA_INIT_PARAMS_HPP // see ldpf/Makefile.plugins.mk

// -----------------------------------------------------------------------
START_NAMESPACE_LDGL
// -----------------------------------------------------------------------

/**
 * LuaInitParams - Initial parameters to be provided by PluginUI. 
 * See LuaBase.hpp for class declaration.
 * 
 * @param luaPath - Lua modules path for overriding builtin Lua modules for 
 *                  debugging purposes.
 *                  NULL if source modules should not be loaded from file
 *                  system.
 *
 * @param luaPathEnvVar - Name of environment variable for Lua modules path 
 *                        for overriding builtin Lua modules for debugging purposes.
 *                        NULL if source modules should not be loaded from file
 *                        system.
 */
inline LuaInitParams::LuaInitParams(const char* luaPath,
                                    const char* luaPathEnvVar)
    : cmodules(LDPF_generatedLuaCModules),          // see LDPF_GENERATED_LUA_INIT_PARAMS_HPP
      lmodules(LDPF_generatedLuaLModules),          // see LDPF_GENERATED_LUA_INIT_PARAMS_HPP
      resources(LDPF_generatedMainModuleResources), // see LDPF_GENERATED_LUA_INIT_PARAMS_HPP
      luaPath(luaPath),
      luaPathEnvVar(luaPathEnvVar)
{}

// -----------------------------------------------------------------------
END_NAMESPACE_LDGL
// -----------------------------------------------------------------------

#endif // LDGL_LUA_INIT_PARAMS_HPP_INCLUDED
