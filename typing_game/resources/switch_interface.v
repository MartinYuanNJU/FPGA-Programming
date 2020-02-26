module switch_interface(
	input interface,
	input start_or_stop,
	input choose_mode,
	input reset,
	output menu_or_game,
	output [1:0] mode,
	output start
);

reg at_main_menu;
reg [1:0] mode_choose;
reg start_game;

initial
begin
	at_main_menu=1;
	start_game=0;
	mode_choose=0;
end

always @ (negedge interface)
begin
	at_main_menu=~at_main_menu;
end

always @ (negedge choose_mode)
begin
	if(at_main_menu==1)
		mode_choose=(mode_choose+1)%3;
end

always @ (negedge start_or_stop)
begin
	if(at_main_menu==0)
		start_game=~start_game;
end

assign menu_or_game=at_main_menu;
assign mode=mode_choose;
assign start=start_game & (~at_main_menu);
endmodule
