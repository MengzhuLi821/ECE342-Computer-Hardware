module wallace_mult (
  input [7:0] x,
  input [7:0] y,
  output [15:0] out,
  output [15:0] pp [4]
);

// These signals are created to help you map the wires you need with the diagram provided in the lab document.

wire [15:0] s_lev01; //the first "save" output of level0's CSA array
wire [15:0] c_lev01; //the first "carry" output of level0's CSA array
wire [15:0] s_lev02; //the second "save" output of level0's CSA array
wire [15:0] c_lev02;
wire [15:0] s_lev11;
wire [15:0] c_lev11;
wire [15:0] s_lev12; //the second "save" output of level1's CSA array
wire [15:0] c_lev12;
wire [15:0] s_lev21;
wire [15:0] c_lev21;
wire [15:0] s_lev31;
wire [15:0] c_lev31;

// TODO: complete the hardware design for instantiating the CSA blocks per level.


logic [15:0] i0,i1,i2,i3,i4,i5,i6,i7;
logic rca_cout;

genvar n;
generate 
	for(n = 0; n < 8; n++)begin: multiply
		//i0
		assign i0[n] = y[0] & x[n];
		//i1
		assign i1[n+1] = y[1] & x[n];
		//i2
		assign i2[n+2] = y[2] & x[n];
		//i3
		assign i3[n+3] = y[3] & x[n];
		//i4
		assign i4[n+4] = y[4] & x[n];
		//i5
		assign i5[n+5] = y[5] & x[n];
		//i6	
		assign i6[n+6] = y[6] & x[n];
		//i7
		assign i7[n+7] = y[7] & x[n];
	end
endgenerate

///using zero for vacancy

//i0
assign i0[15:8] = '0;
//i1 
assign i1[0] = '0;
assign i1[15:9] = '0;
//i2
assign i2[1:0] = '0;
assign i2[15:10] = '0;
//i3
assign i3[2:0] = '0;
assign i3[15:11] = '0;
//i4
assign i4[3:0] = '0;
assign i4[15:12] = '0;
//i5
assign i5[4:0] = '0;
assign i5[15:13] = '0;
//i6
assign i6[5:0] = '0;
assign i6[15:14] = '0;
//i7
assign i7[6:0] = '0;
assign i7[15] = '0;

		
//level 0
	csa CSA1(
		.op1(i0),
		.op2(i1),
		.op3(i2),
		.S(s_lev01),
		.C(c_lev01)
	);
		
	csa CSA2(
		.op1(i3),
		.op2(i4),
		.op3(i5),
		.S(s_lev02),
		.C(c_lev02)
	);

//level 1
	csa CSA3(
		.op1(s_lev01),
		.op2(c_lev01 << 1),
		.op3(s_lev02),
		.S(s_lev11),
		.C(c_lev11)
	);
	
	csa CSA4(
		.op1(c_lev02 << 1),
		.op2(i6),
		.op3(i7),
		.S(s_lev12),
		.C(c_lev12)
	);


//level 2, the save and carry output of level 2 will be pp[2] and pp[3]
  
  assign pp[0] = s_lev21;
  assign pp[1] = c_lev21;
  
  
	csa CSA5(
		.op1(c_lev11 << 1),
		.op2(s_lev11),
		.op3(s_lev12),
		.S(s_lev21),
		.C(c_lev21)
	);
  

//level 3, the save and carry output of level 3 will be pp[2] and pp[3]
  
  assign pp[2] = s_lev31;
  assign pp[3] = c_lev31;
  
  csa CSA6(
		.op1(s_lev21),
		.op2(c_lev21 << 1),
		.op3(c_lev12 << 1),
		.S(s_lev31),
		.C(c_lev31)
	);
  

// Ripple carry adder to calculate the final output.


	rca RCA(
		 .op1(s_lev31),
		 .op2(c_lev31 << 1),
		 .cin(1'b0),
		 .sum(out),
		 .cout(rca_cout)
	);



endmodule





// These modules are provided for you to use in your designs.
// They also serve as examples of parameterized module instantiation.
module rca #(width=16) (
    input  [width-1:0] op1,
    input  [width-1:0] op2,
    input  cin,
    output [width-1:0] sum,
    output cout
);

wire [width:0] temp;
assign temp[0] = cin;
assign cout = temp[width];

genvar i;
for( i=0; i<width; i=i+1) begin
    full_adder u_full_adder(
        .a      (   op1[i]     ),
        .b      (   op2[i]     ),
        .cin    (   temp[i]    ),
        .cout   (   temp[i+1]  ),
        .s      (   sum[i]     )
    );
end

endmodule


module full_adder(
    input a,
    input b,
    input cin,
    output cout,
    output s
);

assign s = a ^ b ^ cin;
assign cout = a & b | (cin & (a ^ b));

endmodule

module csa #(width=16) (
	input [width-1:0] op1,
	input [width-1:0] op2,
	input [width-1:0] op3,
	output [width-1:0] S,
	output [width-1:0] C
);

genvar i;
generate
	for(i=0; i<width; i++) begin
		full_adder u_full_adder(
			.a      (   op1[i]    ),
			.b      (   op2[i]    ),
			.cin    (   op3[i]    ),
			.cout   (   C[i]	  ),
			.s      (   S[i]      )
		);
	end
endgenerate

endmodule

