///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019 Xilinx, Inc.
// All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor     : Xilinx
// \   \   \/     Version    : 14.7
//  \   \         Application: Xilinx CORE Generator
//  /   /         Filename   : VIO.v
// /___/   /\     Timestamp  : Fri May 03 19:46:25 Eastern Daylight Time 2019
// \   \  /  \
//  \___\/\___\
//
// Design Name: Verilog Synthesis Wrapper
///////////////////////////////////////////////////////////////////////////////
// This wrapper is used to integrate with Project Navigator and PlanAhead

`timescale 1ns/1ps

module VIO(
    CONTROL,
    ASYNC_IN,
    ASYNC_OUT) /* synthesis syn_black_box syn_noprune=1 */;


inout [35 : 0] CONTROL;
input [191 : 0] ASYNC_IN;
output [9 : 0] ASYNC_OUT;

endmodule
