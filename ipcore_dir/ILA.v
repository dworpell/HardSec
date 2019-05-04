///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019 Xilinx, Inc.
// All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor     : Xilinx
// \   \   \/     Version    : 14.7
//  \   \         Application: Xilinx CORE Generator
//  /   /         Filename   : ILA.v
// /___/   /\     Timestamp  : Fri May 03 20:01:28 Eastern Daylight Time 2019
// \   \  /  \
//  \___\/\___\
//
// Design Name: Verilog Synthesis Wrapper
///////////////////////////////////////////////////////////////////////////////
// This wrapper is used to integrate with Project Navigator and PlanAhead

`timescale 1ns/1ps

module ILA(
    CONTROL,
    CLK,
    DATA,
    TRIG0,
    TRIG1) /* synthesis syn_black_box syn_noprune=1 */;


inout [35 : 0] CONTROL;
input CLK;
input [229 : 0] DATA;
input [11 : 0] TRIG0;
input [11 : 0] TRIG1;

endmodule
