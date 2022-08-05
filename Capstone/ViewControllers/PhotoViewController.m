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
#import "AppDelegate.h"
#import "AVKit/AVKit.h"
#import "MBProgressHUD.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "ParseReactionAPIManager.h"
#import "ParsePostAPIManager.h"
#import "NotificationManager.h"
#import "PlayVideoViewController.h"

static Float32 _spacing = 20.0;
static Float32 _aspectRatio = 16.0/9.0;
static Float32 _aspectRatioConstant = 0.0;
static Float32 _buttonWidthMultiplier = 4.0;
static Float32 _buttonHeightMultiplier = 1.5;
static Float32 _backFrontRatio = 0.25;
static NSInteger _videoLength = 5;
static NSInteger _videoTimeScale = 1;
static NSInteger _priorityValue = 0;
static NSInteger _startTime = 0;

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
    UIButton *_picButton;
    
    dispatch_queue_t _dataOutputQueue;
    AVCaptureDevicePosition _pipDevicePosition;
    NSLayoutConstraint *_frontCameraPiPConstraints;
    NSLayoutConstraint *_backCameraPiPConstraints;
    BOOL _isRecording;
    BOOL _donePosting;
    BOOL _takePic;
    BOOL _frontCamInForeground;
    NSURL *_frontUrl;
    NSURL *_backUrl;
    AVCaptureMovieFileOutput *_frontMovieFileOutput;
    AVCaptureMovieFileOutput *_backMovieFileOutput;
    UIBackgroundTaskIdentifier _backgroundRecordingID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRecordingConstants];
    [self setupLiveDisplayConstants];
    if (!self.isPicture) {
        [self setupDoubleTapGesture];
        [self setupTimer];
    }
    [self updateViewConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _captureSession = [AVCaptureMultiCamSession new];
    [_captureSession beginConfiguration];
    [self setupCameras];
    [self setupMicrophone];
    [self setupButton];
    [self setupFileOutput];
    if (self.isPicture) {
        [_recordButton removeFromSuperview];
        [self setupPictureButton];
    }
    [_captureSession commitConfiguration];
    [_captureSession startRunning];
}

-(void)setupRecordingConstants {
    _isRecording = NO;
    _donePosting = NO;
    _takePic = NO;
    _frontCamInForeground = YES;
    _recordButton = [[UIButton alloc] init];
    _picButton = [[UIButton alloc] init];
    _backUrl = [self tempURL];
    _frontUrl = [self tempURL];
    _dataOutputQueue = dispatch_queue_create("data output queue", DISPATCH_QUEUE_SERIAL);
}

-(void)setupLiveDisplayConstants {
    _background = [[UIView alloc] init];
    _foreground = [[UIView alloc] init];
    _pipDevicePosition = AVCaptureDevicePositionFront;
    AppDelegate *shared = [UIApplication sharedApplication].delegate;
    shared.disableRotation = YES;
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
}

-(void)setupDoubleTapGesture {
    UITapGestureRecognizer *toggleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePiP)];
    [toggleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:toggleTapGestureRecognizer];
}

-(void)setupTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:_videoLength target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

