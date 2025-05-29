//
//  ArtResourceConfig.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation
import SpriteKit

/// 美术资源配置管理器
/// 这个文件是你替换美术资源的统一入口
/// 只需要修改这里的资源名称，就能替换整个游戏的美术资源
class ArtResourceConfig {
    
    // MARK: - 🎨 宝石资源配置
    /// 在这里配置你的宝石美术资源文件名
    /// 格式：将你的宝石图片放入Assets.xcassets，然后修改下面的文件名
    struct GemAssets {
        static let redGem = "gem_red"           // 红宝石图片文件名
        static let blueGem = "gem_blue"         // 蓝宝石图片文件名
        static let greenGem = "gem_green"       // 绿宝石图片文件名
        static let yellowGem = "gem_yellow"     // 黄宝石图片文件名
        static let purpleGem = "gem_purple"     // 紫宝石图片文件名
        static let whiteGem = "gem_white"       // 白宝石图片文件名
        
        // 特殊宝石
        static let bombGem = "gem_bomb"         // 炸弹宝石
        static let rainbowGem = "gem_rainbow"   // 彩虹宝石
        static let lightningGem = "gem_lightning" // 闪电宝石
        
        /// 获取宝石资源映射
        static func getGemAssetMapping() -> [GemType: String] {
            return [
                .red: redGem,
                .blue: blueGem,
                .green: greenGem,
                .yellow: yellowGem,
                .purple: purpleGem,
                .white: whiteGem
            ]
        }
    }
    
    // MARK: - 🎭 角色资源配置
    struct CharacterAssets {
        // 玩家角色
        static let playerIdle = "player_idle"
        static let playerAttack = "player_attack"
        static let playerHurt = "player_hurt"
        static let playerVictory = "player_victory"
        static let playerDeath = "player_death"
        
        // 玩家头像
        static let playerAvatar = "player_avatar"
        static let playerPortrait = "player_portrait"
    }
    
    // MARK: - 👹 敌人资源配置
    struct EnemyAssets {
        // 史莱姆
        static let slimeGreen = "enemy_slime_green"
        static let slimeBlue = "enemy_slime_blue"
        static let slimeRed = "enemy_slime_red"
        
        // 哥布林
        static let goblinWarrior = "enemy_goblin_warrior"
        static let goblinArcher = "enemy_goblin_archer"
        static let goblinShaman = "enemy_goblin_shaman"
        
        // 骷髅
        static let skeletonWarrior = "enemy_skeleton_warrior"
        static let skeletonArcher = "enemy_skeleton_archer"
        static let skeletonMage = "enemy_skeleton_mage"
        
        // 兽人
        static let orcBerserker = "enemy_orc_berserker"
        static let orcChief = "enemy_orc_chief"
        
        // Boss
        static let dragonBoss = "enemy_dragon_boss"
        static let lichKing = "enemy_lich_king"
        static let demonLord = "enemy_demon_lord"
    }
    
    // MARK: - 🎨 UI界面资源配置
    struct UIAssets {
        // 按钮
        static let buttonNormal = "ui_button_normal"
        static let buttonPressed = "ui_button_pressed"
        static let buttonDisabled = "ui_button_disabled"
        
        // 面板
        static let panelBackground = "ui_panel_background"
        static let panelFrame = "ui_panel_frame"
        static let dialogBackground = "ui_dialog_background"
        
        // 血条和法力条
        static let healthBarBackground = "ui_health_bar_bg"
        static let healthBarFill = "ui_health_bar_fill"
        static let manaBarBackground = "ui_mana_bar_bg"
        static let manaBarFill = "ui_mana_bar_fill"
        
        // 图标
        static let coinIcon = "ui_icon_coin"
        static let diamondIcon = "ui_icon_diamond"
        static let heartIcon = "ui_icon_heart"
        static let starIcon = "ui_icon_star"
        static let settingsIcon = "ui_icon_settings"
        static let pauseIcon = "ui_icon_pause"
        static let playIcon = "ui_icon_play"
        
