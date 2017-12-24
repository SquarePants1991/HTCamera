//
// Created by yang wang on 2017/12/24.
//

#import "HTCameraFrame.h"

@interface HTCameraFrame () {
    CVPixelBufferRef _pixelBuffer;
}
@end

@implementation HTCameraFrame
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef *)pixelBuffer {
    if (self = [super init]) {
        _pixelBuffer = pixelBuffer;
        CFRetain(_pixelBuffer);
    }
    return self;
}

- (void)dealloc {
    if (_pixelBuffer) {
        CFRelease(_pixelBuffer);
    }
}

- (CVPixelBufferRef)getPixelBuffer {
    return _pixelBuffer;
}
@end