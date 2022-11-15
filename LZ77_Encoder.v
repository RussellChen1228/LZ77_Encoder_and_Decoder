module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output  			valid;
output  			encode;
output  			finish;
output 		[3:0] 	offset;
output 		[2:0] 	match_len;
output 	 	[7:0] 	char_nxt;

assign encode = 1'b1;

wire [1:0] signal;
wire [3:0] tmp_offset, max_offset;
wire [7:0] nxt;
wire [2:0] max_len;


Control control(
	.clk(clk),
	.rst(reset),
	.chardata(chardata),
	.tmp_offset(tmp_offset),
	.max_offset(max_offset),
	.max_len(max_len),
	.nxt(nxt),
	.currentstate(signal),
	.valid(valid),
	.finish(finish),
	.offset(offset),
	.match_len(match_len),
	.char_nxt(char_nxt)
);

Compare compare(
	.clk(clk),
	.signal(signal),
	.chardata(chardata),
	.nxt(nxt),
	.tmp_offset(tmp_offset),
	.max_len(max_len),
	.max_offset(max_offset)
);
endmodule


module Control(clk,rst,chardata,tmp_offset,max_offset,max_len,nxt,currentstate,valid,finish,offset,match_len,char_nxt);
	input clk, rst;
	input [2:0] max_len;
	input [7:0] chardata, nxt;
	input [3:0] tmp_offset, max_offset;

	output finish, valid;
	output [3:0] offset;
	output [7:0] char_nxt;
	output [2:0] match_len;
	output [1:0] currentstate;

	reg finish, valid;
	reg [3:0] offset;
	reg [7:0] char_nxt;
	reg	[2:0] match_len;
	reg [1:0] currentstate, nextstate;
    
	parameter [1:0] inputstate = 0 , countstate = 1, outputstate = 2, finishstate = 3;

	always @(posedge clk) begin
		if(rst)
			currentstate <= inputstate;
		else
			currentstate <= nextstate;
	end
	always @(*) begin
		case (currentstate)
			inputstate: begin
				if (chardata != 8'h24)
					nextstate = inputstate;
				else 
					nextstate = countstate;
			end
			countstate: begin
				if (tmp_offset < 9)
					nextstate = countstate;
				else
					nextstate = outputstate;
			end
			outputstate: begin
				if(nxt != 8'h24)
					nextstate = countstate;
				else
					nextstate = finishstate;
			end
			finishstate: 
				nextstate = finishstate;
		endcase
	end
	always @(currentstate) begin
		case(currentstate)
			inputstate: begin
				valid = 1'b0;
				finish = 1'b0;
				offset = 4'b0;
				match_len = 3'b0;
				char_nxt = 8'b0;
			end
			countstate: begin
				valid = 1'b0;
				finish = 1'b0;
				offset = offset;
				match_len = match_len;
				char_nxt = char_nxt;
			end
			outputstate: begin
				valid = 1'b1;
				finish = 1'b0;
				offset = max_offset;
				match_len = max_len;
				char_nxt = nxt;
			end
			finishstate: begin
				valid = 1'b0;
				finish = 1'b1;
				offset = offset;
				match_len = match_len;
				char_nxt = char_nxt;
			end
		endcase
	end
endmodule

module Compare (clk, signal, chardata, nxt, max_len, tmp_offset, max_offset);
	input clk;
	input [1:0] signal;
	input [7:0] chardata;

	output [7:0] nxt;
	output [2:0] max_len;
	output [3:0] tmp_offset, max_offset;
	
	reg equal;
	reg [2:0] len, max_len;
	reg [3:0] tmp_offset, max_offset, offset;
	reg [7:0] nxt;
	reg [14:0] search_pos, look_pos, max_pos;
	reg [8199:0] char_buffer;

	// signal = 0: inputstate 
	// signal = 1: countstate
	// signal = 2: outputstate
	// sugnal = 3: finishstate
	always @(posedge clk) begin
		case (signal)
			0: begin
				if (chardata != 8'h24)
					char_buffer <= {char_buffer, chardata[3:0]};
				else
					char_buffer <= {char_buffer, chardata};
				len <= 0;
				tmp_offset <= 0;
				look_pos <= 8167;
				search_pos <= 8163;
			end
			1: begin
				if (equal) begin
					len <= len + 1;
					look_pos <= look_pos - 4;
					search_pos <= search_pos - 4;
				end
				else begin
					len <= 0;
					look_pos <= 8163;
					tmp_offset <= tmp_offset + 1;
					search_pos <= 8167 + ((offset+1)<<2);
				end
			end
			2: begin
				char_buffer <= char_buffer << ((max_len+1)<<3);
				len <= 0;
				tmp_offset <= 0;
				look_pos <= 8163;
				search_pos <= 8167;
			end
			3: begin
				len <= 0;
				tmp_offset <= 0;
				look_pos <= 8163;
				search_pos <= 8167;
			end
		endcase
	end
	always @(*) begin
			if(signal == 1) begin
				if(char_buffer[search_pos-:4] == char_buffer[look_pos-:4] && len < 7)
					equal = 1;
				else begin
					equal = 0;
					if (len >= max_len && len > 0) begin
						max_len = len;
						max_pos = look_pos;
						max_offset = tmp_offset;
					end
					else begin
						max_len = max_len;
						max_pos = max_pos;
						max_offset = max_offset;
					end
					nxt = char_buffer[max_pos-: 4];
					offset = tmp_offset;
				end
			end
			else begin
				max_len = 0;
				max_offset = 0;
				max_pos = 8163;
			end
	end
	
endmodule