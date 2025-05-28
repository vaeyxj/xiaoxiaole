//
//  GameTypes.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation

// MARK: - 宝石类型
enum GemType: CaseIterable, Codable {
    case red        // 红宝石
    case blue       // 蓝宝石
    case green      // 绿宝石
    case purple     // 紫水晶
    case yellow     // 黄玉
    case white      // 白珍珠
    case bomb       // 炸弹
    case lightning  // 闪电
    case rainbow    // 彩虹石
    
    var displayName: String {
        switch self {
        case .red: return "红宝石"
        case .blue: return "蓝宝石"
        case .green: return "绿宝石"
        case .purple: return "紫水晶"
        case .yellow: return "黄玉"
        case .white: return "白珍珠"
        case .bomb: return "炸弹"
        case .lightning: return "闪电"
        case .rainbow: return "彩虹石"
        }
    }
    
    var isSpecial: Bool {
        switch self {
        case .bomb, .lightning, .rainbow:
            return true
        default:
            return false
        }
    }
    
    static var basicGems: [GemType] {
        return [.red, .blue, .green, .purple, .yellow, .white]
    }
    
    static var specialGems: [GemType] {
        return [.bomb, .lightning, .rainbow]
    }
}

// MARK: - 游戏状态
enum GameState {
    case menu           // 主菜单
    case playing        // 游戏中
    case paused         // 暂停
    case gameOver       // 游戏结束
    case victory        // 胜利
    case shopping       // 商店
    case inventory      // 物品栏
    case settings       // 设置
}

// MARK: - 战斗状态
enum CombatState {
    case playerTurn     // 玩家回合
    case enemyTurn      // 敌人回合
    case processing     // 处理中
    case victory        // 战斗胜利
    case defeat         // 战斗失败
}

// MARK: - 敌人类型
enum EnemyType: String, CaseIterable, Codable {
    case slimeGreen = "slime_green"
    case slimeBlue = "slime_blue"
    case goblinWarrior = "goblin_warrior"
    case skeletonArcher = "skeleton_archer"
    case orcBerserker = "orc_berserker"
    case dragonBoss = "dragon_boss"
    
    var displayName: String {
        switch self {
        case .slimeGreen: return "绿色史莱姆"
        case .slimeBlue: return "蓝色史莱姆"
        case .goblinWarrior: return "哥布林战士"
        case .skeletonArcher: return "骷髅弓手"
        case .orcBerserker: return "兽人狂战士"
        case .dragonBoss: return "龙王"
        }
    }
    
    var difficulty: Int {
        switch self {
        case .slimeGreen: return 1
        case .slimeBlue: return 1
        case .goblinWarrior: return 2
        case .skeletonArcher: return 3
        case .orcBerserker: return 4
        case .dragonBoss: return 5
        }
    }
}

// MARK: - 装备类型
enum EquipmentType: String, CaseIterable, Codable {
    case weapon = "weapon"
    case armor = "armor"
    case accessory = "accessory"
    
    var displayName: String {
        switch self {
        case .weapon: return "武器"
        case .armor: return "护甲"
        case .accessory: return "饰品"
        }
    }
}

// MARK: - 装备稀有度
enum EquipmentRarity: Int, CaseIterable, Codable {
    case common = 1     // 普通
    case uncommon = 2   // 不常见
    case rare = 3       // 稀有
    case epic = 4       // 史诗
    case legendary = 5  // 传说
    
    var displayName: String {
        switch self {
        case .common: return "普通"
        case .uncommon: return "不常见"
        case .rare: return "稀有"
        case .epic: return "史诗"
        case .legendary: return "传说"
        }
    }
    
    var color: String {
        switch self {
        case .common: return "gray"
        case .uncommon: return "green"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "orange"
        }
    }
}

// MARK: - 技能类型
enum SkillType: String, CaseIterable, Codable {
    case heal = "heal"
    case attack = "attack"
    case defense = "defense"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .heal: return "治疗"
        case .attack: return "攻击"
        case .defense: return "防御"
        case .special: return "特殊"
        }
    }
    
    var icon: String {
        switch self {
        case .heal: return "❤️"
        case .attack: return "⚔️"
        case .defense: return "🛡️"
        case .special: return "✨"
        }
    }
}

