
import Foundation
import MetalKit

class Scene {
    let rootNode = Node()
    let avatarNode = Node()
    
    init() {
        rootNode.addChildNode(avatarNode)
        avatarNode.transform = matrix_float4x4()
    }

    func hitTest(_ ray: Ray) -> HitResult? {
        return rootNode.hitTest(ray)
    }
}
