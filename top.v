`timescale 1ns / 1ps
`default_nettype none
module ro(clock, puf_out);
	 //For simulation, you can add select1, select2, enable, and reset to the inputs.
	 //Do not forget to make them wires before implementation
	 
	 input clock;
	 output wire puf_out;

	 //The input signals from VIO
	 wire [3:0] select1, select2;
	 wire enable, reset;
	 
	 //Mux signals
	 wire [11:0] mux1_out, mux2_out;
	 //wire [11:0] muxin1, muxin2;
	 //Counter outputs
	 wire [11:0] clockcounter_out;
	 wire [3:0] muxmux, muxmux2;
	 wire start, done;

	 	//wire quick_enable;
	wire [191:0] counter_outs;
	wire [3:0] sel1, sel2;

	 
	 mux16_1_12 mux1 (counter_outs[11:0],counter_outs[23:12],counter_outs[35:24],counter_outs[47:36],counter_outs[59:48],counter_outs[71:60],counter_outs[83:72],counter_outs[95:84],counter_outs[107:96],counter_outs[119:108],counter_outs[131:120],counter_outs[143:132],counter_outs[155:144],counter_outs[167:156],counter_outs[179:168],counter_outs[191:180], muxmux, mux1_out);
	 mux16_1_12 mux2 (counter_outs[11:0],counter_outs[23:12],counter_outs[35:24],counter_outs[47:36],counter_outs[59:48],counter_outs[71:60],counter_outs[83:72],counter_outs[95:84],counter_outs[107:96],counter_outs[119:108],counter_outs[131:120],counter_outs[143:132],counter_outs[155:144],counter_outs[167:156],counter_outs[179:168],counter_outs[191:180], muxmux2, mux2_out);
	 //Mux the mux so that we do not need to re-synth between captures. Yeet
	 assign muxmux  = (~done) ? sel1:select1;
	 assign muxmux2 = (~done) ? sel2:select2;
	 //wire [11:0] clockCountOut, mux1CounterOut, mux2CounterOut;
	 
	 wire enable1;
	 
	 //Artifacts that have remained here because the code works. 
	 
	 assign enable1=clockcounter_out!=12'hfff;
	 
	 wire reset1;
	 //Over-zealous reset
	 assign reset1=(clockcounter_out==12'h002 || reset) ? 1:0;
	 
	 
	 //wire temp1;
	 //wire[3:0] temp2,temp3;
	 wire [3:0] rng1, rng2;
	 wire [255:0] crp;
	 wire puf_request;
	 wire [11:0] oc;
	 PUF_FSM fsm(clock, reset,puf_out,clockcounter_out,mux1_out, mux2_out, enable,puf_request,done,oc,crp,sel1,sel2,rng1,rng2);
	 
	 //I really wanted to make sure everything was reset to its initial state before allowing the PUF to progress.
	 wire fenable, freset;
	 assign fenable = (enable && clockcounter_out>12'h002)||done ? 1:0;
	 assign freset  = (reset || ((clockcounter_out <= 12'h002)&&~done)) ? 1:0;
   wire [16:0] outs;
	 counter12 clock_counter (clockcounter_out, enable, clock, reset,1'b0);
	 //possible meta-stability fixed with double buffer
	 assign puf_out =(mux1_out > mux2_out) ? 1:0;
	 /*always @(posedge clock) begin
		//temppufout<=(mux1_out > mux2_out) ? 1:0;
		puf_out =(mux1_out > mux2_out) ? 1:0;
	 end*/

	 generate
		 genvar i;
		 for (i=0; i<16; i=i+1) begin: ro  
			counter12 ro_counter (counter_outs[(i*12)+11:(i*12)], enable1, outs[i], reset1, 1'b0); 
			ringoscillator ro (fenable, freset, outs[i]);
			//counter20 ro_counter_counter (total_counts[i],counter_outs[(i*12)+11:(i*12)], quick_enable, clock, reset_total);
		 end
   endgenerate 
	wire fakeclock;
	assign fakeclock = (clockcounter_out < 12'd2048) ? 1: 0;
	wire [127:0] rngstring;
	wire fakerclock;
	RNG rng (rngstring,fakerclock, outs,rng1,rng2, clock, reset);
	
	//assign quick_enable=(clockcounter_out==12'hffE) ? 1:0;//fakeclock & ~previous_fake;
	
//Instantiate your ring oscillators. Do not forget to add (* KEEP = "TRUE" *) before each instantiation
//Example: (* KEEP = "TRUE" *)   ro_hardmacro ro1(enable, reset, out1);



//Instantiate your muxes and counters


//Write the code for generating your PUF output



	//////////////////////////////////////////////////////////////
	//ICON, VIO, and ILA instantiations. No need to edit this part
	 wire [11:0] vio_op;
	 assign puf_request=vio_op[10];
	 assign select2=vio_op[9:6];
	 assign select1=vio_op[5:2];
	 assign reset=vio_op[1];	 
	 assign enable=vio_op[0];
	 
	 wire [191:0] vio_ip;
	 //assign vio_ip[24:13]=counter2_out;
	 //assign vio_ip[12:1]=counter1_out;
	 //assign vio_ip[0]=puf_out;
	 assign vio_ip = counter_outs;
	 wire [413:0] ila_data;
	 assign ila_data[7:4]=sel1[3:0];
	 assign ila_data[11:8]=rng1;
	 assign ila_data[15:12]=rng2;
	 assign ila_data[24] = puf_out;
	 assign ila_data[25] = outs[rng1]^outs[rng2];
	 assign ila_data[37:26] = oc;
	 //assign ila_data[35:24]=crpcount;
	 assign ila_data[3:0] = sel2[3:0];
	 //assign ila_data[229:38] = counter_outs;
	 assign ila_data[157:38] = rngstring[119:0];
	 assign ila_data[413:158] = crp;
	 /*generate
	 genvar il;
		 for (il=0; il<16; il=il+1) begin: r
			assign ila_data[350+(il*16)+:16] = pufgood[il];
		 end
	 endgenerate*/
	 //assign ila_data[249:230] = total_counts[0];
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
    .CLK(fakeclock),
    .DATA(ila_data),
	 .TRIG0(clockcounter_out),
    .TRIG1(enable),
	 .TRIG2(sel1));
	 ////////////////////////////////////////////////////////////
endmodule
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

module PUF_FSM(input clock, 
					input reset,
					input puf_out,
					input [11:0] clockcounter_out,
					input [11:0] mux1_out,
					input [11:0] mux2_out,
					input start,
					input puf_request,
					output reg done,
					//output [255:0] pufgood,
					output [11:0] oc,
					output [255:0] crp,
					output [3:0] sel1,
					output [3:0] sel2,
					output reg [3:0] rng1,
					output reg [3:0] rng2);
					
	wire [11:0] muxin1, muxin2, mathstuff, CRP_count,CRP_index,onescount;
	//Artifacts that have remained here because the code works. 
	reg clearmux2, clearmux1;
	reg clearcrpcountmux,clearindexmux,clearonescount,onescountenable;
	reg enablemux1,enablemux2;
	reg [3:0] rng1t,rng2t;
	reg setrngvals;
	reg [1:0] currentState;
	reg [1:0] nextState;
	wire CRP_DONE;
	reg indexenable;
	reg [255:0] pufgoodtemp, pufgoodmask,crptemp,crpmask;
	reg resetcrp;
	//assign pufgood=pufgoodtemp;
	assign CRP_DONE=(clockcounter_out==12'hfff) ? 1:0;
	assign crp=crptemp;//crptemp;
	reg sel2mux;
	always @(posedge clock, posedge reset) begin
		if (reset) begin
			currentState<=2'd0;
			rng1<=4'd0;
			rng2<=4'd1;
			pufgoodtemp<=256'd0;
		end
		else begin
			if (setrngvals) begin
				rng1<=rng1t;
				rng2<=rng2t;
				crptemp<=256'd0;
			end
			if (resetcrp) begin
				crptemp<=256'd0;
			end
			else begin
				crptemp<=crptemp|crpmask;
			end
			pufgoodtemp<=pufgoodtemp|pufgoodmask;
			currentState<=nextState;
		end
	end
	reg [11:0] min_diff;
	reg [11:0] diff_to_add;
	reg [11:0] currentdiff;
	reg [11:0] prev_diff;
	reg resetdiff;
	reg updatediff;
	reg updatemindiff;
	reg diffneg;
		assign oc= currentdiff;
	always @(posedge clock, posedge reset) begin
			if(reset) begin
				min_diff<=12'h000;
				currentdiff<=12'd0;
				prev_diff<=12'd0;
			end
			else begin
				if (resetdiff) begin
					currentdiff<=12'd0;
					prev_diff<=12'd0;
				end
				else if (updatediff) begin
					if(CRP_count!=0)
						currentdiff<=currentdiff+(diff_to_add-prev_diff);
					prev_diff<=diff_to_add;
				end
				if (updatemindiff) begin
					if (diffneg)
						min_diff<=~currentdiff;
					else
						min_diff<=currentdiff;
				end
			end
	end
	

	always @(currentState or start or CRP_DONE or mathstuff or puf_out or onescount or CRP_count or CRP_index or muxin1 or mux1_out or mux2_out or muxin2 or puf_request or pufgoodtemp or currentdiff or min_diff) begin
		clearcrpcountmux=1'b0;
		enablemux1=1'b0;
		done=1'b0;
		enablemux2=1'b0;
		indexenable=1'b0;
		clearonescount=1'b0;
		clearindexmux=1'b0;
		clearmux2=1'b0;
		clearmux1=1'b0;
		setrngvals=1'b0;
		rng1t=4'd0;
		rng2t=4'd0;
		sel2mux=1'b0;
		crpmask=256'd0;
		pufgoodmask=256'd0;
		resetcrp=1'b0;
		onescountenable=1'b0;
		updatediff=1'b0;
		resetdiff=1'b0;
		updatemindiff=1'b0;
		diffneg=1'b0;
		diff_to_add=12'd0;
		case(currentState)
			2'd0: begin
				nextState=2'd0;
				clearcrpcountmux=1'b1;
				clearindexmux=1'b1;
				clearmux1=1'b1;
				clearmux2=1'b1;
				resetdiff=1'b1;
				if(start) begin
					nextState=2'd1;
				end
			end
			
			2'd1: begin
				nextState=2'd1;
				if (CRP_DONE) begin
					if (CRP_count==12'd50 || (muxin1[3:0]==muxin2[3:0])) begin
						if (muxin2[3:0]==4'hf) begin
							enablemux1=1'b1;
							clearmux2=1'b1;
							if (muxin1[3:0]==4'hF)
								clearmux1=1'b1;
						end
						//increment muxin2
						enablemux2=1'b1;
						//clear CRP_count
						clearcrpcountmux=1'b1;
						//increment index location
						indexenable=1'b1;
						//clear number of ones counted
						clearonescount=1'b1;
						resetdiff=1'b1;
						if ((onescount>12'd45 || onescount<12'd5) && muxin2[3:0]!=muxin1[3:0]) begin
							pufgoodmask[CRP_index] = 1'b1;
						end
						if (muxin1[3:0] != muxin2[3:0]) begin
							if ((mux1_out>mux2_out && mux1_out-mux2_out<=2) ||(mux2_out>mux1_out && mux2_out-mux1_out<=2))begin 
								if (currentdiff[11] && ~currentdiff>=min_diff) begin
									setrngvals=1'b1;
									rng2t=muxin1[3:0];
									rng1t=mathstuff[3:0];
									updatemindiff=1'b1;
									diffneg=1'b1;
								end
								else if (~currentdiff[11] && currentdiff>=min_diff) begin
									setrngvals=1'b1;
									rng2t=muxin1[3:0];
									rng1t=mathstuff[3:0];
									updatemindiff=1'b1;
								end
							end
						end
						/*else if (mux2_out-mux1_out>=3 &&mux2_out-mux1_out<=6) begin
							setrngvals=1'b1;
							rng1t=muxin1[3:0];
							rng2t=mathstuff[3:0];
						end*/
					end
					//at the end of every CRP run, increment ones count if puf_out is one
					if (puf_out)
						onescountenable=1'b1;
					diff_to_add=mux1_out-mux2_out;
					updatediff=1'b1;
				end
				if (CRP_index>=12'd256) begin
					nextState=2'd2;
					clearindexmux=1'b0;
					clearmux1=1'b1;
					clearmux2=1'b1;
					clearonescount=1'b1;
					clearcrpcountmux=1'b1;
				end
			end
			
			2'd2: begin
				nextState=2'd2;
				done=1'b1;
				if (puf_request) begin
					clearcrpcountmux=1'b1;
					clearonescount=1'b1;
					clearindexmux=1'b1;
					clearmux2=1'b1;
					clearmux1=1'b1;
					nextState=2'd3;
					resetcrp=1'b1;
				end
			end
			//
			2'd3: begin
				nextState=2'd3;
				sel2mux=1'b1;
				if (CRP_DONE) begin
					if (CRP_count==12'd5 || (muxin1[3:0]==muxin2[3:0])) begin
						if (muxin2[3:0]==4'hf) begin
							enablemux1=1'b1;
							clearmux2=1'b1;
							if (muxin1[3:0]==4'hF)
								clearmux1=1'b1;
						end
						//increment muxin2
						enablemux2=1'b1;
						//clear CRP_count
						clearcrpcountmux=1'b1;
						//increment index location
						indexenable=1'b1;
						//clear number of ones counted
						clearonescount=1'b1;
						if (~pufgoodtemp[CRP_index]) begin
							crpmask[CRP_index]=1'b0;
						end
						else if (onescount>=12'd3) begin
							crpmask[CRP_index]=1'b1;
						end
						else begin
							crpmask[CRP_index]=1'b0;
						end
					end
					//at the end of every CRP run, increment ones count if puf_out is one
					if (puf_out)
						onescountenable=1'b1;
				end
				if (CRP_index>=12'd256) begin
					nextState=2'd2;
					clearindexmux=1'b1;
					clearmux1=1'b1;
					clearmux2=1'b1;
					clearonescount=1'b1;
					clearcrpcountmux=1'b1;
				end
			end
			
		endcase
	end

	
	assign mathstuff = muxin2;//muxin1 + 1 +muxin2;
	
	counter12 muxincoconut  (muxin1, enablemux1, clock, reset, clearmux1);
	counter12 mux2incoconut (muxin2, enablemux2, clock, reset, clearmux2);
	
	assign sel1=muxin1[3:0];
	assign sel2=(sel2mux) ? mathstuff[3:0]:muxin2;
	
	
	counter12 onecounter  	(onescount, CRP_DONE & puf_out, clock, reset, clearonescount);
	counter12 CRP_Counter  	(CRP_count, CRP_DONE, clock, reset, clearcrpcountmux);
	counter12 CRP_index_count (CRP_index, indexenable, clock, reset, clearindexmux);
	
	 
endmodule
module counter7(
	output [6:0] count,
    input enable,
    input clk,
    input reset, input clear);
reg [6:0] temp;
assign count=temp;
always @(posedge clk, posedge reset)
if (reset) begin
  temp <= 7'd0 ;
end else if (clear) begin
	temp<=7'd0;
end else if (enable) begin
  temp <= temp + 1;
end
endmodule

module mux16_1_12(
								 input [11:0] in1,                
                         input [11:0]in2,                
                         input [11:0]in3,                
                         input [11:0]in4,
								 input [11:0]in5,                
                         input [11:0]in6,                
                         input [11:0]in7,                
                         input [11:0]in8,
								 input [11:0]in9,                
                         input [11:0]in10,                
                         input [11:0]in11,                
                         input [11:0]in12,
								 input [11:0]in13,                
                         input [11:0]in14,                
                         input [11:0]in15,                
                         input [11:0]in16,								 
                         input [3:0] sel,               
                         output [11:0]outfinal);             

//------------Internal Variables--------
reg [11:0] out;
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
    input reset, input clear
);
reg [11:0] temp;
assign count=temp;
always @(posedge clk, posedge reset)
if (reset) begin
  temp <= 12'b0 ;
end else if (clear) begin
	temp<=12'd0;
end else if (enable) begin
  temp <= temp + 1;
end
endmodule

module counter20(
    output [19:0] count,
	 input [11:0] D,
    input enable,
    input clk,
    input reset
);
reg [19:0] temp;
assign count=temp;
always @(posedge clk, posedge reset)
if (reset) begin
  temp <= 20'b0 ;
end else if (enable) begin
  temp <= temp + {8'd0, D};
end
endmodule 

module RNG(
    output [127:0] bits,
	 output xorouto,
    input [16:0] outs,
	 input [3:0] rng1,
	 input [3:0] rng2,
    input clk,
    input reset
);
//terrible RNG implementation
	wire fakerclock;
	wire [11:0] fakecounter_out;
	wire [127:0] rngdata1;
	assign bits = rngdata1;
	wire xorout;
	assign xorouto=fakerclock;

	assign xorout=outs[0]^outs[1]^outs[2]^outs[3]^outs[4]^outs[5]^outs[6]^outs[7]^outs[8]^outs[9]^outs[10]^outs[11]^outs[12]^outs[13]^outs[14]^outs[15];
	counter12 ro_counter (fakecounter_out, 1'b1, xorout, 0,0); 
	assign fakerclock = (fakecounter_out < 12'd2048) ? 1: 0;

	rng_data data1 (rngdata1, outs[rng2]^outs[rng1], fakerclock, reset);
endmodule

module rng_data(
    output [127:0] bits,
    input in,
    input clk,
    input reset
);
reg [127:0] temp;
assign bits=temp;
always @(posedge clk, posedge reset)
if (reset) begin
  temp <= 128'b0 ;
end else if (in) begin
	temp <= {temp[126:0],1'b1};
end else begin
  temp <= {temp[126:0],1'b0};
end
endmodule 