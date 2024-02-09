//
//  GameScene.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 7/2/24.
//

import SpriteKit

enum BulletType {
    case shipFired
    case invaderFired
}

enum Constants {
    static let kMinInvaderBottomHeight: Float = 32
    static let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    static let kInvaderRowCount = 5
    static let kInvaderColCount = 10
    static let kShipSize = CGSize(width: 30, height: 16)
    static let kBulletSize = CGSize(width: 4, height: 8)
    static let kInvaderCategory: UInt32 = 0x1 << 0
    static let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    static let kShipCategory: UInt32 = 0x1 << 2
    static let kSceneEdgeCategory: UInt32 = 0x1 << 3
    static let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
}

enum InvaderMovementDirection {
    case right
    case left
    case downThenRight
    case downThenLeft
    case none
}

enum InvaderType {
    case a
    case b
    case c

    static var size: CGSize {
        CGSize(width: 24, height: 16)
    }

    static var name: String {
        "invader"
    }
}

enum Nodes: String {
    case firePad
    case invaderFiredBullet
    case joystick
    case joystickBase
    case scoreHud
    case ship
    case shipFiredBullet
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties

    var invaderMovementDirection: InvaderMovementDirection = .right
    var timeOfLastMove: CFTimeInterval = 0
    var timePerMove: CFTimeInterval = 1
    var contactQueue = [SKPhysicsContact]()
    var score: Int = 0
    var selectedNodes: [UITouch: SKSpriteNode] = [:]
    var joystickIsActive = false
    var playerVelocityX: CGFloat = 0

    let joystickBase = SKSpriteNode(imageNamed: "img_base_joystick")
    let joystick = SKSpriteNode(imageNamed: "img_joystick")
    let firePad = SKSpriteNode(imageNamed: "img_joystick")
    let ship = SKSpriteNode(imageNamed: "ship")

    // MARK: - Life's cycle

    override func didMove(to view: SKView) {
        backgroundColor = .black

        setup()
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        if isGameOver() {
            routeToGameOverScene()
        }

        moveInvaders(forUpdate: currentTime)
        fireInvaderBullets(forUpdate: currentTime)
        processContacts(forUpdate: currentTime)

        if joystickIsActive == true {
            ship.position = CGPointMake(ship.position.x - (playerVelocityX * 3), ship.position.y)
        }
    }

    // MARK: - Public

    func adjustScore(by points: Int) {
        score += points

        if let score = childNode(withName: Nodes.scoreHud.rawValue) as? SKLabelNode {
            score.text = String(format: "Puntuación: %04u", self.score)
        }
    }

    func makeBullet(ofType bulletType: BulletType) -> SKNode {
        var bullet: SKNode

        switch bulletType {
        case .shipFired:
            bullet = SKSpriteNode(color: .green, size: Constants.kBulletSize)
            bullet.name = Nodes.shipFiredBullet.rawValue
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = Constants.kShipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = Constants.kInvaderCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        case .invaderFired:
            bullet = SKSpriteNode(color: .magenta, size: Constants.kBulletSize)
            bullet.name = Nodes.invaderFiredBullet.rawValue
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = Constants.kInvaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = Constants.kShipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        }

        return bullet
    }

