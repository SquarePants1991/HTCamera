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

#import "HTCameraSession+CAPreview.h"
#import "HTCameraSession+GLPreview.h"
#import "HTCameraDefaultAuthProvider.h"
#import "HTCameraFrame.h"
#import "HTCameraRecognizeResult.h"
#import "HTCameraSession.h"
#import "HTCameraSessionConfig.h"
#import "HTCameraSessionDelegate.h"

FOUNDATION_EXPORT double HTCameraVersionNumber;
FOUNDATION_EXPORT const unsigned char HTCameraVersionString[];

