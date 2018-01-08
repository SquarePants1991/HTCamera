//
// Created by yang wang on 2017/12/24.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    HTCameraDeviceTypeFront,
    HTCameraDeviceTypeBack,
} HTCameraDeviceType;

typedef enum : NSInteger {
    HTCameraSessionPresetLow,
    HTCameraSessionPresetMedium,
    HTCameraSessionPresetHigh,
} HTCameraSessionPreset;

@interface HTCameraSessionConfig : NSObject
/// @abstract 是否在delegate中输出每一帧的数据
@property (assign, nonatomic) BOOL useVideoDataOutput;

/// @abstract 默认使用的摄像机
@property (assign, nonatomic) HTCameraDeviceType defaultCameraDeviceType;

/// @abstract 摄像机配置
@property (assign, nonatomic) HTCameraSessionPreset defaultCameraSessionPreset;

/// @abstract 是否需要开启识别二维码
@property (assign, nonatomic) BOOL needRecognizeQrCode;
@end
