//
//  ImageAnchorViewController.m.m
//  ImageToVideo
//
//  Created by hetao on 2018/6/28.
//  Copyright © 2018 hetao. All rights reserved.
//

#import "ImageAnchorViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface ImageAnchorViewController () <ARSessionDelegate, ARSCNViewDelegate>

@property(nonatomic, weak) IBOutlet UIView *sessionInfoView;
@property(nonatomic, weak) IBOutlet UILabel *sessionInfoLabel;
@property(nonatomic, weak) IBOutlet ARSCNView *sceneView;

@end

@implementation ImageAnchorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    self.sceneView.showsStatistics = YES;

    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [self resetTracking];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - ARSCNViewDelegate
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    if ([anchor isKindOfClass:[ARImageAnchor class]]) {
        NSLog(@"didAddNode");
        ARImageAnchor *imageAnchor = (ARImageAnchor *)anchor;
        float width = imageAnchor.referenceImage.physicalSize.width;
        float height = width * 9 / 16;
        SCNPlane *plane = [SCNPlane planeWithWidth:width
                                            height:height];
        
        //添加视频node
        plane.firstMaterial = [self videoMaterial];
        
        //
        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
//        planeNode.opacity = 0.95;
        [planeNode setEulerAngles:SCNVector3Make(- 3.14159265 / 2, planeNode.eulerAngles.y, planeNode.eulerAngles.z)];
        
        [node addChildNode:planeNode];
    }
}

- (SCNMaterial *)videoMaterial
{
    NSString *urlString = [[NSBundle mainBundle] pathForResource:@"helijiaAD" ofType:@"mp4"];
    NSURL *fileUrl = [NSURL fileURLWithPath:urlString];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:fileUrl];
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
    
    SKVideoNode *videoNode = [[SKVideoNode alloc] initWithAVPlayer:player];
    CGSize size = CGSizeMake(1600, 900);
    videoNode.size = size;
    videoNode.position = CGPointMake(size.width * 0.5, size.height * 0.5);
    videoNode.yScale = -1;
    SKScene *vedioScene = [[SKScene alloc] initWithSize:size];
    [vedioScene addChild:videoNode];
    
    SCNMaterial *material = [[SCNMaterial alloc] init];
    material.diffuse.contents = vedioScene;
    
    [player play];

    return material;
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    if ([anchor isKindOfClass:[ARImageAnchor class]]) {
        NSLog(@"didUpdateNode");
        ARImageAnchor *imageAnchor = (ARImageAnchor *)anchor;
        SCNNode *planeNode = node.childNodes.firstObject;
        SCNPlane *plane = (SCNPlane *)planeNode.geometry;
        
        float width = imageAnchor.referenceImage.physicalSize.width;
        float height = width * 9 / 16;
        plane.width = width;
        plane.height = height;
    }
}

// MARK: - ARSession Delegate & Observer
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors
{
    ARFrame *frame = session.currentFrame;
    [self updateSessionInfoLabel:frame state:frame.camera.trackingState];
}

- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors
{
    ARFrame *frame = session.currentFrame;
    [self updateSessionInfoLabel:frame state:frame.camera.trackingState];
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera
{
    ARFrame *frame = session.currentFrame;
    [self updateSessionInfoLabel:frame state:camera.trackingState];
}

- (void)sessionWasInterrupted:(ARSession *)session
{
    self.sessionInfoLabel.text = @"Session was interrupted";
}

- (void)sessionInterruptionEnded:(ARSession *)session
{
    self.sessionInfoLabel.text = @"Session interruption ended";
    [self resetTracking];
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error
{
    self.sessionInfoLabel.text = @"Session failed: \(error.localizedDescription)";
    [self resetTracking];
}

// MARK: - Private
- (void)updateSessionInfoLabel:(ARFrame *)frame state:(ARTrackingState)trackingState
{
    // Update the UI to provide feedback on the state of the AR experience.
    NSString *message;
    
    
    switch (trackingState) {
        case ARTrackingStateNormal:
            // No planes detected; provide instructions for this app's AR interactions.
            message = @"Move the device around to detect horizontal surfaces.";
            break;
        case ARTrackingStateNotAvailable:
            message = @"Tracking unavailable.";
            break;
        case ARTrackingStateLimited:
            message = @"ARTrackingStateLimited See trackingStateReason AR session.";
            break;
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = @"";
            break;
    }
    
    self.sessionInfoLabel.text = message;
}

- (void)resetTracking
{
    // Boundle Image
    UIImage *image = [UIImage imageNamed:@"imac-21"];
    CGImageRef cgImage = image.CGImage;
    ARReferenceImage *arImage = [[ARReferenceImage alloc] initWithCGImage:cgImage orientation:kCGImagePropertyOrientationUp physicalWidth:0.2];
    NSSet<ARReferenceImage *> *referenceIamges = [NSSet setWithObject:arImage];
    
    // AR_Resources Image
//    NSSet<ARReferenceImage *> *referenceIamges = [ARReferenceImage referenceImagesInGroupNamed:@"AR_Resources" bundle:nil];
    
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    configuration.detectionImages = referenceIamges;
    [self.sceneView.session runWithConfiguration:configuration
                                         options:(ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors)];
}

@end
