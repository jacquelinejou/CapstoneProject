//
//  PhotoViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import "PhotoViewController.h"
#import "SceneDelegate.h"
#import "MapViewController.h"
#import "Photos/Photos.h"
#import "Post.h"
#import "AVKit/AVKit.h"
#import "MBProgressHUD.h"
#import "MovieRecorder.h"
#include <math.h>
#import "AssetsLibrary/AssetsLibrary.h"

@interface PhotoViewController ()
@property (nonatomic) AVCaptureMultiCamSession *captureSession;
@property (nonatomic) AVCaptureVideoDataOutput *backCameraVideoDataOutput;
@property (nonatomic) AVCaptureVideoDataOutput *frontCameraVideoDataOutput;
@property (nonatomic) AVCaptureAudioDataOutput *backMicrophoneAudioDataOutput;
@property (nonatomic) AVCaptureAudioDataOutput *frontMicrophoneAudioDataOutput;
@property (nonatomic) AVCaptureVideoPreviewLayer *backCameraVideoPreviewLayer;
@property (nonatomic) AVCaptureVideoPreviewLayer *frontCameraVideoPreviewLayer;
@property (nonatomic) AVCaptureDevice *backCamera;
@property (nonatomic) AVCaptureDevice *frontCamera;
@property (nonatomic) AVCaptureDevice *microphone;
@end

@implementation PhotoViewController {
    UIView *_background;
    UIView *_foreground;
    UIButton *_recordButton;
    
    Float32 spacing;
    Float32 widthHeight;
    Float32 backFrontRatio;
    
    dispatch_queue_t sessionQueue;
    dispatch_queue_t dataOutputQueue;
    
    AVCaptureDevicePosition pipDevicePosition;
    CGRect normalizedPipFrame;
    NSLayoutConstraint *frontCameraPiPConstraints;
    NSLayoutConstraint *backCameraPiPConstraints;
    BOOL isRecording;
    RPScreenRecorder* recorder;
    AVAssetWriter *assetWriter;
    AVAssetWriterInput *assetWriterInput;
    AVAssetWriterInput *audioWriterInput;
    NSURL *frontUrl;
    NSURL *backUrl;
    BOOL doneRecording;
    AVPlayerViewController *playerViewController;
    CGRect myContextRect;
    AVCaptureMovieFileOutput *frontMovieFileOutput;
    AVCaptureMovieFileOutput *backMovieFileOutput;
    UIBackgroundTaskIdentifier backgroundRecordingID;
    
    MovieRecorder *movieRecorder;
    CMSampleBufferRef currentPiPSampleBuffer;
    AVAssetExportSession *exporter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCaptureSession:_captureSession];
    _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    spacing = 20.0;
    widthHeight = 16.0/9.0;
    backFrontRatio = 0.25;
    isRecording = NO;
    doneRecording = NO;
    _background = [[UIView alloc] init];
    _foreground = [[UIView alloc] init];
    _recordButton = [[UIButton alloc] init];
    pipDevicePosition = AVCaptureDevicePositionFront;
    normalizedPipFrame = CGRectZero;
    frontUrl = [self tempURL];
    backUrl = [self tempURL];
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    UITapGestureRecognizer *toggleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePiP)];
    [toggleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:toggleTapGestureRecognizer];
    
    sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    dataOutputQueue = dispatch_queue_create("data output queue", DISPATCH_QUEUE_SERIAL);
    playerViewController = [[AVPlayerViewController alloc] init];
    [self updateViewConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.captureSession = [AVCaptureMultiCamSession new];
    [_captureSession beginConfiguration];
    [self setupCameras];
    [self setupBackCamera];
    [self setupFrontCamera];
    [self setupFileOutput];
    [self setupButton];
    
    [_captureSession commitConfiguration];
    [self.captureSession startRunning];
}

