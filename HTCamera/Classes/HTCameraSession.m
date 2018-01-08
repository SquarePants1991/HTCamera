//
// Created by yang wang on 2017/12/24.
//

#import "HTCameraSession.h"
#import "HTCameraFrame.h"
#import "HTCameraRecognizeResult.h"
#import "HTCameraDefaultAuthProvider.h"

const NSString *kHTCameraErrorDomain = @"kHTCameraErrorDomain";

@interface HTCameraSession () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate> {
@private
    AVCaptureSession *_captureSession;
    NSDictionary *_cameraDevices;
    HTCameraSessionConfig *_config;

    dispatch_queue_t _cameraSessionQueue;
    BOOL _isReadyToUse;

    // Default Auth Behavior Provider
    HTCameraDefaultAuthProvider *_defaultAuthProvider;
}
@end

@implementation HTCameraSession

- (id)initWithConfig:(HTCameraSessionConfig *)config {
    if (self = [super init]) {
        _captureSession = [AVCaptureSession new];
        _cameraSessionQueue = dispatch_queue_create("me.ht.camerasession", DISPATCH_QUEUE_SERIAL);
        _config = config;
        _defaultAuthProvider = [HTCameraDefaultAuthProvider new];
        self.authDelegate = _defaultAuthProvider;
        _isReadyToUse = NO;

        [self tryRun];
    }
    return self;
}

- (id)initWithConfig:(HTCameraSessionConfig *)config authDelegate:(id <HTCameraSessionAuthorizationDelegate>)authDelegate {
    if (self = [super init]) {
        _captureSession = [AVCaptureSession new];
        _cameraSessionQueue = dispatch_queue_create("me.ht.camerasession", DISPATCH_QUEUE_SERIAL);
        _config = config;
        self.authDelegate = authDelegate;
        _isReadyToUse = NO;

        [self tryRun];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)tryRun {
    [self requireAuthorization:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            [self configuration];
            [self beginCapture:nil];
        } else if (self.authDelegate && [self.authDelegate respondsToSelector:@selector(cameraSessionRequireAuth:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
            [self.authDelegate cameraSessionRequireAuth:self];
        }
    }];
}

- (void)configuration {
    [self configCameraSessionPreset:_config.defaultCameraSessionPreset];
    [self fetchCameraDevice];
    [self useCameraDevice:_config.defaultCameraDeviceType];
    if (_config.useVideoDataOutput) {
        [self configVideoDataOutput];
    }
    if (_config.needRecognizeQrCode) {
        [self configRecognizeOutput];
    }
    _isReadyToUse = YES;
}

- (AVCaptureSession *)avCaptureSession {
    return _captureSession;
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    [self tryRun];
}

#pragma mark - Auth

- (void)requireAuthorization:(HTCameraSessionOperationHandler)handler {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    handler(YES, nil);
                } else {
                    handler(NO, [NSError errorWithDomain:kHTCameraErrorDomain code:-1 userInfo:@{@"message": @"无权限访问"}]);
                }
            }];
            break;
        }

        case AVAuthorizationStatusAuthorized: {
            handler(YES, nil);
            break;
        }

        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            handler(NO, [NSError errorWithDomain:kHTCameraErrorDomain code:-1 userInfo:@{@"message": @"无权限访问"}]);
            break;
        }

        default: {
            break;
        }
    }
}

#pragma mark - AV Setup Methods

- (void)fetchCameraDevice {
    NSMutableDictionary *devices = [NSMutableDictionary new];

    // TODO: 更新API AVCaptureDevice
    NSArray<AVCaptureDevice *> *availableDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in availableDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            devices[@(HTCameraDeviceTypeFront)] = device;
        } else if (device.position == AVCaptureDevicePositionBack) {
            devices[@(HTCameraDeviceTypeBack)] = device;
        }
    }

    _cameraDevices = devices;
}


