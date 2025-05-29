//
//  GameSceneManager.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import SpriteKit
import GameplayKit

// MARK: - 辅助结构体
struct Position: Hashable {
    let x: Int
    let y: Int
}

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
    
    // MARK: - 属性
    weak var sceneManager: GameSceneManager?
    private var isSceneSetup = false
    
    // 游戏系统
    private var boardSystem: MatchBoardSystem!
    private var combatUI: CombatUISystem!
    
    // 游戏状态
    private var gameBoard: [[GemType?]] = []
    private var cellPositions: [String: CGPoint] = [:]
    private var selectedGem: Position?
    
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
        static let transitionDuration: TimeInterval = 0.5  // 调整为更合适的过渡时间
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
        
        return scene
    }
    
    private func setupScene(_ scene: SKScene, type: SceneType) {
        guard let view = gameViewController?.skView else { return }
        
        scene.size = view.bounds.size
        scene.scaleMode = .resizeFill
        
        // 设置场景管理器引用
        if let gameScene = scene as? BaseGameScene {
            gameScene.sceneManager = self
        }
        
        print("🎬 创建场景: \(type)")
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
        
        let oldSceneType = currentSceneType
        
        if pushToStack && currentSceneType != sceneType {
            sceneStack.append(currentSceneType)
        }
        
        let newScene = createScene(type: sceneType)
        newScene.size = gameViewController.skView.bounds.size
        newScene.scaleMode = .resizeFill
        
        let transitionAction = createTransition(type: transition)
        
        if let currentScene = currentScene as? BaseGameScene {
            currentScene.willDisappear()
        }
        
        gameViewController.skView.presentScene(newScene, transition: transitionAction)
        
        currentScene = newScene
        currentSceneType = sceneType
        
        if let newGameScene = newScene as? BaseGameScene {
            newGameScene.didAppear()
        }
        
        playBackgroundMusicForScene(sceneType)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Config.transitionDuration) {
            self.isTransitioning = false
        print("🎬 场景切换完成: \(oldSceneType) -> \(sceneType)")
        }
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
    
    // MARK: - 音乐管理
    private func playBackgroundMusicForScene(_ sceneType: SceneType) {
        switch sceneType {
        case .menu:
            AudioSystem.shared.playBackgroundMusic("menu_theme")
        case .gameplay, .combat:
            AudioSystem.shared.playBackgroundMusic("dungeon_theme")
        case .victory:
            AudioSystem.shared.playBackgroundMusic("victory_theme")
        default:
            break
        }
    }
    
    // MARK: - 场景信息
    func getCurrentScene() -> SKScene? {
        return currentScene
    }
    
    func getCurrentSceneType() -> SceneType {
        return currentSceneType
    }
    
    func getSceneStackCount() -> Int {
        return sceneStack.count
    }
    
    func isSceneInStack(_ sceneType: SceneType) -> Bool {
        return sceneStack.contains(sceneType)
    }
    
    // MARK: - 缓存管理
    func removeSceneFromCache(_ sceneType: SceneType) {
        sceneCache.removeValue(forKey: sceneType)
    }
    
    func clearSceneCache() {
        sceneCache.removeAll()
    }
}

// MARK: - 基础游戏场景类
class BaseGameScene: SKScene {
    weak var sceneManager: GameSceneManager?
    
    func willAppear() {
        // 子类重写此方法来处理场景即将显示的逻辑
    }
    
    func didAppear() {
        // 子类重写此方法来处理场景已显示的逻辑
    }
    
    func willDisappear() {
        // 子类重写此方法来处理场景即将消失的逻辑
    }
    
    func didDisappear() {
        // 子类重写此方法来处理场景已消失的逻辑
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // 定期检测和修复缩放问题（每秒检测一次）
        if currentTime - lastUpdateTime > 1.0 {
            AnimationSystem.shared.detectAndFixScaleIssues(in: self)
            lastUpdateTime = currentTime
        }
    }
    
    private var lastUpdateTime: TimeInterval = 0
}

