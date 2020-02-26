module new_assign_vgadata(
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
	input reset,
	input v_end,
	output reg [13:0] miss_count,
	input [1:0] mode
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
	reg [4:0] v_count;
	reg [5:0] vm_count;
	
	wire video_mem_wren;
	
	reg mswr_en;
	reg [5:0] mswr_addr;
	
	
	
	wire end_flag;
	wire begin_flag;
	//reg hit_flag;

	
initial
begin
	vm_count = 1;
end


VideoMem_IP video_memory_ip(clk, video_mem_wrdata, video_mem_addr, video_mem_wraddr, video_mem_wren, video_mem_data);

DotMem dot_memory(dot_mem_addr, dot_mem_data);

VelocityMem_IP velocity_mem_ip(clk, velocity_mem_wrdata, velocity_mem_addr, velocity_mem_wraddr, velocity_mem_wren, velocity);

always @ (posedge vga_clk)
begin
	if(reset)
	begin
		hit_count <= 0;
		miss_count <= 0;
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
			/*if(kb_ready)
			begin
				for(i = 0; i < 53; i = i + 1)
				begin
					if(video_mem[i] == kb_data) 
					begin
						if(wr_iter == 0) wr_iter <= i;
						else if(offset[i] - 32 > offset[wr_iter] - 32) wr_iter <= i;
					end
				end
			end else wr_iter <= 0;*/
		

			for(i = 0; i < 53; i = i + 1)
			begin
				if(video_mem[i] != 0)
					offset[i] <= offset[i] - pause * (velocity_mem[i] % 4 + 1);
				if(offset[i][10:1] == 544 || offset[i][10:1] == 543) //offset[i] <= 32;
				begin
					mswr_en <= 1;
					mswr_addr <= i;
				end
			end
		
		end
		
		if(v_end && kb_ready)
		begin
			if(vm_count == 53) vm_count <= 1;
			else
			begin
				if(video_mem[vm_count] == kb_data)
				begin
					if(wr_iter == 0) wr_iter <= vm_count;
					else if(offset[vm_count] - 32 < offset[wr_iter] - 32) wr_iter <= vm_count;
				end
				vm_count <= vm_count + 1;
			end
		end
		else if(v_end && ~kb_ready) wr_iter <= 0;
		
		if(begin_flag)
		begin
			if(video_mem_wren)	offset[video_mem_wraddr] <= 32;
			if(vmdelete_wren) hit_count <= hit_count + 1;
			if(mswr_en)	miss_count <= miss_count + 1;
			v_count <= v_count + 1;
			mswr_en <= 0;
		end
	end
end



assign color_addr = (iter < 53 && my_va[iter] >= 1 && my_va[iter] <= 16) ? (ha - 1) % 9 : 0;
assign video_mem_addr = (valid == 1) ? vmcol : vel_count;
assign dot_mem_addr = ((video_mem_data) << 4) + ((my_va[iter] - 1) & 15);

assign end_flag = (va == 480) & (ha == 640);
assign begin_flag = (va == 1) & (ha == 1);

assign vgadata = dot_mem_data[color_addr] ? 24'hffffff - va * 136 : 24'h363636; //在这里改背景颜色
	
assign iter = (ha - 1) / 9;	
assign vmrow = (my_va[iter] - 1) / 16;
assign vmcol = (ha - 1) / 9;

assign ready = dot_mem_data[color_addr];
assign wr_ready = video_mem[vmdata_wraddr] == 0;

assign velocity_mem_addr = vel_count;
assign off = (wr_iter != 0) ? offset[wr_iter] : 32;

assign video_mem_wraddr = reset ? reset_addr : (vmdelete_wren ? wr_iter : (mswr_en ? mswr_addr : vmdata_wraddr));
assign video_mem_wren = (vmdelete_wren & end_flag) | (vmdata_wren & begin_flag & v_count % (32 - mode * 8) == 0) | reset | (mswr_en & begin_flag);
assign video_mem_wrdata = (vmdelete_wren || reset || mswr_en) ? 0 : vmdata_wr;

assign velocity_mem_wraddr = video_mem_wraddr;
assign velocity_mem_wren = (vmdata_wren & begin_flag & v_count % (32 - mode * 8) == 0);
assign velocity_mem_wrdata = veldata_wr;

endmodule
