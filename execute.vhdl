LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all; 

entity execute is
	port(a: in std_logic;
        b: out std_logic);
end execute;

architecture behav of execute is 

begin
    process(a)
        begin
        	if (a = '0') then
        		report "not executing";
        	else
	            report "start executing";
	            b <= '1';
	            report "end executing";
	        end if;
        end process;
end behav;