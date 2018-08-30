//
//  MIMetalRender.swift
//  metalTest
//
//  Created by 加冰 on 2018/8/28.
//  Copyright © 2018年 加冰. All rights reserved.
//

import Foundation
import MetalKit

let MBEInFlightBufferCount:Int = 3

class MIVertexBuffer {
    var vertexBuffer:MTLBuffer!
    var indexBuffer:MTLBuffer!
}

class MIMetalRender : NSObject {
    
    var device:MTLDevice!
    var uniformBuffer:MTLBuffer!
    var commandQueue:MTLCommandQueue!
    
    var renderPipelineState:MTLRenderPipelineState!
    var depthStencilState:MTLDepthStencilState!
    var samplerState:MTLSamplerState!
    
    var displaySemaphore:DispatchSemaphore!
    var bufferIndex:Int = 0
    
    var depthTexture:MTLTexture!
    var bgTexture:MTLTexture!
    var diffuseTexture:MTLTexture!
    var mesh:MIMesh!
    
    var node:MINode = MINode.init()
    var meshBuffer:MIVertexBuffer!
    
    
    override init() {
        super.init()
        self.device = MTLCreateSystemDefaultDevice()
        self.uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size * MBEInFlightBufferCount, options: MTLResourceOptions.cpuCacheModeWriteCombined)
        self.uniformBuffer.label = "Uniform"
        self.commandQueue = device.makeCommandQueue()
        
        createRenderPipelineState()
        createDepthStencilState()
        createSamplerState()
        
        displaySemaphore = DispatchSemaphore(value: MBEInFlightBufferCount)
    }
    
    
    func makeResource(mesh:MIMesh) -> Void {
        self.mesh = mesh
        meshBuffer = MIVertexBuffer.init()
        meshBuffer.vertexBuffer = device!.makeBuffer(bytes: mesh.vecs, length: MemoryLayout<MIVertex>.size * mesh.vecs.count, options: [])
        meshBuffer.indexBuffer = device!.makeBuffer(bytes: mesh.face, length: MemoryLayout<UInt16>.size * mesh.face.count , options: [])
    }
    
    func makeResource(buffers:MIVertexBuffer) -> Void {
        self.meshBuffer = buffers
    }
    
    func setTexture(texture:UIImage) -> Void {
        let loader = MTKTextureLoader.init(device: self.device)
        do{
            let dic = [MTKTextureLoader.Option.textureUsage:MTLTextureUsage.unknown]
            self.bgTexture = try loader.newTexture(cgImage: #imageLiteral(resourceName: "bg").cgImage!, options: nil)
            self.diffuseTexture = try loader.newTexture(cgImage: texture.cgImage!, options: nil)
        }catch{
            print("error: metal texture load failed !!!")
        }
    }
    
    func createRenderPipelineState() -> Void {
        let library = self.device.makeDefaultLibrary()
        let pipelineDescriptor = MTLRenderPipelineDescriptor.init()
        
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_project")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_texture")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        self.renderPipelineState = try! self.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func createDepthStencilState() -> Void {
        let depthStencilDescriptor = MTLDepthStencilDescriptor.init()
        depthStencilDescriptor.depthCompareFunction = .less;
        depthStencilDescriptor.isDepthWriteEnabled = true;
        self.depthStencilState = self.device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
    
    func createSamplerState() -> Void {
        let samplerDesc = MTLSamplerDescriptor.init()
        samplerDesc.sAddressMode = .clampToEdge
        samplerDesc.tAddressMode = .clampToEdge
        samplerDesc.minFilter = .nearest
        samplerDesc.magFilter = .linear
        samplerDesc.mipFilter = .linear
        self.samplerState = device.makeSamplerState(descriptor: samplerDesc)
    }
    
    func makeDepthTexture(view:MTKView) -> Void {
        
        let drawableSize = view.drawableSize;
        
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                            width: Int(drawableSize.width),
                                                            height: Int(drawableSize.height),
                                                            mipmapped: false)
        desc.usage = .renderTarget
        self.depthTexture = view.device?.makeTexture(descriptor: desc)
    }
    
    //瞬时变量
    func currentRenderPassDescriptor(view:MTKView) -> MTLRenderPassDescriptor? {
        
        let passDescriptor = MTLRenderPassDescriptor.init()
        
        passDescriptor.colorAttachments[0].texture = view.currentDrawable?.texture
        passDescriptor.colorAttachments[0].clearColor = view.clearColor
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].loadAction = .clear
        
        passDescriptor.depthAttachment.texture = self.depthTexture
        passDescriptor.depthAttachment.clearDepth = 1.0
        passDescriptor.depthAttachment.loadAction = .clear
        passDescriptor.depthAttachment.storeAction = .dontCare
        
        return passDescriptor
    }

    
}

