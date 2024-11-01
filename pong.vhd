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
   -- CONSTANTS
   constant HD : integer := 640;    -- screen width
   constant HFP : integer := 16;    -- horizontal front porch
   constant HSP : integer := 96;    -- horizontal sync pulse
   constant HBP : integer := 48;    -- horizontal back porch
   constant SCREEN_W : integer := HD + HFP + HSP + HBP;

   constant VD : integer := 480;    -- screen height
   constant VFP : integer := 10;    -- vertical front porc      
   constant VSP : integer := 2;     -- vertical sync pulse
   constant VBP : integer := 33;    -- vertical back porch
   constant SCREEN_H : integer := VD + VFP + VSP + VBP;
   
   -- clock signals
   signal clk_counter : integer := 0;
   signal pxl_clk : std_logic;

   -- rendering signals
   signal video_on : std_logic;
   signal hsync : std_logic;
   signal vsync : std_logic;
   signal hpos : integer := 0;
   signal vpos : integer := 0;

   signal R : std_logic_vector(7 downto 0);
   signal G : std_logic_vector(7 downto 0);
   signal B : std_logic_vector(7 downto 0);

   -- player signals
   constant PADDLE_SPD : integer := 1;
   constant PADDLE_HEIGHT : integer := 15;
   constant P1_X : integer := 5;   -- initialize these
   constant P2_X : integer := 0;   -- initialize these

   signal p1_y : integer := 240; --VD/2
   signal p2_y : integer := VD/2;

   constant BALL_SPD : integer := 4;

   signal ball_dir_x : integer := 1;   -- -1 or 1
   signal ball_dir_y : integer := 1;   -- -1 or 1
   signal ball_x : integer := HD/2;
   signal ball_y : integer := VD/2;

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

   hvpos: process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         if(hpos >= SCREEN_W) then
            hpos <= 0; -- reset to start of line
           
            if(vpos >= SCREEN_H) then
               vpos <= 0; -- reset to first line
            else
               vpos <= vpos + 1;
            end if;
         else
            hpos <= hpos + 1;
         end if;
      end if;
   end process;

   HVSync: process(pxl_clk, hpos, vpos)
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         if(hpos <= HD + HFP or hpos >= HD + HFP + HSP) then
            hsync <= '1';
         else
            hsync <= '0';
         end if;

         if(vpos <= VD + VFP or vpos >= VD + VFP + VSP) then
            vsync <= '1';
         else
            vsync <= '0';
         end if;
      end if;
   end process;

   video : process(pxl_clk, hpos, vpos)
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         if(hpos <= HD and vpos <= VD) then
            video_on <= '1';
         else
            video_on <= '0';
         end if;
      end if;
   end process;

   game: process(pxl_clk, SW0, SW1, SW2, SW3)
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         -- sw0: pause switch
-- and SW0 = '1'

         -- sw1: player 1
         if(SW1 = '1' and p1_y >= 43) then
            p1_y <= p1_y - PADDLE_SPD;
         elsif(SW1 = '0' and p1_y + PADDLE_HEIGHT <= 440) then
            p1_y <= p1_y + PADDLE_SPD;
         end if;

         -- sw2: player 2
         if(SW2 = '1' and p2_y >= 43) then
            p2_y <= p2_y - PADDLE_SPD;
         elsif(SW2 = '0' and p2_y + PADDLE_HEIGHT <= 440) then
            p2_y <= p2_y + PADDLE_SPD;
         end if;

         -- ball movement
         -- add checks for walls
         ball_x <= ball_x + BALL_SPD * ball_dir_x;
         ball_y <= ball_y + BALL_SPD * ball_dir_y;

         -- ball_dir_y <= ball_dir_y * -1



         --sw3: reset
         if(SW3'event and SW3 = '1') then
            -- reset variables
         end if;

      end if;
   end process;

   draw: process(pxl_clk, video_on, hpos, vpos, p1_y)
   begin
      if(pxl_clk'event and pxl_clk = '1' and video_on = '1') then
         -- if outside screen, must output 1111111
         -- else, display colors



         -- edges
         --if(hpos >= 25 and hpos <= 615 and ((vpos >= 34 and vpos <= 45) or (vpos >= 435 and vpos <= 446))) then
         if(hpos > HD or vpos > VD) then
         -- all 1s = black in the porch
            R <= "11111111";
            G <= "11111111";
            B <= "11111111";
         --and (vpos < p1_y + 5 or vpos > p1_y - 5)
         elsif(hpos < 100) then
            R <= "11111111";
            G <= "11111111";
            B <= "11111111";
         elsif(hpos > 100) then
            R <= "11110000";
            G <= "11001111";
            B <= "00001111";
         end if;


         

-- board

         -- paddle 1

         -- paddle 2

         -- ball

      end if;
   end process;

   -- put signals to outputs
   Rout <= R;
   Gout <= G;
   Bout <= B;
   H <= hsync;
   V <= vsync;
   DAC_CLK <= pxl_clk;
   
end Behavioral;