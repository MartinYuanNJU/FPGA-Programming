module VelocityMem(
	input [6:0] row,
	input [6:0] col,
	input wren,
	input [1:0]data_in,
	output [1:0] data_out
	);
	
	reg [1:0] velocity_mem [52:0];
	
	reg init_flag;
	
initial
begin
	//init_flag = 1;
	$readmemh("velocity_mem_init.txt", velocity_mem, 0, 52);
end

/*always @ (*)	init_flag = 1;

always @ (posedge init_flag)
begin
		velocity_mem[0] = 0;		velocity_mem[11] = 2;		velocity_mem[22] = 0;		velocity_mem[33] = 3;		velocity_mem[44] = 0;
		velocity_mem[1] = 1;		velocity_mem[12] = 1;		velocity_mem[23] = 1;		velocity_mem[34] = 2;		velocity_mem[45] = 1;
		velocity_mem[2] = 2;		velocity_mem[13] = 3;		velocity_mem[24] = 3;		velocity_mem[35] = 3;		velocity_mem[46] = 3;
		velocity_mem[3] = 3;		velocity_mem[14] = 1;		velocity_mem[25] = 1;		velocity_mem[36] = 1;		velocity_mem[47] = 3;
		velocity_mem[4] = 1;		velocity_mem[15] = 0;		velocity_mem[26] = 2;		velocity_mem[37] = 0;		velocity_mem[48] = 2;
		velocity_mem[5] = 3;		velocity_mem[16] = 2;		velocity_mem[27] = 0;		velocity_mem[38] = 1;		velocity_mem[49] = 2;
		velocity_mem[6] = 2;		velocity_mem[17] = 3;		velocity_mem[28] = 1;		velocity_mem[39] = 3;		velocity_mem[50] = 1;
		velocity_mem[7] = 0;		velocity_mem[18] = 2;		velocity_mem[29] = 2;		velocity_mem[40] = 2;		velocity_mem[51] = 0;
		velocity_mem[8] = 0;		velocity_mem[19] = 1;		velocity_mem[30] = 3;		velocity_mem[41] = 3;		velocity_mem[52] = 1;
		velocity_mem[9] = 3;		velocity_mem[20] = 0;		velocity_mem[31] = 1;		velocity_mem[42] = 1;
		velocity_mem[10] = 1;	velocity_mem[21] = 2;		velocity_mem[32] = 0;		velocity_mem[43] = 2;	
end*/
	
/*always @ (row or col)
	if(wren == 1) velocity_mem[row*53+col] = data_in;*/

assign data_out = velocity_mem[row*53+col];

endmodule
