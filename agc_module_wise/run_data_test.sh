#!/bin/bash

iverilog -g2012 -o agc_data_test \
    agc_timestamp.v \
    agc_pulse_detector.v \
    agc_alpha_detector.v \
    agc_gamma_detector.v \
    agc_event_formatter.v \
    agc_event_fifo.v \
    agc_system_bus.v \
    agc_top.v \
    tb_agc_data_driven.v

vvp agc_data_test