// MARK: - 具体场景类
class MenuScene: BaseGameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupMenuScene()
    }
    
    private func setupMenuScene() {
        backgroundColor = UIColor.systemOrange
        
        let titleLabel = SKLabelNode(fontNamed: AssetManager.FontNames.title)
        titleLabel.text = "🏰 宝石迷城探险 🏰"
        titleLabel.fontSize = 28
        titleLabel.fontColor = AssetManager.Colors.textPrimary
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        let startButton = createButton(
            text: "🎮 开始游戏",
            position: CGPoint(x: size.width/2, y: size.height * 0.5),
            name: "startButton"
        )
        addChild(startButton)
        
        let settingsButton = createButton(
            text: "⚙️ 设置",
            position: CGPoint(x: size.width/2, y: size.height * 0.4),
            name: "settingsButton"
        )
        addChild(settingsButton)
    }
    
    private func createButton(text: String, position: CGPoint, name: String) -> SKNode {
        let button = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        button.fillColor = AssetManager.Colors.primaryBlue
        button.strokeColor = UIColor.white
        button.lineWidth = 3
        button.position = position
        button.name = name
        
        let label = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        label.text = text
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        AudioSystem.shared.playButtonTapSound()
        
        switch touchedNode.name {
        case "startButton":
            print("🎮 开始游戏")
            sceneManager?.transitionToScene(.gameplay, transition: .fade)
        case "settingsButton":
            print("⚙️ 打开设置")
            sceneManager?.transitionToScene(.settings, transition: .push)
        default:
            break
        }
    }
}

