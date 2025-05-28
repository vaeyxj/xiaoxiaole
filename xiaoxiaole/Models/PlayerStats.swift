//
//  PlayerStats.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation

/// 玩家属性数据模型
class PlayerStats: ObservableObject, Codable {
    @Published var health: Int
    @Published var maxHealth: Int
    @Published var mana: Int
    @Published var maxMana: Int
    @Published var attack: Int
    @Published var defense: Int
    @Published var level: Int
    @Published var experience: Int
    @Published var gold: Int
    @Published var diamonds: Int
    
    // 临时属性加成
    @Published var temporaryAttackBoost: Int = 0
    @Published var temporaryDefenseBoost: Int = 0
    
    private var experienceToNextLevel: Int {
        return level * 100 // 每级需要的经验值
    }
    
    init(health: Int, maxHealth: Int, mana: Int, maxMana: Int, attack: Int, defense: Int, level: Int, experience: Int, gold: Int, diamonds: Int) {
        self.health = health
        self.maxHealth = maxHealth
        self.mana = mana
        self.maxMana = maxMana
        self.attack = attack
        self.defense = defense
        self.level = level
        self.experience = experience
        self.gold = gold
        self.diamonds = diamonds
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case health, maxHealth, mana, maxMana, attack, defense, level, experience, gold, diamonds
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        health = try container.decode(Int.self, forKey: .health)
        maxHealth = try container.decode(Int.self, forKey: .maxHealth)
        mana = try container.decode(Int.self, forKey: .mana)
        maxMana = try container.decode(Int.self, forKey: .maxMana)
        attack = try container.decode(Int.self, forKey: .attack)
        defense = try container.decode(Int.self, forKey: .defense)
        level = try container.decode(Int.self, forKey: .level)
        experience = try container.decode(Int.self, forKey: .experience)
        gold = try container.decode(Int.self, forKey: .gold)
        diamonds = try container.decode(Int.self, forKey: .diamonds)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(health, forKey: .health)
        try container.encode(maxHealth, forKey: .maxHealth)
        try container.encode(mana, forKey: .mana)
        try container.encode(maxMana, forKey: .maxMana)
        try container.encode(attack, forKey: .attack)
        try container.encode(defense, forKey: .defense)
        try container.encode(level, forKey: .level)
        try container.encode(experience, forKey: .experience)
        try container.encode(gold, forKey: .gold)
        try container.encode(diamonds, forKey: .diamonds)
    }
    
    // MARK: - 健康值管理
    func takeDamage(_ damage: Int) {
        let actualDamage = max(1, damage - (defense + temporaryDefenseBoost))
        health = max(0, health - actualDamage)
        print("❤️ 受到伤害: \(actualDamage), 剩余血量: \(health)/\(maxHealth)")
    }
    
    func restoreHealth(_ amount: Int) {
        health = min(maxHealth, health + amount)
        print("❤️ 恢复生命: \(amount), 当前血量: \(health)/\(maxHealth)")
    }
    
    func restoreMana(_ amount: Int) {
        mana = min(maxMana, mana + amount)
        print("💙 恢复法力: \(amount), 当前法力: \(mana)/\(maxMana)")
    }
    
    // MARK: - 经验和等级管理
    func gainExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
        print("⭐ 获得经验: \(amount), 当前经验: \(experience)")
    }
    
    private func checkLevelUp() {
        while experience >= experienceToNextLevel {
            experience -= experienceToNextLevel
            levelUp()
        }
    }
    
    private func levelUp() {
        level += 1
        
        // 升级时提升属性
        maxHealth += 20
        health = maxHealth // 升级时满血
        maxMana += 10
        mana = maxMana // 升级时满法力
        attack += 3
        defense += 2
        
        print("🎉 升级! 等级: \(level)")
    }
    
    // MARK: - 装备效果
    func applyEquipment(_ equipment: Equipment) {
        attack += equipment.attackBonus
        defense += equipment.defenseBonus
        maxHealth += equipment.healthBonus
        maxMana += equipment.manaBonus
        
        // 如果生命值或法力值增加，按比例恢复
        health = min(maxHealth, health + equipment.healthBonus)
        mana = min(maxMana, mana + equipment.manaBonus)
    }
    
    func removeEquipment(_ equipment: Equipment) {
        attack = max(1, attack - equipment.attackBonus)
        defense = max(0, defense - equipment.defenseBonus)
        maxHealth = max(1, maxHealth - equipment.healthBonus)
        maxMana = max(1, maxMana - equipment.manaBonus)
        
        // 确保当前值不超过最大值
        health = min(health, maxHealth)
        mana = min(mana, maxMana)
    }
    
    // MARK: - 临时效果
    func temporaryBoost() {
        temporaryAttackBoost += 5
        temporaryDefenseBoost += 3
        
        // 临时效果持续3回合（这里简化处理）
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.temporaryAttackBoost = max(0, self.temporaryAttackBoost - 5)
            self.temporaryDefenseBoost = max(0, self.temporaryDefenseBoost - 3)
        }
        
        print("✨ 临时属性提升! 攻击+5, 防御+3")
    }
    
    // MARK: - 计算属性
    var totalAttack: Int {
        return attack + temporaryAttackBoost
    }
    
    var totalDefense: Int {
        return defense + temporaryDefenseBoost
    }
    
    var healthPercentage: Float {
        return Float(health) / Float(maxHealth)
    }
    
    var manaPercentage: Float {
        return Float(mana) / Float(maxMana)
    }
    
    var experiencePercentage: Float {
        return Float(experience) / Float(experienceToNextLevel)
    }
    
    var isAlive: Bool {
        return health > 0
    }
    
    // MARK: - 描述信息
    var statusDescription: String {
        return """
        👤 等级: \(level)
        ❤️ 生命: \(health)/\(maxHealth)
        💙 法力: \(mana)/\(maxMana)
        ⚔️ 攻击: \(totalAttack)
        🛡️ 防御: \(totalDefense)
        ⭐ 经验: \(experience)/\(experienceToNextLevel)
        💰 金币: \(gold)
        💎 钻石: \(diamonds)
        """
    }
} 