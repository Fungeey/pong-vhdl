library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Pong is
   Port(
      clk : in std_logic;
      SW0 : in std_logic;
      SW1 : in std_logic;
      SW2 : in std_logic;
      SW3 : in std_logic;

      Rout : out std_logic_vector(7 downto 0);
      Gout : out std_logic_vector(7 downto 0);
      Bout : out std_logic_vector(7 downto 0);

      H : out std_logic;
      V : out std_logic;
      DAC_CLK : out std_logic
   );
end Pong;

architecture Behavioral of Pong is
   -- SIGNALS
   signal R : std_logic_vector(7 downto 0);
   signal G : std_logic_vector(7 downto 0);
   signal B : std_logic_vector(7 downto 0);

   signal Hsync : std_logic;
   signal Vsync : std_logic;
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

   horizontalSync: process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then

         Hsync <= '0';
      end if;
   end process;

   verticalSync: process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then

         Vsync <= '0';
      end if;
   end process;

   video : process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         video_on <= '1';
         --if(hpos <= HD and vpos <= VD) then
         --end if;
      end if;
   end process;

   draw: process(pxl_clk)
   begin

      -- if outside screen, must output 1111111
      -- else, display colors

      --if(pxl_clk'event and pxl_clk = '1') then
         --if(video_on = '1') then
            R <= "00000000";
            G <= "11111111";
            B <= "00000000";

            -- board

            -- paddle 1

            -- paddle 2

         --end if;
      --end if;
   end process;

   -- put signals to outputs
   Rout <= R;
   Gout <= G;
   Bout <= B;
   H <= Hsync;
   V <= Vsync;
   DAC_CLK <= pxl_clk;
   
end Behavioral;