//
//  EnemyAISystem.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation
import GameplayKit

/// 敌人AI行为系统 - 负责敌人的智能决策和行为模式
class EnemyAISystem {
    static let shared = EnemyAISystem()
    
    // MARK: - AI配置
    struct AIConfig {
        static let thinkingDelay: TimeInterval = 1.0
        static let actionDelay: TimeInterval = 0.5
        static let aggressiveThreshold: Float = 0.3  // 血量低于30%时变得激进
        static let defensiveThreshold: Float = 0.7   // 血量高于70%时较为保守
    }
    
    // MARK: - AI状态
    enum AIState {
        case thinking    // 思考中
        case acting      // 执行行动
        case waiting     // 等待
        case defeated    // 已败北
    }
    
    // MARK: - AI行动结构
    struct AIAction {
        let type: ActionType
        let targetType: TargetType
        let skillName: String
        let damage: Int
        let healAmount: Int?
        let description: String
        let effects: [StatusEffect]?
        
        init(type: ActionType, targetType: TargetType, skillName: String, damage: Int = 0, healAmount: Int? = nil, description: String, effects: [StatusEffect]? = nil) {
            self.type = type
            self.targetType = targetType
            self.skillName = skillName
            self.damage = damage
            self.healAmount = healAmount
            self.description = description
            self.effects = effects
        }
    }
    
    enum ActionType {
        case attack
        case defend
        case heal
        case special
        case wait
    }
    
    enum TargetType {
        case player
        case `self`
        case enemy
    }
    
    enum StatusEffect {
        case poison(String, Int)
        case stun(String, Int)
        case buff(String, Int)
        case debuff(String, Int)
    }
    
    // MARK: - 特殊效果
    enum SpecialEffect {
        case poison(duration: Int, damagePerTurn: Int)
        case stun(duration: Int)
        case buff(type: BuffType, duration: Int, value: Int)
        case debuff(type: DebuffType, duration: Int, value: Int)
    }
    
    enum BuffType {
        case attackBoost, defenseBoost, speedBoost
    }
    
    enum DebuffType {
        case attackReduction, defenseReduction, slowdown
    }
    
    // MARK: - 私有属性
    private var currentState: AIState = .waiting
    private var randomSource = GKRandomSource.sharedRandom()
    
    // 回调
    var onActionDecided: ((AIAction) -> Void)?
    var onStateChanged: ((AIState) -> Void)?
    
    private init() {}
    
    // MARK: - 公共接口
    func processEnemyTurn(enemy: Enemy, playerStats: PlayerStats) {
        guard enemy.isAlive else {
            changeState(to: .defeated)
            return
        }
        
        changeState(to: .thinking)
        
        // 延迟思考，增加真实感
        DispatchQueue.main.asyncAfter(deadline: .now() + AIConfig.thinkingDelay) {
            let action = self.decideAction(for: enemy, against: playerStats)
            self.changeState(to: .acting)
            
            // 延迟执行行动
            DispatchQueue.main.asyncAfter(deadline: .now() + AIConfig.actionDelay) {
                self.onActionDecided?(action)
                self.changeState(to: .waiting)
            }
        }
    }
    
    func getCurrentState() -> AIState {
        return currentState
    }
    
    // MARK: - AI决策核心
    private func decideAction(for enemy: Enemy, against playerStats: PlayerStats) -> AIAction {
        let enemyHealthPercentage = Float(enemy.health) / Float(enemy.maxHealth)
        let playerHealthPercentage = Float(playerStats.health) / Float(playerStats.maxHealth)
        
        // 根据敌人类型选择行为模式
        switch enemy.type {
        case .slimeGreen, .slimeBlue:
            return decideSlimeAction(enemy: enemy, playerStats: playerStats, healthPercentage: enemyHealthPercentage)
            
        case .goblinWarrior:
            return decideGoblinAction(enemy: enemy, playerStats: playerStats, healthPercentage: enemyHealthPercentage)
            
        case .skeletonArcher:
            return decideArcherAction(enemy: enemy, playerStats: playerStats, healthPercentage: enemyHealthPercentage)
            
        case .orcBerserker:
            return decideBerserkerAction(enemy: enemy, playerStats: playerStats, healthPercentage: enemyHealthPercentage)
            
        case .dragonBoss:
            return decideDragonAction(enemy: enemy, playerStats: playerStats, healthPercentage: enemyHealthPercentage)
        }
    }
    
