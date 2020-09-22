//
//  RootTableViewController.m
//  SceneKitMolly
//
//  Created by houwenjie on 2020/9/15.
//  Copyright © 2020 houwenjie. All rights reserved.
//

#import "RootTableViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "GoodsDetailViewController.h"
#import "ScanSurfaceViewController.h"
#import "ScanImageViewController.h"
#import "ScanObjectViewController.h"

@interface RootTableViewController ()

/// class Array
@property (nonatomic, strong) NSArray *classArray;
/// titleArray
@property (nonatomic, strong) NSArray <NSString *>*titleArray;

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:@"选择场景"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"itemArray"];
    
    
    self.classArray = @[[GoodsDetailViewController class],[ScanSurfaceViewController class],[ScanImageViewController class]];
    self.titleArray = @[@"下载模型并展示",@"检测平面，放置模型",@"检测图片，放置模型"];
}


/// 检测是否支持 AR
- (void)checkSystemVersion:(void(^)(BOOL valid))block {
    if (__builtin_available(iOS 11, *)) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
        completionHandler:^(BOOL granted) {
            if (block) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(granted);
                });
            }
        }];
    } else {
        block(NO);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemArray" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemArray"];
    }
    cell.textLabel.text = self.titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self checkSystemVersion:^(BOOL valid) {
        Class class = self.classArray[indexPath.row];
        UIViewController *vc = [[class alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
