
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module sound_sample(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

wire clk_i2c;
wire reset;
//implement
wire [15:0] sound_data;//the sound data
wire [7:0] signal;//signal from the board
wire off;//make sound or not
reg [15:0] out_sound;//the out sound data
wire dual;//harmony sound
wire [7:0] psignal;//past data
//end
wire [15:0] audiodata;

//implement
initial
begin
	out_sound=16'd0;
end
//end

//=======================================================
//  Structural coding
//=======================================================

assign reset = ~KEY[0];

audio_clk u1(CLOCK_50, reset,AUD_XCK, LEDR[9]);


//I2C part
clkgen #(10000) my_i2c_clk(CLOCK_50,reset,1'b1,clk_i2c);  //10k I2C clock  


I2C_Audio_Config myconfig(clk_i2c, KEY[0],FPGA_I2C_SCLK,FPGA_I2C_SDAT,LEDR[2:0]);

I2S_Audio myaudio(AUD_XCK, KEY[0], AUD_BCLK, AUD_DACDAT, AUD_DACLRCK, out_sound);

Sin_Generator sin_wave(AUD_DACLRCK, KEY[0], sound_data, audiodata);

//implement
/*ps2board board(
	.clk(CLOCK_50),
	.ps2_clk(PS2_CLK),
	.ps2_data(PS2_DAT),
	.signalOut(signal),
	.offOut(off)
);

frequency frequent(
	.signal(signal),
	.off(off),
	.outfreq(sound_data)
);*/

newps2board board(
	.clk(CLOCK_50),
	.reset(reset),
	.ps2_clk(PS2_CLK),
	.ps2_data(PS2_DAT),
	.nowdataOut(signal),
	.pastdataOut(psignal),
	.offOut(off),
	.dualOut(dual)
);

newfrequency frequent(
	.nowdata(signal),
	.pastdata(psignal),
	.off(off),
	.dual(dual),
	.outfreq(sound_data)
);

always @ (posedge CLOCK_50)
begin
	if(reset)
		out_sound <= 16'd0;
	else
	begin
		case(SW[9:0])
			10'b1111111111:out_sound <= audiodata[15:0];
			10'b0111111111:out_sound <= $signed(audiodata[15:0]) >>> 1;
			10'b0011111111:out_sound <= $signed(audiodata[15:0]) >>> 2;
			10'b0001111111:out_sound <= $signed(audiodata[15:0]) >>> 3;
			10'b0000111111:out_sound <= $signed(audiodata[15:0]) >>> 4;
			10'b0000011111:out_sound <= $signed(audiodata[15:0]) >>> 5;
			10'b0000001111:out_sound <= $signed(audiodata[15:0]) >>> 6;
			10'b0000000111:out_sound <= $signed(audiodata[15:0]) >>> 7;
			10'b0000000011:out_sound <= $signed(audiodata[15:0]) >>> 8;
			10'b0000000001:out_sound <= 16'd0;
			default:out_sound <= out_sound;
		endcase
	end
end
//end

endmodule
