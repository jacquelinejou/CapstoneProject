//
//  PhotoViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import "PhotoViewController.h"
#import "MapViewController.h"
#import "Photos/Photos.h"
#import "Post.h"
#import "AVKit/AVKit.h"
#import "MBProgressHUD.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "APIManager.h"
#import "NotificationManager.h"

@interface PhotoViewController ()
@end

@implementation PhotoViewController {
    AVCaptureMultiCamSession *_captureSession;
    AVCaptureVideoDataOutput *_backCameraVideoDataOutput;
    AVCaptureVideoDataOutput *_frontCameraVideoDataOutput;
    AVCaptureAudioDataOutput *_backMicrophoneAudioDataOutput;
    AVCaptureAudioDataOutput *_frontMicrophoneAudioDataOutput;
    AVCaptureVideoPreviewLayer *_backCameraVideoPreviewLayer;
    AVCaptureVideoPreviewLayer *_frontCameraVideoPreviewLayer;
    AVCaptureDevice *_backCamera;
    AVCaptureDevice *_frontCamera;
    AVCaptureDevice *_microphone;
    
    UIView *_background;
    UIView *_foreground;
    UIButton *_recordButton;
    
    Float32 _spacing;
    Float32 _aspectRatio;
    Float32 _backFrontRatio;
    
    dispatch_queue_t _dataOutputQueue;
    AVCaptureDevicePosition _pipDevicePosition;
    NSLayoutConstraint *_frontCameraPiPConstraints;
    NSLayoutConstraint *_backCameraPiPConstraints;
    BOOL _isRecording;
    BOOL _donePosting;
    NSURL *_frontUrl;
    NSURL *_backUrl;
    AVCaptureMovieFileOutput *_frontMovieFileOutput;
    AVCaptureMovieFileOutput *_backMovieFileOutput;
    UIBackgroundTaskIdentifier _backgroundRecordingID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConstraintConstants];
    [self setupRecordingConstants];
    [self setupLiveDisplayConstants];
    [self setupTimer];
    [self updateViewConstraints];
}

-(void)setupConstraintConstants {
    _spacing = 20.0;
    _aspectRatio = 16.0/9.0;
    _backFrontRatio = 0.25;
}

-(void)setupRecordingConstants {
    _isRecording = NO;
    _donePosting = NO;
    _recordButton = [[UIButton alloc] init];
    _frontUrl = [self tempURL];
    _backUrl = [self tempURL];
    _dataOutputQueue = dispatch_queue_create("data output queue", DISPATCH_QUEUE_SERIAL);
}

-(void)setupLiveDisplayConstants {
    _background = [[UIView alloc] init];
    _foreground = [[UIView alloc] init];
    _pipDevicePosition = AVCaptureDevicePositionFront;
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
}

-(void)setupDoubleTapGesture {
    UITapGestureRecognizer *toggleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePiP)];
    [toggleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:toggleTapGestureRecognizer];
}

-(void)setupTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _captureSession = [AVCaptureMultiCamSession new];
    [_captureSession beginConfiguration];
    [self setupCameras];
    [self setupBackCamera];
    [self setupFrontCamera];
    [self setupFileOutput];
    [self setupButton];
    
    [_captureSession commitConfiguration];
    [_captureSession startRunning];
}

-(void)setupFrontCamera {
    NSError *frontError;
    // add front camera input
    AVCaptureDeviceInput *frontCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontCamera error:&frontError];
    if (!frontError) {
        _frontCameraVideoDataOutput = [AVCaptureVideoDataOutput new];
    }
    if ([_captureSession canAddInput:frontCameraDeviceInput]) {
        [_captureSession addInputWithNoConnections:frontCameraDeviceInput];
    }
    // connect front camera output
    AVCaptureInputPort *frontCameraVideoPort = [[frontCameraDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:_frontCamera.deviceType sourceDevicePosition:_frontCamera.position] firstObject];
    if ([_captureSession canAddOutput:_frontCameraVideoDataOutput]) {
        [_captureSession addOutputWithNoConnections:_frontCameraVideoDataOutput];
    }
    [_frontCameraVideoDataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    // add front camera connections
    AVCaptureConnection *connection = [AVCaptureConnection connectionWithInputPorts:@[frontCameraVideoPort] output:_frontCameraVideoDataOutput];
    if ([_captureSession canAddConnection:connection]) {
        [_captureSession addConnection:connection];
    }
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self setupFrontLivePreview];
    // connect front camera to layer
    AVCaptureConnection *frontCameraVideoPreviewLayerConnection = [AVCaptureConnection connectionWithInputPort:frontCameraVideoPort videoPreviewLayer:_frontCameraVideoPreviewLayer];
    if ([_captureSession canAddConnection:frontCameraVideoPreviewLayerConnection]) {
        [_captureSession addConnection:frontCameraVideoPreviewLayerConnection];
    }
}

