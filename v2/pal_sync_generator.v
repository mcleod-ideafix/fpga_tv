/*
 * This file is part of "TV broadcasting demo using FPGA" project.
 * Copyright (c) 2018 Miguel Angel Rodriguez Jodar.
 * 
 * This program is free software: you can redistribute it and/or modify  
 * it under the terms of the GNU General Public License as published by  
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of 
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
*/


`timescale 1ns / 1ps
`default_nettype none

module pal_sync_generator (
    input wire clk7,
    input wire video_in,
    output reg [8:0] hc,
    output reg [8:0] vc,
    output reg video_out,
    output reg csync
    );
    
    // Valores para HORIZONTAL_... referidos a un dot clock de 7.5 MHz
    // Referencia: http://martin.hinner.info/vga/pal.html
    localparam
      HORIZONTAL_TOTAL  = 9'd480,
      VERTICAL_TOTAL    = 9'd312,
      HORIZONTAL_ACTIVE = 9'd390,
      HORIZONTAL_FPORCH = 9'd12,
      HORIZONTAL_SYNC   = 9'd35,
      HORIZONTAL_BPORCH = 9'd43,
      VERTICAL_ACTIVE   = 9'd304,
      VERTICAL_FPORCH   = 9'd3,
      VERTICAL_SYNC     = 9'd3,
      VERTICAL_BPORCH   = 9'd2;

    initial hc = 9'h000;
    initial vc = 9'h000;

    // Contadores para fila y columna
    always @(posedge clk7) begin
      if (hc == HORIZONTAL_TOTAL-1) begin
         hc <= 9'd0;
         if (vc == VERTICAL_TOTAL-1) begin
            vc <= 9'd0;
         end
         else begin
            vc <= vc + 9'd1;
         end
      end
      else begin
         hc <= hc + 9'd1;
      end
    end

    // Generación de sincronismo compuesto PAL progresivo (más o menos...)
    always @* begin
      if (hc >= 9'd0 && hc < HORIZONTAL_ACTIVE && vc >= 9'd0 && vc < VERTICAL_ACTIVE)
        video_out = video_in;
      else
        video_out = 1'b0;
        
      if (hc >= (HORIZONTAL_ACTIVE+HORIZONTAL_FPORCH) && hc < (HORIZONTAL_ACTIVE+HORIZONTAL_FPORCH+HORIZONTAL_SYNC) )
        csync = 1'b0;
      else
        csync = 1'b1;
      
      if (vc >= (VERTICAL_ACTIVE+VERTICAL_FPORCH) && vc < (VERTICAL_ACTIVE+VERTICAL_FPORCH+VERTICAL_SYNC) )
        csync = ~csync;
    end
endmodule

`default_nettype wire