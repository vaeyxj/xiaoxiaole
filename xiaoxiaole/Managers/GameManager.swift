//
//  GameManager.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation
import SpriteKit
import GameplayKit

/// 游戏主管理器 - 负责游戏状态管理、进度保存、全局控制
class GameManager: ObservableObject {
    static let shared = GameManager()
    
    // MARK: - 游戏状态
    @Published var currentState: GameState = .menu
    @Published var combatState: CombatState = .playerTurn
    
    // MARK: - 玩家数据
    @Published var playerStats: PlayerStats
    @Published var currentLevel: Int = 1
    @Published var currentFloor: Int = 1
    @Published var totalScore: Int = 0
    @Published var currentCombo: Int = 0
    @Published var maxCombo: Int = 0
    
    // MARK: - 游戏配置
    let boardSize: Int = 8
    let maxDungeonFloors: Int = 15
    let minMatchCount: Int = 3
    
    // MARK: - 管理器依赖
    private let assetManager = AssetManager.shared
    private let dungeonGenerator = DungeonGenerator()
    private let saveManager = SaveManager.shared
    
    // MARK: - 当前游戏状态
    var currentEnemy: Enemy?
    var currentDungeon: Dungeon?
    var playerInventory: [Equipment] = []
    var playerSkills: [Skill] = []
    
    // MARK: - 初始化
    private init() {
        self.playerStats = PlayerStats(
            health: 100,
            maxHealth: 100,
            mana: 50,
            maxMana: 50,
            attack: 10,
            defense: 5,
            level: 1,
            experience: 0,
            gold: 100,
            diamonds: 10
        )
        
        loadGameData()
    }
    
    // MARK: - 游戏状态管理
    func startNewGame() {
        resetPlayerStats()
        currentLevel = 1
        currentFloor = 1
        totalScore = 0
        currentCombo = 0
        maxCombo = 0
        
        // 生成新地牢
        currentDungeon = dungeonGenerator.generateDungeon(level: currentLevel)
        
        changeState(to: .playing)
        print("🎮 开始新游戏 - 等级: \(currentLevel), 楼层: \(currentFloor)")
    }
    
    func pauseGame() {
        if currentState == .playing {
            changeState(to: .paused)
        }
    }
    
    func resumeGame() {
        if currentState == .paused {
            changeState(to: .playing)
        }
    }
    
    func endGame() {
        saveGameData()
        changeState(to: .gameOver)
        print("🎮 游戏结束 - 最终得分: \(totalScore)")
    }
    
    func changeState(to newState: GameState) {
        let oldState = currentState
        currentState = newState
        onStateChanged(from: oldState, to: newState)
    }
    
    private func onStateChanged(from oldState: GameState, to newState: GameState) {
        print("🎮 游戏状态变化: \(oldState) -> \(newState)")
        
        switch newState {
        case .menu:
            // 停止背景音乐，播放菜单音乐
            break
        case .playing:
            // 播放游戏背景音乐
            break
        case .paused:
            // 暂停所有动画和音效
            break
        case .gameOver:
            // 播放游戏结束音效，显示结算界面
            break
        case .victory:
            // 播放胜利音效，显示胜利界面
            break
        default:
            break
        }
    }
    
    // MARK: - 战斗系统管理
    func startCombat(with enemy: Enemy) {
        currentEnemy = enemy
        combatState = .playerTurn
        print("⚔️ 开始战斗 - 敌人: \(enemy.name)")
    }
    
    func playerAttack(damage: Int) {
        guard let enemy = currentEnemy, combatState == .playerTurn else { return }
        
        enemy.takeDamage(damage)
        print("⚔️ 玩家攻击 - 伤害: \(damage), 敌人血量: \(enemy.health)/\(enemy.maxHealth)")
        
        if enemy.health <= 0 {
            combatState = .victory
            onCombatVictory()
        } else {
            combatState = .enemyTurn
            performEnemyAction()
        }
    }
    
