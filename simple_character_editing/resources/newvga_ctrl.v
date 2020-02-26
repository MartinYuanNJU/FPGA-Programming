module newvga_ctrl(
input pclk,
input reset,
input clk50,
input clk25,
input en,
input [11:0] waddr,
input [11:0] raddr,
input [7:0] asciicode,
input [23:0] vga_data,
output [9:0] h_addr, 
output [9:0] v_addr,
output hsync, 
output vsync,
output valid, 
output [7:0] vga_r, 
output [7:0] vga_g,
output [7:0] vga_b,
output [7:0] vgaasciicode
);
parameter h_frontporch = 96;
parameter h_active = 144;
parameter h_backporch = 784;
parameter h_total = 800;
parameter v_frontporch = 2;
parameter v_active = 35;
parameter v_backporch = 515;
parameter v_total = 525;
reg [9:0] x_cnt;
reg [9:0] y_cnt;

wire h_valid;
wire v_valid;
always @(posedge reset or posedge pclk)
if (reset == 1'b1)
	x_cnt <= 1;
else
begin
	if (x_cnt == h_total)
		x_cnt <= 1;
	else
		x_cnt <= x_cnt + 10'd1;
end
always @(posedge pclk)
if (reset == 1'b1)
	y_cnt <= 1;
else
begin
	if (y_cnt == v_total & x_cnt == h_total)
		y_cnt <= 1;
	else if (x_cnt == h_total)
		y_cnt <= y_cnt + 10'd1;
end

VGARam vgaram(
	.data(asciicode),
	.rdaddress(raddr),
	.rdclock(clk25),
	.rden(1'b1),
	.wraddress(waddr),
	.wrclock(clk50),
	.wren(en),
	.q(vgaasciicode)
);

assign hsync = (x_cnt > h_frontporch);
assign vsync = (y_cnt > v_frontporch);
assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
assign valid = h_valid & v_valid;
assign h_addr = h_valid ? (x_cnt - 10'd144) : {10{1'b0}};
assign v_addr = v_valid ? (y_cnt - 10'd35) : {10{1'b0}};
assign vga_r = vga_data[23:16];
assign vga_g = vga_data[15:8];
assign vga_b = vga_data[7:0];
endmodule
