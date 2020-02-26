module assign_vgadata(
	input clk,					//50HZ时钟
	input vga_clk,				//VGA_CLK
	input [9:0] ha,			//h_addr
	input [9:0] va,			//v_addr
	output [23:0] vgadata,	//输出的vgadata
	input valid,				//消隐信号
	input pause,				//暂停，低态有效****
	output ready,				//vgadata有效
	input n,						//用于调试
	input kb_ready,			//键盘ready****
	input vmdelete_wren,		//删除信号
	input [7:0] kb_data,		//键盘给的ascii码****
	output [10:0] off,		//改行要删除的元素所处于屏幕中的位置
	output reg [9:0] wr_iter,	//所要删除元素的地址
	input [7:0] vmdata_wr,	//要写入显存的数据，为ASCII码****
	input vmdata_wren,		//写使能
	input [5:0] vmdata_wraddr,	//写地址****
	output wr_ready,			//为1代表可以写入，否则代表该地址仍有数据，不可写入
	input [7:0] veldata_wr,	//要写入的速度数据****
	output reg [13:0] hit_count,
	input reset
	);
	
	
	reg [10:0] offset [52:0];
	reg [9:0] my_va [52:0];
		
	wire [6:0] vmrow;
	wire [6:0] vmcol;
	wire [11:0] dot_mem_addr;
	wire [3:0] color_addr;
	wire [5:0] video_mem_addr;
	wire [5:0] velocity_mem_addr;
	wire [5:0] video_mem_wraddr;
	wire [7:0] velocity_mem_wrdata;
	wire [5:0] velocity_mem_wraddr;
	wire velocity_mem_wren;
	
	wire [7:0] video_mem_data;
	wire [11:0] dot_mem_data;
	wire [7:0] velocity;
	
	reg [7:0] velocity_mem [52:0];
	reg [7:0] video_mem [52:0];
	
	wire [7:0] video_mem_wrdata;
	
	integer i;
	wire [9:0] iter;
	reg [5:0] vel_count;
	reg [5:0] reset_addr;
	reg [2:0] v_count;
	
	wire video_mem_wren;
	
	
	wire end_flag;
	wire begin_flag;
	reg hit_flag;

	
initial
begin
end


VideoMem_IP video_memory_ip(clk, video_mem_wrdata, video_mem_addr, video_mem_wraddr, video_mem_wren, video_mem_data);

DotMem dot_memory(dot_mem_addr, dot_mem_data);

VelocityMem_IP velocity_mem_ip(clk, velocity_mem_wrdata, velocity_mem_addr, velocity_mem_wraddr, velocity_mem_wren, velocity);

always @ (posedge vga_clk)
begin
	if(reset)
	begin
		hit_count <= 0;
		if(reset_addr == 53) reset_addr <= 0;
		else	reset_addr <= reset_addr + 1;
	end
	else
	begin
		video_mem[video_mem_addr] <= video_mem_data;
		if(vel_count == 53) vel_count <= 0;
		else 
		begin
			velocity_mem[vel_count] <= velocity;
			vel_count <= vel_count + 1;
		end
		if(valid)
		begin
			for(i = 0; i < 53; i = i + 1) my_va[i] <= va + offset[i][10:1];
		end
		if(end_flag)
		begin
			if(kb_ready)
			begin
				for(i = 0; i < 53; i = i + 1)
				begin
					if(video_mem[i] == kb_data) 
					begin
						if(vmdelete_wren)	hit_flag <= 1;
						if(wr_iter == 0) wr_iter <= i;
						else if(offset[i] - 32 > offset[wr_iter] - 32) wr_iter <= i;
					end
				end
			end else wr_iter <= 0;
		
			//if(vmdelete_wren) hit_count <= hit_count + 1;

			for(i = 0; i < 53; i = i + 1)
			begin 
				offset[i] <= offset[i] - pause * ((velocity_mem[i] + n) % 4 + 1);
				if(offset[i][10:1] == 544 || offset[i][10:1] == 543) offset[i] <= 32;
			end
		
		end
		if(begin_flag)
		begin
			if(video_mem_wren)	offset[video_mem_wraddr] <= 32;
			if(vmdelete_wren && hit_flag) hit_count <= hit_count + 1;
			hit_flag <= 0;
			v_count <= v_count + 1;
		end
	end
end



assign color_addr = (iter < 53 && my_va[iter] >= 1 && my_va[iter] <= 16) ? (ha - 1) % 9 : 0;
assign video_mem_addr = (valid == 1) ? vmcol : vel_count;
assign dot_mem_addr = ((video_mem_data - 8'h41) << 4) + ((my_va[iter] - 1) & 15);

assign end_flag = (va == 480) & (ha == 640);
assign begin_flag = (va == 1) & (ha == 1);

assign vgadata = {24{dot_mem_data[color_addr]}};
	
assign iter = (ha - 1) / 9;	
assign vmrow = (my_va[iter] - 1) / 16;
assign vmcol = (ha - 1) / 9;

assign ready = vgadata == 24'hffffff;
assign wr_ready = video_mem[vmdata_wraddr] == 0;

assign velocity_mem_addr = vel_count;
assign off = (wr_iter != 0) ? offset[wr_iter] : 32;

assign video_mem_wraddr = reset ? reset_addr : (vmdelete_wren ? wr_iter : vmdata_wraddr);
assign video_mem_wren = (vmdelete_wren & end_flag) | (vmdata_wren & begin_flag & v_count == 7) | reset;
assign video_mem_wrdata = (vmdelete_wren || reset) ? 0 : vmdata_wr;

assign velocity_mem_wraddr = video_mem_wraddr;
assign velocity_mem_wren = vmdata_wren & begin_flag;
assign velocity_mem_wrdata = veldata_wr;

endmodule