//
//  CameraViewController.m
//  Custom Camera
//
//  Created by Chris Leversuch on 30/06/2016.
//  Copyright © 2016 Brightec. All rights reserved.
//

#import "CameraViewController.h"
#import "ImageViewerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <PureLayout/PureLayout.h>
#import <objc/runtime.h>
#import "ServerCommunication.h"

static char imageKey;

@interface CameraViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCapturePhotoCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet UIView *cameraContainerView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIView *flashModeContainerView;
@property (weak, nonatomic) IBOutlet UIButton *flashAutoButton;
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;
@property (weak, nonatomic) IBOutlet UIButton *flashOffButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *openPhotoAlbumButton;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
//@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightConstraint;

@property (strong, nonatomic) UIVisualEffectView *blurView;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIView *capturePreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic, strong) NSOperationQueue *captureQueue;
@property (nonatomic, assign) UIImageOrientation imageOrientation;
@property (assign, nonatomic) AVCaptureFlashMode flashMode;
@end


@implementation CameraViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Default to the flash mode buttons being hidden
    self.flashModeContainerView.alpha = 0.0f;
    
    // Initialise the capture queue
    self.captureQueue = [[NSOperationQueue alloc] init];
    
    // Initialise the blur effect used when switching between cameras
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    
    // Listen for orientation changes so that we can update the UI
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // 3.5" and 4" devices have a smaller bottom bar
    if (CGRectGetHeight([UIScreen mainScreen].bounds) <= 568.0f) {
        self.bottomBarHeightConstraint.constant = 91.0f;
        [self.bottomBarView layoutIfNeeded];
    }
    
    // 3.5" devices have the top and bottom bars over the camera view
    if (CGRectGetHeight([UIScreen mainScreen].bounds) == 480.0f) {
        self.cameraViewTopConstraint.constant = -CGRectGetHeight(self.topBarView.frame);
        self.cameraViewBottomConstraint.constant = -CGRectGetHeight(self.bottomBarView.frame);
        [self.cameraContainerView layoutIfNeeded];
    }
    
    [self updateOrientation];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self enableCapture];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.captureQueue cancelAllOperations];
    [self.capturePreviewLayer removeFromSuperlayer];
    for (AVCaptureInput *input in self.session.inputs) {
        [self.session removeInput:input];
    }
    for (AVCaptureOutput *output in self.session.outputs) {
        [self.session removeOutput:output];
    }
    [self.session stopRunning];
    self.session = nil;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.capturePreviewLayer.frame = self.cameraContainerView.bounds;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (BOOL)shouldAutorotate
{
    // We'll rotate the UI elements manually.
    // The downside of this is that the device is technically always in portrait
    // which means that the Control Center always pulls up from the edge with
    // the home button even when the device is landscape
    return NO;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark -
#pragma mark Accessors

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    _flashMode = flashMode;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // Main thread work (UI usually)
         [self updateFlashButton];
    }];
   
}


#pragma mark -
#pragma mark UI

/**
 *  @brief Toggle the visibility of the flash mode buttons and camera button. Animated
 */
- (void)toggleFlashModeButtons
{
    [UIView animateWithDuration:0.3f animations:^{
        self.flashModeContainerView.alpha = self.flashModeContainerView.alpha == 1.0f ? 0.0f : 1.0f;
        self.cameraButton.alpha = self.cameraButton.alpha == 1.0f ? 0.0f : 1.0f;
    }];
}


/**
 *  @brief Update the image for the flash button based on the current flash mode
 */
