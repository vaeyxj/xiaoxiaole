import SpriteKit
import GameplayKit

// MARK: - 战斗UI系统
class CombatUISystem: SKNode {
    
    // MARK: - UI元素
    private var playerHealthBar: HealthBar!
    private var playerManaBar: ManaBar!
    private var enemyHealthBar: HealthBar!
    private var playerStatsPanel: StatsPanel!
    private var enemyStatsPanel: StatsPanel!
    private var skillButtonsPanel: SkillButtonsPanel!
    private var turnIndicator: TurnIndicator!
    private var combatLog: CombatLog!
    private var comboCounter: ComboCounter!
    
    // 回调
    var onSkillUsed: ((SkillType) -> Void)?
    var onTurnEnded: (() -> Void)?
    
    private weak var gameManager: GameManager?
    
    // MARK: - 初始化
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setGameManager(_ manager: GameManager) {
        self.gameManager = manager
        updateUI()
    }
    
    private func setupUI() {
        setupBackground()
        setupPlayerUI()
        setupEnemyUI()
        setupSkillButtons()
        setupTurnIndicator()
        setupCombatLog()
        setupComboCounter()
    }
    
    private func setupBackground() {
        let background = SKShapeNode(rectOf: CGSize(width: 400, height: 600))
        background.fillColor = AssetManager.Colors.combatBackground
        background.strokeColor = AssetManager.Colors.borderColor
        background.lineWidth = 2
        background.alpha = 0.9
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
    }
    
    private func setupPlayerUI() {
        // 玩家血条
        playerHealthBar = HealthBar(width: 150, height: 20, type: .player)
        playerHealthBar.position = CGPoint(x: -150, y: 250)
        addChild(playerHealthBar)
        
        // 玩家法力条
        playerManaBar = ManaBar(width: 150, height: 15)
        playerManaBar.position = CGPoint(x: -150, y: 220)
        addChild(playerManaBar)
        
        // 玩家状态面板
        playerStatsPanel = StatsPanel(type: .player)
        playerStatsPanel.position = CGPoint(x: -150, y: 180)
        addChild(playerStatsPanel)
    }
    
    private func setupEnemyUI() {
        // 敌人血条
        enemyHealthBar = HealthBar(width: 150, height: 20, type: .enemy)
        enemyHealthBar.position = CGPoint(x: 150, y: 250)
        addChild(enemyHealthBar)
        
        // 敌人状态面板
        enemyStatsPanel = StatsPanel(type: .enemy)
        enemyStatsPanel.position = CGPoint(x: 150, y: 180)
        addChild(enemyStatsPanel)
    }
    
    private func setupSkillButtons() {
        skillButtonsPanel = SkillButtonsPanel()
        skillButtonsPanel.position = CGPoint(x: 0, y: -200)
        skillButtonsPanel.onSkillTapped = { [weak self] skillType in
            self?.onSkillUsed?(skillType)
        }
        addChild(skillButtonsPanel)
    }
    
    private func setupTurnIndicator() {
        turnIndicator = TurnIndicator()
        turnIndicator.position = CGPoint(x: 0, y: 280)
        addChild(turnIndicator)
    }
    
    private func setupCombatLog() {
        combatLog = CombatLog()
        combatLog.position = CGPoint(x: 0, y: -50)
        addChild(combatLog)
    }
    
    private func setupComboCounter() {
        comboCounter = ComboCounter()
        comboCounter.position = CGPoint(x: 0, y: 150)
        addChild(comboCounter)
    }
    
    // MARK: - 更新UI
    func updateUI() {
        let gameManager = GameManager.shared
        let playerStats = gameManager.playerStats
        
        // 更新玩家血量条
        playerHealthBar.updateHealth(current: playerStats.health, max: playerStats.maxHealth)
        
        // 更新玩家法力条
        playerManaBar.updateMana(current: playerStats.mana, max: playerStats.maxMana)
        
        // 更新敌人血量条
        if let currentEnemy = gameManager.currentEnemy {
            enemyHealthBar.updateHealth(current: currentEnemy.health, max: currentEnemy.maxHealth)
        }
        
        // 更新状态显示
        updateStatusDisplay()
    }
    
    private func updateStatusDisplay() {
        let gameManager = GameManager.shared
        let currentState = gameManager.currentState
        
        // 根据游戏状态更新UI显示
        switch currentState {
        case .playing:
            showCombatUI()
        case .menu, .paused, .gameOver, .victory, .shopping, .inventory, .settings:
            hideCombatUI()
        }
    }
    
