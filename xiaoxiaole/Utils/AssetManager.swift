//
//  AssetManager.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import SpriteKit
import UIKit

/// 资源管理器 - 负责游戏中所有资源的加载、缓存和管理
class AssetManager {
    static let shared = AssetManager()
    
    // MARK: - 纹理缓存系统
    private var textureCache: [String: SKTexture] = [:]
    private var gemTextureCache: [GemType: SKTexture] = [:]
    private let cacheQueue = DispatchQueue(label: "com.xiaoxiaole.texture.cache", qos: .userInitiated)
    
    // MARK: - 对象池系统
    private var gemNodePool: [SKSpriteNode] = []
    private var labelNodePool: [SKLabelNode] = []
    private let maxPoolSize = 100
    
    // MARK: - 美术资源配置
    struct ArtAssets {
        // 宝石资源配置 - 你可以在这里替换为你的美术资源
        static var gemAssets: [GemType: String] = [
            .red: "gem_red",           // 红宝石
            .blue: "gem_blue",         // 蓝宝石  
            .green: "gem_green",       // 绿宝石
            .yellow: "gem_yellow",     // 黄宝石
            .purple: "gem_purple",     // 紫宝石
            .white: "gem_white"        // 白宝石
        ]
        
        // 特殊宝石资源
        static var specialGemAssets: [String: String] = [
            "bomb": "gem_bomb",        // 炸弹宝石
            "rainbow": "gem_rainbow",  // 彩虹宝石
            "lightning": "gem_lightning" // 闪电宝石
        ]
        
        // 背景资源
        static var backgroundAssets: [String: String] = [
            "menu": "bg_menu",
            "game": "bg_game",
            "combat": "bg_combat"
        ]
        
        // UI元素资源
        static var uiAssets: [String: String] = [
            "button_normal": "ui_button_normal",
            "button_pressed": "ui_button_pressed",
            "panel": "ui_panel",
            "health_bar": "ui_health_bar",
            "mana_bar": "ui_mana_bar"
        ]
        
        // 粒子效果资源
        static var particleAssets: [String: String] = [
            "gem_explosion": "particle_gem_explosion",
            "combo_effect": "particle_combo",
            "level_up": "particle_level_up"
        ]
    }
    
    // MARK: - 性能配置
    struct PerformanceConfig {
        static let enableTextureAtlas = true
        static let enableObjectPooling = true
        static let maxConcurrentAnimations = 20
        static let animationFrameRate: TimeInterval = 1.0/60.0
        static let enableParticleOptimization = true
    }
    
    private init() {
        preloadEssentialTextures()
        setupObjectPools()
    }
    
    // MARK: - 纹理管理
    
