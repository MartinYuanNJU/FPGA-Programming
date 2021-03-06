module DotMem(
	input [11:0] addr,
	output [11:0] q
	);
	
reg [11:0] mem [4095:0];
	
initial
begin
	$readmemh("vga_font.txt", mem, 0, 4095);
end

assign q = mem[addr];

endmodule
