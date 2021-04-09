// This module uses parameterized instantiation. If values are not set in the testbench the default values specified here are used. 
// The values for EXP and MAN set here are for a IEEE-754 32-bit Floating point representation. 
// TO DO: Edit BITS and BIAS based on the EXP and MAN parameters. 

module part3
	#(parameter EXP = 8,			// Number of bits in the Exponent
	  parameter MAN = 23, 			// Number of bits in the Mantissa
	  parameter BITS = EXP+MAN+1/*TODO*/,	// Total number of bits in the floating point number
	  parameter BIAS = 2**(EXP-1)-1/*TODO*/		// Value of the bias, based on the exponent. 
	  )
	(
		input [BITS - 1:0] X,
		input [BITS - 1:0] Y,
		output inf, nan, zero, overflow, underflow,
		output reg[BITS - 1:0] result
);



// Design your 32-bit Floating Point unit here. 


	
	logic inf_1, nan_1, zero_1, overflow_1, underflow_1; //for corner cases in part 2
	
	
	logic [EXP-1:0]exponent;
	logic [2*MAN+1:0]Mult;//store product of Mantissa
	logic [MAN:0]MantissaX,MantissaY;

	assign MantissaX[MAN] = 1;
	assign MantissaX[MAN-1:0]= X[MAN-1:0];
	assign MantissaY[MAN] = 1;
	assign MantissaY[MAN-1:0]= Y[MAN-1:0];
	

	//normalize
	always_comb begin
	
		result[BITS - 1] = X[BITS - 1] ^ Y[BITS - 1];//sign of output
		
		exponent  = X[BITS-2:MAN] + Y[BITS-2:MAN] - BIAS; //exponent = Xexponent + Yexponent − bias
		
		Mult = MantissaX * MantissaY;//Multiplying mantissas 
		
		
		//for corner cases in part2
		inf_1 = 0;
		nan_1 = 0;
		zero_1 = 0;
		overflow_1 = 0;
		underflow_1 = 0;
		
	
		//if the MSB = 1 
		if(Mult[2*MAN+1] == 1)begin
			Mult = Mult >> 1;//shift the mantissa right
			exponent = exponent + 1'b1;//increment the exponent by 1 
		end
	
		//corner cases for part2
		//case#1 Zero
		//input E = 0, M = 0
		if((X[MAN-1:0] == 0 && X[BITS-2:MAN] == 0) || (Y[MAN-1:0] == 0 && Y[BITS-2:MAN] == 0))begin
			result[BITS - 1] = 0;//S=0
			exponent = 0;
			Mult = 0;
			
			zero_1 = 1;

		end
		
		//case#2 Not-a-Number
		//E = EB, M != 0 
		else if((X[MAN-1:0] != 0 && X[BITS-2:MAN] == 2*BIAS+1) || (Y[MAN-1:0] != 0 && Y[BITS-2:MAN] == 2*BIAS+1))begin
			result[BITS - 1] = 0;//S=0
			Mult = 0;//M = 0
			exponent = 2*BIAS+1;//E = EB

			nan_1 = 1;

		end
		
		//case#3 Infinity
		//E = EB , M = 0
		else if((X[MAN-1:0] == 0 && X[BITS-2:MAN] == 2*BIAS+1) || (Y[MAN-1:0] == 0 && Y[BITS-2:MAN] == 2*BIAS+1))begin
			result[BITS - 1] = 0;//S=0
			Mult = 0;//M = 0
			exponent = 2*BIAS+1;//E = EB
			
			inf_1 = 1;

		end
	
		//if normalized
		else if(Mult[2*MAN+1] == 1)begin
			//case#4 Underflow
			//E < 0 
			if((X[BITS-2:MAN] + Y[BITS-2:MAN] + 1) <= BIAS)begin
				result[BITS - 1] = 0;//S=0
				Mult = 0;//M = 0
				exponent = 0;//E = 0

				underflow_1 = 1;
			end


			
			//case#5 Overflow
			//E > EB
			else if((X[BITS-2:MAN] + Y[BITS-2:MAN] - BIAS + 1) >= 2*BIAS+1)begin
				result[BITS - 1] = 0;//S=0
				Mult = 0;//M = 0
				exponent = 2*BIAS+1;//E = EB
				
				overflow_1 = 1;
			end
		end
		
		//not normalized
		//case#4 Underflow
		//E < 0 
		else if((X[BITS-2:MAN] + Y[BITS-2:MAN]) <= BIAS)begin
			result[BITS - 1] = 0;//S=0
			Mult = 0;//M = 0
			exponent = 0;//E = 0

			underflow_1 = 1;
		end


		
		//case#5 Overflow
		//E > EB
		else if((X[BITS-2:MAN] + Y[BITS-2:MAN] - BIAS) >= 2*BIAS+1)begin
			result[BITS - 1] = 0;//S=0
			Mult = 0;//M = 0
			exponent = 2*BIAS+1;//E = EB
			
			overflow_1 = 1;
		end
	
	
		

	end
	
	
	//for corner cases in part2
	assign inf = inf_1;
	assign nan = nan_1;
	assign zero = zero_1;
	assign overflow = overflow_1;
	assign underflow = underflow_1; 
	
	
	//round
	assign result[MAN-1:0] = Mult[2*MAN-1:MAN];//Mantissa of output
	
	assign result[BITS - 2 : MAN] = exponent[EXP-1:0];//E of output


endmodule