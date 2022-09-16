library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity game_fsm is
port (
		clk, reset, PB1, PB2, SW_pause : in std_logic; 
		hit : in std_logic;
		game_reset, game_pause : out std_logic;
		mode : out std_logic_vector(1 downto 0)
		);
		
end entity;

architecture fsm of game_fsm is
-- FSM signals
type state_type is (s_menu, s_single, s_practice, s_over);
signal state, next_state : state_type := s_menu;

begin

	--synchronously move to next state
	sync_proc : process(clk, reset) 
	begin
		if (reset = '1') then
			state <= s_menu;
		elsif (rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;

	--asynchronously decide next state based only on current state and inputs
	next_states_fn: process(state, PB1, PB2, SW_pause, hit) 
	begin
		case(state) is
			when s_menu =>
				if (PB1 = '0' and PB2 = '1') then
					next_state <= s_practice;
				elsif (PB1 = '0' and PB2 = '0') then
					next_state <= s_single;
				else
					next_state <= s_menu;
				end if;
				
			when s_practice =>
				if (hit = '1') then 
					next_state <= s_over;
				elsif (reset = '1') then 
					next_state <= s_menu;	
				else
					next_state <= s_practice;
				end if;
				
			when s_single =>
				if (hit = '1') then 
					next_state <= s_over;
				elsif (reset = '1') then 
					next_state <= s_menu;
				else
					next_state <= s_single;
				end if;
				
			when s_over =>
				if (reset = '1') then
					next_state <= s_menu;
				else 
					next_state <= s_over;
				end if;
				
		end case;
		game_pause <= SW_pause;
	end process;
	
	-- Determines the outputs depending on the state
	outputs:process(state)
		begin
			case state is
				when s_menu =>
					game_reset <= '1';
					mode <= "00";
				when s_practice =>
					game_reset <= '0';
					mode <= "01";
				when s_single =>
					game_reset <= '0';
					mode <= "10";
				when s_over =>
					game_reset <= '0';
					mode <= "11";
			end case;
		end process;
end architecture fsm;