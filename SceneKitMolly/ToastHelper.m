//
//  ToastHelper.m
//  SceneKitMolly
//
//  Created by houwenjie on 2020/9/16.
//  Copyright © 2020 houwenjie. All rights reserved.
//

#import "ToastHelper.h"

@implementation ToastHelper

+ (void)showToast:(UIViewController *)viewController text:(NSString *)text {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:text
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [viewController presentViewController:alert animated:YES completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

@end
