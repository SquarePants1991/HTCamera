//
// Created by yang wang on 2017/12/24.
//

#import "HTCameraSession+GLPreview.h"
#import "HTCameraFrame.h"
#import <objc/runtime.h>
#import <GLKit/GLKit.h>

const NSString *kGLPreviewLayerPropertyKey;
const NSString *kCIContextPropertyKey;

@implementation HTCameraSession (GLPreview)
- (void)addGLPreviewToView:(UIView *)parentView {
    GLKView *previewView = objc_getAssociatedObject(self, &kGLPreviewLayerPropertyKey);
    if (!previewView) {
        previewView = [self previewView];
        objc_setAssociatedObject(self, &kGLPreviewLayerPropertyKey, previewView, OBJC_ASSOCIATION_RETAIN);
    } else {
        [previewView removeFromSuperview];
    }
    previewView.frame = parentView.bounds;
    [parentView addSubview:previewView];
}

- (GLKView *)previewView {
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *glkView = [[GLKView alloc] initWithFrame:CGRectZero context:eaglContext];
    CIContext *ciContext = [CIContext contextWithEAGLContext:eaglContext];
    objc_setAssociatedObject(self, &kCIContextPropertyKey, ciContext, OBJC_ASSOCIATION_RETAIN);
    self.delegate = self;
    return glkView;
}

- (CIContext *)ciContext {
    return objc_getAssociatedObject(self, &kCIContextPropertyKey);
}

- (void)cameraSessionCapturing:(HTCameraSession *)cameraSession frame:(HTCameraFrame *)frame {
    dispatch_async(dispatch_get_main_queue(), ^{
        GLKView *previewView = objc_getAssociatedObject(self, &kGLPreviewLayerPropertyKey);
        if (previewView) {
            if (previewView.context != [EAGLContext currentContext]) {
                [EAGLContext setCurrentContext:previewView.context];
            }
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:frame.pixelBuffer];
            CIImage *renderImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
            float screenScale = [UIScreen mainScreen].scale;
            CGRect renderRect = previewView.bounds;
            renderRect.size.width *= screenScale;
            renderRect.size.height *= screenScale;
            float scaleFactorX = renderRect.size.width / renderImage.extent.size.width;
            float scaleFactorY = renderRect.size.height / renderImage.extent.size.height;
            float scaleFactor = scaleFactorX > scaleFactorY ? scaleFactorX : scaleFactorY;
            renderRect.size.width = renderImage.extent.size.width * scaleFactor;
            renderRect.size.height = renderImage.extent.size.height * scaleFactor;
            renderRect.origin.x = (previewView.bounds.size.width * screenScale - renderRect.size.width) / 2;
            renderRect.origin.y = (previewView.bounds.size.height * screenScale - renderRect.size.height) / 2;

            [previewView bindDrawable];
            [[self ciContext] drawImage:renderImage inRect:renderRect fromRect:renderImage.extent];
            [previewView display];
        }
    });
}
@end
