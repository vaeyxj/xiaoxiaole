//
//  GameSceneManager.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import SpriteKit
import GameplayKit

/// 游戏场景管理器 - 负责不同游戏场景的切换和管理
class GameSceneManager {
    static let shared = GameSceneManager()
    
    // MARK: - 场景类型
    enum SceneType {
        case menu           // 主菜单
        case gameplay       // 游戏玩法
        case combat         // 战斗场景
        case shop           // 商店
        case inventory      // 物品栏
        case settings       // 设置
        case gameOver       // 游戏结束
        case victory        // 胜利
        case loading        // 加载场景
        case none           // 无场景状态（初始状态）
    }
    
    // MARK: - 场景转换类型
    enum TransitionType {
        case none           // 无转换
        case fade           // 淡入淡出
        case push           // 推入
        case reveal         // 揭示
        case flipHorizontal // 水平翻转
        case flipVertical   // 垂直翻转
        case doorway        // 门户效果
        case crossFade      // 交叉淡化
    }
    
    // MARK: - 私有属性
    private weak var gameViewController: GameViewController?
    private var currentScene: SKScene?
    private var currentSceneType: SceneType = .none  // 初始状态为无场景
    private var sceneStack: [SceneType] = []
    private var isTransitioning = false
    
    // 场景缓存
    private var sceneCache: [SceneType: SKScene] = [:]
    
    // 配置
    struct Config {
        static let transitionDuration: TimeInterval = 0.5
        static let maxCachedScenes = 3
        static let preloadScenes: [SceneType] = [.menu, .gameplay, .combat]
    }
    
    private init() {}
    
    // MARK: - 初始化
    func initialize(with gameViewController: GameViewController) {
        self.gameViewController = gameViewController
        preloadScenes()
    }
    
    private func preloadScenes() {
        for sceneType in Config.preloadScenes {
            _ = createScene(type: sceneType)
        }
        print("🎬 场景预加载完成")
    }
    
    // MARK: - 场景创建
    private func createScene(type: SceneType) -> SKScene {
        if let cachedScene = sceneCache[type] {
            return cachedScene
        }
        
        let scene: SKScene
        
        switch type {
        case .menu:
            scene = MenuScene()
        case .gameplay:
            scene = GameplayScene()
        case .combat:
            scene = CombatScene()
        case .shop:
            scene = ShopScene()
        case .inventory:
            scene = InventoryScene()
        case .settings:
            scene = SettingsScene()
        case .gameOver:
            scene = GameOverScene()
        case .victory:
            scene = VictoryScene()
        case .loading:
            scene = LoadingScene()
        case .none:
            fatalError("无场景状态不应出现在场景创建中")
        }
        
        // 设置场景基本属性
        setupScene(scene, type: type)
        
        // 缓存场景
        cacheScene(scene, type: type)
        
        return scene
    }
    
    private func setupScene(_ scene: SKScene, type: SceneType) {
        guard let view = gameViewController?.skView else { return }
        
        scene.size = view.bounds.size
        scene.scaleMode = .aspectFill
        
        // 设置场景管理器引用
        if let gameScene = scene as? BaseGameScene {
            gameScene.sceneManager = self
        }
        
        print("🎬 创建场景: \(type)")
    }
    
    private func cacheScene(_ scene: SKScene, type: SceneType) {
        // 如果缓存已满，移除最旧的场景
        if sceneCache.count >= Config.maxCachedScenes {
            let oldestType = sceneCache.keys.first!
            sceneCache.removeValue(forKey: oldestType)
        }
        
        sceneCache[type] = scene
    }
    
