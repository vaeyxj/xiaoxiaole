//
//  SaveManager.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation

/// 存档管理器 - 负责游戏数据的本地存储和读取
class SaveManager {
    static let shared = SaveManager()
    
    // MARK: - 存档文件路径
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var saveFileURL: URL {
        return documentsDirectory.appendingPathComponent("GameSave.json")
    }
    
    private var settingsFileURL: URL {
        return documentsDirectory.appendingPathComponent("Settings.json")
    }
    
    private var statisticsFileURL: URL {
        return documentsDirectory.appendingPathComponent("Statistics.json")
    }
    
    // MARK: - 私有初始化
    private init() {
        createDirectoryIfNeeded()
    }
    
    // MARK: - 目录创建
    private func createDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: documentsDirectory.path) {
            try? FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // MARK: - 游戏存档管理
    func saveGame(_ gameData: GameSaveData) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(gameData)
            try data.write(to: saveFileURL)
            
            print("📁 游戏数据保存成功")
        } catch {
            print("❌ 游戏数据保存失败: \(error.localizedDescription)")
        }
    }
    
    func loadGame() -> GameSaveData? {
        guard FileManager.default.fileExists(atPath: saveFileURL.path) else {
            print("📁 未找到存档文件")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: saveFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let gameData = try decoder.decode(GameSaveData.self, from: data)
            
            print("📁 游戏数据读取成功")
            return gameData
        } catch {
            print("❌ 游戏数据读取失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    func hasSaveGame() -> Bool {
        return FileManager.default.fileExists(atPath: saveFileURL.path)
    }
    
    func deleteSaveGame() {
        do {
            try FileManager.default.removeItem(at: saveFileURL)
            print("📁 存档删除成功")
        } catch {
            print("❌ 存档删除失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 游戏设置管理
    func saveSettings(_ settings: GameSettings) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            try data.write(to: settingsFileURL)
            
            print("⚙️ 设置保存成功")
        } catch {
            print("❌ 设置保存失败: \(error.localizedDescription)")
        }
    }
    
    func loadSettings() -> GameSettings {
        guard FileManager.default.fileExists(atPath: settingsFileURL.path) else {
            print("⚙️ 未找到设置文件，使用默认设置")
            return GameSettings()
        }
        
        do {
            let data = try Data(contentsOf: settingsFileURL)
            let decoder = JSONDecoder()
            let settings = try decoder.decode(GameSettings.self, from: data)
            
            print("⚙️ 设置读取成功")
            return settings
        } catch {
            print("❌ 设置读取失败: \(error.localizedDescription)")
            return GameSettings()
        }
    }
    
    // MARK: - 游戏统计数据管理
    func saveStatistics(_ statistics: GameStatistics) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(statistics)
            try data.write(to: statisticsFileURL)
            
            print("📊 统计数据保存成功")
        } catch {
            print("❌ 统计数据保存失败: \(error.localizedDescription)")
        }
    }
    
    func loadStatistics() -> GameStatistics {
        guard FileManager.default.fileExists(atPath: statisticsFileURL.path) else {
            print("📊 未找到统计数据文件，创建新的统计数据")
            return GameStatistics()
        }
        
        do {
            let data = try Data(contentsOf: statisticsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let statistics = try decoder.decode(GameStatistics.self, from: data)
            
            print("📊 统计数据读取成功")
            return statistics
        } catch {
            print("❌ 统计数据读取失败: \(error.localizedDescription)")
            return GameStatistics()
        }
    }
    
    // MARK: - 存档备份和恢复
    func createBackup() -> Bool {
        guard hasSaveGame() else { return false }
        
        let backupURL = documentsDirectory.appendingPathComponent("GameSave_Backup.json")
        
        do {
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }
            try FileManager.default.copyItem(at: saveFileURL, to: backupURL)
            print("📁 备份创建成功")
            return true
        } catch {
            print("❌ 备份创建失败: \(error.localizedDescription)")
            return false
        }
    }
    
    func restoreFromBackup() -> Bool {
        let backupURL = documentsDirectory.appendingPathComponent("GameSave_Backup.json")
        
        guard FileManager.default.fileExists(atPath: backupURL.path) else {
            print("❌ 未找到备份文件")
            return false
        }
        
        do {
            if FileManager.default.fileExists(atPath: saveFileURL.path) {
                try FileManager.default.removeItem(at: saveFileURL)
            }
            try FileManager.default.copyItem(at: backupURL, to: saveFileURL)
            print("📁 备份恢复成功")
            return true
        } catch {
            print("❌ 备份恢复失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 存档信息
    func getSaveGameInfo() -> SaveGameInfo? {
        guard let gameData = loadGame() else { return nil }
        
        return SaveGameInfo(
            saveDate: gameData.saveDate,
            playerLevel: gameData.playerStats.level,
            dungeonLevel: gameData.currentLevel,
            totalScore: gameData.totalScore,
            playtime: calculatePlaytime()
        )
    }
    
    private func calculatePlaytime() -> TimeInterval {
        // 这里可以实现游戏时间计算逻辑
        // 简化实现，返回存档创建到现在的时间差
        guard let gameData = loadGame() else { return 0 }
        return Date().timeIntervalSince(gameData.saveDate)
    }
    
    // MARK: - 文件管理
    func getFileSizes() -> [String: Int64] {
        var fileSizes: [String: Int64] = [:]
        
        let files = [
            "存档文件": saveFileURL,
            "设置文件": settingsFileURL,
            "统计文件": statisticsFileURL
        ]
        
        for (name, url) in files {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    fileSizes[name] = attributes[.size] as? Int64 ?? 0
                } catch {
                    fileSizes[name] = 0
                }
            } else {
                fileSizes[name] = 0
            }
        }
        
        return fileSizes
    }
    
    func clearAllData() {
        let files = [saveFileURL, settingsFileURL, statisticsFileURL]
        
        for fileURL in files {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("📁 删除文件: \(fileURL.lastPathComponent)")
                } catch {
                    print("❌ 删除文件失败: \(fileURL.lastPathComponent)")
                }
            }
        }
    }
    
    // MARK: - iCloud同步支持 (预留)
    func enableiCloudSync() {
        // 预留iCloud同步功能
        print("📱 iCloud同步功能待实现")
    }
    
    func synciCloudData() {
        // 预留iCloud同步数据
        print("📱 iCloud数据同步待实现")
    }
}

