import SceneKit
import UIKit

final class TycoonScene: SCNScene {
    private let sky = UIColor(red: 0.035, green: 0.05, blue: 0.09, alpha: 1)
    private var map = "HQ"
    private var avatarNode: SCNNode?
    private var dealNodes: [SCNNode] = []

    override init() {
        super.init()
        build(map: "HQ")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build(map: "HQ")
    }

    func setMap(_ newMap: String) {
        guard map != newMap else { return }
        map = newMap
        rootNode.childNodes.forEach { $0.removeFromParentNode() }
        build(map: newMap)
    }

    func updatePlayer(x: Float, z: Float, pickupsCollected: Int) {
        avatarNode?.position = SCNVector3(x, 0.9, z)
        for (index, node) in dealNodes.enumerated() {
            node.isHidden = index < pickupsCollected
        }
    }

    private func build(map: String) {
        background.contents = sky
        fogStartDistance = 35; fogEndDistance = 80; fogColor = sky
        dealNodes = []

        let camera = SCNCamera(); camera.fieldOfView = 48
        let cameraNode = SCNNode(); cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 10, 18); cameraNode.eulerAngles = SCNVector3(-0.42, 0, 0)
        rootNode.addChildNode(cameraNode)

        let light = SCNLight(); light.type = .omni; light.intensity = 1100; light.color = UIColor.white
        let lightNode = SCNNode(); lightNode.light = light; lightNode.position = SCNVector3(2, 12, 8); rootNode.addChildNode(lightNode)
        let fill = SCNLight(); fill.type = .ambient; fill.intensity = 450; fill.color = UIColor(red: 0.25, green: 0.35, blue: 0.65, alpha: 1)
        let fillNode = SCNNode(); fillNode.light = fill; rootNode.addChildNode(fillNode)

