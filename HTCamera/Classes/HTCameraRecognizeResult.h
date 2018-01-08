//
// Created by yang wang on 2017/12/24.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    HTCameraRecognizeResultQRCode,
    HTCameraRecognizeResultFace,
} HTCameraRecognizeResultType;

@interface HTCameraRecognizeResult : NSObject
@property (assign, nonatomic) HTCameraRecognizeResultType type;

- (instancetype)initAsQRCode:(NSString *)qrcodeContent;

- (NSString *)qrcodeContentString;
@end
