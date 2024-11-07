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
   constant SCREEN_W : integer := HD + HFP + HSP + HBP; -- 800

   constant VD : integer := 480;    -- screen height
   constant VFP : integer := 10;    -- vertical front porc      
   constant VSP : integer := 2;     -- vertical sync pulse
   constant VBP : integer := 33;    -- vertical back porch
   constant SCREEN_H : integer := VD + VFP + VSP + VBP; -- 525
   
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

   -- borders
   constant BORDER : integer := 10;
   constant MARGIN : integer := 25;

   -- player signals
   constant PADDLE_SPD : integer := 1;
   constant PADDLE_WIDTH : integer := 10;
   constant PADDLE_HEIGHT : integer := 100;
   constant P1_X : integer := 50;   -- initialize these
   constant P2_X : integer := 590;   -- initialize these

   signal p1_y : integer := VD/2; --VD/2
   signal p2_y : integer := VD/2;

   constant BALL_SPD : integer := 4;

   signal ball_dir_x : integer := 1;   -- -1 or 1
   signal ball_dir_y : integer := 1;   -- -1 or 1
   signal ball_x : integer := HD/2;
   signal ball_y : integer := VD/2;

   signal movementTick : std_logic;
   signal movCounter : integer := 0;

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

   moveDelay: process(pxl_clk)
   begin
      movCounter <= movCounter + 1;

      if(movCounter >= 90000) then
         movementTick <= '1';
         movCounter <= 0;
      else
         movementTick <= '0';
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

   HVSync: process(pxl_clk)
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

   video : process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         if(hpos <= HD and vpos <= VD) then
            video_on <= '1';
         else
            video_on <= '0';
         end if;
      end if;
   end process;

   game: process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1') then
         -- sw2: pause switch
         -- and SW2 = '1'

         if(movementTick = '1') then

            -- sw1: player 1
            if(SW3 = '1' and p1_y >= MARGIN+BORDER + PADDLE_HEIGHT/2) then
               p1_y <= p1_y - PADDLE_SPD;
            elsif(SW3 = '0' and p1_y <= VD-MARGIN-BORDER- PADDLE_HEIGHT/2) then
               p1_y <= p1_y + PADDLE_SPD;
            end if;

            -- sw2: player 2
            if(SW0 = '1' and p2_y >= 43) then
               p2_y <= p2_y - PADDLE_SPD;
            elsif(SW0 = '0' and p2_y + PADDLE_HEIGHT <= 440) then
               p2_y <= p2_y + PADDLE_SPD;
            end if;
         end if;

         -- ball movement
         -- add checks for walls
         ball_x <= ball_x + BALL_SPD * ball_dir_x;
         ball_y <= ball_y + BALL_SPD * ball_dir_y;

         -- ball_dir_y <= ball_dir_y * -1




         --sw2: reset
         if(SW2'event and SW2 = '1') then
            -- reset variables
            p1_y <= VD/2;
            p2_y <= VD/2;
            ball_x <= HD/2;
            ball_y <= VD/2;
         end if;

      end if;
   end process;

   draw: process(pxl_clk)
   begin
      if(pxl_clk'event and pxl_clk = '1' and video_on = '1') then
         if(hpos > HD or vpos > VD) then
            -- all 1s = white in the porch
            -- if outside screen, must output 1111111
            -- else, display colors
            R <= "00000000";
            G <= "00000000";
            B <= "00000000";
         elsif(hpos >= MARGIN and hpos <= HD-MARGIN and
         ((vpos >= MARGIN and vpos <= MARGIN + BORDER) or
         (vpos >= VD-MARGIN-BORDER and vpos <= VD-MARGIN))) then
            -- horizontal borders
            R <= "11111111";
            G <= "11111111";
            B <= "11111111";
         elsif(((hpos >= MARGIN and hpos <= MARGIN + BORDER) or (hpos >= 604 and hpos <= 615)) and
         ((vpos >= 34 and vpos <= 112) or (vpos >= 370 and vpos <= 446))) then
            -- vertical borders
            R <= "11111111";
            G <= "11111111";
            B <= "11111111";
         elsif(hpos >= HD/2-2 and hpos <= HD/2+2 and (vpos mod 64 >= 32) and vpos >= 45 and vpos <= 435) then
         -- black middle line
            R <= "00000000";
            G <= "00000000";
            B <= "00000000";
         elsif(hpos >= P1_X-PADDLE_WIDTH/2 and hpos <= P1_X+PADDLE_WIDTH/2 and vpos >= p1_y - PADDLE_HEIGHT/2 and vpos <= p1_y + PADDLE_HEIGHT/2) then
         -- player 1
            R <= "00000000";
            G <= "00000000";
            B <= "11111111";
         elsif(hpos >= P2_X-PADDLE_WIDTH/2 and hpos <= P2_X+PADDLE_WIDTH/2 and vpos >= p2_y - PADDLE_HEIGHT/2 and vpos <= p2_y + PADDLE_HEIGHT/2) then
            -- player 2
            R <= "11111111";
            G <= "00000000";
            B <= "11111111";
         else
            R <= "00000000";
            G <= "11111111";
            B <= "00000000";
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