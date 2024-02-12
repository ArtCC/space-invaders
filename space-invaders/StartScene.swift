//
//  StartScene.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 7/2/24.
//

import SpriteKit
import UIKit

class StartScene: SKScene {
    // MARK: - Life's cycle

    override func didMove(to view: SKView) {
        createHeader()

        backgroundColor = .black
    }

    // MARK: - UITouch

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill

        view?.presentScene(gameScene, transition: .crossFade(withDuration: 0.5))
    }

    // MARK: - Private

    private func createHeader() {
        let sprite = SKSpriteNode(imageNamed: Constants.Images.logo)
        sprite.size = CGSize(width: 360, height: 200)
        sprite.position = CGPoint(x: size.width / 2, y: size.height / 2)

        addChild(sprite)

        let waitAction = SKAction.wait(forDuration: 0.5)
        let moveTo = CGPoint(x: size.width / 2, y: size.height - sprite.size.height / 2 - sprite.size.height)
        let moveAction = SKAction.move(to: moveTo, duration: 0.5)

        sprite.run(SKAction.sequence([waitAction, moveAction])) {
            self.createLabel()
        }
    }

    private func createLabel() {
        let gameOverLabel = SKLabelNode(fontNamed: Constants.Fonts.courier)
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .white
        gameOverLabel.text = "Jugar"
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)

        addChild(gameOverLabel)
    }
}
