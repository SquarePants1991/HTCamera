//
//  HTCameraDefaultAuthProvider.m
//  HTCamera
//
//  Created by ocean on 2018/1/8.
//

#import <Foundation/Foundation.h>
#import "HTCameraDefaultAuthProvider.h"

@implementation HTCameraDefaultAuthProvider
- (void)cameraSessionRequireAuth:(HTCameraSession *)cameraSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求授权" message:@"需要使用您的摄像机" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"前往授权" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 10) {
                [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}
@end
