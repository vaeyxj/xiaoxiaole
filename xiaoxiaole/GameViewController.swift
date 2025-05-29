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
        // 恢复游戏场景（如果需要）
        if let currentScene = gameSceneManager.getCurrentScene() {
            currentScene.isPaused = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 暂停游戏场景
        if let currentScene = gameSceneManager.getCurrentScene() {
            currentScene.isPaused = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新SKView的frame
        skView.frame = view.bounds
    }
    
    // MARK: - 设置方法
    private func setupSKView() {
        // 直接使用Storyboard中已设置的SKView
        skView = view as! SKView
        
        // 配置SKView
        skView.showsFPS = false  // 发布版本关闭FPS显示
        skView.showsNodeCount = false  // 发布版本关闭节点数显示
        skView.ignoresSiblingOrder = true
        
        print("🎮 SKView设置完成")
        print("🎮 SKView大小: \(skView.bounds.size)")
        print("🎮 SKView类型: \(type(of: skView))")
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
        // 清理场景缓存
        gameSceneManager.clearSceneCache()
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
    
    // MARK: - 应用生命周期
    @objc private func applicationWillResignActive() {
        // 应用即将失去焦点时暂停游戏
        if let currentScene = gameSceneManager.getCurrentScene() {
            currentScene.isPaused = true
        }
    }
    
    @objc private func applicationDidBecomeActive() {
        // 应用重新获得焦点时恢复游戏
        if let currentScene = gameSceneManager.getCurrentScene() {
            currentScene.isPaused = false
        }
    }
    
    // MARK: - 调试信息
    private func printDebugInfo() {
        print("""
        🔍 GameViewController 调试信息:
        当前场景类型: \(gameSceneManager.getCurrentSceneType())
        场景栈深度: \(gameSceneManager.getSceneStackCount())
        """)
        
        print("🔍 主视图: \(String(describing: view))")
        print("🔍 主视图类型: \(type(of: view))")
        print("🔍 主视图大小: \(view.bounds.size)")
        print("🔍 SKView: \(String(describing: skView))")
        print("🔍 SKView类型: \(type(of: skView))")
        print("🔍 SKView大小: \(skView.bounds.size)")
        print("🔍 SKView superview: \(String(describing: skView.superview))")
        print("🔍 SKView frame: \(skView.frame)")
        print("🔍 SKView bounds: \(skView.bounds)")
        print("🔍 SKView 背景色: \(String(describing: skView.backgroundColor))")
        print("🔍 SKView 子视图数量: \(skView.subviews.count)")
        
        if let scene = skView.scene {
            print("🔍 当前场景: \(type(of: scene))")
            print("🔍 场景大小: \(scene.size)")
            print("🔍 场景缩放模式: \(scene.scaleMode.rawValue)")
        } else {
            print("🔍 当前没有场景")
        }
    }
}
