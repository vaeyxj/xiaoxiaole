//
//  AudioSystem.swift
//  xiaoxiaole
//
//  Created by Developer on 2024/1/1.
//

import Foundation
import AVFoundation
import SpriteKit

/// 音效系统 - 负责游戏中所有音效和背景音乐的播放管理
class AudioSystem {
    static let shared = AudioSystem()
    
    // MARK: - 音频播放器
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    private var audioEngine = AVAudioEngine()
    
    // MARK: - 音量设置
    private var masterVolume: Float = 1.0
    private var musicVolume: Float = 0.8
    private var soundEffectVolume: Float = 1.0
    private var isMuted: Bool = false
    
    // MARK: - 当前播放状态
    private var currentBackgroundMusic: String?
    private var isBackgroundMusicPlaying: Bool = false
    
    // MARK: - 音效缓存
    private var soundCache: [String: Data] = [:]
    private var musicCache: [String: Data] = [:]
    
    // MARK: - 配置
    struct AudioConfig {
        static let maxSoundEffectPlayers = 10
        static let fadeInDuration: TimeInterval = 1.0
        static let fadeOutDuration: TimeInterval = 0.5
        static let crossFadeDuration: TimeInterval = 2.0
        static let enableMissingFileWarnings = false // 是否显示缺失文件警告
    }
    
    private init() {
        setupAudioSession()
        loadAudioCache()
    }
    
