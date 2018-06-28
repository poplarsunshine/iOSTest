//
//  ViewController.m
//  ImageToVideo
//
//  Created by hetao on 2018/6/28.
//  Copyright © 2018 hetao. All rights reserved.
//

#import "ViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface ViewController () <ARSessionDelegate, ARSCNViewDelegate>

@property(nonatomic, weak) IBOutlet UIView *sessionInfoView;
@property(nonatomic, weak) IBOutlet UILabel *sessionInfoLabel;
@property(nonatomic, weak) IBOutlet ARSCNView *sceneView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.sceneView.delegate = self;
    
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    configuration.planeDetection = ARPlaneDetectionHorizontal | ARPlaneDetectionVertical;
    [self.sceneView.session runWithConfiguration:configuration];
    
    self.sceneView.session.delegate = self;
    self.sceneView.showsStatistics = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
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
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
        NSLog(@"didAddNode");
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        SCNPlane *plane = [SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.y];
        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
        planeNode.simdPosition = simd_make_float3(planeAnchor.center.x, 0, planeAnchor.center.z);
        planeNode.opacity = 0.25;
        [planeNode setEulerAngles:SCNVector3Make(- 3.1416 / 2, planeNode.eulerAngles.y, planeNode.eulerAngles.z)];
        
        [node addChildNode:planeNode];
    }
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
        NSLog(@"didUpdateNode");
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        SCNNode *planeNode = node.childNodes.firstObject;
        SCNPlane *plane = (SCNPlane *)planeNode.geometry;

        planeNode.simdPosition = simd_make_float3(planeAnchor.center.x, 0, planeAnchor.center.z);
        
        plane.width = (CGFloat)planeAnchor.extent.x;
        plane.height = (CGFloat)planeAnchor.extent.z;
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
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    [self.sceneView.session runWithConfiguration:configuration options:(ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors)];
}

@end
