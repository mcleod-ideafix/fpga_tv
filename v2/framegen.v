/*
 * This file is part of "TV broadcasting demo using FPGA" project.
 * Copyright (c) 2018 Miguel Angel Rodriguez Jodar (integration with TV boardacasting project).
 *           (c)      Juan Manuel Rico (rotating+zooming demoeffect in FPGA)
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

// Resolucion: 390x304

module framegen (
  input wire clk7,
  input wire [8:0] hc,
  input wire [8:0] vc,
  output reg video_out
  );

  reg [8:0] angle;   /* angle that image is rotated (0..255) */
  reg signed [15:0] scale;   /* scale to draw at */

  localparam ROTATE_CENTRE_X = 194;
  localparam ROTATE_CENTRE_Y = 152;

  reg signed [15:0] unscaled_u_stride;
  reg signed [15:0] unscaled_v_stride;

  reg signed [32:0] u_stride;
  reg signed [32:0] v_stride;

  // todo check widths etc
  reg signed [32:0] u_offset;
  reg signed [32:0] v_offset;

  // start positions for u&v at the beginning of each line
  reg signed [16:0] u_start;
  reg signed [16:0] v_start;

  // current positions for u&v (fixed point 1.16 indexes into the texture space)
  reg signed [16:0] u;
  reg signed [16:0] v;

  reg signed[15:0] SINE_TABLE_ROM[0:255];
  initial $readmemh ("tabla_senos.hex", SINE_TABLE_ROM);
  always @(posedge clk7) begin
    unscaled_v_stride <= SINE_TABLE_ROM[angle[7:0]];
    unscaled_u_stride <= SINE_TABLE_ROM[angle[7:0]+64];
    scale             <= SINE_TABLE_ROM[angle[8:1]];
  end

  reg [127:0] textura[0:127];
  initial $readmemh ("textura.hex", textura);
  always @(posedge clk7) begin
    video_out <= textura[~u[16:10]][v[16:10]];
  end

  always @(posedge clk7)
  begin
    if (hc == 9'd0 && vc == 9'd304) begin
      // una vez en cada frame (por ejemplo, cuando se ha terminado de pintar el frame actual
      // actualizamos algunos valores que sólo hay que actualizar una vez por frame
      angle <= angle + 1;   // como por ejemplo, el angulo de giro
      u_stride <= (scale * unscaled_u_stride) >>> (16+3);  // actualizmos el valor del escalon en X e Y.
      v_stride <= (scale * unscaled_v_stride) >>> (16+3);  // 16 to account for scale, 3 to make textures bigger or smaller
      u_offset <= (ROTATE_CENTRE_X * unscaled_u_stride) >>> (16+5);
      v_offset <= (ROTATE_CENTRE_Y * unscaled_v_stride) >>> (16+5);
      u_start <= -u_offset[16:0];
      v_start <= v_offset[16:0];
    end
    else if (hc >= 9'd0 && hc < 9'd390 && vc >= 9'd0 && vc < 9'd304) begin
      if (hc == 9'd0) begin
        u_start <= u_start + v_stride[16:0];
        v_start <= v_start - u_stride[16:0];
        u <= u_start;
        v <= v_start;
      end else begin
        u <= u + u_stride[16:0];
        v <= v + v_stride[16:0];
      end
    end 
  end
endmodule
  
`default_nettype wire