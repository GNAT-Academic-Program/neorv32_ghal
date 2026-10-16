# NEORV32 Drivers — Fall 2026 Project Plan

**Team:** 3–4 students per team  
**Period:** October 19 – December 11, 2026 (8 weeks)  
**Target:** NEORV32 **v1.13.6** on MicroNova Mercury 2 or Digilent Nexys 4 / Nexys 4 DDR  
**Language:** Ada, using Alire and the GNAT Academic Program's generic hardware interfaces  
**Goal:** Implement small, tested peripheral drivers that other Ada projects can reuse.

## 1. What are we building?

NEORV32 is a RISC-V processor implemented inside an FPGA. The processor executes Ada software, but it does not automatically know how to talk to everything connected to it: serial buses, timers, LEDs, and other peripherals.

A **driver** is the piece of software that controls one such peripheral. It knows which registers to read and write, which bits mean *busy* or *ready*, and how to handle an error.

Consider an SPI transaction. An application wants to exchange one byte with a device. It should not need to know where NEORV32 stores its SPI control register. It should simply call an SPI operation. The NEORV32 driver translates that request into register accesses and waits for the transfer to finish.

This semester we will add drivers to an existing Ada stack, not write an operating system or redesign the processor. Each team takes a different set of peripherals. By December, a driver should compile, run on real hardware, produce a repeatable PASS/FAIL test, and come with enough documentation for another student to use it.

**The important distinction:** A program that compiles is not yet a working driver. A driver is complete only when the hardware test demonstrates the claimed behavior on a bitstream that actually contains the peripheral.

## 2. The repositories and how they fit together

There are several layers. Learn what belongs in each one before starting a pull request.

```text
Ada example or hardware test
          |
          v
Board-level Ada setup (which UART, which pins, which connected device)
          |
          v
Generic Ada interface (what an SPI/UART/I2C driver must provide)
          |
          v
NEORV32-specific driver body (the register operations)
          |
          v
Generated SVD register packages
          |
          v
NEORV32 peripheral enabled inside the FPGA bitstream
          |
          v
Physical pins, wires, LEDs, sensors, or other equipment
```

### The NEORV32 Ada crate

