import SpriteKit
import GameplayKit

// MARK: - 棋盘系统
class MatchBoardSystem {
    static let shared = MatchBoardSystem()
    
    // MARK: - 配置
    struct Config {
        static let boardSize = 8
        static let minMatchCount = 3
        static let gemTypes: [GemType] = [.red, .blue, .green, .yellow, .purple, .white]
        static let cellSize: CGFloat = 64
        static let animationDuration: TimeInterval = 0.3
        static let cascadeDelay: TimeInterval = 0.1
    }
    
    // MARK: - 属性
    private var board: [[Gem?]] = []
    private var selectedGem: GridPosition?
    private var isAnimating = false
    private var comboCount = 0
    private weak var gameManager: GameManager?
    
    // 回调
    var onMatchFound: (([Match]) -> Void)?
    var onGemsCleared: ((Int, GemType) -> Void)?
    var onComboChanged: ((Int) -> Void)?
    var onBoardStable: (() -> Void)?
    
    private init() {
        initializeBoard()
    }
    
    // MARK: - 初始化
    func setGameManager(_ manager: GameManager) {
        self.gameManager = manager
    }
    
    private func initializeBoard() {
        board = Array(repeating: Array(repeating: nil, count: Config.boardSize), 
                     count: Config.boardSize)
        generateInitialBoard()
    }
    
    private func generateInitialBoard() {
        for row in 0..<Config.boardSize {
            for col in 0..<Config.boardSize {
                let position = GridPosition(row, col)
                board[row][col] = generateRandomGem(at: position, avoidMatches: true)
            }
        }
        
        // 确保没有初始匹配
        while hasMatches() {
            shuffleBoard()
        }
    }
    
    private func generateRandomGem(at position: GridPosition, avoidMatches: Bool = false) -> Gem {
        var availableTypes = Config.gemTypes
        
        if avoidMatches {
            // 检查左边和上边的宝石，避免立即形成匹配
            let leftTypes = getConsecutiveTypes(from: position, direction: (-1, 0))
            let topTypes = getConsecutiveTypes(from: position, direction: (0, -1))
            
            if leftTypes.count >= 2 {
                availableTypes.removeAll { $0 == leftTypes.first }
            }
            if topTypes.count >= 2 {
                availableTypes.removeAll { $0 == topTypes.first }
            }
        }
        
        if availableTypes.isEmpty {
            availableTypes = Config.gemTypes
        }
        
        let gemType = availableTypes.randomElement() ?? .red
        return Gem(type: gemType, position: position)
    }
    
    private func getConsecutiveTypes(from position: GridPosition, direction: (Int, Int)) -> [GemType] {
        var types: [GemType] = []
        var currentPos = GridPosition(
            position.x + direction.0,
            position.y + direction.1
        )
        
        while isValidPosition(currentPos), 
              let gem = board[currentPos.x][currentPos.y] {
            if types.isEmpty || types.last == gem.type {
                types.append(gem.type)
                currentPos = GridPosition(
                    currentPos.x + direction.0,
                    currentPos.y + direction.1
                )
            } else {
                break
            }
        }
        
        return types
    }
    
    // MARK: - 公共接口
    func getBoard() -> [[Gem?]] {
        return board
    }
    
    func getGem(at position: GridPosition) -> Gem? {
        guard isValidPosition(position) else { return nil }
        return board[position.x][position.y]
    }
    
    func selectGem(at position: GridPosition) -> Bool {
        guard isValidPosition(position), !isAnimating else { return false }
        
        if let selected = selectedGem {
            if selected == position {
                // 取消选择
                selectedGem = nil
                return true
            } else if areAdjacent(selected, position) {
                // 尝试交换
                return attemptSwap(from: selected, to: position)
            } else {
                // 选择新的宝石
                selectedGem = position
                return true
            }
        } else {
            // 首次选择
            selectedGem = position
            return true
        }
    }
    
    func getSelectedPosition() -> GridPosition? {
        return selectedGem
    }
    
    func resetSelection() {
        selectedGem = nil
    }
    
