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

module video (
  input wire clk,
  output wire video,
  output wire csync
  );
  
  wire [8:0] hc,vc;
  wire video_to_syncgen;

  // Instanciación del generador de señal de video
  framegen the_video (
    .clk7(clk),
    .hc(hc),
    .vc(vc),
    .video_out(video_to_syncgen)
  );

  // Que es enviada al generador de sincronismos, para obtener la señal de video
  // definitiva, y además generar el sincronismo compuesto
  pal_sync_generator syncs(
    .clk7(clk),
    .video_in(video_to_syncgen),
    .hc(hc),
    .vc(vc),
    .video_out(video),
    .csync(csync)
  );
  
endmodule

`default_nettype wire