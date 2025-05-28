//
//  GameViewController.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    // MARK: - 属性
    var skView: SKView!
    private var gameSceneManager: GameSceneManager!
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSKView()
        setupGameSystems()
        startGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 恢复游戏
        gameSceneManager.resumeCurrentScene()
        AudioSystem.shared.resumeBackgroundMusic()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 暂停游戏
        gameSceneManager.pauseCurrentScene()
        AudioSystem.shared.pauseBackgroundMusic()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新SKView的frame
        skView.frame = view.bounds
    }
    
    // MARK: - 设置方法
    private func setupSKView() {
        // 直接使用Storyboard中已经设置的SKView
        skView = view as! SKView
        
        // 配置SKView
        skView.showsFPS = false  // 发布版本关闭FPS显示
        skView.showsNodeCount = false  // 发布版本关闭节点数显示
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60
        
        print("🎮 SKView 设置完成")
    }
    
    private func setupGameSystems() {
        // 初始化游戏场景管理器
        gameSceneManager = GameSceneManager.shared
        gameSceneManager.initialize(with: self)
        
        // 初始化其他系统
        _ = AudioSystem.shared
        _ = GameManager.shared
        _ = SaveManager.shared
        
        print("🎮 游戏系统初始化完成")
    }
    
    private func startGame() {
        // 启动主菜单场景
        gameSceneManager.transitionToScene(.menu, transition: .none)
        
        print("🎮 游戏启动完成")
    }
    
    // MARK: - 内存管理
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // 处理内存警告
        gameSceneManager.handleMemoryWarning()
        AudioSystem.shared.stopAllSoundEffects()
        
        print("⚠️ 收到内存警告，已清理缓存")
    }
    
    // MARK: - 状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - 屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: - 应用生命周期处理
    func applicationDidEnterBackground() {
        // 应用进入后台
        gameSceneManager.pauseCurrentScene()
        AudioSystem.shared.pauseBackgroundMusic()
        
        // 保存游戏数据
        let gameManager = GameManager.shared
        let gameData = GameSaveData(
            playerStats: gameManager.playerStats,
            currentLevel: gameManager.currentLevel,
            currentFloor: gameManager.currentFloor,
            totalScore: gameManager.totalScore,
            maxCombo: gameManager.maxCombo,
            inventory: gameManager.playerInventory,
            skills: gameManager.playerSkills
        )
        SaveManager.shared.saveGame(gameData)
        
        print("📱 应用进入后台")
    }
    
    func applicationWillEnterForeground() {
        // 应用即将进入前台
        gameSceneManager.resumeCurrentScene()
        AudioSystem.shared.resumeBackgroundMusic()
        
        print("📱 应用进入前台")
    }
    
    func applicationWillTerminate() {
        // 应用即将终止
        let gameManager = GameManager.shared
        let gameData = GameSaveData(
            playerStats: gameManager.playerStats,
            currentLevel: gameManager.currentLevel,
            currentFloor: gameManager.currentFloor,
            totalScore: gameManager.totalScore,
            maxCombo: gameManager.maxCombo,
            inventory: gameManager.playerInventory,
            skills: gameManager.playerSkills
        )
        SaveManager.shared.saveGame(gameData)
        AudioSystem.shared.cleanup()
        
        print("📱 应用即将终止")
    }
    
    // MARK: - 调试方法
    func toggleDebugInfo() {
        skView.showsFPS.toggle()
        skView.showsNodeCount.toggle()
        skView.showsPhysics.toggle()
    }
    
    func getDebugInfo() -> String {
        return """
        🎮 GameViewController 状态:
        SKView Frame: \(skView.frame)
        FPS显示: \(skView.showsFPS ? "开启" : "关闭")
        节点数显示: \(skView.showsNodeCount ? "开启" : "关闭")
        物理显示: \(skView.showsPhysics ? "开启" : "关闭")
        首选帧率: \(skView.preferredFramesPerSecond)
        
        \(gameSceneManager.getDebugInfo())
        """
    }
    
    func debugViewHierarchy() {
        print("🔍 视图层级调试:")
        print("🔍 主视图: \(view)")
        print("🔍 主视图类型: \(type(of: view))")
        print("🔍 主视图子视图数: \(view.subviews.count)")
        print("🔍 SKView: \(skView)")
        print("🔍 SKView === view: \(skView === view)")
        print("🔍 SKView frame: \(skView.frame)")
        print("🔍 SKView bounds: \(skView.bounds)")
        print("🔍 SKView superview: \(skView.superview)")
        print("🔍 SKView 是否隐藏: \(skView.isHidden)")
        print("🔍 SKView alpha: \(skView.alpha)")
        print("🔍 SKView 背景色: \(skView.backgroundColor)")
        
        if let scene = skView.scene {
            print("🔍 当前场景: \(scene)")
            print("🔍 场景类型: \(type(of: scene))")
            print("🔍 场景大小: \(scene.size)")
            print("🔍 场景背景色: \(scene.backgroundColor)")
            print("🔍 场景子节点数: \(scene.children.count)")
            
            // 列出场景的子节点
            for (index, child) in scene.children.enumerated() {
                print("🔍   子节点\(index): \(type(of: child)) - \(child.name ?? "无名称")")
            }
        } else {
            print("🔍 没有当前场景")
        }
        
        // 强制重新布局
        view.setNeedsLayout()
        view.layoutIfNeeded()
        skView.setNeedsDisplay()
        
        print("🔍 已强制重新布局和显示")
    }
}
