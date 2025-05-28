//
//  DungeonGenerator.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation
import GameplayKit

/// 地牢生成系统 - 负责随机生成地牢内容，实现Roguelike的随机性
class DungeonGenerator {
    
    // MARK: - 随机数生成器
    private let randomSource = GKRandomSource.sharedRandom()
    
    // MARK: - 配置参数
    private let floorsPerDungeon = 15
    private let minCombatFloors = 8
    private let maxEliteFloors = 3
    private let bossFloorNumber = 15
    
    // MARK: - 地牢生成
    func generateDungeon(level: Int) -> Dungeon {
        var floors: [DungeonFloor] = []
        
        // 生成所有楼层
        for floorNumber in 1...floorsPerDungeon {
            let floor = generateFloor(floorNumber: floorNumber, dungeonLevel: level)
            floors.append(floor)
        }
        
        let theme = selectDungeonTheme(for: level)
        return Dungeon(level: level, floors: floors, theme: theme)
    }
    
    // MARK: - 楼层生成
    private func generateFloor(floorNumber: Int, dungeonLevel: Int) -> DungeonFloor {
        let eventType = selectEventType(for: floorNumber)
        var floor = DungeonFloor(floorNumber: floorNumber, eventType: eventType)
        
        switch eventType {
        case .combat:
            floor.enemy = generateEnemy(for: dungeonLevel, isElite: false)
            floor.rewards = generateCombatRewards(dungeonLevel: dungeonLevel)
            
        case .elite:
            floor.enemy = generateEnemy(for: dungeonLevel, isElite: true)
            floor.rewards = generateEliteRewards(dungeonLevel: dungeonLevel)
            
        case .boss:
            floor.enemy = generateBoss(for: dungeonLevel)
            floor.rewards = generateBossRewards(dungeonLevel: dungeonLevel)
            
        case .treasure:
            floor.rewards = generateTreasureRewards(dungeonLevel: dungeonLevel)
            
        case .shop:
            // 商店不需要敌人和奖励，由商店系统处理
            break
            
        case .rest:
            floor.rewards = [Reward(type: .health, amount: 30)]
            
        case .random:
            floor = generateRandomEvent(floorNumber: floorNumber, dungeonLevel: dungeonLevel)
        }
        
        return floor
    }
    
    // MARK: - 事件类型选择
    private func selectEventType(for floorNumber: Int) -> DungeonEventType {
        // Boss层固定
        if floorNumber == bossFloorNumber {
            return .boss
        }
        
        // 第一层不会是精英或Boss
        if floorNumber == 1 {
            return .combat
        }
        
        // 根据楼层数和概率选择事件类型
        let weights: [DungeonEventType: Int] = [
            .combat: 40,
            .treasure: 15,
            .shop: 10,
            .rest: 8,
            .elite: floorNumber > 5 ? 12 : 0,
            .random: 15
        ]
        
        return selectRandomEvent(with: weights)
    }
    
    private func selectRandomEvent(with weights: [DungeonEventType: Int]) -> DungeonEventType {
        let totalWeight = weights.values.reduce(0, +)
        let randomValue = randomSource.nextInt(upperBound: totalWeight)
        
        var currentWeight = 0
        for (eventType, weight) in weights {
            currentWeight += weight
            if randomValue < currentWeight {
                return eventType
            }
        }
        
        return .combat // 默认返回战斗
    }
    