    // MARK: - 交换逻辑
    private func attemptSwap(from: GridPosition, to: GridPosition) -> Bool {
        guard let gem1 = board[from.x][from.y],
              let gem2 = board[to.x][to.y] else { return false }
        
        // 执行交换
        swapGems(from: from, to: to)
        
        // 检查是否形成匹配
        let matches = findMatches()
        
        if matches.isEmpty {
            // 没有匹配，交换回去
            swapGems(from: from, to: to)
            selectedGem = nil
            return false
        } else {
            // 有匹配，开始处理
            selectedGem = nil
            processMatches(matches)
            return true
        }
    }
    
    private func swapGems(from: GridPosition, to: GridPosition) {
        guard let gem1 = board[from.x][from.y],
              let gem2 = board[to.x][to.y] else { return }
        
        // 更新宝石位置
        var newGem1 = gem1
        var newGem2 = gem2
        newGem1.position = to
        newGem2.position = from
        
        // 更新棋盘
        board[from.x][from.y] = newGem2
        board[to.x][to.y] = newGem1
    }
    
    // MARK: - 匹配检测
    func findMatches() -> [Match] {
        var matches: [Match] = []
        
        // 检查水平匹配
        for row in 0..<Config.boardSize {
            var currentMatch: [GridPosition] = []
            var currentType: GemType?
            
            for col in 0..<Config.boardSize {
                let position = GridPosition(row, col)
                guard let gem = board[row][col] else {
                    if currentMatch.count >= Config.minMatchCount {
                        matches.append(Match(
                            gems: currentMatch,
                            type: .horizontal(count: currentMatch.count),
                            gemType: currentType!
                        ))
                    }
                    currentMatch.removeAll()
                    currentType = nil
                    continue
                }
                
                if gem.type == currentType {
                    currentMatch.append(position)
                } else {
                    if currentMatch.count >= Config.minMatchCount {
                        matches.append(Match(
                            gems: currentMatch,
                            type: .horizontal(count: currentMatch.count),
                            gemType: currentType!
                        ))
                    }
                    currentMatch = [position]
                    currentType = gem.type
                }
            }
            
            if currentMatch.count >= Config.minMatchCount {
                matches.append(Match(
                    gems: currentMatch,
                    type: .horizontal(count: currentMatch.count),
                    gemType: currentType!
                ))
            }
        }
        
        // 检查垂直匹配
        for col in 0..<Config.boardSize {
            var currentMatch: [GridPosition] = []
            var currentType: GemType?
            
            for row in 0..<Config.boardSize {
                let position = GridPosition(row, col)
                guard let gem = board[row][col] else {
                    if currentMatch.count >= Config.minMatchCount {
                        matches.append(Match(
                            gems: currentMatch,
                            type: .vertical(count: currentMatch.count),
                            gemType: currentType!
                        ))
                    }
                    currentMatch.removeAll()
                    currentType = nil
                    continue
                }
                
                if gem.type == currentType {
                    currentMatch.append(position)
                } else {
                    if currentMatch.count >= Config.minMatchCount {
                        matches.append(Match(
                            gems: currentMatch,
                            type: .vertical(count: currentMatch.count),
                            gemType: currentType!
                        ))
                    }
                    currentMatch = [position]
                    currentType = gem.type
                }
            }
            
            if currentMatch.count >= Config.minMatchCount {
                matches.append(Match(
                    gems: currentMatch,
                    type: .vertical(count: currentMatch.count),
                    gemType: currentType!
                ))
            }
        }
        
        return matches
    }
    
    private func hasMatches() -> Bool {
        return !findMatches().isEmpty
    }
    
    // MARK: - 匹配处理
    private func processMatches(_ matches: [Match]) {
        guard !matches.isEmpty else {
            resetCombo()
            onBoardStable?()
            return
        }
        
        isAnimating = true
        comboCount += 1
        onComboChanged?(comboCount)
        
        // 清除匹配的宝石
        clearMatches(matches)
        
        // 通知游戏管理器处理匹配效果
        onMatchFound?(matches)
        
        // 延迟处理掉落和填充
        DispatchQueue.main.asyncAfter(deadline: .now() + Config.animationDuration) {
            self.dropGems()
            self.fillEmptySpaces()
            
            // 检查新的匹配
            DispatchQueue.main.asyncAfter(deadline: .now() + Config.cascadeDelay) {
                self.isAnimating = false
                let newMatches = self.findMatches()
                
                if !newMatches.isEmpty {
                    // 继续连击
                    self.processMatches(newMatches)
                } else {
                    // 连击结束
                    self.resetCombo()
                    self.onBoardStable?()
                }
            }
        }
    }
    
