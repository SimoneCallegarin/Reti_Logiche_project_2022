library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity project_reti_logiche is
   port(
    i_clk     : in  std_logic;                                                                                               
    i_start   : in  std_logic;                                                                                             
    i_rst     : in  std_logic;                                                                               
    i_data    : in  std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);           
    o_done    : out std_logic;                                                                                        
    o_en      : out std_logic;                                                                           
    o_we      : out std_logic;                                                                                          
    o_data    : out std_logic_vector (7 downto 0) 
   );
end project_reti_logiche;
 
architecture FSM of project_reti_logiche is
 
    type state_type is (
    STARTING_STATE,
    MEM_NUMBER_OF_WORDS_SETUP, 
    ACCESS_MEM_NUMBER_OF_WORDS,
    READING_NUMBER_OF_WORDS,
    MEM_WORD_SETUP, 
    ACCESS_MEM_WORD,
    READING_WORD,
    S00,
    S01,
    S10,
    S11,
    CONVOLUTION_END,
    WRITING_MEM1,
    WRITING_MEM2,
    END_STATE
    ); 
  
    signal next_state, current_state                            : state_type;
    signal count_reg, count_next                                : integer range 0 to 15 := 0;             
    signal n_word_reg, n_word_next                              : std_logic_vector(7 downto 0)  := "00000000"; 
    signal word_reg, word_next                                  : std_logic_vector(7 downto 0)  := "00000000"; 
    signal out_word_reg, out_word_next                          : std_logic_vector(15 downto 0) := "0000000000000000"; 
    signal output_address_reg, output_address_next              : std_logic_vector(15 downto 0) := "0000000000000000"; 
    signal input_address_reg, input_address_next                : std_logic_vector(15 downto 0) := "0000000000000000";
    signal o_address_next                                       : std_logic_vector(15 downto 0) := "0000000000000000";  
    signal done                                                 : std_logic                     := '0';          
    signal enable                                               : std_logic                     := '0';             
    signal write                                                : std_logic                     := '0';             
    signal dout                                                 : std_logic_vector(7 downto 0)  := "00000000";
 
begin
   
registers_process : process(i_clk, i_rst) 
    begin
        if (i_rst = '1') then
        
            count_reg               <= 0;
            n_word_reg              <= "00000000";
            word_reg                <= "00000000";
            out_word_reg            <= "0000000000000000";
            output_address_reg      <= "0000000000000000";
            input_address_reg       <= "0000000000000000";
            
        elsif rising_edge(i_clk) then 
        
            o_address               <= o_address_next;
            o_done                  <= done;
            o_en                    <= enable;
            o_we                    <= write;
            o_data                  <= dout;
            
            count_reg               <= count_next;
            n_word_reg              <= n_word_next;
            word_reg                <= word_next;
            out_word_reg            <= out_word_next;
            output_address_reg      <= output_address_next;
            input_address_reg       <= input_address_next;
        
            current_state           <= next_state;
            
        end if;
end process;
 
