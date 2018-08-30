//
//  ObjLoaderBridge.h
//  Mirage3D
//
//  Created by 影子.zsr on 2018/5/28.
//  Copyright © 2018年 影子. All rights reserved.
//

#ifndef ObjLoaderBridge_h
#define ObjLoaderBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>


typedef struct __attribute((packed)){
    simd_float4 position;
    simd_float4 normal;
    simd_float2 texcoord;
}MIVertex;

typedef struct{
    float x, y, z;    // position
    float nx, ny, nz; // normal
    float s, t;       // texture coordinates
} MyVertex;

@interface ObjLoaderBridge :NSObject

@property (strong) NSMutableArray *data_v;
@property (strong) NSMutableArray *data_vn;
@property (strong) NSMutableArray *data_vt;
@property (strong) NSMutableArray *data_face;

-(void)load:(NSString *)path;

@end
#endif /* ObjLoaderBridge_h */