-(void)connectCameras:(AVCaptureDevice *)camera withOutput:(AVCaptureVideoDataOutput *)output withLayer:(AVCaptureVideoPreviewLayer *)layer isFront:(BOOL)isFront {
    NSError *error;
    // add camera input
    AVCaptureDeviceInput *cameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    if (!error) {
        output = [AVCaptureVideoDataOutput new];
    }
    if ([_captureSession canAddInput:cameraDeviceInput]) {
        [_captureSession addInputWithNoConnections:cameraDeviceInput];
    }
    // connect camera output
    AVCaptureInputPort *cameraVideoPort = [[cameraDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:camera.deviceType sourceDevicePosition:camera.position] firstObject];
    if ([_captureSession canAddOutput:output]) {
        [_captureSession addOutputWithNoConnections:output];
    }
    [output setSampleBufferDelegate:self queue:_dataOutputQueue];
    // add camera connections
    AVCaptureConnection *connection = [AVCaptureConnection connectionWithInputPorts:@[cameraVideoPort] output:output];
    if ([_captureSession canAddConnection:connection]) {
        [_captureSession addConnection:connection];
    }
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if (isFront) {
        [self setupFrontLivePreview];
    } else {
        [self setupBackLivePreview];
    }
    // connect camera to layer
    AVCaptureConnection *cameraVideoPreviewLayerConnection = [AVCaptureConnection connectionWithInputPort:cameraVideoPort videoPreviewLayer:layer];
    if ([_captureSession canAddConnection:cameraVideoPreviewLayerConnection]) {
        [_captureSession addConnection:cameraVideoPreviewLayerConnection];
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

-(void)setupPictureButton {
    [self.view addSubview:_picButton];
    [self setupPictureButtonConstraints];
    _picButton.tintColor = [UIColor blackColor];
    [_picButton setTitleColor:[UIColor blackColor] forState:normal];
    [_picButton setTitle:@"React" forState:normal];
    [_picButton addTarget:self action:@selector(didTapRecord:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupPhotoView {
    [_backCameraVideoPreviewLayer removeFromSuperlayer];
    [_frontCameraVideoPreviewLayer removeFromSuperlayer];
    [_background.layer addSublayer:_frontCameraVideoPreviewLayer];
    _frontCameraVideoPreviewLayer.frame = self->_background.bounds;
    [_foreground.layer addSublayer:_backCameraVideoPreviewLayer];
    _backCameraVideoPreviewLayer.frame = self->_foreground.bounds;
    [_foreground setHidden:YES];
}

-(void)setupFileOutput {
    _frontMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    // record time limit 5 seconds
    CMTime timeLimit;
    if (self.isPicture) {
        timeLimit = CMTimeMake(_videoTimeScale, _videoTimeScale);
    } else {
        timeLimit = CMTimeMake(_videoLength, _videoTimeScale);
    }
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
    [self connectCameras:_frontCamera withOutput:_frontCameraVideoDataOutput withLayer:_frontCameraVideoPreviewLayer isFront:YES];
    [self connectCameras:_backCamera withOutput:_backCameraVideoDataOutput withLayer:_backCameraVideoPreviewLayer isFront:NO];
}

-(AVCaptureVideoPreviewLayer *)setupPreviewLayers {
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    if (layer) {
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
        layer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return layer;
}

- (void)setupFrontLivePreview {
    _frontCameraVideoPreviewLayer = [self setupPreviewLayers];
    if (_frontCameraVideoPreviewLayer) {
        [_foreground.layer addSublayer:_frontCameraVideoPreviewLayer];
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, _priorityValue);
        dispatch_async(globalQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isPicture) {
                    [self setupPhotoView];
                    self->_frontCameraVideoPreviewLayer.frame = self->_background.bounds;
                } else {
                    self->_frontCameraVideoPreviewLayer.frame = self->_foreground.bounds;
                }
            });
        });
    }
}

- (void)setupBackLivePreview {
    _backCameraVideoPreviewLayer = [self setupPreviewLayers];
    if (_backCameraVideoPreviewLayer) {
        [_background.layer addSublayer:_backCameraVideoPreviewLayer];
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, _priorityValue);
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
        [_backMovieFileOutput startRecordingToOutputFileURL:_backUrl recordingDelegate:self];
        [_frontMovieFileOutput startRecordingToOutputFileURL:_frontUrl recordingDelegate:self];
        if (!self.isPicture) {
            _isRecording = YES;
            [self setupButton];
        }
    }
}

