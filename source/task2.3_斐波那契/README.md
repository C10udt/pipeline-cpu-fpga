# 任务 13：流水线 CPU 计算斐波那契数列

本工程面向配套 `cg_fpga v1.4` 在线 FPGA 平台，目标器件为
`xc7z020clg400-2`，使用 Vivado 2022.2 构建。

## 功能

- 下排拨码开关 `gpio_sw_1[5:0]` 输入 `n`；平台原始信号低有效，顶层已取反，
  所有拨码关闭时 `n=0`。
- 五级 MIPS 风格流水线 CPU 执行 `program/fibonacci.asm`。
- CPU 读取 `0x4000` 的开关值，并把 `F(n)` 写到 `0x4004`。
- 九位动态扫描数码管以十进制显示结果，并自动消隐高位零。
- 平台数码管段信号为低电平点亮，驱动使用低有效段码和 `8'hFF` 消隐。
- `n=0` 或按住 RST 时九位数码管显示 `000000000`。
- 定义 `F(0)=0, F(1)=1, F(2)=1`；题目范围内最大示例为
  `F(44)=701408733`。

## CPU 特性

- IF/ID/EX/MEM/WB 五级流水线。
- 支持 `ADD/SUB/AND/OR/SLT/ADDI/LW/SW/BEQ/BNE/J`。
- EX/MEM、MEM/WB 数据前递。
- load-use 冒险自动停顿一个周期。
- taken branch 和 jump 自动冲刷流水线。

## 目录

- `src/`：CPU、指令 ROM、数码管驱动、平台顶层。
- `program/`：汇编程序与对应机器码。
- `sim/`：Vivado 行为仿真 testbench。
- `scripts/`：仿真和 bitstream 构建脚本。
- `ip_repo/`：题目提供的 `cg_fpga v1.4` IP。
- `vivado/`：脚本生成的 Vivado 工程。
- `output/task13.bit`：最终 bit 文件。
- `reports/`：时序、资源和 DRC 报告。

## 重新运行

由于 Vivado 2022.2 在含中文的路径下生成配套 PS7 IP 时会发生路径编码错误，
请使用封装脚本。它会在纯 ASCII 临时目录中仿真和构建，然后把完整工程、
报告与 bit 文件自动复制回来：

```powershell
& '.\task13\scripts\build.ps1'
```

如果 Vivado 安装位置不同：

```powershell
& '.\task13\scripts\build.ps1' -VivadoBat 'D:\Xilinx\Vivado\2022.2\bin\vivado.bat'
```

仅重新运行核心行为仿真时，可直接执行：

```powershell
& 'E:\Xilinx\Vivado\2022.2\bin\vivado.bat' -mode batch -source '.\task13\scripts\run_sim.tcl'
```

工程验证数据见 `VERIFICATION.md`。

下载 bit 后，先按一次 RST，再用下排低 6 位拨码开关设置 `n`。
