from __future__ import annotations

import os
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb_tools.runner import get_runner


@cocotb.test()
async def incremental_fifo_checker_test(dut):
    """Test incremental FIFO checker end-to-end."""

    dut.rst.value = 1
    dut.en.value = 0

    clock = Clock(dut.clk, 2, unit="us")
    cocotb.start_soon(clock.start(start_high=False))

    # Reset
    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.rst.value = 0
    dut.en.value = 1

    # Run generator + FIFO + checker
    for i in range(80):
        await RisingEdge(dut.clk)

        # out should remain high once valid data starts passing
        # ignore first few cycles because FIFO/checker pipeline needs time
        if i > 10:
            assert dut.out.value == 1, f"Checker failed at cycle {i}"

    # Disable generator and verify design does not falsely fail
    dut.en.value = 0

    for i in range(20):
        await RisingEdge(dut.clk)

    dut.en.value = 1

    for i in range(60):
        await RisingEdge(dut.clk)

        if i > 20:
            assert dut.out.value == 1, f"Checker failed after enable resume at cycle {i}"


def test_incremental_fifo_checker_hidden_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    sources = [
        proj_path / "sources/fifo_top.sv",
        proj_path / "sources/generator.sv",
        proj_path / "sources/pattern_checker.sv",
        proj_path / "sources/fifo_sync.sv",
    ]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="fifo_top",
        always=True,
    )

    runner.test(
        hdl_toplevel="fifo_top",
        test_module="test_incremental_fifo_checker_hidden",
    )