-(void)postVideo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You've taken 5!" message:@"Do you want to post?" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"no" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self postVideoToParse:^(NSError *error) {
            // finish posting before switching view controllers
            [self->_recordButton setEnabled:NO];
            self->_donePosting = YES;
        }];
    }];
    [alert addAction:okAction];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save & Post" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self postVideoToParse:^(NSError *error) {
            // whichever video finishes posting first, prepare switching view controllers
            [self->_recordButton setEnabled:NO];
            self->_donePosting = YES;
        }];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *frontRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self->_frontUrl];
            PHAssetChangeRequest *backRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self->_backUrl];
        } completionHandler:^(BOOL success, NSError *error) {
            self->_donePosting = YES;
        }];
    }];
    [alert addAction:saveAction];
    [self presentViewController:alert animated:YES completion:^{
    }];
}

-(void)postReaction {
    UIImage *reactionImage = [Post imageFromVideo:_frontUrl atTime:_startTime];
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [[ParseReactionAPIManager sharedManager] postReactionWithCompletion:reactionImage withPostID:self.postID completion:^(Reactions * _Nonnull reaction, NSError * _Nonnull error) {
        if ([self.delegate respondsToSelector:@selector(didSendPic:)]) {
            [self.delegate didSendPic:reaction];
        }
        [MBProgressHUD hideHUDForView:self.view animated:true];
        [[self navigationController] popViewControllerAnimated:YES];
    }];
}

-(void)postVideoToParse:(void(^)(NSError *error))completion {
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [[ParsePostAPIManager sharedManager] postVideoWithCompletion:self->_frontUrl backURL:self->_backUrl withOrientation:_frontCamInForeground completion:^(NSError * _Nonnull error) {
        if (!error) {
            [MBProgressHUD hideHUDForView:self.view animated:true];
            PlayVideoViewController *playVideoVC = [[PlayVideoViewController alloc] init];
            playVideoVC.vid1 = self->_frontUrl;
            playVideoVC.vid2 = self->_backUrl;
            playVideoVC.isFrontCamInForeground = self->_frontCamInForeground;
            [self presentViewController:playVideoVC animated:YES completion:nil];
            completion(error);
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
    if (!_backMovieFileOutput.isRecording && !_frontMovieFileOutput.isRecording) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIBackgroundTaskIdentifier currBackgroundRecordingID = self->_backgroundRecordingID;
            self->_backgroundRecordingID = UIBackgroundTaskInvalid;
            if (currBackgroundRecordingID != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:currBackgroundRecordingID];
            }
            if (!self.isPicture) {
                [self postVideo];
            } else {
                [self postReaction];
            }
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

// only allowed while not recording
- (void)togglePiP {
    if (!_isRecording) {
        // disable animations so views move immediately
        [CATransaction begin];
        [UIView setAnimationsEnabled:NO];
        [CATransaction setDisableActions:YES];
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
        _frontCamInForeground = !_frontCamInForeground;
        // re-enable animations
        [CATransaction commit];
        [UIView setAnimationsEnabled:YES];
        [CATransaction setDisableActions:NO];
    }
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
    _frontCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_foreground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_foreground attribute:NSLayoutAttributeWidth multiplier:_aspectRatio constant:_aspectRatioConstant];
    _backCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_background attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_background attribute:NSLayoutAttributeWidth multiplier:_aspectRatio constant:_aspectRatioConstant];
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
    [_recordButton.widthAnchor constraintGreaterThanOrEqualToConstant:_buttonWidthMultiplier * _spacing].active = YES;
    [_recordButton.heightAnchor constraintEqualToConstant:_buttonHeightMultiplier * _spacing].active = YES;
    [_recordButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
}

-(void)setupPictureButtonConstraints {
    [_picButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_picButton.widthAnchor constraintGreaterThanOrEqualToConstant:_buttonWidthMultiplier * _spacing].active = YES;
    [_picButton.heightAnchor constraintEqualToConstant:_buttonHeightMultiplier * _spacing].active = YES;
    [_picButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_background.bottomAnchor constraintEqualToAnchor:_picButton.bottomAnchor constant:_spacing].active = YES;
}

-(void)checkTime{
    [[NotificationManager sharedManager] isTime:^(BOOL isTime) {
        if (!isTime || self->_donePosting) {
            [self performSegueWithIdentifier:@"postSegue" sender:nil];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_captureSession stopRunning];
}

@end
