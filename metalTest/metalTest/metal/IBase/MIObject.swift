//
//  MIObject.swift
//  metalTest
//
//  Created by 影子 on 2018/8/30.
//  Copyright © 2018年 加冰. All rights reserved.
//

import Foundation
import MetalKit

class MIObject: NSObject,MIMetalDelegate {


    var rps: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    var diffuseTexture:MTLTexture!
    var samplerState:MTLSamplerState!
    
    override init() {
        super.init()
    }
    
    func initialize(device: MTLDevice, library: MTLLibrary) {
        createBuffers(device: device)
        registerShaders(device: device, library: library)
        setTexture(device: device, texture: #imageLiteral(resourceName: "bg"))
        createSamplerState(device:device)
    }
    
    
    func setTexture(device:MTLDevice,texture:UIImage) -> Void {
        let loader = MTKTextureLoader.init(device: device)
        do{
            self.diffuseTexture = try loader.newTexture(cgImage: texture.cgImage!, options: nil)
        }catch{
            print("error: metal texture load failed !!!")
        }
    }
    
    func createSamplerState(device:MTLDevice) -> Void {
        let samplerDesc = MTLSamplerDescriptor.init()
        samplerDesc.sAddressMode = .clampToEdge
        samplerDesc.tAddressMode = .clampToEdge
        samplerDesc.minFilter = .nearest
        samplerDesc.magFilter = .linear
        samplerDesc.mipFilter = .linear
        self.samplerState = device.makeSamplerState(descriptor: samplerDesc)
    }
    
    struct Vertex {
        var position: simd_float4
        var color: simd_float4
    }
    
    struct Matrix {
        var m: [Float]
        init() {
            m = [1, 0, 0, 0,
                 0, 1, 0, 0,
                 0, 0, 1, 0,
                 0, 0, 0, 1
            ]
        }
        
    }
    
    func createBuffers(device:MTLDevice) {
        let vertex_data = [Vertex(position: [-1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
                           Vertex(position: [ 1.0, -1.0, 0.0, 1.0], color: [1, 1, 0, 1]),
                           Vertex(position: [-1.0,  1.0, 0.0, 1.0], color: [0, 0, 1, 1]),
                           Vertex(position: [ 1.0,  1.0, 0.0, 1.0], color: [1, 0, 0, 1])
        ]
        vertexBuffer = device.makeBuffer(bytes: vertex_data, length: MemoryLayout<Vertex>.size * 4, options:[])
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, Matrix().m, MemoryLayout<Float>.size * 16)
    }
    
    func registerShaders(device:MTLDevice,library:MTLLibrary) {
        let vertex_func = library.makeFunction(name: "vertex_background")
        let frag_func = library.makeFunction(name: "fragment_background")
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = frag_func
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        rpld.depthAttachmentPixelFormat = .depth32Float
        do {
            try rps = device.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            print("\(error)")
        }
        
        
    }
    
    
    func render(commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setRenderPipelineState(rps!)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentTexture(diffuseTexture, index: 0)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
    }
    
    
    
}


protocol MIMetalDelegate {
    
    func initialize(device:MTLDevice,library:MTLLibrary) -> Void
    
    func render(commandEncoder:MTLRenderCommandEncoder) -> Void
    
}