// MARK: - 消除类型
enum MatchType: Codable {
    case horizontal(count: Int)  // 水平消除
    case vertical(count: Int)    // 垂直消除
    case lShape                  // L型消除
    case tShape                  // T型消除
    case square                  // 正方形消除
    
    var displayName: String {
        switch self {
        case .horizontal(let count): return "水平消除(\(count))"
        case .vertical(let count): return "垂直消除(\(count))"
        case .lShape: return "L型消除"
        case .tShape: return "T型消除"
        case .square: return "正方形消除"
        }
    }
    
    var score: Int {
        switch self {
        case .horizontal(let count): return count * 10
        case .vertical(let count): return count * 10
        case .lShape: return 50
        case .tShape: return 60
        case .square: return 80
        }
    }
}

// MARK: - 地牢事件类型
enum DungeonEventType: String, CaseIterable, Codable {
    case combat = "combat"       // 战斗
    case treasure = "treasure"   // 宝箱
    case shop = "shop"          // 商店
    case rest = "rest"          // 休息
    case elite = "elite"        // 精英怪
    case boss = "boss"          // Boss
    case random = "random"      // 随机事件
    
    var displayName: String {
        switch self {
        case .combat: return "战斗"
        case .treasure: return "宝箱"
        case .shop: return "商店"
        case .rest: return "休息"
        case .elite: return "精英怪"
        case .boss: return "Boss"
        case .random: return "随机事件"
        }
    }
}

// MARK: - 奖励类型
enum RewardType: String, CaseIterable, Codable {
    case gold = "gold"
    case experience = "experience"
    case equipment = "equipment"
    case skill = "skill"
    case health = "health"
    case mana = "mana"
    
    var displayName: String {
        switch self {
        case .gold: return "金币"
        case .experience: return "经验值"
        case .equipment: return "装备"
        case .skill: return "技能"
        case .health: return "生命值"
        case .mana: return "法力值"
        }
    }
}

// MARK: - 伤害类型
enum DamageType: Codable {
    case normal     // 普通伤害
    case critical   // 暴击伤害
    case special    // 特殊伤害
    
    var displayName: String {
        switch self {
        case .normal: return "普通"
        case .critical: return "暴击"
        case .special: return "特殊"
        }
    }
}

// MARK: - 战斗回合
enum CombatTurn: Codable {
    case player     // 玩家回合
    case enemy      // 敌人回合
    
    var displayName: String {
        switch self {
        case .player: return "玩家回合"
        case .enemy: return "敌人回合"
        }
    }
}

// MARK: - 方向
enum Direction: CaseIterable {
    case up
    case down
    case left
    case right
    
    var offset: (x: Int, y: Int) {
        switch self {
        case .up: return (0, 1)
        case .down: return (0, -1)
        case .left: return (-1, 0)
        case .right: return (1, 0)
        }
    }
}

// MARK: - 动画类型
enum AnimationType {
    case gemDrop
    case gemMatch
    case gemExplode
    case playerAttack
    case enemyAttack
    case heal
    case levelUp
    case victory
    case defeat
    
    var duration: TimeInterval {
        switch self {
        case .gemDrop: return 0.5
        case .gemMatch: return 0.3
        case .gemExplode: return 0.4
        case .playerAttack: return 0.6
        case .enemyAttack: return 0.8
        case .heal: return 0.7
        case .levelUp: return 1.2
        case .victory: return 1.5
        case .defeat: return 1.0
        }
    }
}

// MARK: - 音效类型
enum SoundType: String, CaseIterable {
    case gemMatch = "gem_match"
    case gemDrop = "gem_drop"
    case enemyHit = "enemy_hit"
    case playerHurt = "player_hurt"
    case victory = "victory"
    case gameOver = "game_over"
    case buttonTap = "button_tap"
    case levelUp = "level_up"
    case heal = "heal"
    case explosion = "explosion"
    
    var displayName: String {
        switch self {
        case .gemMatch: return "宝石消除"
        case .gemDrop: return "宝石掉落"
        case .enemyHit: return "攻击敌人"
        case .playerHurt: return "玩家受伤"
        case .victory: return "胜利"
        case .gameOver: return "游戏结束"
        case .buttonTap: return "按钮点击"
        case .levelUp: return "升级"
        case .heal: return "治疗"
        case .explosion: return "爆炸"
        }
    }
} 