LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use STD.textio.all; 

entity project is
end project;

architecture behave of project is
    signal fetchFlag: std_logic;
    signal fetchFlagOut: std_logic;
    signal decodeFlag: std_logic;
    signal decodeFlagOut: std_logic;
    signal executeFlag: std_logic;
    signal executeFlagout: std_logic;
    signal memoryFlag: std_logic;
    signal memoryFlagOut: std_logic;
    signal writebackFlag: std_logic;
    signal writebackFlagOut: std_logic;
    
    signal edge: std_logic;

    signal pc1: std_logic;
    signal pc2: std_logic;
    signal pc3: std_logic;
    signal pc4: std_logic;

    signal overFlow: std_logic;
    signal underFlow: std_logic; 
    signal signF: std_logic;

    constant c_WIDTH : natural := 4;
    --converted instruction to bits
    type instrSet is 
      record
        op: std_logic_vector(2 downto 0);
        r1: std_logic_vector(5 downto 0);
        r2: std_logic_vector(5 downto 0);
        r3: std_logic_vector(5 downto 0);
      end record;
    type linesArray is array (0 to 14) of instrSet;
    --signal instrArray: linesArray;

    --register with its equivalent bits and its value
    type regArray is
      record
        reg: string(3 downto 1);
        bits: std_logic_vector(6 downto 1);
        val : integer;
      end record;
    type registers is array (0 to 35) of regArray;


    type immArray is
      record
        immediateVal: string(2 downto 1);
        bits: std_logic_vector(6 downto 1);
        val: integer;
      end record;
    type immediates is array (0 to 3) of immArray;


    --operand with its equivalent bits
    type opArray is
      record
        operand: string(4 downto 1);
        val: std_logic_vector(3 downto 1);
      end record;
    type operations is array (0 to 5) of opArray;

    --type flagArray is
    --    record
    --        line: integer;
    --        signF: std_logic;
    --        overFlow: std_logic;
    --        underFlow: std_logic;
    --    end record;
    --signal flags is array (0 to 14) of flagArray;

    signal toSign: signed(6 to 1);
    signal toInt: integer;

    -- F D E M W components
    component fetch is
        port(a: in std_logic;
            b: out std_logic);
    end component;  

    component decode is
        port(a: in std_logic;
            b: out std_logic);
    end component;

    component execute is
        port(a: in std_logic;
            b: out std_logic);
    end component;
    
    component memoryAccess is
        port(a: in std_logic;
            b: out std_logic);
    end component;

    component writeback is
        port(a: in std_logic;
            b: out std_logic);
    end component;