    // MARK: - 敌人生成
    func generateEnemy(for dungeonLevel: Int, isElite: Bool = false) -> Enemy {
        let baseHealth = 30 + (dungeonLevel * 10)
        let baseAttack = 8 + (dungeonLevel * 2)
        let baseDefense = 2 + (dungeonLevel * 1)
        let baseExp = 15 + (dungeonLevel * 5)
        let baseGold = 10 + (dungeonLevel * 3)
        
        // 精英怪属性加强
        let multiplier: Float = isElite ? 1.5 : 1.0
        
        let health = Int(Float(baseHealth) * multiplier)
        let attack = Int(Float(baseAttack) * multiplier)
        let defense = Int(Float(baseDefense) * multiplier)
        let exp = Int(Float(baseExp) * multiplier)
        let gold = Int(Float(baseGold) * multiplier)
        
        // 随机选择敌人类型
        let enemyType = selectEnemyType(for: dungeonLevel, isElite: isElite)
        let enemy = Enemy(
            name: generateEnemyName(type: enemyType, isElite: isElite),
            type: enemyType,
            health: health,
            attack: attack,
            defense: defense,
            experience: exp,
            goldReward: gold,
            gemWeakness: selectRandomGemWeakness(),
            specialAbility: isElite ? generateSpecialAbility() : nil
        )
        
        return enemy
    }
    
    func generateBoss(for dungeonLevel: Int) -> Enemy {
        let health = 100 + (dungeonLevel * 25)
        let attack = 15 + (dungeonLevel * 4)
        let defense = 5 + (dungeonLevel * 2)
        let exp = 50 + (dungeonLevel * 15)
        let gold = 50 + (dungeonLevel * 10)
        
        return Enemy(
            name: "龙王·毁灭者",
            type: .dragonBoss,
            health: health,
            attack: attack,
            defense: defense,
            experience: exp,
            goldReward: gold,
            specialAbility: "龙息攻击"
        )
    }
    
    // MARK: - 敌人类型和名称
    private func selectEnemyType(for dungeonLevel: Int, isElite: Bool) -> EnemyType {
        if isElite {
            // 精英怪从高级敌人中选择
            let eliteTypes: [EnemyType] = [.goblinWarrior, .skeletonArcher, .orcBerserker]
            return eliteTypes.randomElement() ?? .goblinWarrior
        }
        
        // 根据地牢等级选择合适的敌人
        switch dungeonLevel {
        case 1...2:
            return [.slimeGreen, .slimeBlue].randomElement() ?? .slimeGreen
        case 3...4:
            return [.slimeGreen, .slimeBlue, .goblinWarrior].randomElement() ?? .goblinWarrior
        case 5...7:
            return [.goblinWarrior, .skeletonArcher].randomElement() ?? .goblinWarrior
        default:
            return EnemyType.allCases.filter { $0 != .dragonBoss }.randomElement() ?? .orcBerserker
        }
    }
    
    private func generateEnemyName(type: EnemyType, isElite: Bool) -> String {
        let prefix = isElite ? "精英·" : ""
        return prefix + type.displayName
    }
    
    private func selectRandomGemWeakness() -> GemType? {
        // 30% 概率有宝石弱点
        guard randomSource.nextUniform() < 0.3 else { return nil }
        return GemType.basicGems.randomElement()
    }
    
    private func generateSpecialAbility() -> String {
        let abilities = [
            "狂暴攻击", "治疗光环", "护甲强化", "魔法反射", "连续攻击", "生命汲取"
        ]
        return abilities.randomElement() ?? "未知能力"
    }
    
    // MARK: - 奖励生成
    private func generateCombatRewards(dungeonLevel: Int) -> [Reward] {
        var rewards: [Reward] = []
        
        // 基础金币奖励
        let goldAmount = 5 + randomSource.nextInt(upperBound: dungeonLevel * 3)
        rewards.append(Reward(type: .gold, amount: goldAmount))
        
        // 有机会获得装备
        if randomSource.nextUniform() < 0.2 {
            let equipment = generateRandomEquipment(for: dungeonLevel)
            rewards.append(Reward(type: .equipment, equipment: equipment))
        }
        
        return rewards
    }
    
    private func generateEliteRewards(dungeonLevel: Int) -> [Reward] {
        var rewards: [Reward] = []
        
        // 更多金币
        let goldAmount = 15 + randomSource.nextInt(upperBound: dungeonLevel * 5)
        rewards.append(Reward(type: .gold, amount: goldAmount))
        
        // 必定掉落装备
        let equipment = generateRandomEquipment(for: dungeonLevel, minRarity: .uncommon)
        rewards.append(Reward(type: .equipment, equipment: equipment))
        
        // 有机会获得技能
        if randomSource.nextUniform() < 0.3 {
            let skill = generateRandomSkill()
            rewards.append(Reward(type: .skill, skill: skill))
        }
        
        return rewards
    }
    
