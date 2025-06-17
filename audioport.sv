//
//  audioport.sv: Top-level module of audioport design.
//

`include "audioport.svh"

import audioport_pkg::*;

module audioport
  
  (input logic clk,
   input logic 	       rst_n,
   input logic 	       mclk,
   // APB interface
   input logic 	       PSEL,
   input logic 	       PENABLE,
   input logic 	       PWRITE,
   input logic [31:0]  PADDR,
   input logic [31:0]  PWDATA,
   output logic [31:0] PRDATA,
   output logic        PREADY,
   output logic        PSLVERR,
   // Interrupt request
   output logic        irq_out,
   // Audio outputs
   output logic        ws_out,
   output logic        sck_out, 
   output logic        sdo_out,
   // Test signals
   input logic 	       test_mode_in,
   input logic 	       scan_en_in
   );

   /////////////////////////////////////////////////////////////////////////////
   // Internal variables
   /////////////////////////////////////////////////////////////////////////////
   
   // b/w control unit and dsp 
   logic [31:0] cfg_reg;
   logic [3135:0] dsp_regs;
   logic [31:0] level_reg;
   logic [23:0] audio0;
   logic [23:0] audio1;
   logic          clr;
   logic          level;
   logic          cfg;
   logic          tick;
   logic          play;
   logic          req;

   //b/w dsp & cdc 
   logic [23:0]  daudio0;
   logic [23:0]  daudio1;
   logic         dtick;

   // b/w cdc & i2s
   logic [31:0] mcfg_reg;
   logic [23:0] maudio0;
   logic [23:0] maudio1;
   logic          mtick;
   logic          mplay;
   logic          mreq;
   logic          muxclk;
   logic          muxrst_n;

   
   /////////////////////////////////////////////////////////////////////////////
   // control_unit instantiation
   /////////////////////////////////////////////////////////////////////////////
   control_unit control_unit_1(
   .PREADY(PREADY), .PSEL(PSEL), 
   .PENABLE(PENABLE), .PWRITE(PWRITE), .PADDR(PADDR), 
   .PWDATA(PWDATA), .PRDATA(PRDATA), .PSLVERR(PSLVERR), .irq_out(irq_out), 
   .cfg_reg_out(cfg_reg), .dsp_regs_out(dsp_regs), 
   .level_reg_out(level_reg), .audio0_out(audio0), .audio1_out(audio1), 
   .clr_out(clr), .level_out(level), .cfg_out(cfg), .tick_out(tick), .play_out(play), 
   .req_in(req), 
   .clk(clk), .rst_n(rst_n));

   /////////////////////////////////////////////////////////////////////////////
   // dsp_unit instantiation
   /////////////////////////////////////////////////////////////////////////////
   dsp_unit dsp_unit_1(
   .cfg_reg_in(cfg_reg), 
   .dsp_regs_in(dsp_regs), 
   .level_reg_in(level_reg),                    
   .audio0_in(audio0), 
   .audio1_in(audio1), 
   .clr_in(clr), 
   .level_in(level), 
   .cfg_in(cfg), 
   .tick_in(tick),          
   .audio0_out(daudio0), 
   .audio1_out(daudio1), 
   .tick_out(dtick), 
   .clk(clk), .rst_n(rst_n));

   /////////////////////////////////////////////////////////////////////////////
   // cdc_unit instantiation
   /////////////////////////////////////////////////////////////////////////////
   cdc_unit cdc_unit_1(
   .tick_in(dtick), 
   .audio0_in(daudio0), 
   .audio1_in(daudio1), 
   .play_in(play), 
   .req_out(req),  
   .audio0_out(maudio0), 
   .audio1_out(maudio1), 
   .tick_out(mtick), 
   .play_out(mplay), 
   .req_in(mreq), 
   .muxclk_out(muxclk), 
   .muxrst_n_out(muxrst_n), 
   .clk(clk), .rst_n(rst_n),    
   .test_mode_in(test_mode_in), .mclk(mclk));

   /////////////////////////////////////////////////////////////////////////////
   // i2s_unit instantiation
   /////////////////////////////////////////////////////////////////////////////
   i2s_unit i2s_unit_1(
   .tick_in(mtick), 
   .audio0_in(maudio0), .audio1_in(maudio1), 
   .play_in(mplay), 
   .req_out(mreq), .ws_out(ws_out), .sck_out(sck_out), .sdo_out(sdo_out), 
   .clk(muxclk), .rst_n(muxrst_n)); 

endmodule