    // MARK: - 场景切换
    func transitionToScene(_ sceneType: SceneType, transition: TransitionType = .fade, pushToStack: Bool = true) {
        guard !isTransitioning else {
            print("⚠️ 场景正在转换中，忽略请求")
            return
        }
        
        guard let gameViewController = gameViewController else {
            print("❌ GameViewController 未设置")
            return
        }
        
        isTransitioning = true
        
        // 保存旧的场景类型用于日志
        let oldSceneType = currentSceneType
        
        // 添加到场景栈
        if pushToStack && currentSceneType != sceneType {
            sceneStack.append(currentSceneType)
        }
        
        let newScene = createScene(type: sceneType)
        let transitionAction = createTransition(type: transition)
        
        // 场景切换前的清理
        if let currentScene = currentScene as? BaseGameScene {
            currentScene.willDisappear()
        }
        
        // 执行场景切换
        gameViewController.skView.presentScene(newScene, transition: transitionAction)
        
        // 更新当前场景信息
        currentScene = newScene
        currentSceneType = sceneType
        
        // 场景切换后的初始化
        if let newGameScene = newScene as? BaseGameScene {
            newGameScene.didAppear()
        }
        
        // 播放对应的背景音乐
        playBackgroundMusicForScene(sceneType)
        
        // 延迟重置转换状态
        DispatchQueue.main.asyncAfter(deadline: .now() + Config.transitionDuration) {
            self.isTransitioning = false
        }
        
        print("🎬 场景切换: \(oldSceneType) -> \(sceneType)")
    }
    
    private func createTransition(type: TransitionType) -> SKTransition {
        let duration = Config.transitionDuration
        
        switch type {
        case .none:
            return SKTransition.fade(withDuration: 0)
        case .fade:
            return SKTransition.fade(withDuration: duration)
        case .push:
            return SKTransition.push(with: .left, duration: duration)
        case .reveal:
            return SKTransition.reveal(with: .left, duration: duration)
        case .flipHorizontal:
            return SKTransition.flipHorizontal(withDuration: duration)
        case .flipVertical:
            return SKTransition.flipVertical(withDuration: duration)
        case .doorway:
            return SKTransition.doorway(withDuration: duration)
        case .crossFade:
            return SKTransition.crossFade(withDuration: duration)
        }
    }
    
    // MARK: - 场景栈管理
    func popScene(transition: TransitionType = .fade) {
        guard !sceneStack.isEmpty else {
            print("⚠️ 场景栈为空，无法返回")
            return
        }
        
        let previousSceneType = sceneStack.removeLast()
        transitionToScene(previousSceneType, transition: transition, pushToStack: false)
    }
    
    func popToRootScene(transition: TransitionType = .fade) {
        guard !sceneStack.isEmpty else { return }
        
        let rootSceneType = sceneStack.first!
        sceneStack.removeAll()
        transitionToScene(rootSceneType, transition: transition, pushToStack: false)
    }
    
    func clearSceneStack() {
        sceneStack.removeAll()
    }
    
    // MARK: - 背景音乐管理
    private func playBackgroundMusicForScene(_ sceneType: SceneType) {
        let audioSystem = AudioSystem.shared
        
        switch sceneType {
        case .menu:
            audioSystem.playBackgroundMusic("menu_theme")
        case .gameplay, .combat:
            audioSystem.playBackgroundMusic("dungeon_theme")
        case .shop, .inventory:
            audioSystem.playBackgroundMusic("shop_theme")
        case .victory:
            audioSystem.playBackgroundMusic("victory_theme", loop: false)
        case .gameOver:
            audioSystem.playBackgroundMusic("game_over_theme", loop: false)
        case .settings, .loading:
            // 设置和加载场景不改变背景音乐
            break
        case .none:
            fatalError("无场景状态不应出现在背景音乐管理中")
        }
    }
    
    // MARK: - 场景状态管理
    func pauseCurrentScene() {
        currentScene?.isPaused = true
        if let gameScene = currentScene as? BaseGameScene {
            gameScene.pauseGame()
        }
    }
    
    func resumeCurrentScene() {
        currentScene?.isPaused = false
        if let gameScene = currentScene as? BaseGameScene {
            gameScene.resumeGame()
        }
    }
    
    func getCurrentSceneType() -> SceneType {
        return currentSceneType
    }
    
    func getCurrentScene() -> SKScene? {
        return currentScene
    }
    
    // MARK: - 场景缓存管理
    func clearSceneCache() {
        sceneCache.removeAll()
        print("🎬 场景缓存已清理")
    }
    
    func removeSceneFromCache(_ sceneType: SceneType) {
        sceneCache.removeValue(forKey: sceneType)
    }
    
