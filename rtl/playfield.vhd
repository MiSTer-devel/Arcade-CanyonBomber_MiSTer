-- Playfield generation circuitry for Atari Canyon Bomber
-- (c) 2018 James Sweet
--
-- This is free software: you can redistribute
-- it and/or modify it under the terms of the GNU General
-- Public License as published by the Free Software
-- Foundation, either version 3 of the License, or (at your
-- option) any later version.
--
-- This is distributed in the hope that it will
-- be useful, but WITHOUT ANY WARRANTY; without even the
-- implied warranty of MERCHANTABILITY or FITNESS FOR A
-- PARTICULAR PURPOSE. See the GNU General Public License
-- for more details.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity playfield is 
port(   
			clk6				: in		std_logic;
			clk12				: in		std_logic;
			display			: in		std_logic_vector(7 downto 0);
			HCount			: in  	std_logic_vector(8 downto 0);
			VCount			: in  	std_logic_vector(7 downto 0);
			H256_s			: buffer std_logic;
			HBlank			: in		std_logic;
			VBlank			: in		std_logic;
			VBlank_n_s		: in  	std_logic; -- VBLANK* on the schematic	
			HSync				: in		std_logic;
			VSync				: in		std_logic;
			CompSync_n_s	: out 	std_logic; -- COMP SYNC* on schematic
			CompBlank_n_s	: buffer std_logic; -- COMP BLANK* on schematic
			WhitePF_n		: out		std_logic; 
			BlackPF_n		: out		std_logic;
			-- signals that carry the ROM data from the MiSTer disk
			dn_addr        	: in  std_logic_vector(15 downto 0);
			dn_data        	: in  std_logic_vector(7 downto 0);
			dn_wr          	: in  std_logic;
			
			Char_ROM_cs		: in  std_logic
			);
end playfield;

architecture rtl of playfield is

signal H1				: std_logic;
signal H2				: std_logic;
signal H4				: std_logic;
signal H256				: std_logic;
signal H256_n			: std_logic;

signal V1				: std_logic;
signal V2				: std_logic;
signal V4				: std_logic;
signal V128				: std_logic;

signal char_addr		: std_logic_vector(9 downto 0) := (others => '0');
signal char_data		: std_logic_vector(3 downto 0) := (others => '0');

signal shift_data		: std_logic_vector(3 downto 0) := (others => '0');
signal QH				: std_logic;

signal R2_reg			: std_logic_vector(3 downto 0) := (others => '0');

signal H1H2				: std_logic;
signal SL				: std_logic;
signal CompSync_n		: std_logic;
signal CompBlank_n	: std_logic;


signal Display7_s		: std_logic;

begin

-- Video synchronization signals
H1 <= Hcount(0);
H2 <= Hcount(1);
H4 <= Hcount(2);
H256 <= Hcount(8);
H256_n <= not(Hcount(8));

V1 <= Vcount(0);
V2 <= Vcount(1);
V4 <= Vcount(2);
V128 <= Vcount(7);

H1H2 <= (H1 nand H2);
SL <= (not H256_s) or H1H2;


CompSync_n <= (HSync nor VSync);

CompBlank_n <= VBlank nor (HBlank);-- or H256_s and V128));



char_addr <= display(5 downto 0) & V4 & V2 & V1 & (not H4);

-- Background character ROM
--N8: entity work.Char_ROM
--port map(
--	clock => clk6,
--	Address => char_addr,
--	q => char_data
--	);
N8 : work.dpram generic map (10,8)
port map
(
	clock_a   => clk12,
	wren_a    => dn_wr and Char_ROM_cs,
	address_a => dn_addr(9 downto 0),
	data_a    => dn_data,

	clock_b   => clk6,
	address_b => char_addr,
	q_b(3 downto 0)       => char_data
);


-- 74LS195 video shift register	
R3: process(clk6, SL, VBlank_n_s, char_data, shift_data)
begin
	if VBlank_n_s = '0' then -- Connected Clear input
		shift_data <= (others => '0');
	elsif rising_edge(clk6) then 
		if SL = '0' then -- Parallel load
			shift_data <= char_data;
		else
			shift_data <= shift_data(2 downto 0) & '0';
		end if;
	end if;
	QH <= shift_data(3);
end process;


-- 9316 counter at R2
-- CEP and CET tied to ground, counter is used only as a synchronous latch
R2: process(clk6, H1H2, display, H256, CompSync_n, CompBlank_n)
begin
	if rising_edge(clk6) then
		if H1H2 = '0' then
			R2_reg <= (H256 & display(7) & CompBlank_n & CompSync_n);
		end if;
	end if;
end process;


H256_s <= R2_reg(3);
Display7_s <= R2_reg(2);
CompBlank_n_s <= R2_reg(1);
CompSync_n_s <= R2_reg(0);


WhitePF_n <= (QH nand Display7_s);
BlackPF_n <= (not QH) or Display7_s;

end rtl;