    // MARK: - UI显示控制
    private func showCombatUI() {
        // 显示战斗UI元素
        playerHealthBar.isHidden = false
        playerManaBar.isHidden = false
        enemyHealthBar.isHidden = false
        
        // 添加到场景
        if let scene = scene {
            if playerHealthBar.parent == nil {
                scene.addChild(playerHealthBar)
            }
            if playerManaBar.parent == nil {
                scene.addChild(playerManaBar)
            }
            if enemyHealthBar.parent == nil {
                scene.addChild(enemyHealthBar)
            }
        }
    }
    
    private func hideCombatUI() {
        // 隐藏战斗UI元素
        playerHealthBar.isHidden = true
        playerManaBar.isHidden = true
        enemyHealthBar.isHidden = true
    }
    
    // MARK: - 伤害显示
    func showDamage(damage: Int, type: DamageLabel.DamageType, target: CombatTarget, position: CGPoint) {
        let damageLabel = DamageLabel(damage: damage, type: type)
        damageLabel.position = position
        
        if let scene = scene {
            scene.addChild(damageLabel)
        }
    }
    
    func updateCombo(_ comboCount: Int) {
        comboCounter.updateCombo(comboCount)
    }
    
    func showHeal(_ amount: Int, to target: CombatTarget) {
        let position: CGPoint
        switch target {
        case .player:
            position = CGPoint(x: -150, y: 200)
        case .enemy:
            position = CGPoint(x: 150, y: 200)
        }
        
        let healLabel = HealLabel(amount: amount)
        healLabel.position = position
        addChild(healLabel)
        healLabel.animate()
    }
    
    func addCombatMessage(_ message: String) {
        combatLog.addMessage(message)
    }
    
    func enableSkills(_ enabled: Bool) {
        skillButtonsPanel.setEnabled(enabled)
    }
}

// MARK: - 血量条组件
class HealthBar: SKNode {
    enum BarType {
        case player, enemy
    }
    
    private let backgroundBar: SKShapeNode
    private var healthBar: SKShapeNode
    private let healthLabel: SKLabelNode
    private let width: CGFloat
    private let height: CGFloat
    private let type: BarType
    
    init(width: CGFloat, height: CGFloat, type: BarType) {
        self.width = width
        self.height = height
        self.type = type
        
        // 背景条
        backgroundBar = SKShapeNode(rectOf: CGSize(width: width, height: height))
        backgroundBar.fillColor = AssetManager.Colors.healthBarBackground
        backgroundBar.strokeColor = AssetManager.Colors.borderColor
        backgroundBar.lineWidth = 1
        
        // 血条
        healthBar = SKShapeNode(rectOf: CGSize(width: width, height: height))
        healthBar.fillColor = type == .player ? 
            AssetManager.Colors.playerHealthBar : 
            AssetManager.Colors.enemyHealthBar
        healthBar.strokeColor = .clear
        
        // 血量文字
        healthLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        healthLabel.fontSize = 12
        healthLabel.fontColor = AssetManager.Colors.textColor
        healthLabel.verticalAlignmentMode = .center
        healthLabel.horizontalAlignmentMode = .center
        
        super.init()
        
        addChild(backgroundBar)
        addChild(healthBar)
        addChild(healthLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHealth(current: Int, max: Int) {
        let percentage = max > 0 ? CGFloat(current) / CGFloat(max) : 0
        let newWidth = width * percentage
        
        // 更新血条宽度
        healthBar.removeFromParent()
        healthBar = SKShapeNode(rectOf: CGSize(width: newWidth, height: height))
        healthBar.fillColor = type == .player ? 
            AssetManager.Colors.playerHealthBar : 
            AssetManager.Colors.enemyHealthBar
        healthBar.strokeColor = .clear
        healthBar.position.x = -(width - newWidth) / 2
        addChild(healthBar)
        
        // 更新文字
        healthLabel.text = "\(current)/\(max)"
        
        // 血量过低时闪烁警告
        if percentage < 0.2 {
            let blinkAction = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ])
            )
            healthBar.run(blinkAction, withKey: "lowHealthBlink")
        } else {
            healthBar.removeAction(forKey: "lowHealthBlink")
        }
    }
}

// MARK: - 法力条组件
class ManaBar: SKNode {
    private let backgroundBar: SKShapeNode
    private var manaBar: SKShapeNode
    private let manaLabel: SKLabelNode
    private let width: CGFloat
    private let height: CGFloat
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        
        // 背景条
        backgroundBar = SKShapeNode(rectOf: CGSize(width: width, height: height))
        backgroundBar.fillColor = AssetManager.Colors.manaBarBackground
        backgroundBar.strokeColor = AssetManager.Colors.borderColor
        backgroundBar.lineWidth = 1
        
        // 法力条
        manaBar = SKShapeNode(rectOf: CGSize(width: width, height: height))
        manaBar.fillColor = AssetManager.Colors.manaBar
        manaBar.strokeColor = .clear
        
