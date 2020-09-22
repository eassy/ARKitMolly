//
//  NodeLoader.m
//  SceneKitMolly
//
//  Created by houwenjie on 2020/9/16.
//  Copyright © 2020 houwenjie. All rights reserved.
//

#import "NodeLoader.h"

@implementation NodeLoader

+ (SCNNode *)mollyNodeRotate:(BOOL)rotate {
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/movie.dae"];
    SCNNode *movieNode = [scene.rootNode clone];
    
    SCNNode *lightNode = [SCNNode node];
    SCNLight *light = [SCNLight light];
    light.type = SCNLightTypeOmni;
    light.color = [UIColor lightGrayColor];
    lightNode.light = light;
    lightNode.position = SCNVector3Make(0, 100, 50);
    
    [movieNode addChildNode:lightNode];
    
    [movieNode runAction:[SCNAction scaleTo:0.005 duration:0.1]];
    if (rotate) {
        [movieNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:1 z:0 duration:2.5]]];
    }
    return movieNode;
}



+ (SCNNode *)dragonNode {
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/Dragon/Dragon_2.5_dae.dae"];
    SCNNode *node = [scene.rootNode clone];
    [node runAction:[SCNAction scaleTo:0.01 duration:0.1]];
    return node;
}
//+ (SCNNode *)tableNode;
+ (SCNNode *)vaseNode {
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/vase.dae"];
    SCNNode *movieNode = [scene.rootNode clone];
    return movieNode;
}

+ (SCNNode *)cupNode {
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/cup.dae"];
    SCNNode *node = [scene.rootNode clone];
    return node;
}

+ (SCNNode *)flowerNode {
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/flower.dae"];
    SCNNode *node = [[scene.rootNode clone] childNodeWithName:@"_3dxy" recursively:YES];
    [node runAction:[SCNAction scaleTo:0.001 duration:0.1]];

    return node;
}

+ (SCNNode *)normalNodeWithName:(NSString *)name {
    SCNScene *scene = [SCNScene sceneNamed:[NSString stringWithFormat:@"art.scnassets/%@",name]];
    SCNNode *node = [[scene.rootNode clone] childNodeWithName:@"_3dxy" recursively:YES];
    [node runAction:[SCNAction scaleTo:0.001 duration:0.1]];

    return node;
}

@end