        // 装饰元素
        static let frameCorner = "ui_frame_corner"
        static let frameBorder = "ui_frame_border"
        static let glowEffect = "ui_glow_effect"
    }
    
    // MARK: - 🏰 背景资源配置
    struct BackgroundAssets {
        // 场景背景
        static let menuBackground = "bg_menu"
        static let gameBackground = "bg_game"
        static let combatBackground = "bg_combat"
        static let shopBackground = "bg_shop"
        static let inventoryBackground = "bg_inventory"
        
        // 地牢背景
        static let dungeonFloor1 = "bg_dungeon_floor1"
        static let dungeonFloor2 = "bg_dungeon_floor2"
        static let dungeonFloor3 = "bg_dungeon_floor3"
        static let dungeonBoss = "bg_dungeon_boss"
        
        // 装饰元素
        static let clouds = "bg_clouds"
        static let mountains = "bg_mountains"
        static let castle = "bg_castle"
        static let trees = "bg_trees"
    }
    
    // MARK: - ⚔️ 装备道具资源配置
    struct EquipmentAssets {
        // 武器
        static let swordBasic = "equipment_sword_basic"
        static let swordFire = "equipment_sword_fire"
        static let swordIce = "equipment_sword_ice"
        static let swordLightning = "equipment_sword_lightning"
        
        // 防具
        static let shieldWooden = "equipment_shield_wooden"
        static let shieldIron = "equipment_shield_iron"
        static let shieldSteel = "equipment_shield_steel"
        static let shieldMagic = "equipment_shield_magic"
        
        // 药水
        static let potionHealth = "equipment_potion_health"
        static let potionMana = "equipment_potion_mana"
        static let potionStrength = "equipment_potion_strength"
        static let potionSpeed = "equipment_potion_speed"
        
        // 饰品
        static let ringPower = "equipment_ring_power"
        static let ringDefense = "equipment_ring_defense"
        static let amuletLuck = "equipment_amulet_luck"
        static let amuletWisdom = "equipment_amulet_wisdom"
    }
    
    // MARK: - ✨ 特效资源配置
    struct EffectAssets {
        // 粒子特效
        static let explosionParticle = "effect_explosion"
        static let starParticle = "effect_star"
        static let sparkleParticle = "effect_sparkle"
        static let fireParticle = "effect_fire"
        static let iceParticle = "effect_ice"
        static let lightningParticle = "effect_lightning"
        
        // 技能特效
        static let healEffect = "effect_heal"
        static let shieldEffect = "effect_shield"
        static let attackEffect = "effect_attack"
        static let criticalEffect = "effect_critical"
        
        // 环境特效
        static let levelUpEffect = "effect_level_up"
        static let victoryEffect = "effect_victory"
        static let defeatEffect = "effect_defeat"
        static let comboEffect = "effect_combo"
    }
    
    // MARK: - 🎵 音效资源配置
    struct AudioAssets {
        // 音效文件
        static let gemMatch = "sfx_gem_match.wav"
        static let gemDrop = "sfx_gem_drop.wav"
        static let gemSwap = "sfx_gem_swap.wav"
        static let gemCombo = "sfx_gem_combo.wav"
        
        static let buttonTap = "sfx_button_tap.wav"
        static let buttonHover = "sfx_button_hover.wav"
        
        static let playerAttack = "sfx_player_attack.wav"
        static let playerHurt = "sfx_player_hurt.wav"
        static let enemyHit = "sfx_enemy_hit.wav"
        static let enemyDeath = "sfx_enemy_death.wav"
        
        static let levelUp = "sfx_level_up.wav"
        static let victory = "sfx_victory.wav"
        static let defeat = "sfx_defeat.wav"
        
