library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

--This is the default state of the FSM

entity menu is
	port(
		SIGNAL clk, vert_sync		      : IN std_logic;
		SIGNAL reset, pause					: IN std_logic;
		SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		SIGNAL menu_text_on, menu_out 	: OUT std_logic	
		);
end menu;

architecture main of menu is

--Adds a char_rom component which imports the mif file of letters and characters
COMPONENT char_rom is
	PORT (
		character_address		:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock						: 	IN STD_LOGIC ;
		rom_mux_output			:	OUT STD_LOGIC
	);
end COMPONENT char_rom;


SIGNAL title_out  	: STD_LOGIC := '0';
SIGNAL single_out  	: STD_LOGIC := '0';
SIGNAL practice_out  : STD_LOGIC := '0';
SIGNAL play_out  		: STD_LOGIC := '0';
SIGNAL reset_out  	: STD_LOGIC := '0';
SIGNAL pause_out  	: STD_LOGIC := '0';

SIGNAL title_text   	: std_logic_vector(5 downto 0); 
SIGNAL single_text 	: std_logic_vector(5 downto 0);
SIGNAL practice_text : std_logic_vector(5 downto 0);
SIGNAL play_text 		: std_logic_vector(5 downto 0);
SIGNAL reset_text 	: std_logic_vector(5 downto 0);
SIGNAL pause_text 	: std_logic_vector(5 downto 0);

begin