        // 法力文字
        manaLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        manaLabel.fontSize = 10
        manaLabel.fontColor = AssetManager.Colors.textColor
        manaLabel.verticalAlignmentMode = .center
        manaLabel.horizontalAlignmentMode = .center
        
        super.init()
        
        addChild(backgroundBar)
        addChild(manaBar)
        addChild(manaLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMana(current: Int, max: Int) {
        let percentage = max > 0 ? CGFloat(current) / CGFloat(max) : 0
        let newWidth = width * percentage
        
        // 更新法力条宽度
        manaBar.removeFromParent()
        manaBar = SKShapeNode(rectOf: CGSize(width: newWidth, height: height))
        manaBar.fillColor = AssetManager.Colors.manaBar
        manaBar.strokeColor = .clear
        manaBar.position.x = -(width - newWidth) / 2
        addChild(manaBar)
        
        // 更新文字
        manaLabel.text = "\(current)/\(max)"
    }
}

// MARK: - 状态面板
class StatsPanel: SKNode {
    enum PanelType {
        case player, enemy
    }
    
    private let type: PanelType
    private let attackLabel: SKLabelNode
    private let defenseLabel: SKLabelNode
    private let levelLabel: SKLabelNode
    private let background: SKShapeNode
    
    init(type: PanelType) {
        self.type = type
        
        background = SKShapeNode(rectOf: CGSize(width: 120, height: 60))
        background.fillColor = AssetManager.Colors.panelBackground
        background.strokeColor = AssetManager.Colors.borderColor
        background.lineWidth = 1
        background.alpha = 0.8
        
        attackLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        attackLabel.fontSize = 10
        attackLabel.fontColor = AssetManager.Colors.textColor
        attackLabel.horizontalAlignmentMode = .left
        attackLabel.position = CGPoint(x: -55, y: 10)
        
        defenseLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        defenseLabel.fontSize = 10
        defenseLabel.fontColor = AssetManager.Colors.textColor
        defenseLabel.horizontalAlignmentMode = .left
        defenseLabel.position = CGPoint(x: -55, y: -5)
        
        levelLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        levelLabel.fontSize = 10
        levelLabel.fontColor = AssetManager.Colors.textColor
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: -55, y: -20)
        
        super.init()
        
        addChild(background)
        addChild(attackLabel)
        addChild(defenseLabel)
        addChild(levelLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateStats(_ stats: PlayerStats) {
        attackLabel.text = "攻击: \(stats.attack)"
        defenseLabel.text = "防御: \(stats.defense)"
        levelLabel.text = "等级: \(stats.level)"
    }
    
    func updateEnemyStats(_ enemy: Enemy) {
        attackLabel.text = "攻击: \(enemy.attack)"
        defenseLabel.text = "防御: \(enemy.defense)"
        levelLabel.text = "\(enemy.name)"
    }
}

// MARK: - 伤害显示标签
class DamageLabel: SKLabelNode {
    enum DamageType {
        case normal
        case critical
        case special
        
        var color: UIColor {
            switch self {
            case .normal: return .white
            case .critical: return .red
            case .special: return .purple
            }
        }
    }
    
    init(damage: Int, type: DamageType) {
        super.init(fontNamed: "Helvetica-Bold")
        
        self.text = "-\(damage)"
        self.fontSize = type == .critical ? 24 : 18
        self.fontColor = type.color
        self.zPosition = 1000
        
        // 添加动画效果
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([SKAction.group([moveUp, fadeOut]), remove])
        
        self.run(sequence)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let mainSequence = SKAction.group([moveUp, fadeOut])
        let fullSequence = SKAction.sequence([scaleSequence, mainSequence])
        
        run(fullSequence) { [weak self] in
            self?.removeFromParent()
        }
    }
}

// MARK: - 治疗显示标签
class HealLabel: SKLabelNode {
    init(amount: Int) {
        super.init()
        
        text = "+\(amount)"
        fontName = AssetManager.FontNames.combat
        fontSize = 16
        fontColor = AssetManager.Colors.healColor
        verticalAlignmentMode = .center
        horizontalAlignmentMode = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let fullSequence = SKAction.group([moveUp, fadeOut])
        
        run(fullSequence) { [weak self] in
            self?.removeFromParent()
        }
    }
}

// MARK: - 技能按钮面板
class SkillButtonsPanel: SKNode {
    private var skillButtons: [SkillButton] = []
    var onSkillTapped: ((SkillType) -> Void)?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateSkills(_ skills: [Skill]) {
        // 清除现有按钮
        skillButtons.forEach { $0.removeFromParent() }
        skillButtons.removeAll()
        
        // 创建新按钮
        for (index, skill) in skills.enumerated() {
            let button = SkillButton(skill: skill)
            button.position = CGPoint(x: CGFloat(index - 1) * 70, y: 0)
            button.onTapped = { [weak self] skillType in
                self?.onSkillTapped?(skillType)
            }
            addChild(button)
            skillButtons.append(button)
        }
    }
    