outputs_process : process(current_state, i_data, i_start, count_reg, n_word_reg, word_reg, out_word_reg, output_address_reg, input_address_reg)
    begin
    
        o_address_next              <= "0000000000000000";
        done                        <= '0';
        enable                      <= '0';
        write                       <= '0';
        dout                        <= "00000000";
    
        count_next                  <= count_reg;
        n_word_next                 <= n_word_reg;
        word_next                   <= word_reg;
        out_word_next               <= out_word_reg;
        output_address_next         <= output_address_reg;
        input_address_next          <= input_address_reg;
        

        case current_state is
        
        
            when STARTING_STATE => 
                if (i_start = '1') then 
                    enable                  <= '1'; 
                    write                   <= '0';
                    output_address_next     <= "0000001111100111";  --999 in binario
                    o_address_next          <= input_address_reg;   --"0000000000000000"
                end if;
        
        
            when MEM_NUMBER_OF_WORDS_SETUP => 
                    enable                  <= '1'; 
                    write                   <= '0';
                    
    
            when ACCESS_MEM_NUMBER_OF_WORDS => 
                    enable                  <= '1';  
                    n_word_next             <= i_data;
                    input_address_next      <= std_logic_vector(unsigned(input_address_reg)+1);
                    o_address_next          <= input_address_reg;
                    
                
            when READING_NUMBER_OF_WORDS => 
                if (n_word_reg = "00000000") then 
                    done                    <= '1';
                else 
                    enable                  <= '1'; 
                    write                   <= '0'; 
                    o_address_next          <= input_address_reg;
                end if;
                
                
            when MEM_WORD_SETUP => 
                enable                  <= '1'; 
                write                   <= '0';
                o_address_next          <= input_address_reg;
                
                
            when ACCESS_MEM_WORD => 
                enable                  <= '1'; 
                write                   <= '0';
                word_next               <= i_data;
                o_address_next          <= input_address_reg;

                             
            when READING_WORD =>  --potrei rimuoverlo!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    enable                  <= '0'; 
                    write                   <= '0';
                    o_address_next          <= input_address_reg;
                                  
                    
            when S00 => 
                if(word_reg(count_reg)='0') then
                    out_word_next           <= std_logic_vector(shift_left(unsigned(out_word_reg), 2) + "0000000000000000");
                    count_next              <= count_reg + 1;
                else
                    out_word_next           <= std_logic_vector(shift_left(unsigned(out_word_reg), 2) + "0000000000000011");
                    count_next              <= count_reg + 1;
                end if; 
        
  
            when S01 => 
                if(word_reg(count_reg)='0') then
                    out_word_next           <= std_logic_vector(shift_left(unsigned(out_word_reg), 2) + "0000000000000011");
                    count_next              <= count_reg + 1;
                else
                    out_word_next           <= std_logic_vector(shift_left(unsigned(out_word_reg), 2) + "0000000000000000");
                    count_next              <= count_reg + 1;
                end if;                      
 
 
            when S10 => 
                if(word_reg(count_reg)='0') then
                    out_word_next           <= std_logic_vector(shift_left(unsigned(out_word_reg), 2) + "0000000000000001");
                    count_next              <= count_reg + 1;
                else
                    out_word_next           <= std_logic_vector(shift_left(unsigned(out_word_reg), 2) + "0000000000000010");
                    count_next              <= count_reg + 1;
                end if;
                
                
            when S11 =>
                if(word_reg(count_reg)='0') then
                    out_word_next           <= std_logic_vector(shift_left(unsigned(out_word_reg), 2) + "0000000000000010");
                    count_next              <= count_reg + 1;
                else
                    out_word_next           <= std_logic_vector(shift_left(unsigned(out_word_reg), 2) + "0000000000000001");
                    count_next              <= count_reg + 1;
                end if;
                                
 
            when CONVOLUTION_END => 
                enable                      <= '1'; 
                write                       <= '1';
                output_address_next         <= std_logic_vector(unsigned(output_address_reg)+1);
                o_address_next              <= output_address_next;
                dout(0)                     <= out_word_reg(0);
                dout(1)                     <= out_word_reg(1);
                dout(2)                     <= out_word_reg(2);
                dout(3)                     <= out_word_reg(3);
                dout(4)                     <= out_word_reg(4);
                dout(5)                     <= out_word_reg(5); 
                dout(6)                     <= out_word_reg(6);
                dout(7)                     <= out_word_reg(7);
                word_next                   <= "00000000";  
                n_word_next                 <= std_logic_vector(unsigned(n_word_reg)-1);
                    
                    
            when WRITING_MEM1 => 
                enable                      <= '1'; 
                write                       <= '1';
                output_address_next         <= std_logic_vector(unsigned(output_address_reg)+1);
                dout(0)                     <= out_word_reg(8);
                dout(1)                     <= out_word_reg(9);
                dout(2)                     <= out_word_reg(10);
                dout(3)                     <= out_word_reg(11);
                dout(4)                     <= out_word_reg(12);
                dout(5)                     <= out_word_reg(13); 
                dout(6)                     <= out_word_reg(14);
                dout(7)                     <= out_word_reg(15);
                
                
            when WRITING_MEM2 => 
                if (n_word_reg = "00000000") then 
                    done                    <= '1';
                else  
                    enable                  <= '1';
                    write                   <= '0'; 
                    out_word_next           <= "0000000000000000";
                    count_next              <= 0;
                    dout                    <= "00000000";
                end if; 
  
                
            when END_STATE => 
                if (i_start = '0') then 
                    enable          <= '0'; 
                    write           <= '0';
                    done            <= '0';
                    input_address_next   <= "0000000000000000";
                    output_address_next  <= "0000000000000000";
                else  
                    enable          <= '0';
                    write           <= '0';
                    done            <= '1';
                    input_address_next   <= "0000000000000000";
                    output_address_next  <= "0000000000000000";
                end if;       
                       
                        
            when others =>
                enable              <= '0';
                write               <= '0';
                done                <= '1';
                dout                <= "00000000";
                
                
    end case;
