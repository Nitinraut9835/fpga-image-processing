# Pin Assignments — ADC-SoC Board

## Clock
| Signal | FPGA Pin | Notes |
|--------|----------|-------|
| FPGA_CLK1_50 | V11 | 50 MHz input clock |

## Push Buttons
| Signal | FPGA Pin |
|--------|----------|
| KEY[0] | AH17 |
| KEY[1] | AH16 |

## Slide Switches
| Signal | FPGA Pin |
|--------|----------|
| SW[0] | Y11 |
| SW[1] | AA11 |
| SW[2] | AD5 |
| SW[3] | AE6 |

## LEDs
| Signal | FPGA Pin |
|--------|----------|
| LED[0] | W15 |
| LED[1] | AA24 |
| LED[2] | V16 |
| LED[3] | V15 |
| LED[4] | AF26 |
| LED[5] | AE26 |
| LED[6] | Y16 |
| LED[7] | AA23 |

## LCD Interface (via GPIO_1 / JP7)

| LCD Pin | Signal | GPIO_1 Index | FPGA Pin |
|---------|--------|-------------|----------|
| 1 | ADC_PENIRQ_N | [0] | Y15 |
| 2 | ADC_DOUT | [1] | AC24 |
| 3 | ADC_BUSY | [2] | AA15 |
| 4 | ADC_DIN | [3] | AD23 |
| 5 | ADC_DCLK | [4] | AG28 |
| 6 | B3 | [5] | AF28 |
| 7 | B2 | [6] | AE25 |
| 8 | B1 | [7] | AF27 |
| 9 | B0 | [8] | AG26 |
| 10 | NCLK | [9] | AH27 |
| 11 | NC | 5V (safe-NC) | — |
| 12 | GND | GND | — |
| 13 | DEN | [10] | AG25 |
| 14 | HD | [11] | AH26 |
| 15 | VD | [12] | AH24 |
| 16 | B4 | [13] | AF25 |
| 17 | B5 | [14] | AG23 |
| 18 | B6 | [15] | AF23 |
| 19 | B7 | [16] | AG24 |
| 20 | G0 | [17] | AH22 |
| 21 | G1 | [18] | AH21 |
| 22 | G2 | [19] | AG21 |
| 23 | G3 | [20] | AH23 |
| 24 | G4 | [21] | AA20 |
| 25 | G5 | [22] | AF22 |
| 26 | G6 | [23] | AE22 |
| 27 | G7 | [24] | AG20 |
| 28 | R0 | [25] | AF21 |
| 29 | VCC33 | 3.3V | — |
| 30 | GND | GND | — |
| 31 | R1 | [26] | AG19 |
| 32 | R2 | [27] | AH19 |
| 33 | R3 | [28] | AG18 |
| 34 | R4 | [29] | AH18 |
| 35 | R5 | [30] | AF18 |
| 36 | R6 | [31] | AF20 |
| 37 | R7 | [32] | AG15 |
| 38 | GREST | [33] | AE20 |
| 39 | SCEN | [34] | AE19 |
| 40 | SDA | [35] | AE17 |

## IO Standard
All signals: **3.3-V LVTTL**
