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

// Para todas las señales, la frecuencia que se sintetiza con el acumulador de fase
// tiene como valor: Fs = Fp * N / 65536
// Donde Fs es la frecuencia que queremos sintetizar
//       Fp es la frecuencia portadora maestra (200 MHz)
//        N es el valor que sumamos en el registro de acumulación de fase
// Ejemplo: RFSYNC vale 20398. Esto generará una frecuencia de
//          Fs = 200 * 20398 / 65536 = 62.24975 MHz

module video_emitter (
  input wire clkp,
  input wire video,
  input wire csync,
  output wire rfv
  );
  
  localparam
    RFSYNC  = 16'd20398,  // 62.25 MHz (frecuencia fundamental, 100% de profundidad de amplitud)
    RFVIDEO = 16'd6799;   // 20.75 MHz (primer armónico en 62.25 MHz, 33% de profundidad de amplitud)
    
  reg [15:0] acumphase = 16'h0000;
  always @(posedge clkp)
      acumphase <= acumphase + ((csync == 1'b0)? RFSYNC : RFVIDEO);
    
  assign rfv = (video == 1'b0)? acumphase[15] : 1'b0;  // modulación en amplitud negativa.
endmodule
    
`default_nettype wire