        addTexturedBox(name: "ground", size: SCNVector3(38, 0.3, 38), position: SCNVector3(0, -0.2, 0), asset: map == "Downtown" ? "NeonFloor" : "OfficeFloor", fallback: map == "Downtown" ? .darkGray : UIColor(red: 0.07, green: 0.11, blue: 0.16, alpha: 1))
        if map == "HQ" { buildHQ() } else { buildDowntown() }
        addAvatar(position: SCNVector3(0, 0.9, 2.4))
        addDeals()
        addBillboard(text: map == "HQ" ? "H0RII HQ" : "DOWNTOWN", position: SCNVector3(0, 5.7, -3.2))
    }

    private func buildHQ() {
        addTexturedBox(name: "office", size: SCNVector3(12, 5, 5), position: SCNVector3(0, 2.5, -5), asset: "OfficeWall", fallback: UIColor(red: 0.12, green: 0.18, blue: 0.28, alpha: 1))
        addBox(name: "roof", size: SCNVector3(13, 0.25, 6), position: SCNVector3(0, 5.15, -5), color: UIColor.systemIndigo)
        for x in stride(from: Float(-4.5), through: Float(4.5), by: Float(3.0)) {
            addBox(name: "window", size: SCNVector3(1.7, 1.5, 0.12), position: SCNVector3(x, 3.0, -2.42), color: UIColor.cyan)
        }
        addDesk(position: SCNVector3(0, 0.65, -1.4)); addPlant(position: SCNVector3(-5.5, 0.8, 0))
        for x in [Float(-10.0), Float(9.0)] {
            addBox(name: "tower", size: SCNVector3(2.5, 8, 2.5), position: SCNVector3(x, 4, -7), color: UIColor.systemPurple)
        }
    }

    private func buildDowntown() {
        addBox(name: "road", size: SCNVector3(4, 0.08, 35), position: SCNVector3(0, 0.03, 0), color: UIColor.black)
        for x in [Float(-8.0), Float(8.0)] {
            for z in stride(from: Float(-10.0), through: Float(10.0), by: Float(6.0)) {
                addTexturedBox(name: "building", size: SCNVector3(4, Float(3 + Int(abs(z)) % 6), 4), position: SCNVector3(x, 2.0, z), asset: "CityPanel", fallback: UIColor(hue: CGFloat((abs(z) + abs(x)) / 30), saturation: 0.65, brightness: 0.75, alpha: 1))
            }
        }
        addTexturedBox(name: "stage", size: SCNVector3(8, 0.4, 5), position: SCNVector3(0, 0.25, -5), asset: "CreatorStage", fallback: UIColor.systemPink)
    }

    private func addDeals() {
        let positions: [SCNVector3] = map == "HQ"
            ? [SCNVector3(-4, 0.8, 3), SCNVector3(5, 0.8, -1), SCNVector3(2, 0.8, -8)]
            : [SCNVector3(-2, 0.8, 6), SCNVector3(3, 0.8, -2), SCNVector3(-5, 0.8, -7)]
        for pos in positions {
            let coin = SCNCylinder(radius: 0.45, height: 0.12)
            coin.firstMaterial?.diffuse.contents = UIImage(named: "Coin") ?? UIColor.systemYellow
            let node = SCNNode(geometry: coin); node.position = pos; node.eulerAngles.x = .pi / 2
            let spin = CABasicAnimation(keyPath: "eulerAngles.z"); spin.fromValue = 0; spin.toValue = CGFloat.pi * 2; spin.duration = 1.2; spin.repeatCount = .greatestFiniteMagnitude
            node.addAnimation(spin, forKey: "spin")
            dealNodes.append(node); rootNode.addChildNode(node)
        }
    }

    private func addAvatar(position: SCNVector3) {
        let root = SCNNode(); root.position = position; root.name = "player-avatar"; avatarNode = root
        let body = SCNCapsule(capRadius: 0.45, height: 1.3); body.firstMaterial?.diffuse.contents = UIImage(named: "AvatarSuit") ?? UIColor.systemPink
        let bodyNode = SCNNode(geometry: body); bodyNode.position.y = 0.7; root.addChildNode(bodyNode)
        let head = SCNSphere(radius: 0.43); head.firstMaterial?.diffuse.contents = UIColor(red: 0.95, green: 0.72, blue: 0.56, alpha: 1)
        let headNode = SCNNode(geometry: head); headNode.position.y = 1.65; root.addChildNode(headNode)
        let hair = SCNCylinder(radius: 0.46, height: 0.18); hair.firstMaterial?.diffuse.contents = UIColor.black
        let hairNode = SCNNode(geometry: hair); hairNode.position.y = 2.02; root.addChildNode(hairNode)
        let bob = CABasicAnimation(keyPath: "position.y"); bob.fromValue = 0.9; bob.toValue = 1.05; bob.duration = 1.2; bob.autoreverses = true; bob.repeatCount = .greatestFiniteMagnitude
        root.addAnimation(bob, forKey: "idle-bob"); rootNode.addChildNode(root)
    }

    private func addDesk(position: SCNVector3) {
        addTexturedBox(name: "desk", size: SCNVector3(5, 0.35, 1.5), position: position, asset: "DeskTexture", fallback: UIColor.systemOrange)
        addTexturedBox(name: "screen", size: SCNVector3(1.8, 1.1, 0.15), position: SCNVector3(position.x, position.y + 1, position.z - 0.45), asset: "CreatorScreen", fallback: UIColor.cyan)
    }

    private func addPlant(position: SCNVector3) {
        addBox(name: "pot", size: SCNVector3(0.8, 0.7, 0.8), position: position, color: UIColor.brown)
        let crown = SCNSphere(radius: 1.0); crown.firstMaterial?.diffuse.contents = UIColor.systemGreen
        let node = SCNNode(geometry: crown); node.position = SCNVector3(position.x, position.y + 1.2, position.z); rootNode.addChildNode(node)
    }

    private func addBillboard(text: String, position: SCNVector3) {
        let geometry = SCNText(string: text, extrusionDepth: 0.03); geometry.font = UIFont.boldSystemFont(ofSize: 0.8); geometry.firstMaterial?.diffuse.contents = UIColor.systemPink
        let node = SCNNode(geometry: geometry); node.position = position; node.scale = SCNVector3(0.012, 0.012, 0.012); node.constraints = [SCNBillboardConstraint()]; rootNode.addChildNode(node)
    }

    private func addTexturedBox(name: String, size: SCNVector3, position: SCNVector3, asset: String, fallback: UIColor) {
        let box = SCNBox(width: CGFloat(size.x), height: CGFloat(size.y), length: CGFloat(size.z), chamferRadius: 0.08)
        box.firstMaterial?.diffuse.contents = UIImage(named: asset) ?? fallback
        box.firstMaterial?.diffuse.wrapS = .repeat; box.firstMaterial?.diffuse.wrapT = .repeat
        let node = SCNNode(geometry: box); node.name = name; node.position = position; rootNode.addChildNode(node)
    }

    private func addBox(name: String, size: SCNVector3, position: SCNVector3, color: UIColor) {
        let box = SCNBox(width: CGFloat(size.x), height: CGFloat(size.y), length: CGFloat(size.z), chamferRadius: 0.08)
        box.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: box); node.name = name; node.position = position; rootNode.addChildNode(node)
    }
}
