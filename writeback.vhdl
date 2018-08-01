LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all; 

entity writeback is
    port(a: in std_logic;
        b: out std_logic);
end writeback;

architecture behav of writeback is 

begin
    process(a)
        begin
        	if (a = '0') then
        		report "not writing";
        	else
	            report "start writing";
	            b <= '1';
	            report "end writing";
	        end if;
        end process;
end behav;