library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Pong is
   Port(
      clk : in std_logic,
      SW0 : in std_logic,
      SW1 : in std_logic,
      SW2 : in std_logic,
      SW3 : in std_logic,

      Rout : out std_logic_vector(7 downto 0),
      Gout : out std_logic_vector(7 downto 0),
      Bout : out std_logic_vector(7 downto 0),

      H : out std_logic,
      V : out std_logic,
      DAC_CLK : out std_logic;
   )
end Pong;

architecture Behavioral of Pong is
   -- SIGNALS
   signal _Rout : std_logic_vector(7 downto 0);
   signal _Gout : std_logic_vector(7 downto 0);
   signal _Bout : std_logic_vector(7 downto 0);

   signal _H : std_logic;
   signal _V : std_logic;
   signal pxl_clk : std_logic;

   signal clk_counter : integer := 0;
   signal video_on : std_logic;
   
   -- COMPONENTS
begin
   
   generateClk: process(clk)
   begin
      if(clk'event and clk = '1') then
         clk_counter <= clk_counter + 1;

         if(clk_counter mod 2 = 0) then
            pxl_clk <= '1';
         else 
            pxl_clk <= '0';
         end if;
      end if;
   end process;

   hsync: process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then

         H <= '0';
      end if;
   end process;

   vsync: process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then

         V <= '0';
      end if;
   end process;

   video_on : process(pxl_clk) 
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         video_on <= 1;
         --if(hpos <= HD and vpos <= VD) then
         --end if;
      end if;
   end process;

   draw: process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         if(video_on = '1') then
            _Rout <= '0000000';
            _Gout <= '1111111';
            _Bout <= '0000000';

            -- board

            -- paddle 1

            -- paddle 2

         end if;
      end if;
   end process;

   -- put signals to outputs 
   Rout <= _Rout;
   Gout <= _Gout;
   Bout <= _Bout;
   H <= _H;
   V <= _V;
   DAC_CLK <= pxl_clk;
   
end Behavioral;