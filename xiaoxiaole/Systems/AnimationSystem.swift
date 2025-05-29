//
//  AnimationSystem.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import SpriteKit
import GameplayKit

/// 动画系统 - 负责管理游戏中所有动画效果
class AnimationSystem {
    static let shared = AnimationSystem()
    
    // MARK: - 动画配置
    struct Config {
        // 基础动画时长
        static let gemDropDuration: TimeInterval = 0.4
        static let gemMatchDuration: TimeInterval = 0.25
        static let gemSwapDuration: TimeInterval = 0.3
        static let gemSpawnDuration: TimeInterval = 0.2
        
        // 特效动画时长
        static let explosionDuration: TimeInterval = 0.5
        static let comboDuration: TimeInterval = 0.8
        static let scorePopDuration: TimeInterval = 1.0
        
        // UI动画时长
        static let buttonPressDuration: TimeInterval = 0.1
        static let panelSlideDuration: TimeInterval = 0.3
        static let fadeTransitionDuration: TimeInterval = 0.25
        
        // 缓动函数
        static let defaultEasing = SKActionTimingMode.easeInEaseOut
        static let bounceEasing = SKActionTimingMode.easeOut
        static let snapEasing = SKActionTimingMode.easeIn
    }
    
    // MARK: - 动画队列管理
    private var activeAnimations: Set<String> = []
    private var animationQueue: [String: [SKAction]] = [:]
    private let maxConcurrentAnimations = 15
    
    private init() {}
    
    // MARK: - 宝石动画
    
    /// 宝石生成动画
    func animateGemSpawn(_ node: SKSpriteNode, at position: CGPoint, completion: (() -> Void)? = nil) {
        node.position = CGPoint(x: position.x, y: position.y + 200)
        node.alpha = 0
        node.setScale(0.1)
        
        let moveAction = SKAction.move(to: position, duration: Config.gemSpawnDuration)
        moveAction.timingMode = Config.bounceEasing
        
        let fadeAction = SKAction.fadeIn(withDuration: Config.gemSpawnDuration * 0.8)
        let scaleAction = SKAction.scale(to: 1.0, duration: Config.gemSpawnDuration)
        scaleAction.timingMode = Config.bounceEasing
        
        let group = SKAction.group([moveAction, fadeAction, scaleAction])
        
        if let completion = completion {
            let sequence = SKAction.sequence([group, SKAction.run(completion)])
            node.run(sequence, withKey: "spawn")
        } else {
            node.run(group, withKey: "spawn")
        }
    }
    
    /// 宝石交换动画
    func animateGemSwap(_ node1: SKSpriteNode, _ node2: SKSpriteNode, completion: (() -> Void)? = nil) {
        let pos1 = node1.position
        let pos2 = node2.position
        
        let move1 = SKAction.move(to: pos2, duration: Config.gemSwapDuration)
        let move2 = SKAction.move(to: pos1, duration: Config.gemSwapDuration)
        
        move1.timingMode = Config.defaultEasing
        move2.timingMode = Config.defaultEasing
        
        // 添加轻微的弧形路径效果
        let arc1 = createArcMovement(from: pos1, to: pos2, duration: Config.gemSwapDuration)
        let arc2 = createArcMovement(from: pos2, to: pos1, duration: Config.gemSwapDuration)
        
        node1.run(arc1, withKey: "swap")
        
        if let completion = completion {
            let sequence = SKAction.sequence([arc2, SKAction.run(completion)])
            node2.run(sequence, withKey: "swap")
        } else {
            node2.run(arc2, withKey: "swap")
        }
    }
    
    /// 宝石消除动画
    func animateGemMatch(_ nodes: [SKSpriteNode], completion: (() -> Void)? = nil) {
        let animationId = UUID().uuidString
        activeAnimations.insert(animationId)
        
        var completedCount = 0
        let totalCount = nodes.count
        
        for (index, node) in nodes.enumerated() {
            let delay = Double(index) * 0.05 // 错开消除时间
            
            let scaleDown = SKAction.scale(to: 0.1, duration: Config.gemMatchDuration)
            let fadeOut = SKAction.fadeOut(withDuration: Config.gemMatchDuration)
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: Config.gemMatchDuration)
            
            scaleDown.timingMode = Config.snapEasing
            fadeOut.timingMode = Config.defaultEasing
            
            let group = SKAction.group([scaleDown, fadeOut, rotate])
            let delayedGroup = SKAction.sequence([SKAction.wait(forDuration: delay), group])
            
            let removeAction = SKAction.sequence([
                delayedGroup,
                SKAction.run {
                    AssetManager.shared.recycleGemNode(node)
                    completedCount += 1
                    
                    if completedCount == totalCount {
                        self.activeAnimations.remove(animationId)
                        completion?()
                    }
                }
            ])
            
            node.run(removeAction, withKey: "match")
        }
        
