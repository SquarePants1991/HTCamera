//
// Created by yang wang on 2017/12/24.
//

#import "HTCameraRecognizeResult.h"

@interface HTCameraRecognizeResult () {
@private
    NSString *_qrcodeContent;
}
@end

@implementation HTCameraRecognizeResult
- (instancetype)initAsQRCode:(NSString *)qrcodeContent {
    if (self = [super init]) {
        self.type = HTCameraRecognizeResultQRCode;
        _qrcodeContent = qrcodeContent;
    }
    return self;
}

- (NSString *)qrcodeContentString {
    return _qrcodeContent;
}
@end