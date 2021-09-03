#import <Cocoa/Cocoa.h>

#include "ldpf_macos_util.h"

double LDPF_getScreenScaleFactor()
{
    return [[NSScreen mainScreen] backingScaleFactor];
}