// MARK: - 游戏设置数据结构
struct GameSettings: Codable {
    var masterVolume: Float = 1.0
    var musicVolume: Float = 0.8
    var soundEffectVolume: Float = 1.0
    var isVibrationEnabled: Bool = true
    var isAutoSaveEnabled: Bool = true
    var autoSaveInterval: TimeInterval = 30.0 // 秒
    var language: String = "zh-Hans"
    var difficultyLevel: String = "normal"
    var isFirstLaunch: Bool = true
    var tutorialCompleted: Bool = false
    var showHints: Bool = true
    var animationSpeed: Float = 1.0
    
    init() {}
}

// MARK: - 游戏统计数据结构
struct GameStatistics: Codable {
    var totalPlayTime: TimeInterval = 0
    var totalGamesPlayed: Int = 0
    var totalGamesWon: Int = 0
    var totalScore: Int = 0
    var highestScore: Int = 0
    var totalGemsMatched: Int = 0
    var totalEnemiesDefeated: Int = 0
    var totalLevelsCompleted: Int = 0
    var maxComboAchieved: Int = 0
    var totalGoldEarned: Int = 0
    var totalEquipmentObtained: Int = 0
    var totalSkillsLearned: Int = 0
    var achievementsUnlocked: [String] = []
    var lastPlayDate: Date = Date()
    var favoriteGemType: String = "red"
    var averageGameDuration: TimeInterval = 0
    
    init() {}
    
    mutating func updateGameCompleted(score: Int, duration: TimeInterval, gemsMatched: Int, enemiesDefeated: Int) {
        totalGamesPlayed += 1
        totalPlayTime += duration
        totalScore += score
        highestScore = max(highestScore, score)
        totalGemsMatched += gemsMatched
        totalEnemiesDefeated += enemiesDefeated
        lastPlayDate = Date()
        averageGameDuration = totalPlayTime / Double(totalGamesPlayed)
    }
    
    mutating func updateGameWon() {
        totalGamesWon += 1
    }
    
    var winRate: Double {
        guard totalGamesPlayed > 0 else { return 0 }
        return Double(totalGamesWon) / Double(totalGamesPlayed)
    }
}

// MARK: - 存档信息结构
struct SaveGameInfo {
    let saveDate: Date
    let playerLevel: Int
    let dungeonLevel: Int
    let totalScore: Int
    let playtime: TimeInterval
    
    var formattedSaveDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: saveDate)
    }
    
    var formattedPlaytime: String {
        let hours = Int(playtime) / 3600
        let minutes = Int(playtime) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
} 