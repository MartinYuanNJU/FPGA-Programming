module newps2board(reset,clk,ps2_clk,ps2_data,offOut,nowdataOut,pastdataOut,dualOut);
input clk,ps2_clk,ps2_data;
input reset;
reg [7:0] nowdata;
reg [7:0] pastdata;
reg [9:0] buffer;
reg [3:0] count;
reg [2:0] ps2_clk_sync;
reg off;
reg isEnd;
reg past;
reg dual;
output [7:0] nowdataOut;
output [7:0] pastdataOut;
output offOut;
output dualOut;
initial
begin
	off=1;
	count=0;
	nowdata=0;
	pastdata=0;
	past=0;
	dual=0;
end
always @ (posedge clk) 
begin
	ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};
end
wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
always @ (posedge clk)
begin
	if(reset)
	begin
		count<=0;
	end
	else if(sampling)
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
	if(reset)
	begin
		off<=1;
		nowdata<=0;
		pastdata<=0;
		past<=0;
		dual<=0;
	end
	else if((count==4'd10) && (sampling) && (buffer[0]==0) && (ps2_data) && (^buffer[9:1]))
	begin
		if(buffer[8:1]==8'b11110000)
		begin
			isEnd<=1;
			off<=1;
			past<=0;
			dual<=0;
		end
		else
		begin
			if(isEnd==0)
			begin
				off<=0;
				nowdata<=buffer[8:1];
				if(past==0&&dual==0)
				begin
					pastdata<=buffer[8:1];
					past<=1;
				end
				else if(past==1&&dual==0)
				begin
					if(pastdata!=buffer[8:1])
					begin
						dual<=1;
					end
				end
			end
			else
			begin
				isEnd<=0;
				past<=0;
				dual<=0;
			end
		end
	end
end
assign nowdataOut=nowdata;
assign pastdataOut=pastdataOut;
assign dualOut=dual;
assign offOut=off;
endmodule
