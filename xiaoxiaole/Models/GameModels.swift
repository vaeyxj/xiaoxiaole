//
//  GameModels.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation
import SpriteKit

// MARK: - 敌人模型
class Enemy: ObservableObject, Codable {
    let id = UUID()
    var name: String
    var type: EnemyType
    @Published var health: Int
    var maxHealth: Int
    var attack: Int
    var defense: Int
    var experience: Int
    var goldReward: Int
    var gemWeakness: GemType?
    var specialAbility: String?
    
    init(name: String, type: EnemyType, health: Int, attack: Int, defense: Int, experience: Int, goldReward: Int, gemWeakness: GemType? = nil, specialAbility: String? = nil) {
        self.name = name
        self.type = type
        self.health = health
        self.maxHealth = health
        self.attack = attack
        self.defense = defense
        self.experience = experience
        self.goldReward = goldReward
        self.gemWeakness = gemWeakness
        self.specialAbility = specialAbility
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name, type, health, maxHealth, attack, defense, experience, goldReward, gemWeakness, specialAbility
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(EnemyType.self, forKey: .type)
        health = try container.decode(Int.self, forKey: .health)
        maxHealth = try container.decode(Int.self, forKey: .maxHealth)
        attack = try container.decode(Int.self, forKey: .attack)
        defense = try container.decode(Int.self, forKey: .defense)
        experience = try container.decode(Int.self, forKey: .experience)
        goldReward = try container.decode(Int.self, forKey: .goldReward)
        gemWeakness = try container.decodeIfPresent(GemType.self, forKey: .gemWeakness)
        specialAbility = try container.decodeIfPresent(String.self, forKey: .specialAbility)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(health, forKey: .health)
        try container.encode(maxHealth, forKey: .maxHealth)
        try container.encode(attack, forKey: .attack)
        try container.encode(defense, forKey: .defense)
        try container.encode(experience, forKey: .experience)
        try container.encode(goldReward, forKey: .goldReward)
        try container.encodeIfPresent(gemWeakness, forKey: .gemWeakness)
        try container.encodeIfPresent(specialAbility, forKey: .specialAbility)
    }
    
    func takeDamage(_ damage: Int) {
        let actualDamage = max(1, damage - defense)
        health = max(0, health - actualDamage)
    }
    
    var healthPercentage: Float {
        return Float(health) / Float(maxHealth)
    }
    
    var isAlive: Bool {
        return health > 0
    }
}

// MARK: - 装备模型
class Equipment: ObservableObject, Codable, Identifiable {
    let id = UUID()
    var name: String
    var type: EquipmentType
    var rarity: EquipmentRarity
    var attackBonus: Int
    var defenseBonus: Int
    var healthBonus: Int
    var manaBonus: Int
    var specialEffect: String?
    var isEquipped: Bool = false
    var price: Int
    
    init(name: String, type: EquipmentType, rarity: EquipmentRarity, attackBonus: Int = 0, defenseBonus: Int = 0, healthBonus: Int = 0, manaBonus: Int = 0, specialEffect: String? = nil, price: Int = 0) {
        self.name = name
        self.type = type
        self.rarity = rarity
        self.attackBonus = attackBonus
        self.defenseBonus = defenseBonus
        self.healthBonus = healthBonus
        self.manaBonus = manaBonus
        self.specialEffect = specialEffect
        self.price = price
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name, type, rarity, attackBonus, defenseBonus, healthBonus, manaBonus, specialEffect, isEquipped, price
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(EquipmentType.self, forKey: .type)
        rarity = try container.decode(EquipmentRarity.self, forKey: .rarity)
        attackBonus = try container.decode(Int.self, forKey: .attackBonus)
        defenseBonus = try container.decode(Int.self, forKey: .defenseBonus)
        healthBonus = try container.decode(Int.self, forKey: .healthBonus)
        manaBonus = try container.decode(Int.self, forKey: .manaBonus)
        specialEffect = try container.decodeIfPresent(String.self, forKey: .specialEffect)
        isEquipped = try container.decode(Bool.self, forKey: .isEquipped)
        price = try container.decode(Int.self, forKey: .price)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(rarity, forKey: .rarity)
        try container.encode(attackBonus, forKey: .attackBonus)
        try container.encode(defenseBonus, forKey: .defenseBonus)
        try container.encode(healthBonus, forKey: .healthBonus)
        try container.encode(manaBonus, forKey: .manaBonus)
        try container.encodeIfPresent(specialEffect, forKey: .specialEffect)
        try container.encode(isEquipped, forKey: .isEquipped)
        try container.encode(price, forKey: .price)
    }
    
    var description: String {
        var desc = "\(name) (\(rarity.displayName))\n"
        if attackBonus > 0 { desc += "攻击: +\(attackBonus)\n" }
        if defenseBonus > 0 { desc += "防御: +\(defenseBonus)\n" }
        if healthBonus > 0 { desc += "生命: +\(healthBonus)\n" }
        if manaBonus > 0 { desc += "法力: +\(manaBonus)\n" }
        if let effect = specialEffect { desc += "特效: \(effect)\n" }
        return desc
    }
}

// MARK: - 技能模型
class Skill: ObservableObject, Codable, Identifiable {
    let id = UUID()
    var name: String
    var type: SkillType
    var description: String
    var manaCost: Int
    var cooldown: Int
    var currentCooldown: Int = 0
    var level: Int = 1
    var maxLevel: Int = 5
    
