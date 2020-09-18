//
//  ToastHelper.h
//  SceneKitMolly
//
//  Created by houwenjie on 2020/9/16.
//  Copyright © 2020 houwenjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastHelper : NSObject

+ (void)showToast:(UIViewController *)viewController text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