- (void)useNewCaptureInput:(AVCaptureInput *)captureInput {
    if (_captureSession.inputs.count == 0) {
        if ([_captureSession canAddInput:captureInput]) {
            [_captureSession addInput:captureInput];
        }
    }
    dispatch_async(_cameraSessionQueue, ^{
        if (_captureSession.isRunning) {
            [_captureSession stopRunning];
            for (AVCaptureInput *input in _captureSession.inputs) {
                [_captureSession removeInput:input];
            }
            if ([_captureSession canAddInput:captureInput]) {
                [_captureSession addInput:captureInput];
            }
            [_captureSession startRunning];
        } else {
            if ([_captureSession canAddInput:captureInput]) {
                [_captureSession addInput:captureInput];
            }
        }
    });
}

- (void)configCameraSessionPreset:(HTCameraSessionPreset)preset {
    AVCaptureSessionPreset avCaptureSessionPreset;
    switch (preset) {
        case HTCameraSessionPresetLow:
            avCaptureSessionPreset = AVCaptureSessionPresetLow;
            break;
        case HTCameraSessionPresetMedium:
            avCaptureSessionPreset = AVCaptureSessionPresetMedium;
            break;
        default:
            avCaptureSessionPreset = AVCaptureSessionPresetPhoto;
    }
    if ([_captureSession canSetSessionPreset:avCaptureSessionPreset]) {
        _captureSession.sessionPreset = avCaptureSessionPreset;
    }
}

- (void)configVideoDataOutput {
    AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
    [output setSampleBufferDelegate:self queue:_cameraSessionQueue];
    if ([_captureSession canAddOutput:output]) {
        [_captureSession addOutput:output];
    }
}

- (void)configRecognizeOutput {
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    [output setMetadataObjectsDelegate:self queue:_cameraSessionQueue];
    if ([_captureSession canAddOutput:output]) {
        [_captureSession addOutput:output];
    }
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
}

#pragma mark - Control Logic

- (void)beginCapture:(HTCameraSessionOperationHandler)resultHandler {
    if (_isReadyToUse == NO) {
        if (resultHandler) {
            resultHandler(NO, nil);
        }
        return;
    }
    if (![_captureSession isRunning]) {
        dispatch_async(_cameraSessionQueue, ^{
            [_captureSession startRunning];
            if (resultHandler) {
                resultHandler([_captureSession isRunning], nil);
            }
            if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(cameraSessionDidStart:)]) {
                [self.delegate cameraSessionDidStart:self];
            }
        });
    }
}

- (void)stopCapture:(HTCameraSessionOperationHandler)resultHandler {
    if (_isReadyToUse == NO) {
        if (resultHandler) {
            resultHandler(NO, nil);
        }
        return;
    }
    if ([_captureSession isRunning]) {
        dispatch_async(_cameraSessionQueue, ^{
            [_captureSession stopRunning];
            if (resultHandler) {
                resultHandler(![_captureSession isRunning], nil);
            }
            if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(cameraSessionDidStop:)]) {
                [self.delegate cameraSessionDidStop:self];
            }
        });
    }
}

- (void)useCameraDevice:(HTCameraDeviceType)cameraDeviceType {
    AVCaptureDevice *device = _cameraDevices[@(cameraDeviceType)];
    if (device) {
        NSError *error;
        AVCaptureInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!error) {
            [self useNewCaptureInput:captureInput];
        } else {
            // TODO: print error later
        }
    }
}

#pragma mark - Video Data Output Delegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.delegate &&
            [self.delegate respondsToSelector:@selector(cameraSessionCapturing:frame:)]) {
        CVImageBufferRef cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        HTCameraFrame *frame = [[HTCameraFrame alloc] initWithPixelBuffer:cvImageBuffer];
        [self.delegate cameraSessionCapturing:self frame:frame];
    }
}

#pragma mark - Metadata Output Delegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (self.recognizeDelegate &&
            [self.recognizeDelegate respondsToSelector:@selector(cameraSession:didRecognize:)]) {
        AVMetadataMachineReadableCodeObject *readableCodeObject = [metadataObjects firstObject];
        if (readableCodeObject && [readableCodeObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *qrcodeContent = readableCodeObject.stringValue;
            [self.recognizeDelegate cameraSession:self didRecognize:[[HTCameraRecognizeResult alloc] initAsQRCode:qrcodeContent]];
        }
    }
}
@end
