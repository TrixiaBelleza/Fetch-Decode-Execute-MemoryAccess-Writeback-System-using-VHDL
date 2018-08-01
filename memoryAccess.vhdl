LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all; 

entity memoryAccess is
    port(a: in std_logic;
        b: out std_logic);
end memoryAccess;

architecture behav of memoryAccess is 

begin
    process(a)
        begin
        	if (a = '0') then
        		report "not accessing";
        	else
	            report "start accessing";
	            b <= '1';
	            report "end accessing";
	        end if;
        end process;
end behav;