module info_frame(
	input clk,
	input reset,
	input start,
	input end_game,
	input [13:0] presscount,
	input [13:0] score,
	input [7:0] addr,
	input [13:0] count_time,
	input [13:0] misscount,
	input [1:0] mode,
	output [7:0]info_ascii
);

reg [7:0] info [179:0];

wire [5:0] seconds;
wire [6:0] minutes;

assign seconds=count_time%60;
assign minutes=count_time/60;

wire [7:0] tempaddr;
assign tempaddr=addr%180;

initial
begin
	$readmemh("info.txt",info,0,179);
end

always @ (posedge clk)
begin
	if(reset==1)
	begin
		info[52]<=42;
		info[53]<=42;
		info[54]<=42;
		info[55]<=42;
		info[76]<=42;
		info[77]<=42;
		info[78]<=42;
		info[79]<=42;
		info[100]<=42;
		info[101]<=42;
		info[102]<=42;
		info[103]<=42;
		info[123]<=42;
		info[124]<=42;
		info[126]<=42;
		info[127]<=42;
		info[134]<=0;
		info[135]<=0;
		info[136]<=0;
		info[137]<=0;
		info[139]<=0;
		info[140]<=0;
		info[141]<=0;
		info[163]<=42;
		info[164]<=42;
		info[165]<=42;
	end
	else
	begin
		if(start==0)
		begin
			info[147]<=80;
			info[148]<=65;
			info[149]<=85;
			info[150]<=83;
			info[151]<=69;
			info[152]<=68;
		end
		else
		begin
			info[147]<=0;
			info[148]<=0;
			info[149]<=0;
			info[150]<=0;
			info[151]<=0;
			info[152]<=0;
			info[52]<=(misscount/1000)+48;
			info[53]<=((misscount/100)%10)+48;
			info[54]<=((misscount/10)%10)+48;
			info[55]<=(misscount%10)+48;
			info[76]<=(presscount/1000)+48;
			info[77]<=((presscount/100)%10)+48;
			info[78]<=((presscount/10)%10)+48;
			info[79]<=(presscount%10)+48;
			info[100]<=(score/1000)+48;
			info[101]<=((score/100)%10)+48;
			info[102]<=((score/10)%10)+48;;
			info[103]<=(score%10)+48;
			info[123]<=(minutes/10)+48;
			info[124]<=(minutes%10)+48;
			info[126]<=(seconds/10)+48;
			info[127]<=(seconds%10)+48;
		end
		if(mode==2'b00)
		begin
			info[163]<=65;
			info[164]<=77;
			info[165]<=65;
		end
		else if(mode==2'b01)
		begin
			info[163]<=80;
			info[164]<=82;
			info[165]<=79;
		end
		else if(mode==2'b10)
		begin
			info[163]<=69;
			info[164]<=68;
			info[165]<=76;
		end
		if(end_game==1)
		begin
			info[134]<=84;
			info[135]<=73;
			info[136]<=77;
			info[137]<=69;
			info[139]<=85;
			info[140]<=80;
			info[141]<=33;
		end
		else
		begin
			info[134]<=0;
			info[135]<=0;
			info[136]<=0;
			info[137]<=0;
			info[139]<=0;
			info[140]<=0;
			info[141]<=0;
		end
	end
end

assign info_ascii=info[tempaddr];

endmodule
