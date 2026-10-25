# 第三方资源与制作来源

《伪人小镇》自有代码与自有美术/文本的许可范围见 [LICENSE.md](LICENSE.md)。下列第三方内容和既有单独许可不受该声明替换。各资源路径以 Godot 工程根目录为基准。

| 内容 | 文件或位置 | 来源与许可 |
| --- | --- | --- |
| Godot Engine | Windows Demo 所使用的 Godot 4.6.3 官方导出运行时 | Godot Engine contributors，MIT；可执行发行包保留引擎许可证及其第三方版权声明。[官方分发说明](https://docs.godotengine.org/en/4.6/about/complying_with_licenses.html) |
| Noto Sans CJK SC Regular 2.004 | `assets/fonts/NotoSansCJKsc-Regular.otf`；`vehicle_service/assets/font.otf` 为相同字体副本 | © 2014–2021 Adobe，SIL OFL 1.1；保留 [Noto OFL](licenses/NotoSansCJK-OFL.txt)。[上游](https://github.com/notofonts/noto-cjk) |
| Ma Shan Zheng Regular | `assets/ui/town_map/MaShanZheng-Regular.ttf` | The Ma Shan Zheng Project Authors，SIL OFL 1.1；保留 [Ma Shan Zheng OFL](licenses/MaShanZheng-OFL.txt)。[上游](https://github.com/googlefonts/mashanzheng) |
| Parchment Paper Background Texture | `assets/ui/town_map/parchment.jpg` | Andrea Stöckel，Public Domain Pictures；项目来源清单记录为 CC0/Public Domain。原 JPEG 未改动，游戏内用于地图及笔记背景。[来源页面](https://www.publicdomainpictures.net/en/view-image.php?image=488602&picture=parchment-paper-background-texture) |
| 三段机械音效 | `firearms/assets/audio/mechanical_open.wav`、`mechanical_insert.wav`、`mechanical_close.wav` | 既有本地数学合成脚本生成；保留制作目录既有的 [CC0 声明](licenses/MechanicalAudio-CC0.txt)，不将它改为项目自有资产的 CC BY 4.0 |

项目包含程序化建模/材质、AI 辅助生成后经像素化和接入整理的角色图像、规则与剧情文本、本地数学合成音效。制作方式分别记录，不以“全部手绘”或“没有第三方资源”描述整个项目。

装饰画包含依据古典作品构图描述生成的像素风改编；已有项目内原图、提示词和接入脚本记录。维尔攻击姿势与阴影、B 的角色图像也有项目内生成和用户验收记录。上述记录说明制作流程，不把第三方参考输入的权利或古典原作公共领域部分重新授权为本项目独占内容。

两段旧 Windows 本机语音 `assets/audio/car_fault_line.wav`、`check_engine_line.wav` 使用 System.Speech / Microsoft Kangkang 生成，其输出再分发条款未确认。当前主角对白使用字幕，这两段旧音频不包含在本次公开 Demo 和公开源码文件清单中；保留已核实的 `engine_stall.wav` 故障音效。
