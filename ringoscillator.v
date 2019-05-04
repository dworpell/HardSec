`timescale 1ns / 1ps

//Comment out the line below while implementing your design with hard macro
//(*KEEP_HIERARCHY="TRUE"*)

module ringoscillator(enable, reset, dffout);
    input enable, reset;
    output dffout;
	 
   //Comment out the line below while implementing your design with hard macro
	//(* S = "TRUE" *)
	
	//Write the code for your ring oscillator
	//Comment it out after you create the hard macro
	/*wire in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,pufOut;
	reg dffout;
	and a1 (in1, enable, pufOut);
	not inv1 (in2, in1);
	not inv2 (in3, in2);
	not inv3 (in4, in3);
	not inv4 (in5, in4);
	not inv5 (in6, in5);
	not inv6 (in7, in6);
	not inv7 (in8, in7);
	not inv8 (in9, in8);
	not inv9 (in10, in9);
	not inv10 (in11, in10);
	not inv11 (in12, in11);
	not inv12 (in13, in12);
	not inv13 (pufOut, in13);*/
	/*assign in2 = ~(enable & pufOut);
	assign in3 = ~in2;
	assign in4 = ~in3;
	assign in5 = ~in4;
	assign in6 = ~in5;
	assign in7 = ~in6;
	assign in8 = ~in7;
	assign in9 = ~in8;
	assign in10 = ~in9;
	assign in11 = ~in10;
	assign pufOut = ~in11;*/
	/*always @(posedge pufOut, posedge reset) begin
		if (reset)
			dffout<=0;
		else
			dffout<=~dffout;
	end*/
	/////////////////////////////////////////
endmodule
