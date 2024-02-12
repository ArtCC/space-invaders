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
        createScoreLabel()

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
            self.createStartLabel()
        }
    }

    private func createStartLabel() {
        let label = SKLabelNode(fontNamed: Constants.Fonts.courier)
        label.fontSize = 50
        label.fontColor = .white
        label.text = "Jugar"
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)

        addChild(label)
    }

    private func createScoreLabel() {
        let score = String(ScoreManager.getScore())
        let scoreLabel = SKLabelNode(fontNamed: Constants.Fonts.courier)
        scoreLabel.text = String(format: "Puntuación: %@", score)
        scoreLabel.fontSize = 25
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: size.width - 35, y: size.height - (60 + scoreLabel.frame.size.height))

        addChild(scoreLabel)
    }
}