- (void)updateFlashButton
{
    switch (self.flashMode) {
        case AVCaptureFlashModeAuto:
            [self.flashButton setImage:[UIImage imageNamed:@"ic_flash_auto_white"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureFlashModeOn:
            [self.flashButton setImage:[UIImage imageNamed:@"ic_flash_on_white"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureFlashModeOff:
            [self.flashButton setImage:[UIImage imageNamed:@"ic_flash_off_white"] forState:UIControlStateNormal];
            break;
    }
}


/**
 *  @brief Rotate the UI elements based on the device orientation. Animated
 */
- (void)updateOrientation
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    CGFloat angle;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            angle = - M_PI_2;
            break;
            
        default:
            angle = 0;
            break;
    }
    
    [UIView animateWithDuration:.3 animations:^{
        self.flashButton.transform = CGAffineTransformMakeRotation(angle);
        self.flashAutoButton.transform = CGAffineTransformMakeRotation(angle);
        self.flashOnButton.transform = CGAffineTransformMakeRotation(angle);
        self.flashOffButton.transform = CGAffineTransformMakeRotation(angle);
        self.cameraButton.transform = CGAffineTransformMakeRotation(angle);
        self.openPhotoAlbumButton.transform = CGAffineTransformMakeRotation(angle);
        self.takePhotoButton.transform = CGAffineTransformMakeRotation(angle);
//        self.cancelButton.transform = CGAffineTransformMakeRotation(angle);
    }];
}


#pragma mark -
#pragma mark Helpers

- (void)enableCapture
{
    if (self.session) return;
    
    self.flashButton.hidden = YES;
    self.cameraButton.hidden = YES;
    
    NSBlockOperation *operation = [self captureOperation];
    operation.completionBlock = ^{
        [self operationCompleted];
    };
    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    [self.captureQueue addOperation:operation];
}


- (NSBlockOperation *)captureOperation
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        self.session = [[AVCaptureSession alloc] init];
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!input) return;
        
        [self.session addInput:input];
        
        // Turn on point autofocus for middle of view
        [device lockForConfiguration:&error];
        if (!error) {
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                device.focusPointOfInterest = CGPointMake(0.5,0.5);
                device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
           
            AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
            
        
            
            
            if ([device hasFlash]) {
                photoSettings.flashMode = AVCaptureFlashModeAuto;
            } else {
                photoSettings.flashMode = AVCaptureFlashModeOff;
            }
            self.flashMode = photoSettings.flashMode;
        }
        [device unlockForConfiguration];
        
        self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Main thread work (UI usually)
           self.capturePreviewLayer.frame = self.cameraContainerView.bounds;
        }];
        
        self.capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
       
        
        
        // Still Image Output
//        AVCaptureStillImageOutput *stillOutput = [[AVCaptureStillImageOutput alloc] init];
//        stillOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
//        [self.session addOutput:stillOutput];
         [self.session addOutput: photoOutput];
    }];
    return operation;
}


- (void)operationCompleted
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.session) return;
        self.capturePreviewView = [[UIView alloc] initWithFrame:CGRectZero];
#if TARGET_IPHONE_SIMULATOR
        self.capturePreviewView.backgroundColor = [UIColor redColor];
#endif
        [self.cameraContainerView addSubview:self.capturePreviewView];
        [self.capturePreviewView autoPinEdgesToSuperviewEdges];
        [self.capturePreviewView.layer addSublayer:self.capturePreviewLayer];
        [self.session startRunning];
        if ([[self currentDevice] hasFlash]) {
            [self updateFlashlightState];
            self.flashButton.hidden = NO;
        }
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] &&
            [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            self.cameraButton.hidden = NO;
        }
    });
}


- (void)updateFlashlightState
{
    if (![self currentDevice]) return;
    
    self.flashAutoButton.selected = self.flashMode == AVCaptureFlashModeAuto;
    self.flashOnButton.selected = self.flashMode == AVCaptureFlashModeOn;
    self.flashOffButton.selected = self.flashMode == AVCaptureFlashModeOff;
    
    AVCaptureDevice *device = [self currentDevice];
    NSError *error = nil;
    BOOL success = [device lockForConfiguration:&error];
    if (success) {
//        device.flashMode = self.flashMode;
        AVCapturePhotoSettings *photosettings = [AVCapturePhotoSettings photoSettings];
        photosettings.flashMode=self.flashMode;
    }
    [device unlockForConfiguration];
}


- (AVCaptureDevice *)currentDevice
{
    return [(AVCaptureDeviceInput *)self.session.inputs.firstObject device];
}


- (AVCaptureDevice *)frontCamera
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}


- (UIImageOrientation)currentImageOrientation
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIImageOrientation imageOrientation;
    
    AVCaptureDeviceInput *input = self.session.inputs.firstObject;
    if (input.device.position == AVCaptureDevicePositionBack) {
        switch (deviceOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationUp;
                break;
                
            case UIDeviceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationDown;
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationLeft;
                break;
                
            default:
                imageOrientation = UIImageOrientationRight;
                break;
        }
    } else {
        switch (deviceOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationDownMirrored;
                break;
                
            case UIDeviceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationUpMirrored;
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationRightMirrored;
                break;
                
            default:
                imageOrientation = UIImageOrientationLeftMirrored;
                break;
        }
    }
    
    return imageOrientation;
}


