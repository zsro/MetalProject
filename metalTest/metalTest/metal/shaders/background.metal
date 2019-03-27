//
//  Shaders.metal
//  chapter05
//
//  Created by Marius on 2/3/16.
//  Copyright © 2016 Marius Horga. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex_b {
    float4 position [[position]];
    float4 color;
};

struct Uniforms_background {
    float4x4 modelMatrix;
};

vertex Vertex_b vertex_background(constant Vertex_b *vertices [[buffer(0)]],
                          constant Uniforms_background &uniforms [[buffer(1)]],
                          uint vid [[vertex_id]]) {
    float4x4 matrix = uniforms.modelMatrix;
    Vertex_b in = vertices[vid];
    Vertex_b out;
    out.position = matrix * float4(in.position);
    out.color = in.color;
    return out;
}

fragment float4 fragment_background(Vertex_b vert [[stage_in]],
                                    texture2d<float> diffuseTexture [[texture(0)]],
                                    sampler samplr [[sampler(0)]]) {
    float4 c = diffuseTexture.sample(samplr, vert.color.xy);
    return float4(c.x,c.y,c.z,0);
}
