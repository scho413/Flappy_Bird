LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;
USE IEEE.NUMERIC_STD.all;
USE IEEE.MATH_REAL.all;

ENTITY pipe_move IS
	PORT
		(clk, vert_sync, reset, pause		: IN std_logic;
		score										: IN integer range 0 to 999;
		mode										: IN std_logic_vector(1 DOWNTO 0);
		pixel_row, pixel_column				: IN std_logic_vector(9 DOWNTO 0);
		x_pos_1, x_pos_2 			 			: OUT std_logic_vector(10 DOWNTO 0);
		topHeight_1, bottomHeight_1 		: OUT integer;
	   topHeight_2, bottomHeight_2 		: OUT integer;
		pipe_on									: OUT std_logic);		
END pipe_move;

architecture behavior of pipe_move is
	component LFSR is
		port
			(clk : in std_logic;
			reset : in std_logic;
			output : out std_logic_vector(8 downto 0));
	end component;
	SIGNAL LFSR_reset					: std_logic := '0';
	SIGNAL randomNumber				: std_logic_vector(8 downto 0) := CONV_STD_LOGIC_VECTOR(200, 9);
	
	SIGNAL middle_length 			: integer := 75;	
	
	SIGNAL pipe_width 				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(35,10);

	SIGNAL pipe_center_1       	: integer range 99 to 356 := 200;
	SIGNAL pipe_center_2       	: integer range 99 to 356 := 255;

	SIGNAL pipe_y_pos					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,10);
	SIGNAL pipe_x_pos_1				: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(640,11);
	SIGNAL pipe_x_pos_2				: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(960,11);

	SIGNAL height1_1					: integer := pipe_center_1 - middle_length;
	SIGNAL height2_1 					: integer := pipe_center_1 + middle_length;
	SIGNAL height1_2 					: integer := pipe_center_2 - middle_length;
	SIGNAL height2_2 					: integer := pipe_center_2 + middle_length;
	
	SIGNAL pipe_x_motion 			: std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(2,11);

BEGIN
rand: LFSR port map (clk, LFSR_reset, randomNumber);

pipe_on <= '1' when ((('0' & pipe_x_pos_1 <= '0' & pixel_column + pipe_width) and ('0' & pixel_column <= '0' & pipe_x_pos_1 + pipe_width))
		and ((('0' & pipe_y_pos <= pixel_row) and ('0' & pixel_row <= height1_1)) 
		or ((height2_1 <= pixel_row) and ('0' & pixel_row <= CONV_STD_LOGIC_VECTOR(480,10)))))
		or
		((('0' & pipe_x_pos_2 <= '0' & pixel_column + pipe_width) and ('0' & pixel_column <= '0' & pipe_x_pos_2 + pipe_width))
		and ((('0' & pipe_y_pos <= pixel_row) and ('0' & pixel_row <= height1_2)) 
		or ((height2_2 <= pixel_row) and ('0' & pixel_row <= CONV_STD_LOGIC_VECTOR(480,10)))))
		else '0';


Move_Pipe: process (vert_sync, LFSR_reset, mode, pause)
	variable level_val	: integer range 1 to 10 := 1;
	variable level_score	: integer range 10 to 990 := 10;
	variable flag			: std_logic := '1';
begin
	if(reset = '1') then
		pipe_x_pos_1 <= CONV_STD_LOGIC_VECTOR(640,11);
		pipe_x_pos_2 <= CONV_STD_LOGIC_VECTOR(960,11);
		pipe_x_motion <= CONV_STD_LOGIC_VECTOR(2,11);
		level_val := 1;
		level_score := score + 10;
		pipe_center_1 <= 200;
		pipe_center_2 <= 255;
		
	elsif(rising_edge(vert_sync) and pause = '0') then
			-- practice mode pipe movement logic, difficulty levels remain the same
		if (mode = "01") then -- practice mode	
		
			pipe_x_pos_1 <= pipe_x_pos_1 - pipe_x_motion;
			pipe_x_pos_2 <= pipe_x_pos_2 - pipe_x_motion;
		
			if (pipe_x_pos_1 <= CONV_STD_LOGIC_VECTOR(0,11)) then
				pipe_x_pos_1 <= CONV_STD_LOGIC_VECTOR(640,11);
				pipe_center_1 <= CONV_INTEGER(randomNumber);
			end if;
		
			if (pipe_x_pos_2 <= CONV_STD_LOGIC_VECTOR(0,11)) then
				pipe_x_pos_2 <= CONV_STD_LOGIC_VECTOR(640,11);
				pipe_center_2 <= CONV_INTEGER(randomNumber);
			end if;
			
			--	single mode pipe movement logic, difficulty increases every 10 pipes.
		elsif (mode = "10") then --single mode	
	
			pipe_x_pos_1 <= pipe_x_pos_1 - pipe_x_motion;
			pipe_x_pos_2 <= pipe_x_pos_2 - pipe_x_motion;
			
			if (pipe_x_pos_1 <= CONV_STD_LOGIC_VECTOR(0,11)) then
				pipe_x_pos_1 <= CONV_STD_LOGIC_VECTOR(640,11);
				pipe_center_1 <= CONV_INTEGER(randomNumber);
			end if;
		
			if (pipe_x_pos_2 <= CONV_STD_LOGIC_VECTOR(0,11)) then
				pipe_x_pos_2 <= CONV_STD_LOGIC_VECTOR(640,11);
				pipe_center_2 <= CONV_INTEGER(randomNumber);
			end if;
			
			-- Speed of the pipe movement increase as level increases
			if(score = level_score and level_val < 9) then
				level_val := level_val + 1;
				level_score := level_score + 10;
				pipe_x_motion <= pipe_x_motion + CONV_STD_LOGIC_VECTOR(1,11);
			end if;
		end if;
	end if;
end process Move_Pipe;	
topHeight_1 <= height1_1;
topHeight_2 <= height1_2;
bottomHeight_1 <= height2_1;
bottomHeight_2 <= height2_2;
x_pos_1 <= pipe_x_pos_1;
x_pos_2 <= pipe_x_pos_2;
END behavior;
