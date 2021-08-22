#ifndef LDGL_LUA_UI_EXPORTER_HPP_INCLUDED
#define LDGL_LUA_UI_EXPORTER_HPP_INCLUDED

#include "LuaBase.hpp"

// -----------------------------------------------------------------------
START_NAMESPACE_LDGL
// -----------------------------------------------------------------------

using DGL_NAMESPACE::IdleCallback;

// -----------------------------------------------------------------------
// UI callbacks

typedef void (*editParamFunc)   (void* ptr, uint32_t rindex, bool started);
typedef void (*setParamFunc)    (void* ptr, uint32_t rindex, float value);
typedef void (*setStateFunc)    (void* ptr, const char* key, const char* value);
typedef void (*sendNoteFunc)    (void* ptr, uint8_t channel, uint8_t note, uint8_t velo);
typedef void (*setSizeFunc)     (void* ptr, uint width, uint height);
typedef bool (*fileRequestFunc) (void* ptr, const char* key);


// -----------------------------------------------------------------------

class LuaUIExporter
{
public:
    LuaUIExporter(uint32_t parameterOffset,
                  void* const callbacksPtr,
                  const uintptr_t winId,
                  const double sampleRate,
                  const editParamFunc editParamCall,
                  const setParamFunc setParamCall,
                  const setStateFunc setStateCall,
                  const sendNoteFunc sendNoteCall,
                  const setSizeFunc setSizeCall,
                  const fileRequestFunc fileRequestCall,
                  const char* const bundlePath = nullptr,
                  void* const dspPtr = nullptr,
                  const double scaleFactor = 1.0,
                  const uint32_t bgColor = 0,
                  const uint32_t fgColor = 0xffffffff);
    
    ~LuaUIExporter();
    
    void setWindowTransientWinId(const uintptr_t winId);
    void setWindowTitle(const char* const uiTitle);
    void setWindowSize(const uint width, const uint height, const bool updateUI = false);
    bool setWindowVisible(const bool yesNo);
    void focus();

    bool isVisible() const noexcept;

    uint getWidth() const noexcept;

    uint getHeight() const noexcept;

    double getScaleFactor() const noexcept;
    
    uintptr_t getNativeWindowHandle() const noexcept;
    
    void notifyScaleFactorChanged(const double scaleFactor);
    
    void setSampleRate(const double sampleRate, const bool doCallback = false);
    void stateChanged(const char* const key, const char* const value);

    void parameterChanged(const uint32_t index, const float value);
    void programLoaded(const uint32_t index);

    bool handlePluginKeyboard(const bool press, const uint key, const uint16_t mods);
    bool handlePluginSpecial(const bool press, const DGL_NAMESPACE::Key key, const uint16_t mods);
    
    /**
     * Return false for termination.
     */ 
    bool plugin_idle();
    
    void exec(IdleCallback* const cb);
    void exec_idle();
    
    void quit();

    uint32_t getParameterOffset() const noexcept {
        return parameterOffset;
    }

private:
    class Internal;
    
    const uint32_t parameterOffset;
    Internal*      internal;
};

// -----------------------------------------------------------------------
END_NAMESPACE_LDGL
// -----------------------------------------------------------------------

#endif // LDGL_LUA_UI_EXPORTER_HPP_INCLUDED
