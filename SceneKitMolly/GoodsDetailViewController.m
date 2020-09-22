//
//  GoodsDetailViewController.m
//  SceneKitMolly
//
//  Created by houwenjie on 2020/9/14.
//  Copyright © 2020 houwenjie. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import <SceneKit/SceneKit.h>
#import "AFNetworking.h"
#import "SSZipArchive.h"
#import "ToastHelper.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface GoodsDetailViewController ()<SSZipArchiveDelegate>

/// sceneView
@property (nonatomic, strong) SCNView *scnView;
/// 下载按钮
@property (nonatomic, strong) UIButton *downloadBtn;
@property(nonatomic, copy) NSString *zipModelFolderPath;
@property(nonatomic, copy) NSString *zipFileName;
@property(nonatomic, copy) NSString *unzipModelFolderPath;
/// 进度条
@property (nonatomic, strong) UIProgressView *downloadProgress;

@end

@implementation GoodsDetailViewController

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
    [self setUI];
    [self configErrorView];
    self.zipFileName = @"movie.dae";
    [self setTitle:@"下载并展示"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.view addSubview:self.scnView];
    [self.view addSubview:self.downloadBtn];
    [self.view addSubview:self.downloadProgress];
}

- (void)setConstraints {
    
}

- (void)setNav {
    
}

- (void)configErrorView {
    
}


- (void)startScene {
    NSFileManager *manager = [NSFileManager new];
    NSArray *directoryContents = [manager contentsOfDirectoryAtPath:self.unzipModelFolderPath error:NULL];
    SCNScene *scene = [SCNScene sceneWithURL:[NSURL fileURLWithPath:[self.unzipModelFolderPath stringByAppendingPathComponent:self.zipFileName]]
    options:nil
      error:nil];
    
    
    
    self.scnView.scene = [SCNScene scene];
    
    SCNNode *rootNode = self.scnView.scene.rootNode;
    
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    SCNCamera *camera = [SCNCamera camera];
//    camera.automaticallyAdjustsZRange = YES;
    cameraNode.camera = camera;
//    [rootNode addChildNode:cameraNode];
//        [scene.rootNode addChildNode:cameraNode];
//
//        // place the camera
//        cameraNode.position = SCNVector3Make(0, 20, 50);
//        cameraNode.position = SCNVector3Make(0, 200, 400);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    
    lightNode.position = SCNVector3Make(0, 20, 40);
    [rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor lightGrayColor];
    ambientLightNode.light.castsShadow = NO;
    [rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    SCNNode *ship = [scene.rootNode childNodeWithName:@"3D电影" recursively:YES];
    
    ship.position = SCNVector3Make(0, 0, -10);
    [rootNode addChildNode:ship];

    // animate the 3d object
    [ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:2.5]]];
//    [ship runAction:[SCNAction scaleBy:0.2 duration:0.1]];
    
}


#pragma mark - handler Data

- (void)downloadResource {
    self.downloadBtn.enabled = NO;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    //这里我们用本地链接替代一下，可以使用任意url链接
    NSURL *URL = [NSURL URLWithString:@"http://172.17.2.88/movie.zip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadProgress.progress = (float_t)downloadProgress.completedUnitCount / (float_t)downloadProgress.totalUnitCount;
        });
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSURL *unzipModelFilePathURL = [NSURL fileURLWithPath:self.zipModelFolderPath];
//        [[NSFileManager defaultManager] removeItemAtPath:[unzipModelFilePathURL URLByAppendingPathComponent:self.zipFileName].absoluteString error:nil];
        return [unzipModelFilePathURL URLByAppendingPathComponent:self.zipFileName];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        if (!error) {
            self.downloadProgress.hidden = YES;
            BOOL unzip = [SSZipArchive unzipFileAtPath:[self.zipModelFolderPath stringByAppendingPathComponent:self.zipFileName]
                                         toDestination:self.unzipModelFolderPath delegate:self];
            
            if(!unzip){
                NSLog(@"解压失败");
            }else {
                NSLog(@"解压成功");
                [self startScene];
            }
        } else {
            [self.downloadBtn setTitle:@"下载失败，请重试" forState:UIControlStateNormal];
            self.downloadBtn.enabled = YES;
            [ToastHelper showToast:self text:@"需要连接 POPMART 无线网，并且在 eassy 电脑上开启服务器"];
        }
        
        
    }];
    [downloadTask resume];
}

- (NSString *)zipModelFolderPath {
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"zipModelFolder"];//zipModelFolder
    BOOL isDirExist = [NSFileManager.defaultManager fileExistsAtPath:folderPath];
    if (!isDirExist) {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"%s: zipFileFolderPath create error:%@",  __FUNCTION__, error);
        }else
        {
            _zipModelFolderPath = folderPath;
        }
        
    }else {
        _zipModelFolderPath = folderPath;
    }
    
    return _zipModelFolderPath;
}

- (NSString *)unzipModelFolderPath {
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"unzipModelFolder"];//unzipModelFolder
    BOOL isDirExist = [NSFileManager.defaultManager fileExistsAtPath:folderPath];
    if (!isDirExist) {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"%s: unzipFileFolder create error:%@",  __FUNCTION__, error);
        }else
        {
            _unzipModelFolderPath = folderPath;
        }
        
    }else {
        _unzipModelFolderPath = folderPath;
    }
    
    return _unzipModelFolderPath;
}


#pragma mark - event handlers

#pragma mark - customDelegates

#pragma mark - systemDelegates

#pragma mark - getters and setters


- (SCNView *)scnView {
    if (!_scnView) {
        _scnView = [[SCNView alloc] initWithFrame:CGRectMake(0, 100, 375, 400)];
        
        
        // retrieve the SCNView
        SCNView *scnView = _scnView;
        
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = YES;
            
        // show statistics such as fps and timing information
        scnView.showsStatistics = YES;

        // configure the view
        scnView.backgroundColor = [UIColor whiteColor];
        
        
    }
    return _scnView;
}

- (UIButton *)downloadBtn {
    if (!_downloadBtn) {
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadBtn setFrame:CGRectMake((kScreenWidth - 200) / 2.f, kScreenHeight - 50 - 80, 200, 50)];
        [_downloadBtn setTitle:@"点击下载文件" forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_downloadBtn addTarget:self action:@selector(downloadResource) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadBtn;
}

- (UIProgressView *)downloadProgress {
    if (!_downloadProgress) {
        _downloadProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, 3)];
        _downloadProgress.progressTintColor = [UIColor orangeColor];
        _downloadProgress.trackTintColor = [UIColor lightGrayColor];
    }
    return _downloadProgress;
}

@end
