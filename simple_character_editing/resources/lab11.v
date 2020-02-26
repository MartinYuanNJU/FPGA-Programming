module lab11(CLK_50,reset,CLK_25,CLK_PS2,PS2_DAT,hsync,vsync,blank,vga_r,vga_g,vga_b,vga_sync,ledA,ledB);
input CLK_50;
input reset;
input CLK_PS2;
input PS2_DAT;
reg [23:0] vga_data;
reg [25:0] clockcount;
wire [11:0] waddr;
wire [11:0] ptr;
wire [9:0] ptr1;
wire [9:0] ptr2;
wire [9:0] h_addr;
wire [9:0] v_addr;
wire [7:0] asciicode;
wire [7:0] vgaasciicode;
wire [7:0] ascii;
wire [11:0] addr;
wire [9:0] h_addr1;
wire [9:0] v_addr1;
wire [9:0] h_addr2;
wire [9:0] v_addr2;
wire [11:0] lineaddr;
wire clear;
wire en;
reg [11:0] text [4095:0];
reg [11:0] line;
reg dot;
reg point;
output CLK_25;
output hsync;
output vsync;
output blank; 
output [7:0] vga_r;
output [7:0] vga_g;
output [7:0] vga_b;
output reg vga_sync;
output [6:0]ledA;
output [6:0]ledB;
assign vag_sync=1'b0;
assign clear=~reset;
assign h_addr1=h_addr/9;
assign h_addr2=(h_addr%9)-1;
assign v_addr1=v_addr/16;
assign v_addr2=v_addr%16;
assign addr=(v_addr1 << 6)+(v_addr1 << 2)+(v_addr1 << 1)+h_addr1;
assign lineaddr=(vgaasciicode << 4)+v_addr2;
assign ptr1=ptr/70;
assign ptr2=ptr%70;
initial
begin
	$readmemh("vga_font.txt",text,0,4095);
	point=1;
	clockcount=0;
end

clkgen #(25000000) my_vgaclk(CLK_50,clear,1'b1,CLK_25);

numToled func3(
	.count(ascii/16),
	.led(ledB)
);

numToled func4(
	.count(ascii%16),
	.led(ledA)
);

newvga_ctrl func1(
	.pclk(CLK_25),
	.reset(clear),
	.clk50(CLK_50),
	.clk25(CLK_25),
	.en(en),
	.waddr(waddr),
	.raddr(addr),
	.asciicode(asciicode),
	.vga_data(vga_data),
	.h_addr(h_addr),
	.v_addr(v_addr),
	.hsync(hsync),
	.vsync(vsync),
	.valid(blank),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b),
	.vgaasciicode(vgaasciicode)
);

newkeyboard func2(
	.clk(CLK_50),
	.clrn(clear),
	.ps2_clk(CLK_PS2),
	.ps2_data(PS2_DAT),
	.enOut(en),
	.waddrOut(waddr),
	.codeOut(asciicode),
	.ascii(ascii),
	.ptrOut(ptr)
);

always @ (posedge CLK_50)
begin
	line<=text[lineaddr];
	if(v_addr1==ptr1&&h_addr1==ptr2)
	begin
		point<=0;
		if(v_addr2>12&&clockcount<=25000000)
			vga_data<=24'hFFFFFF;
		else
			vga_data<=24'h000000;
	end
	else if(line[h_addr2]&&h_addr1<70&&point)
		vga_data<=24'hFFFFFF;
	else
	begin
		vga_data<=24'h000000;
		point<=1;
	end
	clockcount<=(clockcount+1)%50000000;
end

endmodule