-(void)setupFrontCamera {
    NSError *frontError;
    AVCaptureDeviceInput *frontCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.frontCamera error:&frontError];
    if (!frontError) {
        self.frontCameraVideoDataOutput = [AVCaptureVideoDataOutput new];
    }
    if ([self.captureSession canAddInput:frontCameraDeviceInput]) {
        [self.captureSession addInputWithNoConnections:frontCameraDeviceInput];
    }
    AVCaptureInputPort *frontCameraVideoPort = [[frontCameraDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:self.frontCamera.deviceType sourceDevicePosition:self.frontCamera.position] firstObject];
    if ([self.captureSession canAddOutput:self.frontCameraVideoDataOutput]) {
        [self.captureSession addOutputWithNoConnections:self.frontCameraVideoDataOutput];
    }
    [self.frontCameraVideoDataOutput setSampleBufferDelegate:self queue:dataOutputQueue];
    AVCaptureConnection *connection = [AVCaptureConnection connectionWithInputPorts:@[frontCameraVideoPort] output:self.frontCameraVideoDataOutput];
    if ([self.captureSession canAddConnection:connection]) {
        [self.captureSession addConnection:connection];
    }
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self setupFrontLivePreview];
    AVCaptureConnection *frontCameraVideoPreviewLayerConnection = [AVCaptureConnection connectionWithInputPort:frontCameraVideoPort videoPreviewLayer:self.frontCameraVideoPreviewLayer];
    if ([self.captureSession canAddConnection:frontCameraVideoPreviewLayerConnection]) {
        [self.captureSession addConnection:frontCameraVideoPreviewLayerConnection];
    }
}

-(void)setupBackCamera {
    NSError *backError;
    AVCaptureDeviceInput *backCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:&backError];
    if (!backError) {
        self.backCameraVideoDataOutput = [AVCaptureVideoDataOutput new];
    }
    if ([self.captureSession canAddInput:backCameraDeviceInput]) {
        [self.captureSession addInputWithNoConnections:backCameraDeviceInput];
    }
    AVCaptureInputPort *backCameraVideoPort = [[backCameraDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:self.backCamera.deviceType sourceDevicePosition:self.backCamera.position] firstObject];
    if ([self.captureSession canAddOutput:self.backCameraVideoDataOutput]) {
        [self.captureSession addOutputWithNoConnections:self.backCameraVideoDataOutput];
    }
    [self.backCameraVideoDataOutput setSampleBufferDelegate:self queue:dataOutputQueue];
    AVCaptureConnection *connection = [AVCaptureConnection connectionWithInputPorts:@[backCameraVideoPort] output:self.backCameraVideoDataOutput];
    if ([self.captureSession canAddConnection:connection]) {
        [self.captureSession addConnection:connection];
    }
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self setupBackLivePreview];
    AVCaptureConnection *backCameraVideoPreviewLayerConnection = [AVCaptureConnection connectionWithInputPort:backCameraVideoPort videoPreviewLayer:self.backCameraVideoPreviewLayer];
    if ([self.captureSession canAddConnection:backCameraVideoPreviewLayerConnection]) {
        [self.captureSession addConnection:backCameraVideoPreviewLayerConnection];
    }
}

-(void)setupMicrophone {
    self.microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (!self.microphone) {
        return;
    }
    // add micrphone input to session
    NSError * error = NULL;
    AVCaptureDeviceInput *microphoneDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.microphone error:&error];
    if (!error) {
        self.backMicrophoneAudioDataOutput = [AVCaptureAudioDataOutput new];
        self.frontMicrophoneAudioDataOutput = [AVCaptureAudioDataOutput new];
    }
    if ([self.captureSession canAddInput:microphoneDeviceInput]) {
        [self.captureSession addInputWithNoConnections:microphoneDeviceInput];
    }
    AVCaptureInputPort *backMicrophonePort = [[microphoneDeviceInput portsWithMediaType:AVMediaTypeAudio sourceDeviceType:self.microphone.deviceType sourceDevicePosition:AVCaptureDevicePositionBack] firstObject];
    AVCaptureInputPort *frontMicrophonePort = [[microphoneDeviceInput portsWithMediaType:AVMediaTypeAudio sourceDeviceType:self.microphone.deviceType sourceDevicePosition:AVCaptureDevicePositionFront] firstObject];
    if ([self.captureSession canAddOutput:self.backMicrophoneAudioDataOutput]) {
        [self.captureSession addOutputWithNoConnections:self.backMicrophoneAudioDataOutput];
    }
    [self.backMicrophoneAudioDataOutput setSampleBufferDelegate:self queue:dataOutputQueue];
    if ([self.captureSession canAddOutput:self.frontMicrophoneAudioDataOutput]) {
        [self.captureSession addOutputWithNoConnections:self.frontMicrophoneAudioDataOutput];
    }
    [self.frontMicrophoneAudioDataOutput setSampleBufferDelegate:self queue:dataOutputQueue];
    NSArray *backInputPorts = [[NSArray alloc] initWithObjects:backMicrophonePort, nil];
    AVCaptureConnection *backMicrophoneAudioDataOutputConnection = [AVCaptureConnection connectionWithInputPorts:backInputPorts output:self.backMicrophoneAudioDataOutput];
    if ([self.captureSession canAddConnection:backMicrophoneAudioDataOutputConnection]) {
        [self.captureSession addConnection:backMicrophoneAudioDataOutputConnection];
    }
    NSArray *frontInputPorts = [[NSArray alloc] initWithObjects:frontMicrophonePort, nil];
    AVCaptureConnection *frontMicrophoneAudioDataOutputConnection = [AVCaptureConnection connectionWithInputPorts:frontInputPorts output:self.frontMicrophoneAudioDataOutput];
    if ([self.captureSession canAddConnection:frontMicrophoneAudioDataOutputConnection]) {
        [self.captureSession addConnection:frontMicrophoneAudioDataOutputConnection];
    }
}

