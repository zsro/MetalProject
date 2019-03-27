
import simd

struct BoundingSphere {
    var center: float3
    var radius: Float
    
    // https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection
    func intersect(_ ray: Ray) -> float4? {
        var t0, t1: Float
        let radius2 = radius * radius
        if (radius2 == 0) { return nil }
        let L = center - ray.origin
        let tca = simd_dot(L, ray.direction)
        
        let d2 = simd_dot(L, L) - tca * tca
        if (d2 > radius2) { return nil }
        let thc = sqrt(radius2 - d2)
        t0 = tca - thc
        t1 = tca + thc
        
        if (t0 > t1) { swap(&t0, &t1) }
        
        if t0 < 0 {
            t0 = t1
            if t0 < 0 { return nil }
        }
        
        return float4(ray.origin + ray.direction * t0, 1)
    }
}

func IntersectTriangle(orig: float3, dir: float3, v0: float3, v1: float3, v2: float3) -> Bool{
    
    let E1 = v1 - v0
    let E2 = v2 - v0
    let p = cross(dir, E2)
    
    var det = dot(E1, p)
    
    var t: float3
    if det > 0{
        t = orig - v0
    }else{
        t = v0 - orig
        det = -det
    }
    
    if det < 0.0001{
        return false
    }
    
    let u = dot(t, p)
    if u < 0.0 || u > det{
        return false
    }
    
    let Q = cross(t, E1)
    
    let v = dot(dir, Q)
    
    if v < 0.0 || u + v > det{
        return false
    }

    return true
}
