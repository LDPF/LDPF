/* Name of package */
#define PACKAGE "pixman"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "pixman@lists.freedesktop.org"

/* Define to the version of this package. */
#define PACKAGE_VERSION "0.40.0"

/* use x86 MMX compiler intrinsics */
#define USE_X86_MMX 1

/* use SSE2 compiler intrinsics */
#define USE_SSE2 1

/* use SSSE3 compiler intrinsics */
#define USE_SSSE3 1

/* define this to use xmmintrin.h. _WIN64 is only used in pixman-mmx.c:63 */
#define USE_XMMINTRIN_H
