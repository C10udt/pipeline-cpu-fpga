# 验证结果

- 工具：Vivado 2022.2，目标器件 `xc7z020clg400-2`。
- 行为仿真：`F(1)=1`、`F(4)=3`、`F(44)=701408733` 全部通过。
- 数码管仿真：九位扫描段码 `701408733` 逐位检查通过。
- 数码管极性：低电平点亮；高位消隐码为 `8'hFF`。
- 板级输入映射：下排拨码开关 `gpio_sw_1[5:0]`。
- 拨码极性：平台原始信号低有效，顶层取反；全部关闭时逻辑输入为 0。
- 零值/复位显示：`n=0` 和 RST 按住期间九位均输出零段码 `8'hC0`。
- 综合、实现、bitstream：全部完成。
- DRC：0 Errors、0 Critical Warnings；4 个普通 Warning 均来自题目提供的
  `cg_fpga` AXI 平台 IP。
- Setup：0 failing endpoints，WNS = 2.165 ns。
- Hold：0 failing endpoints，WHS = 0.049 ns。
- Slice LUTs：5196 / 53200 (9.77%)。
- Slice Registers：7095 / 106400 (6.67%)。
- Block RAM Tile：5 / 140 (3.57%)。
- DSP：0 / 220。
- `output/task13.bit` 大小：4,045,670 bytes。
- SHA256：`236834CCDE4369DFA8E70BEC68AD25AD1B5983FD4B5D58D3EEF75CFF19ACB078`。
