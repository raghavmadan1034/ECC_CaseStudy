# Verilog Finite Field Multiplier for Curve25519

## Overview

[cite_start]This project is a Verilog implementation of a finite field multiplier designed for the prime field $GF(P)$ where $P = 2^{255} - 19$[cite: 52]. This multiplier is a fundamental component for cryptographic accelerators, particularly for operations on the elliptic curve Curve25519.

[cite_start]The module takes two 255-bit operands, `a` and `b`, and computes their product modulo `P`, which is $(a \cdot b) \pmod{P}$[cite: 22, 36].

## Key Features

* [cite_start]**High-Speed Modular Reduction**: Implements a fast modular reduction algorithm that avoids costly division operations by leveraging the special form of the prime $P=2^{255}-19$[cite: 36, 48].
* [cite_start]**Resource-Efficient Multiplication**: Utilizes a custom, iterative 264x256-bit multiplier (`dsp_mul`)[cite: 1]. [cite_start]This module breaks the operation into smaller 24x16-bit chunks, making it suitable for synthesis on FPGA DSP blocks[cite: 4, 5, 6].
* [cite_start]**FSM-Controlled Architecture**: The entire multi-cycle operation is managed by a hierarchical Finite State Machine (FSM) for precise and reliable control[cite: 3, 4, 63].

## Algorithm Details: Modular Reduction

The core of this design is the efficient modular reduction method described in `doc(1).pdf`.

1.  [cite_start]**Multiplication**: Two 255-bit numbers, `a` and `b`, are first multiplied to produce a 510-bit product, `C`[cite: 22, 27].
2.  [cite_start]**Partitioning**: The 510-bit product `C` is partitioned into six 85-bit words: $C_5, C_4, C_3, C_2, C_1, C_0$[cite: 28]. [cite_start]This is implemented in the Verilog by wiring segments of the `product` wire to `C0` through `C5`[cite: 55, 56].
3.  [cite_start]**Reduction using Congruence**: The reduction leverages the key property that $2^{255} \equiv 19 \pmod{P}$[cite: 32]. This allows higher-order parts of the product to be folded back into the lower 255 bits.
4.  [cite_start]**Intermediate Sums**: Three intermediate sums are calculated[cite: 39]:
    * [cite_start]$S_0 = C_0 + 19 \cdot C_3$ [cite: 41]
    * [cite_start]$S_1 = C_1 + 19 \cdot C_4$ [cite: 42]
    * [cite_start]$S_2 = C_2 + 19 \cdot C_5$ [cite: 43]
    * [cite_start]The multiplication by 19 is implemented efficiently in hardware using shifts and additions: `(x << 4) + (x << 1) + x`[cite: 58, 59, 60].
5.  [cite_start]**Reconstruction**: The sums are combined to form a result `R` that is congruent to the original product `C`[cite: 45].
6.  [cite_start]**Final Reduction**: Since `R` might still be larger than `P`, one final subtraction may be performed to bring the result into the range $[0, P-1]$[cite: 46, 74].

## Hardware Architecture

The design is hierarchical, consisting of two main modules:

### `finite_multiplier.v`

This is the top-level module that orchestrates the entire operation.
* [cite_start]It instantiates the `dsp_mul` core[cite: 54].
* [cite_start]It implements the modular reduction logic, including partitioning the product and calculating $S_0, S_1, S_2$ [cite: 55-62].
* [cite_start]It contains the main FSM to control the flow from multiplication to reduction and output[cite: 63].

### `dsp_mul.v`

This module is a specialized, iterative multiplier designed to handle large operands efficiently.
* [cite_start]It computes the product of a 264-bit and a 256-bit input[cite: 1].
* [cite_start]It works by sequentially calculating 24x16 bit partial products and accumulating them over multiple clock cycles[cite: 4, 5, 6, 12, 13].
* [cite_start]It is controlled by its own internal FSM[cite: 3, 4].

## State Machine Descriptions

### `finite_multiplier` FSM

* [cite_start]`IDLE`: Waits for the `start` signal[cite: 67].
* [cite_start]`WAIT_MULT`: Triggers the `dsp_mul` core and waits for its `mult_valid` signal[cite: 68, 70].
* [cite_start]`REDUCE`: Performs the final subtraction of `P` if the intermediate result is too large[cite: 74].
* [cite_start]`OUT`: Asserts the `valid` signal and presents the final `result`[cite: 76, 77].

### `dsp_mul` FSM

* [cite_start]`IDLE`: Waits for the `start` signal[cite: 10].
* [cite_start]`COMPUTE`: Iterates through segments of the operands, calculating and accumulating partial products[cite: 12, 13, 16, 17].
* [cite_start]`DONE`: Asserts the `valid` signal to indicate the multiplication is complete[cite: 18].

## How to Use

1.  **Inputs**:
    * `clk`: System clock.
    * `rst`: Active-high reset.
    * `start`: A single-cycle pulse to begin the multiplication.
    * `a`, `b`: The two 255-bit operands.
2.  **Outputs**:
    * `result`: The 255-bit result of $(a \cdot b) \pmod{P}$.
    * `valid`: A signal that goes high for one cycle when the `result` is ready.
3.  **Operation Flow**:
    * Apply `rst`.
    * Provide the inputs `a` and `b`.
    * Pulse `start` high for one clock cycle.
    * The multiplier will begin its computation. After a number of cycles, the `valid` signal will be asserted, and the correct `result` will be available on the same cycle.
