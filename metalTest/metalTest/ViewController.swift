//
//  ViewController.swift
//  metalTest
//
//  Created by 加冰 on 2018/8/28.
//  Copyright © 2018年 加冰. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var metalView:MIMetalView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textureName = "head3d"
        let objName = "head3dStandard"
        
        let objPath = Bundle.main.path(forResource: objName, ofType: "obj")!
        let loader = MeshLoader.init()
        loader.loadObj(path: objPath)
        let mesh = loader.getMetalData()
        
        let texturePath = Bundle.main.path(forResource: textureName, ofType: "jpg")!
        let texture = UIImage.init(contentsOfFile: texturePath)


        
        self.metalView = MIMetalView.init(frame: self.view.bounds)
        self.metalView.render.makeResource(mesh: mesh)
        self.metalView.render.setTexture(texture: texture!)
        
        self.view.addSubview(metalView)

    }
    

    

    
    
    
}