    private func clearMatches(_ matches: [Match]) {
        var clearedGems: [GemType: Int] = [:]
        
        for match in matches {
            for position in match.gems {
                if let gem = board[position.x][position.y] {
                    clearedGems[gem.type, default: 0] += 1
                    board[position.x][position.y] = nil
                }
            }
        }
        
        // 通知清除的宝石数量
        for (gemType, count) in clearedGems {
            onGemsCleared?(count, gemType)
        }
    }
    
    private func dropGems() {
        for col in 0..<Config.boardSize {
            var writeIndex = Config.boardSize - 1
            
            for row in stride(from: Config.boardSize - 1, through: 0, by: -1) {
                if let gem = board[row][col] {
                    if writeIndex != row {
                        var newGem = gem
                        newGem.position = GridPosition(writeIndex, col)
                        board[writeIndex][col] = newGem
                        board[row][col] = nil
                    }
                    writeIndex -= 1
                }
            }
        }
    }
    
    private func fillEmptySpaces() {
        for col in 0..<Config.boardSize {
            for row in 0..<Config.boardSize {
                if board[row][col] == nil {
                    let position = GridPosition(row, col)
                    board[row][col] = generateRandomGem(at: position)
                }
            }
        }
    }
    
    private func resetCombo() {
        comboCount = 0
        onComboChanged?(comboCount)
    }
    
    // MARK: - 工具方法
    private func isValidPosition(_ position: GridPosition) -> Bool {
        return position.x >= 0 && position.x < Config.boardSize &&
               position.y >= 0 && position.y < Config.boardSize
    }
    
    private func areAdjacent(_ pos1: GridPosition, _ pos2: GridPosition) -> Bool {
        let rowDiff = abs(pos1.x - pos2.x)
        let colDiff = abs(pos1.y - pos2.y)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    private func shuffleBoard() {
        var allGems: [Gem] = []
        
        // 收集所有宝石
        for row in 0..<Config.boardSize {
            for col in 0..<Config.boardSize {
                if let gem = board[row][col] {
                    allGems.append(gem)
                }
            }
        }
        
        // 打乱
        allGems.shuffle()
        
        // 重新分配
        var index = 0
        for row in 0..<Config.boardSize {
            for col in 0..<Config.boardSize {
                if index < allGems.count {
                    var gem = allGems[index]
                    gem.position = GridPosition(row, col)
                    board[row][col] = gem
                    index += 1
                }
            }
        }
    }
    
    // MARK: - 特殊功能
    func hasValidMoves() -> Bool {
        // 检查是否存在可能的移动
        for row in 0..<Config.boardSize {
            for col in 0..<Config.boardSize {
                let position = GridPosition(row, col)
                let adjacentPositions = [
                    GridPosition(row - 1, col),  // 上
                    GridPosition(row + 1, col),  // 下
                    GridPosition(row, col - 1),  // 左
                    GridPosition(row, col + 1)   // 右
                ]
                
                for adjacentPos in adjacentPositions {
                    if isValidPosition(adjacentPos) {
                        // 模拟交换
                        swapGems(from: position, to: adjacentPos)
                        let hasMatch = hasMatches()
                        // 交换回去
                        swapGems(from: position, to: adjacentPos)
                        
                        if hasMatch {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func shuffleBoardIfNeeded() {
        if !hasValidMoves() {
            shuffleBoard()
        }
    }
    
    func reset() {
        board.removeAll()
        selectedGem = nil
        isAnimating = false
        comboCount = 0
        initializeBoard()
    }
}

// MARK: - 扩展：调试功能
extension MatchBoardSystem {
    func printBoard() {
        print("=== 棋盘状态 ===")
        for row in 0..<Config.boardSize {
            var line = ""
            for col in 0..<Config.boardSize {
                if let gem = board[row][col] {
                    switch gem.type {
                    case .red: line += "🔴 "
                    case .blue: line += "🔵 "
                    case .green: line += "🟢 "
                    case .yellow: line += "🟡 "
                    case .purple: line += "🟣 "
                    case .white: line += "🟤 "
                    case .bomb: line += "💣 "
                    case .lightning: line += "⚡ "
                    case .rainbow: line += "🌈 "
                    }
                } else {
                    line += "⬜ "
                }
            }
            print(line)
        }
        print("================")
    }
} 