    // MARK: - 史莱姆AI (简单攻击型)
    private func decideSlimeAction(enemy: Enemy, playerStats: PlayerStats, healthPercentage: Float) -> AIAction {
        let playerHealthPercentage = Float(playerStats.health) / Float(playerStats.maxHealth)
        
        // 90% 概率攻击，10% 概率防御
        if randomSource.nextUniform() < 0.9 {
            return AIAction(
                type: .attack,
                targetType: .player,
                skillName: "粘液攻击",
                damage: 8 + randomSource.nextInt(upperBound: 5),
                description: "史莱姆发动粘液攻击！"
            )
        } else {
            return AIAction(
                type: .defend,
                targetType: .self,
                skillName: "收缩防御",
                damage: 0,
                description: "史莱姆收缩身体进行防御。"
            )
        }
    }
    
    // MARK: - 哥布林战士AI (平衡型)
    private func decideGoblinAction(enemy: Enemy, playerStats: PlayerStats, healthPercentage: Float) -> AIAction {
        let healthPercentage = Float(enemy.health) / Float(enemy.maxHealth)
        
        if healthPercentage < 0.3 {
            // 血量低时优先治疗
            if randomSource.nextUniform() < 0.6 {
                return AIAction(
                    type: .heal,
                    targetType: .self,
                    skillName: "战斗药剂",
                    damage: 0,
                    healAmount: 15,
                    description: "哥布林战士喝下治疗药剂！"
                )
            }
        }
        
        // 随机选择行动
        let actionRoll = randomSource.nextUniform()
        
        if actionRoll < 0.5 {
            // 攻击
            return AIAction(
                type: .attack,
                targetType: .player,
                skillName: "利剑斩击",
                damage: 12 + randomSource.nextInt(upperBound: 6),
                description: "哥布林战士挥舞利剑攻击！"
            )
        } else if actionRoll < 0.8 {
            // 防御
            return AIAction(
                type: .defend,
                targetType: .self,
                skillName: "盾牌格挡",
                damage: 0,
                description: "哥布林战士举起盾牌防御。"
            )
        } else {
            // 特殊技能
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "战吼",
                damage: 8,
                description: "哥布林战士发出战吼，降低敌人士气！",
                effects: [.debuff("士气低落", 3)]
            )
        }
    }
    
    // MARK: - 骷髅弓手AI (远程特化)
    private func decideArcherAction(enemy: Enemy, playerStats: PlayerStats, healthPercentage: Float) -> AIAction {
        // 骷髅弓手：远程攻击为主，有特殊射击技能
        
        if healthPercentage < AIConfig.aggressiveThreshold {
            // 血量低时使用连射
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "连环射击",
                damage: 15,
                description: "骷髅弓手发动连环射击！",
                effects: [.buff("攻击强化", 3)]
            )
        }
        
        // 正常攻击模式
        let actionRoll = randomSource.nextUniform()
        
        if actionRoll < 0.8 {
            return AIAction(
                type: .attack,
                targetType: .player,
                skillName: "精准射击",
                damage: 10 + randomSource.nextInt(upperBound: 8),
                description: "骷髅弓手瞄准射击！"
            )
        } else {
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "毒箭",
                damage: 8,
                description: "骷髅弓手射出毒箭！",
                effects: [.poison("中毒", 3)]
            )
        }
    }
    
    // MARK: - 兽人狂战士AI (狂暴型)
    private func decideBerserkerAction(enemy: Enemy, playerStats: PlayerStats, healthPercentage: Float) -> AIAction {
        // 兽人狂战士：血量越低攻击越强
        
        let rageMultiplier = 1.0 + (1.0 - healthPercentage) // 血量越低倍数越高
        let baseDamage = Int(Float(15) * rageMultiplier)
        
        if healthPercentage < 0.2 {
            // 血量极低时狂暴
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "狂暴冲锋",
                damage: baseDamage + 10,
                description: "兽人狂战士进入狂暴状态！",
                effects: [.buff("狂暴", 2)]
            )
        } else if randomSource.nextUniform() < 0.7 {
            // 70% 概率普通攻击
            return AIAction(
                type: .attack,
                targetType: .player,
                skillName: "重击",
                damage: baseDamage,
                description: "兽人狂战士发动重击！"
            )
        } else {
            // 30% 概率特殊技能
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "战斧旋风",
                damage: baseDamage - 3,
                description: "兽人狂战士挥舞战斧！",
                effects: [.debuff("眩晕", 1)]
            )
        }
    }
    
    // MARK: - 龙王Boss AI (复杂型)
    private func decideDragonAction(enemy: Enemy, playerStats: PlayerStats, healthPercentage: Float) -> AIAction {
        // 龙王：三阶段AI，技能丰富
        
        if healthPercentage > 0.7 {
            // 第一阶段：保守攻击
            return firstPhaseAction(enemy: enemy, playerStats: playerStats)
        } else if healthPercentage > 0.3 {
            // 第二阶段：技能组合
            return secondPhaseAction(enemy: enemy, playerStats: playerStats)
        } else {
            // 第三阶段：狂暴模式
            return thirdPhaseAction(enemy: enemy, playerStats: playerStats)
        }
    }
    
    private func firstPhaseAction(enemy: Enemy, playerStats: PlayerStats) -> AIAction {
        let actionRoll = randomSource.nextUniform()
        
        if actionRoll < 0.6 {
            return AIAction(
                type: .attack,
                targetType: .player,
                skillName: "龙爪攻击",
                damage: 18 + randomSource.nextInt(upperBound: 8),
                description: "龙王挥舞巨爪攻击！"
            )
        } else {
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "龙息",
                damage: 15,
                description: "龙王喷出灼热龙息！",
                effects: [.debuff("灼烧", 2)]
            )
        }
    }
    
    private func secondPhaseAction(enemy: Enemy, playerStats: PlayerStats) -> AIAction {
        let actionRoll = randomSource.nextUniform()
        
        if actionRoll < 0.4 {
            return AIAction(
                type: .attack,
                targetType: .player,
                skillName: "龙尾横扫",
                damage: 20 + randomSource.nextInt(upperBound: 10),
                description: "龙王用尾巴横扫！"
            )
        } else if actionRoll < 0.7 {
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "烈焰风暴",
                damage: 25,
                description: "龙王召唤烈焰风暴！",
                effects: [.debuff("灼烧", 3)]
            )
        } else {
            return AIAction(
                type: .heal,
                targetType: .self,
                skillName: "龙族恢复",
                healAmount: 30,
                description: "龙王恢复体力！"
            )
        }
    }
    
    private func thirdPhaseAction(enemy: Enemy, playerStats: PlayerStats) -> AIAction {
        let actionRoll = randomSource.nextUniform()
        
        if actionRoll < 0.5 {
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "毁灭龙息",
                damage: 35,
                description: "龙王发出毁灭性龙息！",
                effects: [.debuff("重伤", 2)]
            )
        } else {
            return AIAction(
                type: .special,
                targetType: .player,
                skillName: "龙王怒吼",
                damage: 30,
                description: "龙王发出震天怒吼！",
                effects: [.stun("眩晕", 1)]
            )
        }
    }
    
    // MARK: - 工具方法
    private func calculateAttackDamage(enemy: Enemy, modifier: Float = 1.0) -> Int {
        let baseDamage = enemy.attack
        let randomVariation = randomSource.nextInt(upperBound: 5) - 2 // -2到+2的随机变化
        return max(1, Int(Float(baseDamage + randomVariation) * modifier))
    }
    
    private func selectWeightedAction(_ weightedActions: [(AIAction, Float)]) -> AIAction {
        let totalWeight = weightedActions.reduce(0) { $0 + $1.1 }
        let randomValue = randomSource.nextUniform() * totalWeight
        
        var currentWeight: Float = 0
        for (action, weight) in weightedActions {
            currentWeight += weight
            if randomValue <= currentWeight {
                return action
            }
        }
        
        // 默认返回第一个行动，如果没有则返回等待动作
        return weightedActions.first?.0 ?? AIAction(
            type: .wait,
            targetType: .self,
            skillName: "等待",
            description: "敌人在等待时机..."
        )
    }
    
    private func changeState(to newState: AIState) {
        currentState = newState
        onStateChanged?(newState)
        
        print("🤖 AI状态变更: \(newState)")
    }
    
    // MARK: - 特殊能力判断
    func canUseSpecialAbility(enemy: Enemy, abilityName: String) -> Bool {
        // 根据敌人类型和当前状态判断是否可以使用特殊能力
        switch enemy.type {
        case .slimeGreen, .slimeBlue:
            return false // 史莱姆没有特殊能力
        case .goblinWarrior:
            return true // 哥布林总是可以使用技能
        case .skeletonArcher:
            return true // 弓手总是可以使用技能
        case .orcBerserker:
            return enemy.health < enemy.maxHealth / 2 // 血量低于50%才能狂暴
        case .dragonBoss:
            return true // Boss总是可以使用技能
        }
    }
    
    // MARK: - 调试信息
    func getAIDebugInfo(for enemy: Enemy) -> String {
        let healthPercentage = Float(enemy.health) / Float(enemy.maxHealth)
        return """
        🤖 AI状态: \(currentState)
        👹 敌人: \(enemy.name)
        ❤️ 血量: \(enemy.health)/\(enemy.maxHealth) (\(Int(healthPercentage * 100))%)
        🎯 AI模式: \(getAIModeDescription(for: enemy, healthPercentage: healthPercentage))
        """
    }
    
    private func getAIModeDescription(for enemy: Enemy, healthPercentage: Float) -> String {
        if healthPercentage < AIConfig.aggressiveThreshold {
            return "激进模式"
        } else if healthPercentage > AIConfig.defensiveThreshold {
            return "保守模式"
        } else {
            return "平衡模式"
        }
    }
} 