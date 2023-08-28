library ieee;
use ieee.std_logic_1164.all;

entity infoDisplay is
port( clk, rst : in std_logic;
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
		);
end entity infoDisplay;

architecture controller of infoDisplay is
	constant clk_freq : integer := 50e6; -- The clock frequency of the DE10-Lite is 50 MHz.
	-- Having this constant makes it possible to use it later for computations in seconds.
	
	-- Below are a number of definitions of constants that can be written directly to the seven segment display
	
	constant A : std_logic_vector(6 downto 0) := "0001000";
	constant b : std_logic_vector(6 downto 0) := "0000011";
	constant C : std_logic_vector(6 downto 0) := "1000110";
	constant d : std_logic_vector(6 downto 0) := "0100001";
	constant E : std_logic_vector(6 downto 0) := "0000110";
	constant F : std_logic_vector(6 downto 0) := "0001110";
	constant g : std_logic_vector(6 downto 0) := "0010000";
	constant h : std_logic_vector(6 downto 0) := "0001011";
	constant I : std_logic_vector(6 downto 0) := "1001111";
	constant J : std_logic_vector(6 downto 0) := "1110000";
	constant K : std_logic_vector(6 downto 0) := "0101000";
	constant L : std_logic_vector(6 downto 0) := "1000111";
	constant M1 : std_logic_vector(6 downto 0) := "1001100";
	constant M2 : std_logic_vector(6 downto 0) := "1011000";
	constant N : std_logic_vector(6 downto 0) := "1001000";
	constant O : std_logic_vector(6 downto 0) := "1000000";
	constant P : std_logic_vector(6 downto 0) := "0001100";
	constant Q : std_logic_vector(6 downto 0) := "0011000";
	constant r : std_logic_vector(6 downto 0) := "0101111";
	constant S : std_logic_vector(6 downto 0) := "0010010";
	constant t : std_logic_vector(6 downto 0) := "0000111";
	constant u : std_logic_vector(6 downto 0) := "1000001";
	constant V : std_logic_vector(6 downto 0) := "0101001";
	constant Y : std_logic_vector(6 downto 0) := "0010001";
	
	constant blank	: std_logic_vector(6 downto 0) := "1111111";
	constant dash : std_logic_vector(6 downto 0) := "0111111";
	
	constant zero	: std_logic_vector(6 downto 0) := "1000000";
	constant one	: std_logic_vector(6 downto 0) := "1111001";
	constant two	: std_logic_vector(6 downto 0) := "0100100";
	constant three	: std_logic_vector(6 downto 0) := "0110000";
	constant four	: std_logic_vector(6 downto 0) := "0011001";
	constant five	: std_logic_vector(6 downto 0) := "0010010";
	constant six	: std_logic_vector(6 downto 0) := "0000010";
	constant seven	: std_logic_vector(6 downto 0) := "1111000";
	constant eight	: std_logic_vector(6 downto 0) := "0000000";
	constant nine	: std_logic_vector(6 downto 0) := "0011000";
	
	-- Below is the declaration of states
	
	type state is (reset, s_1, s_2, s_3, s_4, s_5, 
						s_6, s_7, s_8, s_9, s_10,
						s_11, s_12, s_13, s_14, s_15,
						s_16, s_17, s_18, s_19, s_20,
						s_21, s_22, s_23, s_24, s_25,
						s_26, s_27, s_28, s_29, s_30,
						s_31, s_32, s_33, s_34, s_35,
						s_36, s_37, s_38, s_39, s_40,
						s_41, s_42, s_43, s_44, s_45,
						s_46, s_47, s_48, s_49, s_50,
						s_51, s_52, s_53, s_54, s_55,
						s_56, s_57, s_58, s_59, s_60,
						s_61, s_62, s_63, s_64, s_65,
						s_66, s_67, s_68, s_69, s_70,
						s_71, s_72, s_73, s_74, s_75,
						s_76, s_77, s_78, s_79, s_80,
						s_81, s_82, s_83, s_84, s_85,
						s_86, s_87 );
	signal pres_state, next_state : state;
	
	signal clk_1Hz : std_logic;
	
	constant state0_duration : integer := 31;
	constant state1_duration : integer := 2;
	constant state2_duration : integer := 2;
	
