//
//  GameScene+Setup.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 7/2/24.
//

import SpriteKit

extension GameScene {
    func setup() {
        physicsWorld.contactDelegate = self

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody!.categoryBitMask = Constants.kSceneEdgeCategory

        setupHud()
        setupInvaders()
        setupPlayerControls()
        setupShip()
    }

    func setupHud() {
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = Nodes.scoreHud.rawValue
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = .red
        scoreLabel.text = String(format: "Puntuación: %04u", 0)
        scoreLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (60 + scoreLabel.frame.size.height)
        )

        addChild(scoreLabel)
    }

    func setupInvaders() {
        let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 1.35)

        for row in 0..<Constants.kInvaderRowCount {
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

            for _ in 1..<Constants.kInvaderColCount {
                let invader = makeInvader(ofType: invaderType)
                invader.position = invaderPosition

                addChild(invader)

                invaderPosition = CGPoint(
                    x: invaderPosition.x + InvaderType.size.width + Constants.kInvaderGridSpacing.width,
                    y: invaderPositionY
                )
            }
        }
    }

    func setupShip() {
        let ship = makeShip()
        ship.position = CGPoint(x: size.width / 2.0, 
                                y: Constants.kShipSize.height / 2.0 + joystickBase.position.y + joystick.frame.height)

        addChild(ship)
    }

    func setupPlayerControls() {
        joystickBase.name = Nodes.joystickBase.rawValue
        joystickBase.position = CGPoint(x: 80, y: 250)
        joystickBase.zPosition = 5.0
        joystickBase.alpha = 0.2
        joystickBase.setScale(0.3)

        joystick.name = Nodes.joystick.rawValue
        joystick.position = joystickBase.position
        joystick.zPosition = 6.0
        joystick.alpha = 0.5
        joystick.setScale(0.20)

        firePad.name = Nodes.firePad.rawValue
        firePad.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        firePad.position = CGPoint(x: frame.size.width - 50, y: joystick.position.y - joystick.frame.size.height / 2)
        firePad.zPosition = 6.0
        firePad.alpha = 0.5
        firePad.setScale(0.20)

        addChild(joystickBase)
        addChild(joystick)
        addChild(firePad)
    }

    func makeInvader(ofType invaderType: InvaderType) -> SKNode {
        let invaderTextures = loadInvaderTextures(ofType: invaderType)

        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = InvaderType.name
        invader.run(SKAction.repeatForever(SKAction.animate(with: invaderTextures, timePerFrame: timePerMove)))
        invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
        invader.physicsBody!.isDynamic = false
        invader.physicsBody!.categoryBitMask = Constants.kInvaderCategory
        invader.physicsBody!.contactTestBitMask = 0x0
        invader.physicsBody!.collisionBitMask = 0x0

        return invader
    }

    func loadInvaderTextures(ofType invaderType: InvaderType) -> [SKTexture] {
        var prefix: String

        switch(invaderType) {
        case .a:
            prefix = "invaderA"
        case .b:
            prefix = "invaderB"
        case .c:
            prefix = "invaderC"
        }

        return [SKTexture(imageNamed: String(format: "%@_00", prefix)),
                SKTexture(imageNamed: String(format: "%@_01", prefix))]
    }

    func makeShip() -> SKNode {
        ship.name = Nodes.ship.rawValue
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody!.isDynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.mass = 0.02
        ship.physicsBody!.categoryBitMask = Constants.kShipCategory
        ship.physicsBody!.contactTestBitMask = 0x0
        ship.physicsBody!.collisionBitMask = Constants.kSceneEdgeCategory

        return ship
    }
}
