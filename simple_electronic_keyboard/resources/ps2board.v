module ps2board(clk,ps2_clk,ps2_data,signalOut,offOut);
input clk,ps2_clk,ps2_data;
reg [7:0] data;
reg [9:0] buffer;
reg [3:0] count;
reg [2:0] ps2_clk_sync;
reg off;
reg isEnd;
output [7:0]signalOut;
output offOut;
initial
begin
	off=1;
	count=0;
	data=0;
end
always @ (posedge clk) 
begin
	ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};
end
wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
always @ (posedge clk)
begin
	if(sampling)
	begin
		if(count == 4'd10)
		begin
			if((buffer[0] == 0) && (ps2_data) && (^buffer[9:1]))
				count <= 0;
		end
		else
		begin
			buffer[count] <= ps2_data;
			count <= count + 3'b1;
		end
	end
end
always @ (posedge clk)
begin
	if((count==4'd10) && (sampling) && (buffer[0]==0) && (ps2_data) && (^buffer[9:1]))
	begin
		if(buffer[8:1]==8'b11110000)
		begin
			isEnd<=1;
			off<=1;
		end
		else
		begin
			if(isEnd==0)
			begin
				off<=0;
				data<=buffer[8:1];
			end
			else
			begin
				isEnd<=0;
			end
		end
	end
end
assign signalOut=data;
assign offOut=off;
endmodule