-(void)setupButton {
    UIColor *color = [[UIColor alloc] init];
    NSString *title = [[NSString alloc] init];
    if (isRecording) {
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
    frontMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    CMTime timeLimit = CMTimeMake(5, 1);
    frontMovieFileOutput.maxRecordedDuration = timeLimit;
    if([self.captureSession canAddOutput:frontMovieFileOutput]){
        [self.captureSession addOutput:frontMovieFileOutput];
    }
    backMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    backMovieFileOutput.maxRecordedDuration = timeLimit;
    if([self.captureSession canAddOutput:backMovieFileOutput]){
        [self.captureSession addOutput:backMovieFileOutput];
    }
    if (UIDevice.currentDevice.isMultitaskingSupported) {
        backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
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
    NSMutableArray * devices = (NSMutableArray *)[captureBackDeviceDiscoverySession devices];
    [devices addObjectsFromArray:[captureFrontDeviceDiscoverySession devices]];
    for (AVCaptureDevice * device in devices) {
        if (AVCaptureDevicePositionFront == [device position]) {
            self.frontCamera = device;
        }
        else if (AVCaptureDevicePositionBack == [device position]) {
            self.backCamera = device;
        }
    }
}

- (void)setupFrontLivePreview {
    self.frontCameraVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    if (self.frontCameraVideoPreviewLayer) {
        self.frontCameraVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.frontCameraVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [_foreground.layer addSublayer:self.frontCameraVideoPreviewLayer];
        
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.frontCameraVideoPreviewLayer.frame = self->_foreground.bounds;
            });
        });
    }
}

- (void)setupBackLivePreview {
    self.backCameraVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    if (self.backCameraVideoPreviewLayer) {
        self.backCameraVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.backCameraVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [_background.layer addSublayer:self.backCameraVideoPreviewLayer];
        
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backCameraVideoPreviewLayer.frame = self->_background.bounds;
            });
        });
    }
}

-(IBAction)didTapRecord:(id)sender {
    [_recordButton setEnabled:NO];
    if (!isRecording) {
        [frontMovieFileOutput startRecordingToOutputFileURL:frontUrl recordingDelegate:self];
        [backMovieFileOutput startRecordingToOutputFileURL:backUrl recordingDelegate:self];
        NSLog(@"Start recording");
        isRecording = YES;
        [self setupButton];
    }
}

// contentOverlayView add another url

