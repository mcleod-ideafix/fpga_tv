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

module tld_zxuno (
  input wire clk50mhz,
  output wire [2:0] r,
  output wire [2:0] g,
  output wire [2:0] b,
  output wire csync,
  output wire stdn,
  output wire stdnb,
  output wire antenna_tv
  );
  
  wire clk200, clk30, clk7;
  wire video, audio;
  
  clocks clks (
    .clk50mhz(clk50mhz),  // cristal de la placa del ZXUNO
    .clk200(clk200),      // 200 MHz: frecuencia base para las portadoras de audio y video
    .clk30(clk30),        //  30 MHz: frecuencia para la RAM sincrona interna de la FPGA
    .clk7(clk7),          // 7.5 MHz: frecuencia para el generador de video y audio
    .clocks_ready()
  );
  
  // Instanciación de todo el generador de video y audio
  video baseband_signal (
    .clk(clk7),
    .video(video),
    .csync(csync)
  );
  
  // Enviamos video y sincronismos al emisor de video
  video_emitter video_carrier (
    .clkp(clk200),
    .video(video),
    .csync(csync),
    .rfv(antenna_tv)
  );
  
  // Usamos la salida de video del ZX-UNO para monitorizar el resultado
  assign r = {video, video, video};
  assign g = {video, video, video};
  assign b = {video, video, video};

  // Sólo si se usa la salida de video compuesto del ZX-UNO, para programar el AD724.  
  // No interviene para nada en la emisión por RF.
	assign stdn = 1'b0;  // fijar norma PAL. Sólo para salida monitor.
	assign stdnb = 1'b1; // y conectamos reloj PAL. Sólo para salida monitor.
endmodule

`default_nettype wire