    /// 预加载核心纹理
    private func preloadEssentialTextures() {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 预加载宝石纹理
            for gemType in GemType.allCases {
                _ = self.getGemTexture(gemType)
            }
            
            // 预加载UI纹理
            for (_, assetName) in ArtAssets.uiAssets {
                _ = self.getTexture(named: assetName)
            }
            
            print("🎨 核心纹理预加载完成")
        }
    }
    
    /// 获取纹理（带缓存）
    func getTexture(named name: String) -> SKTexture {
        if let cachedTexture = textureCache[name] {
            return cachedTexture
        }
        
        let texture: SKTexture
        
        // 尝试从Assets.xcassets加载
        if let image = UIImage(named: name) {
            texture = SKTexture(image: image)
        } else {
            // 如果找不到资源，创建占位符纹理
            texture = createPlaceholderTexture(for: name)
            print("⚠️ 未找到纹理资源: \(name)，使用占位符")
        }
        
        // 优化纹理设置
        texture.filteringMode = .nearest
        
        textureCache[name] = texture
        return texture
    }
    
    /// 获取宝石纹理
    func getGemTexture(_ gemType: GemType) -> SKTexture {
        if let cachedTexture = gemTextureCache[gemType] {
            return cachedTexture
        }
        
        let assetName = ArtAssets.gemAssets[gemType] ?? "gem_default"
        let texture = getTexture(named: assetName)
        
        gemTextureCache[gemType] = texture
        return texture
    }
    
    /// 创建占位符纹理
    private func createPlaceholderTexture(for name: String) -> SKTexture {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // 根据资源类型创建不同的占位符
            if name.contains("gem") {
                // 宝石占位符
                let color = getGemPlaceholderColor(for: name)
                color.setFill()
                context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            } else {
                // 通用占位符
                UIColor.lightGray.setFill()
                context.cgContext.fill(CGRect(origin: .zero, size: size))
            }
        }
        
        return SKTexture(image: image)
    }
    
    /// 获取宝石占位符颜色
    private func getGemPlaceholderColor(for name: String) -> UIColor {
        switch name {
        case let n where n.contains("red"): return UIColor.red
        case let n where n.contains("blue"): return UIColor.blue
        case let n where n.contains("green"): return UIColor.green
        case let n where n.contains("yellow"): return UIColor.yellow
        case let n where n.contains("purple"): return UIColor.purple
        case let n where n.contains("white"): return UIColor.white
        default: return UIColor.gray
        }
    }
    
    // MARK: - 对象池系统
    
    /// 设置对象池
    private func setupObjectPools() {
        guard PerformanceConfig.enableObjectPooling else { return }
        
        // 预创建宝石节点池
        for _ in 0..<maxPoolSize/2 {
            let gemNode = SKSpriteNode()
            gemNode.size = CGSize(width: 30, height: 30)
            gemNodePool.append(gemNode)
        }
        
        // 预创建标签节点池
        for _ in 0..<maxPoolSize/4 {
            let labelNode = SKLabelNode(fontNamed: FontNames.body)
            labelNodePool.append(labelNode)
        }
        
        print("🎯 对象池初始化完成 - 宝石节点: \(gemNodePool.count), 标签节点: \(labelNodePool.count)")
    }
    
    /// 获取宝石节点（从对象池）
    func getGemNode(type: GemType) -> SKSpriteNode {
        let node: SKSpriteNode
        
        if PerformanceConfig.enableObjectPooling && !gemNodePool.isEmpty {
            node = gemNodePool.removeLast()
            node.removeAllActions()
            node.removeFromParent()
        } else {
            node = SKSpriteNode()
        }
        
        // 完全重置节点属性
        node.texture = getGemTexture(type)
        node.size = CGSize(width: 30, height: 30)
        node.alpha = 1.0
        node.setScale(1.0)  // 重置缩放
        node.xScale = 1.0   // 确保X轴缩放正确
        node.yScale = 1.0   // 确保Y轴缩放正确
        node.zRotation = 0  // 重置旋转
        node.position = CGPoint.zero  // 重置位置
        
        return node
    }
    
    /// 回收宝石节点到对象池
    func recycleGemNode(_ node: SKSpriteNode) {
        guard PerformanceConfig.enableObjectPooling && gemNodePool.count < maxPoolSize else {
            return
        }
        
        // 完全重置节点状态
        node.removeAllActions()
        node.removeFromParent()
        node.setScale(1.0)
        node.xScale = 1.0
        node.yScale = 1.0
        node.zRotation = 0
        node.alpha = 1.0
        node.position = CGPoint.zero
        
        gemNodePool.append(node)
    }
    
    /// 获取标签节点（从对象池）
    func getLabelNode() -> SKLabelNode {
        let node: SKLabelNode
        
        if PerformanceConfig.enableObjectPooling && !labelNodePool.isEmpty {
            node = labelNodePool.removeLast()
            node.removeAllActions()
            node.removeFromParent()
        } else {
            node = SKLabelNode(fontNamed: FontNames.body)
        }
        
        return node
    }
    
    /// 回收标签节点到对象池
    func recycleLabelNode(_ node: SKLabelNode) {
        guard PerformanceConfig.enableObjectPooling && labelNodePool.count < maxPoolSize else {
            return
        }
        
        node.removeAllActions()
        node.removeFromParent()
        labelNodePool.append(node)
    }
    
    // MARK: - 美术资源配置接口
    
    /// 更新宝石资源配置
    func updateGemAsset(for gemType: GemType, assetName: String) {
        ArtAssets.gemAssets[gemType] = assetName
        // 清除缓存，强制重新加载
        gemTextureCache.removeValue(forKey: gemType)
        textureCache.removeValue(forKey: assetName)
        print("🎨 更新宝石资源: \(gemType) -> \(assetName)")
    }
    
    /// 批量更新宝石资源
    func updateGemAssets(_ assets: [GemType: String]) {
        for (gemType, assetName) in assets {
            updateGemAsset(for: gemType, assetName: assetName)
        }
    }
    
    /// 更新UI资源配置
    func updateUIAsset(for key: String, assetName: String) {
        ArtAssets.uiAssets[key] = assetName
        textureCache.removeValue(forKey: assetName)
        print("🎨 更新UI资源: \(key) -> \(assetName)")
    }
    
    /// 获取当前资源配置
    func getCurrentAssetConfig() -> [String: Any] {
        return [
            "gemAssets": ArtAssets.gemAssets,
            "specialGemAssets": ArtAssets.specialGemAssets,
            "backgroundAssets": ArtAssets.backgroundAssets,
            "uiAssets": ArtAssets.uiAssets,
            "particleAssets": ArtAssets.particleAssets
        ]
    }
    
    // MARK: - 内存管理
    
    /// 清理纹理缓存
    func clearTextureCache() {
        textureCache.removeAll()
        gemTextureCache.removeAll()
        print("🧹 纹理缓存已清理")
    }
    
    /// 清理对象池
    func clearObjectPools() {
        gemNodePool.removeAll()
        labelNodePool.removeAll()
        print("🧹 对象池已清理")
    }
    
    /// 内存警告处理
    func handleMemoryWarning() {
        // 清理一半的缓存
        let halfCount = textureCache.count / 2
        let keysToRemove = Array(textureCache.keys.prefix(halfCount))
        for key in keysToRemove {
            textureCache.removeValue(forKey: key)
        }
        
        // 清理对象池
        gemNodePool.removeAll()
        labelNodePool.removeAll()
        
        print("⚠️ 内存警告 - 已清理部分缓存和对象池")
    }
    
    // MARK: - 颜色配置（保持原有）
    struct Colors {
        // 主题颜色
        static let primaryBlue = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        static let primaryGreen = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        static let primaryRed = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        
        // UI颜色
        static let backgroundPrimary = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        static let backgroundSecondary = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        static let textPrimary = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        static let textSecondary = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        
        // 边框颜色
        static let borderPrimary = UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
        static let borderSecondary = UIColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
        
        // 棋盘格子颜色
        static let cellLight = UIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1.0)
        static let cellDark = UIColor(red: 0.75, green: 0.75, blue: 0.8, alpha: 1.0)
        
        // 战斗UI颜色
        static let healthBarBackground = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
        static let playerHealthBar = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        static let enemyHealthBar = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        static let manaBarBackground = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        static let manaBar = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        static let panelBackground = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.7)
        static let borderColor = UIColor.white
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
    }
    
    // MARK: - 字体配置
    struct FontNames {
        static let title = "Helvetica-Bold"
        static let body = "Helvetica"
        static let ui = "Helvetica-Medium"
        static let combat = "Helvetica-Bold"
    }
} 