LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

--Logic of the bouncy bird

ENTITY flappy_bird IS
	PORT
		(SIGNAL pb1, pb2, clk, vert_sync	      			: IN std_logic;
		 SIGNAL reset, pause    			      			: IN std_logic;
       SIGNAL pixel_row, pixel_column	      			: IN std_logic_vector(9 DOWNTO 0);
		 SIGNAL mode                 			   			: IN std_logic_vector(1 downto 0);
		 SIGNAL score0_out, score1_out, score2_out 	   : OUT std_logic_vector(5 downto 0);
		 SIGNAL hit													: OUT std_logic := '0';
		 SIGNAL text_on, bird_on, pipe_on 					: OUT std_logic);		
END flappy_bird;

architecture behavior of flappy_bird is

--Adds a char_rom component which imports the mif file, used to display the score and lives remaining
COMPONENT char_rom is
	PORT 
		(character_address	: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock						: IN STD_LOGIC ;
		rom_mux_output			: OUT STD_LOGIC);
end COMPONENT char_rom;

COMPONENT pipe_move is
	port
		(clk, vert_sync, reset, pause		: IN std_logic;
		score										: IN integer range 0 to 999;
		mode										: IN std_logic_vector(1 DOWNTO 0);
		pixel_row, pixel_column				: IN std_logic_vector(9 DOWNTO 0);
		x_pos_1, x_pos_2 			 			: OUT std_logic_vector(10 DOWNTO 0);
		topHeight_1, bottomHeight_1 		: OUT integer;
	   topHeight_2, bottomHeight_2 		: OUT integer;
		pipe_on									: OUT std_logic);	
end COMPONENT pipe_move;

component bird_move is
	port
		(clk, vert_sync, reset, pause				: IN std_logic;
		pb1, pb2											: IN std_logic;
      pixel_row, pixel_column						: IN std_logic_vector(9 DOWNTO 0);
		pipe_x_pos_1, pipe_x_pos_2					: IN std_logic_vector(10 DOWNTO 0);
		topHeight_1, bottomHeight_1 				: IN integer range 0 to 480;
	   topHeight_2, bottomHeight_2 				: IN integer range 0 to 480;
		mode												: IN std_logic_vector(1 DOWNTO 0);
		score0_out, score1_out, score2_out		: OUT std_logic_vector(5 DOWNTO 0);
		lives_out										: OUT std_logic_vector(5 DOWNTO 0);
		score_out												: OUT integer range 0 to 999;
		bird_on, hit, rst_out						: OUT std_logic);
end component bird_move;

SIGNAL score_text_out        	: std_logic := '0';
SIGNAL score_text            	: std_logic_vector(5 downto 0);
SIGNAL score0, score1, score2 : std_logic_vector(5 downto 0) := "110000";
SIGNAL score						: integer range 0 to 999 := 0;

SIGNAL lives_text_out : std_logic := '0';
SIGNAL lives_text     : std_logic_vector(5 downto 0); 
SIGNAL lives          : std_logic_vector(5 downto 0) := "110011";

SIGNAL text_x_pos : std_logic_vector(10 DOWNTO 0);
SIGNAL text_y_pos : std_logic_vector(9 DOWNTO 0);
SIGNAL text_size  : std_logic_vector(9 DOWNTO 0);

SIGNAL pipe_x_pos_1 : std_logic_vector(10 DOWNTO 0);
SIGNAL pipe_x_pos_2 : std_logic_vector(10 DOWNTO 0);

SIGNAL topHeight_1, bottomHeight_1 	: integer range 0 to 480;
SIGNAL topHeight_2, bottomHeight_2 	: integer range 0 to 480;
SIGNAL rst1, rst2      	  	: std_logic := '0';

BEGIN

-- determines when and where to display the score 
text_on <= '1' when (score_text_out = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(158,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(14,10) 
					and pixel_row <= CONV_STD_LOGIC_VECTOR(30,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(16,10)) or
					(lives_text_out = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(128,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(14,10) 
					and pixel_row <= CONV_STD_LOGIC_VECTOR(45,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(30,10))
					else 
					'0';

-- prints "SCORE:sss" where s is the score value
score_text <= CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(30,10) else -- "S"
				CONV_STD_LOGIC_VECTOR(3,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(54,10) else    -- "C"
				CONV_STD_LOGIC_VECTOR(15,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(62,10) else   -- "O"
				CONV_STD_LOGIC_VECTOR(18,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(78,10) else 	 -- "R"
				CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(94,10) else    -- "E"
				CONV_STD_LOGIC_VECTOR(45,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(110,10) else  -- "-"
				score0 when pixel_column <= CONV_STD_LOGIC_VECTOR(126,10) else                       -- "#"
				score1 when pixel_column <= CONV_STD_LOGIC_VECTOR(143,10) else                       -- "#"
				score2 when pixel_column <= CONV_STD_LOGIC_VECTOR(158,10) else                       -- "#"
				"101111";
			
--Prints the number of lives remaining			
lives_text <= CONV_STD_LOGIC_VECTOR(12,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(30,10) else -- "L"
				CONV_STD_LOGIC_VECTOR(9,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(45,10) else -- "I"
				CONV_STD_LOGIC_VECTOR(22,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(62,10) else -- "V"
				CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(78,10) else -- "E"
				CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(94,10) else -- "S"
				CONV_STD_LOGIC_VECTOR(45,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(110,10) else -- "-"
				lives when pixel_column <= CONV_STD_LOGIC_VECTOR(126,10) else -- "#"
				"101111";

--	Assigns port map and instantiates these components	
textscore: char_rom port map (score_text, pixel_row(3 downto 1), pixel_column(3 downto 1), clk, score_text_out);
textlives: char_rom port map (lives_text, pixel_row(3 downto 1), pixel_column(3 downto 1), clk, lives_text_out);

rst1 <= rst2 or reset;

pipe: pipe_move port map (clk, vert_sync, rst1, pause, score, mode, pixel_row, pixel_column, pipe_x_pos_1, 
                      pipe_x_pos_2, topHeight_1, bottomHeight_1, topHeight_2, bottomHeight_2, pipe_on);
bird: bird_move port map (clk, vert_sync, reset, pause, pb1, pb2, pixel_row, pixel_column, pipe_x_pos_1, 
                      pipe_x_pos_2, topHeight_1, bottomHeight_1, topHeight_2, bottomHeight_2, mode, score0, score1, score2, lives, score, bird_on, hit, rst2);

score0_out <= score0;
score1_out <= score1;
score2_out <= score2;

END behavior;

