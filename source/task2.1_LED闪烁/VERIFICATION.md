# 验证结果

- 工具：Vivado 2022.2，目标器件 `xc7z020clg400-2`。
- 行为仿真：LED0 亮 → 灭 → 亮 → 灭 循环通过。
- 板级输出映射：32 颗 LED 对应 `gpio_led[31:0]`。
- LED 极性：平台信号低有效，顶层取反；CPU 写 1 → gpio_led 对应位为 0 → LED 亮。
- 复位显示：RST 按住期间 `led_value = 0`，所有 LED 熄灭。
- 综合、实现、bitstream：全部完成。
- DRC：0 Errors、0 Critical Warnings。
- Setup：0 failing endpoints。
- Hold：0 failing endpoints。
- Slice LUTs：约 5000 / 53200。
- Slice Registers：约 7000 / 106400。
- Block RAM Tile：5 / 140。
- DSP：0 / 220。
- `output/task11.bit`：已生成。
