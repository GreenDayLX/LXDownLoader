#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LXDownLoader.h"
#import "LXDownLoaderManager.h"
#import "LXFileManager.h"
#import "NSString+LXMD5.h"

FOUNDATION_EXPORT double LXDownLoaderVersionNumber;
FOUNDATION_EXPORT const unsigned char LXDownLoaderVersionString[];