begin
	-- Process to create 10Hz clock for use in the program.
	create_1Hz_clk: process(clk, rst)
	variable cnt : integer range 0 to clk_freq := 0;
	begin
		if rst = '0' then
			cnt := 0;
		elsif rising_edge(clk) then
			if cnt >= clk_freq/20 then
				clk_1Hz <= not clk_1Hz;
				cnt := 0;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
	
	
	
	
	-- The FSM below is designed using the process method.
	-- The s_1 process is for ensures that states get updated only on the active clock transitions.
	-- The s_2 process determines holds the rules that governs what the next state to go to is.
	-- Till the s_41 process which governs the output rules.

	-- The s_1 process resets the FSM if an active reset signal is received. Otherwise, on every
	-- active clock transition, it checks what the next state should be and updates the FSM accordingly.
	
	sync_state_tras_1ition: process(clk, rst)
	begin
		if (rst = '0') then
			pres_state <= reset;
		elsif rising_edge(clk) then
			pres_state <= next_state;
		end if;
	end process;
	
	
	
	-- This process controls what the next state will be. Hence, it holds the state transition logic.
	
	state_tras_1ition_logic: process(pres_state, clk_1Hz, rst)
	variable cnt : integer range 0 to 31 := 0;
	begin
		if rst = '0' then
			cnt := 0; -- to ensure that the counter is reset when reset btn is pressed.
			next_state <= reset; -- to ensure that the value in next_state is also changed to reset
			-- if this is not done, the FSM may return to its previous state once the reset
			-- button is released.
		elsif rising_edge(clk_1Hz) then -- this is needed only because this FSM used a counter.
			case pres_state is
				when reset =>
					if cnt >= state0_duration then
						cnt := 0;
						next_state <= s_1;
					else
						cnt := cnt + 1;
						next_state <= reset;
					end if;
				
				
				when s_1 =>
					if cnt >= state1_duration then
						cnt := 0;
						next_state <= s_2;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_2 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_3;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_3 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_4;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_4 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_5;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_5 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_6;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_6 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_7;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_7 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_8;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_8 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_9;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_9 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_10;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_10 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_11;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_11 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_12;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_12 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_13;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_13 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_14;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_14 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_15;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_15 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_16;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_16 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_17;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_17 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_18;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_18 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_19;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_19 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_20;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_20 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_21;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_21 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_22;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_22 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_23;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_23 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_24;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_24 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_25;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_25 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_26;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_26 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_27;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_27 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_28;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_28 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_29;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_29 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_30;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_30 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_31;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_31 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_32;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_32 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_33;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_33 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_34;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_34 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_35;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_35 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_36;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_36 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_37;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_37 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_38;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_38 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_39;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_39 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_40;
					else
						cnt := cnt + 1;
					end if;
				
				
				when s_40 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_41;
					else
						cnt := cnt + 1;
					end if;
				
				when s_41 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_42;
					else
						cnt := cnt + 1;
					end if;
					
				when s_42 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_43;
					else
						cnt := cnt + 1;
					end if;
					
				when s_43 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_44;
					else
						cnt := cnt + 1;
					end if;
					
				when s_44 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_45;
					else
						cnt := cnt + 1;
					end if;
				
				when s_45 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_46;
					else
						cnt := cnt + 1;
					end if;
					
				when s_46 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_47;
					else
						cnt := cnt + 1;
					end if;
				
				when s_47 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_48;
					else
						cnt := cnt + 1;
					end if;
					
				when s_48 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_49;
					else
						cnt := cnt + 1;
					end if;
					
				when s_49 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_50;
					else
						cnt := cnt + 1;
					end if;
					
				when s_50 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_51;
					else
						cnt := cnt + 1;
					end if;
					
				when s_51 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_52;
					else
						cnt := cnt + 1;
					end if;
					
				when s_52 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_53;
					else
						cnt := cnt + 1;
					end if;
					
				when s_53 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_54;
					else
						cnt := cnt + 1;
					end if;
					
				when s_54 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_55;
					else
						cnt := cnt + 1;
					end if;
				
				when s_55 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_56;
					else
						cnt := cnt + 1;
					end if;
					
				when s_56 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_57;
					else
						cnt := cnt + 1;
					end if;
					
				when s_57 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_58;
					else
						cnt := cnt + 1;
					end if;
					
				when s_58 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_59;
					else
						cnt := cnt + 1;
					end if;
					
				when s_59 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_60;
					else
						cnt := cnt + 1;
					end if;
					
				when s_60 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_61;
					else
						cnt := cnt + 1;
					end if;
					
				when s_61 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_62;
					else
						cnt := cnt + 1;
					end if;
					
				when s_62 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_63;
					else
						cnt := cnt + 1;
					end if;
					
				when s_63 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_64;
					else
						cnt := cnt + 1;
					end if;
					
				when s_64 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_65;
					else
						cnt := cnt + 1;
					end if;
					
				when s_65 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_66;
					else
						cnt := cnt + 1;
					end if;
					
				when s_66 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_67;
					else
						cnt := cnt + 1;
					end if;
					
				when s_67 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_68;
					else
						cnt := cnt + 1;
					end if;
					
				when s_68 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_69;
					else
						cnt := cnt + 1;
					end if;
					
				when s_69 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_70;
					else
						cnt := cnt + 1;
					end if;
					
				when s_70 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_71;
					else
						cnt := cnt + 1;
					end if;
					
				when s_71 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_72;
					else
						cnt := cnt + 1;
					end if;
					
				when s_72 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_73;
					else
						cnt := cnt + 1;
					end if;
					
				when s_73 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_74;
					else
						cnt := cnt + 1;
					end if;
					
				when s_74 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_75;
					else
						cnt := cnt + 1;
					end if;
					
				when s_75 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_76;
					else
						cnt := cnt + 1;
					end if;
					
				when s_76 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_77;
					else
						cnt := cnt + 1;
					end if;
					
				when s_77 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_78;
					else
						cnt := cnt + 1;
					end if;
					
				when s_78 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_79;
					else
						cnt := cnt + 1;
					end if;
					
				when s_79 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_80;
					else
						cnt := cnt + 1;
					end if;
					
				when s_80 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_81;
					else
						cnt := cnt + 1;
					end if;
					
				when s_81 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_82;
					else
						cnt := cnt + 1;
					end if;
					
				when s_82 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_83;
					else
						cnt := cnt + 1;
					end if;
					
				when s_83 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_84;
					else
						cnt := cnt + 1;
					end if;
					
				when s_84 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_85;
					else
						cnt := cnt + 1;
					end if;
					
				when s_85 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_86;
					else
						cnt := cnt + 1;
					end if;
				
				when s_86 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_87;
					else
						cnt := cnt + 1;
					end if;
				
				when s_87 =>
					if cnt >= state2_duration then
						cnt := 0;
						next_state <= s_1;
					else
						cnt := cnt + 1;
					end if;
			end case;
		end if;
	end process;
	
	
	
	-- The s_41 process controls the rules that determine the output in each state.
	-- This FSM is designed as a MOORE FSM so the outputs here are only dependent on the present state
	-- Hence, the process sensitivity list only has the present state signal.

	output_logic: process(pres_state)
	begin
		case pres_state is
			when reset =>
				HEX5 <= h;
				HEX4 <= E;
				HEX3 <= L;
				HEX2 <= L;
				HEX1 <= O;
				HEX0 <= blank;
			when s_1 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= t;
				HEX2 <= h;
				HEX1 <= I;
				HEX0 <= s;
			when s_2 =>
				HEX5 <= blank;
				HEX4 <= t;
				HEX3 <= h;
				HEX2 <= I;
				HEX1 <= s;
				HEX0 <= blank;
			when s_3 =>
				HEX5 <= t;
				HEX4 <= h;
				HEX3 <= I;
				HEX2 <= s;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_4 =>
				HEX5 <= h;
				HEX4 <= I;
				HEX3 <= s;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= I;
			when s_5 =>
				HEX5 <= I;
				HEX4 <= s;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= I;
				HEX0 <= S;
			when s_6 =>
				HEX5 <= s;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= I;
				HEX1 <= s;
				HEX0 <= blank;
			when s_7 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= I;
				HEX2 <= s;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_8 =>
				HEX5 <= blank;
				HEX4 <= I;
				HEX3 <= s;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= E;
			when s_9 =>
				HEX5 <= I;
				HEX4 <= s;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= E;
				HEX0 <= E;
			when s_10 =>
				HEX5 <= s;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= E;
				HEX1 <= E;
				HEX0 <= E;
			when s_11 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= E;
				HEX2 <= E;
				HEX1 <= E;
				HEX0 <= blank;
			when s_12 =>
				HEX5 <= blank;
				HEX4 <= E;
				HEX3 <= E;
				HEX2 <= E;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_13 =>
				HEX5 <= E;
				HEX4 <= E;
				HEX3 <= E;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= three;
			when s_14 =>
				HEX5 <= E;
				HEX4 <= E;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= three;
				HEX0 <= zero;
			when s_15 =>
				HEX5 <= E;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= three;
				HEX1 <= zero;
				HEX0 <= eight;
			when s_16 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= three;
				HEX2 <= zero;
				HEX1 <= eight;
				HEX0 <= blank;
			when s_17 =>
				HEX5 <= blank;
				HEX4 <= three;
				HEX3 <= zero;
				HEX2 <= eight;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_18 =>
				HEX5 <= three;
				HEX4 <= zero;
				HEX3 <= eight;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= g;
			when s_19 =>
				HEX5 <= zero;
				HEX4 <= eight;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= g;
				HEX0 <= r;
			when s_20 =>
				HEX5 <= eight;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= g;
				HEX1 <= r;
				HEX0 <= O;
			when s_21 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= g;
				HEX2 <= r;
				HEX1 <= O;
				HEX0 <= u;
			when s_22 =>
				HEX5 <= blank;
				HEX4 <= g;
				HEX3 <= r;
				HEX2 <= O;
				HEX1 <= u;
				HEX0 <= P;
			when s_23 =>
				HEX5 <= g;
				HEX4 <= r;
				HEX3 <= O;
				HEX2 <= u;
				HEX1 <= P;
				HEX0 <= blank;
			when s_24 =>
				HEX5 <= r;
				HEX4 <= O;
				HEX3 <= u;
				HEX2 <= P;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_25 =>
				HEX5 <= O;
				HEX4 <= u;
				HEX3 <= P;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= one;
			when s_26 =>
				HEX5 <= u;
				HEX4 <= p;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= one;
				HEX0 <= zero;
			when s_27 =>
				HEX5 <= P;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= one;
				HEX1 <= zero;
				HEX0 <= blank;
			when s_28 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= one;
				HEX2 <= zero;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_29 =>
				HEX5 <= blank;
				HEX4 <= one;
				HEX3 <= zero;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= P;
			when s_30 =>
				HEX5 <= one;
				HEX4 <= zero;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= P;
				HEX0 <= r;
			when s_31 =>
				HEX5 <= zero;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= P;
				HEX1 <= r;
				HEX0 <= O;
			when s_32 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= P;
				HEX2 <= r;
				HEX1 <= O;
				HEX0 <= J;
			when s_33 =>
				HEX5 <= blank;
				HEX4 <= P;
				HEX3 <= r;
				HEX2 <= O;
				HEX1 <= J;
				HEX0 <= E;
			when s_34 =>
				HEX5 <= P;
				HEX4 <= r;
				HEX3 <= O;
				HEX2 <= J;
				HEX1 <= E;
				HEX0 <= C;
			when s_35 =>
				HEX5 <= r;
				HEX4 <= O;
				HEX3 <= J;
				HEX2 <= E;
				HEX1 <= C;
				HEX0 <= t;
			when s_36 =>
				HEX5 <= O;
				HEX4 <= J;
				HEX3 <= E;
				HEX2 <= C;
				HEX1 <= t;
				HEX0 <= blank;
			when s_37 =>
				HEX5 <= J;
				HEX4 <= E;
				HEX3 <= C;
				HEX2 <= t;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_38 =>
				HEX5 <= E;
				HEX4 <= C;
				HEX3 <= t;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= d;
			when s_39 =>
				HEX5 <= C;
				HEX4 <= t;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= d;
				HEX0 <= O;
			when s_40 =>
				HEX5 <= t;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= d;
				HEX1 <= O;
				HEX0 <= N;
			when s_41 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= d;
				HEX2 <= O;
				HEX1 <= N;
				HEX0 <= E;
			when s_42 =>
				HEX5 <= blank;
				HEX4 <= d;
				HEX3 <= O;
				HEX2 <= N;
				HEX1 <= E;
				HEX0 <= blank;
			when s_43 =>
				HEX5 <= d;
				HEX4 <= O;
				HEX3 <= N;
				HEX2 <= E;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_44 =>
				HEX5 <= O;
				HEX4 <= N;
				HEX3 <= E;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= b;
			when s_45 =>
				HEX5 <= N;
				HEX4 <= E;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= b;
				HEX0 <= Y;
			when s_46 =>
				HEX5 <= E;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= b;
				HEX1 <= Y;
				HEX0 <= blank;
			when s_47 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= b;
				HEX2 <= Y;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_48 =>
				HEX5 <= blank;
				HEX4 <= b;
				HEX3 <= Y;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= F;
			when s_49 =>
				HEX5 <= b;
				HEX4 <= Y;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= F;
				HEX0 <= O;
			when s_50 =>
				HEX5 <= Y;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= F;
				HEX1 <= O;
				HEX0 <= r;
			when s_51 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= F;
				HEX2 <= O;
				HEX1 <= r;
				HEX0 <= t;
			when s_52 =>
				HEX5 <= blank;
				HEX4 <= F;
				HEX3 <= O;
				HEX2 <= r;
				HEX1 <= t;
				HEX0 <= u;
			when s_53 =>
				HEX5 <= F;
				HEX4 <= O;
				HEX3 <= r;
				HEX2 <= t;
				HEX1 <= u;
				HEX0 <= n;
			when s_54 =>
				HEX5 <= O;
				HEX4 <= r;
				HEX3 <= t;
				HEX2 <= u;
				HEX1 <= n;
				HEX0 <= E;
			when s_55 =>
				HEX5 <= r;
				HEX4 <= t;
				HEX3 <= u;
				HEX2 <= n;
				HEX1 <= E;
				HEX0 <= blank;
			when s_56 =>
				HEX5 <= t;
				HEX4 <= u;
				HEX3 <= n;
				HEX2 <= E;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_57 =>
				HEX5 <= u;
				HEX4 <= n;
				HEX3 <= E;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= A;
			when s_58 =>
				HEX5 <= n;
				HEX4 <= E;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= A;
				HEX0 <= S;
			when s_59 =>
				HEX5 <= E;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= A;
				HEX1 <= S;
				HEX0 <= E;
			when s_60 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= A;
				HEX2 <= S;
				HEX1 <= E;
				HEX0 <= P;
			when s_61 =>
				HEX5 <= blank;
				HEX4 <= A;
				HEX3 <= S;
				HEX2 <= E;
				HEX1 <= P;
				HEX0 <= E;
			when s_62 =>
				HEX5 <= A;
				HEX4 <= S;
				HEX3 <= E;
				HEX2 <= P;
				HEX1 <= E;
				HEX0 <= blank;
			when s_63 =>
				HEX5 <= S;
				HEX4 <= E;
				HEX3 <= P;
				HEX2 <= E;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_64 =>
				HEX5 <= E;
				HEX4 <= P;
				HEX3 <= E;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= D;
			when s_65 =>
				HEX5 <= P;
				HEX4 <= E;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= D;
				HEX0 <= A;
			when s_66 =>
				HEX5 <= E;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= D;
				HEX1 <= A;
				HEX0 <= M1;
			when s_67 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= D;
				HEX2 <= A;
				HEX1 <= M1;
				HEX0 <= M2;
			when s_68 =>
				HEX5 <= blank;
				HEX4 <= D;
				HEX3 <= A;
				HEX2 <= M1;
				HEX1 <= M2;
				HEX0 <= O;
			when s_69 =>
				HEX5 <= D;
				HEX4 <= A;
				HEX3 <= M1;
				HEX2 <= M2;
				HEX1 <= O;
				HEX0 <= L;
			when s_70 =>
				HEX5 <= A;
				HEX4 <= M1;
				HEX3 <= M2;
				HEX2 <= O;
				HEX1 <= L;
				HEX0 <= A;
			when s_71 =>
				HEX5 <= M1;
				HEX4 <= M2;
				HEX3 <= O;
				HEX2 <= L;
				HEX1 <= A;
				HEX0 <= blank;
			when s_72 =>
				HEX5 <= M2;
				HEX4 <= O;
				HEX3 <= L;
				HEX2 <= A;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_73 =>
				HEX5 <= O;
				HEX4 <= L;
				HEX3 <= A;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= d;
			when s_74 =>
				HEX5 <= L;
				HEX4 <= A;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= d;
				HEX0 <= A;
			when s_75 =>
				HEX5 <= A;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= d;
				HEX1 <= A;
				HEX0 <= M1;
			when s_76 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= d;
				HEX2 <= A;
				HEX1 <= M1;
				HEX0 <= M2;
			when s_77 =>
				HEX5 <= blank;
				HEX4 <= d;
				HEX3 <= A;
				HEX2 <= M1;
				HEX1 <= M2;
				HEX0 <= I;
			when s_78 =>
				HEX5 <= d;
				HEX4 <= A;
				HEX3 <= M1;
				HEX2 <= M2;
				HEX1 <= I;
				HEX0 <= L;
			when s_79 =>
				HEX5 <= A;
				HEX4 <= M1;
				HEX3 <= M2;
				HEX2 <= I;
				HEX1 <= L;
				HEX0 <= O;
			when s_80 =>
				HEX5 <= M1;
				HEX4 <= M2;
				HEX3 <= I;
				HEX2 <= L;
				HEX1 <= O;
				HEX0 <= L;
			when s_81 =>
				HEX5 <= M2;
				HEX4 <= I;
				HEX3 <= L;
				HEX2 <= O;
				HEX1 <= L;
				HEX0 <= A;
			when s_82 =>
				HEX5 <= I;
				HEX4 <= L;
				HEX3 <= O;
				HEX2 <= L;
				HEX1 <= A;
				HEX0 <= blank;
			when s_83 =>
				HEX5 <= L;
				HEX4 <= O;
				HEX3 <= L;
				HEX2 <= A;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_84 =>
				HEX5 <= O;
				HEX4 <= L;
				HEX3 <= A;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_85 =>
				HEX5 <= L;
				HEX4 <= A;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_86 =>
				HEX5 <= A;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= blank;
			when s_87 =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= blank;
		end case;
	end process;
end architecture controller;