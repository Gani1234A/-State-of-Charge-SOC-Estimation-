# Lithium-Ion Battery Modeling & SOC Estimation Using FPGA

## 📌 Project Overview

This project implements a **Lithium-Ion Battery Model and State of Charge (SOC) Estimation system using Xilinx FPGA and Vivado**. The design models battery voltage under dynamic load conditions and estimates SOC using both **Coulomb Counting** and **Open-Circuit Voltage (OCV)** methods.

The complete system is developed in **Verilog HDL** and verified through **Vivado Behavioral Simulation**, without MATLAB/Simulink.

## 🎯 Objectives

* Model a Lithium-Ion battery using the Rint model.
* Generate a dynamic battery load profile.
* Estimate SOC using Coulomb Counting.
* Estimate SOC using an OCV lookup table.
* Calculate battery terminal voltage.
* Compare both SOC estimation methods.
* Analyze SOC estimation error through simulation waveforms.
* Develop an FPGA-ready battery monitoring architecture.

## 🏗️ System Architecture

```text
                Dynamic Load Profile
                        │
                        ▼
                Current Generator
                        │
                        ▼
              ┌──────────────────┐
              │  Battery Model   │
              │   Rint Model     │
              └────────┬─────────┘
                       │
                Battery Voltage
                       │
              ┌────────┴────────┐
              ▼                 ▼
       Coulomb Counting       OCV Model
              │                 │
              ▼                 ▼
          SOC_CC             SOC_OCV
              │                 │
              └────────┬────────┘
                       ▼
                 SOC Comparison
                       │
                       ▼
                Error Calculation
```

## ⚙️ Battery Parameters

| Parameter           |       Value |
| ------------------- | ----------: |
| Battery Type        | Lithium-Ion |
| Capacity            |      2.5 Ah |
| Capacity            |    2500 mAh |
| Initial SOC         |        100% |
| Internal Resistance |       50 mΩ |
| Nominal OCV         |      ~4.2 V |
| Voltage Unit        |          mV |
| Current Unit        |          mA |
| SOC Resolution      |       0.01% |

## 🔋 Battery Model

The project uses the **Rint battery model**:

```text
Vbattery = OCV − I × R
```

where:

* `Vbattery` = terminal battery voltage
* `OCV` = open-circuit voltage
* `I` = battery current
* `R` = internal resistance

For the project:

```text
R = 50 mΩ
```

Positive current represents **discharge**, while negative current represents **charging**.

## 📊 SOC Estimation

### 1. Coulomb Counting

The SOC is calculated using:

```text
SOCnew = SOCold − (I × Δt / Capacity)
```

Positive current decreases SOC, while negative current increases SOC.

### 2. OCV-Based SOC

An OCV lookup table is used:

|  SOC |     OCV |
| ---: | ------: |
| 100% | 4200 mV |
|  90% | 4100 mV |
|  80% | 4050 mV |
|  70% | 4000 mV |
|  60% | 3950 mV |
|  50% | 3900 mV |
|  40% | 3850 mV |
|  30% | 3800 mV |
|  20% | 3750 mV |
|  10% | 3650 mV |
|   0% | 3000 mV |

## 🔄 Dynamic Load Profile

The simulation uses an 80-second repeating load profile:

```text
0–10 s    →  0 A
10–20 s   → +1 A discharge
20–30 s   → +2 A discharge
30–40 s   →  0 A
40–50 s   → −1 A charge
50–60 s   → +2 A discharge
60–70 s   →  0 A
70–80 s   → −0.5 A charge
```

## 📁 Project Files

```text
Project_1/
│
├── battery_model.v
├── voltage_model.v
├── load_profile.v
├── soc_coulomb.v
├── ocv_soc.v
├── soc_compare.v
├── battery_top.v
└── battery_tb.v
```

### File Description

| File              | Description                          |
| ----------------- | ------------------------------------ |
| `battery_model.v` | Basic battery/Rint model             |
| `voltage_model.v` | OCV and terminal voltage calculation |
| `load_profile.v`  | Generates dynamic battery current    |
| `soc_coulomb.v`   | Coulomb-counting SOC estimator       |
| `ocv_soc.v`       | OCV-to-SOC lookup                    |
| `soc_compare.v`   | Compares two SOC estimates           |
| `battery_top.v`   | Top-level FPGA design                |
| `battery_tb.v`    | Vivado simulation testbench          |

## 🧪 Simulation

The testbench uses a reduced simulation clock:

```text
Simulation Clock = 1 MHz
Clock Period     = 1000 ns
```

This is used to make behavioral simulation faster than using the actual 50 MHz FPGA clock.

### Important Waveform Signals

Add these signals in Vivado:

```text
clk
rst
current_ma
ocv_mv
battery_voltage_mv
soc_coulomb
soc_ocv
soc_signed_error
soc_abs_error
```

## ✅ Expected Results

During discharge:

```text
Current ↑
   ↓
SOC decreases
   ↓
OCV decreases
   ↓
Battery voltage decreases
```

During charging:

```text
Current < 0
   ↓
SOC increases
   ↓
OCV increases
```

The terminal voltage follows:

```text
Vbattery = OCV − I×R
```

The difference between Coulomb-counting SOC and OCV-based SOC is monitored using:

```text
SOC Error = SOC_Coulomb − SOC_OCV
```

## 🛠️ Tools Used

* **Xilinx Vivado**
* **Verilog HDL**
* **Xilinx FPGA**
* **Vivado Behavioral Simulation**

## 🚀 Future Improvements

* Common FPGA time-base module
* SOC interpolation instead of threshold lookup
* Temperature-dependent battery model
* State-of-Health (SOH) estimation
* Extended Kalman Filter (EKF)
* Real battery sensor interface
* ADC integration
* FPGA board hardware implementation
* Real-time SOC display using LEDs/UART/LCD

## 👨‍💻 Project Status

**Current Stage:** Verilog design and Vivado behavioral simulation

**Implementation Approach:** FPGA + Vivado only, without MATLAB/Simulink.
