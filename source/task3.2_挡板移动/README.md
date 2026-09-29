# 任务 16：流水线 CPU 控制挡板左右移动

本目录是一套可直接打开、仿真、重新生成 bitstream 的 Vivado 2022.2 工程，面向
`cg_fpga v1.4` 在线 FPGA 平台，目标器件为 `xc7z020clg400-2`。

## 实现效果

- 视频分辨率为 640×480，25 MHz 像素时钟，蓝色背景。
- 绿色挡板尺寸严格为 84×24 像素，初始左边界 `x=278`，位于底部正中央。
- 平台视频 IP 实际采用 `G_B_R_444` 分量排列（`[7:0]=G、[15:8]=B、[23:16]=R`）；源码已经按该真实位序打包颜色。
- BTN4 向左、BTN2 向右；平台原始按钮低有效，顶层已经转换为逻辑高有效。
- 按住按钮时，每 100 ms 移动 8 像素。
- 左右边界分别钳位到 `x=0` 和 `x=556`，挡板不会越出屏幕。
- 按 RST 后立即回到中央位置。
- 数码管全部消隐，LED 全部关闭，避免与视频任务无关的显示干扰。

## CPU 与外设

挡板位置由五级流水线 CPU 执行 `program/paddle.asm` 更新，而不是由按钮直接驱动：

- IF/ID/EX/MEM/WB 五级流水线。
- 支持 `ADD/SUB/AND/OR/SLT/ADDI/LW/SW/BEQ/BNE/J`。
- 包含 EX/MEM、MEM/WB 前递，load-use 停顿和控制冒险冲刷。
- `0x00004000`：逻辑高有效按钮，BTN4 为 bit 3，BTN2 为 bit 1。
- `0x00004004`：每 100 ms 加一的定时计数器。
- `0x00004008`：挡板左边界 x 坐标写寄存器。

视频模块产生标准的 640/16/96/48 水平和 480/10/2/33 垂直时序。CPU 坐标经过双触发器同步，并只在帧起点更新到绘图寄存器，避免一帧中途撕裂。

## 目录

- `src/`：流水线 CPU、ROM、定时器、VGA 时序、绘图器、时钟和平台顶层。
- `program/`：带注释的汇编程序及对应机器码。
- `sim/tb_task16.v`：Vivado 行为仿真 testbench。
- `scripts/`：仿真、构建、工程检查脚本。
- `ip_repo/`：题目提供的 `cg_fpga v1.4` IP。
- `vivado/task16.xpr`：已完成实现的 Vivado 工程。
- `output/task16.bit`：最终可下载 bit 文件。
- `reports/`：时序、资源、DRC 与时钟交互报告。

## 使用

直接下载：

1. 在在线 FPGA 平台选择 `output/task16.bit`。
2. 下载后按一次 RST。
3. 按住 BTN4 左移，按住 BTN2 右移。

查看工程时打开 `vivado/task16.xpr`。工程复制回中文目录后已经过重开验证，源文件和 IP 路径会相对工程位置自动重定位。

完整重建：

```powershell
& '.\task16\scripts\build.ps1'
```

脚本会先运行行为仿真，再执行综合、实现和 bitstream 生成。由于 Vivado 2022.2 在中文路径下生成题目 PS7 IP 会出错，脚本会自动在纯英文临时目录构建，然后把完整工程、报告和 bit 复制回来。

如果 Vivado 安装位置不同：

```powershell
& '.\task16\scripts\build.ps1' -VivadoBat 'D:\Xilinx\Vivado\2022.2\bin\vivado.bat'
```

验证结果见 `VERIFICATION.md`。
