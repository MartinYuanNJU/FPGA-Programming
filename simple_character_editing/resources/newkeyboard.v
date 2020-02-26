module newkeyboard(clk,clrn,ps2_clk,ps2_data,codeOut,enOut,waddrOut,ascii,ptrOut);
input clk,clrn,ps2_clk,ps2_data;
reg [9:0] buffer;
reg [3:0] count;
reg [2:0] ps2_clk_sync;
reg isEnd;
reg isShift;
reg delEnter;
reg isE0;
reg [7:0] data;
reg [11:0] ptr;
reg [11:0] waddr;
reg [11:0] tempwaddr;
wire [7:0] waddr1;
wire [11:0] waddr2;
wire [11:0] waddr3;
wire [7:0] ptr1;
wire [11:0] ptr2;
wire [4:0] ptr3;
wire [11:0] ptr4;
wire [11:0] ptr5;
wire [7:0] asciicode;
reg en;
reg [7:0] back [4:0];
output enOut;
output [7:0] codeOut;
output [7:0] ascii;
output [11:0] waddrOut;
output [11:0] ptrOut;
assign waddr1=waddr%70;
assign ptr1=ptr%70; //这一行已经有多少个字符
assign ptr2=ptr+70-ptr1;
assign ptr3=ptr/70; //第几行的字符
assign ptr4=((ptr3-1) << 6)+((ptr3-1) << 2)+((ptr3-1) << 1)+back[ptr3-1]-1;
assign ptr5=((ptr3-1) << 6)+((ptr3-1) << 2)+((ptr3-1) << 1)+69;
assign waddr2=((ptr3-1) << 6)+((ptr3-1) << 2)+((ptr3-1) << 1)+back[ptr3-1]-1;
assign waddr3=((ptr3-1) << 6)+((ptr3-1) << 2)+((ptr3-1) << 1)+69;
initial
begin
	data=0;
	count=0;
	isEnd=0;
	isShift=0;
	waddr=0;
	ptr=0;
	en=0;
	delEnter=0;
	isE0=0;
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

codeChange func(.code(data),.shift(isShift),.outdata(asciicode)); //发送的键码时刻转化为ASCII码

always @ (posedge clk)
begin
	if(clrn==1)
	begin
		isEnd<=0;
		isShift<=0;
		en<=0;
		ptr<=0;
		data<=0;
		waddr<=0;
		delEnter<=0;
		isE0<=0;
	end
	else if((count==4'd10) && (sampling) && (buffer[0]==0) && (ps2_data) && (^buffer[9:1]))
	begin
		if(buffer[8:1]==8'b11110000)
		begin
			isEnd<=1;
			en<=0;
			isE0<=0;
		end
		else
		begin
			if(isEnd==0)
			begin
				if(buffer[8:1]==8'h12||buffer[8:1]==8'h59)
				begin
					isShift<=1;
					isE0<=0;
					delEnter<=0;
				end
				else if(buffer[8:1]==8'h66) //退格键
				begin
					if(back[ptr3]!=0) //这一行还有字符
					begin
						back[ptr3]<=back[ptr3]-1;
						ptr<=ptr-1;
						waddr<=tempwaddr;
						tempwaddr<=tempwaddr-1;
						data<=8'h00;
						en<=1;
					end
					else if(ptr3!=0) //这一行已经没有字符且不是第一行
					begin
						if(delEnter==0)
						begin
							delEnter<=1;
						end
						else
						begin
							back[ptr3-1]<=back[ptr3-1]-1;
							ptr<=ptr4;
							waddr<=waddr2;
							data<=8'h00;
							en<=1;
							delEnter<=0;
						end
					end
					isE0<=0;
				end
				else if(buffer[8:1]==8'h5A) //回车键
				begin
					if(ptr!=0&&waddr1==69)
						ptr<=ptr;
					else
						ptr<=ptr2;
					en<=0;
					delEnter<=0;
					isE0<=0;
				end
				else if(buffer[8:1]==8'hE0)
				begin
					isE0<=1;
					en<=0;
				end
				else if(buffer[8:1]==8'h75)
				begin
					if(isE0==1)
					begin
						if(ptr3!=0)
						begin
							ptr<=ptr-70;
						end
						isE0<=0;
					end
				end
				else if(buffer[8:1]==8'h6B)
				begin
					if(isE0==1)
					begin
						if(ptr!=0)
						begin
							ptr<=ptr-1;
						end
						isE0<=0;
					end
				end
				else if(buffer[8:1]==8'h72)
				begin
					if(isE0==1)
					begin
						if(ptr3!=29)
						begin
							ptr<=ptr+70;
						end
						isE0<=0;
					end
				end
				else if(buffer[8:1]==8'h74)
				begin
					if(isE0==1)
					begin
						ptr<=(ptr+1)%2100;
						isE0<=0;
					end
				end
				else
				begin
					data<=buffer[8:1];
					waddr<=ptr;
					tempwaddr<=ptr;
					back[ptr3]<=ptr1+1;
					if(buffer[8:1]==8'h0D)
					begin
						ptr<=(ptr+4)%2100;
						en<=0;
					end
					else
					begin
						ptr<=(ptr+1)%2100;
						en<=1;
					end
					delEnter<=0;
					isE0<=0;
				end
			end
			else
			begin
				if(buffer[8:1]==8'h12||buffer[8:1]==8'h59)
					isShift<=0;
				isEnd<=0;
				en<=0;
				isE0<=0;
			end
		end
	end
end
assign codeOut=asciicode;
assign ascii=back[ptr3];
assign enOut=en;
assign waddrOut=waddr;
assign ptrOut=ptr;
endmodule