    // MARK: - 音频会话设置
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            
            // 监听音频中断
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioInterruption),
                name: AVAudioSession.interruptionNotification,
                object: nil
            )
            
            print("🔊 音频会话设置成功")
        } catch {
            print("❌ 音频会话设置失败: \(error.localizedDescription)")
        }
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // 音频中断开始，暂停背景音乐
            pauseBackgroundMusic()
        case .ended:
            // 音频中断结束，恢复背景音乐
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resumeBackgroundMusic()
                }
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - 音效缓存加载
    private func loadAudioCache() {
        // 预加载常用音效到内存
        let commonSounds = [
            "gem_match", "gem_drop", "enemy_hit", "player_hurt",
            "button_tap", "victory", "game_over", "level_up"
        ]
        
        for soundName in commonSounds {
            loadSoundToCache(soundName)
        }
        
        print("🔊 音效缓存加载完成")
    }
    
    private func loadSoundToCache(_ soundName: String) {
        // 尝试多个可能的路径
        let possiblePaths = [
            "Audio/SoundEffects/\(soundName)",
            soundName
        ]
        
        var soundURL: URL?
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "wav") {
                soundURL = url
                break
            }
        }
        
        guard let url = soundURL else {
            if AudioConfig.enableMissingFileWarnings {
                print("⚠️ 音效文件未找到: \(soundName).wav，使用静默模式")
            }
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            soundCache[soundName] = data
        } catch {
            if AudioConfig.enableMissingFileWarnings {
                print("❌ 音效加载失败: \(soundName) - \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 背景音乐控制
    func playBackgroundMusic(_ musicName: String, loop: Bool = true, fadeIn: Bool = true) {
        // 如果已经在播放相同音乐，直接返回
        if currentBackgroundMusic == musicName && isBackgroundMusicPlaying {
            return
        }
        
        // 停止当前背景音乐
        if isBackgroundMusicPlaying {
            stopBackgroundMusic(fadeOut: true)
        }
        
        // 尝试多个可能的路径
        let possiblePaths = [
            "Audio/BackgroundMusic/\(musicName)",
            musicName
        ]
        
        var musicURL: URL?
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "mp3") {
                musicURL = url
                break
            }
        }
        
        guard let url = musicURL else {
            if AudioConfig.enableMissingFileWarnings {
                print("⚠️ 背景音乐文件未找到: \(musicName).mp3，跳过播放")
            }
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundMusicPlayer?.volume = fadeIn ? 0.0 : (musicVolume * masterVolume)
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
            
            currentBackgroundMusic = musicName
            isBackgroundMusicPlaying = true
            
            if fadeIn {
                fadeInBackgroundMusic()
            }
            
            print("🎵 开始播放背景音乐: \(musicName)")
        } catch {
            if AudioConfig.enableMissingFileWarnings {
                print("❌ 背景音乐播放失败: \(error.localizedDescription)")
            }
        }
    }
    
    func stopBackgroundMusic(fadeOut: Bool = false) {
        guard let player = backgroundMusicPlayer, isBackgroundMusicPlaying else { return }
        
        if fadeOut {
            fadeOutBackgroundMusic {
                player.stop()
                self.isBackgroundMusicPlaying = false
                self.currentBackgroundMusic = nil
            }
        } else {
            player.stop()
            isBackgroundMusicPlaying = false
            currentBackgroundMusic = nil
        }
        
        print("🎵 停止背景音乐")
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
        print("🎵 暂停背景音乐")
    }
    
    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
        print("🎵 恢复背景音乐")
    }
    
    // MARK: - 音效播放
    func playSoundEffect(_ soundName: String, volume: Float = 1.0) {
        guard !isMuted else { return }
        
        // 从缓存或文件加载音效
        let soundData: Data?
        if let cachedData = soundCache[soundName] {
            soundData = cachedData
        } else {
            // 尝试多个可能的路径
            let possiblePaths = [
                "Audio/SoundEffects/\(soundName)",
                soundName
            ]
            
            var soundURL: URL?
            for path in possiblePaths {
                if let url = Bundle.main.url(forResource: path, withExtension: "wav") {
                    soundURL = url
                    break
                }
            }
            
            guard let url = soundURL else {
                if AudioConfig.enableMissingFileWarnings {
                    print("⚠️ 音效文件未找到: \(soundName).wav，跳过播放")
                }
                return
            }
            soundData = try? Data(contentsOf: url)
        }
        
        guard let data = soundData else {
            if AudioConfig.enableMissingFileWarnings {
                print("❌ 音效数据加载失败: \(soundName)")
            }
            return
        }
        
        do {
            let player = try AVAudioPlayer(data: data)
            player.volume = volume * soundEffectVolume * masterVolume
            player.prepareToPlay()
            player.play()
            
            // 缓存播放器，播放完成后自动清理
            soundEffectPlayers[soundName] = player
            
            // 设置播放完成回调
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.1) {
                self.soundEffectPlayers.removeValue(forKey: soundName)
            }
            
        } catch {
            if AudioConfig.enableMissingFileWarnings {
                print("❌ 音效播放失败: \(soundName) - \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 游戏特定音效
    func playGemMatchSound(gemType: GemType, comboCount: Int = 1) {
        let baseSoundName = "gem_match"
        let volume = min(1.0, 0.7 + Float(comboCount) * 0.1) // 连击时音量稍微增加
        playSoundEffect(baseSoundName, volume: volume)
        
        // 连击时播放额外音效
        if comboCount > 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.playSoundEffect("combo_\(min(comboCount, 5))", volume: 0.8)
            }
        }
    }
    
    func playGemDropSound() {
        playSoundEffect("gem_drop", volume: 0.6)
    }
    
    func playAttackSound(isPlayerAttack: Bool, isCritical: Bool = false) {
        let soundName = isPlayerAttack ? "player_attack" : "enemy_attack"
        let volume: Float = isCritical ? 1.0 : 0.8
        playSoundEffect(soundName, volume: volume)
        
        if isCritical {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.playSoundEffect("critical_hit", volume: 0.9)
            }
        }
    }
    
    func playHurtSound(isPlayer: Bool) {
        let soundName = isPlayer ? "player_hurt" : "enemy_hurt"
        playSoundEffect(soundName, volume: 0.8)
    }
    
    func playVictorySound() {
        playSoundEffect("victory", volume: 1.0)
    }
    
    func playDefeatSound() {
        playSoundEffect("game_over", volume: 1.0)
    }
    
    func playLevelUpSound() {
        playSoundEffect("level_up", volume: 0.9)
    }
    
    func playButtonTapSound() {
        playSoundEffect("button_tap", volume: 0.5)
    }
    
    func playSkillSound(skillType: SkillType) {
        let soundName: String
        switch skillType {
        case .heal:
            soundName = "skill_heal"
        case .attack:
            soundName = "skill_attack"
        case .defense:
            soundName = "skill_defense"
        case .special:
            soundName = "skill_special"
        }
        playSoundEffect(soundName, volume: 0.8)
    }
    
    // MARK: - 音量控制
    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0.0, min(1.0, volume))
        updateAllVolumes()
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = max(0.0, min(1.0, volume))
        backgroundMusicPlayer?.volume = musicVolume * masterVolume
    }
    
    func setSoundEffectVolume(_ volume: Float) {
        soundEffectVolume = max(0.0, min(1.0, volume))
        updateSoundEffectVolumes()
    }
    
    func setMuted(_ muted: Bool) {
        isMuted = muted
        if muted {
            backgroundMusicPlayer?.volume = 0
            stopAllSoundEffects()
        } else {
            updateAllVolumes()
        }
    }
    
    private func updateAllVolumes() {
        backgroundMusicPlayer?.volume = isMuted ? 0 : (musicVolume * masterVolume)
        updateSoundEffectVolumes()
    }
    
    private func updateSoundEffectVolumes() {
        for player in soundEffectPlayers.values {
            player.volume = isMuted ? 0 : (soundEffectVolume * masterVolume)
        }
    }
    
    // MARK: - 淡入淡出效果
    private func fadeInBackgroundMusic() {
        guard let player = backgroundMusicPlayer else { return }
        
        player.volume = 0
        let targetVolume = musicVolume * masterVolume
        let steps = 20
        let stepDuration = AudioConfig.fadeInDuration / Double(steps)
        let volumeStep = targetVolume / Float(steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                player.volume = min(targetVolume, volumeStep * Float(i))
            }
        }
    }
    
    private func fadeOutBackgroundMusic(completion: @escaping () -> Void) {
        guard let player = backgroundMusicPlayer else {
            completion()
            return
        }
        
        let initialVolume = player.volume
        let steps = 20
        let stepDuration = AudioConfig.fadeOutDuration / Double(steps)
        let volumeStep = initialVolume / Float(steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                player.volume = max(0, initialVolume - volumeStep * Float(i))
                
                if i == steps {
                    completion()
                }
            }
        }
    }
    
    // MARK: - 清理方法
    func stopAllSoundEffects() {
        for player in soundEffectPlayers.values {
            player.stop()
        }
        soundEffectPlayers.removeAll()
    }
    
    func cleanup() {
        stopBackgroundMusic()
        stopAllSoundEffects()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 获取当前状态
    func getCurrentVolumes() -> (master: Float, music: Float, soundEffect: Float) {
        return (masterVolume, musicVolume, soundEffectVolume)
    }
    
    func getMasterVolume() -> Float {
        return masterVolume
    }
    
    func getMusicVolume() -> Float {
        return musicVolume
    }
    
    func getSoundEffectVolume() -> Float {
        return soundEffectVolume
    }
    
    func isAudioMuted() -> Bool {
        return isMuted
    }
    
    func toggleMute() {
        setMuted(!isMuted)
    }
    
    func isPlayingBackgroundMusic() -> Bool {
        return isBackgroundMusicPlaying
    }
    
    func getCurrentBackgroundMusic() -> String? {
        return currentBackgroundMusic
    }
    
    func isMusicMuted() -> Bool {
        return isMuted
    }
    
    // MARK: - 调试信息
    func getAudioDebugInfo() -> String {
        return """
        🔊 音频系统状态:
        主音量: \(Int(masterVolume * 100))%
        音乐音量: \(Int(musicVolume * 100))%
        音效音量: \(Int(soundEffectVolume * 100))%
        静音: \(isMuted ? "是" : "否")
        背景音乐: \(currentBackgroundMusic ?? "无")
        正在播放: \(isBackgroundMusicPlaying ? "是" : "否")
        活跃音效: \(soundEffectPlayers.count)个
        """
    }
}

// MARK: - 扩展：SpriteKit集成
extension AudioSystem {
    /// 为SpriteKit节点添加音效播放功能
    func playSoundForNode(_ node: SKNode, soundName: String, volume: Float = 1.0) {
        let soundAction = SKAction.playSoundFileNamed("\(soundName).wav", waitForCompletion: false)
        node.run(soundAction)
    }
    
    /// 创建带音效的动作序列
    func createSoundAction(soundName: String, volume: Float = 1.0) -> SKAction {
        return SKAction.run {
            self.playSoundEffect(soundName, volume: volume)
        }
    }
} 