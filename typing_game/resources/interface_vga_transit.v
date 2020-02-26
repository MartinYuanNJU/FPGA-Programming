module interface_vga_transit(
	input clk,
	input menu_or_game,
	input [9:0] h_addr,
	input [9:0] v_addr,
	input [7:0] game_info_ascii,
	output initiate_black,
	output game_info_black,
	output gameover_info_black
);

reg ini_color;
reg gain_color;
reg gaov_color;

reg [11:0] text [4095:0]; //the icon information base

//start of initial_color
wire [9:0] h_addr_ini1;
wire [9:0] h_addr_ini2;
wire [9:0] v_addr_ini1;
wire [9:0] v_addr_ini2;

wire [7:0] initiate_ascii;

wire [7:0] gameover_ascii;
wire [11:0] lineaddr_gameover;
reg [11:0] line_gameover;

assign lineaddr_gameover=(gameover_ascii << 4)+v_addr_ini2;

wire [11:0] initiate_addr;
wire [11:0] lineaddr_ini;
reg [11:0] line_ini;

assign h_addr_ini1=h_addr/9;
assign h_addr_ini2=(h_addr%9)-1;
assign v_addr_ini1=v_addr/16;
assign v_addr_ini2=v_addr%16;

assign initiate_addr=(v_addr_ini1 << 6)+(v_addr_ini1 << 2)+(v_addr_ini1 << 1)+h_addr_ini1;
assign lineaddr_ini=(initiate_ascii << 4)+v_addr_ini2;

//end

//start of game_color

wire [9:0] h_addr_game;
wire [9:0] v_addr_game;
wire [11:0] lineaddr_game;

reg [11:0] line_game;

assign h_addr_game=(h_addr%9)-1;
assign v_addr_game=v_addr%16;
assign lineaddr_game=(game_info_ascii << 4)+v_addr_game;

//end

initial
begin
	$readmemh("vga_font.txt",text,0,4095);
	ini_color=0;
	gain_color=0;
	gaov_color=0;
end

initiate_pic my_initiate(.address(initiate_addr),.clock(clk),.q(initiate_ascii));

gameover my_gameover(.address(initiate_addr),.clock(clk),.q(gameover_ascii));

always @ (posedge clk)
begin
	if(menu_or_game==1)
	begin
		line_ini<=text[lineaddr_ini];
		if(line_ini[h_addr_ini2]==1)
			ini_color<=1;
		else
			ini_color<=0;
	end
	else
	begin
		line_game<=text[lineaddr_game];
		line_gameover<=text[lineaddr_gameover];
		if(line_game[h_addr_game]==1)
			gain_color<=1;
		else
			gain_color<=0;
		if(line_gameover[h_addr_ini2]==1)
			gaov_color<=1;
		else
			gaov_color<=0;
	end
end

assign initiate_black=ini_color;
assign game_info_black=gain_color;
assign gameover_info_black=gaov_color;

endmodule
