module LFSR(
	input clk,
	input en,
	input [31:0] seed,
	input [1:0] mode,
	output [7:0] velocity_port,
	output [5:0] position_port,
	output [7:0] asciicode_port,
	output linenum_port
);

reg [31:0] lfsr;
reg [7:0] velocity;
reg [5:0] position;
reg [7:0] asciicode;
reg linenum;

initial
begin
	lfsr={seed[30:0], seed[31] ^~ seed[28]};
end

always @ (posedge clk)
begin
	if(en)
	begin
		velocity <= lfsr[7:0];
		position <= (lfsr[5:0] % 52) + 1;
		if(mode == 2'b00)
			asciicode <= (lfsr[7:0] % 26) + 97;
		else
		begin
			if(lfsr[7]==1)
				asciicode <= (lfsr[7:0] % 26) + 65;
			else
				asciicode <= (lfsr[7:0] % 26) + 97;
		end
		linenum <= lfsr[0];
		lfsr <= {lfsr[30:0], lfsr[31] ^~ lfsr[28]};
	end
	else
	begin
		velocity <= 0;
		position <= 0;
		asciicode <= 0;
		linenum <= 0;
		lfsr <= {seed[30:0], seed[31] ^~ seed[28]};
	end
end

assign velocity_port=velocity;
assign position_port=position;
assign asciicode_port=asciicode;
assign linenum_port=linenum;

endmodule