-(void)stitchVideos {
//    AVAsset *backVideoAsset = [AVAsset assetWithURL:backUrl];
//    AVAsset *frontVideoAsset = [AVAsset assetWithURL:frontUrl];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
//        NSLog(@"%@", self->frontUrl);
//        playerViewController.player = [AVPlayer playerWithURL:self->frontUrl];
//        [self presentViewController:playerViewController animated:YES completion:^{
//            //Start Playback
//            [playerViewController.player play];
//        }];
//    });
    NSLog(@"%@", backUrl);
    NSLog(@"%@", frontUrl);
    AVAsset *video1Asset = [AVAsset assetWithURL:backUrl];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1Asset.duration) ofTrack:[[video1Asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVAsset *video2Asset = [AVAsset assetWithURL:frontUrl];
    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video2Asset.duration) ofTrack:[[video2Asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, video1Asset.duration);
    
    AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [self videoCompositionInstruction:firstTrack withAsset:video1Asset];
    CGAffineTransform scale = CGAffineTransformMakeScale(0.68f,0.68f);
    CGAffineTransform move = CGAffineTransformMakeTranslation(secondTrack.naturalSize.height,-(secondTrack.naturalSize.width - secondTrack.naturalSize.height)/2);
    CGFloat rotation = M_PI / 2;
    CGAffineTransform rotate = CGAffineTransformRotate(move, rotation);
    [firstlayerInstruction setTransform:CGAffineTransformConcat(scale,rotate) atTime:kCMTimeZero];
    
    AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [self videoCompositionInstruction:secondTrack withAsset:video2Asset];
    CGAffineTransform secondScale = CGAffineTransformMakeScale(1.0f,1.0f);
    CGAffineTransform secondMove =  CGAffineTransformMakeTranslation(secondTrack.naturalSize.height,-(secondTrack.naturalSize.width - secondTrack.naturalSize.height)/2);
    CGAffineTransform secondRotate = CGAffineTransformRotate(secondMove, rotation);
    [secondlayerInstruction setTransform:CGAffineTransformConcat(secondScale,secondRotate) atTime:kCMTimeZero];
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction,secondlayerInstruction,nil];
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    AVAssetTrack *videoAssetTrack = [[video1Asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    mainCompositionInst.renderSize = naturalSize;
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    AVPlayerItem * newPlayerItem = [AVPlayerItem playerItemWithAsset:mixComposition];
    newPlayerItem.videoComposition = mainCompositionInst;
    
    // Create the export session with the composition and set the preset to the highest quality.
    exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    // Set the desired output URL for the file created by the export process.
    exporter.outputURL = [self tempURL];
    exporter.videoComposition = mainCompositionInst;
    // Set the output file type to be a QuickTime movie.
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                playerViewController.player = [AVPlayer playerWithURL:self->exporter.outputURL];
                [self presentViewController:playerViewController animated:YES completion:^{
                    //Start Playback
                    [playerViewController.player play];
                }];
            });
        }];
    });
}

-(AVMutableVideoCompositionLayerInstruction *)videoCompositionInstruction:(AVCompositionTrack*)track withAsset:(AVAsset*)asset {
    //    AVMutableVideoCompositionLayerInstruction *instruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
    //    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    //    CGAffineTransform transform = assetTrack.preferredTransform;
    //    CGFloat scaleToFitRation = UIScreen.mainScreen.bounds.size.width / assetTrack.naturalSize.height;
    //    CGAffineTransform scaleFactor = CGAffineTransformMakeScale(scaleToFitRation, scaleToFitRation);
    //    CGAffineTransform scaleFactor2 = assetTrack.preferredTransform;
    //    CGAffineTransform concatScaleFactor = CGAffineTransformConcat(scaleFactor, scaleFactor2);
    //    [instruction setTransform:concatScaleFactor atTime:kCMTimeZero];
    //    return instruction;
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
    BOOL isPortrait_ = [self isVideoPortrait:asset];
    if(isPortrait_) {
        NSLog(@"video is portrait ");
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    composition.naturalSize     = videoSize;
    videoComposition.renderSize = videoSize;
    // videoComposition.renderSize = videoTrack.naturalSize; //
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    return layerInst;
    //    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
    //    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //
    //    BOOL isVideoAssetPortrait_  = NO;
    //    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    //    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
    //        isVideoAssetPortrait_ = YES;
    //    }
    //    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
    //
    //        isVideoAssetPortrait_ = YES;
    //    }
    //    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
    //        isVideoAssetPortrait_  = NO;
    //    }
    //    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
    //        isVideoAssetPortrait_  = NO;
    //    }
    //    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    //    [videolayerInstruction setOpacity:0.0 atTime:asset.duration];
    //
    //    return videolayerInstruction;
    
    // 1.2 - Add instructions
    //    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    //    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    //    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    //
    //    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    //
    //    CGSize naturalSize;
    //    if(isVideoAssetPortrait_){
    //        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    //    } else {
    //        naturalSize = videoAssetTrack.naturalSize;
    //    }
    //
    //    mainCompositionInst.renderSize = naturalSize;
    //    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    //    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    //    return mainCompositionInst;
}

-(BOOL) isVideoPortrait:(AVAsset *)asset {
    BOOL isPortrait = FALSE;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            isPortrait = YES;
        } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            isPortrait = YES;
        } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            isPortrait = NO;
        } else {
            isPortrait = NO;
        }
    }
    return isPortrait;
}

