//
//  ScanViewController.m
//  SceneKitMolly
//
//  Created by houwenjie on 2020/9/15.
//  Copyright © 2020 houwenjie. All rights reserved.
//

#import "ScanSurfaceViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

#import "ToastHelper.h"
#import "NodeLoader.h"

@interface ScanSurfaceViewController ()<ARSCNViewDelegate>

/// 承载相机的 view
@property (nonatomic, strong) ARSCNView *sceneView;
/// 删除按钮
@property (nonatomic, strong) UIButton *removeButton;
/// 选中的 Node
@property (nonatomic, strong) SCNNode *currentTouchedNode;

@property (nonatomic, strong) ARHitTestResult *initialHitTestResult;

@property (nonatomic, strong) SCNNode *movedObject;

/// 放置平面 node
@property (nonatomic, strong) SCNNode *surfaceNode;

@end

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation ScanSurfaceViewController

#pragma mark - life cycle


- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setScene];
    [self setUI];
    [self configErrorView];
    [self setGesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - public methods


#pragma mark - private methods

- (void)setUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNav];
    [self addSubViews];
    [self setConstraints];
}

- (void)addSubViews {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nav_back_white"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(5, 88, 44, 44)];
    [backButton addTarget:self action:@selector(backHandler) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backButton];
    
    self.removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removeButton setImage:[[UIImage imageNamed:@"delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.removeButton setFrame:CGRectMake((kScreenWidth - 44)/2.f, kScreenHeight - 100, 44, 44)];
    self.removeButton.hidden = YES;
    [self.removeButton addTarget:self action:@selector(removeNodeHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.removeButton];
}

- (void)setConstraints {
    
}

- (void)setNav {
    
}

- (void)configErrorView {
    
}


- (void)setScene {
    
    self.sceneView = [[ARSCNView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.sceneView];
    self.sceneView.autoenablesDefaultLighting = YES;
    self.sceneView.automaticallyUpdatesLighting = YES;
    // 初始化 configuration,用于检测横向平面,支持自动对焦
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    if (@available(iOS 11.3, *)) {
        configuration.autoFocusEnabled = YES;
    } else {
        // Fallback on earlier versions
    }
    // 追踪平面
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    
    self.sceneView.delegate = self;
    // 开始 track 模式
    [self.sceneView.session runWithConfiguration:configuration options:ARSessionRunOptionResetTracking];
}


- (void)setGesture {
    // 点击 添加 或者 删除 模型。
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddObjectFrom:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.sceneView addGestureRecognizer:tapGestureRecognizer];
    
    // Pan Press Gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveObjectFrom:)];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [self.sceneView addGestureRecognizer:panGestureRecognizer];
    
    // Pinch Press Gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleScaleObjectFrom:)];
    [self.sceneView addGestureRecognizer:pinchGestureRecognizer];
}


- (void)addObjectToScene:(UITapGestureRecognizer *)recognizer {
    CGPoint holdPoint = [recognizer locationInView:self.sceneView];
    SCNNode *node = [NodeLoader mollyNodeRotate:NO];
    NSArray<ARHitTestResult *> *resultArray = [self.sceneView hitTest:holdPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];//在已经检测到的平面区域查找点
    if (resultArray.count == 0) {
        return;
    }
    ARHitTestResult *hitResult = [resultArray firstObject];
    node.position = SCNVector3Make(
        hitResult.worldTransform.columns[3].x,
        hitResult.worldTransform.columns[3].y,
        hitResult.worldTransform.columns[3].z
    );
    
    [self.sceneView.scene.rootNode addChildNode:node];
}


- (void)removeNode:(SCNNode *)node {
    [node.parentNode removeFromParentNode];
}

#pragma mark - handler Data


#pragma mark - event handlers


- (void)removeNodeHandler {
    self.removeButton.hidden = YES;
    if (self.currentTouchedNode) {
        
        [self removeNode:self.currentTouchedNode];
    }
}


- (void)backHandler {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleAddObjectFrom:(UITapGestureRecognizer *) recognizer {
    
    CGPoint holdPoint = [recognizer locationInView:self.sceneView];
    /// 检测点击位置是否有物体
    NSArray<SCNHitTestResult *> *result = [self.sceneView hitTest:holdPoint
                                                          options:@{SCNHitTestBoundingBoxOnlyKey: @YES, SCNHitTestFirstFoundOnlyKey: @YES}];
    if (result.count == 0) {
        /// 添加一个新的 node
        self.removeButton.hidden = YES;
        [self addObjectToScene:recognizer];
    } else {
        /// 删除掉
        self.removeButton.hidden = NO;
        self.currentTouchedNode = result.firstObject.node;
    }
//    if (result.count == 0) {
//        self.viewController.removeButton.hidden = YES;
//        [self insertARObject:recognizer];
//    } else {
//        self.removeHitResult = [result firstObject];
//        self.viewController.removeButton.hidden = NO;
//        [self.viewController.removeButton setImage:[[UIImage imageNamed:@"delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//        self.viewController.removeButton.tintColor = [UIColor redColor];
//    }
}


- (void)handleMoveObjectFrom:(UIPanGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tapPoint = [recognizer locationInView:self.sceneView];
        NSArray <SCNHitTestResult *> *result = [self.sceneView hitTest:tapPoint options:nil];
        NSArray <ARHitTestResult *> *hitResults = [self.sceneView hitTest:tapPoint types:ARHitTestResultTypeFeaturePoint];
        
        if ([result count] == 0) {
            return;
        }
        SCNHitTestResult *hitResult = [result firstObject];
        
        self.movedObject = [[hitResult node] parentNode];
        self.initialHitTestResult = [hitResults firstObject];
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (self.movedObject) {
            CGPoint tapPoint = [recognizer locationInView:self.sceneView];
            NSArray <ARHitTestResult *> *hitResults = [self.sceneView hitTest:tapPoint types:ARHitTestResultTypeFeaturePoint];
            ARHitTestResult *result = [hitResults lastObject];
            
            [SCNTransaction begin];
            
            SCNMatrix4 initialMatrix = SCNMatrix4FromMat4(self.initialHitTestResult.worldTransform);
            SCNVector3 initialVector = SCNVector3Make(initialMatrix.m41, initialMatrix.m42, initialMatrix.m43);
            
            SCNMatrix4 matrix = SCNMatrix4FromMat4(result.worldTransform);
            SCNVector3 vector = SCNVector3Make(matrix.m41, matrix.m42, matrix.m43);
            
            CGFloat dx= vector.x - initialVector.x;
            CGFloat dy= vector.y - initialVector.y;
            CGFloat dz= vector.z - initialVector.z;
            
            SCNVector3 newPositionVector = SCNVector3Make(self.movedObject.position.x+dx, self.movedObject.position.y+dy, self.movedObject.position.z+dz);
            
            [self.movedObject setPosition:newPositionVector];
            
            [SCNTransaction commit];
            
            self.initialHitTestResult = result;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.movedObject = nil;
        self.initialHitTestResult = nil;
    }
}

- (void)handleScaleObjectFrom:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tapPoint = [recognizer locationOfTouch:1 inView:self.sceneView];
        NSArray <SCNHitTestResult *> *result = [self.sceneView hitTest:tapPoint options:nil];
        if ([result count] == 0) {
            tapPoint = [recognizer locationOfTouch:0 inView:self.sceneView];
            result = [self.sceneView hitTest:tapPoint options:nil];
            if ([result count] == 0) {
                return;
            }
        }
        
        SCNHitTestResult *hitResult = [result firstObject];
        self.movedObject = [[hitResult node] parentNode];
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (self.movedObject) {
            CGFloat pinchScaleX = recognizer.scale * self.movedObject.scale.x;
            CGFloat pinchScaleY = recognizer.scale * self.movedObject.scale.y;
            CGFloat pinchScaleZ = recognizer.scale * self.movedObject.scale.z;
            [self.movedObject setScale:SCNVector3Make(pinchScaleX, pinchScaleY, pinchScaleZ)];
        }
        recognizer.scale = 1;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.movedObject = nil;
    }
}


#pragma mark - customDelegates

#pragma mark - systemDelegates

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    [ToastHelper showToast:self text:@"已检测到表面,点击放置模型"];
//    if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
//        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
//        CGFloat width = planeAnchor.extent.x;
//        CGFloat height = planeAnchor.extent.z;
//
//        SCNPlane *plane = [SCNPlane planeWithWidth:width height:height];
//        plane.materials.firstObject.diffuse.contents = [UIColor lightGrayColor];
//        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
//
//        CGFloat x = planeAnchor.center.x;
//        CGFloat y = planeAnchor.center.y;
//        CGFloat z = planeAnchor.center.z;
//
//        planeNode.position = SCNVector3Make(x, y, z);
//        planeNode.eulerAngles = SCNVector3Make(-M_PI / 2.f, 0, 0);
//        [node addChildNode:planeNode];
//        self.surfaceNode = planeNode;
//    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (self.surfaceNode) {
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        CGFloat width = planeAnchor.extent.x;
        CGFloat height = planeAnchor.extent.z;
        CGFloat x = planeAnchor.center.x;
        CGFloat y = planeAnchor.center.y;
        CGFloat z = planeAnchor.center.z;
        
        SCNPlane *plane = (SCNPlane *)self.surfaceNode.geometry;
        plane.width = width;
        plane.height = height;
        
        self.surfaceNode.position = SCNVector3Make(x, y, z);
        
    }
}

#pragma mark - getters and setters



@end
