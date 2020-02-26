module frequency(signal,off,outfreq);
input [7:0]signal;
input off;
reg [15:0]freq;
output [15:0]outfreq;
initial
begin
	freq=16'd0;
end
always @ (*)
begin
	if(off==1)
		freq=16'd0;
	else
	begin
		case(signal)
			8'h16:freq=16'd523;
			8'h1E:freq=16'd554;
			8'h26:freq=16'd587;
			8'h25:freq=16'd622;
			8'h2E:freq=16'd659;
			8'h36:freq=16'd698;
			8'h3D:freq=16'd740;
			8'h3E:freq=16'd784;
			8'h46:freq=16'd831;
			8'h45:freq=16'd880;
			8'h4E:freq=16'd932;
			8'h55:freq=16'd988;
			default:freq=16'd0;
		endcase
	end
end
assign outfreq=freq;
endmodule
