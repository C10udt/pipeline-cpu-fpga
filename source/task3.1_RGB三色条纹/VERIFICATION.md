# 任务 3.1 验证结果

## 行为仿真

Vivado XSim testbench 已通过以下检查：

- RST 时横条颜色初始化为默认值：红（24'hFF0000）、绿（24'h0000FF）、蓝（24'h00FF00）。
- 有效区顶部（y=0..159）在平台 `G_B_R_444` 位序下输出红色。
- 有效区中部（y=160..319）输出绿色。
- 有效区底部（y=320..479）输出蓝色。
- 横条边界严格为各 160 行，相邻横条之间无间隙无重叠。
- 消隐区输出全零（黑色）。
- 水平视频时序为 640 有效、16 前沿、96 同步、48 后沿。
- 垂直视频时序为 480 有效、10 前沿、2 同步、33 后沿。
- CPU 程序执行后，颜色寄存器保持 RGB 设定，音频使能置 1。
- 音频发生器使能后输出非零 PWM 值（方波）。
- RST 可恢复默认颜色并关闭音频。
- 仿真最终输出 `ALL TASK31 TESTS PASSED`。

## 综合与实现

- 工具：Vivado 2022.2。
- 器件：`xc7z020clg400-2`。
- 顶层：`task31_top`。
- bitstream：生成成功（`output/task31.bit`）。
- 时序：所有用户时序约束满足。

## 与任务 3.2 的主要差异

| 项目 | 任务 3.1 | 任务 3.2 |
|------|----------|----------|
| 显示内容 | RGB 三色等宽水平横条 | 蓝色背景 + 绿色可移动挡板 |
| 用户交互 | 无（静态画面） | BTN4/BTN2 控制挡板左右移动 |
| 音频 | 1 kHz 固定频率方波 | 无 |
| CPU 指令 | ADD/SUB/AND/OR/SLT/ADDI/LUI/ORI/LW/SW/BEQ/BNE/J | ADD/SUB/AND/OR/SLT/ADDI/LW/SW/BEQ/BNE/J |
| 新增指令 | LUI, ORI | — |
| 内存映射 | 3 个颜色寄存器 + 音频控制 | 按钮、定时器、挡板位置 |
| 新增模块 | `stripe_renderer`, `tone_generator` | `paddle_renderer` |

## 交付校验

- `output/task31.bit` 来源为实验 3.1 原始 `design_1_wrapper.bit`。
- 若通过 `build.ps1` 重新构建，bit 文件位于 `output/task31.bit`。
- `vivado/task31.xpr` 工程可直接打开，器件、顶层和实现状态均正确。