-(void)setupBackCamera {
    NSError *backError;
    // add back camera input
    AVCaptureDeviceInput *backCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_backCamera error:&backError];
    if (!backError) {
        _backCameraVideoDataOutput = [AVCaptureVideoDataOutput new];
    }
    if ([_captureSession canAddInput:backCameraDeviceInput]) {
        [_captureSession addInputWithNoConnections:backCameraDeviceInput];
    }
    // connect back camera output
    AVCaptureInputPort *backCameraVideoPort = [[backCameraDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:_backCamera.deviceType sourceDevicePosition:_backCamera.position] firstObject];
    if ([_captureSession canAddOutput:_backCameraVideoDataOutput]) {
        [_captureSession addOutputWithNoConnections:_backCameraVideoDataOutput];
    }
    [_backCameraVideoDataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    // add back camera connections
    AVCaptureConnection *connection = [AVCaptureConnection connectionWithInputPorts:@[backCameraVideoPort] output:_backCameraVideoDataOutput];
    if ([_captureSession canAddConnection:connection]) {
        [_captureSession addConnection:connection];
    }
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self setupBackLivePreview];
    // connect back camera to layer
    AVCaptureConnection *backCameraVideoPreviewLayerConnection = [AVCaptureConnection connectionWithInputPort:backCameraVideoPort videoPreviewLayer:_backCameraVideoPreviewLayer];
    if ([_captureSession canAddConnection:backCameraVideoPreviewLayerConnection]) {
        [_captureSession addConnection:backCameraVideoPreviewLayerConnection];
    }
}

