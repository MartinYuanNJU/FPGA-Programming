module VideoMem(
	input [6:0] row,
	input [6:0] col,
	input wren,
	input [7:0]data_in,
	output [7:0] data_out
	);
	
	reg [7:0] video_mem [69:0];
	
initial
begin
	video_mem[0] = 8'h61;
	video_mem[1] = 8'h62;
	video_mem[2] = 8'h63;
	video_mem[3] = 8'h64;
end
	
always @ (row or col)
begin
	if(wren == 1) video_mem[row*70+col] = data_in;
end

assign data_out = video_mem[row*70+col];

endmodule
