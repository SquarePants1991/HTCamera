//
// Created by yang wang on 2017/12/24.
//

#import <AVFoundation/AVFoundation.h>

#import "HTCameraSessionDelegate.h"
#import "HTCameraSessionConfig.h"
#import "HTCameraRecognizeResult.h"

typedef void (^HTCameraSessionOperationHandler)(BOOL isSuccess, NSError *error);

@interface HTCameraSession : NSObject
@property (weak, nonatomic) id <HTCameraSessionDelegate> delegate;
@property (weak, nonatomic) id <HTCameraSessionRecognizeDelegate> recognizeDelegate;
@property (weak, nonatomic) id <HTCameraSessionAuthorizationDelegate> authDelegate;

- (id)initWithConfig:(HTCameraSessionConfig *)config;
- (id)initWithConfig:(HTCameraSessionConfig *)config authDelegate:(id <HTCameraSessionAuthorizationDelegate>)authDelegate;

- (void)run;

- (void)beginCapture:(HTCameraSessionOperationHandler)resultHandler;

- (void)stopCapture:(HTCameraSessionOperationHandler)resultHandler;

- (void)useCameraDevice:(HTCameraDeviceType)cameraDeviceType;

- (AVCaptureSession *)avCaptureSession;
@end
