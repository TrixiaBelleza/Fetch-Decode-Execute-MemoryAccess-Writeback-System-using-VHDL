LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all; 

entity decode is
    port(a: in std_logic;
        b: out std_logic);
end decode;

architecture behav of decode is 

begin
    process(a)
        begin
        	if (a = '0') then
        		report "not decoding";
        	else
	            report "start decoding";
	            b <= '1';
	            report "end decoding";
	        end if;
        end process;
end behav;