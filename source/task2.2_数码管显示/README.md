# 任务 12：流水线 CPU 控制数码管显示数字

本工程面向配套 `cg_fpga v1.4` 在线 FPGA 平台，目标器件为
`xc7z020clg400-2`，使用 Vivado 2022.2 构建。

## 功能

- 下排拨码开关低四位 `gpio_sw_1[3:0]` 输入 4 位二进制值（0-F）。
  平台原始信号低有效，`task12_core` 内部取反，使所有拨码关闭时输入为 0。
- 五级 MIPS 风格流水线 CPU 执行 `program/hex_display.asm`。
- CPU 读取 `0x4000` 的开关值，用 `ANDI` 指令取低 4 位，
  然后把原始值写到 `0x4004`。
- `hex_segment` 模块将 4 位值编码为共阳极 7 段码（支持 0-F 十六进制），
  驱动最右侧单个数码管（`seg_cs = 0`）。
- 平台数码管段信号为低电平点亮；码表包含 A-F 的十六进制显示。
- 按住 RST 时数码管显示 `0`。

## CPU 特性

- IF/ID/EX/MEM/WB 五级流水线。
- 支持 `ADD/SUB/AND/OR/SLT/ADDI/ANDI/LW/SW/BEQ/BNE/J`。
- EX/MEM、MEM/WB 数据前递。
- load-use 冒险自动停顿一个周期。
- taken branch 和 jump 自动冲刷流水线。

## 目录

- `src/`：CPU、指令 ROM、十六进制 7 段编码器、平台顶层。
- `program/`：汇编程序与对应机器码。
- `sim/`：Vivado 行为仿真 testbench。
- `scripts/`：仿真和 bitstream 构建脚本。
- `ip_repo/`：题目提供的 `cg_fpga v1.4` IP。
- `vivado/`：脚本生成的 Vivado 工程。
- `output/task12.bit`：最终 bit 文件。
- `reports/`：时序、资源和 DRC 报告。

## 重新运行

由于 Vivado 2022.2 在含中文的路径下生成配套 PS7 IP 时会发生路径编码错误，
请使用封装脚本。它会在纯 ASCII 临时目录中仿真和构建，然后把完整工程、
报告与 bit 文件自动复制回来：

```powershell
& '.\task12\scripts\build.ps1'
```

如果 Vivado 安装位置不同：

```powershell
& '.\task12\scripts\build.ps1' -VivadoBat 'D:\Xilinx\Vivado\2022.2\bin\vivado.bat'
```

仅重新运行核心行为仿真时，可直接执行：

```powershell
& 'E:\Xilinx\Vivado\2022.2\bin\vivado.bat' -mode batch -source '.\task12\scripts\run_sim.tcl'
```

工程验证数据见 `VERIFICATION.md`。

下载 bit 后，先按一次 RST，然后用下排最右侧 4 位拨码开关设置输入值，
最右侧数码管将显示对应的十六进制数字（0-F）。
