# FPGA Image Processing System
### Terasic ADC-SoC | Cyclone V | VHDL | Quartus Prime Lite

![FPGA](https://img.shields.io/badge/FPGA-Cyclone%20V-blue)
![Language](https://img.shields.io/badge/Language-VHDL-orange)
![Tool](https://img.shields.io/badge/Tool-Quartus%20Prime%20Lite%2018.1-green)
![Status](https://img.shields.io/badge/Status-Working-brightgreen)

---
1
## 📺 Project Demo

A fully working real-time image processing system implemented entirely in **FPGA hardware logic** (no CPU, no Linux, no ARM processor).

The system drives a **4.3-inch 800×480 LCD touch panel** and performs:

| Mode | Switch | Description |
|------|--------|-------------|
| Colour Test Pattern | SW1=0, SW0=0 | 8-bar colour test pattern |
| Full Colour Image | SW1=0, SW0=1 | Image loaded from Block RAM |
| Grayscale | SW1=1, SW0=0 | Real-time RGB→Grayscale |
| Sobel Edge Detection | SW1=1, SW0=1 | Real-time Sobel edges |

---

## 🛠 Hardware

| Component | Details |
|-----------|---------|
| FPGA Board | Terasic ADC-SoC Development Board |
| FPGA Device | Cyclone V SE — 5CSEMA4U23C6N |
| Logic Elements | 40K |
| Embedded Memory | 2,460 Kbits |
| Clock Sources | 3× 50 MHz oscillators |
| Display | Terasic 4.3" LCD Touch Panel (TRDB-LTM) |
| Resolution | 800 × 480 pixels |
| Touch Controller | AD7843 12-bit ADC (SPI) |
| Programming | USB-Blaster II — JTAG |

---

## 📁 Project Structure

```
fpga-image-processing/
├── src/
│   ├── top_level.vhd         # Top-level entity — connects all modules
│   ├── lcd_timing.vhd        # LCD horizontal/vertical timing generator
│   ├── test_pattern.vhd      # 8-bar colour test pattern
│   ├── image_rom.vhd         # On-chip Block RAM image storage
│   ├── rgb_to_gray.vhd       # RGB to Grayscale converter (pipeline)
│   ├── line_buffer.vhd       # 3-line buffer for 3×3 sliding window
│   ├── sobel.vhd             # Sobel edge detection (pipeline)
│   └── ad7843_ctrl.vhd       # SPI touch screen controller
├── scripts/
│   └── convert_to_mif.py     # Python: converts image to Quartus MIF format
├── docs/
│   ├── pin_assignments.md    # All FPGA pin assignments
│   └── timing_parameters.md  # LCD timing parameters
└── README.md
```

---

## ⚙️ System Architecture

```
50 MHz Clock (FPGA_CLK1_50)
        │
        ▼
   pll_33mhz          ← Generates 33.25 MHz pixel clock
        │
        ▼
   lcd_timing          ← HD, VD, DEN, NCLK signals for LCD
        │
        ├──────────────────────────────────────────┐
        │                                          │
        ▼                                          ▼
  image_rom             SW=00              test_pattern
  (Block RAM)        ─────────►          (colour bars)
        │
        ▼
  rgb_to_gray         ← Gray = (306R + 601G + 117B) >> 10
        │
        ▼
  line_buffer          ← Stores 2 full lines for 3×3 window
        │
        ▼
    sobel              ← Gx, Gy kernels → |Gx|+|Gy| magnitude
        │
        ▼
  Display MUX          ← Selects output based on SW[1:0]
        │
        ▼
  LCD 800×480          ← 24-bit RGB parallel interface
```

---

## 🔌 LCD Pin Mapping

The LCD connects to **GPIO_1 (JP7)** header on the ADC-SoC board.

| LCD Pin | Signal | GPIO_1 | FPGA Pin |
|---------|--------|--------|----------|
| 1 | ADC_PENIRQ_N | [0] | Y15 |
| 2 | ADC_DOUT | [1] | AC24 |
| 3 | ADC_BUSY | [2] | AA15 |
| 4 | ADC_DIN | [3] | AD23 |
| 5 | ADC_DCLK | [4] | AG28 |
| 10 | NCLK | [9] | AH27 |
| 13 | DEN | [10] | AG25 |
| 14 | HD | [11] | AH26 |
| 15 | VD | [12] | AH24 |
| 19 | B7 | [16] | AG24 |
| 27 | G7 | [24] | AG20 |
| 37 | R7 | [32] | AG15 |
| 29 | VCC33 | 3.3V | — |
| 12,30 | GND | GND | — |

Full pin table in `docs/pin_assignments.md`

---

## 📐 LCD Timing Parameters

| Parameter | Value |
|-----------|-------|
| Pixel Clock | 33.25 MHz |
| H Active | 800 pixels |
| H Total | 1056 clocks |
| H Front Porch | 40 |
| H Back Porch | 215 |
| V Active | 480 lines |
| V Total | 525 lines |
| V Front Porch | 10 |
| V Back Porch | 34 |
| Frame Rate | ~60 Hz |

---

## 🖥️ Grayscale Algorithm

Uses fixed-point arithmetic to avoid floating point in hardware:

```
Gray = (306×R + 601×G + 117×B) >> 10

Where:
  306/1024 ≈ 0.299  (red weight)
  601/1024 ≈ 0.587  (green weight)
  117/1024 ≈ 0.114  (blue weight)
```

Implemented as a **3-stage pipeline** running at 33.25 MHz.

---

## 🔲 Sobel Edge Detection

Two 3×3 convolution kernels applied simultaneously:

```
Gx kernel:          Gy kernel:
-1  0 +1           -1 -2 -1
-2  0 +2            0  0  0
-1  0 +1           +1 +2 +1

Magnitude = |Gx| + |Gy|   (Manhattan distance)
```

Implemented as a **3-stage pipeline** after a 3-line circular buffer.

---

## 📦 Image Storage

- Images stored in on-chip **Block RAM** (76,800 words × 24-bit)
- 320×240 pixels scaled to 800×480 using pixel repetition
- Image converted to Quartus `.mif` format using Python script

### Convert your own image:
```bash
pip install Pillow
python scripts/convert_to_mif.py your_image.jpg image_data.mif
```

---

## 🚀 How to Build and Run

### Requirements
- Quartus Prime Lite 18.1
- Windows PC
- Terasic ADC-SoC board
- Terasic TRDB-LTM 4.3" LCD module
- USB cable (USB-Blaster II)

### Steps

**1. Clone this repository**
```bash
git clone https://github.com/YOUR_USERNAME/fpga-image-processing.git
```

**2. Open Quartus**
- File → Open Project → select `lcd_project.qpf`

**3. Convert your image (optional)**
```bash
python scripts/convert_to_mif.py my_photo.jpg image_data.mif
```
Copy `image_data.mif` into the project folder.

**4. Compile**
- Press `Ctrl+L` or Processing → Start Compilation

**5. Program FPGA**
- Tools → Programmer → Start

**6. Test on hardware**

| SW1 | SW0 | Mode |
|-----|-----|------|
| 0 | 0 | Colour bars |
| 0 | 1 | Full colour image |
| 1 | 0 | Grayscale |
| 1 | 1 | Sobel edges |

---

## 📊 Resource Utilization

| Resource | Used | Available | % |
|----------|------|-----------|---|
| Logic Elements (ALMs) | 6,432 | 15,880 | 41% |
| Registers | 13,018 | — | — |
| Block Memory Bits | 1,843,200 | 2,764,800 | 67% |
| PLLs | 1 | 5 | 20% |
| DSP Blocks | 2 | 84 | 2% |
| I/O Pins | 51 | 314 | 16% |

---

## ✅ What I Learned

- VHDL hardware description language
- FPGA digital design flow (RTL → Synthesis → Place & Route)
- LCD timing signal generation (HD, VD, DEN, NCLK)
- Fixed-point arithmetic in hardware (no floating point)
- Pipelined digital signal processing
- SPI protocol implementation (AD7843 touch controller)
- Quartus Prime project setup, compilation, and JTAG programming
- Image format conversion for FPGA Block RAM initialization

---

## 📄 License

MIT License — free to use for learning and projects.

---

## 👤 Author

Made with ❤️ using pure FPGA logic — no CPU, no Linux, no ARM.
