# Synchronous-Fifo
Created a personal project synchronous fifo
# Synchronous FIFO (First-In, First-Out) in Verilog

A parameterizable Synchronous FIFO designed in Verilog HDL and verified with a self-checking testbench. This repository includes complete RTL, testbench code, GTKWave waveform analysis, and Yosys synthesis results.

## Technical Specifications

* **Clocking:** Single Clock Domain (Synchronous Read/Write).
* **Configurable Parameters:**
  * `DATA_WIDTH`: Default = 8 bits.
  * `FIFO_DEPTH`: Default = 8 words.
* **Output Architecture:** First-Word Fall-Through (FWFT) combinational read interface.
* **Flag Generation:** Pointer-width expansion bit technique to accurately differentiate between `FULL` and `EMPTY` conditions.
* **Reset:** Asynchronous Active-Low (`rst_n`).

---

## Design Overview

### Block Diagram & Flag Logic
The FIFO uses an extra MSB bit on the read/write pointers (`PTR_WIDTH = $clog2(FIFO_DEPTH) + 1`):
* **EMPTY Condition:** `wrt_ptr == rd_ptr`
* **FULL Condition:** `wrt_ptr[PTR_WIDTH-1] != rd_ptr[PTR_WIDTH-1]` AND `wrt_ptr[PTR_WIDTH-2:0] == rd_ptr[PTR_WIDTH-2:0]`

### RTL Schematic
![
<img width="964" height="696" alt="Waveform fifo" src="https://github.com/user-attachments/assets/0278049e-5500-43a9-9954-3e5350efac66" />
](schematic fifo.png)
*Synthesized gate-level representation generated via Yosys.
## Verification & Simulation Results

The testbench (`tb/sfifo_tb.v`) exercises the following test cases:
1. **Sequential Fill Operations:** Fills the FIFO to capacity with incremental data (`0x05` to `0x28`).
2. **Overflow Handling:** Attempts writing when `FULL = 1` to verify write-blocking.
3. **Sequential Read Operations:** Reads all data out to verify First-In, First-Out ordering and FWFT timing alignment.
4. **Underflow Handling:** Attempts reading when `EMPTY = 1` to verify read-blocking.

### Waveform Analysis
![<img width="964" height="696" alt="Waveform fifo" src="https://github.com/user-attachments/assets/13714fb8-f053-45bc-9967-53f3c5dbaea1" />
](Waveform fifo.png)

#### Important Architectural Note (FWFT Read Alignment):
Because `data_out` is combinationally driven (`assign data_out = fifo_ram[rd_ptr]`), data is valid **before** `read_en` is pulsed. The testbench samples `data_out` prior to stepping `rd_ptr` on `posedge clk`, ensuring 0-cycle latency read access without dropping the head entry (`0x05`).
## How to Run Simulation

### Prerequisites
* **Compiler:** Icarus Verilog (`iverilog`)
* **Waveform Viewer:** GTKWave

### Execution Commands
```bash
# 1. Compile design and testbench
iverilog -o sim/sfifo_sim.out rtl/sfifo.v tb/sfifo_tb.v

# 2. Run simulation and generate VCD
vvp sim/sfifo_sim.out

# 3. View waveforms
gtkwave sim/sfifo_dump.vcd
```
