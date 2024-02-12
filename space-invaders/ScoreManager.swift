//
//  ScoreManager.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 12/2/24.
//

import Foundation

struct ScoreManager {
    // MARK: - Properties

    private static let defaults = UserDefaults.standard

    // MARK: - Public

    static func getScore() -> Int {
        defaults.integer(forKey: Constants.Keys.scoreKey)
    }

    static func saveScore(_ score: Int) {
        score > getScore() ? defaults.setValue(score, forKey: Constants.Keys.scoreKey) : nil
    }
}
