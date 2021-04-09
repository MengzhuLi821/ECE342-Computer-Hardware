module part2
	(
		input [31:0] X,
		input [31:0] Y,
		output inf, nan, zero, overflow, underflow,
		output reg[31:0] result
);

// Design your 32-bit Floating Point unit here. 


	
	logic inf_1, nan_1, zero_1, overflow_1, underflow_1; //for corner cases in part 2
	
	
	logic [7:0]exponent;
	logic [47:0]Mult;//store product of Mantissa
	logic [23:0]MantissaX,MantissaY;

	assign MantissaX[23] = 1;
	assign MantissaX[22:0]= X[22:0];
	assign MantissaY[23] = 1;
	assign MantissaY[22:0]= Y[22:0];
	

	//normalize
	always_comb begin
	
		result[31] = X[31] ^ Y[31];//sign of output
		
		exponent  = X[30:23] + Y[30:23] - 127; //exponent = Xexponent + Yexponent − 127
		
		Mult = MantissaX * MantissaY;//Multiplying mantissas 
		
		
		//for corner cases in part2
		inf_1 = 0;
		nan_1 = 0;
		zero_1 = 0;
		overflow_1 = 0;
		underflow_1 = 0;
		
	
		//if the MSB = 1 
		if(Mult[47] == 1)begin
			Mult = Mult >> 1;//shift the mantissa right
			exponent = exponent + 1'b1;//increment the exponent by 1 
		end
	
		//corner cases for part2
		//case#1 Zero
		//input E = 0, M = 0
		if((X[22:0] == 0 && X[30:23] == 0) || (Y[22:0] == 0 && Y[30:23] == 0))begin
			result[31] = 0;//S=0
			exponent = 0;
			Mult = 0;
			
			zero_1 = 1;

		end
		
		//case#2 Not-a-Number
		//E = EB, M != 0 
		else if((X[22:0] != 0 && X[30:23] == 255) || (Y[22:0] != 0 && Y[30:23] == 255))begin
			result[31] = 0;//S=0
			Mult = 0;//M = 0
			exponent = 255;//E = EB

			nan_1 = 1;

		end
		
		//case#3 Infinity
		//E = EB , M = 0
		else if((X[22:0] == 0 && X[30:23] == 255) || (Y[22:0] == 0 && Y[30:23] == 255))begin
			result[31] = 0;//S=0
			Mult = 0;//M = 0
			exponent = 255;//E = EB
			
			inf_1 = 1;

		end
	
		
		//if normalized
		else if(Mult[47] == 1)begin
			//case#4 Underflow
			//E < 0
			if((X[30:23] + Y[30:23] + 1) <= 127)begin
				result[31] = 0;//S=0
				Mult = 0;//M = 0
				exponent = 0;//E = 0

				underflow_1 = 1;
			end	
			
			//case#5 Overflow
			//E > EB
			else if((X[30:23] + Y[30:23] - 127 + 1) >= 255)begin
				result[31] = 0;//S=0
				Mult = 0;//M = 0
				exponent = 255;//E = EB
				
				overflow_1 = 1;
			end
		end
	
	
		//case#4 Underflow
		//E < 0 
		else if((X[30:23] + Y[30:23]) <= 127)begin
			result[31] = 0;//S=0
			Mult = 0;//M = 0
			exponent = 0;//E = 0

			underflow_1 = 1;
		end
		
		//case#5 Overflow
		//E > EB
		else if((X[30:23] + Y[30:23] - 127) >= 255)begin
			result[31] = 0;//S=0
			Mult = 0;//M = 0
			exponent = 255;//E = EB
			
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
	assign result[22:0] = Mult[45:23];//Mantissa of output
	
	assign result[30:23] = exponent[7:0];//E of output


endmodule