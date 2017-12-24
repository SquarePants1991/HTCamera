//
// Created by yang wang on 2017/12/24.
//

#import "HTCameraSession+CAPreview.h"
#import <objc/runtime.h>

const NSString *kCAPreviewLayerPropertyKey;

@implementation HTCameraSession (CAPreview)
- (void)addPreviewToLayer:(CALayer *)parentLayer {
    CALayer *previewLayer = objc_getAssociatedObject(self, &kCAPreviewLayerPropertyKey);
    if (!previewLayer) {
        previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self avCaptureSession]];
        objc_setAssociatedObject(self, &kCAPreviewLayerPropertyKey, previewLayer, OBJC_ASSOCIATION_RETAIN);
    } else {
        [previewLayer removeFromSuperlayer];
    }
    previewLayer.frame = parentLayer.bounds;
    [parentLayer addSublayer:previewLayer];
}
@end