    private func generateBossRewards(dungeonLevel: Int) -> [Reward] {
        var rewards: [Reward] = []
        
        // 大量金币
        let goldAmount = 50 + randomSource.nextInt(upperBound: dungeonLevel * 10)
        rewards.append(Reward(type: .gold, amount: goldAmount))
        
        // 高级装备
        let equipment = generateRandomEquipment(for: dungeonLevel, minRarity: .rare)
        rewards.append(Reward(type: .equipment, equipment: equipment))
        
        // 技能
        let skill = generateRandomSkill()
        rewards.append(Reward(type: .skill, skill: skill))
        
        return rewards
    }
    
    private func generateTreasureRewards(dungeonLevel: Int) -> [Reward] {
        var rewards: [Reward] = []
        
        // 随机奖励类型
        let rewardTypes: [RewardType] = [.gold, .equipment, .skill]
        let selectedType = rewardTypes.randomElement() ?? .gold
        
        switch selectedType {
        case .gold:
            let goldAmount = 20 + randomSource.nextInt(upperBound: dungeonLevel * 8)
            rewards.append(Reward(type: .gold, amount: goldAmount))
        case .equipment:
            let equipment = generateRandomEquipment(for: dungeonLevel)
            rewards.append(Reward(type: .equipment, equipment: equipment))
        case .skill:
            let skill = generateRandomSkill()
            rewards.append(Reward(type: .skill, skill: skill))
        default:
            break
        }
        
        return rewards
    }
    
    // MARK: - 装备生成
    func generateRandomEquipment(for dungeonLevel: Int, minRarity: EquipmentRarity = .common) -> Equipment {
        let rarity = selectEquipmentRarity(dungeonLevel: dungeonLevel, minRarity: minRarity)
        let type = EquipmentType.allCases.randomElement() ?? .weapon
        
        let (name, attackBonus, defenseBonus, healthBonus, manaBonus, specialEffect, price) = generateEquipmentStats(
            type: type,
            rarity: rarity,
            dungeonLevel: dungeonLevel
        )
        
        return Equipment(
            name: name,
            type: type,
            rarity: rarity,
            attackBonus: attackBonus,
            defenseBonus: defenseBonus,
            healthBonus: healthBonus,
            manaBonus: manaBonus,
            specialEffect: specialEffect,
            price: price
        )
    }
    
    private func selectEquipmentRarity(dungeonLevel: Int, minRarity: EquipmentRarity) -> EquipmentRarity {
        let weights: [EquipmentRarity: Int] = [
            .common: max(0, 50 - dungeonLevel * 5),
            .uncommon: 30 + dungeonLevel * 2,
            .rare: 15 + dungeonLevel * 3,
            .epic: max(0, dungeonLevel * 2 - 10),
            .legendary: max(0, dungeonLevel - 15)
        ]
        
        let availableRarities = weights.filter { $0.key.rawValue >= minRarity.rawValue && $0.value > 0 }
        
        let totalWeight = availableRarities.values.reduce(0, +)
        let randomValue = randomSource.nextInt(upperBound: totalWeight)
        
        var currentWeight = 0
        for (rarity, weight) in availableRarities {
            currentWeight += weight
            if randomValue < currentWeight {
                return rarity
            }
        }
        
        return minRarity
    }
    