-(void)setupMicrophone {
    _microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (!_microphone) {
        return;
    }
    // add microphone input to session
    NSError * error = NULL;
    AVCaptureDeviceInput *microphoneDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_microphone error:&error];
    if (!error) {
        _backMicrophoneAudioDataOutput = [AVCaptureAudioDataOutput new];
        _frontMicrophoneAudioDataOutput = [AVCaptureAudioDataOutput new];
    }
    if ([_captureSession canAddInput:microphoneDeviceInput]) {
        [_captureSession addInputWithNoConnections:microphoneDeviceInput];
    }
    // add microphone output to session
    AVCaptureInputPort *backMicrophonePort = [[microphoneDeviceInput portsWithMediaType:AVMediaTypeAudio sourceDeviceType:_microphone.deviceType sourceDevicePosition:AVCaptureDevicePositionBack] firstObject];
    AVCaptureInputPort *frontMicrophonePort = [[microphoneDeviceInput portsWithMediaType:AVMediaTypeAudio sourceDeviceType:_microphone.deviceType sourceDevicePosition:AVCaptureDevicePositionFront] firstObject];
    if ([_captureSession canAddOutput:_backMicrophoneAudioDataOutput]) {
        [_captureSession addOutputWithNoConnections:_backMicrophoneAudioDataOutput];
    }
    [_backMicrophoneAudioDataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    if ([_captureSession canAddOutput:_frontMicrophoneAudioDataOutput]) {
        [_captureSession addOutputWithNoConnections:_frontMicrophoneAudioDataOutput];
    }
    [_frontMicrophoneAudioDataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    NSArray *backInputPorts = [[NSArray alloc] initWithObjects:backMicrophonePort, nil];
    AVCaptureConnection *backMicrophoneAudioDataOutputConnection = [AVCaptureConnection connectionWithInputPorts:backInputPorts output:_backMicrophoneAudioDataOutput];
    if ([_captureSession canAddConnection:backMicrophoneAudioDataOutputConnection]) {
        [_captureSession addConnection:backMicrophoneAudioDataOutputConnection];
    }
    // connect audio to session
    NSArray *frontInputPorts = [[NSArray alloc] initWithObjects:frontMicrophonePort, nil];
    AVCaptureConnection *frontMicrophoneAudioDataOutputConnection = [AVCaptureConnection connectionWithInputPorts:frontInputPorts output:_frontMicrophoneAudioDataOutput];
    if ([_captureSession canAddConnection:frontMicrophoneAudioDataOutputConnection]) {
        [_captureSession addConnection:frontMicrophoneAudioDataOutputConnection];
    }
}

-(void)setupButton {
    UIColor *color = [[UIColor alloc] init];
    NSString *title = [[NSString alloc] init];
    if (_isRecording) {
        color = [UIColor redColor];
        title = @"Stop";
    } else {
        color = [UIColor blackColor];
        title = @"Record";
    }
    _recordButton.tintColor = color;
    [_recordButton setTitleColor:color forState:normal];
    [_recordButton setTitle:title forState:normal];
    [_recordButton addTarget:self action:@selector(didTapRecord:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupFileOutput {
    _frontMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    // record time limit 5 seconds
    CMTime timeLimit = CMTimeMake(5, 1);
    _frontMovieFileOutput.maxRecordedDuration = timeLimit;
    if([_captureSession canAddOutput:_frontMovieFileOutput]){
        [_captureSession addOutput:_frontMovieFileOutput];
    }
    _backMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    _backMovieFileOutput.maxRecordedDuration = timeLimit;
    if([_captureSession canAddOutput:_backMovieFileOutput]){
        [_captureSession addOutput:_backMovieFileOutput];
    }
    if (UIDevice.currentDevice.isMultitaskingSupported) {
        _backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    }
}

-(NSDictionary *)createAudioSettings {
    NSDictionary *backMicrophoneAudioSettings = [_backMicrophoneAudioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
    NSDictionary *frontMicrophoneAudioSettings = [_frontMicrophoneAudioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
    if ([backMicrophoneAudioSettings isEqualToDictionary:frontMicrophoneAudioSettings]) {
        return backMicrophoneAudioSettings;
    } else {
        return nil;
    }
}

-(void)setupCameras {
    AVCaptureDeviceDiscoverySession *captureBackDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    AVCaptureDeviceDiscoverySession *captureFrontDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    // find a front and back camera
    NSMutableArray * devices = (NSMutableArray *)[captureBackDeviceDiscoverySession devices];
    [devices addObjectsFromArray:[captureFrontDeviceDiscoverySession devices]];
    for (AVCaptureDevice * device in devices) {
        if (AVCaptureDevicePositionFront == [device position]) {
            _frontCamera = device;
        }
        else if (AVCaptureDevicePositionBack == [device position]) {
            _backCamera = device;
        }
    }
}

- (void)setupFrontLivePreview {
    _frontCameraVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    if (_frontCameraVideoPreviewLayer) {
        _frontCameraVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _frontCameraVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [_foreground.layer addSublayer:_frontCameraVideoPreviewLayer];
        
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_frontCameraVideoPreviewLayer.frame = self->_foreground.bounds;
            });
        });
    }
}

- (void)setupBackLivePreview {
    _backCameraVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    if (_backCameraVideoPreviewLayer) {
        _backCameraVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _backCameraVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [_background.layer addSublayer:_backCameraVideoPreviewLayer];
        
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_backCameraVideoPreviewLayer.frame = self->_background.bounds;
            });
        });
    }
}

-(IBAction)didTapRecord:(id)sender {
    [_recordButton setEnabled:NO];
    if (!_isRecording) {
        [_frontMovieFileOutput startRecordingToOutputFileURL:_frontUrl recordingDelegate:self];
        [_backMovieFileOutput startRecordingToOutputFileURL:_backUrl recordingDelegate:self];
        _isRecording = YES;
        [self setupButton];
    }
}

-(void)postVideo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You've taken 5!" message:@"Do you want to post?" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"no" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self postHelper];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = [AVPlayer playerWithURL:self->_backUrl];
        [self presentViewController:playerViewController animated:YES completion:^{
            //Start Playback
            [playerViewController.player play];
            self -> _donePosting = YES;
        }];
    }];
    [alert addAction:okAction];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save & Post" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self postHelper];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self->_backUrl];
        } completionHandler:^(BOOL success, NSError *error) {
            self->_donePosting = YES;
        }];
    }];
    [alert addAction:saveAction];
    [self presentViewController:alert animated:YES completion:^{
    }];
}

-(void)postHelper {
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [[APIManager sharedManager] postVideoWithCompletion:self->_backUrl completion:^(NSError * _Nonnull error) {
        if (!error) {
            [MBProgressHUD hideHUDForView:self.view animated:true];
        }
    }];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if ([output isEqual:_frontMovieFileOutput]) {
        [_frontMovieFileOutput stopRecording];
    } else if ([output isEqual:_backMovieFileOutput]) {
        [_backMovieFileOutput stopRecording];
    }
    [self->_recordButton setEnabled:YES];
    _isRecording = NO;
    [self setupButton];
    if (!_backMovieFileOutput.isRecording && !_backMovieFileOutput.isRecording) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIBackgroundTaskIdentifier currBackgroundRecordingID = self->_backgroundRecordingID;
            self->_backgroundRecordingID = UIBackgroundTaskInvalid;
            if (currBackgroundRecordingID != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:currBackgroundRecordingID];
            }
            [self postVideo];
        });
    }
}

