//
//  MIMetalView.swift
//  metalTest
//
//  Created by 加冰 on 2018/8/28.
//  Copyright © 2018年 加冰. All rights reserved.
//

import Foundation
import MetalKit

class MIMetalView: MTKView {

    var render:MIMetalRender!
    

    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device == nil ? MTLCreateSystemDefaultDevice() : device)
        
        self.preferredFramesPerSecond = 30
        self.colorPixelFormat = .bgra8Unorm
        self.clearColor = MTLClearColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        render = MIMetalRender.init()
        self.delegate = render
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panHandle(_:)))
        self.addGestureRecognizer(pan)

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var angularVelocity:CGPoint = CGPoint.init()
    var angle:CGPoint = CGPoint.init()
    let kVelocityScale:Float = 0.0003
    
    @objc func panHandle(_ sender:UIPanGestureRecognizer) ->Void{
        let velocity = sender.velocity(in: self)
        render.node.rotate.x -= (Float(velocity.y) * kVelocityScale)
        render.node.rotate.y -= (Float(velocity.x) * kVelocityScale)
    }
    
    
}











