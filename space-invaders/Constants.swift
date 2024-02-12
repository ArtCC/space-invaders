//
//  Constants.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 12/2/24.
//

import Foundation

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

    enum Images {
        static let logo = "logo"
    }

    enum Fonts {
        static let courier = "Courier"
    }

    enum Sounds {
        static let invader = "InvaderHit.wav"
        static let invaderBullet = "InvaderBullet.wav"
        static let ship = "ShipHit.wav"
        static let shipBullet = "ShipBullet.wav"
    }
}
