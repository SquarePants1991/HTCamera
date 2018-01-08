//
// Created by yang wang on 2017/12/24.
//

#import "HTCameraSessionConfig.h"

@implementation HTCameraSessionConfig
- (instancetype)init {
    if (self = [super init]) {
        self.useVideoDataOutput = YES;
        self.defaultCameraDeviceType = HTCameraDeviceTypeBack;
        self.defaultCameraSessionPreset = HTCameraSessionPresetHigh;
        self.needRecognizeQrCode = NO;
    }
    return self;
}
@end