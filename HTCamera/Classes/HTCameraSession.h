//
// Created by yang wang on 2017/12/24.
//

#import <AVFoundation/AVFoundation.h>

#import "HTCameraSessionDelegate.h"
#import "HTCameraSessionConfig.h"

typedef void (^HTCameraSessionOperationHandler)(BOOL isSuccess, NSError *error);

@interface HTCameraSession : NSObject
@property (weak, nonatomic) id <HTCameraSessionDelegate> delegate;

- (id)initWithConfig:(HTCameraSessionConfig *)config;

- (void)beginCapture:(HTCameraSessionOperationHandler)resultHandler;

- (void)stopCapture:(HTCameraSessionOperationHandler)resultHandler;

- (void)useCameraDevice:(HTCameraDeviceType)cameraDeviceType;

- (AVCaptureSession *)avCaptureSession;
@end
