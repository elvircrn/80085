----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:39:23 01/12/2017 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    port (
             clk : in std_logic;
             reset : in std_logic;
             adresa : out std_logic_vector (11 downto 0);
             podaci : inout std_logic_vector (15 downto 0);
             rd : out std_logic;
             wr : out std_logic
         );
end cpu;

architecture Behavioral of cpu is

signal s_rom_out : std_logic_vector (31 downto 0);
signal s_t1, s_t2, s_t3, s_t4 : std_logic;
signal s_amux : std_logic; 
signal s_cond, s_alu, s_sh : std_logic_vector(1 downto 0);
signal s_mbr, s_mar, s_rd, s_wr, s_enc : std_logic;
signal s_c, s_b, s_a : std_logic_vector(3 downto 0);
signal s_mir_adresa : std_logic_vector(7 downto 0);
signal s_a_bus, s_b_bus : std_logic_vector(15 downto 0);
signal s_mpc_out : std_logic_vector(7 downto 0) :=x"00" ;
signal s_mpc_out_inc : std_logic_vector(7 downto 0);
signal s_a_dek_out, s_b_dek_out, s_c_dek_out : std_logic_vector(15 downto 0);
signal s_a_latch, s_b_latch : std_logic_vector(15 downto 0);
signal s_amux_out : std_logic_vector(15 downto 0);
signal s_mbr_latch : std_logic_vector(15 downto 0);
signal s_alu_out : std_logic_vector(15 downto 0);
signal s_z, s_n : std_logic;
signal s_c_bus : std_logic_vector(15 downto 0);
signal s_seq_out : std_logic;
signal s_mmux_out : std_logic_vector(7 downto 0);
signal s_a_decoded : std_logic := '0';
signal s_b_decoded : std_logic := '0';
signal s_c_decoded : std_logic := '0';

component distributer
	port (
	clk, reset : in std_logic;
	t1, t2, t3, t4 : out std_logic
	);
end component;

component ALU
	port(
		x1, x2 : in std_logic_vector(15 downto 0);
		f0, f1 : in std_logic;
		y0 : out std_logic_vector(15 downto 0);
		z, n : out std_logic
	);
end component;

component mircomp
	port(
		s_rom_out : in std_logic_vector (31 downto 0);
		s_amux : out std_logic; 
		s_cond, s_alu, s_sh : out std_logic_vector(1 downto 0);
		s_mbr, s_mar, s_rd, s_wr, s_enc : out std_logic;
		s_c, s_b, s_a : out std_logic_vector(3 downto 0);
		s_mir_adresa : out std_logic_vector(7 downto 0);
		s_t1 : in std_logic
	);
end component;

component ROM256x32
  port ( address : in std_logic_vector(7 downto 0);
         data : out std_logic_vector(31 downto 0) );
end component;

component incrementer
	port (
		a    : in std_logic_vector(7 downto 0);
		ainc : out std_logic_vector(7 downto 0);
		en   : in std_logic
	);
end component;
	

component decoder
	port ( enc : in std_logic_vector(3 downto 0);
			 en  : in std_logic; 
			 dec : out std_logic_vector(15 downto 0);
			 s_decoded : buffer std_logic
	);
end component;

component mseq 
	port(
		cond : in std_logic_vector(1 downto 0);
		n, z : in std_logic;
		seq_out : out std_logic
	);
end component;

component registri
	port (
		a_adr : in std_logic_vector (15 downto 0);
		b_adr : in std_logic_vector (15 downto 0);
		c_adr : in std_logic_vector (15 downto 0);
		enc : in std_logic;
		reset : in std_logic;
		a_bus : out std_logic_vector (15 downto 0);
		b_bus : out std_logic_vector (15 downto 0);
		c_bus : in std_logic_vector (15 downto 0);
		s_a_decoded : in std_logic;
		s_b_decoded : in std_logic;
		s_c_decoded : in std_logic
	);
end component;

component shifter16
	  port ( data_in : in std_logic_vector(15 downto 0);
			s0 : in std_logic;
			s1 : in std_logic;
         data_out : out std_logic_vector(15 downto 0) );
end component;

component hex2u1mux 
port(
        x0, x1 : in std_logic_vector(15 downto 0);
        y0 : out std_logic_vector(15 downto 0);
        c : in std_logic
);
end component;

component oct2to1mux
port(
        x0, x1 : in std_logic_vector(7 downto 0);
        y0 : out std_logic_vector(7 downto 0);
        c : in std_logic
);
end component;

component marcomp
	port (
		s_t3, s_mar : in std_logic;
		s_b_latch : in std_logic_vector(15 downto 0);
		adresa : out std_logic_vector (11 downto 0)
	);
end component;

component ab_latches 
	port(
		s_t : in std_logic;
		s_a_bus, s_b_bus : in std_logic_vector(15 downto 0);
		s_a_latch_out, s_b_latch_out : out std_logic_vector(15 downto 0)
	);
end component; 

component mbrcomp
	port(
		s_t : in std_logic;
		s_c_bus : in std_logic_vector(15 downto 0);
		s_mbr, s_rd, s_wr : in std_logic;
		podaci : inout std_logic_vector(15 downto 0)
	);
end component;

begin

--TODO 
--Provjeriti velicinu mar latcha
--rd i wr <= s_rd i s_wr
--preloadati instrukcije
--izbaciti rising edge i/ili inicijalizirati SVE signale
--dodati mpcreg komponentu i uvezati

--Mapiranje
p_fazni_sat : distributer port map (clk, reset, s_t1, s_t2, s_t3, s_t4);
p_rom : rom256x32 port map (s_mpc_out, s_rom_out);
p_a_dekoder : decoder port map (s_a, '1', s_a_dek_out, s_a_decoded);
p_b_dekoder : decoder port map (s_b, '1', s_b_dek_out, s_b_decoded);
p_c_dekoder : decoder port map (s_c, s_t4, s_c_dek_out, s_c_decoded);
p_alu: alu port map (s_amux_out, s_b_latch, s_alu(0), s_alu(1), s_alu_out, s_z, s_n);
p_sifter: shifter16 port map (s_alu_out, s_sh(1), s_sh(0), s_c_bus);
p_mseq: mseq port map(s_cond, s_n, s_z, s_seq_out);
p_mmux : oct2to1mux port map(s_mpc_out_inc, s_mir_adresa, s_mmux_out, s_seq_out);
p_amux : hex2u1mux port map (s_a_latch, s_mbr_latch, s_amux_out, s_amux);
p_registri : registri port map(s_a_dek_out, s_b_dek_out, s_c_dek_out, s_enc, reset, s_a_bus, s_b_bus, s_c_bus, 
s_a_decoded, s_b_decoded, s_c_decoded);
p_inkrementer : incrementer port map(s_mpc_out, s_mpc_out_inc, s_t2);
p_mir : mircomp port map(s_rom_out, s_amux, s_cond, s_alu, s_sh, s_mbr, s_mar, s_rd, s_wr, s_enc, s_c, s_b, s_a, s_mir_adresa, s_t1);
p_mar : marcomp port map(s_t3, s_mar, s_b_latch, adresa);
p_ab_lecevi : ab_latches port map(s_t2, s_a_bus, s_b_bus, s_a_latch, s_b_latch);
p_mbr : mbrcomp port map(s_t4, s_c_bus, s_mbr, s_rd, s_wr, podaci);

--Ciklus 4
process(s_t4)
begin
 if (s_t4 = '1') then
	s_mpc_out <= s_mmux_out;
 end if;
end process;

end Behavioral;






















