# pipeline-cpu-fpga

五级 MIPS 风格流水线 CPU 设计与 FPGA 上板验证。

面向配套 `cg_fpga v1.4` 在线 FPGA 平台，目标器件 `xc7z020clg400-2`，使用 Vivado 2022.2 构建，在 FPGA 上完成从汇编程序到外设驱动的完整链路验证。

## 任务概览

| 任务 | 内容 | 关键模块 |
|------|------|----------|
| 2.1 LED 闪烁 | 流水线 CPU 执行汇编程序，控制 32 颗 LED 闪烁 | pipeline_cpu、instruction_rom |
| 2.2 数码管显示 | CPU 驱动数码管显示十六进制数值 | hex_segment、pipeline_cpu |
| 2.3 斐波那契 | CPU 计算斐波那契数列并显示 | seven_segment_9digit |
| 3.1 RGB 三色条纹 | CPU + VGA 时序输出 RGB 三色条纹 | vga_timing_640x480、stripe_renderer、pixel_clock |
| 3.2 挡板移动 | CPU 驱动 VGA 绘制动态挡板 | VGA 输出 + 外设交互 |

## CPU 特性

- IF/ID/EX/MEM/WB 五级流水线。
- 支持 `ADD/SUB/AND/OR/SLT/ADDI/ANDI/LW/SW/BEQ/BNE/J` 指令。
- EX/MEM、MEM/WB 数据前递。
- load-use 冒险自动停顿一个周期。
- taken branch 和 jump 自动冲刷流水线。

## 目录结构

```
pipeline-cpu-fpga/
├── source/
│   ├── task2.1_LED闪烁/      # LED 闪烁
│   │   ├── src/              # Verilog 源码（CPU、指令 ROM、顶层）
│   │   ├── program/          # 汇编程序与对应机器码
│   │   ├── README.md
│   │   └── VERIFICATION.md
│   ├── task2.2_数码管显示/    # 数码管显示
│   ├── task2.3_斐波那契/      # 斐波那契计算
│   ├── task3.1_RGB三色条纹/   # VGA 三色条纹
│   └── task3.2_挡板移动/      # VGA 挡板移动
├── 实验报告_流水线CPU设计与FPGA验证.docx
└── 实验报告_流水线CPU设计与FPGA验证.pdf
```

每个任务子目录内含 `src/`（Verilog 源码）、`program/`（汇编与机器码）、`README.md`（功能与复现说明）、`VERIFICATION.md`（仿真/上板验证数据）。

## 技术栈

- Verilog / SystemVerilog
- Vivado 2022.2
- FPGA：Zynq xc7z020clg400-2
- VGA 时序（640x480）、像素时钟、数码管驱动、LED 控制

## 如何复现

各任务子目录的 `README.md` 内含复现步骤。由于 Vivado 2022.2 在含中文路径下生成配套 PS7 IP 会报路径编码错误，需使用各任务封装脚本在纯 ASCII 临时目录中仿真构建，再回拷产物。

## 时间说明

约完成时间：2026 年 7 月（大二暑假；由文件编辑时间推算，可能不精确）。

上板演示视频与 bitstream 文件体积较大（含超过 GitHub 单文件 100MB 限制的项），未纳入本仓库，可另存于网盘留档。
