module newfrequency(nowdata,pastdata,dual,off,outfreq);
input [7:0]nowdata;
input [7:0]pastdata;
input dual;
input off;
reg [15:0]freq;
reg [15:0]pfreq;
reg [15:0]finalfreq;
output [15:0]outfreq;
initial
begin
	finalfreq=16'd0;
end
always @ (*)
begin
	if(off==1)
		finalfreq=16'd0;
	else
	begin
		case(nowdata)
			8'h16:freq=16'd357;
			8'h1E:freq=16'd378;
			8'h26:freq=16'd401;
			8'h25:freq=16'd425;
			8'h2E:freq=16'd450;
			8'h36:freq=16'd477;
			8'h3D:freq=16'd505;
			8'h3E:freq=16'd535;
			8'h46:freq=16'd567;
			8'h45:freq=16'd601;
			8'h4E:freq=16'd636;
			8'h55:freq=16'd674;
			default:freq=16'd0;
		endcase
		case(pastdata)
			8'h16:pfreq=16'd357;
			8'h1E:pfreq=16'd378;
			8'h26:pfreq=16'd401;
			8'h25:pfreq=16'd425;
			8'h2E:pfreq=16'd450;
			8'h36:pfreq=16'd477;
			8'h3D:pfreq=16'd505;
			8'h3E:pfreq=16'd535;
			8'h46:pfreq=16'd567;
			8'h45:pfreq=16'd601;
			8'h4E:pfreq=16'd636;
			8'h55:pfreq=16'd674;
			default:pfreq=16'd0;
		endcase
		if(dual)
			finalfreq=(freq+pfreq)/2;
		else
			finalfreq=freq;
	end
end
assign outfreq=finalfreq;
endmodule
