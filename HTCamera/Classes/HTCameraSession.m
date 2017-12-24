//
// Created by yang wang on 2017/12/24.
//

#import "HTCameraSession.h"
#import "HTCameraFrame.h"

@interface HTCameraSession () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *_captureSession;
    NSDictionary *_cameraDevices;

    dispatch_queue_t _cameraSessionQueue;
}
@end

@implementation HTCameraSession

- (id)initWithConfig:(HTCameraSessionConfig *)config {
    if (self = [super init]) {
        _captureSession = [AVCaptureSession new];
        _cameraSessionQueue = dispatch_queue_create("me.ht.camerasession", DISPATCH_QUEUE_SERIAL);

        [self configCameraSessionPreset:config.defaultCameraSessionPreset];
        [self fetchCameraDevice];
        [self useCameraDevice:config.defaultCameraDeviceType];
        if (config.useVideoDataOutput) {
            [self configVideoDataOutput];
        }
    }
    return self;
}

- (AVCaptureSession *)avCaptureSession {
    return _captureSession;
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
    switch(preset) {
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

#pragma mark - Control Logic

- (void)beginCapture:(HTCameraSessionOperationHandler)resultHandler {
    if (![_captureSession isRunning]) {
        dispatch_async(_cameraSessionQueue, ^{
            [_captureSession startRunning];
            resultHandler([_captureSession isRunning], nil);
            if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(cameraSessionDidStart:)]) {
                [self.delegate cameraSessionDidStart:self];
            }
        });
    }
}

- (void)stopCapture:(HTCameraSessionOperationHandler)resultHandler {
    if ([_captureSession isRunning]) {
        dispatch_async(_cameraSessionQueue, ^{
            [_captureSession stopRunning];
            resultHandler(![_captureSession isRunning], nil);
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
@end
