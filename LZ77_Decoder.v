module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output  			encode;
output  			finish;
output 	 	[7:0] 	char_nxt;

assign encode = 0;

reg finish, tmp_finish, set, tmp_set;
reg [2:0] len, tmp_len;
reg [7:0] char_nxt;
reg [3:0] nxt;
reg [6:0] pos;
reg [35:0] search_buffer;

always @(posedge clk) begin
    if(reset) begin
		set <= 1'b1;
		len <= 3'b0;
      	finish <= 1'b0;
		char_nxt <= 8'b0;
		search_buffer <= 36'b0;
    end
    else begin
        finish <= tmp_finish;
        char_nxt <= {4'b0, nxt};

		set <= tmp_set;
		search_buffer <= {search_buffer, nxt};
		
		if(tmp_len != 0)
	    	len <= tmp_len - 1;
		else
	    	len <= tmp_len;
    end
end

always @(*) begin
	if(chardata==8'h24 && tmp_len==0) begin
		tmp_finish = 1;
	end
	else begin
		tmp_finish = 0;
	end

	if(set == 1)
		tmp_len = code_len;
	else 
		tmp_len = len;
	
    pos = (code_pos+1)*4 - 1;

    if(tmp_len == 0) begin
        nxt[0] = chardata[0];
        nxt[1] = chardata[1];
        nxt[2] = chardata[2];
        nxt[3] = chardata[3];
		tmp_set = 1;
	end

    else begin
        nxt[3] = search_buffer[pos];
        nxt[2] = search_buffer[pos-1];
        nxt[1] = search_buffer[pos-2];
        nxt[0] = search_buffer[pos-3];
		tmp_set = 0;
    end
end


endmodule