    func setEnabled(_ enabled: Bool) {
        skillButtons.forEach { $0.setEnabled(enabled) }
    }
}

// MARK: - 技能按钮
class SkillButton: SKNode {
    private let skill: Skill
    private let background: SKShapeNode
    private let iconLabel: SKLabelNode
    private let nameLabel: SKLabelNode
    private let costLabel: SKLabelNode
    private var isEnabled = true
    
    var onTapped: ((SkillType) -> Void)?
    
    init(skill: Skill) {
        self.skill = skill
        
        background = SKShapeNode(rectOf: CGSize(width: 60, height: 80))
        background.fillColor = AssetManager.Colors.skillButtonBackground
        background.strokeColor = AssetManager.Colors.borderColor
        background.lineWidth = 2
        
        iconLabel = SKLabelNode(text: skill.type.icon)
        iconLabel.fontSize = 24
        iconLabel.position = CGPoint(x: 0, y: 15)
        
        nameLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        nameLabel.text = skill.name
        nameLabel.fontSize = 8
        nameLabel.fontColor = AssetManager.Colors.textColor
        nameLabel.position = CGPoint(x: 0, y: -5)
        
        costLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        costLabel.text = "\(skill.manaCost)"
        costLabel.fontSize = 10
        costLabel.fontColor = AssetManager.Colors.manaBar
        costLabel.position = CGPoint(x: 0, y: -20)
        
        super.init()
        
        addChild(background)
        addChild(iconLabel)
        addChild(nameLabel)
        addChild(costLabel)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        background.fillColor = background.fillColor.withAlphaComponent(0.7)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        background.fillColor = AssetManager.Colors.skillButtonBackground
        onTapped?(skill.type)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        background.fillColor = AssetManager.Colors.skillButtonBackground
    }
}

// MARK: - 回合指示器
class TurnIndicator: SKNode {
    private let label: SKLabelNode
    private let background: SKShapeNode
    
    override init() {
        background = SKShapeNode(rectOf: CGSize(width: 120, height: 30))
        background.fillColor = AssetManager.Colors.turnIndicatorBackground
        background.strokeColor = AssetManager.Colors.borderColor
        background.lineWidth = 1
        
        label = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        label.fontSize = 14
        label.fontColor = AssetManager.Colors.textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        super.init()
        
        addChild(background)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTurn(_ turn: CombatTurn) {
        switch turn {
        case .player:
            label.text = "玩家回合"
            background.fillColor = AssetManager.Colors.playerTurnColor
        case .enemy:
            label.text = "敌人回合"
            background.fillColor = AssetManager.Colors.enemyTurnColor
        }
    }
}

// MARK: - 战斗日志
class CombatLog: SKNode {
    private var messages: [SKLabelNode] = []
    private let maxMessages = 3
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addMessage(_ message: String) {
        let messageLabel = SKLabelNode(fontNamed: AssetManager.FontNames.ui)
        messageLabel.text = message
        messageLabel.fontSize = 10
        messageLabel.fontColor = AssetManager.Colors.logTextColor
        messageLabel.horizontalAlignmentMode = .center
        
        // 移除旧消息
        if messages.count >= maxMessages {
            messages.first?.removeFromParent()
            messages.removeFirst()
        }
        
        // 调整现有消息位置
        for (index, existingMessage) in messages.enumerated() {
            existingMessage.position.y = CGFloat(index - messages.count) * 15
        }
        
        // 添加新消息
        messageLabel.position = CGPoint(x: 0, y: 0)
        addChild(messageLabel)
        messages.append(messageLabel)
        
        // 淡入动画
        messageLabel.alpha = 0
        messageLabel.run(SKAction.fadeIn(withDuration: 0.3))
    }
}

// MARK: - 连击计数器
class ComboCounter: SKNode {
    private let label: SKLabelNode
    private let background: SKShapeNode
    
    override init() {
        background = SKShapeNode(rectOf: CGSize(width: 100, height: 40))
        background.fillColor = AssetManager.Colors.comboBackground
        background.strokeColor = AssetManager.Colors.borderColor
        background.lineWidth = 2
        
        label = SKLabelNode(fontNamed: AssetManager.FontNames.combat)
        label.fontSize = 16
        label.fontColor = AssetManager.Colors.comboTextColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        super.init()
        
        addChild(background)
        addChild(label)
        
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCombo(_ count: Int) {
        if count > 1 {
            label.text = "连击 x\(count)"
            isHidden = false
            
            // 连击动画
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            run(pulse)
        } else {
            isHidden = true
        }
    }
}

// MARK: - 战斗目标枚举
enum CombatTarget {
    case player
    case enemy
} 