//
//  GameViewController.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 7/2/24.
//

import SpriteKit

class GameViewController: UIViewController {
    // MARK: - Life's cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            let scene = StartScene(size: view.frame.size)

            view.isMultipleTouchEnabled = true
            view.ignoresSiblingOrder = true
            view.presentScene(scene)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActiveNotification),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    // MARK: - Notifications

    @objc func willResignActiveNotification() {
        if let view = self.view as! SKView? {
            view.isPaused = true
        }
    }

    @objc func didBecomeActiveNotification() {
        if let view = self.view as! SKView? {
            view.isPaused = false
        }
    }
}