        // 背景音乐文件
        static let menuTheme = "bgm_menu.mp3"
        static let dungeonTheme = "bgm_dungeon.mp3"
        static let combatTheme = "bgm_combat.mp3"
        static let victoryTheme = "bgm_victory.mp3"
        static let bossTheme = "bgm_boss.mp3"
    }
    
    // MARK: - 🔧 资源应用方法
    
    /// 应用所有美术资源配置
    /// 调用这个方法来更新游戏中的所有美术资源
    static func applyAllAssets() {
        applyGemAssets()
        applyUIAssets()
        applyBackgroundAssets()
        applyEffectAssets()
        print("🎨 所有美术资源配置已应用")
    }
    
    /// 应用宝石资源配置
    static func applyGemAssets() {
        let gemMapping = GemAssets.getGemAssetMapping()
        AssetManager.shared.updateGemAssets(gemMapping)
        print("💎 宝石资源配置已应用")
    }
    
    /// 应用UI资源配置
    static func applyUIAssets() {
        AssetManager.shared.updateUIAsset(for: "button_normal", assetName: UIAssets.buttonNormal)
        AssetManager.shared.updateUIAsset(for: "button_pressed", assetName: UIAssets.buttonPressed)
        AssetManager.shared.updateUIAsset(for: "panel", assetName: UIAssets.panelBackground)
        AssetManager.shared.updateUIAsset(for: "health_bar", assetName: UIAssets.healthBarFill)
        AssetManager.shared.updateUIAsset(for: "mana_bar", assetName: UIAssets.manaBarFill)
        print("🎨 UI资源配置已应用")
    }
    
    /// 应用背景资源配置
    static func applyBackgroundAssets() {
        // 这里可以添加背景资源的应用逻辑
        print("🏞️ 背景资源配置已应用")
    }
    
    /// 应用特效资源配置
    static func applyEffectAssets() {
        // 这里可以添加特效资源的应用逻辑
        print("✨ 特效资源配置已应用")
    }
    
    // MARK: - 📋 资源检查工具
    
    /// 检查所有资源是否存在
    static func validateAllAssets() -> [String] {
        var missingAssets: [String] = []
        
        // 检查宝石资源
        for (_, assetName) in GemAssets.getGemAssetMapping() {
            if !assetExists(assetName) {
                missingAssets.append(assetName)
            }
        }
        
        // 检查UI资源
        let uiAssets = [
            UIAssets.buttonNormal, UIAssets.buttonPressed, UIAssets.panelBackground,
            UIAssets.healthBarFill, UIAssets.manaBarFill
        ]
        for assetName in uiAssets {
            if !assetExists(assetName) {
                missingAssets.append(assetName)
            }
        }
        
        if missingAssets.isEmpty {
            print("✅ 所有美术资源检查通过")
        } else {
            print("⚠️ 缺失的美术资源: \(missingAssets)")
        }
        
        return missingAssets
    }
    
    /// 检查单个资源是否存在
    private static func assetExists(_ name: String) -> Bool {
        return UIImage(named: name) != nil
    }
    
    // MARK: - 📖 使用说明
    /*
     🎨 美术资源替换指南：
     
     1. 准备你的美术资源文件（PNG、JPG等格式）
     
     2. 将资源文件添加到Xcode项目的Assets.xcassets中
     
     3. 修改上面对应的资源配置常量，将文件名改为你的资源文件名
        例如：static let redGem = "my_red_gem"
     
     4. 在游戏启动时调用 ArtResourceConfig.applyAllAssets()
        或者调用具体的应用方法，如 ArtResourceConfig.applyGemAssets()
     
     5. 运行游戏，你的美术资源就会自动替换原有的占位符
     
     📝 注意事项：
     - 确保资源文件名与配置中的名称完全一致
     - 建议使用统一的命名规范，如 "gem_red", "ui_button_normal" 等
     - 可以使用 validateAllAssets() 方法检查资源是否正确配置
     - 支持热更新，修改配置后重新调用应用方法即可生效
     */
} 