    // MARK: - 内存管理
    func handleMemoryWarning() {
        // 清理非当前场景的缓存
        let currentType = currentSceneType
        sceneCache = sceneCache.filter { $0.key == currentType }
        print("🎬 内存警告：清理场景缓存")
    }
    
    // MARK: - 调试信息
    func getDebugInfo() -> String {
        return """
        🎬 场景管理器状态:
        当前场景: \(currentSceneType)
        场景栈: \(sceneStack)
        缓存场景数: \(sceneCache.count)
        正在转换: \(isTransitioning ? "是" : "否")
        """
    }
}

// MARK: - 基础游戏场景协议
protocol BaseGameScene: AnyObject {
    var sceneManager: GameSceneManager? { get set }
    
    func willAppear()
    func didAppear()
    func willDisappear()
    func didDisappear()
    func pauseGame()
    func resumeGame()
}

// MARK: - 具体场景类
class MenuScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    
    override func didMove(to view: SKView) {
        setupMenuScene()
    }
    
    private func setupMenuScene() {
        backgroundColor = AssetManager.Colors.backgroundPrimary
        
        // 创建标题
        let titleLabel = SKLabelNode(fontNamed: AssetManager.FontNames.title)
        titleLabel.text = "宝石迷城探险"
        titleLabel.fontSize = 32
        titleLabel.fontColor = AssetManager.Colors.textPrimary
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        addChild(titleLabel)
        
        // 创建开始游戏按钮
        let startButton = createButton(text: "开始游戏", position: CGPoint(x: size.width/2, y: size.height * 0.5))
        startButton.name = "startButton"
        addChild(startButton)
        
        // 创建设置按钮
        let settingsButton = createButton(text: "设置", position: CGPoint(x: size.width/2, y: size.height * 0.4))
        settingsButton.name = "settingsButton"
        addChild(settingsButton)
        
        print("🎮 主菜单场景设置完成")
    }
    
    private func createButton(text: String, position: CGPoint) -> SKNode {
        let button = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        button.fillColor = AssetManager.Colors.primaryBlue
        button.strokeColor = AssetManager.Colors.textPrimary
        button.position = position
        
        let label = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        label.text = text
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        print("🎮 触摸位置: \(location)")
        print("🎮 触摸节点: \(touchedNode.name ?? "无名称")")
        print("🎮 触摸节点类型: \(type(of: touchedNode))")
        
        AudioSystem.shared.playButtonTapSound()
        
        // 检查是否点击了按钮或按钮内的标签
        var targetNode = touchedNode
        if touchedNode.name == nil && touchedNode.parent?.name != nil {
            targetNode = touchedNode.parent!
            print("🎮 使用父节点: \(targetNode.name ?? "无名称")")
        }
        
        // 如果还是没有名称，检查是否在按钮区域内
        if targetNode.name == nil {
            // 检查所有子节点，看是否点击在按钮区域内
            for child in children {
                if let button = child as? SKShapeNode, button.contains(location) {
                    targetNode = button
                    print("🎮 通过区域检测找到按钮: \(targetNode.name ?? "无名称")")
                    break
                }
            }
        }
        
        switch targetNode.name {
        case "startButton":
            print("🎮 点击开始游戏按钮")
            sceneManager?.transitionToScene(.gameplay, transition: .fade)
        case "settingsButton":
            print("🎮 点击设置按钮")
            sceneManager?.transitionToScene(.settings, transition: .push)
        default:
            print("🎮 点击了其他区域")
            break
        }
    }
    
    // MARK: - BaseGameScene
    func willAppear() {}
    func didAppear() {}
    func willDisappear() {}
    func didDisappear() {}
    func pauseGame() {}
    func resumeGame() {}
}

class GameplayScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    
    private var boardSystem: MatchBoardSystem!
    private var combatUI: CombatUISystem!
    
    override func didMove(to view: SKView) {
        setupGameplayScene()
    }
    
    private func setupGameplayScene() {
        backgroundColor = AssetManager.Colors.backgroundSecondary
        
        // 添加明显的标题标识
        let titleLabel = SKLabelNode(fontNamed: AssetManager.FontNames.title)
        titleLabel.text = "游戏场景"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .red  // 使用红色，确保明显
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.9)
        addChild(titleLabel)
        
        // 添加返回按钮
        let backButton = createBackButton()
        backButton.name = "backButton"
        addChild(backButton)
        
        // 初始化棋盘系统
        boardSystem = MatchBoardSystem.shared
        boardSystem.setGameManager(GameManager.shared)
        
        // 初始化战斗UI
        combatUI = CombatUISystem()
        combatUI.setGameManager(GameManager.shared)
        combatUI.position = CGPoint(x: size.width * 0.8, y: size.height * 0.5)
        addChild(combatUI)
        
        // 创建棋盘视图
        setupBoardView()
        
        print("🎮 游戏场景初始化完成")
    }
    
    private func createBackButton() -> SKNode {
        let button = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 8)
        button.fillColor = AssetManager.Colors.primaryBlue
        button.strokeColor = AssetManager.Colors.textPrimary
        button.position = CGPoint(x: 80, y: size.height - 50)
        
        let label = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        label.text = "返回菜单"
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    private func setupBoardView() {
        // 这里将在后续实现棋盘视图
        let boardBackground = SKShapeNode(rectOf: CGSize(width: 400, height: 400))
        boardBackground.fillColor = .darkGray
        boardBackground.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
        addChild(boardBackground)
        
        let boardLabel = SKLabelNode(text: "棋盘区域")
        boardLabel.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
        addChild(boardLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        print("🎮 游戏场景触摸位置: \(location)")
        print("🎮 游戏场景触摸节点: \(touchedNode.name ?? "无名称")")
        
        AudioSystem.shared.playButtonTapSound()
        
        // 检查是否点击了按钮或按钮内的标签
        var targetNode = touchedNode
        if touchedNode.name == nil && touchedNode.parent?.name != nil {
            targetNode = touchedNode.parent!
        }
        
        switch targetNode.name {
        case "backButton":
            print("🎮 点击返回菜单按钮")
            sceneManager?.popScene(transition: .fade)
        default:
            print("🎮 点击了游戏场景其他区域")
            break
        }
    }
    
    // MARK: - BaseGameScene
    func willAppear() {
        GameManager.shared.startNewGame()
    }
    
    func didAppear() {
        combatUI.updateUI()
    }
    
    func willDisappear() {}
    func didDisappear() {}
    
    func pauseGame() {
        isPaused = true
    }
    
    func resumeGame() {
        isPaused = false
    }
}

// 其他场景类的简化实现
class CombatScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    func willAppear() {}
    func didAppear() {}
    func willDisappear() {}
    func didDisappear() {}
    func pauseGame() {}
    func resumeGame() {}
}

class ShopScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    func willAppear() {}
    func didAppear() {}
    func willDisappear() {}
    func didDisappear() {}
    func pauseGame() {}
    func resumeGame() {}
}

class InventoryScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    func willAppear() {}
    func didAppear() {}
    func willDisappear() {}
    func didDisappear() {}
    func pauseGame() {}
    func resumeGame() {}
}

class SettingsScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    
    override func didMove(to view: SKView) {
        setupSettingsScene()
    }
    
    private func setupSettingsScene() {
        backgroundColor = AssetManager.Colors.backgroundSecondary
        
        // 创建标题
        let titleLabel = SKLabelNode(fontNamed: AssetManager.FontNames.title)
        titleLabel.text = "设置"
        titleLabel.fontSize = 28
        titleLabel.fontColor = AssetManager.Colors.textPrimary
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.8)
        addChild(titleLabel)
        
        // 音量设置区域
        setupVolumeControls()
        
        // 返回按钮
        let backButton = createButton(text: "返回", position: CGPoint(x: size.width/2, y: size.height * 0.2))
        backButton.name = "backButton"
        addChild(backButton)
        
        print("🎮 设置场景设置完成")
    }
    
    private func setupVolumeControls() {
        let audioSystem = AudioSystem.shared
        
        // 主音量标签
        let masterVolumeLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        masterVolumeLabel.text = "主音量: \(Int(audioSystem.getMasterVolume() * 100))%"
        masterVolumeLabel.fontSize = 16
        masterVolumeLabel.fontColor = AssetManager.Colors.textPrimary
        masterVolumeLabel.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        masterVolumeLabel.name = "masterVolumeLabel"
        addChild(masterVolumeLabel)
        
        // 音乐音量标签
        let musicVolumeLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        musicVolumeLabel.text = "音乐音量: \(Int(audioSystem.getMusicVolume() * 100))%"
        musicVolumeLabel.fontSize = 16
        musicVolumeLabel.fontColor = AssetManager.Colors.textPrimary
        musicVolumeLabel.position = CGPoint(x: size.width/2, y: size.height * 0.5)
        musicVolumeLabel.name = "musicVolumeLabel"
        addChild(musicVolumeLabel)
        
        // 音效音量标签
        let soundVolumeLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        soundVolumeLabel.text = "音效音量: \(Int(audioSystem.getSoundEffectVolume() * 100))%"
        soundVolumeLabel.fontSize = 16
        soundVolumeLabel.fontColor = AssetManager.Colors.textPrimary
        soundVolumeLabel.position = CGPoint(x: size.width/2, y: size.height * 0.4)
        soundVolumeLabel.name = "soundVolumeLabel"
        addChild(soundVolumeLabel)
        
        // 静音按钮
        let muteButton = createButton(
            text: audioSystem.isAudioMuted() ? "取消静音" : "静音", 
            position: CGPoint(x: size.width/2, y: size.height * 0.3)
        )
        muteButton.name = "muteButton"
        addChild(muteButton)
    }
    
    private func createButton(text: String, position: CGPoint) -> SKNode {
        let button = SKShapeNode(rectOf: CGSize(width: 160, height: 40), cornerRadius: 8)
        button.fillColor = AssetManager.Colors.primaryBlue
        button.strokeColor = AssetManager.Colors.textPrimary
        button.position = position
        
        let label = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        label.text = text
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        print("🎮 触摸位置: \(location)")
        print("🎮 触摸节点: \(touchedNode.name ?? "无名称")")
        print("🎮 触摸节点类型: \(type(of: touchedNode))")
        
        AudioSystem.shared.playButtonTapSound()
        
        // 检查是否点击了按钮或按钮内的标签
        var targetNode = touchedNode
        if touchedNode.name == nil && touchedNode.parent?.name != nil {
            targetNode = touchedNode.parent!
            print("🎮 使用父节点: \(targetNode.name ?? "无名称")")
        }
        
        // 如果还是没有名称，检查是否在按钮区域内
        if targetNode.name == nil {
            // 检查所有子节点，看是否点击在按钮区域内
            for child in children {
                if let button = child as? SKShapeNode, button.contains(location) {
                    targetNode = button
                    print("🎮 通过区域检测找到按钮: \(targetNode.name ?? "无名称")")
                    break
                }
            }
        }
        
        switch targetNode.name {
        case "backButton":
            print("🎮 点击返回按钮")
            sceneManager?.popScene(transition: .push)
        case "muteButton":
            print("🎮 点击静音按钮")
            let audioSystem = AudioSystem.shared
            audioSystem.toggleMute()
            updateMuteButton()
        default:
            print("🎮 点击了设置界面其他区域")
            break
        }
    }
    
    private func updateMuteButton() {
        if let muteButton = childNode(withName: "muteButton") as? SKShapeNode,
           let label = muteButton.children.first as? SKLabelNode {
            let audioSystem = AudioSystem.shared
            label.text = audioSystem.isAudioMuted() ? "取消静音" : "静音"
        }
    }
    
    // MARK: - BaseGameScene
    func willAppear() {}
    func didAppear() {}
    func willDisappear() {}
    func didDisappear() {}
    func pauseGame() {}
    func resumeGame() {}
}

class GameOverScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    func willAppear() {}
    func didAppear() {}
    func willDisappear() {}
    func didDisappear() {}
    func pauseGame() {}
    func resumeGame() {}
}

class VictoryScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    func willAppear() {}
    func didAppear() {}
    func willDisappear() {}
    func didDisappear() {}
    func pauseGame() {}
    func resumeGame() {}
}

class LoadingScene: SKScene, BaseGameScene {
    weak var sceneManager: GameSceneManager?
    func willAppear() {}
    func didAppear() {}
    func willDisappear() {}
    func didDisappear() {}
    func pauseGame() {}
    func resumeGame() {}
} 