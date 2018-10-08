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

// Resolucion: 384x288 con borde negro de 3 pixels a izquierda y derecha, y 8 pixels arriba y abajo

// Un generador simple de frames. Cada 8 pixels se carga el shifter desde el último dato
// leido en RAM. Si no se está en el area activa, el shifter se carga con ceros
module framegen (
  input wire clk7,
  input wire [8:0] hc,
  input wire [8:0] vc,
  output reg [13:0] ram_addr,
  input wire [7:0] din,
  output wire video_out
  );

  reg load_ramdata, load_shifter, incr_addr, reset_addr;
  reg [7:0] ramdata_din;
  always @* begin  
    load_ramdata = 1'b0;
    load_shifter = 1'b0;
    ramdata_din = 8'h00;
    incr_addr = 1'b0;
    reset_addr = 1'b0;
    
    if (hc[2:0] == 3'd2)  // un ciclo antes de terminar el shifter, se carga con nuevos datos
      load_shifter = 1'b1;
    if (hc[2:0] == 3'd0) begin  // que se cargaron de RAM dos ciclos de reloj antes
      load_ramdata = 1'b1;
      if (hc >= 9'd0 && hc < 9'd384 && vc >= 9'd0 && vc < 9'd288) begin  // si estamos en el area activa...
        ramdata_din = din;  // los datos provienen efectivamente de la RAM
        incr_addr = 1'b1;   // y se incrementa el contador de direcciones
      end
      else
        ramdata_din = 8'h00; // pero si no estamos en el area activa, los datos que se cargan son ceros.
    end
    if (vc >= 9'd288)
      reset_addr = 1'b1;  // tras generar toda el area activa, resetear contador de direcciones
  end

  reg [7:0] ramdata, shifter;
  initial ram_addr = 14'h0000;
  always @(posedge clk7) begin
      if (load_ramdata == 1'b1)
        ramdata <= ramdata_din;   // cargar registro de entrada con datos (de RAM o ceros)
        
      if (load_shifter == 1'b1)   // al registro shifter, o bien se le cargan datos nuevos
        shifter <= ramdata;
      else
        shifter <= {shifter[6:0], 1'b0};  // o se desplazan los que haya, un bit a la izquierda
        
      if (reset_addr == 1'b1)     // comportamiento del contador de direcciones de RAM
        ram_addr <= 14'h0000;
      else if (incr_addr == 1'b1)
        ram_addr <= ram_addr + 14'd1;
  end

  assign video_out = shifter[7];  // el pixel actual es el bit más significativo del shifter
endmodule

// Memoria para el framebuffer. Es de doble puerto porque en una versión posterior de este core
// una CPU escribirá en ella.
module framebuffer (
  input wire clk,
  input wire [13:0] addrr,
  input wire [13:0] addrw,
  input wire we,
  input wire [7:0] din,
  output reg [7:0] dout
  );
  
  reg [7:0] mem[0:16383];
  integer i;
  initial begin
    for (i=0;i<16384;i=i+1) begin
      mem[i] = 8'h00;
    end
    // https://thewallpaper.co/black-and-white-hd-cat-wallpapers-widescreen-pussycats-high-resolution-pet-photos-animal-love-baby-cat-desktop-images-cat-wallpapers-for-mac-windows-wallpapers-of-cats-1805x1354/
    $readmemh ("cat.hex", mem);
  end
  
  always @(posedge clk) begin
    dout <= mem[addrr];
    if (we == 1'b1)
      mem[addrw] <= din;
  end
endmodule

// Generador simple de un tono de 1 kHz a partir del reloj de 7.5 MHz
module audiogen (
  input wire clk,
  output reg audio
  );
  
  reg [11:0] cnt = 12'h000;
  initial audio = 1'b0;
  
  always @(posedge clk) begin
    if (cnt == 12'd3750) begin
      cnt <= 12'h000;
      audio <= ~audio;
    end
    else
      cnt <= cnt + 12'd1;
  end
endmodule  
  
`default_nettype wire