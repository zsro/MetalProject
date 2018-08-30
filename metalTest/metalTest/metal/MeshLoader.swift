//
//  MeshLoader.swift
//  metalTest
//
//  Created by 加冰 on 2018/8/28.
//  Copyright © 2018年 加冰. All rights reserved.
//

import Foundation

class MeshLoader {
    
    var vecs:[SCNVector3] = [SCNVector3]()
    var uvs:[CGPoint] = [CGPoint]()
    var normal:[SCNVector3] = [SCNVector3]()
    var tris:[UInt16] = []
    
    init() {
        
    }
    
    //获取metal数据
    func getMetalData() -> MIMesh {
        let mesh = MIMesh.init()
        let count = vecs.count
        var arr:[MIVertex] = []
        for i in 0...count - 1{
            let vec = MIVertex.init(position: simd_float4.init([vecs[i].x,vecs[i].y,vecs[i].z,1]),
                                    normal: simd_float4.init(normal[i].x,normal[i].y,normal[i].z,1),
                                    texcoord: simd_float2.init(Float(uvs[i].x), Float(uvs[i].y)))
            arr.append(vec)
        }
        mesh.vecs = arr
        mesh.face = tris
        return mesh
    }
    
    func loadObj(path:String) -> Void {
        let loader = ObjLoaderBridge.init()
        loader.load(path)
        
        let _vs = loader.data_v!
        let _vns = loader.data_vn!
        let _vts = loader.data_vt!
        let _face = loader.data_face!
        
        for i in 0..._vs.count/3 - 1{
            let x = (_vs[i*3] as! NSNumber).floatValue
            let y = (_vs[i*3+1] as! NSNumber).floatValue
            let z = (_vs[i*3+2] as! NSNumber).floatValue
            
            vecs.append(SCNVector3Make(x,y,z))
            
            normal.append(SCNVector3Make((_vns[i*3] as! NSNumber).floatValue,
                                         (_vns[i*3+1] as! NSNumber).floatValue,
                                         (_vns[i*3+2] as! NSNumber).floatValue))
            
            uvs.append(CGPoint.init(x: (_vts[i*2] as! NSNumber).doubleValue,
                                    y: (_vts[i*2+1] as! NSNumber).doubleValue))
        }
        
        for i in 0..._face.count/3 - 1{
            let p1 = (_face[i*3] as! NSNumber).uint16Value
            let p2 = (_face[i*3 + 1] as! NSNumber).uint16Value
            let p3 = (_face[i*3 + 2] as! NSNumber).uint16Value
            let tri_ves:[UInt16] = [p1,p2,p3]
            tris.append(contentsOf: tri_ves)
        }
    }
    
}

class MIMesh: NSObject {
    var vecs:[MIVertex] = []
    var face:[UInt16] = []
    
    func updataVector(vs:NSMutableArray) -> Void {
        if vs.count == 0{
            return
        }
        for i in 0...vs.count/4 - 1{
            let index = (vs[i*4] as! NSNumber).intValue
            vecs[index].position.x = (vs[i*4+1] as! NSNumber).floatValue
            vecs[index].position.y = (vs[i*4+2] as! NSNumber).floatValue
            vecs[index].position.z = (vs[i*4+3] as! NSNumber).floatValue
        }
        
    }
}