begin
    fetchStart: fetch port map(fetchFlag, fetchFlagOut);
    decodeStart: decode port map(decodeFlag, decodeFlagOut);
    executeStart: execute port map(executeFlag, executeFlagOut);
    memoryStart: memoryAccess port map(memoryFlag, memoryFlagOut);
    writebackStart: writeback port map(writebackFlag, writebackFlagOut);
    
    process
        --Read process
        
        file file_pointer : text;
        --variable line_content : string(4 to 9);
        variable operand : string(4 downto 1);
        variable space : character;
        variable reg1 : string(3 downto 1);
        variable space1 : character;
        variable reg2 : string(3 downto 1);
        variable space2 : character;
        variable reg3 : string(3 downto 1);
        variable line_num : line;           --gets the data of the whole line in the input file
        variable linecount : integer;       --counts how many instrArray were read in the input file
        
        variable pc: unsigned(1 downto 0); 

        variable regs: registers;
        variable ops: operations;
        variable imms: immediates;
        variable instrArray: linesArray;

        variable op1: integer;
        variable op2: integer;
        variable answer: integer;
        
    begin

        --Initialization of arrays
        regs := (("000", "000000", 0), ("001", "000001", 1), ("002", "000010", 2), ("003", "000011", 3), ("R00","000100",0), ("R01","000101",0), ("R02","000110",0), ("R03","000111",0), ("R04","001000",0), ("R05","001001",0), ("R06","001010",0), ("R07","001011",0), ("R08","001100",0), ("R09","001101",0), ("R10","001110",0), ("R11","001111",0), ("R12","010000",0), ("R13","010001",0), ("R14","010010",0), ("R15","010011",0), ("R16","010100",0), ("R17","010101",0), ("R18","010110",0), ("R19","010111",0), ("R20","011000",0), ("R21","011001",0), ("R22","011010",0), ("R23","011011",0), ("R24","011100",0), ("R25","011101",0), ("R26","011110",0), ("R27","111111",0), ("R28","100000",0), ("R29","100001",0), ("R30","100010",0), ("R31","100011",0));
        ops := (("LOAD","000"), ("ADDD", "001"), ("SUBT", "010"), ("MULT", "011"), ("DIVD", "100"), ("MODU", "101"));
        answer := 0;
        op1 := 0;
        op2 := 0;
        --flags := ((5,'0','0','0'), (6,'0','0','0'), (7,'0','0','0'), (8,'0','0','0'), (9,'0','0','0'), (10,'0','0','0'), (11,'0','0','0'), (12,'0','0','0'), (13,'0','0','0'), (14,'0','0','0'), (15,'0','0','0'), (16,'0','0','0'), (17,'0','0','0'), (18,'0','0','0'), (19,'0','0','0'))
        
       
        report "fetched: " & ops(0).operand;
        --initialize instruction (converted to bits) array
        --1 kase walang 111 na nagamit 
        for count in 0 to 14 loop
            instrArray(count).op := "111";
            instrArray(count).r1 := "111111";
            instrArray(count).r2 := "111111";
            instrArray(count).r3 := "111111";
        end loop;

        -- FILE READING STARTS HERE
        file_open(file_pointer,"input.txt",READ_MODE);    
        linecount := 0;
        while not endfile(file_pointer) loop --till the end of file is reached continue.
            readline (file_pointer,line_num);  --Read the whole line from the file
                --Read the contents of the line from  the file into a variable.
            READ (line_num,operand); 
            READ (line_num,space); 
            READ (line_num,reg1); 
            READ (line_num,space1); 
            READ (line_num,reg2); 

            overFlow <= '0';
            underFlow <= '0';
            signF <= '0';
            answer := 0;

            if operand = "LOAD" then 
                report operand;
                report reg1;
                report reg2;
                
                --converts the operand to its equivalent bit values and stores to instrArray
                for count in 0 to 5 loop
                    if (operand = ops(count).operand) then
                        instrArray(linecount).op := ops(count).val;
                    end if;
                end loop;

                --converts the registers to its equivalent bit values and stores to instrArray
                for count in 0 to 35 loop
                    if (reg1 = regs(count).reg) then
                        instrArray(linecount).r1 := regs(count).bits; 
                    end if;
                    if (reg2 = regs(count).reg) then
                        instrArray(linecount).r2 := regs(count).bits; 
                    end if;
                end loop;

                --assigns the value of the second register/immediate value to the first reigster
                for count in 0 to 35 loop 
                    if (instrArray(linecount).r2 = regs(count).bits) then
                        for count2 in 0 to 35 loop 
                            if (instrArray(linecount).r1 = regs(count2).bits) then
                                regs(count2).val := regs(count).val;
                                report "LOAD: " & integer'image(regs(count2).val);
                            end if;  
                        end loop;
                    end if;
                end loop;
                

            else  
                READ (line_num,space2); 
                READ (line_num,reg3); 
                report operand;
                report reg1;
                report reg2;
                report reg3;

                    
                 --converts the operand to its equivalent bit values and stores to instrArray
                for count in 0 to 5 loop
                    if (operand = ops(count).operand) then
                        instrArray(linecount).op := ops(count).val;
                    end if;
                end loop;


                  --converts the registers to its equivalent bit values and stores to instrArray
                for count in 0 to 35 loop
                    if (reg1 = regs(count).reg) then
                        instrArray(linecount).r1 := regs(count).bits;
                    end if;
                    if (reg2 = regs(count).reg) then
                        instrArray(linecount).r2 := regs(count).bits;
                    end if;
                    if (reg3 = regs(count).reg) then
                        instrArray(linecount).r3 := regs(count).bits;
                    end if;
                end loop;

                
                --checks for the operand to be used the operation
                if (instrArray(linecount).op = "001") then
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r2 = regs(count).bits) then
                            op1 := regs(count).val;
                        end if;
                    end loop;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r3 = regs(count).bits) then
                            op2 := regs(count).val;
                        end if;
                    end loop;
                    answer := op1 + op2;
                    --stores in the first register
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r1 = regs(count).bits) then
                            regs(count).val := answer;
                            report "ANSWEER: " & integer'image(regs(count).val);
                        end if;  
                    end loop;

                elsif (instrArray(linecount).op = "010") then
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r2 = regs(count).bits) then
                            op1 := regs(count).val;
                        end if;
                    end loop;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r3 = regs(count).bits) then
                            op2 := regs(count).val;
                        end if;
                    end loop;
                    answer := op1 - op2;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r1 = regs(count).bits) then
                            regs(count).val := answer;
                            report "ANSWEER: " & integer'image(regs(count).val);
                        end if;  
                    end loop;

                elsif (instrArray(linecount).op = "011") then
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r2 = regs(count).bits) then
                            op1 := regs(count).val;
                        end if;
                    end loop;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r3 = regs(count).bits) then
                            op2 := regs(count).val;
                        end if;
                    end loop;
                    answer := op1 * op2;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r1 = regs(count).bits) then
                            regs(count).val := answer;
                            report "ANSWEER: " & integer'image(regs(count).val);
                        end if;  
                    end loop;

                elsif (instrArray(linecount).op = "100") then
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r2 = regs(count).bits) then
                            op1 := regs(count).val;
                        end if;
                    end loop;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r3 = regs(count).bits) then
                            op2 := regs(count).val;
                        end if;
                    end loop;
                    answer := op1 / op2;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r1 = regs(count).bits) then
                            regs(count).val := answer;
                            report "ANSWEER: " & integer'image(regs(count).val);
                        end if;  
                    end loop;

                elsif (instrArray(linecount).op = "101") then
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r2 = regs(count).bits) then
                            op1 := regs(count).val;
                        end if;
                    end loop;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r3 = regs(count).bits) then
                            op2 := regs(count).val;
                        end if;
                    end loop;
                    answer := op1 mod op2;
                    for count in 0 to 35 loop 
                        if (instrArray(linecount).r1 = regs(count).bits) then
                            regs(count).val := answer;
                            report "ANSWEER: " & integer'image(regs(count).val);
                        end if;  
                    end loop;
                end if;


                --overflow flag
                if (answer > 3) then
                    overFlow <= '1';
                    report "OVERFLOW";
                end if;

                --underflow flag
                if (answer < -3) then
                   underFlow <= '1';
                    report "UNDERFLOW";
                end if;

                --signflag
                if (answer < 0) then
                    signF <= '1';
                    report "NEGATIVE";
                end if;

            end if;

            --maps the read word OPERAND to its equivalent bits
            for count in 0 to 5 loop --for the operand value
               
                if (operand = ops(count).operand) then          --iterates list of operands and checks if may nag match 
                    
                    instrArray(linecount).op := ops(count).val;      --assign bit values to instruction (converted to bits) array
                    --example if LOAD yung nabasa, kukunin yung bit equivalent then store sa (instrArray -> list of instructions from file)
                end if;
            end loop;

            --maps the read word REGISTER to its equivalent bits
            for count in 0 to 3 loop --for the register value
                if (reg1 = regs(count).reg) then 
                instrArray(linecount).r1 := regs(count).bits;
                end if;
                if (reg2 = regs(count).reg) then 
                instrArray(linecount).r2 := regs(count).bits;
                end if;
                if (operand /= "LOAD") then
                if (reg3 = regs(count).reg) then 
                    instrArray(linecount).r3 := regs(count).bits;
                end if;
                end if;
            end loop;

            --toSign <= signed(instrArray(linecount).r1);
            --toInt <= to_integer(instrArray(linecount).r1);
            --report std_logic(instrArray(linecount).r1);

            linecount := linecount+1;       
        end loop;
        file_close(file_pointer);  --after reading all the instrArray close the file. 
        report integer'image(linecount);    --print linecount

    -- AFTER FILE READING
    -- NAG-OUTPUT SA GTKWAVE

        pc := B"00";    --let pc be a binary type that has two bits
        edge <= '0';   --checks if the edge is rise or fall

        --outputs to GTKWave the switching of f, d, e, m, w flags
        for cycle in 0 to 50 loop

            if (edge = '0')  and (cycle > 1) and (cycle < (linecount*2) +1) then
                fetchFlag <= '1';
            else
                fetchFlag <= '0';
            end if;

            if (edge = '0') and (fetchFlag = '0') and (cycle > 3) and (cycle < (linecount*2)+3) then
                decodeFlag <= '1';
            else
                decodeFlag <= '0';
            end if;

            if (edge = '0') and (decodeFlag = '0') and (cycle > 5) and (cycle < (linecount*2)+5) then
                executeFlag <= '1';

            else
                executeFlag <= '0';
            end if;


            if (edge = '0') and (executeFlag = '0') and (cycle > 7) and (cycle < (linecount*2)+7) then
                memoryFlag <= '1';
            else
                memoryFlag <= '0';
            end if;

            if (edge = '0') and (memoryFlag = '0') and (cycle > 9) and (cycle < (linecount*2)+9) then
                writebackFlag <= '1';
            else
                writebackFlag <= '0';
            end if;
            
            pc := pc + 1;   --increment program counter 
            edge <= pc(0);  --flips every iteration

            wait for 10 ns;
        end loop;

        wait;
    end process;

    process
    variable programCounter: unsigned(3 downto 0);
      
    begin
      programCounter := B"0000";
      for count in 0 to 14 loop
        pc1 <= programCounter(0);
        pc2 <= programCounter(1);
        pc3 <= programCounter(2);
        pc4 <= programCounter(3);
        
        programCounter := programCounter + 1;

        wait for 10 ns;    

        pc1 <= '0';
        pc2 <= '0';
        pc3 <= '0';
        pc4 <= '0';
        
        wait for 10 ns;    

      end loop;

      wait;
  end process;
  
end behave;
