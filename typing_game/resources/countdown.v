module countdown(
	input clk,
	input menu_or_game,
	input start,
	input [1:0] mode,
	output [13:0] count_time,
	output reg end_game
);

reg [13:0] time_info;
reg [24:0] count;

wire [13:0] amateur_time;
wire [13:0] professional_time;

assign amateur_time=45;
assign professional_time=90;

reg [13:0] finaltime;

initial
begin
	time_info=0;
	count=0;
	finaltime=0;
end

always @ (posedge clk)
begin
	if(menu_or_game==1)
	begin
		time_info<=0;
		count<=0;
		end_game<=0;
		if(mode==2'b00)
			finaltime<=amateur_time;
		else if(mode==2'b01)
			finaltime<=professional_time;
		else if(mode==2'b10)
			finaltime<=0;
	end
	else
	begin
		if(end_game==0)
		begin
			if(start==1)
			begin
				if(count==25000000)
				begin
					time_info<=time_info+1;
					count<=0;
				end
				else
					count<=count+1;
			end
			if(mode==2'b00)
				finaltime<=amateur_time-time_info;
			else if(mode==2'b01)
				finaltime<=professional_time-time_info;
			else if(mode==2'b10)
				finaltime<=time_info;
			if(mode==2'b00||mode==2'b01)
			begin
				if(finaltime==0)
					end_game<=1;
			end
		end
	end
end

assign count_time=finaltime;

endmodule