-(NSURL *)tempURL {
    NSString *outputFileName = [[NSUUID UUID] UUIDString];
    NSURL *outputFileURL = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:outputFileName] URLByAppendingPathExtension:@"MOV"];
    if([[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path]) {
        NSError *err;
        [[NSFileManager defaultManager] removeItemAtPath:outputFileURL.path error:&err];
    }
    return outputFileURL;
}

- (void)togglePiP {
    // disable animations so views move immediately
    [CATransaction begin];
    [UIView setAnimationsEnabled:NO];
    [CATransaction setDisableActions:YES];
    
    NSMutableArray *frontCam = [[NSMutableArray alloc] init];
    [frontCam addObject:_frontCameraPiPConstraints];
    NSMutableArray *backCam = [[NSMutableArray alloc] init];
    [backCam addObject:_backCameraPiPConstraints];
    [_backCameraVideoPreviewLayer removeFromSuperlayer];
    [_frontCameraVideoPreviewLayer removeFromSuperlayer];
    if (_pipDevicePosition == AVCaptureDevicePositionFront) {
        [_background.layer addSublayer:_frontCameraVideoPreviewLayer];
        _frontCameraVideoPreviewLayer.frame = self->_background.bounds;
        [_foreground.layer addSublayer:_backCameraVideoPreviewLayer];
        _backCameraVideoPreviewLayer.frame = self->_foreground.bounds;
        _pipDevicePosition = AVCaptureDevicePositionBack;
    } else {
        [_background.layer addSublayer:_backCameraVideoPreviewLayer];
        _backCameraVideoPreviewLayer.frame = self->_background.bounds;
        [_foreground.layer addSublayer:_frontCameraVideoPreviewLayer];
        _frontCameraVideoPreviewLayer.frame = self->_foreground.bounds;
        _pipDevicePosition = AVCaptureDevicePositionFront;
    }
    // re-enable animations
    [CATransaction commit];
    [UIView setAnimationsEnabled:YES];
    [CATransaction setDisableActions:NO];
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    [self.view addSubview:_background];
    [self.view addSubview:_foreground];
    [self.view addSubview:_recordButton];
    [_background setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_foreground setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_recordButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setupAspectRatioConstraints];
    [self setupBackgroundConstraints];
    [self setupForegroundConstraints];
    [self setupRecordButtonConstraints];
}

-(void)setupAspectRatioConstraints {
    _frontCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_foreground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_foreground attribute:NSLayoutAttributeWidth multiplier:_aspectRatio constant:0.0];
    _backCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_background attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_background attribute:NSLayoutAttributeWidth multiplier:_aspectRatio constant:0.0];
    [self.view addConstraints:@[_frontCameraPiPConstraints, _backCameraPiPConstraints]];
}

-(void)setupForegroundConstraints {
    [_foreground.widthAnchor constraintEqualToAnchor:_background.widthAnchor multiplier:_backFrontRatio].active = YES;
    [_foreground.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor].active = YES;
    [_foreground.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor].active = YES;
    [_foreground.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_foreground.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_foreground.bottomAnchor constraintEqualToAnchor:_recordButton.bottomAnchor constant:_spacing].active = YES;
}

-(void)setupBackgroundConstraints {
    [_background.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_background.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_background.trailingAnchor constraintEqualToAnchor:_foreground.trailingAnchor constant:_spacing].active = YES;
    [_background.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_background.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor].active = YES;
    [_background.bottomAnchor constraintEqualToAnchor:_foreground.bottomAnchor constant:_spacing].active = YES;
    [_background.bottomAnchor constraintEqualToAnchor:_recordButton.bottomAnchor constant:_spacing].active = YES;
    [_background.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [_background.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor].active = YES;
    
}

-(void)setupRecordButtonConstraints {
    [_recordButton.widthAnchor constraintGreaterThanOrEqualToConstant:4 * _spacing].active = YES;
    [_recordButton.heightAnchor constraintEqualToConstant:1.5 * _spacing].active = YES;
    [_recordButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
}

-(void)checkTime{
    [[NotificationManager sharedManager] isTime:^(BOOL isTime) {
        if (!isTime || self->_donePosting) {
            [self performSegueWithIdentifier:@"postSegue" sender:nil];
        }
    }];
}

@end
