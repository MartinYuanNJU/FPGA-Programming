module processor
input h_addr;
input v_addr;
reg [7:0] rom [2099:0];
integer i;
initial
begin
	for(i=0;i<2100;i=i+1)
	begin
		rom[i]=8'b00000000;
	end
end
