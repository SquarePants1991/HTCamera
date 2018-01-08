//
//  HTViewController.m
//  HTCamera
//
//  Created by handyTool on 12/24/2017.
//  Copyright (c) 2017 handyTool. All rights reserved.
//

#import <HTCamera/HTCameraSession+CAPreview.h>
#import <HTCamera/HTCameraSession+GLPreview.h>
#import "HTViewController.h"
#import "HTCamera/HTCameraSession.h"

@interface HTViewController () <HTCameraSessionRecognizeDelegate, HTCameraSessionAuthorizationDelegate>
@property (strong, nonatomic) HTCameraSession *cameraSession;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation HTViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HTCameraSessionConfig *config = [HTCameraSessionConfig new];
    config.needRecognizeQrCode = YES;
    config.defaultCameraSessionPreset = HTCameraSessionPresetHigh;
    self.cameraSession = [[HTCameraSession alloc] initWithConfig:config];
    self.cameraSession.recognizeDelegate = self;
    [self.cameraSession addGLPreviewToView:self.view];
}

- (IBAction)cameraModeChange:(UISwitch *)sender {
    if (sender.isOn) {
        [self.cameraSession useCameraDevice:HTCameraDeviceTypeBack];
    } else {
        [self.cameraSession useCameraDevice:HTCameraDeviceTypeFront];
    }
}

- (void)cameraSession:(HTCameraSession *)cameraSession didRecognize:(HTCameraRecognizeResult *)result {
    NSLog(@"%@", [result qrcodeContentString]);
    [cameraSession stopCapture:^(BOOL isSuccess, NSError *error) {

    }];
}

@end
