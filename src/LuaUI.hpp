#ifndef LDPF_LUA_UI_HPP_INCLUDED
#define LDPF_LUA_UI_HPP_INCLUDED

#include "LdpfBase.hpp"
#include "DistrhoUI.hpp"

#include LDPF_GENERATED_LUA_INIT_PARAMS_HPP // see ldpf/Makefile.plugins.mk

// -----------------------------------------------------------------------
START_NAMESPACE_LDPF
// -----------------------------------------------------------------------

class LuaUI : public DISTRHO_NAMESPACE::UI
{
public:
    /**
     *  Initial parameters to be provided by PluginUI. 
     */
    class InitParams
    {
    public:
        /**
         * InitParams - Initial parameters to be provided by PluginUI. 
         * See LdpfBase.hpp for class declaration.
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
        InitParams(const char* luaPath,
                   const char* luaPathEnvVar)
            : cmodules(LDPF_generatedLuaCModules),
              lmodules(LDPF_generatedLuaLModules),
              resources(LDPF_generatedMainModuleResources),
              luaPath(luaPath),
              luaPathEnvVar(luaPathEnvVar)
        {}

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
    
    LuaUI(const InitParams* initParams);
    virtual ~LuaUI();

protected:

    virtual uintptr_t getNativeWindowHandle() const noexcept override;
    virtual void sizeChanged(uint width, uint height) override;
    virtual void focus() override;


   /* --------------------------------------------------------------------------------------------------------
    * DSP/Plugin Callbacks */
    

    virtual void parameterChanged(uint32_t index, float value) override;

#if DISTRHO_PLUGIN_WANT_PROGRAMS
   /**
      A program has been loaded on the plugin side.@n
      This is called by the host to inform the UI about program changes.
    */
    virtual void programLoaded(uint32_t index) override;
#endif

#if DISTRHO_PLUGIN_WANT_STATE
   /**
      A state has changed on the plugin side.@n
      This is called by the host to inform the UI about state changes.
    */
    virtual void stateChanged(const char* key, const char* value) override;
#endif

   /**
      Optional callback to inform the UI about a sample rate change on the plugin side.
      @see getSampleRate()
    */
    virtual void sampleRateChanged(double newSampleRate) override;

   /**
      UI idle function, called to give idle time to the plugin UI directly from the host.
      This is called right after OS event handling and Window idle events (within the same cycle).
      There are no guarantees in terms of timing.
      @see addIdleCallback(IdleCallback*, uint).
    */
    virtual void uiIdle() override;

   /**
      Window scale factor function, called when the scale factor changes.
      This function is for plugin UIs to be able to override Window::onScaleFactorChanged(double).

      The default implementation does nothing.
      WARNING function needs a proper name
    */
    virtual void uiScaleFactorChanged(double scaleFactor) override;


private:
    class Internal;
    
    Internal* internal;

   /**
      Set our UI class as non-copyable and add a leak detector just in case.
    */
    DISTRHO_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(LuaUI)
};

// -----------------------------------------------------------------------

/**
 *  This function has to be implemented by PluginUI.
 */
LuaUI* createLuaUI();

// -----------------------------------------------------------------------
END_NAMESPACE_LDPF
// -----------------------------------------------------------------------

#endif // LDPF_LUA_UI_HPP_INCLUDED
