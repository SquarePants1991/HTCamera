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

@interface HTViewController ()
@property (strong, nonatomic) HTCameraSession *cameraSession;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation HTViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HTCameraSessionConfig *config = [HTCameraSessionConfig new];
    self.cameraSession = [[HTCameraSession alloc] initWithConfig:config];
    [self.cameraSession beginCapture:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cameraSession addGLPreviewToView:self.containerView];
            });
        }
    }];
}

- (IBAction)cameraModeChange:(UISwitch *)sender {
    if (sender.isOn) {
        [self.cameraSession useCameraDevice:HTCameraDeviceTypeBack];
    } else {
        [self.cameraSession useCameraDevice:HTCameraDeviceTypeFront];
    }
}

@end
