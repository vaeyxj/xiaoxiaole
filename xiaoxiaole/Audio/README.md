# 音效文件说明

## 目录结构
```
Audio/
├── SoundEffects/     # 音效文件 (.wav格式)
├── BackgroundMusic/  # 背景音乐 (.mp3格式)
└── README.md        # 说明文档
```

## 需要的音效文件

### 音效文件 (SoundEffects/) - .wav格式
- `button_tap.wav` - 按钮点击音效
- `gem_match.wav` - 宝石消除音效
- `gem_drop.wav` - 宝石掉落音效
- `enemy_hit.wav` - 敌人受击音效
- `player_hurt.wav` - 玩家受伤音效
- `victory.wav` - 胜利音效
- `game_over.wav` - 游戏结束音效
- `level_up.wav` - 升级音效
- `player_attack.wav` - 玩家攻击音效
- `enemy_attack.wav` - 敌人攻击音效
- `critical_hit.wav` - 暴击音效
- `skill_heal.wav` - 治疗技能音效
- `skill_attack.wav` - 攻击技能音效
- `skill_defense.wav` - 防御技能音效
- `skill_special.wav` - 特殊技能音效
- `combo_2.wav` - 2连击音效
- `combo_3.wav` - 3连击音效
- `combo_4.wav` - 4连击音效
- `combo_5.wav` - 5连击音效

### 背景音乐 (BackgroundMusic/) - .mp3格式
- `menu_theme.mp3` - 主菜单背景音乐
- `dungeon_theme.mp3` - 地牢背景音乐
- `shop_theme.mp3` - 商店背景音乐
- `victory_theme.mp3` - 胜利背景音乐
- `game_over_theme.mp3` - 游戏结束背景音乐

## 如何添加音效文件

### 方法1：直接拖拽到Xcode
1. 在Xcode中右键点击项目根目录
2. 选择 "Add Files to 'xiaoxiaole'"
3. 选择音效文件
4. 确保勾选 "Add to target: xiaoxiaole"

### 方法2：通过Finder添加
1. 将音效文件复制到对应目录
2. 在Xcode中右键项目 -> "Add Files to 'xiaoxiaole'"
3. 选择添加的文件

## 音效文件要求
- **音效文件**：WAV格式，16-bit，44.1kHz，单声道或立体声
- **背景音乐**：MP3格式，128kbps或更高，立体声
- **文件大小**：音效文件建议小于100KB，背景音乐建议小于5MB

## 临时解决方案
如果暂时没有音效文件，可以：
1. 下载免费音效素材网站的文件
2. 使用GarageBand等工具创建简单音效
3. 使用在线音效生成器

## 推荐资源网站
- Freesound.org - 免费音效库
- Zapsplat.com - 专业音效库
- Adobe Audition - 音效编辑工具
- GarageBand - iOS音乐制作工具 