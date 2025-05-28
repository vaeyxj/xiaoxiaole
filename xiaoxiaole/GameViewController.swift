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
        // 创建SKView
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        
        // 配置SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
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
}
