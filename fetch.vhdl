LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all; 

entity fetch is
    port(a: in std_logic;
        b: out std_logic);
end fetch;

architecture behav of fetch is 

begin
    process(a)
        begin
        	if (a = '0') then
        		report "not fetching";
        	else
	            report "start fetching";
	            b <= '1';
	            report "end fetching";
	        end if;
        end process;
end behav;