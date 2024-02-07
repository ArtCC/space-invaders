//
//  GameScene.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 7/2/24.
//

import GameplayKit
import SpriteKit
import UIKit

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

enum InvaderMovementDirection {
    case right
    case left
    case downThenRight
    case downThenLeft
    case none
}

enum BulletType {
    case shipFired
    case invaderFired
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties

    var invaderMovementDirection: InvaderMovementDirection = .right
    var timeOfLastMove: CFTimeInterval = 0
    var timePerMove: CFTimeInterval = 1
    var tapQueue = [Int]()
    var contactQueue = [SKPhysicsContact]()
    var score: Int = 0

    let kMinInvaderBottomHeight: Float = 32
    let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    let kScoreHudName = "scoreHud"
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSize(width: 4, height: 8)
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4

    // MARK: - Life's cycle

    override func didMove(to view: SKView) {
        backgroundColor = .black

        createContent()
    }

    // MARK: - UITouch

#warning("Cambiar por el joystick en pantalla y el botón de disparo.")
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.tapCount == 1 {
            tapQueue.append(1)
        }
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        if isGameOver() {
            endGame()
        }

        moveInvaders(forUpdate: currentTime)
        processUserTaps(forUpdate: currentTime)
        fireInvaderBullets(forUpdate: currentTime)
        processContacts(forUpdate: currentTime)
    }

    // MARK: - Private

    private func createContent() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody!.categoryBitMask = kSceneEdgeCategory

        physicsWorld.contactDelegate = self

        setupInvaders()
        setupShip()
        setupHud()
    }

    func loadInvaderTextures(ofType invaderType: InvaderType) -> [SKTexture] {
        var prefix: String

        switch(invaderType) {
        case .a:
            prefix = "InvaderA"
        case .b:
            prefix = "InvaderB"
        case .c:
            prefix = "InvaderC"
        }

        return [SKTexture(imageNamed: String(format: "%@_00", prefix)),
                SKTexture(imageNamed: String(format: "%@_01", prefix))]
    }

    func makeInvader(ofType invaderType: InvaderType) -> SKNode {
        let invaderTextures = loadInvaderTextures(ofType: invaderType)

        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = InvaderType.name
        invader.run(SKAction.repeatForever(SKAction.animate(with: invaderTextures, timePerFrame: timePerMove)))
        invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
        invader.physicsBody!.isDynamic = false
        invader.physicsBody!.categoryBitMask = kInvaderCategory
        invader.physicsBody!.contactTestBitMask = 0x0
        invader.physicsBody!.collisionBitMask = 0x0

        return invader
    }

    func setupInvaders() {
        let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 2)

        for row in 0..<kInvaderRowCount {
            var invaderType: InvaderType

            if row % 3 == 0 {
                invaderType = .a
            } else if row % 3 == 1 {
                invaderType = .b
            } else {
                invaderType = .c
            }

            let invaderPositionY = CGFloat(row) * (InvaderType.size.height * 2) + baseOrigin.y

            var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)

            for _ in 1..<kInvaderRowCount {
                let invader = makeInvader(ofType: invaderType)
                invader.position = invaderPosition

                addChild(invader)

                invaderPosition = CGPoint(
                    x: invaderPosition.x + InvaderType.size.width + kInvaderGridSpacing.width,
                    y: invaderPositionY
                )
            }
        }
    }

    func setupShip() {
        let ship = makeShip()
        ship.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)

        addChild(ship)
    }

    func makeShip() -> SKNode {
        let ship = SKSpriteNode(imageNamed: "Ship")
        ship.name = kShipName
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody!.isDynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.mass = 0.02
        ship.physicsBody!.categoryBitMask = kShipCategory
        ship.physicsBody!.contactTestBitMask = 0x0
        ship.physicsBody!.collisionBitMask = kSceneEdgeCategory

        return ship
    }

    func setupHud() {
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = .red
        scoreLabel.text = String(format: "Puntuación: %04u", 0)
        scoreLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (60 + scoreLabel.frame.size.height)
        )

        addChild(scoreLabel)
    }

    func adjustScore(by points: Int) {
        score += points

        if let score = childNode(withName: kScoreHudName) as? SKLabelNode {
            score.text = String(format: "Puntuación: %04u", self.score)
        }
    }

    func makeBullet(ofType bulletType: BulletType) -> SKNode {
        var bullet: SKNode

        switch bulletType {
        case .shipFired:
            bullet = SKSpriteNode(color: .green, size: kBulletSize)
            bullet.name = kShipFiredBulletName

            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kInvaderCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        case .invaderFired:
            bullet = SKSpriteNode(color: .magenta, size: kBulletSize)
            bullet.name = kInvaderFiredBulletName

            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kShipCategory
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

        let ratio: CGFloat = CGFloat(self.timePerMove / timePerMove)

        self.timePerMove = timePerMove

        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            node.speed = node.speed * ratio
        }
    }

#warning("Cambiar por el joystick en pantalla y el botón de disparo.")
    /**
     func processUserMotion(forUpdate currentTime: CFTimeInterval) {
     if let ship = childNode(withName: kShipName) as? SKSpriteNode,
     let data = motionManager.accelerometerData,
     fabs(data.acceleration.x) > 0.2 {
     ship.physicsBody!.applyForce(CGVector(dx: 40 * CGFloat(data.acceleration.x), dy: 0))
     }
     }*/

    func fireInvaderBullets(forUpdate currentTime: CFTimeInterval) {
        let existingBullet = childNode(withName: kInvaderFiredBulletName)

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

    func processUserTaps(forUpdate currentTime: CFTimeInterval) {
        tapQueue.forEach {
            if $0 == 1 {
                fireShipBullets()
            }
            tapQueue.remove(at: 0)
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
        let existingBullet = childNode(withName: kShipFiredBulletName)

        if existingBullet == nil {
            if let ship = childNode(withName: kShipName) {
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

        if nodeNames.contains(kShipName) && nodeNames.contains(kInvaderFiredBulletName) {
            run(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))

            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
        } else if nodeNames.contains(InvaderType.name) && nodeNames.contains(kShipFiredBulletName) {
            run(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))

            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()

            adjustScore(by: 100)
        }
    }

    func isGameOver() -> Bool {
        var invaderTooLow = false

        let invader = childNode(withName: InvaderType.name)
        let ship = childNode(withName: kShipName)

        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            if Float(node.frame.minY) <= self.kMinInvaderBottomHeight   {
                invaderTooLow = true
                stop.pointee = true
            }
        }

        return invader == nil || invaderTooLow || ship == nil
    }

    func endGame() {
        let gameOverScene = GameOverScene(size: size)

        view?.presentScene(gameOverScene, transition: .crossFade(withDuration: 0.5))
    }
}