- (void)takePicture
{
    if (!self.cameraButton.enabled) return;
    
    AVCapturePhotoOutput *output = self.session.outputs.lastObject;
//    AVCaptureStillImageOutput *output = self.session.outputs.lastObject;
    AVCaptureConnection *videoConnection = output.connections.lastObject;
    if (!videoConnection) return;
    
    [output capturePhotoWithSettings:[AVCapturePhotoSettings photoSettings] delegate:self];
//    [output captureStillImageAsynchronouslyFromConnection:videoConnection
//                                        completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//                                            self.cameraButton.enabled = YES;
//
//                                            if (!imageDataSampleBuffer || error) return;
//
//                                            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//
//                                            UIImage *image = [UIImage imageWithCGImage:[[[UIImage alloc] initWithData:imageData] CGImage]
//                                                                                 scale:1.0f
//                                                                           orientation:[self currentImageOrientation]];
//
//                                            [self handleImage:image];
//                                        }];
    
    self.cameraButton.enabled = NO;
}


-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error{
    
    self.cameraButton.enabled = YES;
    
    if ( error != nil || output==nil) {
        NSLog( @"Error capturing photo: %@", error );
        return;
    }

    
    NSData *imageData = [photo fileDataRepresentation];
    
    UIImage *image = [UIImage imageWithCGImage:[[[UIImage alloc] initWithData:imageData] CGImage]
                                         scale:1.0f
                                   orientation:[self currentImageOrientation]];
    
    [self handleImage:image];
}


/**
 *  @brief Do something with the image that's been taken (camera) / chosen (photo album)
 *
 *  @param image The image
 */
- (void)handleImage:(UIImage *)image
{
    ImageViewerViewController *viewController = [[ImageViewerViewController alloc] initWithImage:image];
//    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonWasTouched:)];
    
    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(uploadBarButtonWasTouched:)];
    
    objc_setAssociatedObject(uploadButton, &imageKey, image, OBJC_ASSOCIATION_RETAIN); // provide button , key , object for passing

    viewController.navigationItem.rightBarButtonItem = uploadButton;
    
    viewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBarButtonWasTouched:)];
    
    
    
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma mark -
#pragma mark Actions

- (IBAction)flashButtonWasTouched:(UIButton *)sender
{
    [self toggleFlashModeButtons];
}


- (IBAction)flashModeButtonWasTouched:(UIButton *)sender
{
    if (sender == self.flashAutoButton) {
        self.flashMode = AVCaptureFlashModeAuto;
    } else if (sender == self.flashOnButton) {
        self.flashMode = AVCaptureFlashModeOn;
    } else {
        self.flashMode = AVCaptureFlashModeOff;
    }
    
    [self updateFlashlightState];
    
    [self toggleFlashModeButtons];
}


- (IBAction)cameraButtonWasTouched:(UIButton *)sender
{
    if (!self.session) return;
    [self.session stopRunning];
    
    // Input Switch
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        AVCaptureDeviceInput *input = self.session.inputs.firstObject;
        
        AVCaptureDevice *newCamera = nil;
        
        if (input.device.position == AVCaptureDevicePositionBack) {
            newCamera = [self frontCamera];
        } else {
            newCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        }
        
        // Should the flash button still be displayed?
        dispatch_async(dispatch_get_main_queue(), ^{
            self.flashButton.hidden = !newCamera.isFlashAvailable;
        });
        
        // Remove previous camera, and add new
        [self.session removeInput:input];
        NSError *error = nil;
        
        input = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
        if (!input) return;
        [self.session addInput:input];
    }];
    operation.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.session) return;
            [self.session startRunning];
            [self.blurView removeFromSuperview];
        });
    };
    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    
    // disable button to avoid crash if the user spams the button
    self.cameraButton.enabled = NO;
    
    // Add blur to avoid flickering
    self.blurView.hidden = NO;
    [self.capturePreviewView addSubview:self.blurView];
    [self.blurView autoPinEdgesToSuperviewEdges];
    
    // Flip Animation
    [UIView transitionWithView:self.capturePreviewView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowAnimatedContent
                    animations:nil
                    completion:^(BOOL finished) {
                        self.cameraButton.enabled = YES;
                        [self.captureQueue addOperation:operation];
                    }];
}


- (IBAction)openPhotoAlbumButtonWasTouched:(UIButton *)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


- (IBAction)takePhotoButtonWasTouched:(UIButton *)sender
{
    [self takePicture];
}


//- (IBAction)cancelButtonWasTouched:(UIButton *)sender
//{
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//}


- (void)orientationChanged:(NSNotification *)sender
{
    [self updateOrientation];
}


- (void)uploadBarButtonWasTouched:(UIBarButtonItem *)sender{
    
    UIImage *image = objc_getAssociatedObject(sender, &imageKey); //using button and key
    if (image){
        [[ServerCommunication alloc] testUploadImage:image WithCompletion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
             [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
    }
    
}
- (void)cancelBarButtonWasTouched:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleImage:image];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
