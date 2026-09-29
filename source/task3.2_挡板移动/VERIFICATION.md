# 任务 16 验证结果

## 行为仿真

Vivado XSim testbench 已通过以下检查：

- RST 时挡板初始位置为 `x=278`。
- 有效区背景在平台 `G_B_R_444` 位序下输出 `vid_data=0x00FF00`，实际显示为蓝色。
- 挡板输出 `vid_data=0x0000FF`，实际显示为绿色，尺寸边界严格为 84×24 像素。
- 水平视频时序为 640 有效、16 前沿、96 同步、48 后沿。
- BTN4 对应逻辑 bit 3，向左每次移动 8 像素。
- BTN2 对应逻辑 bit 1，向右每次移动 8 像素。
- 松开按钮停止移动。
- 左边界钳位 `x=0`，右边界钳位 `x=556`。
- RST 可从任意位置恢复到 `x=278`。
- 仿真最终输出 `ALL TASK16 TESTS PASSED`。

testbench 为加快运行，把定时器周期参数缩短为 120 个 CPU 周期；综合顶层使用正式值 10,000,000 个 100 MHz 周期，即 100 ms。

## 综合与实现

- 工具：Vivado 2022.2。
- 器件：`xc7z020clg400-2`。
- 顶层：`task16_top`。
- bitstream：生成成功。
- 时序：所有用户时序约束满足。
- WNS：1.581 ns。
- WHS：0.037 ns。
- 100 MHz CPU 时钟和 25 MHz 像素时钟均被正确识别。
- Slice LUTs：4,985 / 53,200（9.37%）。
- Slice Registers：7,633 / 106,400（7.17%）。
- Block RAM Tile：5 / 140（3.57%）。
- DSP：0 / 220。
- DRC：0 Errors，0 Critical Warnings；4 个 Warning 和 3 个 Advisory 均位于题目提供的 `cg_fpga` AXI/VDMA 平台 IP 内部。

## 交付校验

- `output/task16.bit` 大小：4,045,670 bytes。
- SHA256：`DAE3413327B5855CE123BC62F2FC8575893A8C444493CA9F83FFB8B7C00BA7A3`。
- 复制回当前中文目录后的 `vivado/task16.xpr` 已用 Vivado 批处理方式重新打开并检查：器件、顶层和 `write_bitstream Complete!` 状态均正确。
