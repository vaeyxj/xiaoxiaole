//
//  AssetManager.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import SpriteKit
import UIKit

/// 统一管理游戏中所有美术资源的管理器
/// 预留变量系统，方便未来美术资源准备好后快速替换
class AssetManager {
    static let shared = AssetManager()
    
    private init() {
        loadAssets()
    }
    
    // MARK: - 宝石纹理资源
    var gemTextures: [GemType: SKTexture] = [:]
    
    // 宝石资源名称映射（临时占位，未来替换为正式美术资源）
    private let gemAssetNames: [GemType: String] = [
        .red: "gem_red_placeholder",
        .blue: "gem_blue_placeholder", 
        .green: "gem_green_placeholder",
        .purple: "gem_purple_placeholder",
        .yellow: "gem_yellow_placeholder",
        .white: "gem_white_placeholder",
        .bomb: "gem_bomb_placeholder",
        .lightning: "gem_lightning_placeholder",
        .rainbow: "gem_rainbow_placeholder"
    ]
    
    // MARK: - 角色纹理资源
    var characterTextures: [String: SKTexture] = [:]
    
    // 角色资源名称映射
    private let characterAssetNames: [String: String] = [
        "player_idle": "player_idle_placeholder",
        "player_attack": "player_attack_placeholder",
        "player_hurt": "player_hurt_placeholder",
        "player_victory": "player_victory_placeholder"
    ]
    
    // MARK: - 敌人纹理资源
    var enemyTextures: [String: SKTexture] = [:]
    
    // 敌人资源名称映射
    private let enemyAssetNames: [String: String] = [
        "slime_green": "slime_green_placeholder",
        "slime_blue": "slime_blue_placeholder",
        "goblin_warrior": "goblin_warrior_placeholder",
        "skeleton_archer": "skeleton_archer_placeholder",
        "orc_berserker": "orc_berserker_placeholder",
        "dragon_boss": "dragon_boss_placeholder"
    ]
    
    // MARK: - UI界面纹理资源
    var uiTextures: [String: SKTexture] = [:]
    
    // UI资源名称映射
    private let uiAssetNames: [String: String] = [
        "button_normal": "button_normal_placeholder",
        "button_pressed": "button_pressed_placeholder",
        "panel_background": "panel_background_placeholder",
        "health_bar": "health_bar_placeholder",
        "mana_bar": "mana_bar_placeholder",
        "coin_icon": "coin_icon_placeholder",
        "diamond_icon": "diamond_icon_placeholder"
    ]
    
    // MARK: - 特效纹理资源
    var effectTextures: [String: SKTexture] = [:]
    
    // 特效资源名称映射
    private let effectAssetNames: [String: String] = [
        "explosion_particle": "explosion_particle_placeholder",
        "star_particle": "star_particle_placeholder",
        "heal_effect": "heal_effect_placeholder",
        "level_up_effect": "level_up_effect_placeholder"
    ]
    
    // MARK: - 装备道具纹理资源
    var equipmentTextures: [String: SKTexture] = [:]
    
    // 装备资源名称映射
    private let equipmentAssetNames: [String: String] = [
        "sword_basic": "sword_basic_placeholder",
        "sword_fire": "sword_fire_placeholder",
        "shield_wooden": "shield_wooden_placeholder",
        "shield_iron": "shield_iron_placeholder",
        "potion_health": "potion_health_placeholder",
        "potion_mana": "potion_mana_placeholder"
    ]
    
    // MARK: - 音效资源
    var soundEffects: [String: SKAction] = [:]
    
    // 音效资源名称映射
    private let soundAssetNames: [String: String] = [
        "gem_match": "gem_match_placeholder.wav",
        "gem_drop": "gem_drop_placeholder.wav",
        "enemy_hit": "enemy_hit_placeholder.wav",
        "player_hurt": "player_hurt_placeholder.wav",
        "victory": "victory_placeholder.wav",
        "game_over": "game_over_placeholder.wav",
        "button_tap": "button_tap_placeholder.wav"
    ]
    
    // MARK: - 背景音乐资源
    var backgroundMusic: [String: String] = [:]
    
