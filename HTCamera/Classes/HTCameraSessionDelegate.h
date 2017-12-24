//
// Created by yang wang on 2017/12/24.
//

#import <Foundation/Foundation.h>

@class HTCameraSession;
@class HTCameraFrame;

@protocol HTCameraSessionDelegate <NSObject>
/// 摄像机开始捕捉图像
/// @param cameraSession
- (void)cameraSessionDidStart:(HTCameraSession *)cameraSession;

/// 摄像机停止捕捉图像
/// @param cameraSession
- (void)cameraSessionDidStop:(HTCameraSession *)cameraSession;

/// 摄像机捕捉到一帧图像
/// @param cameraSession
/// @param frame 帧数据
- (void)cameraSessionCapturing:(HTCameraSession *)cameraSession frame:(HTCameraFrame *)frame;
@end