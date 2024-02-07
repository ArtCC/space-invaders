//
//  GameScene+UITouch.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 7/2/24.
//

import SpriteKit

extension GameScene {
    // MARK: - UITouch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)

            if let node = atPoint(touchLocation) as? SKSpriteNode {
                if node.name == Nodes.joystick.rawValue {
                    if CGRectContainsPoint(joystick.frame, touchLocation) {
                        joystickIsActive = true
                    } else {
                        joystickIsActive = false
                    }
                    selectedNodes[touch] = node
                } else if node.name == Nodes.firePad.rawValue {
                    if let touch = touches.first, touch.tapCount == 1 {
                        tapQueue.append(1)
                    }
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)

            if let node = selectedNodes[touch], node.name == Nodes.joystick.rawValue {
                if joystickIsActive {
                    let vector = CGVector(dx: touchLocation.x - joystickBase.position.x,
                                          dy: touchLocation.y - joystickBase.position.y)
                    let angle = atan2(vector.dy, vector.dx)
                    let radio: CGFloat = joystickBase.frame.size.height / 2

                    let distance = min(sqrt(vector.dx * vector.dx + vector.dy * vector.dy), radio)
                    let xDist: CGFloat = distance * cos(angle)

                    joystick.position = CGPoint(x: joystickBase.position.x + xDist, y: joystickBase.position.y)

                    let xDistPlayer: CGFloat = sin(angle - 1.57079633) * radio

                    playerVelocityX = xDistPlayer / radio
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNodes[touch] != nil {
                if joystickIsActive == true {
                    let defaultPosition: SKAction = SKAction.move(to: joystickBase.position, duration: 0.05)
                    defaultPosition.timingMode = SKActionTimingMode.easeOut

                    joystick.run(defaultPosition)

                    joystickIsActive = false

                    playerVelocityX = 0
                }

                selectedNodes[touch] = nil
            }
        }
    }
}