    // 背景音乐资源名称映射
    private let musicAssetNames: [String: String] = [
        "menu_theme": "menu_theme_placeholder.mp3",
        "dungeon_theme": "dungeon_theme_placeholder.mp3",
        "battle_theme": "battle_theme_placeholder.mp3",
        "victory_theme": "victory_theme_placeholder.mp3"
    ]
    
    // MARK: - 颜色配置
    struct Colors {
        // 主题色彩（舒适休闲风格）
        static let primaryBlue = UIColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 1.0)
        static let primaryGreen = UIColor(red: 0.5, green: 0.8, blue: 0.6, alpha: 1.0)
        static let primaryOrange = UIColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0)
        static let primaryPurple = UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0)
        
        // UI颜色
        static let backgroundPrimary = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        static let backgroundSecondary = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        static let textPrimary = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        static let textSecondary = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        
        // 战斗UI颜色
        static let healthBarBackground = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
        static let playerHealthBar = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        static let enemyHealthBar = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        static let manaBarBackground = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        static let manaBar = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        static let panelBackground = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.7)
        static let borderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        static let textColor = UIColor.white
        
        // 战斗相关颜色
        static let combatBackground = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 0.9)
        static let normalDamage = UIColor.white
        static let criticalDamage = UIColor.yellow
        static let specialDamage = UIColor.orange
        static let healColor = UIColor.green
        static let skillButtonBackground = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 0.8)
        static let turnIndicatorBackground = UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.9)
        static let playerTurnColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 0.9)
        static let enemyTurnColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.9)
        static let logTextColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        static let comboBackground = UIColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 0.9)
        static let comboTextColor = UIColor.black
        
        // 宝石颜色（柔和版本）
        static let gemRed = UIColor(red: 0.9, green: 0.4, blue: 0.4, alpha: 1.0)
        static let gemBlue = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0)
        static let gemGreen = UIColor(red: 0.4, green: 0.8, blue: 0.5, alpha: 1.0)
        static let gemPurple = UIColor(red: 0.7, green: 0.4, blue: 0.8, alpha: 1.0)
        static let gemYellow = UIColor(red: 0.9, green: 0.8, blue: 0.3, alpha: 1.0)
        static let gemWhite = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    }
    
    // MARK: - 字体配置
    struct Fonts {
        static let titleLarge = UIFont.systemFont(ofSize: 24, weight: .bold)
        static let titleMedium = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let bodyLarge = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let bodyMedium = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let bodySmall = UIFont.systemFont(ofSize: 12, weight: .light)
        static let caption = UIFont.systemFont(ofSize: 10, weight: .light)
    }
    
    // MARK: - 字体名称配置（用于SpriteKit）
    struct FontNames {
        static let ui = "Helvetica"
        static let title = "Helvetica-Bold"
        static let body = "Helvetica"
        static let combat = "Helvetica-Bold"
    }
    
    // MARK: - 动画配置
    struct Animations {
        static let gemDropDuration: TimeInterval = 0.5
        static let gemMatchDuration: TimeInterval = 0.3
        static let enemyAttackDuration: TimeInterval = 0.8
        static let playerAttackDuration: TimeInterval = 0.6
        static let uiTransitionDuration: TimeInterval = 0.3
        static let particleLifetime: Float = 2.0
    }
    
    // MARK: - 资源加载方法
    private func loadAssets() {
        loadGemTextures()
        loadCharacterTextures()
        loadEnemyTextures()
        loadUITextures()
        loadEffectTextures()
        loadEquipmentTextures()
        loadSoundEffects()
        loadBackgroundMusic()
    }
    
    private func loadGemTextures() {
        for (gemType, assetName) in gemAssetNames {
            // 临时创建纯色纹理作为占位符
            gemTextures[gemType] = createPlaceholderTexture(for: gemType)
        }
    }
    
    private func loadCharacterTextures() {
        for (key, assetName) in characterAssetNames {
            characterTextures[key] = createPlaceholderTexture(color: .systemBlue, size: CGSize(width: 64, height: 64))
        }
    }
    
    private func loadEnemyTextures() {
        for (key, assetName) in enemyAssetNames {
            enemyTextures[key] = createPlaceholderTexture(color: .systemRed, size: CGSize(width: 48, height: 48))
        }
    }
    
    private func loadUITextures() {
        for (key, assetName) in uiAssetNames {
            uiTextures[key] = createPlaceholderTexture(color: .systemGray, size: CGSize(width: 32, height: 32))
        }
    }
    
    private func loadEffectTextures() {
        for (key, assetName) in effectAssetNames {
            effectTextures[key] = createPlaceholderTexture(color: .systemYellow, size: CGSize(width: 16, height: 16))
        }
    }
    
    private func loadEquipmentTextures() {
        for (key, assetName) in equipmentAssetNames {
            equipmentTextures[key] = createPlaceholderTexture(color: .systemBrown, size: CGSize(width: 32, height: 32))
        }
    }
    
    private func loadSoundEffects() {
        for (key, assetName) in soundAssetNames {
            // 临时创建静音的音效动作
            soundEffects[key] = SKAction.playSoundFileNamed("", waitForCompletion: false)
        }
    }
    
    private func loadBackgroundMusic() {
        backgroundMusic = musicAssetNames
    }
    
    // MARK: - 占位符纹理创建方法
    private func createPlaceholderTexture(for gemType: GemType) -> SKTexture {
        let color: UIColor
        switch gemType {
        case .red: color = Colors.gemRed
        case .blue: color = Colors.gemBlue
        case .green: color = Colors.gemGreen
        case .purple: color = Colors.gemPurple
        case .yellow: color = Colors.gemYellow
        case .white: color = Colors.gemWhite
        case .bomb: color = .systemOrange
        case .lightning: color = .systemCyan
        case .rainbow: color = .systemPink
        }
        return createPlaceholderTexture(color: color, size: CGSize(width: 32, height: 32))
    }
    
    private func createPlaceholderTexture(color: UIColor, size: CGSize) -> SKTexture {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }
    
    // MARK: - 资源获取方法
    func getGemTexture(_ gemType: GemType) -> SKTexture {
        return gemTextures[gemType] ?? createPlaceholderTexture(color: .gray, size: CGSize(width: 32, height: 32))
    }
    
    func getCharacterTexture(_ name: String) -> SKTexture {
        return characterTextures[name] ?? createPlaceholderTexture(color: .blue, size: CGSize(width: 64, height: 64))
    }
    
    func getEnemyTexture(_ name: String) -> SKTexture {
        return enemyTextures[name] ?? createPlaceholderTexture(color: .red, size: CGSize(width: 48, height: 48))
    }
    
    func getUITexture(_ name: String) -> SKTexture {
        return uiTextures[name] ?? createPlaceholderTexture(color: .gray, size: CGSize(width: 32, height: 32))
    }
    
    func getEffectTexture(_ name: String) -> SKTexture {
        return effectTextures[name] ?? createPlaceholderTexture(color: .yellow, size: CGSize(width: 16, height: 16))
    }
    
    func getEquipmentTexture(_ name: String) -> SKTexture {
        return equipmentTextures[name] ?? createPlaceholderTexture(color: .brown, size: CGSize(width: 32, height: 32))
    }
    
    func getSoundEffect(_ name: String) -> SKAction {
        return soundEffects[name] ?? SKAction()
    }
    
    func getBackgroundMusic(_ name: String) -> String {
        return backgroundMusic[name] ?? ""
    }
    
    // MARK: - 资源热更新方法（未来美术资源准备好后使用）
    func updateGemTexture(_ gemType: GemType, with imageName: String) {
        if let image = UIImage(named: imageName) {
            gemTextures[gemType] = SKTexture(image: image)
        }
    }
    
    func updateCharacterTexture(_ name: String, with imageName: String) {
        if let image = UIImage(named: imageName) {
            characterTextures[name] = SKTexture(image: image)
        }
    }
    
    func updateEnemyTexture(_ name: String, with imageName: String) {
        if let image = UIImage(named: imageName) {
            enemyTextures[name] = SKTexture(image: image)
        }
    }
} 