    private func generateEquipmentStats(type: EquipmentType, rarity: EquipmentRarity, dungeonLevel: Int) -> (String, Int, Int, Int, Int, String?, Int) {
        let multiplier = Float(rarity.rawValue)
        let baseValue = 2 + dungeonLevel
        
        var attackBonus = 0
        var defenseBonus = 0
        var healthBonus = 0
        var manaBonus = 0
        var specialEffect: String?
        
        switch type {
        case .weapon:
            attackBonus = Int(Float(baseValue) * multiplier)
            if rarity.rawValue >= 3 {
                specialEffect = "攻击时有10%几率造成双倍伤害"
            }
        case .armor:
            defenseBonus = Int(Float(baseValue) * multiplier * 0.8)
            healthBonus = Int(Float(baseValue) * multiplier * 2)
            if rarity.rawValue >= 3 {
                specialEffect = "受到攻击时有15%几率减少50%伤害"
            }
        case .accessory:
            manaBonus = Int(Float(baseValue) * multiplier * 1.5)
            healthBonus = Int(Float(baseValue) * multiplier * 0.5)
            if rarity.rawValue >= 3 {
                specialEffect = "每回合恢复5点法力值"
            }
        }
        
        let name = generateEquipmentName(type: type, rarity: rarity)
        let price = (attackBonus + defenseBonus + healthBonus + manaBonus) * rarity.rawValue * 5
        
        return (name, attackBonus, defenseBonus, healthBonus, manaBonus, specialEffect, price)
    }
    
    private func generateEquipmentName(type: EquipmentType, rarity: EquipmentRarity) -> String {
        let rarityPrefix: [EquipmentRarity: String] = [
            EquipmentRarity.common: "",
            EquipmentRarity.uncommon: "强化",
            EquipmentRarity.rare: "精良",
            EquipmentRarity.epic: "史诗",
            EquipmentRarity.legendary: "传说"
        ]
        
        let typeNames: [EquipmentType: [String]] = [
            EquipmentType.weapon: ["短剑", "长剑", "法杖", "弓箭", "战斧"],
            EquipmentType.armor: ["皮甲", "锁甲", "板甲", "法袍", "斗篷"],
            EquipmentType.accessory: ["戒指", "项链", "护符", "手镯", "徽章"]
        ]
        
        let prefix = rarityPrefix[rarity] ?? ""
        let baseName = typeNames[type]?.randomElement() ?? "未知"
        
        return prefix.isEmpty ? baseName : "\(prefix)\(baseName)"
    }
    
    // MARK: - 技能生成
    func generateRandomSkill() -> Skill {
        let skillTemplates: [(String, SkillType, String, Int)] = [
            ("治疗术", .heal, "恢复生命值", 10),
            ("火球术", .attack, "对敌人造成魔法伤害", 15),
            ("护盾术", .defense, "提升防御力", 12),
            ("冰冻术", .special, "冻结敌人一回合", 20),
            ("闪电术", .attack, "连锁攻击", 18),
            ("恢复术", .heal, "持续恢复生命", 8)
        ]
        
        let template = skillTemplates.randomElement() ?? skillTemplates[0]
        return Skill(
            name: template.0,
            type: template.1,
            description: template.2,
            manaCost: template.3
        )
    }
    
    // MARK: - 随机事件
    private func generateRandomEvent(floorNumber: Int, dungeonLevel: Int) -> DungeonFloor {
        let events = [
            "神秘商人", "治疗泉水", "诅咒祭坛", "宝石矿脉", "魔法传送门"
        ]
        
        let eventName = events.randomElement() ?? "神秘事件"
        var floor = DungeonFloor(floorNumber: floorNumber, eventType: .random)
        
        // 根据事件名称生成不同的效果
        switch eventName {
        case "治疗泉水":
            floor.rewards = [Reward(type: .health, amount: 50)]
        case "宝石矿脉":
            floor.rewards = [Reward(type: .gold, amount: 30)]
        default:
            floor.rewards = generateTreasureRewards(dungeonLevel: dungeonLevel)
        }
        
        return floor
    }
    
    // MARK: - 地牢主题
    private func selectDungeonTheme(for level: Int) -> String {
        let themes = [
            "神秘洞穴", "废弃矿井", "古老神殿", "魔法塔", "暗影森林", "冰霜要塞", "火焰地狱", "天空之城"
        ]
        
        let themeIndex = (level - 1) % themes.count
        return themes[themeIndex]
    }
} 