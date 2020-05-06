`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2020 01:15:26 PM
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fir(
    input i_clk,
    input i_clr,
    input i_ce,
    output signed [15:0] res
    );
    
    parameter TAPS = 16;
    wire signed [17:0] i_x_cascade [TAPS-1:0];
    wire signed [47:0] res_cascade [TAPS-1:0];
    wire signed [15:0] i_x;
    wire signed [47:0] o_res;
    
    assign res = o_res[31:15];
    
    rom r0
    (
        .i_clk(i_clk),
        .i_ce(i_ce),
        .i_rst(i_clr),
        .o_data(i_x)
    );
                  
    genvar i;
        
    generate
        for (i = 0; i < TAPS; i = i + 1) begin : loop
            case (i)
                32'd0: begin : START_BLOCK
                       DSP48E1 #(
                                       // Feature Control Attributes: Data Path Selection
                                       .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
                                       .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
                                       .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
                                       .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
                                       .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
                                       // Pattern Detector Attributes: Pattern Detection Configuration
                                       .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
                                       .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
                                       .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
                                       .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
                                       .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
                                       .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
                                       // Register Control Attributes: Pipeline Register Configuration
                                       .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
                                       .ADREG(0),                        // Number of pipeline stages for pre-adder (0 or 1)
                                       .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
                                       .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
                                       .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
                                       .BREG(1),                         // Number of pipeline stages for B (0, 1 or 2)
                                       .CARRYINREG(0),                   // Number of pipeline stages for CARRYIN (0 or 1)
                                       .CARRYINSELREG(0),                // Number of pipeline stages for CARRYINSEL (0 or 1)
                                       .CREG(0),                         // Number of pipeline stages for C (0 or 1)
                                       .DREG(0),                         // Number of pipeline stages for D (0 or 1)
                                       .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
                                       .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
                                       .OPMODEREG(1),                    // Number of pipeline stages for OPMODE (0 or 1)
                                       .PREG(1)                          // Number of pipeline stages for P (0 or 1)
                                    )
                                    DSP48E1_inst (
                                       // Cascade: 30-bit (each) output: Cascade Ports
                                       .ACOUT(),                   // 30-bit output: A port cascade output
                                       .BCOUT(i_x_cascade[i]),                   // 18-bit output: B port cascade output
                                       .CARRYCASCOUT(),     // 1-bit output: Cascade carry output
                                       .MULTSIGNOUT(),       // 1-bit output: Multiplier sign cascade output
                                       .PCOUT(res_cascade[i]),                   // 48-bit output: Cascade output
                                       // Control: 1-bit (each) output: Control Inputs/Status Bits
                                       .OVERFLOW(),             // 1-bit output: Overflow in add/acc output
                                       .PATTERNBDETECT(), // 1-bit output: Pattern bar detect output
                                       .PATTERNDETECT(),   // 1-bit output: Pattern detect output
                                       .UNDERFLOW(),           // 1-bit output: Underflow in add/acc output
                                       // Data: 4-bit (each) output: Data Ports
                                       .CARRYOUT(),             // 4-bit output: Carry output
                                       .P(),                           // 48-bit output: Primary data output
                                       // Cascade: 30-bit (each) input: Cascade Ports
                                       .ACIN({30{1'b0}}),                     // 30-bit input: A cascade data input
                                       .BCIN({18{1'b0}}),                     // 18-bit input: B cascade input
                                       .CARRYCASCIN(1'b0),       // 1-bit input: Cascade carry input
                                       .MULTSIGNIN(1'b0),         // 1-bit input: Multiplier sign input
                                       .PCIN({48{1'b0}}),                     // 48-bit input: P cascade input
                                       // Control: 4-bit (each) input: Control Inputs/Status Bits
                                       .ALUMODE(4'b0000),               // 4-bit input: ALU control input
                                       .CARRYINSEL(3'b000),         // 3-bit input: Carry select input
                                       .CLK(i_clk),                       // 1-bit input: Clock input
                                       .INMODE(5'b10001),                 // 5-bit input: INMODE control input
                                       .OPMODE(7'b0000101),                 // 7-bit input: Operation mode input
                                       // Data: 30-bit (each) input: Data Ports
                                       .A(coef(i)),                           // 30-bit input: A data input
                                       .B({{2{i_x[15]}}, i_x}),                           // 18-bit input: B data input
                                       .C({48{1'b0}}),                           // 48-bit input: C data input
                                       .CARRYIN(1'b0),               // 1-bit input: Carry input signal
                                       .D({25{1'b0}}),                           // 25-bit input: D data input
                                       // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
                                       .CEA1(i_ce),                     // 1-bit input: Clock enable input for 1st stage AREG
                                       .CEA2(1'b0),                     // 1-bit input: Clock enable input for 2nd stage AREG
                                       .CEAD(1'b0),                     // 1-bit input: Clock enable input for ADREG
                                       .CEALUMODE(i_ce),           // 1-bit input: Clock enable input for ALUMODE
                                       .CEB1(i_ce),                     // 1-bit input: Clock enable input for 1st stage BREG
                                       .CEB2(i_ce),                     // 1-bit input: Clock enable input for 2nd stage BREG
                                       .CEC(1'b0),                       // 1-bit input: Clock enable input for CREG
                                       .CECARRYIN(1'b0),           // 1-bit input: Clock enable input for CARRYINREG
                                       .CECTRL(i_ce),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
                                       .CED(1'b0),                       // 1-bit input: Clock enable input for DREG
                                       .CEINMODE(i_ce),             // 1-bit input: Clock enable input for INMODEREG
                                       .CEM(i_ce),                       // 1-bit input: Clock enable input for MREG
                                       .CEP(i_ce),                       // 1-bit input: Clock enable input for PREG
                                       .RSTA(i_clr),                     // 1-bit input: Reset input for AREG
                                       .RSTALLCARRYIN(),   // 1-bit input: Reset input for CARRYINREG
                                       .RSTALUMODE(i_clr),         // 1-bit input: Reset input for ALUMODEREG
                                       .RSTB(i_clr),                     // 1-bit input: Reset input for BREG
                                       .RSTC(1'b0),                     // 1-bit input: Reset input for CREG
                                       .RSTCTRL(i_clr),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
                                       .RSTD(1'b0),                     // 1-bit input: Reset input for DREG and ADREG
                                       .RSTINMODE(i_clr),           // 1-bit input: Reset input for INMODEREG
                                       .RSTM(i_clr),                     // 1-bit input: Reset input for MREG
                                       .RSTP(i_clr)                      // 1-bit input: Reset input for PREG
                                    );
                end
                
                TAPS - 1: begin : END_BLOCK
                                      DSP48E1 #(
                                        // Feature Control Attributes: Data Path Selection
                                        .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
                                        .B_INPUT("CASCADE"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
                                        .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
                                        .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
                                        .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
                                        // Pattern Detector Attributes: Pattern Detection Configuration
                                        .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
                                        .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
                                        .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
                                        .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
                                        .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
                                        .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
                                        // Register Control Attributes: Pipeline Register Configuration
                                        .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
                                        .ADREG(0),                        // Number of pipeline stages for pre-adder (0 or 1)
                                        .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
                                        .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
                                        .BCASCREG(2),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
                                        .BREG(2),                         // Number of pipeline stages for B (0, 1 or 2)
                                        .CARRYINREG(0),                   // Number of pipeline stages for CARRYIN (0 or 1)
                                        .CARRYINSELREG(0),                // Number of pipeline stages for CARRYINSEL (0 or 1)
                                        .CREG(0),                         // Number of pipeline stages for C (0 or 1)
                                        .DREG(0),                         // Number of pipeline stages for D (0 or 1)
                                        .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
                                        .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
                                        .OPMODEREG(1),                    // Number of pipeline stages for OPMODE (0 or 1)
                                        .PREG(1)                          // Number of pipeline stages for P (0 or 1)
                                     )
                                     DSP48E1_inst (
                                        // Cascade: 30-bit (each) output: Cascade Ports
                                        .ACOUT(),                   // 30-bit output: A port cascade output
                                        .BCOUT(),                   // 18-bit output: B port cascade output
                                        .CARRYCASCOUT(),     // 1-bit output: Cascade carry output
                                        .MULTSIGNOUT(),       // 1-bit output: Multiplier sign cascade output
                                        .PCOUT(),                   // 48-bit output: Cascade output
                                        // Control: 1-bit (each) output: Control Inputs/Status Bits
                                        .OVERFLOW(),             // 1-bit output: Overflow in add/acc output
                                        .PATTERNBDETECT(), // 1-bit output: Pattern bar detect output
                                        .PATTERNDETECT(),   // 1-bit output: Pattern detect output
                                        .UNDERFLOW(),           // 1-bit output: Underflow in add/acc output
                                        // Data: 4-bit (each) output: Data Ports
                                        .CARRYOUT(),             // 4-bit output: Carry output
                                        .P(o_res),                           // 48-bit output: Primary data output
                                        // Cascade: 30-bit (each) input: Cascade Ports
                                        .ACIN({30{1'b0}}),                     // 30-bit input: A cascade data input
                                        .BCIN(i_x_cascade[i-1]),                     // 18-bit input: B cascade input
                                        .CARRYCASCIN(1'b0),       // 1-bit input: Cascade carry input
                                        .MULTSIGNIN(1'b0),         // 1-bit input: Multiplier sign input
                                        .PCIN(res_cascade[i-1]),                     // 48-bit input: P cascade input
                                        // Control: 4-bit (each) input: Control Inputs/Status Bits
                                        .ALUMODE(4'b0000),               // 4-bit input: ALU control input
                                        .CARRYINSEL(3'b000),         // 3-bit input: Carry select input
                                        .CLK(i_clk),                       // 1-bit input: Clock input
                                        .INMODE(5'b00001),                 // 5-bit input: INMODE control input
                                        .OPMODE(7'b0010101),                 // 7-bit input: Operation mode input from PCIN
                                        // Data: 30-bit (each) input: Data Ports
                                        .A(coef(i)),                           // 30-bit input: A data input
                                        .B({18{1'b0}}),                           // 18-bit input: B data input
                                        .C({48{1'b0}}),                           // 48-bit input: C data input
                                        .CARRYIN(1'b0),               // 1-bit input: Carry input signal
                                        .D({25{1'b0}}),                           // 25-bit input: D data input
                                        // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
                                        .CEA1(i_ce),                     // 1-bit input: Clock enable input for 1st stage AREG
                                        .CEA2(1'b0),                     // 1-bit input: Clock enable input for 2nd stage AREG
                                        .CEAD(1'b0),                     // 1-bit input: Clock enable input for ADREG
                                        .CEALUMODE(i_ce),           // 1-bit input: Clock enable input for ALUMODE
                                        .CEB1(i_ce),                     // 1-bit input: Clock enable input for 1st stage BREG
                                        .CEB2(i_ce),                     // 1-bit input: Clock enable input for 2nd stage BREG
                                        .CEC(1'b0),                       // 1-bit input: Clock enable input for CREG
                                        .CECARRYIN(1'b0),           // 1-bit input: Clock enable input for CARRYINREG
                                        .CECTRL(i_ce),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
                                        .CED(1'b0),                       // 1-bit input: Clock enable input for DREG
                                        .CEINMODE(i_ce),             // 1-bit input: Clock enable input for INMODEREG
                                        .CEM(i_ce),                       // 1-bit input: Clock enable input for MREG
                                        .CEP(i_ce),                       // 1-bit input: Clock enable input for PREG
                                        .RSTA(i_clr),                     // 1-bit input: Reset input for AREG
                                        .RSTALLCARRYIN(),   // 1-bit input: Reset input for CARRYINREG
                                        .RSTALUMODE(i_clr),         // 1-bit input: Reset input for ALUMODEREG
                                        .RSTB(i_clr),                     // 1-bit input: Reset input for BREG
                                        .RSTC(1'b0),                     // 1-bit input: Reset input for CREG
                                        .RSTCTRL(i_clr),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
                                        .RSTD(1'b0),                     // 1-bit input: Reset input for DREG and ADREG
                                        .RSTINMODE(i_clr),           // 1-bit input: Reset input for INMODEREG
                                        .RSTM(i_clr),                     // 1-bit input: Reset input for MREG
                                        .RSTP(i_clr)                      // 1-bit input: Reset input for PREG
                                     );
                end
                
                default: begin : MIDLE_BLOCK
                                      DSP48E1 #(
                                        // Feature Control Attributes: Data Path Selection
                                        .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
                                        .B_INPUT("CASCADE"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
                                        .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
                                        .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
                                        .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
                                        // Pattern Detector Attributes: Pattern Detection Configuration
                                        .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
                                        .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
                                        .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
                                        .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
                                        .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
                                        .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
                                        // Register Control Attributes: Pipeline Register Configuration
                                        .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
                                        .ADREG(0),                        // Number of pipeline stages for pre-adder (0 or 1)
                                        .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
                                        .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
                                        .BCASCREG(2),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
                                        .BREG(2),                         // Number of pipeline stages for B (0, 1 or 2)
                                        .CARRYINREG(0),                   // Number of pipeline stages for CARRYIN (0 or 1)
                                        .CARRYINSELREG(0),                // Number of pipeline stages for CARRYINSEL (0 or 1)
                                        .CREG(0),                         // Number of pipeline stages for C (0 or 1)
                                        .DREG(0),                         // Number of pipeline stages for D (0 or 1)
                                        .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
                                        .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
                                        .OPMODEREG(1),                    // Number of pipeline stages for OPMODE (0 or 1)
                                        .PREG(1)                          // Number of pipeline stages for P (0 or 1)
                                     )
                                     DSP48E1_inst (
                                        // Cascade: 30-bit (each) output: Cascade Ports
                                        .ACOUT(),                   // 30-bit output: A port cascade output
                                        .BCOUT(i_x_cascade[i]),                   // 18-bit output: B port cascade output
                                        .CARRYCASCOUT(),     // 1-bit output: Cascade carry output
                                        .MULTSIGNOUT(),       // 1-bit output: Multiplier sign cascade output
                                        .PCOUT(res_cascade[i]),                   // 48-bit output: Cascade output
                                        // Control: 1-bit (each) output: Control Inputs/Status Bits
                                        .OVERFLOW(),             // 1-bit output: Overflow in add/acc output
                                        .PATTERNBDETECT(), // 1-bit output: Pattern bar detect output
                                        .PATTERNDETECT(),   // 1-bit output: Pattern detect output
                                        .UNDERFLOW(),           // 1-bit output: Underflow in add/acc output
                                        // Data: 4-bit (each) output: Data Ports
                                        .CARRYOUT(),             // 4-bit output: Carry output
                                        .P(),                           // 48-bit output: Primary data output
                                        // Cascade: 30-bit (each) input: Cascade Ports
                                        .ACIN({30{1'b0}}),                     // 30-bit input: A cascade data input
                                        .BCIN(i_x_cascade[i-1]),                     // 18-bit input: B cascade input
                                        .CARRYCASCIN(1'b0),       // 1-bit input: Cascade carry input
                                        .MULTSIGNIN(1'b0),         // 1-bit input: Multiplier sign input
                                        .PCIN(res_cascade[i-1]),                     // 48-bit input: P cascade input
                                        // Control: 4-bit (each) input: Control Inputs/Status Bits
                                        .ALUMODE(4'b0000),               // 4-bit input: ALU control input
                                        .CARRYINSEL(3'b000),         // 3-bit input: Carry select input
                                        .CLK(i_clk),                       // 1-bit input: Clock input
                                        .INMODE(5'b00001),                 // 5-bit input: INMODE control input
                                        .OPMODE(7'b0010101),                 // 7-bit input: Operation mode input from PCIN
                                        // Data: 30-bit (each) input: Data Ports
                                        .A(coef(i)),                           // 30-bit input: A data input
                                        .B({18{1'b0}}),                           // 18-bit input: B data input
                                        .C({48{1'b0}}),                           // 48-bit input: C data input
                                        .CARRYIN(1'b0),               // 1-bit input: Carry input signal
                                        .D({25{1'b0}}),                           // 25-bit input: D data input
                                        // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
                                        .CEA1(i_ce),                     // 1-bit input: Clock enable input for 1st stage AREG
                                        .CEA2(1'b0),                     // 1-bit input: Clock enable input for 2nd stage AREG
                                        .CEAD(1'b0),                     // 1-bit input: Clock enable input for ADREG
                                        .CEALUMODE(i_ce),           // 1-bit input: Clock enable input for ALUMODE
                                        .CEB1(i_ce),                     // 1-bit input: Clock enable input for 1st stage BREG
                                        .CEB2(i_ce),                     // 1-bit input: Clock enable input for 2nd stage BREG
                                        .CEC(1'b0),                       // 1-bit input: Clock enable input for CREG
                                        .CECARRYIN(1'b0),           // 1-bit input: Clock enable input for CARRYINREG
                                        .CECTRL(i_ce),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
                                        .CED(1'b0),                       // 1-bit input: Clock enable input for DREG
                                        .CEINMODE(i_ce),             // 1-bit input: Clock enable input for INMODEREG
                                        .CEM(i_ce),                       // 1-bit input: Clock enable input for MREG
                                        .CEP(i_ce),                       // 1-bit input: Clock enable input for PREG
                                        .RSTA(i_clr),                     // 1-bit input: Reset input for AREG
                                        .RSTALLCARRYIN(),   // 1-bit input: Reset input for CARRYINREG
                                        .RSTALUMODE(i_clr),         // 1-bit input: Reset input for ALUMODEREG
                                        .RSTB(i_clr),                     // 1-bit input: Reset input for BREG
                                        .RSTC(1'b0),                     // 1-bit input: Reset input for CREG
                                        .RSTCTRL(i_clr),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
                                        .RSTD(1'b0),                     // 1-bit input: Reset input for DREG and ADREG
                                        .RSTINMODE(i_clr),           // 1-bit input: Reset input for INMODEREG
                                        .RSTM(i_clr),                     // 1-bit input: Reset input for MREG
                                        .RSTP(i_clr)                      // 1-bit input: Reset input for PREG
                                     );
                end
            endcase
        end
    endgenerate
    
    
    function signed [29:0] coef;
        input [3:0] ii;
        begin
            case (ii)
                4'd0: coef = 16'd2466;
                4'd1: coef = 16'd6016;
                4'd2: coef = 16'd5521;
                4'd3: coef = -16'd293;
                4'd4: coef = -16'd6332;
                4'd5: coef = -16'd2391;
                4'd6: coef = 16'd12329;
                4'd7: coef = 16'd26409;
                4'd8: coef = 16'd26409;
                4'd9: coef = 16'd12329;
                4'd10: coef = -16'd2391;
                4'd11: coef = -16'd6332;
                4'd12: coef = -16'd293;
                4'd13: coef = 16'd5521;
                4'd14: coef = 16'd6016;
                4'd15: coef = 16'd2466;
            endcase
        end
    endfunction
    
endmodule