extension MIMetalRender:MTKViewDelegate{

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        makeDepthTexture(view: view)
    }
    
    func draw(in view: MTKView) {
        if depthTexture == nil {
            makeDepthTexture(view: view)
        }
        
        if let currentDrawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let passDescriptor = self.currentRenderPassDescriptor(view: view),
            let renderPass = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor){
            
            let _ = displaySemaphore.wait(timeout: DispatchTime.distantFuture)
    
            self.updata(view)
            
            renderPass.setRenderPipelineState(self.renderPipelineState)
            renderPass.setDepthStencilState(self.depthStencilState)
            renderPass.setFrontFacing(MTLWinding.counterClockwise)
            renderPass.setCullMode(.back)
            
            let uniformOffset = MemoryLayout<Uniforms>.size * self.bufferIndex
            renderPass.setVertexBuffer(meshBuffer.vertexBuffer, offset: 0, index: 0)
            renderPass.setVertexBuffer(uniformBuffer, offset: uniformOffset, index: 1)
            
            renderPass.setFragmentTexture(self.diffuseTexture, index: 0)
            renderPass.setFragmentSamplerState(self.samplerState, index: 0)
            
            renderPass.drawIndexedPrimitives(type: .triangle,
                                              indexCount: meshBuffer.indexBuffer.length / MemoryLayout<UInt16>.size,
                                              indexType: MTLIndexType.uint16,
                                              indexBuffer: meshBuffer.indexBuffer,
                                              indexBufferOffset: 0)
            
            renderPass.endEncoding()
            
            commandBuffer.present(currentDrawable)
            commandBuffer.addCompletedHandler({ (commandBuffer) in
                self.bufferIndex = (self.bufferIndex + 1) % MBEInFlightBufferCount
                self.displaySemaphore.signal()
            })
            commandBuffer.commit()
        }
    
    }
    
    func updata(_ view:MTKView) -> Void {
        let xAxis:vector_float3 = [1,0,0]
        let yAxis:vector_float3 = [0,1,0]
        let xRot:matrix_float4x4 = matrix_float4x4_rotation(axis: xAxis, angle: self.node.rotate.x)
        let yRot:matrix_float4x4 = matrix_float4x4_rotation(axis: yAxis, angle: self.node.rotate.y)
        let scale = matrix_float4x4_uniform_scale(scale: node.scale)
        let modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale)
        
        let cameraTranslation:simd_float3 = [0,0,-250]
        let viewMatrix:matrix_float4x4 = matrix_float4x4_translation(t: cameraTranslation)
        
        let drawabelSize = view.drawableSize
        
        let aspect:Float = Float(drawabelSize.width / drawabelSize.height)
        let fov:Float = (2.0 * Float.pi) / 5.0
        let near:Float = 0.1
        let far:Float = 1000
        let projectionMatrix:matrix_float4x4 = matrix_float4x4_perspective(aspect, fov, near, far)
        
        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
        let modelViewProjectionMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
        let normalMatrix = matrix_float4x4_extract_linear(m: modelViewMatrix)
        
        var uniforms = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix,
                                modelViewMatrix: modelViewMatrix,
                                normalMatrix: normalMatrix)
        
        let uniformBufferOffset = MemoryLayout<Uniforms>.size * self.bufferIndex
        memcpy(self.uniformBuffer.contents() + uniformBufferOffset, &uniforms, MemoryLayout<Uniforms>.size)
    }


    
}




