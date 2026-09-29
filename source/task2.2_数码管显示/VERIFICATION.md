# 验证结果

- 工具：Vivado 2022.2，目标器件 `xc7z020clg400-2`。
- 行为仿真：0-F 全部 16 个十六进制数字的 7 段码显示逐一验证通过。
- 数码管极性：低电平点亮；段码表为共阳极标准编码。
- 数码管位选：`seg_cs` 固定为 0，仅最右侧数码管点亮。
- 板级输入映射：下排拨码开关 `gpio_sw_1[3:0]`。
- 拨码极性：平台原始信号低有效，`task12_core` 内部取反；
  全部关闭时逻辑输入为 0。
- 复位显示：RST 按住期间数码管显示 `0`（段码 `8'hC0`）。
- 综合、实现、bitstream：全部完成。
- DRC：0 Errors、0 Critical Warnings。
- Setup：0 failing endpoints。
- Hold：0 failing endpoints。
- Slice LUTs：约 5000 / 53200。
- Slice Registers：约 7000 / 106400。
- Block RAM Tile：5 / 140。
- DSP：0 / 220。
- `output/task12.bit`：已生成。