    func moveInvaders(forUpdate currentTime: CFTimeInterval) {
        if currentTime - timeOfLastMove < timePerMove {
            return
        }

        determineInvaderMovementDirection()

        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            switch self.invaderMovementDirection {
            case .right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .downThenLeft, .downThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .none:
                break
            }

            self.timeOfLastMove = currentTime
        }
    }

    func adjustInvaderMovement(to timePerMove: CFTimeInterval) {
        if self.timePerMove <= 0 {
            return
        }

        let ratio = CGFloat(self.timePerMove / timePerMove)

        self.timePerMove = timePerMove

        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            node.speed = node.speed * ratio
        }
    }

    func fireInvaderBullets(forUpdate currentTime: CFTimeInterval) {
        let existingBullet = childNode(withName: Nodes.invaderFiredBullet.rawValue)

        if existingBullet == nil {
            var allInvaders = [SKNode]()

            enumerateChildNodes(withName: InvaderType.name) { node, stop in
                allInvaders.append(node)
            }

            if allInvaders.count > 0 {
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                let invader = allInvaders[allInvadersIndex]

                let bullet = makeBullet(ofType: .invaderFired)
                bullet.position = CGPoint(
                    x: invader.position.x,
                    y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
                )

                let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))

                fireBullet(
                    bullet: bullet,
                    toDestination: bulletDestination,
                    withDuration: 2.0,
                    andSoundFileName: "InvaderBullet.wav"
                )
            }
        }
    }

    func processContacts(forUpdate currentTime: CFTimeInterval) {
        contactQueue.forEach {
            handle($0)

            if let index = contactQueue.firstIndex(of: $0) {
                contactQueue.remove(at: index)
            }
        }
    }

    func determineInvaderMovementDirection() {
        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection

        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            switch self.invaderMovementDirection {
            case .right:
                if node.frame.maxX >= node.scene!.size.width - 1.0 {
                    proposedMovementDirection = .downThenLeft

                    self.adjustInvaderMovement(to: self.timePerMove * 0.8)

                    stop.pointee = true
                }
            case .left:
                if node.frame.minX <= 1.0 {
                    proposedMovementDirection = .downThenRight

                    self.adjustInvaderMovement(to: self.timePerMove * 0.8)

                    stop.pointee = true
                }
            case .downThenLeft:
                proposedMovementDirection = .left

                stop.pointee = true
            case .downThenRight:
                proposedMovementDirection = .right

                stop.pointee = true
            default:
                break
            }
        }

        if proposedMovementDirection != invaderMovementDirection {
            invaderMovementDirection = proposedMovementDirection
        }
    }

    func fireBullet(bullet: SKNode,
                    toDestination destination: CGPoint,
                    withDuration duration: CFTimeInterval,
                    andSoundFileName soundName: String) {
        let bulletAction = SKAction.sequence([
            SKAction.move(to: destination, duration: duration),
            SKAction.wait(forDuration: 3.0 / 60.0),
            SKAction.removeFromParent()
        ])

        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)

        bullet.run(SKAction.group([bulletAction, soundAction]))

        addChild(bullet)
    }

    func fireShipBullets() {
        let existingBullet = childNode(withName: Nodes.shipFiredBullet.rawValue)

        if existingBullet == nil {
            if let ship = childNode(withName: Nodes.ship.rawValue) {
                let bullet = makeBullet(ofType: .shipFired)
                bullet.position = CGPoint(
                    x: ship.position.x,
                    y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
                )

                let bulletDestination = CGPoint(
                    x: ship.position.x,
                    y: frame.size.height + bullet.frame.size.height / 2
                )

                fireBullet(
                    bullet: bullet,
                    toDestination: bulletDestination,
                    withDuration: 1.0,
                    andSoundFileName: "ShipBullet.wav"
                )
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        contactQueue.append(contact)
    }

    func handle(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }

        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]

        if nodeNames.contains(Nodes.ship.rawValue) && nodeNames.contains(Nodes.invaderFiredBullet.rawValue) {
            run(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))

            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
        } else if nodeNames.contains(InvaderType.name) && nodeNames.contains(Nodes.shipFiredBullet.rawValue) {
            run(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))

            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()

            adjustScore(by: 100)
        } else if nodeNames.contains(InvaderType.name) && nodeNames.contains(Nodes.ship.rawValue) {
            run(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))

            routeToGameOverScene()
        }
    }

    func isGameOver() -> Bool {
        var invaderTooLow = false

        let invader = childNode(withName: InvaderType.name)
        let ship = childNode(withName: Nodes.ship.rawValue)

        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            if Float(node.frame.minY) <= Constants.kMinInvaderBottomHeight {
                invaderTooLow = true
                stop.pointee = true
            }
        }

        return invader == nil || invaderTooLow || ship == nil
    }

    func routeToGameOverScene() {
        let gameOverScene = GameOverScene(size: size)

        view?.presentScene(gameOverScene, transition: .crossFade(withDuration: 0.5))
    }
}
