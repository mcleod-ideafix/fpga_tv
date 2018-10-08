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

module video_audio (
  input wire clk,
  input wire clkram,
  output wire video,
  output wire audio,
  output wire csync
  );
  
  wire [8:0] hc,vc;
  wire video_to_syncgen;
  wire [13:0] vram_addr;
  wire [7:0] vram_dout;

  // Instanciación de la memoria de video
  framebuffer the_screen (
    .clk(clkram),
    .addrr(vram_addr),
    .addrw(14'h0000),
    .we(1'b0),
    .din(8'h00),
    .dout(vram_dout)
  );

  // Instanciación del generador de tono de 1 kHz
  audiogen the_audio (
    .clk(clk),
    .audio(audio)
  );

  // Instanciación del generador de señal de video
  framegen the_video (
    .clk7(clk),
    .hc(hc),
    .vc(vc),
    .ram_addr(vram_addr),
    .din(vram_dout),
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