/*******************************************************/
/********************Multiplier module********************/
/*****************************************************/
// add additional modules as needs, such as full adder, and others

// multiplier module
module mult
(
	input [7:0] x,
	input [7:0] y,
	output [15:0] out,   // Result of the multiplication
	output [15:0] pp [9] // for automarker to check partial products of a multiplication 
);
	// Declare a 9-high, 16-deep array of signals holding sums of the partial products.
	// They represent the _input_ partial sums for that row, coming from above.
	// The input for the "ninth row" is actually the final multiplier output.
	// The first row is tied to 0.
	assign pp[0] = '0;
	assign pp[1] = '0;
	// Make another array to hold the carry signals
	logic [16:0] cin[9];
	assign cin[0] = '0;
	
	// Cin signals for the final (fast adder) row
	logic [16:8] cin_final;
	assign cin_final[8] = '0;
	
	// TODO: complete the following digital logic design of a carry save multiplier (unsigned)
	// Note: generate_hw tutorial can help you describe duplicated modules efficiently
	
	// Note: partial product of each row is the result coming out from a full adder at the end of that row
	
	// Note: a "Fast adder" operates on columns 8 through 15 of final row.
	
	
	logic [8:0] [15:0] FA_sum;
	logic [8:0] [15:0] FA_cin;
	logic [8:0] [15:0] FA_cout;
	logic [8:0] [15:0] FA_a;
   logic [8:0] [15:0] FA_b;
	logic	[15:0] osum;

	//row=2,col from 1 to 8
	
	assign pp[2][0] = x[0] & y[0];
	assign pp[2][15:9] = '0;

	genvar i;
	generate
		for(i = 1; i < 9; i++) begin : add_row2
		
			//special cases for row 2
			if(i == 1)begin //col = 1,b = 0
				assign pp[2][i] = x[i] & y[0];
				assign FA_a[2][i] = pp[2][i];
				assign FA_b[2][i] = 1'b0;
				assign FA_cin[2][i] = x[i-1] & y[1];
				//assign FA_cout[2][i] = FA_cin[3][i+1];
				//assign FA_sum[2][i] = pp[3][i];
			end
			else if(i == 8)begin //col = 8, a = x[7] & y[1], cin = 0
				assign pp[2][i] = x[i-1] & y[1];
				assign FA_a[2][i] = pp[2][i];
				assign FA_cin[2][i] = 1'b0;
				assign FA_b[2][i] = x[i-2] & y[2];
				//assign FA_cout[2][i] = FA_cin[3][i+1];
				//assign FA_sum[2][i] = pp[3][i];
			end
			else begin
				//general cases for row 2
				assign pp[2][i] = x[i] & y[0];
				assign FA_a[2][i] = pp[2][i];
				assign FA_b[2][i] = x[i-2] & y[2];
				assign FA_cin[2][i] = x[i-1] & y[1];
				//assign FA_cout[2][i] = FA_cin[3][i+1];
				//assign FA_sum[2][i] = pp[3][i];
			end
		
		full_adder FA(
				  .a(FA_a[2][i]),
				  .b(FA_b[2][i]),
				  .cin(FA_cin[2][i]),
				  .cout(FA_cout[2][i]),
				  .s(pp[3][i]) // i 1~8
				);
		
		end
	endgenerate	
	
 
 
	//row from 3 to 7, col from row-1 to row+6
	genvar row, col;
	generate
		for(row = 3; row < 8; row++) begin : add_row3_to_7
			assign pp[row][row-3:0] = pp[row-1][row-3:0];
			assign pp[row][15:row+7] = '0;
			for(col = row-1; col < row+7; col++) begin : add_col2_to_13
				// row3 col 2~9
				//special cases for row 3 to 7
				if(col == row-1)begin
					//assign pp[row][col] = FA_sum[row-1][col];
					assign FA_a[row][col] = pp[row][col];
					assign FA_b[row][col] = 1'b0;
					assign FA_cin[row][col] = FA_cout[row-1][col-1];
				end
				else if(col == row+6)begin 
					assign pp[row][col] = x[7] & y[row-1];
					assign FA_a[row][col] = pp[row][col];
					assign FA_b[row][col] = x[col-row] & y[row];
					assign FA_cin[row][col] = FA_cout[row-1][col-1];
				end
				else begin
					//general cases for row 3 to 7
					//assign pp[row][col] = FA_sum[row-1][col];
					assign FA_a[row][col] = pp[row][col];
					assign FA_b[row][col] = x[col-row] & y[row];
					assign FA_cin[row][col] = FA_cout[row-1][col-1];
					//assign FA_cout[row][col] = FA_cin[row+1][col+1];
					//assign FA_sum[row][col] = pp[row+1][col];
				end
				
				full_adder FA(
				  .a(FA_a[row][col]),
				  .b(FA_b[row][col]),
				  .cin(FA_cin[row][col]),
				  //.cout(FA_cout[row][col]),
				  .cout(FA_cout[row][col]),
				  //.s(FA_sum[row][col])
				  .s(pp[row+1][col])
				);
			end
			
		end
		
		
		
	endgenerate
	
	genvar j;
	//for bottom row,row=8,col from 7 to 14
	generate
	
		for(j = 7; j < 15; j++) begin : add_col7_to_14
			
			//special cases for row 3 to 7
			if(j == 7)begin
				//assign pp[8][j] = FA_sum[7][j];
				assign FA_a[8][j] = pp[8][j];
				assign FA_b[8][j] = FA_cout[7][6];
				assign FA_cin[8][j] = '0;
				//assign FA_cout[8][j] = FA_cin[8][j+1];
				//assign FA_sum[8][j] = pp[8][j];
			end
			else if(j == 14)begin 
				assign pp[8][j] = x[7] & y[7];
				assign FA_a[8][j] = pp[8][j];
				assign FA_b[8][j] = FA_cout[7][13];
				//assign FA_cin[8][j] = FA_cout[7][j-1];
				//assign FA_cout[8][j] = FA_cin[8][j+1];
				assign FA_sum[8][j] = pp[8][j];
			end
			else begin		
				//general cases for row 3 to 7				
				
				//assign pp[8][j] = FA_sum[7][j];
				assign FA_a[8][j] = pp[8][j];
				assign FA_b[8][j] = FA_cout[7][j-1];
				//assign FA_cin[8][j] = FA_cout[7][j-1];
				//assign FA_cout[8][j] = FA_cin[8][j+1];
				//assign FA_sum[8][j] = pp[8][j];
			end
		end			
	endgenerate
	
	assign pp[8][5:0] = pp[7][5:0];
	assign pp[8][15] = '0;
	assign FA_a[8][6:0] = '0;
	assign FA_a[8][15] = '0;
	assign FA_b[8][6:0] = '0;
	assign FA_b[8][15] = '0;
	
	fast_adder FastAdder(
			.a(FA_a[8]),//p[8][15:1]
			.b(FA_b[8]),
			.cin('0),
			//.sum(FA_sum[8][j]),
			.sum(osum),
			//.cout(FA_cout[8][j])
			.cout(FA_cout[8][15])
	);
	
	assign out[6:0] = pp[8][6:0];
	assign out[14:7] = osum[14:7];
	assign out[15] = FA_cout[8][15];

endmodule			  


// genarate col from row-1 to row+6
/*module genarate_col(
	input row,
	output col
); 
	generate
		for(col = row - 1; col < row+6; col++) begin : add_col2_to_13
			assign col = row - 1;

		end;
	endgenerate
endmodule
	*/



// fast adder

module fast_adder(
	input [15:0] a,
   input [15:0] b,
   input cin,
	output cout,
	output [15:0] sum
);
	logic [16:0] carryin;
	logic [15:0] g,p;
	assign carryin[0] = cin;
	assign cout = carryin[15];
	
	genvar i;
	generate
		for (i = 0; i < 16; i++) begin: adder
			assign g[i] = a[i] & b[i];
			assign p[i] = a[i] | b[i];
			assign carryin[i+1] = g[i] | (p[i] & carryin[i]);
			assign sum[i] = a[i] ^ b[i] ^ carryin[i];
		end
	endgenerate
endmodule



// The following code is provided for you to use in your design

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