    init(name: String, type: SkillType, description: String, manaCost: Int, cooldown: Int = 0) {
        self.name = name
        self.type = type
        self.description = description
        self.manaCost = manaCost
        self.cooldown = cooldown
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name, type, description, manaCost, cooldown, currentCooldown, level, maxLevel
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(SkillType.self, forKey: .type)
        description = try container.decode(String.self, forKey: .description)
        manaCost = try container.decode(Int.self, forKey: .manaCost)
        cooldown = try container.decode(Int.self, forKey: .cooldown)
        currentCooldown = try container.decode(Int.self, forKey: .currentCooldown)
        level = try container.decode(Int.self, forKey: .level)
        maxLevel = try container.decode(Int.self, forKey: .maxLevel)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(description, forKey: .description)
        try container.encode(manaCost, forKey: .manaCost)
        try container.encode(cooldown, forKey: .cooldown)
        try container.encode(currentCooldown, forKey: .currentCooldown)
        try container.encode(level, forKey: .level)
        try container.encode(maxLevel, forKey: .maxLevel)
    }
    
    func activate(on player: PlayerStats, enemy: Enemy?) {
        switch type {
        case .heal:
            let healAmount = 20 + (level * 5)
            player.restoreHealth(healAmount)
        case .attack:
            if let enemy = enemy {
                let damage = 15 + (level * 3)
                enemy.takeDamage(damage)
            }
        case .defense:
            player.temporaryBoost()
        case .special:
            // 特殊技能效果
            break
        }
        
        currentCooldown = cooldown
    }
    
    var isAvailable: Bool {
        return currentCooldown == 0
    }
    
    func reduceCooldown() {
        currentCooldown = max(0, currentCooldown - 1)
    }
}

// MARK: - 地牢模型
struct Dungeon: Codable {
    let id = UUID()
    var level: Int
    var floors: [DungeonFloor]
    var theme: String
    var name: String
    
    init(level: Int, floors: [DungeonFloor], theme: String = "基础地牢") {
        self.level = level
        self.floors = floors
        self.theme = theme
        self.name = "\(theme) - 第\(level)层"
    }
}

// MARK: - 地牢楼层模型
struct DungeonFloor: Codable {
    let id = UUID()
    var floorNumber: Int
    var eventType: DungeonEventType
    var enemy: Enemy?
    var rewards: [Reward]
    var isCompleted: Bool = false
    var nextFloorOptions: [DungeonEventType] = []
    
    init(floorNumber: Int, eventType: DungeonEventType, enemy: Enemy? = nil, rewards: [Reward] = []) {
        self.floorNumber = floorNumber
        self.eventType = eventType
        self.enemy = enemy
        self.rewards = rewards
    }
}

// MARK: - 奖励模型
struct Reward: Codable, Identifiable {
    let id = UUID()
    var type: RewardType
    var amount: Int
    var equipment: Equipment?
    var skill: Skill?
    
    init(type: RewardType, amount: Int = 0, equipment: Equipment? = nil, skill: Skill? = nil) {
        self.type = type
        self.amount = amount
        self.equipment = equipment
        self.skill = skill
    }
    
    var description: String {
        switch type {
        case .gold:
            return "金币 x\(amount)"
        case .experience:
            return "经验值 x\(amount)"
        case .health:
            return "生命值 x\(amount)"
        case .mana:
            return "法力值 x\(amount)"
        case .equipment:
            return equipment?.name ?? "未知装备"
        case .skill:
            return skill?.name ?? "未知技能"
        }
    }
}

// MARK: - 宝石模型
struct Gem: Codable, Identifiable {
    let id = UUID()
    var type: GemType
    var position: GridPosition
    var isMatched: Bool = false
    var isSpecial: Bool
    
    init(type: GemType, position: GridPosition) {
        self.type = type
        self.position = position
        self.isSpecial = type.isSpecial
    }
}

// MARK: - 网格位置
struct GridPosition: Codable, Equatable {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    func distance(to other: GridPosition) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
    
    func neighbors(in boardSize: Int) -> [GridPosition] {
        var neighbors: [GridPosition] = []
        
        for direction in Direction.allCases {
            let offset = direction.offset
            let newPos = GridPosition(x + offset.x, y + offset.y)
            
            if newPos.x >= 0 && newPos.x < boardSize && newPos.y >= 0 && newPos.y < boardSize {
                neighbors.append(newPos)
            }
        }
        
        return neighbors
    }
}

// MARK: - 消除匹配
struct Match: Codable {
    var gems: [GridPosition]
    var type: MatchType
    var gemType: GemType
    
    init(gems: [GridPosition], type: MatchType, gemType: GemType) {
        self.gems = gems
        self.type = type
        self.gemType = gemType
    }
    
    var count: Int {
        return gems.count
    }
}

// MARK: - 游戏存档数据
struct GameSaveData: Codable {
    var playerStats: PlayerStats
    var currentLevel: Int
    var currentFloor: Int
    var totalScore: Int
    var maxCombo: Int
    var inventory: [Equipment]
    var skills: [Skill]
    var saveDate: Date = Date()
    
    init(playerStats: PlayerStats, currentLevel: Int, currentFloor: Int, totalScore: Int, maxCombo: Int, inventory: [Equipment], skills: [Skill]) {
        self.playerStats = playerStats
        self.currentLevel = currentLevel
        self.currentFloor = currentFloor
        self.totalScore = totalScore
        self.maxCombo = maxCombo
        self.inventory = inventory
        self.skills = skills
    }
} 