-- determines when and where to display our team name 
menu_text_on <= '1' when 
					  (title_out = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(415,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(304,10) 
					  and pixel_row <= CONV_STD_LOGIC_VECTOR(158,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(142,10)) or
					  (single_out = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(500,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(208,10) 
					  and pixel_row <= CONV_STD_LOGIC_VECTOR(254,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(238,10)) or
					  (practice_out = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(500,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(208,10) 
					  and pixel_row <= CONV_STD_LOGIC_VECTOR(286,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(270,10)) or
					  (play_out = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(500,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(208,10) 
					  and pixel_row <= CONV_STD_LOGIC_VECTOR(318,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(302,10)) or
					  (reset_out = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(500,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(208,10) 
					  and pixel_row <= CONV_STD_LOGIC_VECTOR(350,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(334,10)) or
					  (pause_out = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(500,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(208,10) 
					  and pixel_row <= CONV_STD_LOGIC_VECTOR(382,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(366,10))
					  else 
			        '0';

-- print "ONI"
title_text <= CONV_STD_LOGIC_VECTOR(15,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(320,10) else 		--"O"
				CONV_STD_LOGIC_VECTOR(14,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(336,10) else 		--"N"
				CONV_STD_LOGIC_VECTOR(9,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(352,10) else 		--"I"
				"100000";																											--"/ "

-- Prints the game mode selection instruction and play and reset	
single_text <= CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(224,10) else 	--"s"
				  CONV_STD_LOGIC_VECTOR(23,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(240,10) else 		--"w"
				  CONV_STD_LOGIC_VECTOR(48,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(256,10) else 		--"0"
				  CONV_STD_LOGIC_VECTOR(40,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(272,10) else 		--"("
				  CONV_STD_LOGIC_VECTOR(48,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(288,10) else 		--"0"
				  CONV_STD_LOGIC_VECTOR(41,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(304,10) else 		--")"
				  CONV_STD_LOGIC_VECTOR(45,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(320,10) else 		--"-"
				  CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(336,10) else 		--"s"
				  CONV_STD_LOGIC_VECTOR(9,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(352,10) else 		--"i"
				  CONV_STD_LOGIC_VECTOR(14,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(368,10) else 		--"n"
				  CONV_STD_LOGIC_VECTOR(7,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(384,10) else 		--"g"
				  CONV_STD_LOGIC_VECTOR(12,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(400,10) else 		--"l"
				  CONV_STD_LOGIC_VECTOR(5,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(416,10) else 		--"e"
				  "100000";																											--" "	
				  
practice_text <= CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(224,10) else 	--"s"
				  CONV_STD_LOGIC_VECTOR(23,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(240,10) else 		--"w"
				  CONV_STD_LOGIC_VECTOR(48,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(256,10) else 		--"0"
				  CONV_STD_LOGIC_VECTOR(40,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(272,10) else 		--"("
				  CONV_STD_LOGIC_VECTOR(49,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(288,10) else 		--"1"
				  CONV_STD_LOGIC_VECTOR(41,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(304,10) else 		--")"
				  CONV_STD_LOGIC_VECTOR(45,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(320,10) else 		--"-"
				  CONV_STD_LOGIC_VECTOR(16,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(336,10) else 		--"p"
				  CONV_STD_LOGIC_VECTOR(18,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(352,10) else 		--"r"
				  CONV_STD_LOGIC_VECTOR(1,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(368,10) else 		--"a"
				  CONV_STD_LOGIC_VECTOR(3,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(384,10) else 		--"c"
				  CONV_STD_LOGIC_VECTOR(20,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(400,10) else		--"t"
				  CONV_STD_LOGIC_VECTOR(9,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(416,10) else 		--"i"
				  CONV_STD_LOGIC_VECTOR(3,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(432,10) else 		--"c"
				  CONV_STD_LOGIC_VECTOR(5,6)  when pixel_column <= CONV_STD_LOGIC_VECTOR(448,10) else 		--"e"
			 	  "100000";																											--" "
				 
play_text <= CONV_STD_LOGIC_VECTOR(16,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(224,10) else 		--"p"
				  CONV_STD_LOGIC_VECTOR(2,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(240,10) else 		--"b"
				  CONV_STD_LOGIC_VECTOR(50,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(256,10) else 		--"2"
				  CONV_STD_LOGIC_VECTOR(45,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(272,10) else 		--"-"
				  CONV_STD_LOGIC_VECTOR(16,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(288,10) else 		--"p"
				  CONV_STD_LOGIC_VECTOR(12,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(304,10) else 		--"l"
				  CONV_STD_LOGIC_VECTOR(1,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(320,10) else 		--"a"
				  CONV_STD_LOGIC_VECTOR(25,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(336,10) else 		--"y"
				  "100000";																											--" "
				  
reset_text <= CONV_STD_LOGIC_VECTOR(16,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(224,10) else 		--"p"
				  CONV_STD_LOGIC_VECTOR(2,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(240,10) else 		--"b"
				  CONV_STD_LOGIC_VECTOR(48,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(256,10) else 		--"0"
				  CONV_STD_LOGIC_VECTOR(45,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(272,10) else 		--"-"
				  CONV_STD_LOGIC_VECTOR(18,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(288,10) else 		--"r"
				  CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(304,10) else 		--"e"
				  CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(320,10) else 		--"s"
				  CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(336,10) else 		--"e"
				  CONV_STD_LOGIC_VECTOR(20,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(352,10) else 		--"t"
				  "100000";																											--" "
				 
pause_text <= CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(224,10) else 		--"s"
				  CONV_STD_LOGIC_VECTOR(23,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(240,10) else 		--"w"
				  CONV_STD_LOGIC_VECTOR(49,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(256,10) else 		--"1"
				  CONV_STD_LOGIC_VECTOR(45,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(272,10) else 		--"-"
				  CONV_STD_LOGIC_VECTOR(16,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(288,10) else 		--"p"
				  CONV_STD_LOGIC_VECTOR(1,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(304,10) else 		--"a"
				  CONV_STD_LOGIC_VECTOR(21,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(320,10) else 		--"u"
				  CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(336,10) else 		--"s"
				  CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(352,10) else 		--"e"
				  "100000";																											--" "
				  
--	Assigns port map and instantiates these components			 
title: 		char_rom port map (title_text, 		pixel_row(3 downto 1), pixel_column(3 downto 1), clk, title_out);
single: 		char_rom port map (single_text, 		pixel_row(3 downto 1), pixel_column(3 downto 1), clk, single_out);
practice: 	char_rom port map (practice_text,	pixel_row(3 downto 1), pixel_column(3 downto 1), clk, practice_out);
play: 		char_rom port map (play_text, 		pixel_row(3 downto 1), pixel_column(3 downto 1), clk, play_out);
rst: 			char_rom port map (reset_text,		pixel_row(3 downto 1), pixel_column(3 downto 1), clk, reset_out);
pse:			char_rom port map (pause_text,		pixel_row(3 downto 1), pixel_column(3 downto 1), clk, pause_out);

menu_out <= '1';

end architecture main;