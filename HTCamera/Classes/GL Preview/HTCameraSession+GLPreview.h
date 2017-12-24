//
// Created by yang wang on 2017/12/24.
//

#import <Foundation/Foundation.h>
#import "HTCameraSession.h"

@interface HTCameraSession (GLPreview) <HTCameraSessionDelegate>
- (void)addGLPreviewToView:(UIView *)parentView;
@end