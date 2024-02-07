//
//  GameOverScene.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 7/2/24.
//

import SpriteKit
import UIKit

class GameOverScene: SKScene {
    // MARK: - Life's cycle

    override func didMove(to view: SKView) {
        backgroundColor = .black

        createLabel()
        routeToStartScene()
    }

    // MARK: - Private

    private func createLabel() {
        let gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .white
        gameOverLabel.text = "¡Has perdido!"
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)

        addChild(gameOverLabel)
    }

    private func routeToStartScene() {
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run() { [weak self] in
                guard let self else {
                    return
                }
                let startScene = StartScene(size: size)
                startScene.scaleMode = .aspectFill

                view?.presentScene(startScene, transition: .crossFade(withDuration: 0.5))
            }
        ]))
    }
}
