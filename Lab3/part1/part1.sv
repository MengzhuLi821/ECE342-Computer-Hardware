module part1
	(
		input [31:0] X,
		input [31:0] Y,
		output [31:0] result
);

// Design your 32-bit Floating Point unit here. 


	assign result[31] = X[31] ^ Y[31];//sign of output

	logic [7:0]exponent;
	logic [47:0]Mult;//store product of Mantissa
	logic [23:0]MantissaX,MantissaY;

	assign MantissaX[23] = 1;
	assign MantissaX[22:0]= X[22:0];
	assign MantissaY[23] = 1;
	assign MantissaY[22:0]= Y[22:0];

	
	//denormalize
	always_comb begin
	
	exponent  = X[30:23] + Y[30:23] - 127; //exponent = Xexponent + Yexponent − 127
	
	Mult = MantissaX * MantissaY;//Multiplying mantissas 
	
	
		//if the MSB = 1 
		if(Mult[47] == 1)begin
			Mult = Mult >> 1;//shift the mantissa right
			exponent = exponent + 1'b1;//increment the exponent by 1 	
		end
	
	end
	
	//round
	assign result[22:0] = Mult[45:23];//Mantissa of output
	
	assign result[30:23] = exponent[7:0];//E of output

endmodule