Repository: [GNAT-Academic-Program/neorv32_ghal](https://github.com/GNAT-Academic-Program/neorv32_ghal)

Its Alire crate is named `neorv32`. It already has generated register packages under `src/svd/`, system information in `NEORV32_System`, a GPIO driver, and a **polled UART driver**. Do not implement these existing pieces again merely to have something to submit.

New NEORV32 driver bodies belong here, generally in a `src/<peripheral>/` directory. For example, an SPI driver deals with NEORV32 SPI registers. It should not decide which board header carries MOSI or which external chip is attached.

The register packages in `src/svd/` were generated from the NEORV32 **v1.13.6** SVD. **Do not edit them.** A driver should use those declarations and the v1.13.6 datasheet. Also check register read side effects: reading a receive FIFO may consume a byte; a field assignment that first reads a register can therefore cause bugs.

### The generic interfaces

Existing examples include [spi_generic](https://github.com/GNAT-Academic-Program/spi_generic), [i2c_generic](https://github.com/GNAT-Academic-Program/i2c_generic), and [usart_generic](https://github.com/GNAT-Academic-Program/usart_generic).

A generic interface describes *what an operation means* without depending on a particular chip. The NEORV32 body supplies the hardware-specific subprograms. Ada **generic instantiation** connects the two at compile time.

A generic crate is not automatically needed for every new peripheral: first check whether a suitable interface exists and whether the assigned peripheral can meet it. Reuse an existing interface without changing it when possible. If it does not exist, propose the small API and have it reviewed **before** implementing the driver body. Do not create a new, incompatible interface merely because it is easier than reading the existing one.

The MCU crate's README illustrates the two-stage pattern for UART: first instantiate `NEORV32_UART` for UART0, then instantiate `Usart_Interface` using the resulting driver operations. Read that example; it is a good introduction to Ada generics in this project.

### The FPGA board repositories

- [GNAT-Academic-Program/neorv32_mercury2](https://github.com/GNAT-Academic-Program/neorv32_mercury2)
- [GNAT-Academic-Program/neorv32_nexys4](https://github.com/GNAT-Academic-Program/neorv32_nexys4)

These are primarily **gateware** repositories: VHDL, FPGA constraints, build scripts, and programming instructions. They are not the same thing as an Ada board crate. Board-level Ada instantiations, pin choices, example applications, and test setup must be kept in the appropriate board/application code; create that glue if it is not provided.

Both repositories pin the processor source to NEORV32 v1.13.6. The Mercury 2 runs at 50 MHz; the Nexys 4 configuration runs at 100 MHz. Drivers should obtain the actual clock from `NEORV32_System.Clock_Hz`, not assume one fixed frequency. Check `NEORV32_System.Version_Matches` and whether each peripheral is implemented before accessing its registers.

**Do not use the older `neorv32-hal` repository as your starting point.** It represents a different, older setup. For this work, use the repositories listed above.

## 3. Important hardware prerequisite — resolve this before Week 3

The current published board configurations provide **GPIO, UART0, CLINT, and SYSINFO**. They do **not** yet include SPI, TWI, GPTMR, PWM, or NEOLED. The Nexys 4 top-level already requests 64-byte UART0 RX and TX FIFOs; the Mercury 2 top-level does not explicitly request those depths.

That means the original bitstreams are sufficient for the initial UART and GPIO work, **not** for most of the assigned new drivers.

The gateware owner / project mentor must provide updated, tested v1.13.6 bitstreams and publish the following information by **Friday, October 30** (end of Week 2), ready for Week 3 hardware work:

1. UART0 RX and TX FIFO depth set to 64 on **both** boards, plus the exact SoC profile used.
2. The peripheral enable settings, FIFO sizes, GPTMR slice count, and pin mappings required by the assigned team.
3. The board variant, bitstream file or release, and a way to verify at runtime that each peripheral is present.
4. Working external connections: SPI signals and loopback pins; TWI SDA/SCL with open-drain behavior and pull-ups; a PWM output; an NEOLED data output. Only include peripherals needed by the assigned teams.
5. For interrupt work, a known-good Ada runtime FIRQ test. For GPIO edge interrupts, an actual XIRQ input path or other explicitly documented gateware wiring is also required.

The TWI test additionally needs a **specific sensor or I2C device**, its address and voltage requirements, and the physical wiring. NEOLED needs a compatible addressable LED. PWM needs an accessible output (an external LED with suitable current limiting, or a measured output); the normal on-board GPIO LED does not become a PWM output by magic.

These are prerequisites, not extra driver assignments. The student teams should not lose several weeks inventing FPGA pin mappings or rebuilding the hardware stack. If a peripheral is not available by Week 3, report it as blocked and agree on a reduced target immediately. **Do not claim a hardware PASS for a peripheral that is not in the bitstream.**

## 4. How the team works

With **three students**, assign one person to each role. With **four**, two students share the driver work.

| Role | Responsibility |
|---|---|
| Board and test lead | Program the FPGA, load firmware, record serial output, maintain the hardware test runner and UART0 PASS/FAIL convention. |
| Driver author (one or two students) | Study the peripheral, choose or define its generic interface, implement the NEORV32 body, handle timeouts and error cases. |
| Integration and documentation | Connect drivers to board-level Ada code, maintain example programs, prepare PRs, write reproducible instructions and collect code-size results. |

**Rotate roles in Week 5.** By December, each student should have personally loaded and tested firmware on a board and contributed to driver implementation. Reviewing a driver does not replace writing one.

You do not need weekly presentation slides. Bring a runnable demonstration, a diff, and the exact problem you are working on.

## 5. What makes a driver complete?

For each assigned driver, we expect:

1. **Interface:** An existing generic crate is reused, or a reviewed generic interface is available in a separate GNAT Academic Program crate.
2. **Implementation:** A NEORV32-specific driver body exists in `neorv32_ghal`. Start with **polled I/O**: the code asks the hardware whether it is ready rather than relying on interrupts or DMA.
3. **Board integration:** Ada board/application code instantiates the interface and selects the appropriate device or pin. It should be usable on Mercury 2 and Nexys 4 where that peripheral is provided; hardware verification on at least one supported board is mandatory.
4. **Example:** One small example under an `examples/` directory in the application/test workspace. Keep examples separate from generic hardware-independent interfaces.
5. **Test:** One repeatable hardware test with a definite result, not merely a blinking light or a claim that the program did not crash.
6. **Evidence:** A captured UART0 serial log from the real board attached or linked to the PR, including board variant, bitstream revision, and firmware revision.
7. **README:** Explain what the driver does, what it does not do, wiring, supported modes, and how to run the example and test. **Put one command in each command code block.**

If an API promises to return failure for a timeout or unsupported configuration, test that behavior too. All loops waiting on an external device should have a defined exit or failure path, not hang forever.

### UART0 test result format

UART0 is our common test console. Every test prints one final result line:

```text
PASS spi
```

or:

```text
FAIL spi loopback_mismatch
```

The driver name is lowercase and stable, and the failure reason is a short machine-readable token. The serial capture script should save the entire session to a file. It should report success only if it sees the expected `PASS` for the selected test; a `FAIL`, timeout, unexpected reset, or missing result is a failed run. Ignore ordinary bootloader text when parsing the application's result.

For reproducibility, record the UART baud rate used by the **test firmware**. The stock bootloader uses 19200 8N1; your application can use another rate, but then your test script must match it.

## 6. Weekly plan

### Week 1 — October 19–23: get a real program onto the board

**Everyone:** Start with the appropriate board repository and its README. Clone with submodules, confirm the correct board variant, program the matching bitstream, open UART0, and verify that the bootloader reports hardware version `0x01130600` (NEORV32 v1.13.6).

Then build and run the provided minimal Ada **hello** and **blinky** applications. The current gateware repositories document board programming but do not themselves contain these complete Ada starter applications; if the project workspace has not supplied them, record that as a setup gap and make the minimal examples available before treating the exercise as complete. Do not invent a path or a build command that is not in the checkout.

Each student must independently perform the build/load/run procedure on their own Linux or Windows development machine, even if the board is shared. Write an issue for every README instruction that is missing, wrong, or depends on an unstated tool.

**At the meeting:** Each student shows a successful UART0 console session and a firmware run. Show the list of documentation fixes and identify who owns the updated gateware and starter applications.

### Week 2 — October 26–30: read the hardware before controlling it

**Everyone:** Read the NEORV32 **v1.13.6** datasheet chapter for one assigned peripheral. Inspect the corresponding generated Ada register package, and look at an existing driver (`NEORV32_GPIO` or `NEORV32_UART`) to see how low-level operations are written.

Submit a **one-page technical note**, not a general essay. It must answer:

- What does the peripheral do? Give one concrete use case.
- Which registers and fields are needed for its simplest useful operation?
- What starts that operation? How can software tell it has completed?
- Which reads or writes have side effects? How does failure or timeout appear?
- Which VHDL SoC generic enables it, and which physical pins or extra parts are needed?
- Which generic Ada interface will this driver implement?
- If it has an interrupt, which FIRQ source is involved? Is the Ada runtime ready to use it?

**At the meeting:** Walk through one concrete register transaction, show the relevant Ada package declarations, and verify that the needed gateware is published. No one starts writing arbitrary register assignments until this is understood.

### Week 3 — November 2–6: create the test harness and first driver skeleton

**Board/test lead:** Create a small test application under `tests/` (or an explicitly documented test application workspace) and a host script that opens UART0, captures serial output, recognizes PASS/FAIL, and returns a nonzero process exit status on failure. Exercise the harness with one deliberate PASS and one deliberate FAIL. Record a timeout case.

**Driver author:** Create Driver 1's Ada specification and body skeleton. Connect it to the existing generic crate, or get the new generic interface reviewed first. The empty body is a compilation milestone only; it must not silently report success for operations it does not implement.

**Integration/docs:** Make sure the example and board-level instantiation compile against the pinned `neorv32` crate. Record the selected bitstream and what `NEORV32_System` reports. Confirm any external equipment and wiring.

**At the meeting:** Show the captured serial log, the harness failing when it should, and a compiling driver skeleton. If gateware or a runtime interrupt test is missing, show the issue and the agreed fallback.

### Week 4 — November 9–13: Driver 1, working in polled mode

The first driver must perform its assigned basic function on the real board.

**Team A — events:** Extend the **existing UART0 driver** rather than rewriting its working polled implementation. Introduce a bounded RX ring buffer, test byte ordering and overflow behavior, and implement a polling-based way to fill it. Keep the public `Driver_Rx_Pop` behavior clear. Separately, attempt the standalone UART0 RX FIRQ test if the runtime is ready. Do not describe the ring buffer as interrupt-driven until an actual interrupt handler has been demonstrated.

**Team B — serial buses:** Implement SPI master transfers using the existing `spi_generic` contract. Connect MOSI to MISO on a defined header and verify that transmitted bytes are received unchanged. Test several byte patterns and at least one failure/timeout behavior. State the configuration (clock, mode, chip select) used.

**Team C — outputs and system:** Implement PWM output and demonstrate a brightness ramp on an appropriately wired LED, or measure changing duty cycle on a physical output if the LED wiring is unavailable. Test the boundary duty cycles, not just the middle values.

**At the meeting:** Run the example and show `PASS <driver>` from real hardware. Open the Driver 1 PR with its serial log and instructions. A compiling driver with no hardware evidence remains incomplete.

### Week 5 — November 16–20: merge, rotate, and start Driver 2

Review Driver 1's PR. Fix the issues that affect correctness or reproducibility, run the test again, and merge it when the evidence is complete.

**Rotate roles now.** The person who did the board flashing should do some driver work, and the earlier driver author should take a turn with hardware/integration.

Read Driver 2's register chapter and generic interface, make its first skeleton compile, and begin the simplest polled operation. Do this during Week 5; leaving all Driver 2 implementation to Thanksgiving week is not realistic.

**At the meeting:** Driver 1 merged or a short written list of remaining merge blockers. Driver 2 builds and its test conditions are defined.

### Week 6 — November 23–27: Driver 2, lighter Thanksgiving week

Keep this week small and practical. Complete the work already started on Driver 2 where the necessary hardware is ready. The target remains a running example, a real hardware PASS, and an open PR; if holiday availability prevents that, finish it **early in Week 7 instead of starting an optional third feature**.

**Team A — GPTMR:** Implement one-shot and periodic timer operation. Verify the timer's state and elapsed/tick behavior in polling mode first. Add a real handler only when the FIRQ runtime test works. The NEORV32 GPTMR supports both modes; its interrupt is not proof that the runtime actually services it.

**Team B — TWI / I2C master:** Use `i2c_generic` where it fits. Communicate with the assigned sensor or I2C device. A useful test reads a known register or identification value and checks it, rather than merely transmitting some bytes. Handle NACK and a stalled bus cleanly. TWI pins require proper open-drain wiring and pull-ups.

**Team C — NEOLED:** Drive the assigned WS2812-compatible LED. Test at least two clearly different colors plus off, and document the color ordering, clock configuration, and physical data connection. A visual effect alone is not a complete test; report a definite software status as well.

**At the meeting:** Early-week call or asynchronous review. Provide a PR and hardware log if ready; otherwise state exactly what remains, then prioritize this driver in Week 7.

### Week 7 — November 30 – December 4: optional extension, only after two drivers work

The first priority is to get Driver 1 and Driver 2 merged with passing hardware tests. **No new feature takes priority over that.**

If those are stable, take the team-specific extension below:

**Team A — interrupts and GPIO events:** Convert UART0 RX buffering to an actual interrupt-driven producer **only if** the standalone FIRQ runtime test has been merged and repeatedly passes. Test receiving bytes while the application is doing other work, and test overflow. Do not print debug messages from the interrupt handler. For GPIO pin-change interrupts, the board needs an XIRQ input path or other explicit FPGA edge-detection/routing; standard GPIO inputs alone do not create a pin-change interrupt. If this hardware is absent, implement and label a **polled edge-detection example** instead, or finish the runtime/FIRQ integration.

**Team B — SPI interrupt or ONEWIRE:** Try an SPI interrupt-driven variant only with a verified interrupt path. Otherwise implement a **polled ONEWIRE** driver if its peripheral is enabled and test wiring is available. If neither is ready, improve SPI and TWI error handling and regression tests rather than manufacturing a third deliverable without hardware.

**Team C — custom peripheral guidance and CI size report:** Write a short recipe for an Ada driver talking to a **custom XBUS memory-mapped peripheral**: address assignment, register map, generated/manual binding, generic API, test, and board integration. Explain briefly that **CFS is a different NEORV32 extension mechanism**, not another name for an XBUS peripheral. Do not implement a custom VHDL peripheral this semester. Add the example size report to CI or provide a reproducible script.

An interrupt or DMA-backed implementation is an extension, never a requirement that replaces the polled baseline. Calling a handler *tested* is appropriate after a repeatable hardware test; calling it *formally proved* is not justified unless you actually have a proof.

**At the meeting:** Show all completed hardware test logs and decide which optional work is genuinely ready to merge.

### Week 8 — December 7–11: freeze, demonstrate, and hand over

No new driver families.

- Merge or close every open PR. Leave no unreviewed feature branch described as finished.
- Keep the repository buildable, examples runnable, and test logs linked to their source/bitstream revisions.
- Put a size table in the README showing **`.text`, `.data`, and `.bss` for every example**. Use a RISC-V ELF size tool (for example, `riscv64-elf-size`) and report which ELF, board, compiler flags, and toolchain produced each result. Do not confuse `.bss` with executable file size.
- Prepare a **10-minute demonstration** that exercises the team's completed drivers from one Ada program on one board. A single integrated test is better than three unrelated demos. If a missing hardware dependency prevented integration, report that limitation explicitly rather than presenting a simulated PASS as a hardware PASS.
- Write a short January handoff: what is merged, how to recreate the setup, what remains unimplemented, and the next sensible tasks.

**Final meeting:** Run the combined program, show its UART0 PASS/FAIL output, briefly explain the three layers (generic interface, NEORV32 driver, board wiring), and present the size report and handoff.

## 7. Driver assignments at a glance

| Team | Driver 1 (Week 4) | Driver 2 (Weeks 5–6, finish early Week 7 if needed) | Week 7 extension if ready |
|---|---|---|---|
| **A — events** | UART0 RX ring buffer over existing polled driver; validate UART0 FIRQ separately | GPTMR periodic and one-shot; handler only with working FIRQ runtime | Interrupt-driven UART RX; GPIO/XIRQ input-event work only with proper gateware |
| **B — serial buses** | SPI master, physical MOSI–MISO loopback | TWI/I2C master, known sensor/register test | SPI interrupt variant or ONEWIRE polled if supported |
| **C — outputs and system** | PWM, physical output/ramp | NEOLED, WS2812-compatible LED | Custom XBUS driver recipe; CI size report |

## 8. Rules for the semester

**Keep the NEORV32 version pinned.** The register definitions and hardware must both be v1.13.6. Check the version at application startup. Do not silently switch to a newer upstream NEORV32 checkout.

**Use the hardware's actual clock.** The Mercury 2 and Nexys 4 clock frequencies differ. Calculate timings and baud rates from the value reported by the SoC.

**Read the register description before using field assignments.** Some hardware registers have read side effects. A read-modify-write operation can consume a FIFO element or clear status inadvertently.

**Check that a peripheral exists before accessing it.** A register declaration in Ada does not mean the FPGA bitstream includes that hardware.

**Give blocking operations a defined failure mode.** If a transfer never completes, return/report a timeout instead of hanging the entire test.

**Treat UART0 test output as evidence, not decoration.** A PASS must come from a performed check. Preserve the full log and the hardware/firmware revisions.

**Do not modify generated `src/svd/` sources.** Fix driver code or raise an issue if you believe a generated definition is inconsistent with the pinned SVD.

**Keep generic, MCU, and board concerns separate.** A reusable API should not contain Mercury 2 pin numbers. A NEORV32 driver should not know the model of the attached I2C sensor. The example/board setup is where that choice belongs.

**Report blockers early.** If you need a gateware change, a specific sensor, or an interrupt runtime fix, put the exact missing dependency in the team channel. Do not quietly spend a week working around it.

**Every Friday:** Post exactly three short lines in the team channel: `Done this week:`, `Blocked on:`, and `Next week:`. No slides.

## 9. Out of scope

Do not take on Ethernet, USB, SD-card file systems, complete protocol stacks above these drivers, a new Ada runtime, redesigning the FPGA platform, or changes to the generated SVD register packages. DMA and interrupt variants are optional and require their own tested hardware/runtime prerequisites. Custom XBUS/CFS work is a documented future direction, not an extra FPGA implementation assignment.

## 10. What success looks like in December

By the end of the semester, the team should be able to show **two completed polled drivers (or the agreed equivalent for Team A's existing UART foundation)**, each with a generic interface, NEORV32 implementation, board integration, example, and real hardware test.

The team must be able to explain the registers it used, how it determined completion, what happens on a timeout, and which parts depend on the FPGA configuration. The UART0 tests and the README should allow another student to reproduce the results. Every team member should have contributed real driver code and personally performed a hardware test.

If the hardware or interrupt runtime is not ready, say so precisely. A smaller set of reproducible, working drivers is preferable to three nominal drivers that were never exercised on the actual SoC.

## Reference material

- [NEORV32 Ada driver crate (`neorv32_ghal`)](https://github.com/GNAT-Academic-Program/neorv32_ghal)
- [Mercury 2 SoC and FPGA tools](https://github.com/GNAT-Academic-Program/neorv32_mercury2)
- [Nexys 4 / Nexys 4 DDR SoC and FPGA tools](https://github.com/GNAT-Academic-Program/neorv32_nexys4)
- [SPI generic Ada interface](https://github.com/GNAT-Academic-Program/spi_generic)
- [I2C generic Ada interface](https://github.com/GNAT-Academic-Program/i2c_generic)
- [USART generic Ada interface](https://github.com/GNAT-Academic-Program/usart_generic)
- [NEORV32 v1.13.6 source and documentation](https://github.com/stnolting/neorv32/tree/v1.13.6)

*This plan is based on inspection of the published repository descriptions, VHDL top-level configurations, and pinned NEORV32 documentation as of October 16, 2026. The new driver code and revised gateware have not been independently built or run as part of this review.*