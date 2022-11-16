# LZ77 Encoder and Decoder

LZ77 is a lossless data compression algorithm. 

The document will describe the details of LZ77 Encoder and Decoder. 

Three different image test data are provided to verify the correctness of your design. 

The cycle in the testbench is set as 30 ns.

## Application

**Decoder**
1.	Assign encode = 0 <hr>
2.	Set the set signal = 1 <hr>
  - If set = 1 => tmp_len = code_len
  - Else => tmp_len = tmp_len - 1 
3.  If tmp_len = 0 => char_nxt = chardata and set = 1, Else => pos=[(code_pos+1)*4-1], char_nxt = search_buffer[pos-:4] and set = 0
4.  searchbuffer = {search_buffer, char_nxt}
5.  tmp_len = tmp_len – 1
6.  Repeat the from step2 to step4 until chardata = 8’h24 && tmp_len = 0
7.  finish=1

**Encoder**
- Input state: (finish = 0, valid = 0)
  - finish = 0, valid = 0
  - char buffer = {char buffer, chardata}
  - i=16399, j=16391, length=0, offset=0
  - max length = 0, max offset = 0, max j = 16391;
 
1.	Divided into four statements (input, count , output, finish)
2.	Input state: If chardata != $ => next state = input state
3.	Input state: Else => next state = count state
4.	Count state: If offset < 9  => next state = count state
5.	Count state: Else => next state = output state
6.	Output state: If char_nxt != $ => next state = count state
7.	Output state: Else => next state => finish state
8.	Finish state: Encoder done
