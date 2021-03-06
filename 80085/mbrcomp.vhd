library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mbrcomp is
	port(
		s_t : in std_logic;
		s_c_bus : in std_logic_vector(15 downto 0);
		s_mbr, s_rd, s_wr : in std_logic;
		podaci : buffer std_logic_vector(15 downto 0);
		s_mbr_latch_out : out std_logic_vector(15 downto 0)
	);
end mbrcomp;

architecture Behavioral of mbrcomp is
	signal mbr_latch : std_logic_vector(15 downto 0);
begin
process(s_t)
	variable v_mbr_latch : std_logic_vector(15 downto 0);
	--Mora bit varijabla
begin
	if(s_t = '1') then
		v_mbr_latch := mbr_latch;
		if s_mbr = '1' then
			v_mbr_latch := s_c_bus;
		end if;
		if s_rd = '1' then
			v_mbr_latch := podaci;
		end if;
		if s_wr = '1' then
			podaci <= v_mbr_latch;
		end if;
		s_mbr_latch_out <= v_mbr_latch;
		mbr_latch <= v_mbr_latch;
	end if;
end process;

end Behavioral;

