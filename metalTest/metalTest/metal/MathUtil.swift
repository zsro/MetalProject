//
//  MathUtil.swift
//  metalTest
//
//  Created by 加冰 on 2018/8/28.
//  Copyright © 2018年 加冰. All rights reserved.
//
import Foundation

struct Uniforms {
    var modelViewProjectionMatrix: matrix_float4x4
    var modelViewMatrix:matrix_float4x4
    var normalMatrix:matrix_float3x3
}

func matrix_float4x4_translation(t:simd_float3) -> matrix_float4x4
{
    let X:simd_float4 = [1, 0, 0, 0]
    let Y:simd_float4 = [0, 1, 0, 0]
    let Z:simd_float4 = [0, 0, 1, 0]
    let W:simd_float4 = [t.x, t.y, t.z, 1]
    
    let mat:matrix_float4x4 = matrix_float4x4.init([X,Y,Z,W])
    return mat;
}

func matrix_float4x4_uniform_scale(scale:float3) -> matrix_float4x4
{
    let X:simd_float4 = [scale.x, 0, 0, 0]
    let Y:simd_float4 = [0, scale.y, 0, 0]
    let Z:simd_float4 = [0, 0, scale.z, 0]
    let W:simd_float4 = [0, 0, 0, 1]
    
    let mat:matrix_float4x4 = matrix_float4x4.init([X,Y,Z,W])
    return mat;
}

func matrix_float4x4_rotation(axis:simd_float3, angle:Float) ->matrix_float4x4
{
    let c = cos(angle);
    let s = sin(angle);
    
    var X:simd_float4 = simd_float4.init();
    X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c;
    X.y = axis.x * axis.y * (1 - c) - axis.z * s;
    X.z = axis.x * axis.z * (1 - c) + axis.y * s;
    X.w = 0.0;
    
    var Y:simd_float4 = simd_float4.init();
    Y.x = axis.x * axis.y * (1 - c) + axis.z * s;
    Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c;
    Y.z = axis.y * axis.z * (1 - c) - axis.x * s;
    Y.w = 0.0;
    
    var Z:simd_float4 = simd_float4.init();
    Z.x = axis.x * axis.z * (1 - c) - axis.y * s;
    Z.y = axis.y * axis.z * (1 - c) + axis.x * s;
    Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c;
    Z.w = 0.0;
    
    var W:simd_float4 = simd_float4.init();
    W.x = 0.0;
    W.y = 0.0;
    W.z = 0.0;
    W.w = 1.0;
    
    let mat:matrix_float4x4 = matrix_float4x4.init([X,Y,Z,W])
    return mat;
}

func matrix_float4x4_perspective(_ aspect:Float,_ fovy:Float,_ near:Float,_ far:Float) -> matrix_float4x4
{
    let yScale = 1 / tan(fovy * 0.5);
    let xScale = yScale / aspect;
    let zRange = far - near;
    let zScale = -(far + near) / zRange;
    let wzScale = -2 * far * near / zRange;
    
    let P:simd_float4 = [ xScale, 0, 0, 0 ]
    let Q:simd_float4 = [ 0, yScale, 0, 0 ]
    let R:simd_float4 = [ 0, 0, zScale, -1 ]
    let S:simd_float4 = [ 0, 0, wzScale, 0 ]
    
    let mat:matrix_float4x4 = matrix_float4x4.init([P,Q,R,S])
    return mat;
}


func matrix_float4x4_extract_linear(m:matrix_float4x4) ->matrix_float3x3
{
    let X:simd_float3 = m.columns.0.xyz;
    let Y:simd_float3 = m.columns.1.xyz;
    let Z:simd_float3 = m.columns.2.xyz;
    let l:matrix_float3x3 = matrix_float3x3.init([X,Y,Z])
    return l;
}

extension simd_float4{
    
    var xyz: simd_float3{
        get{
            return [x,y,z]
        }
    }
    
    var xz:simd_float2{
        get{
            return[x,z]
        }
    }
    
    var xy:simd_float2{
        get{
            return[x,y]
        }
    }
    
    var yz:simd_float2{
        get{
            return[y,z]
        }
    }
}