-(void)postVideo {
    [self->_recordButton setEnabled:YES];
    doneRecording = YES;
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if ([output isEqual:frontMovieFileOutput]) {
        //        [frontMovieFileOutput stopRecording];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        //            NSLog(@"%@", self->frontUrl);
        //            playerViewController.player = [AVPlayer playerWithURL:self->frontUrl];
        //            [self presentViewController:playerViewController animated:YES completion:^{
        //                //Start Playback
        //                [playerViewController.player play];
        //            }];
        //        });
    } else if ([output isEqual:backMovieFileOutput]) {
        [backMovieFileOutput stopRecording];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        //            NSLog(@"%@", self->backUrl);
        //            playerViewController.player = [AVPlayer playerWithURL:self->backUrl];
        //            [self presentViewController:playerViewController animated:YES completion:^{
        //                //Start Playback
        //                [playerViewController.player play];
        //            }];
        //        });
    }
    //    [frontMovieFileOutput stopRecording];
    //    [backMovieFileOutput stopRecording];
    [self->_recordButton setEnabled:YES];
    doneRecording = YES;
    isRecording = NO;
    [self setupButton];
    UIBackgroundTaskIdentifier currBackgroundRecordingID = backgroundRecordingID;
    backgroundRecordingID = UIBackgroundTaskInvalid;
    if (currBackgroundRecordingID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:currBackgroundRecordingID];
    }
    if (!frontMovieFileOutput.isRecording && !backMovieFileOutput.isRecording) {
        [self stitchVideos];
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
    [frontCam addObject:frontCameraPiPConstraints];
    NSMutableArray *backCam = [[NSMutableArray alloc] init];
    [backCam addObject:backCameraPiPConstraints];
    [self.backCameraVideoPreviewLayer removeFromSuperlayer];
    [self.frontCameraVideoPreviewLayer removeFromSuperlayer];
    if (pipDevicePosition == AVCaptureDevicePositionFront) {
        [_background.layer addSublayer:self.frontCameraVideoPreviewLayer];
        self.frontCameraVideoPreviewLayer.frame = self->_background.bounds;
        [_foreground.layer addSublayer:self.backCameraVideoPreviewLayer];
        self.backCameraVideoPreviewLayer.frame = self->_foreground.bounds;
        pipDevicePosition = AVCaptureDevicePositionBack;
    } else {
        [_background.layer addSublayer:self.backCameraVideoPreviewLayer];
        self.backCameraVideoPreviewLayer.frame = self->_background.bounds;
        [_foreground.layer addSublayer:self.frontCameraVideoPreviewLayer];
        self.frontCameraVideoPreviewLayer.frame = self->_foreground.bounds;
        pipDevicePosition = AVCaptureDevicePositionFront;
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
    frontCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_foreground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_foreground attribute:NSLayoutAttributeWidth multiplier:widthHeight constant:0.0];
    backCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_background attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_background attribute:NSLayoutAttributeWidth multiplier:widthHeight constant:0.0];
    [self.view addConstraints:@[frontCameraPiPConstraints, backCameraPiPConstraints]];
    [_background setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_foreground setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_recordButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_background.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_background.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_background.trailingAnchor constraintEqualToAnchor:_foreground.trailingAnchor constant:spacing].active = YES;
    [_background.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_background.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor].active = YES;
    [_foreground.widthAnchor constraintEqualToAnchor:_background.widthAnchor multiplier:backFrontRatio].active = YES;
    [_background.bottomAnchor constraintEqualToAnchor:_foreground.bottomAnchor constant:spacing].active = YES;
    [_background.bottomAnchor constraintEqualToAnchor:_recordButton.bottomAnchor constant:spacing].active = YES;
    [_background.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [_background.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor].active = YES;
    [_foreground.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor].active = YES;
    [_foreground.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor].active = YES;
    [_foreground.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_foreground.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_foreground.bottomAnchor constraintEqualToAnchor:_recordButton.bottomAnchor constant:spacing].active = YES;
    [_recordButton.widthAnchor constraintGreaterThanOrEqualToConstant:4 * spacing].active = YES;
    [_recordButton.heightAnchor constraintEqualToConstant:1.5 * spacing].active = YES;
    [_recordButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    [self performSegueWithIdentifier:@"postSegue" sender:nil];
}

-(void)checkTime{
    SceneDelegate *sd = [[SceneDelegate alloc] init];
    if (![sd dateConverter]) {
        //        [self performSegueWithIdentifier:@"postSegue" sender:nil];
    }
}

@end
