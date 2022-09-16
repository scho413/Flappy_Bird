LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

--This is where all the graphics are controlled

ENTITY display IS
	PORT
		(SIGNAL pb1, pb2, clk, vert_sync	: IN std_logic;
		 SIGNAL reset, pause					: IN std_logic;
       SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		 SIGNAL mode            : IN std_logic_vector(1 downto 0);
		 SIGNAL hit 							: OUT std_logic;
		 SIGNAL red, green, blue 			: OUT std_logic_vector(3 DOWNTO 0));		
END display;

architecture behavior of display is


-- Adds the bouncy_bird component where the bird logic is developed
component flappy_bird is
	PORT
		(SIGNAL pb1, pb2, clk, vert_sync	      			: IN std_logic;
		 SIGNAL reset, pause    			      			: IN std_logic;
       SIGNAL pixel_row, pixel_column	      			: IN std_logic_vector(9 DOWNTO 0);
		 SIGNAL mode                 			   : IN std_logic_vector(1 downto 0);
		 SIGNAL score0_out, score1_out, score2_out 	   : OUT std_logic_vector(5 downto 0);
		 SIGNAL hit													: OUT std_logic := '0';
		 SIGNAL text_on, bird_on, pipe_on 					: OUT std_logic);
end component flappy_bird;

-- Adds the menu screen component to allow it to be displayed
component menu is
	port(
		SIGNAL clk, vert_sync		      : IN std_logic;
		SIGNAL reset, pause					: IN std_logic;
		SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		SIGNAL menu_text_on, menu_out 	: OUT std_logic	
		);
end component menu;

-- Adds the game over screen component to allow it to be displayed
component gameover is
    port(
        SIGNAL clk, vert_sync                  : IN std_logic;
        SIGNAL reset, pause                    : IN std_logic;
        SIGNAL pixel_row, pixel_column         : IN std_logic_vector(9 DOWNTO 0);
		  SIGNAL score0, score1, score2 			  : IN std_logic_vector(5 downto 0);
        SIGNAL over_text_on, gameover_out      : OUT std_logic    
        );
end component gameover;

signal bird_text_on, bird_bird_on, bird_pipe_on : std_logic;
signal menu_screen_on, menu_text_on 	   		: std_logic;
signal over_screen_on, over_text_on 	   		: std_logic;
signal player_hit							      		: std_logic;
signal score0_out, score1_out, score2_out 		: std_logic_vector(5 downto 0);

begin

--	Assigns port map and instantiates these components	
game: flappy_bird port map (pb1, pb2, clk, vert_sync, reset, pause, pixel_row, pixel_column, mode, 
                            score0_out, score1_out, score2_out, player_hit, bird_text_on, bird_bird_on, bird_pipe_on);
menu_screen : menu port map (clk, vert_sync, reset, pause, pixel_row, pixel_column, menu_text_on, menu_screen_on);
game_over_screen : gameover port map (clk, vert_sync, reset, pause, pixel_row, pixel_column, score0_out, score1_out, 
												  score2_out, over_text_on, over_screen_on);


select_mode: process (mode)

begin

	--Controls the graphics of the default state (menu) and sets it to blue background, white text
	if (mode = "00") then
		Red   <=  (not(menu_screen_on) or menu_text_on) & "111";
		Green <=  (not(menu_screen_on) or menu_text_on) & "111";
		Blue  <=  (menu_screen_on or menu_text_on) & "111";	
	
	--Controls the graphics of the game over state (gameover) and sets it to red background, white text
	elsif (mode = "11") then
      Red   <=  (over_screen_on) & "111";
      Green <=  (over_text_on) & "111";
      Blue  <=  (not(over_screen_on) or (over_text_on)) & "111";
		
	--Controls the graphics of the game play states (regular and training mode), sets a blue background, white text, green pipes and red bird	
	else
		Red <=  ((bird_text_on or bird_bird_on) and not(bird_pipe_on)) & "111";
		Green <= ((bird_text_on and not(bird_bird_on)) or bird_pipe_on) & "111";
		Blue <=  (not(bird_bird_on) and not(bird_pipe_on)) & "111";
		hit <= player_hit;
		
	end if;
	
end process select_mode;

end architecture behavior;