    private func performEnemyAction() {
        guard let enemy = currentEnemy else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let damage = enemy.attack
            self.playerStats.takeDamage(damage)
            print("⚔️ 敌人攻击 - 伤害: \(damage), 玩家血量: \(self.playerStats.health)/\(self.playerStats.maxHealth)")
            
            if self.playerStats.health <= 0 {
                self.combatState = .defeat
                self.onCombatDefeat()
            } else {
                self.combatState = .playerTurn
            }
        }
    }
    
    private func onCombatVictory() {
        guard let enemy = currentEnemy else { return }
        
        // 获得经验和金币
        let expGain = enemy.experience
        let goldGain = enemy.goldReward
        
        playerStats.gainExperience(expGain)
        playerStats.gold += goldGain
        
        print("🎉 战斗胜利! 获得经验: \(expGain), 金币: \(goldGain)")
        
        // 清理当前敌人
        currentEnemy = nil
        
        // 前往下一层
        advanceToNextFloor()
    }
    
    private func onCombatDefeat() {
        print("💀 战斗失败!")
        endGame()
    }
    
    // MARK: - 地牢系统管理
    func advanceToNextFloor() {
        currentFloor += 1
        
        if currentFloor > maxDungeonFloors {
            // 完成当前地牢，生成新地牢
            currentLevel += 1
            currentFloor = 1
            currentDungeon = dungeonGenerator.generateDungeon(level: currentLevel)
            print("🏰 进入新地牢 - 等级: \(currentLevel)")
        }
        
        print("🏰 前往下一层 - 楼层: \(currentFloor)")
    }
    
    // MARK: - 消除系统管理
    func processMatch(type: MatchType, gemType: GemType, count: Int) {
        let baseScore = type.score
        let comboMultiplier = max(1, currentCombo)
        let finalScore = baseScore * comboMultiplier
        
        totalScore += finalScore
        currentCombo += 1
        maxCombo = max(maxCombo, currentCombo)
        
        // 根据宝石类型给予不同效果
        applyGemEffect(gemType: gemType, count: count)
        
        print("💎 消除成功 - 类型: \(type.displayName), 得分: \(finalScore), 连击: \(currentCombo)")
    }
    
    func resetCombo() {
        currentCombo = 0
    }
    
    private func applyGemEffect(gemType: GemType, count: Int) {
        switch gemType {
        case .red:
            // 红宝石 - 攻击伤害
            if let enemy = currentEnemy {
                let damage = count * 5
                playerAttack(damage: damage)
            }
        case .blue:
            // 蓝宝石 - 恢复法力
            let manaRestore = count * 2
            playerStats.restoreMana(manaRestore)
        case .green:
            // 绿宝石 - 恢复生命
            let healthRestore = count * 3
            playerStats.restoreHealth(healthRestore)
        case .yellow:
            // 黄宝石 - 获得金币
            let goldGain = count * 2
            playerStats.gold += goldGain
        case .purple:
            // 紫水晶 - 经验值
            let expGain = count * 1
            playerStats.gainExperience(expGain)
        case .white:
            // 白珍珠 - 全属性小幅提升
            playerStats.temporaryBoost()
        case .bomb:
            // 炸弹 - 范围伤害
            if let enemy = currentEnemy {
                let damage = count * 15
                playerAttack(damage: damage)
            }
        case .lightning:
            // 闪电 - 连锁伤害
            if let enemy = currentEnemy {
                let damage = count * 8
                for _ in 0..<3 {
                    playerAttack(damage: damage)
                }
            }
        case .rainbow:
            // 彩虹石 - 随机效果
            let randomEffect = GemType.basicGems.randomElement() ?? .red
            applyGemEffect(gemType: randomEffect, count: count * 2)
        }
    }
    
    // MARK: - 数据保存和加载
    private func saveGameData() {
        let gameData = GameSaveData(
            playerStats: playerStats,
            currentLevel: currentLevel,
            currentFloor: currentFloor,
            totalScore: totalScore,
            maxCombo: maxCombo,
            inventory: playerInventory,
            skills: playerSkills
        )
        
        saveManager.saveGame(gameData)
    }
    
    private func loadGameData() {
        if let gameData = saveManager.loadGame() {
            playerStats = gameData.playerStats
            currentLevel = gameData.currentLevel
            currentFloor = gameData.currentFloor
            totalScore = gameData.totalScore
            maxCombo = gameData.maxCombo
            playerInventory = gameData.inventory
            playerSkills = gameData.skills
            print("📁 游戏数据加载成功")
        } else {
            print("📁 没有找到存档，使用默认数据")
        }
    }
    
    private func resetPlayerStats() {
        playerStats = PlayerStats(
            health: 100,
            maxHealth: 100,
            mana: 50,
            maxMana: 50,
            attack: 10,
            defense: 5,
            level: 1,
            experience: 0,
            gold: 100,
            diamonds: 10
        )
    }
    
    // MARK: - 装备和技能管理
    func equipItem(_ equipment: Equipment) {
        // 卸下相同类型的装备
        playerInventory.removeAll { $0.type == equipment.type && $0.isEquipped }
        
        // 装备新物品
        equipment.isEquipped = true
        if !playerInventory.contains(where: { $0.id == equipment.id }) {
            playerInventory.append(equipment)
        }
        
        // 应用装备属性
        playerStats.applyEquipment(equipment)
        print("🛡️ 装备物品: \(equipment.name)")
    }
    
    func learnSkill(_ skill: Skill) {
        if !playerSkills.contains(where: { $0.id == skill.id }) {
            playerSkills.append(skill)
            print("📚 学习技能: \(skill.name)")
        }
    }
    
    func useSkill(_ skill: Skill) -> Bool {
        guard playerStats.mana >= skill.manaCost else {
            print("❌ 法力不足，无法使用技能: \(skill.name)")
            return false
        }
        
        playerStats.mana -= skill.manaCost
        skill.activate(on: playerStats, enemy: currentEnemy)
        print("✨ 使用技能: \(skill.name)")
        return true
    }
    
    // MARK: - 调试和测试方法
    func debugInfo() -> String {
        return """
        🎮 游戏状态: \(currentState)
        ⚔️ 战斗状态: \(combatState)
        👤 玩家等级: \(playerStats.level)
        🏰 地牢等级: \(currentLevel)
        🏗️ 当前楼层: \(currentFloor)
        💎 总得分: \(totalScore)
        🔥 最大连击: \(maxCombo)
        💰 金币: \(playerStats.gold)
        💎 钻石: \(playerStats.diamonds)
        """
    }
} 