        // 添加粒子效果
        if let firstNode = nodes.first {
            addMatchParticleEffect(at: firstNode.position, count: nodes.count)
        }
    }
    
    /// 宝石下落动画
    func animateGemDrop(_ node: SKSpriteNode, to position: CGPoint, completion: (() -> Void)? = nil) {
        let distance = abs(node.position.y - position.y)
        let duration = Config.gemDropDuration * (distance / 300.0) // 根据距离调整时长
        
        let moveAction = SKAction.move(to: position, duration: duration)
        moveAction.timingMode = Config.bounceEasing
        
        // 确保节点缩放正确
        node.setScale(1.0)
        
        // 添加轻微的弹跳效果，使用更安全的动画序列
        let bounceScale = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.03),  // 减小弹跳幅度
            SKAction.scale(to: 1.0, duration: 0.03)    // 确保回到正常大小
        ])
        
        let fullSequence = SKAction.sequence([
            moveAction,
            bounceScale
        ])
        
        if let completion = completion {
            let sequence = SKAction.sequence([fullSequence, SKAction.run(completion)])
            node.run(sequence, withKey: "drop")
        } else {
            node.run(fullSequence, withKey: "drop")
        }
    }
    
    // MARK: - 特效动画
    
    /// 连击特效动画
    func animateComboEffect(at position: CGPoint, comboCount: Int, parent: SKNode) {
        let comboLabel = AssetManager.shared.getLabelNode()
        comboLabel.text = "COMBO x\(comboCount)!"
        comboLabel.fontSize = 24 + CGFloat(min(comboCount * 2, 20))
        comboLabel.fontColor = UIColor.yellow
        comboLabel.position = position
        comboLabel.zPosition = 100
        
        // 添加描边效果
        comboLabel.fontName = AssetManager.FontNames.title
        
        parent.addChild(comboLabel)
        
        // 动画序列
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: Config.comboDuration)
        
        scaleUp.timingMode = Config.bounceEasing
        
        let sequence = SKAction.sequence([
            scaleUp,
            scaleDown,
            SKAction.wait(forDuration: 0.2),
            SKAction.group([fadeOut, moveUp]),
            SKAction.run {
                AssetManager.shared.recycleLabelNode(comboLabel)
            }
        ])
        
        comboLabel.run(sequence)
    }
    
    /// 得分弹出动画
    func animateScorePop(score: Int, at position: CGPoint, parent: SKNode) {
        let scoreLabel = AssetManager.shared.getLabelNode()
        scoreLabel.text = "+\(score)"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = UIColor.green
        scoreLabel.position = position
        scoreLabel.zPosition = 99
        
        parent.addChild(scoreLabel)
        
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: Config.scorePopDuration)
        let fadeOut = SKAction.fadeOut(withDuration: Config.scorePopDuration * 0.7)
        let scaleEffect = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        let sequence = SKAction.sequence([
            scaleEffect,
            SKAction.group([moveUp, fadeOut]),
            SKAction.run {
                AssetManager.shared.recycleLabelNode(scoreLabel)
            }
        ])
        
        scoreLabel.run(sequence)
    }
    
    /// 爆炸特效
    func animateExplosion(at position: CGPoint, parent: SKNode) {
        // 创建多个粒子模拟爆炸效果
        for i in 0..<8 {
            let particle = SKSpriteNode(color: UIColor.orange, size: CGSize(width: 4, height: 4))
            particle.position = position
            particle.zPosition = 50
            parent.addChild(particle)
            
            let angle = Double(i) * .pi / 4
            let distance: CGFloat = 40
            let endPosition = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            
            let moveAction = SKAction.move(to: endPosition, duration: Config.explosionDuration)
            let fadeAction = SKAction.fadeOut(withDuration: Config.explosionDuration)
            let scaleAction = SKAction.scale(to: 0.1, duration: Config.explosionDuration)
            
            let group = SKAction.group([moveAction, fadeAction, scaleAction])
            let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
            
            particle.run(sequence)
        }
    }
    
    // MARK: - UI动画
    
    /// 按钮按下动画
    func animateButtonPress(_ button: SKNode, completion: (() -> Void)? = nil) {
        let scaleDown = SKAction.scale(to: 0.95, duration: Config.buttonPressDuration)
        let scaleUp = SKAction.scale(to: 1.0, duration: Config.buttonPressDuration)
        
        scaleDown.timingMode = Config.snapEasing
        scaleUp.timingMode = Config.bounceEasing
        
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        if let completion = completion {
            let fullSequence = SKAction.sequence([sequence, SKAction.run(completion)])
            button.run(fullSequence, withKey: "buttonPress")
        } else {
            button.run(sequence, withKey: "buttonPress")
        }
    }
    
    /// 面板滑入动画
    func animatePanelSlideIn(_ panel: SKNode, from direction: SlideDirection) {
        let originalPosition = panel.position
        
        // 设置起始位置
        switch direction {
        case .left:
            panel.position.x -= 300
        case .right:
            panel.position.x += 300
        case .top:
            panel.position.y += 300
        case .bottom:
            panel.position.y -= 300
        }
        
        panel.alpha = 0
        
        let moveAction = SKAction.move(to: originalPosition, duration: Config.panelSlideDuration)
        let fadeAction = SKAction.fadeIn(withDuration: Config.panelSlideDuration)
        
        moveAction.timingMode = Config.defaultEasing
        
        let group = SKAction.group([moveAction, fadeAction])
        panel.run(group, withKey: "slideIn")
    }
    
    /// 高亮选中动画
    func animateGemHighlight(_ node: SKSpriteNode) {
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        
        let repeatPulse = SKAction.repeatForever(pulse)
        node.run(repeatPulse, withKey: "highlight")
    }
    
    /// 移除高亮动画
    func removeGemHighlight(_ node: SKSpriteNode) {
        node.removeAction(forKey: "highlight")
        let resetScale = SKAction.scale(to: 1.0, duration: 0.1)
        node.run(resetScale)
    }
    
    // MARK: - 辅助方法
    
    /// 创建弧形移动路径
    private func createArcMovement(from start: CGPoint, to end: CGPoint, duration: TimeInterval) -> SKAction {
        let midPoint = CGPoint(
            x: (start.x + end.x) / 2,
            y: max(start.y, end.y) + 20
        )
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addQuadCurve(to: end, controlPoint: midPoint)
        
        return SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, duration: duration)
    }
    
    /// 添加匹配粒子效果
    private func addMatchParticleEffect(at position: CGPoint, count: Int) {
        // 这里可以添加更复杂的粒子系统
        // 暂时用简单的星星效果代替
        for i in 0..<min(count, 5) {
            let star = SKLabelNode(text: "✨")
            star.fontSize = 16
            star.position = position
            star.zPosition = 60
            
            let randomX = CGFloat.random(in: -30...30)
            let randomY = CGFloat.random(in: -30...30)
            let endPosition = CGPoint(x: position.x + randomX, y: position.y + randomY)
            
            let moveAction = SKAction.move(to: endPosition, duration: 0.5)
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
            
            let group = SKAction.group([moveAction, fadeAction, rotateAction])
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.1),
                group,
                SKAction.removeFromParent()
            ])
            
            star.run(sequence)
        }
    }
    
    /// 停止所有动画
    func stopAllAnimations() {
        activeAnimations.removeAll()
        animationQueue.removeAll()
    }
    
    /// 暂停所有动画
    func pauseAllAnimations() {
        // 实现动画暂停逻辑
    }
    
    /// 恢复所有动画
    func resumeAllAnimations() {
        // 实现动画恢复逻辑
    }
    
    // MARK: - 调试和修复方法
    
    /// 检测并修复异常缩放的节点
    func detectAndFixScaleIssues(in scene: SKScene) {
        scene.enumerateChildNodes(withName: "gem_*") { node, _ in
            if let gemNode = node as? SKSpriteNode {
                // 检测异常缩放
                if abs(gemNode.xScale - 1.0) > 0.1 || abs(gemNode.yScale - 1.0) > 0.1 {
                    print("⚠️ 检测到异常缩放的宝石: \(gemNode.name ?? "unknown"), scale: (\(gemNode.xScale), \(gemNode.yScale))")
                    
                    // 修复缩放
                    gemNode.setScale(1.0)
                    gemNode.xScale = 1.0
                    gemNode.yScale = 1.0
                    
                    print("✅ 已修复宝石缩放: \(gemNode.name ?? "unknown")")
                }
            }
        }
    }
    
    /// 强制重置所有宝石节点的变换
    func resetAllGemTransforms(in scene: SKScene) {
        scene.enumerateChildNodes(withName: "gem_*") { node, _ in
            if let gemNode = node as? SKSpriteNode {
                gemNode.removeAllActions()
                gemNode.setScale(1.0)
                gemNode.xScale = 1.0
                gemNode.yScale = 1.0
                gemNode.zRotation = 0
                gemNode.alpha = 1.0
            }
        }
        print("🔧 已重置所有宝石节点的变换")
    }
}

// MARK: - 辅助枚举
enum SlideDirection {
    case left, right, top, bottom
} 