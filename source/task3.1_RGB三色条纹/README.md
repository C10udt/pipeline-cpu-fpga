# 任务 3.1：流水线 CPU 输出 RGB 三色等宽横条与固定频率音频

本目录是一套可直接打开、仿真、重新生成 bitstream 的 Vivado 2022.2 工程，面向
`cg_fpga v1.4` 在线 FPGA 平台，目标器件为 `xc7z020clg400-2`。

## 实现效果

- 视频分辨率为 640×480，25 MHz 像素时钟。
- 屏幕自上而下显示红、绿、蓝三条等宽（各 160 行）水平横条。
- 平台视频 IP 实际采用 `G_B_R_444` 分量排列（`[7:0]=G、[15:8]=B、[23:16]=R`）；源码已经按该真实位序打包颜色。
- 同时播放 1 kHz 固定频率方波音频。
- 数码管全部消隐，LED 全部关闭，避免与视频任务无关的显示干扰。
- 按 RST 后恢复默认颜色并关闭音频。

## CPU 与外设

画面颜色与音频使能由五级流水线 CPU 执行 `program/stripes.asm` 控制：

- IF/ID/EX/MEM/WB 五级流水线。
- 支持 `ADD/SUB/AND/OR/SLT/ADDI/LUI/ORI/LW/SW/BEQ/BNE/J`。
- 包含 EX/MEM、MEM/WB 前递，load-use 停顿和控制冒险冲刷。
- `0x00004000`：横条 1 颜色（顶部）。
- `0x00004004`：横条 2 颜色（中部）。
- `0x00004008`：横条 3 颜色（底部）。
- `0x0000400C`：音频控制（bit 0 写 1 使能）。

视频模块产生标准的 640/16/96/48 水平和 480/10/2/33 垂直时序。颜色寄存器经过双触发器同步，并只在帧起点更新到绘图寄存器，避免一帧中途撕裂。

音频模块为硬件分频器，将 100 MHz 时钟 100,000 分频后产生 1 kHz 方波，输出至平台 7-bit PWM 音频 DAC。

## 目录

- `src/`：流水线 CPU、ROM、定时器、音频发生器、VGA 时序、横条绘图器、时钟和平台顶层。
- `program/`：带注释的汇编程序及对应机器码。
- `sim/tb_task31.v`：Vivado 行为仿真 testbench。
- `scripts/`：仿真、构建、工程检查脚本。
- `ip_repo/`：题目提供的 `cg_fpga v1.4` IP。
- `output/task31.bit`：最终可下载 bit 文件。
- `reports/`：时序、资源、DRC 与时钟交互报告。

## 使用

直接下载：

1. 在在线 FPGA 平台选择 `output/task31.bit`。
2. 下载后按一次 RST。
3. 观察 RGB 三色横条并听到 1 kHz 音频。

查看工程时打开 `vivado/task31.xpr`。

完整重建：

```powershell
& '.\task\scripts\build.ps1'
```

脚本会先运行行为仿真，再执行综合、实现和 bitstream 生成。由于 Vivado 2022.2 在中文路径下生成题目 PS7 IP 会出错，脚本会自动在纯英文临时目录构建，然后把完整工程、报告和 bit 复制回来。

如果 Vivado 安装位置不同：

```powershell
& '.\task\scripts\build.ps1' -VivadoBat 'D:\Xilinx\Vivado\2022.2\bin\vivado.bat'
```

验证结果见 `VERIFICATION.md`。