end process;
 
  
next_state_process : process(current_state, i_start, count_reg, n_word_reg, word_reg) 
    begin
        case current_state is
 
 
            when STARTING_STATE => 
                if (i_start = '1') then
                    next_state <= MEM_NUMBER_OF_WORDS_SETUP ;
                else 
                    next_state <= STARTING_STATE;
                end if;
 
            
            when MEM_NUMBER_OF_WORDS_SETUP =>
                next_state <= ACCESS_MEM_NUMBER_OF_WORDS; 
            
 
            when  ACCESS_MEM_NUMBER_OF_WORDS => 
                next_state <= READING_NUMBER_OF_WORDS; 
 
 
            when READING_NUMBER_OF_WORDS =>  
                if (n_word_reg = "00000000") then 
                    next_state <= END_STATE;
                else
                    next_state <= MEM_WORD_SETUP;
                end if;
 
 
            when MEM_WORD_SETUP =>
                next_state <= ACCESS_MEM_WORD;
 
 
            when ACCESS_MEM_WORD =>
                next_state <= READING_WORD;
           
           
            when READING_WORD =>
                next_state <= S00;
           
           
            when S00 =>  
                if (count_reg = 15) then 
                    next_state <= CONVOLUTION_END;
                else
                    if(word_reg(count_reg)='0') then
                        next_state <= S00;
                    else
                        next_state <= S10;
                    end if;
                end if;
            
            
            when S10 =>  
                if (count_reg = 15) then 
                    next_state <= CONVOLUTION_END;
                else
                    if(word_reg(count_reg)='0') then
                       next_state <= S01;
                    else
                       next_state <= S11;
                    end if;
                end if;
               
                
            when S11 =>  
                if (count_reg = 15) then 
                    next_state <= CONVOLUTION_END;
                else
                    if(word_reg(count_reg)='0') then
                        next_state <= S01;
                    else
                        next_state <= S11;
                    end if;
                end if;
                
                
            when S01 =>  
                if (count_reg = 15) then 
                    next_state <= CONVOLUTION_END;
                else
                    if(word_reg(count_reg)='0') then
                        next_state <= S00;
                    else
                        next_state <= S10;
                    end if;
                end if;
                
                
            when CONVOLUTION_END =>
                next_state <= WRITING_MEM1;
            
            
            when WRITING_MEM1 =>
                next_state <= WRITING_MEM2;
                
                
            when WRITING_MEM2 =>
                if (n_word_reg = "00000000") then 
                    next_state <= END_STATE;
                else
                    next_state <= READING_NUMBER_OF_WORDS;    
                end if;
             
             
            when END_STATE => 
                if (i_start = '0') then
                    next_state <= STARTING_STATE;
                else
                    next_state <= END_STATE;
                end if;
                       
                        
            when others => 
                next_state <= STARTING_STATE; 
 
 
        end case;
    end process;
 
end FSM;