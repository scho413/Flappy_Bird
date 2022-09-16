LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

ENTITY bird_move IS
	PORT
		(clk, vert_sync, reset, pause				: IN std_logic;
		pb1, pb2											: IN std_logic;
      pixel_row, pixel_column						: IN std_logic_vector(9 DOWNTO 0);
		pipe_x_pos_1, pipe_x_pos_2					: IN std_logic_vector(10 DOWNTO 0);
		topHeight_1, bottomHeight_1 				: IN integer range 0 to 480;
	   topHeight_2, bottomHeight_2 				: IN integer range 0 to 480;
		mode												: IN std_logic_vector(1 DOWNTO 0);
		score0_out, score1_out, score2_out		: OUT std_logic_vector(5 DOWNTO 0);
		lives_out										: OUT std_logic_vector(5 DOWNTO 0);
		score_out										: OUT integer range 0 to 999;
		bird_on, hit, rst_out						: OUT std_logic);
END bird_move;

architecture behavior of bird_move is

COMPONENT char_rom is
	PORT
	(
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC
	);
end COMPONENT char_rom;

SIGNAL size 						: std_logic_vector(9 DOWNTO 0);  
SIGNAL bird_y_pos					: std_logic_vector(9 DOWNTO 0);
SiGNAL bird_x_pos					: std_logic_vector(10 DOWNTO 0);
SIGNAL bird_y_motion				: std_logic_vector(9 DOWNTO 0) := -CONV_STD_LOGIC_VECTOR(5,10);
SIGNAL score0, score1, score2 : std_logic_vector(5 downto 0) := "110000";
SIGNAL lives          			: std_logic_vector(5 downto 0) := "110011";
SIGNAL isHit						: std_logic := '0';
SIGNAL rst 							: std_logic := '0';
SIGNAL score						: integer range 0 to 999 := 0;
SIGNAL bird_out  					: STD_LOGIC := '0';
SIGNAL bird_graph   				: std_logic_vector(5 downto 0); 

BEGIN           
--bird Parameters
size <= CONV_STD_LOGIC_VECTOR(16,10);
-- bird_x_pos and bird_y_pos show the (x,y) for the centre of bird
bird_x_pos <= CONV_STD_LOGIC_VECTOR(142,11); --590

bird_on <= '1' when (bird_out = '1' and (('0' & bird_x_pos) <= ('0' & pixel_column) + size) and (('0' & pixel_column) <= ('0' & bird_x_pos) + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and (('0' & bird_y_pos) <= ('0' & pixel_row) + size) and (('0' & pixel_row) <= ('0' & bird_y_pos) + size))  else	-- y_pos - size <= pixel_row <= y_pos + size
			'0';

bird_graph <= CONV_STD_LOGIC_VECTOR(15,6) when (pixel_row <= bird_y_pos and pixel_column <= bird_x_pos) else "100000"; --"O"
bird: char_rom port map (bird_graph, pixel_row(3 downto 1), pixel_column(3 downto 1), clk, bird_out);
			
Move_bird: process (vert_sync, reset, pause) 
variable flag 			: std_logic := '0';
variable counter 		: integer range 0 to 10 := 0;
variable counter2 	: integer range 0 to 10 := 0; 
variable score_check : std_logic := '1';
variable life_score	: integer range 25 to 1000 := 25;
variable life 			: integer range 1 to 3 := 3;

begin
	if(reset = '1') then
		score <= 0;
		score0 <= "110000";
		score1 <= "110000";
		score2 <= "110000";
		lives  <= "110011";
		bird_y_pos <= CONV_STD_LOGIC_VECTOR(100,10);
		bird_y_motion <= -CONV_STD_LOGIC_VECTOR(5,10);
		hit <= '0';
		life := 3;
		isHit <= '0';
		life_score := 25;
		
	elsif(rising_edge(vert_sync) and pause = '0') then
		if (mode = "01" or mode = "10") then
			if (rst = '1') then
				bird_y_pos <= CONV_STD_LOGIC_VECTOR(100,10);
				bird_y_motion <= -CONV_STD_LOGIC_VECTOR(5,10);
				rst <= '0';
				isHit <= '0';
				flag := '0';
			end if;
			
			if(counter2 = 10) then
				bird_y_motion <= bird_y_motion + CONV_STD_LOGIC_VECTOR(3,10); 
			end if;
			
			if(pb1 = '1' and counter < 10) then
				flag := '1';
			end if;
				
			if(flag = '1') then
				bird_y_motion <= -CONV_STD_LOGIC_VECTOR(5,10);
				counter := counter + 2;
				if(counter = 10) then
					flag := '0';
				end if;
			end if;
				
			if (pb1 = '0' and flag = '0') then
				counter := 0;
			end if;
			
			if (((((bird_x_pos + size) >= (pipe_x_pos_1 - 35) and (bird_x_pos - size) <= (pipe_x_pos_1 + 35)) and
				 ((bird_y_pos - size) <= topHeight_1 or (bird_y_pos + size) >= bottomHeight_1)) or
				(((bird_x_pos + size) >= (pipe_x_pos_2 - 35) and (bird_x_pos - size) <= (pipe_x_pos_2 + 35)) and
				 ((bird_y_pos - size) <= topHeight_2 or (bird_y_pos + size) >= bottomHeight_2))) and isHit = '0') then
				isHit <= '1';
			end if;
			
			if (bird_y_pos >= CONV_STD_LOGIC_VECTOR(464, 10)) then
				hit <= '1';
			end if;
			
			if (isHit = '1') then
				if (life > 1) then
					bird_y_pos <= CONV_STD_LOGIC_VECTOR(100,10);
					bird_y_motion <= -CONV_STD_LOGIC_VECTOR(5,10);
					life := life - 1;
					lives <= lives - 1;
					isHit <= '0';
					rst <= '1';
				else 
					hit <= '1';
				end if;
			end if;
			
			if((bird_x_pos <= pipe_x_pos_1 and bird_x_pos <= pipe_x_pos_2) and score_check = '0') then
				score_check := '1';
			end if;
			
			if (mode = "10" and score = life_score and life < 3) then
				life_score := life_score + 25;
				lives <= lives + 1;
				life := life + 1;
			end if;
			if (score = 1000) then
				score <= 0;
				life_score := 25;
			end if;
			
			counter2 := counter2 + 2;
			bird_y_pos <= bird_y_pos + bird_y_motion;
			
			if ((bird_x_pos >= pipe_x_pos_1 or bird_x_pos >= pipe_x_pos_2) and score_check = '1') then
				score <= score + 1;
				score2 <= score2 + 1;
				if(score2 = "111001") then
					score2 <= "110000";
					score1 <= score1 + 1;
					if(score1 = "111001") then
						score1 <= "110000";
						score0 <= score0 + 1;
						if(score0 = "111001") then
							score0 <= "110000";
						end if;
					end if;
				end if;
				score_check := '0';
			end if;
		end if;
	end if;
end process Move_bird;

rst_out <= rst;
lives_out <= lives;
score_out <= score;
score0_out <= score0;
score1_out <= score1;
score2_out <= score2;

END behavior;

