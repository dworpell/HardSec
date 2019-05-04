`timescale 1ns / 1ps

module ro(clock, puf_out);
	 //For simulation, you can add select1, select2, enable, and reset to the inputs.
	 //Do not forget to make them wires before implementation
	 
	 input clock;
	 output reg puf_out;

	 //The input signals from VIO
	 wire [3:0] select1, select2;
	 wire enable, reset;
	 
	 //Mux signals
    wire out1, out2, out3, out4, out5, out6, out7, out8, 
	 out9, out10, out11, out12, out13, out14, out15, out16, mux1_out, mux2_out;
	 wire [11:0] muxin1, muxin2;
	 //Counter outputs
	 wire [11:0] counter1_out, counter2_out, clockcounter_out;
	 wire [11:0] mathstuff;
	 wire [3:0] muxmux, muxmux2;
		wire [191:0] counter_outs;

	 
	 mux16_1 mux1 (counter_outs[11:0],counter_outs[23:12],counter_outs[35:24],counter_outs[47:36],counter_outs[59:48],counter_outs[71:60],counter_outs[83:72],counter_outs[95:84],counter_outs[107:96],counter_outs[119:108],counter_outs[131:120],counter_outs[143:132],counter_outs[155:144],counter_outs[167:156],counter_outs[179:168],counter_outs[191:180], muxmux, mux1_out);
	 mux16_1 mux2 (counter_outs[11:0],counter_outs[23:12],counter_outs[35:24],counter_outs[47:36],counter_outs[59:48],counter_outs[71:60],counter_outs[83:72],counter_outs[95:84],counter_outs[107:96],counter_outs[119:108],counter_outs[131:120],counter_outs[143:132],counter_outs[155:144],counter_outs[167:156],counter_outs[179:168],counter_outs[191:180], muxmux2, mux2_out);
	 //Mux the mux so that we do not need to re-synth between captures.
	 assign muxmux = (select1==select2) ? muxin1[3:0]:select1;
	 assign muxmux2 = (select1==select2) ? mathstuff[3:0]:select2;
	 //wire [11:0] clockCountOut, mux1CounterOut, mux2CounterOut;
	 wire enable1,enable2;
	 
	 //Artifacts that have remained here because the code works. 
	 assign enable1=clockcounter_out!=12'hfff;
	 assign enable2=clockcounter_out!=12'hfff;
	 
	 wire reset1;
	 wire resetmux2;
	 //Over-zealous reset
	 assign reset1=(clockcounter_out==12'h000 || reset) ? 1:0;
	 
	 wire enablemux1,enablemux2;
	 assign mathstuff = muxin1 + 1 +muxin2;
	 assign enablemux2= (clockcounter_out==12'hfff) ? 1:0;
	 assign enablemux1= (clockcounter_out==12'hfff && mathstuff[3:0]==4'hf ) ? 1:0;
	 assign resetmux2 = ((clockcounter_out==12'hfff && mathstuff==12'd15) || reset) ? 1:0;
	 counter12 muxincoconut  (muxin1, enablemux1, clock, reset);
	 counter12 mux2incoconut  (muxin2, enablemux2, clock, reset);
	 
	 //I really wanted to make sure everything was reset to its initial state before allowing the PUF to progress.
	 wire fenable, freset;
	 assign fenable = (enable && clockcounter_out>12'h002) ? 1:0;
	 assign freset  = (reset || clockcounter_out <= 12'h002) ? 1:0;
   wire [16:0] outs;
	 counter12 clock_counter (clockcounter_out, enable, clock, reset);
	 always @(posedge clock) begin
		puf_out=(mux1_out > mux2_out) ? 1:0;
	 end
   generate
    genvar i;
    for (i=0; i<16; i=i+1) begin: ro  
      counter12 ro_counter (counter_outs[(i*12)+11:(i*12)], enable1, outs[i], reset1); 
      ringoscillator ro (fenable, freset, outs[i]);
    end
   endgenerate 
	wire fakeclock;
	assign fakeclock = (clockcounter_out < 12'd2048) ? 1: 0;
	
//Instantiate your ring oscillators. Do not forget to add (* KEEP = "TRUE" *) before each instantiation
//Example: (* KEEP = "TRUE" *)   ro_hardmacro ro1(enable, reset, out1);



//Instantiate your muxes and counters


//Write the code for generating your PUF output



	//////////////////////////////////////////////////////////////
	//ICON, VIO, and ILA instantiations. No need to edit this part
	 wire [9:0] vio_op;
	 assign select2=vio_op[9:6];
	 assign select1=vio_op[5:2];
	 assign reset=vio_op[1];	 
	 assign enable=vio_op[0];
	 
	 wire [191:0] vio_ip;
	 //assign vio_ip[24:13]=counter2_out;
	 //assign vio_ip[12:1]=counter1_out;
	 //assign vio_ip[0]=puf_out;
	 assign vio_ip = counter_outs;
	 wire [229:0] ila_data;
	 assign ila_data[37:26]=clockcounter_out;
	 assign ila_data[25]=mux1_out;
	 assign ila_data[16:1] = outs;
	 assign ila_data[0]=puf_out;
	 assign ila_data[229:38] = counter_outs;
	 
	wire [35:0] cntbus, ilacntbus;
	ICON ICON0 (
    .CONTROL0(cntbus),
	 .CONTROL1(ilacntbus));	
	VIO VIO0 (
		 .CONTROL(cntbus),
		 .ASYNC_OUT(vio_op),
		 .ASYNC_IN(vio_ip));	 
	ILA ILA0 (
    .CONTROL(ilacntbus),
    .CLK(fakelock),
    .DATA(ila_data),
	 .TRIG0(clockcounter_out),
    .TRIG1(enable));
	 ////////////////////////////////////////////////////////////
endmodule
module mux16_1_12(
								 input in1,                
                         input in2,                
                         input in3,                
                         input in4,
								 input in5,                
                         input in6,                
                         input in7,                
                         input in8,
								 input in9,                
                         input in10,                
                         input in11,                
                         input in12,
								 input in13,                
                         input in14,                
                         input in15,                
                         input in16,								 
                         input [3:0] sel,               
                         output outfinal);             

//------------Internal Variables--------
reg  out;
assign outfinal=out;
//-------------Code Starts Here---------
always @(sel or in1 or in2 or in3 or in4 or in5 or in6 or in7 or in8 or in9 or in10 or in11 or in12 or in13 or in14 or in15 or in16)

 case(sel) 
    4'b0000 : out = in1;
    4'b0001 : out = in2;
    4'b0010 : out = in3;
	 4'b0011 : out = in4;
    4'b0100 : out = in5;
    4'b0101 : out = in6;
    4'b0110 : out = in7;
	 4'b0111 : out = in8;	
    4'b1000 : out = in9;
    4'b1001 : out = in10;
    4'b1010 : out = in11;
	 4'b1011 : out = in12;
    4'b1100 : out = in13;
    4'b1101 : out = in14;
    4'b1110 : out = in15;
	 4'b1111 : out = in16;	 
 endcase 
endmodule //End Of Module mux
module mux16_1(
								 input in1,                
                         input in2,                
                         input in3,                
                         input in4,
								 input in5,                
                         input in6,                
                         input in7,                
                         input in8,
								 input in9,                
                         input in10,                
                         input in11,                
                         input in12,
								 input in13,                
                         input in14,                
                         input in15,                
                         input in16,								 
                         input [3:0] sel,               
                         output outfinal);             

//------------Internal Variables--------
reg  out;
assign outfinal=out;
//-------------Code Starts Here---------
always @(sel or in1 or in2 or in3 or in4 or in5 or in6 or in7 or in8 or in9 or in10 or in11 or in12 or in13 or in14 or in15 or in16)

 case(sel) 
    4'b0000 : out = in1;
    4'b0001 : out = in2;
    4'b0010 : out = in3;
	 4'b0011 : out = in4;
    4'b0100 : out = in5;
    4'b0101 : out = in6;
    4'b0110 : out = in7;
	 4'b0111 : out = in8;	
    4'b1000 : out = in9;
    4'b1001 : out = in10;
    4'b1010 : out = in11;
	 4'b1011 : out = in12;
    4'b1100 : out = in13;
    4'b1101 : out = in14;
    4'b1110 : out = in15;
	 4'b1111 : out = in16;	 
 endcase 
endmodule //End Of Module mux
module counter12(
    output [11:0] count,
    input enable,
    input clk,
    input reset
);
reg [11:0] temp;
assign count=temp;
always @(posedge clk, posedge reset)
if (reset) begin
  temp <= 12'b0 ;
end else if (enable) begin
  temp <= temp + 1;
end
endmodule 
