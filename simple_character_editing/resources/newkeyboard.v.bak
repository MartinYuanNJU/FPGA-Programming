module keyboard(clk,clrn,ps2_clk,ps2_data,addr,codeOut,ascii);
input clk,clrn,ps2_clk,ps2_data;
input [11:0] addr;
reg [9:0] buffer;
reg [3:0] count;
reg [2:0] ps2_clk_sync;
reg isEnd;
reg isShift;
reg [7:0] rom [2099:0];
reg [7:0] data;
integer i;
reg [11:0] ptr;
wire [7:0] asciicode;
output [7:0] codeOut;
output [7:0] ascii;
initial
begin
	for(i=0;i<2100;i=i+1)
	begin
		rom[i]=8'b00000000;
	end
	data=0;
	count=0;
	isEnd=0;
	isShift=0;
	ptr=0;
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

codeChange func(.code(data),.shift(isShift),.outdata(asciicode));

always @ (posedge clk)
begin
	if(clrn==1)
	begin
		isEnd<=0;
		isShift<=0;
		for(i=0;i<2100;i=i+1)
		begin
			rom[i]<=8'b00000000;
		end
		ptr<=0;
		data<=0;
	end
	else if((count==4'd10) && (sampling) && (buffer[0]==0) && (ps2_data) && (^buffer[9:1]))
	begin
		if(buffer[8:1]==8'b11110000)
		begin
			isEnd<=1;
		end
		else
		begin
			if(isEnd==0)
			begin
				if(buffer[8:1]==8'h12||buffer[8:1]==8'h59)
					isShift<=1;
				else
				begin
					data<=buffer[8:1];
					rom[ptr]<=asciicode;
					ptr<=(ptr+1)%2100;
				end
			end
			else
			begin
				if(buffer[8:1]==8'h12||buffer[8:1]==8'h59)
					isShift<=0;
				isEnd<=0;
			end
		end
	end
end
assign codeOut=rom[addr];
assign ascii=asciicode;
endmodule
