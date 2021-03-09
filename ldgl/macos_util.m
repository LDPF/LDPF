#import <Cocoa/Cocoa.h>

#include "macos_util.h"

double LDGL_getScreenScaleFactor()
{
    return [[NSScreen mainScreen] backingScaleFactor];
}
