module ps2_keyboard(clk,clrn,ps2_clk,ps2_data,start,mode,ready,asciicode,presscount,real_ready);
input clk,clrn,ps2_clk,ps2_data;
input start;
input [1:0] mode;
output reg ready;
output [7:0] asciicode;
reg [9:0] buffer;
reg [3:0] count;
reg [7:0] data;
reg [2:0] ps2_clk_sync;
reg isEnd;
reg isShift;
reg isFirst;
output reg [13:0] presscount;
wire [7:0] tempascii;

reg [19:0] real_ready_count;
output real_ready;

initial
begin
	data=0;
	count=0;
	isEnd=0;
	isShift=0;
	ready=0;
	presscount=0;
	isFirst=1;
	real_ready_count=0;
end

always @ (posedge clk) 
begin
	ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};
end

wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

always @ (posedge clk)
begin
	if(clrn==1)
	begin
		count<=0; 
		buffer<=0;
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

codeChange func(.code(data),.shift(isShift),.outdata(tempascii));

always @ (posedge clk)
begin
	if(clrn==1)
	begin
		isEnd<=0;
		isShift<=0;
		isFirst<=1;
		ready<=0;
		presscount<=0;
	end
	else if((count==4'd10) && (sampling) && (buffer[0]==0) && (ps2_data) && (^buffer[9:1]))
	begin
		if(buffer[8:1]==8'b11110000)
		begin
			isEnd<=1;
			ready<=0;
		end
		else
		begin
			if(isEnd==0&&start==1)
			begin
				if(mode==2'b00)
				begin
					data<=buffer[8:1];
					ready<=1;
				end
				else
				begin
					if(buffer[8:1]==8'h12||buffer[8:1]==8'h59)
					begin
						isShift<=1;
						ready<=0;
					end
					else
					begin
						data<=buffer[8:1];
						ready<=1;
					end
				end
				if(isFirst==1)
				begin
					if((mode==2'b00)||(mode!=2'b00&&buffer[8:1]!=8'h12&&buffer[8:1]!=8'h59))
					begin
						presscount<=(presscount+1)%10000;
						isFirst<=0;
					end
				end
			end
			else
			begin
				if(buffer[8:1]==8'h12||buffer[8:1]==8'h59)
					isShift<=0;
				isEnd<=0;
				if(mode==2'b00)
					isFirst<=1;
				else
				begin
					if(buffer[8:1]!=8'h12&&buffer[8:1]!=8'h59)
						isFirst<=1;
				end
				ready<=0;
			end
		end
	end
end

always @ (posedge clk)
begin
	if(clrn==1||ready==0)
		real_ready_count<=0;
	else
	begin
		if(real_ready_count==1000000)
			real_ready_count<=840000;
		else
			real_ready_count<=real_ready_count+1;
	end
end

assign asciicode=tempascii;
assign real_ready=ready && (real_ready_count<840000) && (~clrn);
endmodule
