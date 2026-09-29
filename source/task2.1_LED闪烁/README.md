# 任务 11：流水线 CPU 控制 LED 闪烁

本工程面向配套 `cg_fpga v1.4` 在线 FPGA 平台，目标器件为
`xc7z020clg400-2`，使用 Vivado 2022.2 构建。

## 功能

- 五级 MIPS 风格流水线 CPU 执行 `program/led_blink.asm`。
- CPU 向地址 `0x4004` 写入 1 或 0 控制 32 颗 LED 亮灭。
- 通过嵌套软件延时循环实现约 1 Hz 的 LED0 闪烁。
- 平台 LED 信号低有效，顶层通过 `~led_value` 取反适配。
- 按住 RST 时所有 LED 熄灭。

## CPU 特性

- IF/ID/EX/MEM/WB 五级流水线。
- 支持 `ADD/SUB/AND/OR/SLT/ADDI/ANDI/LW/SW/BEQ/BNE/J`。
- EX/MEM、MEM/WB 数据前递。
- load-use 冒险自动停顿一个周期。
- taken branch 和 jump 自动冲刷流水线。

## 目录

- `src/`：CPU、指令 ROM、平台顶层。
- `program/`：汇编程序与对应机器码。
- `sim/`：Vivado 行为仿真 testbench。
- `scripts/`：仿真和 bitstream 构建脚本。
- `ip_repo/`：题目提供的 `cg_fpga v1.4` IP。
- `vivado/`：脚本生成的 Vivado 工程。
- `output/task11.bit`：最终 bit 文件。
- `reports/`：时序、资源和 DRC 报告。

## 重新运行

由于 Vivado 2022.2 在含中文的路径下生成配套 PS7 IP 时会发生路径编码错误，
请使用封装脚本。它会在纯 ASCII 临时目录中仿真和构建，然后把完整工程、
报告与 bit 文件自动复制回来：

```powershell
& '.\task11\scripts\build.ps1'
```

如果 Vivado 安装位置不同：

```powershell
& '.\task11\scripts\build.ps1' -VivadoBat 'D:\Xilinx\Vivado\2022.2\bin\vivado.bat'
```

仅重新运行核心行为仿真时，可直接执行：

```powershell
& 'E:\Xilinx\Vivado\2022.2\bin\vivado.bat' -mode batch -source '.\task11\scripts\run_sim.tcl'
```

工程验证数据见 `VERIFICATION.md`。

下载 bit 后，先按一次 RST，LED0 将以约 1 Hz 的频率闪烁。
