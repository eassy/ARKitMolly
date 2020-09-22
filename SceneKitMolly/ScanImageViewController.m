//
//  ScanImageViewController.m
//  SceneKitMolly
//
//  Created by houwenjie on 2020/9/16.
//  Copyright © 2020 houwenjie. All rights reserved.
//

#import "ScanImageViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
#import <SDWebImage/SDWebImage.h>

#import "ToastHelper.h"
#import "NodeLoader.h"

@interface ScanImageViewController ()<ARSCNViewDelegate>

/// 承载相机的 view
@property (nonatomic, strong) ARSCNView *sceneView;
/// 删除按钮
@property (nonatomic, strong) UIButton *removeButton;
/// 选中的 Node
@property (nonatomic, strong) SCNNode *currentTouchedNode;
/// 监测到的图片 node
@property (nonatomic, strong) SCNNode *dectectedImageNode;
/// 添加的平面
@property (nonatomic, strong) SCNNode *planeNode;

@end

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation ScanImageViewController


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
//    [self setGesture];
    
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
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1600334692191&di=3f1144aa4f5d3e4ed0e8fc6a61a93b40&imgtype=0&src=http%3A%2F%2Ftimable.com%2Fres%2Fpic%2Fd5d6a8de529917d95e8fc356a21933372.jpg"] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (image) {
            
            ARImageTrackingConfiguration *imageConfiguration = [[ARImageTrackingConfiguration alloc] init];
//            imageConfiguration.trackingImages = [ARReferenceImage referenceImagesInGroupNamed:@"AR Resources" bundle:nil];
            imageConfiguration.trackingImages = [NSSet setWithObject:[[ARReferenceImage alloc] initWithCGImage:image.CGImage orientation:kCGImagePropertyOrientationUp physicalWidth:0.12]];
            
            
            // 初始化 configuration,用于检测横向平面,支持自动对焦
            ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
            if (@available(iOS 11.3, *)) {
                configuration.autoFocusEnabled = YES;
//                configuration.detectionImages = [NSSet setWithObject:[[ARReferenceImage alloc] initWithCGImage:image.CGImage orientation:kCGImagePropertyOrientationUp physicalWidth:0.12]];
                configuration.detectionImages = [ARReferenceImage referenceImagesInGroupNamed:@"AR Resources" bundle:nil];
            }
            if (@available(iOS 13.0, *)) {
//                configuration.automaticImageScaleEstimationEnabled = YES;
            }
            
            self.sceneView.delegate = self;
            // 开始 track 模式
            [self.sceneView.session runWithConfiguration:configuration options:ARSessionRunOptionResetTracking];
        }
    }];

    
}


- (void)setGesture {
    // 点击 添加 或者 删除 模型。
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddObjectFrom:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.sceneView addGestureRecognizer:tapGestureRecognizer];
}


- (void)addObjectToScene:(UITapGestureRecognizer *)recognizer {
    CGPoint holdPoint = [recognizer locationInView:self.sceneView];
    SCNNode *node = [NodeLoader mollyNodeRotate:NO];
    NSArray<ARHitTestResult *> *resultArray = [self.sceneView hitTest:holdPoint types:
                                               
                                               ARHitTestResultTypeEstimatedHorizontalPlane
                                               ];//在已经检测到的平面区域查找点
    if (resultArray.count == 0) {
        return;
    }
    ARHitTestResult *hitResult = [resultArray firstObject];
//    node.position = SCNVector3Make(
//        hitResult.worldTransform.columns[3].x,
//        hitResult.worldTransform.columns[3].y,
//        hitResult.worldTransform.columns[3].z
//    );
    node.eulerAngles = SCNVector3Make(-M_PI / 2.f , 0, 0);
    [self.dectectedImageNode addChildNode:node];
}


- (void)removeNode:(SCNNode *)node {
    __block BOOL hasContain = NO;
    [self.dectectedImageNode childNodesPassingTest:^BOOL(SCNNode * _Nonnull child, BOOL * _Nonnull stop) {
        if (child == node) {
            *stop = YES;
            hasContain = YES;
            return YES;
        }
        return YES;
    }];
    if (hasContain) {
        NSArray <SCNNode *>*childArray = self.dectectedImageNode.childNodes;
        [childArray enumerateObjectsUsingBlock:^(SCNNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromParentNode];
        }];
        
    }
    
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

#pragma mark - customDelegates

#pragma mark - systemDelegates

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
    self.dectectedImageNode = node;
    [ToastHelper showToast:self text:@"已检测到图片,放置模型"];
    if (@available(iOS 11.3, *)) {
        if ([anchor isKindOfClass:[ARImageAnchor class]]) {
            ARImageAnchor *imageAnchor = (ARImageAnchor *)anchor;
            if ([imageAnchor.referenceImage.name isEqualToString:@"Molly"]) {
                // molly 放置模型
                SCNNode *mollyNode = [NodeLoader mollyNodeRotate:NO];
    //            mollyNode.position = SCNVector3Make(0, -0.4, -0.2);
                [mollyNode runAction:[SCNAction rotateByAngle:-M_PI / 2.f aroundAxis:SCNVector3Make(1, 0, 0) duration:0.5]];

                [node addChildNode:mollyNode];
            } else if([imageAnchor.referenceImage.name isEqualToString:@"Labubu"]){
                // labubu 播放视频
                CGFloat scale = 960.f / 544.f; // 视频宽高比
                SCNPlane *plane = [SCNPlane planeWithWidth:imageAnchor.referenceImage.physicalSize.height * scale * 1.5 height:imageAnchor.referenceImage.physicalSize.height * 1.5];
                
                NSString * urlStr = [[NSBundle mainBundle] pathForResource:@"labubu.mp4" ofType:nil];
                
                NSURL *url = [NSURL fileURLWithPath:urlStr];
                
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                
                SCNMaterial * material = [[SCNMaterial alloc]init];
                
                material.diffuse.contents = player;
                
                plane.materials = @[material];
                
                [player play];
                
                SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
                self.planeNode = planeNode;
//                planeNode.eulerAngles = SCNVector3Make(-M_PI / 2.f, 0, 0);
                planeNode.position = SCNVector3Make(anchor.transform.columns[3].x, anchor.transform.columns[3].y, anchor.transform.columns[3].z);
                
                
                
                [self.sceneView.scene.rootNode addChildNode:planeNode];
            }
        }
    } 
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    self.planeNode.position = SCNVector3Make(anchor.transform.columns[3].x, anchor.transform.columns[3].y, anchor.transform.columns[3].z);
}


#pragma mark - getters and setters


@end
