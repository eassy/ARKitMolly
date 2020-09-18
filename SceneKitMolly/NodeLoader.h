//
//  NodeLoader.h
//  SceneKitMolly
//
//  Created by houwenjie on 2020/9/16.
//  Copyright © 2020 houwenjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NodeLoader : NSObject

+ (SCNNode *)mollyNodeRotate:(BOOL)rotate;
+ (SCNNode *)dragonNode;
+ (SCNNode *)tableNode;
+ (SCNNode *)vaseNode;
+ (SCNNode *)cupNode;

@end

NS_ASSUME_NONNULL_END
