//
//  Constants.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 12/2/24.
//

import Foundation

enum Constants {
    enum Fonts {
        static let courier = "Courier"
    }

    enum General {
        static let minInvaderBottomHeight: Float = 32
        static let invaderName = "invader"
        static let invaderGridSpacing = CGSize(width: 12, height: 12)
        static let invaderRowCount = 5
        static let invaderColCount = 10
        static let shipSize = CGSize(width: 30, height: 16)
        static let bulletSize = CGSize(width: 4, height: 8)
    }

    enum Images {
        static let joystickBase = "img_base_joystick"
        static let joystick = "img_joystick"
        static let firePad = "img_joystick"
        static let ship = "ship"
        static let logo = "logo"
    }

    enum Keys {
        static let scoreKey = "score.key"
    }

    enum Physics {
        static let invaderCategory: UInt32 = 0x1 << 0
        static let shipFiredBulletCategory: UInt32 = 0x1 << 1
        static let shipCategory: UInt32 = 0x1 << 2
        static let sceneEdgeCategory: UInt32 = 0x1 << 3
        static let invaderFiredBulletCategory: UInt32 = 0x1 << 4
    }

    enum Sounds {
        static let invader = "InvaderHit.wav"
        static let invaderBullet = "InvaderBullet.wav"
        static let ship = "ShipHit.wav"
        static let shipBullet = "ShipBullet.wav"
    }
}
