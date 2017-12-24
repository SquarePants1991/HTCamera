//
// Created by yang wang on 2017/12/24.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@interface HTCameraFrame : NSObject
@property (assign, nonatomic, getter=getPixelBuffer) CVPixelBufferRef pixelBuffer;

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end