class GameplayScene: BaseGameScene {
    // 游戏状态
    private var gameBoard: [[GemType?]] = []
    private var cellPositions: [String: CGPoint] = [:]
    private var selectedGem: Position?
    private var isSceneSetup = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupGameplayScene()
    }
    
    private func setupGameplayScene() {
        guard !isSceneSetup else { return }
        isSceneSetup = true
        
        // 设置渐变背景
        backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0)
        
        createBackgroundElements()
        createGameBoard()
        createGameUI()
        createControlButtons()
        initializeBoard()
        
        print("🎮 游戏场景设置完成")
    }
    
    private func createBackgroundElements() {
        // 创建顶部装饰条
        let topBar = SKShapeNode(rectOf: CGSize(width: size.width, height: 80))
        topBar.position = CGPoint(x: size.width * 0.5, y: size.height - 40)
        topBar.fillColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.9)
        topBar.strokeColor = UIColor.clear
        topBar.zPosition = 0
        addChild(topBar)
        
        // 添加装饰图案
        for i in 0..<5 {
            let star = SKLabelNode(text: "✨")
            star.fontSize = 16
            star.position = CGPoint(x: 50 + CGFloat(i) * (size.width - 100) / 4, y: size.height - 40)
            star.zPosition = 1
            addChild(star)
        }
    }
    
    private func createGameBoard() {
        // 棋盘容器
        let boardContainer = SKNode()
        boardContainer.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
        boardContainer.zPosition = 2
        addChild(boardContainer)
        
        // 棋盘背景 - 使用圆角矩形和阴影效果
        let boardSize = CGSize(width: 340, height: 340)
        let boardBackground = SKShapeNode(rectOf: boardSize, cornerRadius: 20)
        boardBackground.fillColor = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
        boardBackground.strokeColor = UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0)
        boardBackground.lineWidth = 3
        boardBackground.name = "boardBackground"
        
        // 添加阴影效果
        let shadow = SKShapeNode(rectOf: boardSize, cornerRadius: 20)
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.fillColor = UIColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 0.3)
        shadow.strokeColor = UIColor.clear
        shadow.zPosition = -1
        boardContainer.addChild(shadow)
        
        boardContainer.addChild(boardBackground)
        
        // 创建网格
        let cellSize: CGFloat = 38
        let spacing: CGFloat = 2
        let startX = -boardSize.width * 0.5 + cellSize * 0.5 + 10
        let startY = boardSize.height * 0.5 - cellSize * 0.5 - 10
        
        gameBoard = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        
        for row in 0..<8 {
            for col in 0..<8 {
                let x = startX + CGFloat(col) * (cellSize + spacing)
                let y = startY - CGFloat(row) * (cellSize + spacing)
                
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize), cornerRadius: 8)
                cell.position = CGPoint(x: x, y: y)
                
                // 棋盘格交替颜色
                if (row + col) % 2 == 0 {
                    cell.fillColor = UIColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 1.0)
                } else {
                    cell.fillColor = UIColor(red: 0.88, green: 0.88, blue: 0.94, alpha: 1.0)
                }
                
                cell.strokeColor = UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 0.5)
                cell.lineWidth = 1
                cell.name = "cell_\(row)_\(col)"
                boardContainer.addChild(cell)
                
                // 保存绝对位置（相对于场景）
                let absolutePosition = CGPoint(
                    x: boardContainer.position.x + x,
                    y: boardContainer.position.y + y
                )
                cellPositions["\(row)_\(col)"] = absolutePosition
            }
        }
    }
    
    private func createGameUI() {
        // UI容器
        let uiContainer = SKNode()
        uiContainer.position = CGPoint(x: size.width * 0.5, y: size.height * 0.85)
        uiContainer.zPosition = 10
        addChild(uiContainer)
        
        // 得分面板
        let scorePanel = createInfoPanel(
            title: "得分",
            value: "0",
            position: CGPoint(x: -80, y: 0),
            color: UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        )
        scorePanel.name = "scorePanel"
        uiContainer.addChild(scorePanel)
        
        // 连击面板
        let comboPanel = createInfoPanel(
            title: "连击",
            value: "0",
            position: CGPoint(x: 80, y: 0),
            color: UIColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 1.0)
        )
        comboPanel.name = "comboPanel"
        uiContainer.addChild(comboPanel)
        
        // 关卡信息
        let levelLabel = SKLabelNode(fontNamed: AssetManager.FontNames.title)
        levelLabel.text = "🏰 关卡 1-1"
        levelLabel.fontSize = 18
        levelLabel.fontColor = UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        levelLabel.position = CGPoint(x: 0, y: -40)
        levelLabel.name = "levelLabel"
        uiContainer.addChild(levelLabel)
    }
    
    private func createInfoPanel(title: String, value: String, position: CGPoint, color: UIColor) -> SKNode {
        let panel = SKNode()
        panel.position = position
        
        // 面板背景
        let background = SKShapeNode(rectOf: CGSize(width: 120, height: 50), cornerRadius: 15)
        background.fillColor = color.withAlphaComponent(0.2)
        background.strokeColor = color
        background.lineWidth = 2
        panel.addChild(background)
        
        // 标题
        let titleLabel = SKLabelNode(fontNamed: AssetManager.FontNames.body)
        titleLabel.text = title
        titleLabel.fontSize = 12
        titleLabel.fontColor = color
        titleLabel.position = CGPoint(x: 0, y: 8)
        titleLabel.name = "title"
        panel.addChild(titleLabel)
        
        // 数值
        let valueLabel = SKLabelNode(fontNamed: AssetManager.FontNames.title)
        valueLabel.text = value
        valueLabel.fontSize = 16
        valueLabel.fontColor = color
        valueLabel.position = CGPoint(x: 0, y: -12)
        valueLabel.name = "value"
        panel.addChild(valueLabel)
        
        return panel
    }
    
    private func createControlButtons() {
        // 按钮容器
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: size.width * 0.5, y: size.height * 0.12)
        buttonContainer.zPosition = 10
        addChild(buttonContainer)
        
        // 暂停按钮
        let pauseButton = createStyledButton(
            icon: "⏸",
            text: "暂停",
            position: CGPoint(x: -80, y: 0),
            color: UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0),
            name: "pauseButton"
        )
        buttonContainer.addChild(pauseButton)
        
        // 重置按钮
        let resetButton = createStyledButton(
            icon: "🔄",
            text: "重置",
            position: CGPoint(x: 80, y: 0),
            color: UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 1.0),
            name: "resetButton"
        )
        buttonContainer.addChild(resetButton)
    }
    
    private func createStyledButton(icon: String, text: String, position: CGPoint, color: UIColor, name: String) -> SKNode {
        let button = SKNode()
        button.position = position
        button.name = name
        
        // 按钮背景
        let background = SKShapeNode(rectOf: CGSize(width: 120, height: 45), cornerRadius: 22)
        background.fillColor = color
        background.strokeColor = color.withAlphaComponent(0.8)
        background.lineWidth = 2
        button.addChild(background)
        
        // 按钮阴影
        let shadow = SKShapeNode(rectOf: CGSize(width: 120, height: 45), cornerRadius: 22)
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.2)
        shadow.strokeColor = UIColor.clear
        shadow.zPosition = -1
        button.addChild(shadow)
        
        // 图标
        let iconLabel = SKLabelNode(text: icon)
        iconLabel.fontSize = 20
        iconLabel.position = CGPoint(x: -25, y: -8)
        iconLabel.zPosition = 1
        button.addChild(iconLabel)
        
        // 文字
        let textLabel = SKLabelNode(fontNamed: AssetManager.FontNames.body)
        textLabel.text = text
        textLabel.fontSize = 14
        textLabel.fontColor = UIColor.white
        textLabel.position = CGPoint(x: 10, y: -6)
        textLabel.zPosition = 1
        button.addChild(textLabel)
        
        return button
    }
    
    private func initializeBoard() {
        for row in 0..<8 {
            for col in 0..<8 {
                let gemType = generateRandomGem()
                createGem(at: Position(x: row, y: col), type: gemType)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkForMatches()
        }
    }
    
    private func generateRandomGem() -> GemType {
        let basicGems: [GemType] = [.red, .blue, .green, .yellow, .purple, .white]
        return basicGems.randomElement() ?? .red
    }
    
    private func createGem(at position: Position, type: GemType) {
        guard let cellPosition = cellPositions["\(position.x)_\(position.y)"] else { return }
        
        // 使用对象池获取宝石节点
        let gem = AssetManager.shared.getGemNode(type: type)
        gem.name = "gem_\(position.x)_\(position.y)"
        gem.zPosition = 5
        
        addChild(gem)
        
        // 使用动画系统播放生成动画
        AnimationSystem.shared.animateGemSpawn(gem, at: cellPosition)
        
        gameBoard[position.x][position.y] = type
    }
    
    private func removeGem(at position: Position) {
        if let gem = childNode(withName: "gem_\(position.x)_\(position.y)") as? SKSpriteNode {
            // 使用动画系统播放消除动画
            AnimationSystem.shared.animateGemMatch([gem]) {
                // 动画完成后会自动回收节点到对象池
            }
        }
        
        gameBoard[position.x][position.y] = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if let nodeName = touchedNode.name {
            if nodeName.hasPrefix("gem_") {
                handleGemTouch(nodeName: nodeName, location: location)
            } else if nodeName == "pauseButton" {
                // 使用动画系统播放按钮动画
                AnimationSystem.shared.animateButtonPress(touchedNode) {
                    self.handlePauseButton()
                }
            } else if nodeName == "resetButton" {
                AnimationSystem.shared.animateButtonPress(touchedNode) {
                    self.handleResetButton()
                }
        }
    }
    }
    
    private func handleGemTouch(nodeName: String, location: CGPoint) {
        let components = nodeName.components(separatedBy: "_")
        guard components.count == 3,
              let row = Int(components[1]),
              let col = Int(components[2]) else { return }
        
        if selectedGem == nil {
            selectedGem = Position(x: row, y: col)
            highlightGem(at: Position(x: row, y: col))
        } else if let selected = selectedGem {
            if selected.x == row && selected.y == col {
                unhighlightGem(at: selected)
                selectedGem = nil
            } else if isAdjacent(selected, Position(x: row, y: col)) {
                let targetPosition = Position(x: row, y: col)
                swapGems(from: selected, to: targetPosition)
                unhighlightGem(at: selected)
                selectedGem = nil
            } else {
                unhighlightGem(at: selected)
                selectedGem = Position(x: row, y: col)
                highlightGem(at: Position(x: row, y: col))
            }
        }
    }
    
    private func highlightGem(at position: Position) {
        if let gem = childNode(withName: "gem_\(position.x)_\(position.y)") as? SKSpriteNode {
            AnimationSystem.shared.animateGemHighlight(gem)
        }
    }
    
    private func unhighlightGem(at position: Position) {
        if let gem = childNode(withName: "gem_\(position.x)_\(position.y)") as? SKSpriteNode {
            AnimationSystem.shared.removeGemHighlight(gem)
        }
    }
    
    private func isAdjacent(_ pos1: Position, _ pos2: Position) -> Bool {
        let dx = abs(pos1.x - pos2.x)
        let dy = abs(pos1.y - pos2.y)
        return (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
    }
    
    private func swapGems(from: Position, to: Position) {
        let temp = gameBoard[from.x][from.y]
        gameBoard[from.x][from.y] = gameBoard[to.x][to.y]
        gameBoard[to.x][to.y] = temp
        
        if let gem1 = childNode(withName: "gem_\(from.x)_\(from.y)") as? SKSpriteNode,
           let gem2 = childNode(withName: "gem_\(to.x)_\(to.y)") as? SKSpriteNode {
            
            // 更新节点名称
            gem1.name = "gem_\(to.x)_\(to.y)"
            gem2.name = "gem_\(from.x)_\(from.y)"
            
            // 使用动画系统播放交换动画
            AnimationSystem.shared.animateGemSwap(gem1, gem2) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.checkForMatches()
                }
            }
        }
    }
    
    private func checkForMatches() {
        var matchedPositions: Set<Position> = []
        
        // 检查水平匹配
        for row in 0..<8 {
            var count = 1
            var currentType = gameBoard[row][0]
            
            for col in 1..<8 {
                if gameBoard[row][col] == currentType && currentType != nil {
                    count += 1
                } else {
                    if count >= 3 {
                        for i in (col - count)..<col {
                            matchedPositions.insert(Position(x: row, y: i))
                        }
                    }
                    count = 1
                    currentType = gameBoard[row][col]
                }
            }
            
            if count >= 3 {
                for i in (8 - count)..<8 {
                    matchedPositions.insert(Position(x: row, y: i))
                }
            }
        }
        
        // 检查垂直匹配
        for col in 0..<8 {
            var count = 1
            var currentType = gameBoard[0][col]
            
            for row in 1..<8 {
                if gameBoard[row][col] == currentType && currentType != nil {
                    count += 1
                } else {
                    if count >= 3 {
                        for i in (row - count)..<row {
                            matchedPositions.insert(Position(x: i, y: col))
                        }
                    }
                    count = 1
                    currentType = gameBoard[row][col]
                }
            }
            
            if count >= 3 {
                for i in (8 - count)..<8 {
                    matchedPositions.insert(Position(x: i, y: col))
                }
            }
        }
        
        if !matchedPositions.isEmpty {
            processMatches(matchedPositions)
        }
    }
    
    private func processMatches(_ positions: Set<Position>) {
        let matchCount = positions.count
        let gemType = gameBoard[positions.first!.x][positions.first!.y] ?? .red
        
        // 收集要消除的宝石节点
        var gemsToRemove: [SKSpriteNode] = []
        for position in positions {
            if let gem = childNode(withName: "gem_\(position.x)_\(position.y)") as? SKSpriteNode {
                gemsToRemove.append(gem)
            }
            gameBoard[position.x][position.y] = nil
        }
        
        // 使用动画系统播放消除动画
        AnimationSystem.shared.animateGemMatch(gemsToRemove) {
            self.updateGameUI()
            
            // 添加得分弹出效果
            if let firstGem = gemsToRemove.first {
                let score = matchCount * 10
                AnimationSystem.shared.animateScorePop(score: score, at: firstGem.position, parent: self)
            }
            
            // 如果是连击，添加连击特效
            if GameManager.shared.currentCombo > 1 {
                if let firstGem = gemsToRemove.first {
                    AnimationSystem.shared.animateComboEffect(
                        at: firstGem.position,
                        comboCount: GameManager.shared.currentCombo,
                        parent: self
                    )
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dropGems()
            }
        }
        
        GameManager.shared.processMatch(type: .horizontal(count: matchCount), gemType: gemType, count: matchCount)
    }
    
    private func dropGems() {
        var needsNewGems = false
        var dropAnimations: [SKAction] = []
        
        for col in 0..<8 {
            var writeIndex = 7
            
            for row in stride(from: 7, through: 0, by: -1) {
                if gameBoard[row][col] != nil {
                    if row != writeIndex {
                        gameBoard[writeIndex][col] = gameBoard[row][col]
                        gameBoard[row][col] = nil
                        
                        if let gem = childNode(withName: "gem_\(row)_\(col)") as? SKSpriteNode,
                           let newPosition = cellPositions["\(writeIndex)_\(col)"] {
                            
                            gem.name = "gem_\(writeIndex)_\(col)"
                            
                            // 使用动画系统播放下落动画
                            AnimationSystem.shared.animateGemDrop(gem, to: newPosition)
                        }
                    }
                    writeIndex -= 1
                }
            }
            
            // 只有当writeIndex >= 0时才生成新宝石
            if writeIndex >= 0 {
                for row in 0...writeIndex {
                    let gemType = generateRandomGem()
                    gameBoard[row][col] = gemType
                    
                    if let cellPosition = cellPositions["\(row)_\(col)"] {
                        // 使用对象池创建新宝石
                        let gem = AssetManager.shared.getGemNode(type: gemType)
                        gem.name = "gem_\(row)_\(col)"
                        gem.zPosition = 5
                        addChild(gem)
                        
                        // 使用动画系统播放生成动画
                        AnimationSystem.shared.animateGemSpawn(gem, at: cellPosition)
                    }
                    needsNewGems = true
                }
            }
        }
        
        if needsNewGems {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.checkForMatches()
            }
        }
    }
    
    private func updateGameUI() {
        // 更新得分面板
        if let scorePanel = childNode(withName: "scorePanel") as? SKNode {
            if let scoreValue = scorePanel.childNode(withName: "value") as? SKLabelNode {
                scoreValue.text = "\(GameManager.shared.totalScore)"
            }
        }
        
        // 更新连击面板
        if let comboPanel = childNode(withName: "comboPanel") as? SKNode {
            if let comboValue = comboPanel.childNode(withName: "value") as? SKLabelNode {
                comboValue.text = "\(GameManager.shared.currentCombo)"
            }
        }
        
        // 更新关卡信息
        if let levelLabel = childNode(withName: "levelLabel") as? SKLabelNode {
            levelLabel.text = "🏰 关卡 \(GameManager.shared.currentLevel)-\(GameManager.shared.currentFloor)"
                }
            }
    
    private func handlePauseButton() {
        GameManager.shared.pauseGame()
    }
    
    private func handleResetButton() {
        GameManager.shared.resetCurrentLevel()
        removeAllChildren()
        isSceneSetup = false
        setupGameplayScene()
    }
}

// MARK: - 其他场景类的简单实现
class CombatScene: BaseGameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.systemRed
        
        let label = SKLabelNode(text: "战斗场景")
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        }
    }
    
class ShopScene: BaseGameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.systemGreen
        
        let label = SKLabelNode(text: "商店场景")
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
}

class InventoryScene: BaseGameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.systemPurple
        
        let label = SKLabelNode(text: "物品栏场景")
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        }
    }
    
class SettingsScene: BaseGameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.systemGray
        
        let label = SKLabelNode(text: "设置场景")
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
}

class GameOverScene: BaseGameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.systemRed
        
        let label = SKLabelNode(text: "游戏结束")
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
}

class VictoryScene: BaseGameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.systemYellow
        
        let label = SKLabelNode(text: "胜利！")
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
}

class LoadingScene: BaseGameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.systemBlue
        
        let label = SKLabelNode(text: "加载中...")
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
} 