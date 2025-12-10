// 
// Politecnico di Milano
// Code created using PandA - Version: PandA 2024.10 - Revision 82f6883b7d8c63f358702b47c2067b0ef3c33072-dev - Date 2025-12-10T11:39:21
// Bambu executed with: bambu --top-fname=man_fib ../man_fib.cpp 
// 
// Send any bug to: panda-info@polimi.it
// ************************************************************************
// The following text holds for all the components tagged with PANDA_LGPLv3.
// They are all part of the BAMBU/PANDA IP LIBRARY.
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public
// License along with the PandA framework; see the files COPYING.LIB
// If not, see <http://www.gnu.org/licenses/>.
// ************************************************************************


`ifdef __ICARUS__
  `define _SIM_HAVE_CLOG2
`endif
`ifdef VERILATOR
  `define _SIM_HAVE_CLOG2
`endif
`ifdef MODEL_TECH
  `define _SIM_HAVE_CLOG2
`endif
`ifdef VCS
  `define _SIM_HAVE_CLOG2
`endif
`ifdef NCVERILOG
  `define _SIM_HAVE_CLOG2
`endif
`ifdef XILINX_SIMULATOR
  `define _SIM_HAVE_CLOG2
`endif
`ifdef XILINX_ISIM
  `define _SIM_HAVE_CLOG2
`endif

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>, Christian Pilato <christian.pilato@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module constant_value(out1);
  parameter BITSIZE_out1=1,
    value=1'b0;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = value;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module register_SE(clock,
  reset,
  in1,
  wenable,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input clock;
  input reset;
  input [BITSIZE_in1-1:0] in1;
  input wenable;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  
  reg [BITSIZE_out1-1:0] reg_out1 =0;
  assign out1 = reg_out1;
  always @(posedge clock)
    if (wenable)
      reg_out1 <= in1;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module register_STD(clock,
  reset,
  in1,
  wenable,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input clock;
  input reset;
  input [BITSIZE_in1-1:0] in1;
  input wenable;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  reg [BITSIZE_out1-1:0] reg_out1 =0;
  assign out1 = reg_out1;
  always @(posedge clock)
    reg_out1 <= in1;

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2020-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module STD_SP_BRAM(clock,
  write_enable,
  data_in,
  address_inr,
  address_inw,
  data_out);
  parameter BITSIZE_data_in=1,
    BITSIZE_address_inr=1,
    BITSIZE_address_inw=1,
    BITSIZE_data_out=1,
    MEMORY_INIT_file="array_a.mem",
    n_elements=32,
    READ_ONLY_MEMORY=0,
    HIGH_LATENCY=0;
  // IN
  input clock;
  input write_enable;
  input [BITSIZE_data_in-1:0] data_in;
  input [BITSIZE_address_inr-1:0] address_inr;
  input [BITSIZE_address_inw-1:0] address_inw;
  // OUT
  output [BITSIZE_data_out-1:0] data_out;
  
  wire [BITSIZE_address_inr-1:0] address_inr_mem;
  reg [BITSIZE_address_inr-1:0] address_inr1;
  wire [BITSIZE_address_inw-1:0] address_inw_mem;
  reg [BITSIZE_address_inw-1:0] address_inw1;
  
  wire write_enable_mem;
  reg write_enable1;
  
  reg [BITSIZE_data_out-1:0] data_out_mem;
  reg [BITSIZE_data_out-1:0] data_out1;
  
  wire [BITSIZE_data_in-1:0] data_in_mem;
  reg [BITSIZE_data_in-1:0] data_in1;
  integer index;
  
  reg [BITSIZE_data_out-1:0] memory [0:n_elements-1]/* synthesis syn_ramstyle =  "no_rw_check" */;
  
  initial
  begin
    if (MEMORY_INIT_file != "")
      $readmemb(MEMORY_INIT_file, memory, 0, n_elements-1);
    else
    begin
      for(index=0; index<n_elements; index=index+1)
      begin
        memory[index] = 0;
      end
    end
  end
  
  always @(posedge clock)
  begin
    if(READ_ONLY_MEMORY==0)
    begin
      if (write_enable_mem)
        memory[address_inw_mem] <= data_in_mem;
    end
    data_out_mem <= memory[address_inr_mem];
  end
  
  assign data_out = HIGH_LATENCY==0 ? data_out_mem : data_out1;
  always @(posedge clock)
    data_out1 <= data_out_mem;
  
  
  generate
    if(HIGH_LATENCY==2)
    begin
      always @ (posedge clock)
      begin
         address_inr1 <= address_inr;
         address_inw1 <= address_inw;
         write_enable1 <= write_enable;
         data_in1 <= data_in;
      end
      assign address_inr_mem = address_inr1;
      assign address_inw_mem = address_inw1;
      assign write_enable_mem = write_enable1;
      assign data_in_mem = data_in1;
    end
    else
    begin
      assign address_inr_mem = address_inr;
      assign address_inw_mem = address_inw;
      assign write_enable_mem = write_enable;
      assign data_in_mem = data_in;
    end
  endgenerate

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2020-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module STD_SP_BRAMFW(clock,
  write_enable,
  data_in,
  address_inr,
  address_inw,
  data_out);
  parameter BITSIZE_data_in=1,
    BITSIZE_address_inr=1,
    BITSIZE_address_inw=1,
    BITSIZE_data_out=1,
    MEMORY_INIT_file="array_a.mem",
    n_elements=32,
    READ_ONLY_MEMORY=0,
    HIGH_LATENCY=0;
  // IN
  input clock;
  input write_enable;
  input [BITSIZE_data_in-1:0] data_in;
  input [BITSIZE_address_inr-1:0] address_inr;
  input [BITSIZE_address_inw-1:0] address_inw;
  // OUT
  output [BITSIZE_data_out-1:0] data_out;
  
  wire [BITSIZE_address_inr-1:0] address_inr_mem;
  reg [BITSIZE_address_inr-1:0] address_inr1;
  reg [BITSIZE_address_inr-1:0] address_inr_mem1;
  wire [BITSIZE_address_inw-1:0] address_inw_mem;
  reg [BITSIZE_address_inw-1:0] address_inw1;
  reg [BITSIZE_address_inw-1:0] address_inw_mem1;
  
  wire write_enable_mem;
  reg write_enable1;
  reg write_enable_mem1;
  
  reg [BITSIZE_data_out-1:0] data_out_mem_temp;
  reg [BITSIZE_data_out-1:0] data_out1;
  wire [BITSIZE_data_out-1:0] data_out_mem;
  
  wire [BITSIZE_data_in-1:0] data_in_mem;
  reg [BITSIZE_data_in-1:0] data_in1;
  reg [BITSIZE_data_in-1:0] data_in_mem1;
  
  integer index;
  
  reg [BITSIZE_data_out-1:0] memory [0:n_elements-1]/* synthesis syn_ramstyle =  "no_rw_check" */;
  
  initial
  begin
    if (MEMORY_INIT_file != "")
      $readmemb(MEMORY_INIT_file, memory, 0, n_elements-1);
    else
    begin
      for(index=0; index<n_elements; index=index+1)
      begin
        memory[index] = 0;
      end
    end
  end
  
  always @(posedge clock)
  begin
    if(READ_ONLY_MEMORY==0)
    begin
      if (write_enable_mem)
        memory[address_inw_mem] <= data_in_mem;
    end
    data_out_mem_temp <= memory[address_inr_mem];
  end
  
  assign data_out_mem = write_enable_mem1 && (address_inr_mem1 == address_inw_mem1) ? data_in_mem1 : data_out_mem_temp;
  
  assign data_out = HIGH_LATENCY==0 ? data_out_mem : data_out1;
  always @(posedge clock)
    data_out1 <= data_out_mem;
  
  always @ (posedge clock)
  begin
    address_inr_mem1 <= address_inr_mem;
    address_inw_mem1 <= address_inw_mem;
    write_enable_mem1 <= write_enable_mem;
    data_in_mem1 <= data_in_mem;
  end
  
  generate
    if(HIGH_LATENCY==2)
    begin
      always @ (posedge clock)
      begin
         address_inr1 <= address_inr;
         address_inw1 <= address_inw;
         write_enable1 <= write_enable;
         data_in1 <= data_in;
      end
      assign address_inr_mem = address_inr1;
      assign address_inw_mem = address_inw1;
      assign write_enable_mem = write_enable1;
      assign data_in_mem = data_in1;
    end
    else
    begin
      assign address_inr_mem = address_inr;
      assign address_inw_mem = address_inw;
      assign write_enable_mem = write_enable;
      assign data_in_mem = data_in;
    end
  endgenerate

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2013-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module STD_NR_BRAM(clock,
  write_enable,
  address_inr,
  address_inw,
  data_in,
  data_out);
  parameter BITSIZE_address_inr=1, PORTSIZE_address_inr=2,
    BITSIZE_address_inw=1,
    BITSIZE_data_in=1,
    BITSIZE_data_out=1, PORTSIZE_data_out=2,
    MEMORY_INIT_file="array_a.mem",
    n_elements=32,
    forwarding=0,
    READ_ONLY_MEMORY=0,
    HIGH_LATENCY=0;
  // IN
  input clock;
  input write_enable;
  input [(PORTSIZE_address_inr*BITSIZE_address_inr)+(-1):0] address_inr;
  input [BITSIZE_address_inw-1:0] address_inw;
  input [BITSIZE_data_in-1:0] data_in;
  // OUT
  output [(PORTSIZE_data_out*BITSIZE_data_out)+(-1):0] data_out;
  
  generate
  genvar i1;
    for (i1=0; i1<PORTSIZE_address_inr; i1=i1+1)
    begin : L1
      if(forwarding)
      begin
        STD_SP_BRAMFW #(
          .BITSIZE_address_inr(BITSIZE_address_inr),
          .BITSIZE_address_inw(BITSIZE_address_inw),
          .BITSIZE_data_in(BITSIZE_data_in),
          .BITSIZE_data_out(BITSIZE_data_out),
          .MEMORY_INIT_file(MEMORY_INIT_file),
          .n_elements(n_elements),
          .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
          .HIGH_LATENCY(HIGH_LATENCY)
          )
        STD_SP_BRAMFW_instance (
          .clock(clock),
          .write_enable(write_enable),
          .address_inr(address_inr[(i1+1)*BITSIZE_address_inr-1:i1*BITSIZE_address_inr]),
          .address_inw(address_inw),
          .data_in(data_in),
          .data_out(data_out[(i1+1)*BITSIZE_data_out-1:i1*BITSIZE_data_out]));
      end
      else
      begin
        STD_SP_BRAM #(
          .BITSIZE_address_inr(BITSIZE_address_inr),
          .BITSIZE_address_inw(BITSIZE_address_inw),
          .BITSIZE_data_in(BITSIZE_data_in),
          .BITSIZE_data_out(BITSIZE_data_out),
          .MEMORY_INIT_file(MEMORY_INIT_file),
          .n_elements(n_elements),
          .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
          .HIGH_LATENCY(HIGH_LATENCY)
          )
        STD_SP_BRAM_instance (
          .clock(clock),
          .write_enable(write_enable),
          .address_inr(address_inr[(i1+1)*BITSIZE_address_inr-1:i1*BITSIZE_address_inr]),
          .address_inw(address_inw),
          .data_in(data_in),
          .data_out(data_out[(i1+1)*BITSIZE_data_out-1:i1*BITSIZE_data_out]));
      end
    end
  endgenerate
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module STD_NRNW_BRAM_XOR(clock,
  write_enable,
  address_inr,
  address_inw,
  data_in,
  dout_value);
  parameter BITSIZE_write_enable=1, PORTSIZE_write_enable=2,
    BITSIZE_address_inr=1, PORTSIZE_address_inr=2,
    BITSIZE_address_inw=1, PORTSIZE_address_inw=2,
    BITSIZE_data_in=1, PORTSIZE_data_in=2,
    BITSIZE_dout_value=1, PORTSIZE_dout_value=2,
    MEMORY_INIT_file="array_a.mem",
    n_elements=32,
    READ_ONLY_MEMORY=0,
    HIGH_LATENCY=0;
  // IN
  input clock;
  input [PORTSIZE_write_enable-1:0] write_enable;
  input [(PORTSIZE_address_inr*BITSIZE_address_inr)+(-1):0] address_inr;
  input [(PORTSIZE_address_inw*BITSIZE_address_inw)+(-1):0] address_inw;
  input [(PORTSIZE_data_in*BITSIZE_data_in)+(-1):0] data_in;
  // OUT
  output [(PORTSIZE_dout_value*BITSIZE_dout_value)+(-1):0] dout_value;
  
  `ifndef _SIM_HAVE_CLOG2
    function integer log2;
       input integer value;
       integer temp_value;
      begin
        temp_value = value-1;
        for (log2=0; temp_value>0; log2=log2+1)
          temp_value = temp_value>>1;
      end
    endfunction
  `endif
  `ifdef _SIM_HAVE_CLOG2
    localparam nbit_write = PORTSIZE_address_inw == 1 ? 1 : $clog2(PORTSIZE_address_inw);
  `else
    localparam nbit_write = PORTSIZE_address_inw == 1 ? 1 : log2(PORTSIZE_address_inw);
  `endif
  
  reg [PORTSIZE_data_in*BITSIZE_data_in-1:0] WriteFeedBackData;
  wire [BITSIZE_dout_value*(PORTSIZE_address_inw*(PORTSIZE_address_inw-1))-1:0] ReadFeedBackData;
  reg [BITSIZE_address_inw*(PORTSIZE_address_inw*(PORTSIZE_address_inw-1))-1:0] ReadFeedBackAddr;
  reg [BITSIZE_dout_value*PORTSIZE_dout_value-1:0] ReadData;
  wire [BITSIZE_dout_value*PORTSIZE_dout_value*PORTSIZE_address_inw-1:0] ReadDataOut;
  
  wire [PORTSIZE_write_enable-1:0] write_enable_mem;
  wire [PORTSIZE_address_inw*BITSIZE_address_inw-1:0] address_inw_mem;
  wire [PORTSIZE_address_inr*BITSIZE_address_inr-1:0] address_inr_mem;
  wire [PORTSIZE_data_in*BITSIZE_data_in-1:0] data_in_mem;
  wire [PORTSIZE_dout_value*BITSIZE_dout_value-1:0] dout_value_mem;
  reg [PORTSIZE_dout_value*BITSIZE_dout_value-1:0] dout_value_mem1;
  
  reg [PORTSIZE_write_enable-1:0] write_enable_mem1;
  reg [PORTSIZE_address_inw*BITSIZE_address_inw-1:0] address_inw_mem1;
  reg [PORTSIZE_data_in*BITSIZE_data_in-1:0] data_in_mem1;
  
  reg [PORTSIZE_write_enable-1:0] write_enable1;
  reg [PORTSIZE_address_inw*BITSIZE_address_inw-1:0] address_inw1;
  reg [PORTSIZE_address_inr*BITSIZE_address_inr-1:0] address_inr1;
  reg [PORTSIZE_data_in*BITSIZE_data_in-1:0] data_in1;
  
  assign dout_value = HIGH_LATENCY==0 ? dout_value_mem : dout_value_mem1;
  always @(posedge clock)
    dout_value_mem1 <= dout_value_mem;
  
  
  generate
    if(HIGH_LATENCY==2)
    begin
      always @ (posedge clock)
      begin
         address_inr1 <= address_inr;
         address_inw1 <= address_inw;
         write_enable1 <= write_enable;
         data_in1 <= data_in;
      end
      assign address_inr_mem = address_inr1;
      assign address_inw_mem = address_inw1;
      assign write_enable_mem = write_enable1;
      assign data_in_mem = data_in1;
    end
    else
    begin
      assign address_inr_mem = address_inr;
      assign address_inw_mem = address_inw;
      assign write_enable_mem = write_enable;
      assign data_in_mem = data_in;
    end
  endgenerate
  
  always @(posedge clock)
  begin
    write_enable_mem1 <= write_enable_mem;
    address_inw_mem1 <= address_inw_mem;
    data_in_mem1 <= data_in_mem;
  end
  
  assign dout_value_mem = ReadData;
  
  generate
  genvar ii1;
    for (ii1=0; ii1<PORTSIZE_address_inw; ii1=ii1+1)
    begin : L1
      STD_NR_BRAM #(
        .PORTSIZE_address_inr(PORTSIZE_address_inw-1),
        .BITSIZE_address_inr(BITSIZE_address_inr),
        .BITSIZE_address_inw(BITSIZE_address_inw),
        .BITSIZE_data_in(BITSIZE_data_in),
        .BITSIZE_data_out(BITSIZE_dout_value),
        .PORTSIZE_data_out(PORTSIZE_address_inw-1),
        .MEMORY_INIT_file(ii1 == 0 ? MEMORY_INIT_file : ""),
        .n_elements(n_elements),
        .forwarding(1),
        .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
        .HIGH_LATENCY(0)
      )
      STD_NR_BRAM_FB_instance (
        .clock(clock),
        .write_enable(write_enable_mem1[ii1]),
        .address_inr(ReadFeedBackAddr[ii1*(BITSIZE_address_inw*(PORTSIZE_address_inw-1))+:(BITSIZE_address_inw*(PORTSIZE_address_inw-1))]),
        .address_inw(address_inw_mem1[ii1*BITSIZE_address_inw+:BITSIZE_address_inw]),
        .data_in(WriteFeedBackData[ii1*BITSIZE_data_in+:BITSIZE_data_in]),
        .data_out(ReadFeedBackData[ii1*BITSIZE_dout_value*(PORTSIZE_address_inw-1)+:BITSIZE_dout_value*(PORTSIZE_address_inw-1)]));
  
      STD_NR_BRAM #(
        .PORTSIZE_address_inr(PORTSIZE_address_inr),
        .BITSIZE_address_inr(BITSIZE_address_inr),
        .BITSIZE_address_inw(BITSIZE_address_inw),
        .BITSIZE_data_in(BITSIZE_data_in),
        .BITSIZE_data_out(BITSIZE_dout_value),
        .PORTSIZE_data_out(PORTSIZE_address_inr),
        .MEMORY_INIT_file(ii1 == 0 ? MEMORY_INIT_file : ""),
        .n_elements(n_elements),
        .forwarding(1),
        .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
        .HIGH_LATENCY(0)
      )
      STD_NR_BRAM_instance (
        .clock(clock),
        .write_enable(write_enable_mem1[ii1]),
        .address_inr(address_inr_mem),
        .address_inw(address_inw_mem1[ii1*BITSIZE_address_inw+:BITSIZE_address_inw]),
        .data_in(WriteFeedBackData[ii1*BITSIZE_data_in+:BITSIZE_data_in]),
        .data_out(ReadDataOut[ii1*BITSIZE_dout_value*(PORTSIZE_address_inr)+:BITSIZE_dout_value*(PORTSIZE_address_inr)]));
    end
  endgenerate
  integer i1,i2,i3;
  always @(*)
  begin
    for(i1=0;i1<PORTSIZE_address_inr;i1=i1+1)
    begin
      ReadData[i1*BITSIZE_dout_value+:BITSIZE_dout_value] = ReadDataOut[i1*BITSIZE_dout_value+:BITSIZE_dout_value];
      for(i2=1;i2<PORTSIZE_address_inw;i2=i2+1)
      begin
        ReadData[i1*BITSIZE_dout_value+:BITSIZE_dout_value] = ReadData[i1*BITSIZE_dout_value+:BITSIZE_dout_value]^ReadDataOut[(i2*PORTSIZE_address_inw+i1)*BITSIZE_dout_value+:BITSIZE_dout_value];
      end
    end
    for(i1=0;i1<PORTSIZE_address_inw;i1=i1+1)
      WriteFeedBackData[i1*BITSIZE_data_in+:BITSIZE_data_in] = data_in_mem1[i1*BITSIZE_data_in+:BITSIZE_data_in];
    for(i1=0;i1<PORTSIZE_address_inw;i1=i1+1)
    begin
      i3 = 0;
      for(i2=0;i2<PORTSIZE_address_inw-1;i2=i2+1)
      begin
        i3=i3+(i2==i1);
        ReadFeedBackAddr[(i1*(PORTSIZE_address_inw-1)+i2)*BITSIZE_address_inw+:BITSIZE_address_inw] = address_inw_mem[i3*BITSIZE_address_inw+:BITSIZE_address_inw];
        WriteFeedBackData[i3*BITSIZE_data_in+:BITSIZE_data_in] = WriteFeedBackData[i3*BITSIZE_data_in+:BITSIZE_data_in]^ReadFeedBackData[(i1*(PORTSIZE_address_inw-1)+i2)*BITSIZE_data_in+:BITSIZE_data_in];
        i3=i3+1;
      end
    end
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module STD_DP_BRAM(clock,
  write_enable,
  data_in,
  address_in,
  data_out);
  parameter BITSIZE_write_enable=1, PORTSIZE_write_enable=2,
    BITSIZE_data_in=1, PORTSIZE_data_in=2,
    BITSIZE_address_in=1, PORTSIZE_address_in=2,
    BITSIZE_data_out=1, PORTSIZE_data_out=2,
    MEMORY_INIT_file="array_a.mem",
    n_elements=32,
    READ_ONLY_MEMORY=0,
    HIGH_LATENCY=0;
  // IN
  input clock;
  input [PORTSIZE_write_enable-1:0] write_enable;
  input [(PORTSIZE_data_in*BITSIZE_data_in)+(-1):0] data_in;
  input [(PORTSIZE_address_in*BITSIZE_address_in)+(-1):0] address_in;
  // OUT
  output [(PORTSIZE_data_out*BITSIZE_data_out)+(-1):0] data_out;
  
  wire [2*BITSIZE_address_in-1:0] address_in_mem;
  reg [2*BITSIZE_address_in-1:0] address_in1;
  
  wire [1:0] write_enable_mem;
  reg [1:0] write_enable1;
  
  reg [2*BITSIZE_data_out-1:0] data_out_mem;
  reg [2*BITSIZE_data_out-1:0] data_out1;
  
  wire [2*BITSIZE_data_in-1:0] data_in_mem;
  reg [2*BITSIZE_data_in-1:0] data_in1;
  
  reg [BITSIZE_data_out-1:0] memory [0:n_elements-1] /* synthesis syn_ramstyle = "no_rw_check" */;
  
  initial
  begin
    if (MEMORY_INIT_file != "")
      $readmemb(MEMORY_INIT_file, memory, 0, n_elements-1);
  end
  
  assign data_out = HIGH_LATENCY==0 ? data_out_mem : data_out1;
  always @(posedge clock)
    data_out1 <= data_out_mem;
  
  generate
    if(HIGH_LATENCY==2)
    begin
      always @ (posedge clock)
      begin
         address_in1 <= address_in;
         write_enable1 <= write_enable;
         data_in1 <= data_in;
      end
      assign address_in_mem = address_in1;
      assign write_enable_mem = write_enable1;
      assign data_in_mem = data_in1;
    end
    else
    begin
      assign address_in_mem = address_in;
      assign write_enable_mem = write_enable;
      assign data_in_mem = data_in;
    end
  endgenerate
  
  
  always @(posedge clock)
  begin
    if(READ_ONLY_MEMORY==0)
    begin
      if(write_enable_mem[0])
        memory[address_in_mem[BITSIZE_address_in*0+:BITSIZE_address_in]] <= data_in_mem[BITSIZE_data_in*0+:BITSIZE_data_in];
    end
    data_out_mem[BITSIZE_data_out*0+:BITSIZE_data_out] <= memory[address_in_mem[BITSIZE_address_in*0+:BITSIZE_address_in]];
  end
  always @(posedge clock)
  begin
      if(READ_ONLY_MEMORY==0)
      begin
        if(write_enable_mem[1])
          memory[address_in_mem[BITSIZE_address_in*1+:BITSIZE_address_in]] <= data_in_mem[BITSIZE_data_in*1+:BITSIZE_data_in];
      end
      data_out_mem[BITSIZE_data_out*1+:BITSIZE_data_out] <= memory[address_in_mem[BITSIZE_address_in*1+:BITSIZE_address_in]];
  end

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2023-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module STD_NRNW_BRAM_GEN(clock,
  write_enable,
  address_inr,
  address_inw,
  data_in,
  dout_value);
  parameter BITSIZE_write_enable=1, PORTSIZE_write_enable=2,
    BITSIZE_address_inr=1, PORTSIZE_address_inr=2,
    BITSIZE_address_inw=1, PORTSIZE_address_inw=2,
    BITSIZE_data_in=1, PORTSIZE_data_in=2,
    BITSIZE_dout_value=1, PORTSIZE_dout_value=2,
    MEMORY_INIT_file="array_a.mem",
    n_elements=32,
    READ_ONLY_MEMORY=0,
    HIGH_LATENCY=0;
  // IN
  input clock;
  input [PORTSIZE_write_enable-1:0] write_enable;
  input [(PORTSIZE_address_inr*BITSIZE_address_inr)+(-1):0] address_inr;
  input [(PORTSIZE_address_inw*BITSIZE_address_inw)+(-1):0] address_inw;
  input [(PORTSIZE_data_in*BITSIZE_data_in)+(-1):0] data_in;
  // OUT
  output [(PORTSIZE_dout_value*BITSIZE_dout_value)+(-1):0] dout_value;
  
  parameter nbit_addr = BITSIZE_address_inr > BITSIZE_address_inw ? BITSIZE_address_inr : BITSIZE_address_inw;
  wire [2*nbit_addr-1:0] address_in;
  generate
  if(PORTSIZE_address_inw == 1)
  begin
    STD_NR_BRAM #(
        .PORTSIZE_address_inr(PORTSIZE_address_inr),
        .BITSIZE_address_inr(BITSIZE_address_inr),
        .BITSIZE_address_inw(BITSIZE_address_inw),
        .BITSIZE_data_in(BITSIZE_data_in),
        .BITSIZE_data_out(BITSIZE_dout_value),
        .PORTSIZE_data_out(PORTSIZE_dout_value),
        .MEMORY_INIT_file(MEMORY_INIT_file),
        .n_elements(n_elements),
        .forwarding(0),
        .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
        .HIGH_LATENCY(HIGH_LATENCY)
      )
      STD_NR_BRAM_FB_instance (
        .clock(clock),
        .write_enable(write_enable[0]),
        .address_inr(address_inr),
        .address_inw(address_inw[0+:BITSIZE_address_inw]),
        .data_in(data_in[0+:BITSIZE_data_in]),
        .data_out(dout_value));
  end
  else if(PORTSIZE_address_inr == 2 && PORTSIZE_address_inw == 2)
  begin
    assign address_in[0+:nbit_addr] = write_enable[0] ? address_inw[0+:BITSIZE_address_inw] : address_inr[0+:BITSIZE_address_inr];
    assign address_in[nbit_addr+:nbit_addr] = write_enable[1] ? address_inw[BITSIZE_address_inw+:BITSIZE_address_inw] : address_inr[BITSIZE_address_inr+:BITSIZE_address_inr];
    STD_DP_BRAM #(
      .PORTSIZE_write_enable(PORTSIZE_write_enable),
      .BITSIZE_write_enable(1),
      .PORTSIZE_data_in(PORTSIZE_data_in),
      .BITSIZE_data_in(BITSIZE_data_in),
      .PORTSIZE_data_out(PORTSIZE_dout_value),
      .BITSIZE_data_out(BITSIZE_dout_value),
      .PORTSIZE_address_in(2),
      .BITSIZE_address_in(nbit_addr),
      .n_elements(n_elements),
      .MEMORY_INIT_file(MEMORY_INIT_file),
      .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
      .HIGH_LATENCY(HIGH_LATENCY)
    ) STD_DP_BRAM_instance (
      .clock(clock),
      .write_enable(write_enable),
      .data_in(data_in),
      .address_in(address_in),
      .data_out(dout_value)
    );
  end
  else
  begin
    STD_NRNW_BRAM_XOR #(
      .PORTSIZE_write_enable(PORTSIZE_write_enable),
      .BITSIZE_write_enable(BITSIZE_write_enable),
      .PORTSIZE_address_inr(PORTSIZE_address_inr),
      .BITSIZE_address_inr(BITSIZE_address_inr),
      .PORTSIZE_address_inw(PORTSIZE_address_inw),
      .BITSIZE_address_inw(BITSIZE_address_inw),
      .PORTSIZE_data_in(PORTSIZE_data_in),
      .BITSIZE_data_in(BITSIZE_data_in),
      .PORTSIZE_dout_value(PORTSIZE_dout_value),
      .BITSIZE_dout_value(BITSIZE_dout_value),
      .MEMORY_INIT_file(MEMORY_INIT_file),
      .n_elements(n_elements),
      .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
      .HIGH_LATENCY(HIGH_LATENCY)
    ) STD_NRNW_BRAM_inst (
      .clock(clock),
      .write_enable(write_enable),
      .data_in(data_in),
      .address_inr(address_inr),
      .address_inw(address_inw),
      .dout_value(dout_value)
    );
  end
  endgenerate

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ARRAY_1D_STD_BRAM_NN_SDS_BASE(clock,
  reset,
  in1,
  in2r,
  in2w,
  in3r,
  in3w,
  in4r,
  in4w,
  out1,
  sel_LOAD,
  sel_STORE,
  S_oe_ram,
  S_we_ram,
  S_addr_ram,
  S_Wdata_ram,
  Sin_Rdata_ram,
  Sout_Rdata_ram,
  S_data_ram_size,
  Sin_DataRdy,
  Sout_DataRdy,
  proxy_in1,
  proxy_in2r,
  proxy_in2w,
  proxy_in3r,
  proxy_in3w,
  proxy_in4r,
  proxy_in4w,
  proxy_sel_LOAD,
  proxy_sel_STORE,
  proxy_out1);
  parameter BITSIZE_in1=1, PORTSIZE_in1=2,
    BITSIZE_in2r=1, PORTSIZE_in2r=2,
    BITSIZE_in2w=1, PORTSIZE_in2w=2,
    BITSIZE_in3r=1, PORTSIZE_in3r=2,
    BITSIZE_in3w=1, PORTSIZE_in3w=2,
    BITSIZE_in4r=1, PORTSIZE_in4r=2,
    BITSIZE_in4w=1, PORTSIZE_in4w=2,
    BITSIZE_sel_LOAD=1, PORTSIZE_sel_LOAD=2,
    BITSIZE_sel_STORE=1, PORTSIZE_sel_STORE=2,
    BITSIZE_S_oe_ram=1, PORTSIZE_S_oe_ram=2,
    BITSIZE_S_we_ram=1, PORTSIZE_S_we_ram=2,
    BITSIZE_out1=1, PORTSIZE_out1=2,
    BITSIZE_S_addr_ram=1, PORTSIZE_S_addr_ram=2,
    BITSIZE_S_Wdata_ram=8, PORTSIZE_S_Wdata_ram=2,
    BITSIZE_Sin_Rdata_ram=8, PORTSIZE_Sin_Rdata_ram=2,
    BITSIZE_Sout_Rdata_ram=8, PORTSIZE_Sout_Rdata_ram=2,
    BITSIZE_S_data_ram_size=1, PORTSIZE_S_data_ram_size=2,
    BITSIZE_Sin_DataRdy=1, PORTSIZE_Sin_DataRdy=2,
    BITSIZE_Sout_DataRdy=1, PORTSIZE_Sout_DataRdy=2,
    MEMORY_INIT_file="array.mem",
    n_elements=1,
    data_size=32,
    address_space_begin=0,
    address_space_rangesize=4,
    BUS_PIPELINED=1,
    PRIVATE_MEMORY=0,
    READ_ONLY_MEMORY=0,
    USE_SPARSE_MEMORY=1,
    HIGH_LATENCY=0,
    ALIGNMENT=32,
    BITSIZE_proxy_in1=1, PORTSIZE_proxy_in1=2,
    BITSIZE_proxy_in2r=1, PORTSIZE_proxy_in2r=2,
    BITSIZE_proxy_in2w=1, PORTSIZE_proxy_in2w=2,
    BITSIZE_proxy_in3r=1, PORTSIZE_proxy_in3r=2,
    BITSIZE_proxy_in3w=1, PORTSIZE_proxy_in3w=2,
    BITSIZE_proxy_in4r=1, PORTSIZE_proxy_in4r=2,
    BITSIZE_proxy_in4w=1, PORTSIZE_proxy_in4w=2,
    BITSIZE_proxy_sel_LOAD=1, PORTSIZE_proxy_sel_LOAD=2,
    BITSIZE_proxy_sel_STORE=1, PORTSIZE_proxy_sel_STORE=2,
    BITSIZE_proxy_out1=1, PORTSIZE_proxy_out1=2;
  // IN
  input clock;
  input reset;
  input [(PORTSIZE_in1*BITSIZE_in1)+(-1):0] in1;
  input [(PORTSIZE_in2r*BITSIZE_in2r)+(-1):0] in2r;
  input [(PORTSIZE_in2w*BITSIZE_in2w)+(-1):0] in2w;
  input [(PORTSIZE_in3r*BITSIZE_in3r)+(-1):0] in3r;
  input [(PORTSIZE_in3w*BITSIZE_in3w)+(-1):0] in3w;
  input [PORTSIZE_in4r-1:0] in4r;
  input [PORTSIZE_in4w-1:0] in4w;
  input [PORTSIZE_sel_LOAD-1:0] sel_LOAD;
  input [PORTSIZE_sel_STORE-1:0] sel_STORE;
  input [PORTSIZE_S_oe_ram-1:0] S_oe_ram;
  input [PORTSIZE_S_we_ram-1:0] S_we_ram;
  input [(PORTSIZE_S_addr_ram*BITSIZE_S_addr_ram)+(-1):0] S_addr_ram;
  input [(PORTSIZE_S_Wdata_ram*BITSIZE_S_Wdata_ram)+(-1):0] S_Wdata_ram;
  input [(PORTSIZE_Sin_Rdata_ram*BITSIZE_Sin_Rdata_ram)+(-1):0] Sin_Rdata_ram;
  input [(PORTSIZE_S_data_ram_size*BITSIZE_S_data_ram_size)+(-1):0] S_data_ram_size;
  input [PORTSIZE_Sin_DataRdy-1:0] Sin_DataRdy;
  input [(PORTSIZE_proxy_in1*BITSIZE_proxy_in1)+(-1):0] proxy_in1;
  input [(PORTSIZE_proxy_in2r*BITSIZE_proxy_in2r)+(-1):0] proxy_in2r;
  input [(PORTSIZE_proxy_in2w*BITSIZE_proxy_in2w)+(-1):0] proxy_in2w;
  input [(PORTSIZE_proxy_in3r*BITSIZE_proxy_in3r)+(-1):0] proxy_in3r;
  input [(PORTSIZE_proxy_in3w*BITSIZE_proxy_in3w)+(-1):0] proxy_in3w;
  input [(PORTSIZE_proxy_in4r*BITSIZE_proxy_in4r)+(-1):0] proxy_in4r;
  input [(PORTSIZE_proxy_in4w*BITSIZE_proxy_in4w)+(-1):0] proxy_in4w;
  input [PORTSIZE_proxy_sel_LOAD-1:0] proxy_sel_LOAD;
  input [PORTSIZE_proxy_sel_STORE-1:0] proxy_sel_STORE;
  // OUT
  output [(PORTSIZE_out1*BITSIZE_out1)+(-1):0] out1;
  output [(PORTSIZE_Sout_Rdata_ram*BITSIZE_Sout_Rdata_ram)+(-1):0] Sout_Rdata_ram;
  output [PORTSIZE_Sout_DataRdy-1:0] Sout_DataRdy;
  output [(PORTSIZE_proxy_out1*BITSIZE_proxy_out1)+(-1):0] proxy_out1;
  
  `ifndef _SIM_HAVE_CLOG2
    function integer log2;
       input integer value;
       integer temp_value;
      begin
        temp_value = value-1;
        for (log2=0; temp_value>0; log2=log2+1)
          temp_value = temp_value>>1;
      end
    endfunction
  `endif
  parameter n_byte_on_databus = ALIGNMENT/8;
  parameter nbit_addr_r = BITSIZE_in2r > BITSIZE_proxy_in2r ? BITSIZE_in2r : BITSIZE_proxy_in2r;
  parameter nbit_addr_w = BITSIZE_in2w > BITSIZE_proxy_in2w ? BITSIZE_in2w : BITSIZE_proxy_in2w;
  `ifdef _SIM_HAVE_CLOG2
    localparam nbit_read_addr = n_elements == 1 ? 1 : $clog2(n_elements);
    localparam nbits_byte_offset = n_byte_on_databus<=1 ? 0 : $clog2(n_byte_on_databus);
  `else
    localparam nbit_read_addr = n_elements == 1 ? 1 : log2(n_elements);
    localparam nbits_byte_offset = n_byte_on_databus<=1 ? 0 : log2(n_byte_on_databus);
  `endif
  parameter max_n_writes = READ_ONLY_MEMORY ? 1 : PORTSIZE_sel_STORE;
  parameter max_n_reads = PORTSIZE_sel_LOAD;
  
  wire [nbit_read_addr*max_n_reads-1:0] memory_addr_a_r;
  wire [nbit_read_addr*max_n_writes-1:0] memory_addr_a_w;
  
  wire [max_n_writes-1:0] bram_write;
  
  wire [data_size*max_n_reads-1:0] dout_a;
  wire [nbit_addr_r*max_n_reads-1:0] relative_addr_r;
  wire [nbit_addr_w*max_n_writes-1:0] relative_addr_w;
  wire [nbit_addr_r*max_n_reads-1:0] tmp_addr_r;
  wire [nbit_addr_w*max_n_writes-1:0] tmp_addr_w;
  wire [data_size*max_n_writes-1:0] din_a;
  wire [data_size*max_n_writes-1:0] din_a_mem;
  reg [data_size*max_n_writes-1:0] din_a1;
  
  STD_NRNW_BRAM_GEN #(
    .PORTSIZE_write_enable(max_n_writes),
    .BITSIZE_write_enable(1),
    .PORTSIZE_data_in(max_n_writes),
    .BITSIZE_data_in(data_size),
    .PORTSIZE_dout_value(max_n_reads),
    .BITSIZE_dout_value(data_size),
    .PORTSIZE_address_inr(max_n_reads),
    .BITSIZE_address_inr(nbit_read_addr),
    .PORTSIZE_address_inw(max_n_writes),
    .BITSIZE_address_inw(nbit_read_addr),
    .n_elements(n_elements),
    .MEMORY_INIT_file(MEMORY_INIT_file),
    .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
    .HIGH_LATENCY(HIGH_LATENCY)
  ) STD_NRNW_BRAM_GEN_instance (
    .clock(clock),
    .write_enable(bram_write),
    .data_in(din_a),
    .address_inr(memory_addr_a_r),
    .address_inw(memory_addr_a_w),
    .dout_value(dout_a)
  );
  
  generate
  genvar i14;
    for (i14=0; i14<max_n_writes; i14=i14+1)
    begin : L14
      assign din_a[(i14+1)*data_size-1:i14*data_size] = (proxy_sel_STORE[i14] && proxy_in4w[i14]) ? proxy_in1[(i14+1)*BITSIZE_proxy_in1-1:i14*BITSIZE_proxy_in1] : in1[(i14+1)*BITSIZE_in1-1:i14*BITSIZE_in1];
    end
  endgenerate
  
  generate
  genvar i21;
    for (i21=0; i21<max_n_writes; i21=i21+1)
    begin : L21
        assign bram_write[i21] = (sel_STORE[i21] && in4w[i21]) || (proxy_sel_STORE[i21] && proxy_in4w[i21]);
    end
  endgenerate
  
  generate
  genvar ind2r;
  for (ind2r=0; ind2r<max_n_reads; ind2r=ind2r+1)
    begin : Lind2r
      assign tmp_addr_r[(ind2r+1)*nbit_addr_r-1:ind2r*nbit_addr_r] = (proxy_sel_LOAD[ind2r] && proxy_in4r[ind2r]) ? proxy_in2r[(ind2r+1)*BITSIZE_proxy_in2r-1:ind2r*BITSIZE_proxy_in2r] : in2r[(ind2r+1)*BITSIZE_in2r-1:ind2r*BITSIZE_in2r];
    end
  endgenerate
  
  generate
  genvar ind2w;
  for (ind2w=0; ind2w<max_n_writes; ind2w=ind2w+1)
    begin : Lind2w
      assign tmp_addr_w[(ind2w+1)*nbit_addr_w-1:ind2w*nbit_addr_w] = (proxy_sel_STORE[ind2w] && proxy_in4w[ind2w]) ? proxy_in2w[(ind2w+1)*BITSIZE_proxy_in2w-1:ind2w*BITSIZE_proxy_in2w] : in2w[(ind2w+1)*BITSIZE_in2w-1:ind2w*BITSIZE_in2w];
    end
  endgenerate
  
  generate
  genvar i6r;
    for (i6r=0; i6r<max_n_reads; i6r=i6r+1)
    begin : L6r
      if(USE_SPARSE_MEMORY==1)
        assign relative_addr_r[(i6r+1)*nbit_addr_r-1:i6r*nbit_addr_r] = tmp_addr_r[(i6r+1)*nbit_addr_r-1:i6r*nbit_addr_r];
      else
        assign relative_addr_r[(i6r+1)*nbit_addr_r-1:i6r*nbit_addr_r] = tmp_addr_r[(i6r+1)*nbit_addr_r-1:i6r*nbit_addr_r]-address_space_begin;
    end
  endgenerate
  
  generate
  genvar i6w;
    for (i6w=0; i6w<max_n_writes; i6w=i6w+1)
    begin : L6w
      if(USE_SPARSE_MEMORY==1)
        assign relative_addr_w[(i6w+1)*nbit_addr_w-1:i6w*nbit_addr_w] = tmp_addr_w[(i6w+1)*nbit_addr_w-1:i6w*nbit_addr_w];
      else
        assign relative_addr_w[(i6w+1)*nbit_addr_w-1:i6w*nbit_addr_w] = tmp_addr_w[(i6w+1)*nbit_addr_w-1:i6w*nbit_addr_w]-address_space_begin;
    end
  endgenerate
  
  generate
  genvar i7r;
    for (i7r=0; i7r<max_n_reads; i7r=i7r+1)
    begin : L7_Ar
      if (n_elements==1)
        assign memory_addr_a_r[(i7r+1)*nbit_read_addr-1:i7r*nbit_read_addr] = {nbit_read_addr{1'b0}};
      else
        assign memory_addr_a_r[(i7r+1)*nbit_read_addr-1:i7r*nbit_read_addr] = relative_addr_r[nbit_read_addr+nbits_byte_offset-1+i7r*nbit_addr_r:nbits_byte_offset+i7r*nbit_addr_r];
    end
  endgenerate
  
  generate
  genvar i7w;
    for (i7w=0; i7w<max_n_writes; i7w=i7w+1)
    begin : L7_Aw
      if (n_elements==1)
        assign memory_addr_a_w[(i7w+1)*nbit_read_addr-1:i7w*nbit_read_addr] = {nbit_read_addr{1'b0}};
      else
        assign memory_addr_a_w[(i7w+1)*nbit_read_addr-1:i7w*nbit_read_addr] = relative_addr_w[nbit_read_addr+nbits_byte_offset-1+i7w*nbit_addr_w:nbits_byte_offset+i7w*nbit_addr_w];
    end
  endgenerate
  
  assign out1 = dout_a;
  assign proxy_out1 = dout_a;
  assign Sout_Rdata_ram =Sin_Rdata_ram;
  assign Sout_DataRdy = Sin_DataRdy;

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ARRAY_1D_STD_BRAM_NN_SDS(clock,
  reset,
  in1,
  in2r,
  in2w,
  in3r,
  in3w,
  in4r,
  in4w,
  out1,
  sel_LOAD,
  sel_STORE,
  S_oe_ram,
  S_we_ram,
  S_addr_ram,
  S_Wdata_ram,
  Sin_Rdata_ram,
  Sout_Rdata_ram,
  S_data_ram_size,
  Sin_DataRdy,
  Sout_DataRdy,
  proxy_in1,
  proxy_in2r,
  proxy_in2w,
  proxy_in3r,
  proxy_in3w,
  proxy_in4r,
  proxy_in4w,
  proxy_sel_LOAD,
  proxy_sel_STORE,
  proxy_out1);
  parameter BITSIZE_in1=1, PORTSIZE_in1=2,
    BITSIZE_in2r=1, PORTSIZE_in2r=2,
    BITSIZE_in2w=1, PORTSIZE_in2w=2,
    BITSIZE_in3r=1, PORTSIZE_in3r=2,
    BITSIZE_in3w=1, PORTSIZE_in3w=2,
    BITSIZE_in4r=1, PORTSIZE_in4r=2,
    BITSIZE_in4w=1, PORTSIZE_in4w=2,
    BITSIZE_sel_LOAD=1, PORTSIZE_sel_LOAD=2,
    BITSIZE_sel_STORE=1, PORTSIZE_sel_STORE=2,
    BITSIZE_S_oe_ram=1, PORTSIZE_S_oe_ram=2,
    BITSIZE_S_we_ram=1, PORTSIZE_S_we_ram=2,
    BITSIZE_out1=1, PORTSIZE_out1=2,
    BITSIZE_S_addr_ram=1, PORTSIZE_S_addr_ram=2,
    BITSIZE_S_Wdata_ram=8, PORTSIZE_S_Wdata_ram=2,
    BITSIZE_Sin_Rdata_ram=8, PORTSIZE_Sin_Rdata_ram=2,
    BITSIZE_Sout_Rdata_ram=8, PORTSIZE_Sout_Rdata_ram=2,
    BITSIZE_S_data_ram_size=1, PORTSIZE_S_data_ram_size=2,
    BITSIZE_Sin_DataRdy=1, PORTSIZE_Sin_DataRdy=2,
    BITSIZE_Sout_DataRdy=1, PORTSIZE_Sout_DataRdy=2,
    MEMORY_INIT_file="array.mem",
    n_elements=1,
    data_size=32,
    address_space_begin=0,
    address_space_rangesize=4,
    BUS_PIPELINED=1,
    PRIVATE_MEMORY=0,
    READ_ONLY_MEMORY=0,
    USE_SPARSE_MEMORY=1,
    ALIGNMENT=32,
    BITSIZE_proxy_in1=1, PORTSIZE_proxy_in1=2,
    BITSIZE_proxy_in2r=1, PORTSIZE_proxy_in2r=2,
    BITSIZE_proxy_in2w=1, PORTSIZE_proxy_in2w=2,
    BITSIZE_proxy_in3r=1, PORTSIZE_proxy_in3r=2,
    BITSIZE_proxy_in3w=1, PORTSIZE_proxy_in3w=2,
    BITSIZE_proxy_in4r=1, PORTSIZE_proxy_in4r=2,
    BITSIZE_proxy_in4w=1, PORTSIZE_proxy_in4w=2,
    BITSIZE_proxy_sel_LOAD=1, PORTSIZE_proxy_sel_LOAD=2,
    BITSIZE_proxy_sel_STORE=1, PORTSIZE_proxy_sel_STORE=2,
    BITSIZE_proxy_out1=1, PORTSIZE_proxy_out1=2;
  // IN
  input clock;
  input reset;
  input [(PORTSIZE_in1*BITSIZE_in1)+(-1):0] in1;
  input [(PORTSIZE_in2r*BITSIZE_in2r)+(-1):0] in2r;
  input [(PORTSIZE_in2w*BITSIZE_in2w)+(-1):0] in2w;
  input [(PORTSIZE_in3r*BITSIZE_in3r)+(-1):0] in3r;
  input [(PORTSIZE_in3w*BITSIZE_in3w)+(-1):0] in3w;
  input [PORTSIZE_in4r-1:0] in4r;
  input [PORTSIZE_in4w-1:0] in4w;
  input [PORTSIZE_sel_LOAD-1:0] sel_LOAD;
  input [PORTSIZE_sel_STORE-1:0] sel_STORE;
  input [PORTSIZE_S_oe_ram-1:0] S_oe_ram;
  input [PORTSIZE_S_we_ram-1:0] S_we_ram;
  input [(PORTSIZE_S_addr_ram*BITSIZE_S_addr_ram)+(-1):0] S_addr_ram;
  input [(PORTSIZE_S_Wdata_ram*BITSIZE_S_Wdata_ram)+(-1):0] S_Wdata_ram;
  input [(PORTSIZE_Sin_Rdata_ram*BITSIZE_Sin_Rdata_ram)+(-1):0] Sin_Rdata_ram;
  input [(PORTSIZE_S_data_ram_size*BITSIZE_S_data_ram_size)+(-1):0] S_data_ram_size;
  input [PORTSIZE_Sin_DataRdy-1:0] Sin_DataRdy;
  input [(PORTSIZE_proxy_in1*BITSIZE_proxy_in1)+(-1):0] proxy_in1;
  input [(PORTSIZE_proxy_in2r*BITSIZE_proxy_in2r)+(-1):0] proxy_in2r;
  input [(PORTSIZE_proxy_in2w*BITSIZE_proxy_in2w)+(-1):0] proxy_in2w;
  input [(PORTSIZE_proxy_in3r*BITSIZE_proxy_in3r)+(-1):0] proxy_in3r;
  input [(PORTSIZE_proxy_in3w*BITSIZE_proxy_in3w)+(-1):0] proxy_in3w;
  input [PORTSIZE_proxy_in4r-1:0] proxy_in4r;
  input [PORTSIZE_proxy_in4w-1:0] proxy_in4w;
  input [PORTSIZE_proxy_sel_LOAD-1:0] proxy_sel_LOAD;
  input [PORTSIZE_proxy_sel_STORE-1:0] proxy_sel_STORE;
  // OUT
  output [(PORTSIZE_out1*BITSIZE_out1)+(-1):0] out1;
  output [(PORTSIZE_Sout_Rdata_ram*BITSIZE_Sout_Rdata_ram)+(-1):0] Sout_Rdata_ram;
  output [PORTSIZE_Sout_DataRdy-1:0] Sout_DataRdy;
  output [(PORTSIZE_proxy_out1*BITSIZE_proxy_out1)+(-1):0] proxy_out1;
  
  ARRAY_1D_STD_BRAM_NN_SDS_BASE #(
    .BITSIZE_in1(BITSIZE_in1),
    .PORTSIZE_in1(PORTSIZE_in1),
    .BITSIZE_in2r(BITSIZE_in2r),
    .PORTSIZE_in2r(PORTSIZE_in2r),
    .BITSIZE_in2w(BITSIZE_in2w),
    .PORTSIZE_in2w(PORTSIZE_in2w),
    .BITSIZE_in3r(BITSIZE_in3r),
    .PORTSIZE_in3r(PORTSIZE_in3r),
    .BITSIZE_in3w(BITSIZE_in3w),
    .PORTSIZE_in3w(PORTSIZE_in3w),
    .BITSIZE_in4r(BITSIZE_in4r),
    .PORTSIZE_in4r(PORTSIZE_in4r),
    .BITSIZE_in4w(BITSIZE_in4w),
    .PORTSIZE_in4w(PORTSIZE_in4w),
    .BITSIZE_sel_LOAD(BITSIZE_sel_LOAD),
    .PORTSIZE_sel_LOAD(PORTSIZE_sel_LOAD),
    .BITSIZE_sel_STORE(BITSIZE_sel_STORE),
    .PORTSIZE_sel_STORE(PORTSIZE_sel_STORE),
    .BITSIZE_S_oe_ram(BITSIZE_S_oe_ram),
    .PORTSIZE_S_oe_ram(PORTSIZE_S_oe_ram),
    .BITSIZE_S_we_ram(BITSIZE_S_we_ram),
    .PORTSIZE_S_we_ram(PORTSIZE_S_we_ram),
    .BITSIZE_out1(BITSIZE_out1),
    .PORTSIZE_out1(PORTSIZE_out1),
    .BITSIZE_S_addr_ram(BITSIZE_S_addr_ram),
    .PORTSIZE_S_addr_ram(PORTSIZE_S_addr_ram),
    .BITSIZE_S_Wdata_ram(BITSIZE_S_Wdata_ram),
    .PORTSIZE_S_Wdata_ram(PORTSIZE_S_Wdata_ram),
    .BITSIZE_Sin_Rdata_ram(BITSIZE_Sin_Rdata_ram),
    .PORTSIZE_Sin_Rdata_ram(PORTSIZE_Sin_Rdata_ram),
    .BITSIZE_Sout_Rdata_ram(BITSIZE_Sout_Rdata_ram),
    .PORTSIZE_Sout_Rdata_ram(PORTSIZE_Sout_Rdata_ram),
    .BITSIZE_S_data_ram_size(BITSIZE_S_data_ram_size),
    .PORTSIZE_S_data_ram_size(PORTSIZE_S_data_ram_size),
    .BITSIZE_Sin_DataRdy(BITSIZE_Sin_DataRdy),
    .PORTSIZE_Sin_DataRdy(PORTSIZE_Sin_DataRdy),
    .BITSIZE_Sout_DataRdy(BITSIZE_Sout_DataRdy),
    .PORTSIZE_Sout_DataRdy(PORTSIZE_Sout_DataRdy),
    .MEMORY_INIT_file(MEMORY_INIT_file),
    .n_elements(n_elements),
    .data_size(data_size),
    .address_space_begin(address_space_begin),
    .address_space_rangesize(address_space_rangesize),
    .BUS_PIPELINED(BUS_PIPELINED),
    .PRIVATE_MEMORY(PRIVATE_MEMORY),
    .READ_ONLY_MEMORY(READ_ONLY_MEMORY),
    .USE_SPARSE_MEMORY(USE_SPARSE_MEMORY),
    .HIGH_LATENCY(0),
    .ALIGNMENT(ALIGNMENT),
    .BITSIZE_proxy_in1(BITSIZE_proxy_in1),
    .PORTSIZE_proxy_in1(PORTSIZE_proxy_in1),
    .BITSIZE_proxy_in2r(BITSIZE_proxy_in2r),
    .PORTSIZE_proxy_in2r(PORTSIZE_proxy_in2r),
    .BITSIZE_proxy_in2w(BITSIZE_proxy_in2w),
    .PORTSIZE_proxy_in2w(PORTSIZE_proxy_in2w),
    .BITSIZE_proxy_in3r(BITSIZE_proxy_in3r),
    .PORTSIZE_proxy_in3r(PORTSIZE_proxy_in3r),
    .BITSIZE_proxy_in3w(BITSIZE_proxy_in3w),
    .PORTSIZE_proxy_in3w(PORTSIZE_proxy_in3w),
    .BITSIZE_proxy_in4r(BITSIZE_proxy_in4r),
    .PORTSIZE_proxy_in4r(PORTSIZE_proxy_in4r),
    .BITSIZE_proxy_in4w(BITSIZE_proxy_in4w),
    .PORTSIZE_proxy_in4w(PORTSIZE_proxy_in4w),
    .BITSIZE_proxy_sel_LOAD(BITSIZE_proxy_sel_LOAD),
    .PORTSIZE_proxy_sel_LOAD(PORTSIZE_proxy_sel_LOAD),
    .BITSIZE_proxy_sel_STORE(BITSIZE_proxy_sel_STORE),
    .PORTSIZE_proxy_sel_STORE(PORTSIZE_proxy_sel_STORE),
    .BITSIZE_proxy_out1(BITSIZE_proxy_out1),
    .PORTSIZE_proxy_out1(PORTSIZE_proxy_out1)) ARRAY_1D_STD_BRAM_NN_instance (.out1(out1),
    .Sout_Rdata_ram(Sout_Rdata_ram),
    .Sout_DataRdy(Sout_DataRdy),
    .proxy_out1(proxy_out1),
    .clock(clock),
    .reset(reset),
    .in1(in1),
    .in2r(in2r),
    .in2w(in2w),
    .in3r(in3r),
    .in3w(in3w),
    .in4r(in4r),
    .in4w(in4w),
    .sel_LOAD(sel_LOAD),
    .sel_STORE(sel_STORE),
    .S_oe_ram(S_oe_ram),
    .S_we_ram(S_we_ram),
    .S_addr_ram(S_addr_ram),
    .S_Wdata_ram(S_Wdata_ram),
    .Sin_Rdata_ram(Sin_Rdata_ram),
    .S_data_ram_size(S_data_ram_size ),
    .Sin_DataRdy(Sin_DataRdy),
    .proxy_in1(proxy_in1),
    .proxy_in2r(proxy_in2r),
    .proxy_in2w(proxy_in2w),
    .proxy_in3r(proxy_in3r),
    .proxy_in3w(proxy_in3w),
    .proxy_in4r(proxy_in4r),
    .proxy_in4w(proxy_in4w),
    .proxy_sel_LOAD(proxy_sel_LOAD),
    .proxy_sel_STORE(proxy_sel_STORE));
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module addr_expr_FU(in1,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = in1;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2020-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module extract_bit_expr_FU(in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1;
  // IN
  input signed [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output out1;
  assign out1 = (in1 >>> in2)&1;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2016-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module lut_expr_FU(in1,
  in2,
  in3,
  in4,
  in5,
  in6,
  in7,
  in8,
  in9,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input in2;
  input in3;
  input in4;
  input in5;
  input in6;
  input in7;
  input in8;
  input in9;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  reg[7:0] cleaned_in0;
  wire [7:0] in0;
  wire[BITSIZE_in1-1:0] shifted_s;
  assign in0 = {in9, in8, in7, in6, in5, in4, in3, in2};
  generate
    genvar i0;
    for (i0=0; i0<8; i0=i0+1)
    begin : L0
          always @(*)
          begin
             if (in0[i0] == 1'b1)
                cleaned_in0[i0] = 1'b1;
             else
                cleaned_in0[i0] = 1'b0;
          end
    end
  endgenerate
  assign shifted_s = in1 >> cleaned_in0;
  assign out1[0] = shifted_s[0];
  generate
     if(BITSIZE_out1 > 1)
       assign out1[BITSIZE_out1-1:1] = 0;
  endgenerate

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module UUdata_converter_FU(in1,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  generate
  if (BITSIZE_out1 <= BITSIZE_in1)
  begin
    assign out1 = in1[BITSIZE_out1-1:0];
  end
  else
  begin
    assign out1 = {{(BITSIZE_out1-BITSIZE_in1){1'b0}},in1};
  end
  endgenerate
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module read_cond_FU(in1,
  out1);
  parameter BITSIZE_in1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  // OUT
  output out1;
  assign out1 = in1 != {BITSIZE_in1{1'b0}};
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module multi_read_cond_FU(in1,
  out1);
  parameter BITSIZE_in1=1, PORTSIZE_in1=2,
    BITSIZE_out1=1;
  // IN
  input [(PORTSIZE_in1*BITSIZE_in1)+(-1):0] in1;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = in1;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_bit_and_expr_FU(in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_out1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = in1 & in2;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2016-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_bit_ior_concat_expr_FU(in1,
  in2,
  in3,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_in3=1,
    BITSIZE_out1=1,
    OFFSET_PARAMETER=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  input [BITSIZE_in3-1:0] in3;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  localparam nbit_out = BITSIZE_out1 > OFFSET_PARAMETER ? BITSIZE_out1 : 1+OFFSET_PARAMETER;
  wire [nbit_out-1:0] tmp_in1;
  wire [OFFSET_PARAMETER-1:0] tmp_in2;
  generate
    if(BITSIZE_in1 >= nbit_out)
      assign tmp_in1=in1[nbit_out-1:0];
    else
      assign tmp_in1={{(nbit_out-BITSIZE_in1){1'b0}},in1};
  endgenerate
  generate
    if(BITSIZE_in2 >= OFFSET_PARAMETER)
      assign tmp_in2=in2[OFFSET_PARAMETER-1:0];
    else
      assign tmp_in2={{(OFFSET_PARAMETER-BITSIZE_in2){1'b0}},in2};
  endgenerate
  assign out1 = {tmp_in1[nbit_out-1:OFFSET_PARAMETER] , tmp_in2};
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_eq_expr_FU(in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_out1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = in1 == in2;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_le_expr_FU(in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_out1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = in1 <= in2;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_lshift_expr_FU(in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_out1=1,
    PRECISION=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  `ifndef _SIM_HAVE_CLOG2
    function integer log2;
       input integer value;
       integer temp_value;
      begin
        temp_value = value-1;
        for (log2=0; temp_value>0; log2=log2+1)
          temp_value = temp_value>>1;
      end
    endfunction
  `endif
  `ifdef _SIM_HAVE_CLOG2
    localparam arg2_bitsize = $clog2(PRECISION);
  `else
    localparam arg2_bitsize = log2(PRECISION);
  `endif
  generate
    if(BITSIZE_in2 > arg2_bitsize)
      assign out1 = in1 << in2[arg2_bitsize-1:0];
    else
      assign out1 = in1 << in2;
  endgenerate
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_plus_expr_FU(in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_out1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = in1 + in2;
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_pointer_plus_expr_FU(in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_out1=1,
    LSB_PARAMETER=-1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  wire [BITSIZE_out1-1:0] in1_tmp;
  wire [BITSIZE_out1-1:0] in2_tmp;
  assign in1_tmp = in1;
  assign in2_tmp = in2;generate if (BITSIZE_out1 > LSB_PARAMETER) assign out1[BITSIZE_out1-1:LSB_PARAMETER] = (in1_tmp[BITSIZE_out1-1:LSB_PARAMETER] + in2_tmp[BITSIZE_out1-1:LSB_PARAMETER]); else assign out1 = 0; endgenerate
  generate if (LSB_PARAMETER != 0 && BITSIZE_out1 > LSB_PARAMETER) assign out1[LSB_PARAMETER-1:0] = 0; endgenerate
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_rshift_expr_FU(in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_out1=1,
    PRECISION=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  `ifndef _SIM_HAVE_CLOG2
    function integer log2;
       input integer value;
       integer temp_value;
      begin
        temp_value = value-1;
        for (log2=0; temp_value>0; log2=log2+1)
          temp_value = temp_value>>1;
      end
    endfunction
  `endif
  `ifdef _SIM_HAVE_CLOG2
    localparam arg2_bitsize = $clog2(PRECISION);
  `else
    localparam arg2_bitsize = log2(PRECISION);
  `endif
  generate
    if(BITSIZE_in2 > arg2_bitsize)
      assign out1 = in1 >> (in2[arg2_bitsize-1:0]);
    else
      assign out1 = in1 >> in2;
  endgenerate

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module IIdata_converter_FU(in1,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input signed [BITSIZE_in1-1:0] in1;
  // OUT
  output signed [BITSIZE_out1-1:0] out1;
  generate
  if (BITSIZE_out1 <= BITSIZE_in1)
  begin
    assign out1 = in1[BITSIZE_out1-1:0];
  end
  else
  begin
    assign out1 = {{(BITSIZE_out1-BITSIZE_in1){in1[BITSIZE_in1-1]}},in1};
  end
  endgenerate
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module IUdata_converter_FU(in1,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input signed [BITSIZE_in1-1:0] in1;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  generate
  if (BITSIZE_out1 <= BITSIZE_in1)
  begin
    assign out1 = in1[BITSIZE_out1-1:0];
  end
  else
  begin
    assign out1 = {{(BITSIZE_out1-BITSIZE_in1){in1[BITSIZE_in1-1]}},in1};
  end
  endgenerate
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>, Christian Pilato <christian.pilato@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module MUX_GATE(sel,
  in1,
  in2,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_in2=1,
    BITSIZE_out1=1;
  // IN
  input sel;
  input [BITSIZE_in1-1:0] in1;
  input [BITSIZE_in2-1:0] in2;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = sel ? in1 : in2;
endmodule

// Datapath RTL description for _Z7man_fibj
// This component has been derived from the input source code and so it does not fall under the copyright of PandA framework, but it follows the input source code copyright, and may be aggregated with components of the BAMBU/PANDA IP LIBRARY.
// Author(s): Component automatically generated by bambu
// License: THIS COMPONENT IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
`timescale 1ns / 1ps
module datapath__Z7man_fibj(clock,
  reset,
  in_port_n,
  return_port,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE,
  selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0,
  selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1,
  selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0,
  selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0,
  selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1,
  selector_MUX_39_gimple_return_FU_66_i0_0_0_0,
  selector_MUX_59_reg_0_0_0_0,
  selector_MUX_59_reg_0_0_0_1,
  selector_MUX_60_reg_1_0_0_0,
  selector_MUX_60_reg_1_0_0_1,
  selector_MUX_71_reg_2_0_0_0,
  selector_MUX_71_reg_2_0_0_1,
  selector_MUX_71_reg_2_0_1_0,
  selector_MUX_79_reg_3_0_0_0,
  selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0,
  selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1,
  selector_MUX_84_reg_8_0_0_0,
  selector_MUX_84_reg_8_0_0_1,
  selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0,
  selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0,
  selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1,
  selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2,
  selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0,
  wrenable_reg_0,
  wrenable_reg_1,
  wrenable_reg_10,
  wrenable_reg_11,
  wrenable_reg_12,
  wrenable_reg_13,
  wrenable_reg_14,
  wrenable_reg_15,
  wrenable_reg_16,
  wrenable_reg_17,
  wrenable_reg_18,
  wrenable_reg_19,
  wrenable_reg_2,
  wrenable_reg_20,
  wrenable_reg_21,
  wrenable_reg_22,
  wrenable_reg_23,
  wrenable_reg_24,
  wrenable_reg_25,
  wrenable_reg_26,
  wrenable_reg_3,
  wrenable_reg_4,
  wrenable_reg_5,
  wrenable_reg_6,
  wrenable_reg_7,
  wrenable_reg_8,
  wrenable_reg_9,
  OUT_CONDITION__Z7man_fibj_35150_35305,
  OUT_CONDITION__Z7man_fibj_35150_35308,
  OUT_CONDITION__Z7man_fibj_35150_35311,
  OUT_CONDITION__Z7man_fibj_35150_35317,
  OUT_MULTIIF__Z7man_fibj_35150_35714);
  parameter MEM_var_35176_35150=2048,
    MEM_var_35193_35150=2048,
    MEM_var_35245_35150=2048;
  // IN
  input clock;
  input reset;
  input [31:0] in_port_n;
  input fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD;
  input fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE;
  input fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD;
  input fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE;
  input fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD;
  input fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE;
  input selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0;
  input selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1;
  input selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0;
  input selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0;
  input selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1;
  input selector_MUX_39_gimple_return_FU_66_i0_0_0_0;
  input selector_MUX_59_reg_0_0_0_0;
  input selector_MUX_59_reg_0_0_0_1;
  input selector_MUX_60_reg_1_0_0_0;
  input selector_MUX_60_reg_1_0_0_1;
  input selector_MUX_71_reg_2_0_0_0;
  input selector_MUX_71_reg_2_0_0_1;
  input selector_MUX_71_reg_2_0_1_0;
  input selector_MUX_79_reg_3_0_0_0;
  input selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0;
  input selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1;
  input selector_MUX_84_reg_8_0_0_0;
  input selector_MUX_84_reg_8_0_0_1;
  input selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0;
  input selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0;
  input selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1;
  input selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2;
  input selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0;
  input wrenable_reg_0;
  input wrenable_reg_1;
  input wrenable_reg_10;
  input wrenable_reg_11;
  input wrenable_reg_12;
  input wrenable_reg_13;
  input wrenable_reg_14;
  input wrenable_reg_15;
  input wrenable_reg_16;
  input wrenable_reg_17;
  input wrenable_reg_18;
  input wrenable_reg_19;
  input wrenable_reg_2;
  input wrenable_reg_20;
  input wrenable_reg_21;
  input wrenable_reg_22;
  input wrenable_reg_23;
  input wrenable_reg_24;
  input wrenable_reg_25;
  input wrenable_reg_26;
  input wrenable_reg_3;
  input wrenable_reg_4;
  input wrenable_reg_5;
  input wrenable_reg_6;
  input wrenable_reg_7;
  input wrenable_reg_8;
  input wrenable_reg_9;
  // OUT
  output [31:0] return_port;
  output OUT_CONDITION__Z7man_fibj_35150_35305;
  output OUT_CONDITION__Z7man_fibj_35150_35308;
  output OUT_CONDITION__Z7man_fibj_35150_35311;
  output OUT_CONDITION__Z7man_fibj_35150_35317;
  output [1:0] OUT_MULTIIF__Z7man_fibj_35150_35714;
  // Component and signal declarations
  wire null_out_signal_array_35176_0_Sout_DataRdy_0;
  wire null_out_signal_array_35176_0_Sout_DataRdy_1;
  wire [31:0] null_out_signal_array_35176_0_Sout_Rdata_ram_0;
  wire [31:0] null_out_signal_array_35176_0_Sout_Rdata_ram_1;
  wire [31:0] null_out_signal_array_35176_0_out1_1;
  wire [31:0] null_out_signal_array_35176_0_proxy_out1_0;
  wire [31:0] null_out_signal_array_35176_0_proxy_out1_1;
  wire null_out_signal_array_35193_0_Sout_DataRdy_0;
  wire null_out_signal_array_35193_0_Sout_DataRdy_1;
  wire [31:0] null_out_signal_array_35193_0_Sout_Rdata_ram_0;
  wire [31:0] null_out_signal_array_35193_0_Sout_Rdata_ram_1;
  wire [31:0] null_out_signal_array_35193_0_out1_1;
  wire [31:0] null_out_signal_array_35193_0_proxy_out1_0;
  wire [31:0] null_out_signal_array_35193_0_proxy_out1_1;
  wire null_out_signal_array_35245_0_Sout_DataRdy_0;
  wire null_out_signal_array_35245_0_Sout_DataRdy_1;
  wire [31:0] null_out_signal_array_35245_0_Sout_Rdata_ram_0;
  wire [31:0] null_out_signal_array_35245_0_Sout_Rdata_ram_1;
  wire [31:0] null_out_signal_array_35245_0_out1_1;
  wire [31:0] null_out_signal_array_35245_0_proxy_out1_0;
  wire [31:0] null_out_signal_array_35245_0_proxy_out1_1;
  wire [31:0] out_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_array_35176_0;
  wire [31:0] out_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_array_35193_0;
  wire [31:0] out_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_array_35245_0;
  wire [31:0] out_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0;
  wire [31:0] out_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1;
  wire [11:0] out_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0;
  wire [11:0] out_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0;
  wire [11:0] out_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1;
  wire [31:0] out_MUX_39_gimple_return_FU_66_i0_0_0_0;
  wire [31:0] out_MUX_59_reg_0_0_0_0;
  wire [31:0] out_MUX_59_reg_0_0_0_1;
  wire [31:0] out_MUX_60_reg_1_0_0_0;
  wire [31:0] out_MUX_60_reg_1_0_0_1;
  wire [31:0] out_MUX_71_reg_2_0_0_0;
  wire [31:0] out_MUX_71_reg_2_0_0_1;
  wire [31:0] out_MUX_71_reg_2_0_1_0;
  wire [2:0] out_MUX_79_reg_3_0_0_0;
  wire [31:0] out_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0;
  wire [31:0] out_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1;
  wire [31:0] out_MUX_84_reg_8_0_0_0;
  wire [31:0] out_MUX_84_reg_8_0_0_1;
  wire [11:0] out_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0;
  wire [11:0] out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0;
  wire [11:0] out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1;
  wire [11:0] out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2;
  wire [11:0] out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0;
  wire [9:0] out_UUdata_converter_FU_35_i0_fu__Z7man_fibj_35150_35556;
  wire [9:0] out_UUdata_converter_FU_36_i0_fu__Z7man_fibj_35150_35574;
  wire [9:0] out_UUdata_converter_FU_37_i0_fu__Z7man_fibj_35150_35510;
  wire [9:0] out_UUdata_converter_FU_61_i0_fu__Z7man_fibj_35150_35430;
  wire [9:0] out_UUdata_converter_FU_62_i0_fu__Z7man_fibj_35150_35443;
  wire [9:0] out_UUdata_converter_FU_64_i0_fu__Z7man_fibj_35150_35394;
  wire [11:0] out_addr_expr_FU_5_i0_fu__Z7man_fibj_35150_35379;
  wire [11:0] out_addr_expr_FU_6_i0_fu__Z7man_fibj_35150_35386;
  wire [11:0] out_addr_expr_FU_7_i0_fu__Z7man_fibj_35150_35566;
  wire out_const_0;
  wire [31:0] out_const_1;
  wire [11:0] out_const_10;
  wire [11:0] out_const_11;
  wire [11:0] out_const_12;
  wire [31:0] out_const_2;
  wire [31:0] out_const_3;
  wire [6:0] out_const_4;
  wire out_const_5;
  wire [1:0] out_const_6;
  wire [2:0] out_const_7;
  wire [30:0] out_const_8;
  wire [31:0] out_const_9;
  wire [2:0] out_conv_out_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_array_35193_0_32_3;
  wire [31:0] out_conv_out_const_0_1_32;
  wire signed [2:0] out_conv_out_const_0_I_1_I_3;
  wire [31:0] out_conv_out_const_10_12_32;
  wire [31:0] out_conv_out_const_11_12_32;
  wire [31:0] out_conv_out_const_12_12_32;
  wire [5:0] out_conv_out_const_4_7_6;
  wire [31:0] out_conv_out_const_5_1_32;
  wire out_extract_bit_expr_FU_31_i0_fu__Z7man_fibj_35150_35730;
  wire out_extract_bit_expr_FU_32_i0_fu__Z7man_fibj_35150_35733;
  wire signed [2:0] out_ii_conv_conn_obj_5_IIdata_converter_FU_ii_conv_0;
  wire [31:0] out_iu_conv_conn_obj_1_IUdata_converter_FU_iu_conv_1;
  wire [31:0] out_iu_conv_conn_obj_6_IUdata_converter_FU_iu_conv_2;
  wire [31:0] out_iu_conv_conn_obj_9_IUdata_converter_FU_iu_conv_3;
  wire out_lut_expr_FU_33_i0_fu__Z7man_fibj_35150_35608;
  wire out_lut_expr_FU_34_i0_fu__Z7man_fibj_35150_35614;
  wire out_lut_expr_FU_38_i0_fu__Z7man_fibj_35150_35720;
  wire [1:0] out_multi_read_cond_FU_67_i0_fu__Z7man_fibj_35150_35714;
  wire out_read_cond_FU_39_i0_fu__Z7man_fibj_35150_35305;
  wire out_read_cond_FU_63_i0_fu__Z7man_fibj_35150_35308;
  wire out_read_cond_FU_65_i0_fu__Z7man_fibj_35150_35311;
  wire out_read_cond_FU_68_i0_fu__Z7man_fibj_35150_35317;
  wire [31:0] out_reg_0_reg_0;
  wire [11:0] out_reg_10_reg_10;
  wire [11:0] out_reg_11_reg_11;
  wire [11:0] out_reg_12_reg_12;
  wire [11:0] out_reg_13_reg_13;
  wire out_reg_14_reg_14;
  wire out_reg_15_reg_15;
  wire out_reg_16_reg_16;
  wire [11:0] out_reg_17_reg_17;
  wire [11:0] out_reg_18_reg_18;
  wire [11:0] out_reg_19_reg_19;
  wire [31:0] out_reg_1_reg_1;
  wire [11:0] out_reg_20_reg_20;
  wire [31:0] out_reg_21_reg_21;
  wire [31:0] out_reg_22_reg_22;
  wire [11:0] out_reg_23_reg_23;
  wire [11:0] out_reg_24_reg_24;
  wire [11:0] out_reg_25_reg_25;
  wire [11:0] out_reg_26_reg_26;
  wire [31:0] out_reg_2_reg_2;
  wire [2:0] out_reg_3_reg_3;
  wire [11:0] out_reg_4_reg_4;
  wire [11:0] out_reg_5_reg_5;
  wire [11:0] out_reg_6_reg_6;
  wire [31:0] out_reg_7_reg_7;
  wire [31:0] out_reg_8_reg_8;
  wire [31:0] out_reg_9_reg_9;
  wire [0:0] out_ui_bit_and_expr_FU_1_0_1_69_i0_fu__Z7man_fibj_35150_35649;
  wire [31:0] out_ui_bit_ior_concat_expr_FU_70_i0_fu__Z7man_fibj_35150_35273;
  wire out_ui_eq_expr_FU_32_0_32_71_i0_fu__Z7man_fibj_35150_35612;
  wire out_ui_eq_expr_FU_32_0_32_71_i1_fu__Z7man_fibj_35150_35618;
  wire out_ui_le_expr_FU_32_0_32_72_i0_fu__Z7man_fibj_35150_35610;
  wire [11:0] out_ui_lshift_expr_FU_16_0_16_73_i0_fu__Z7man_fibj_35150_35397;
  wire [11:0] out_ui_lshift_expr_FU_16_0_16_73_i1_fu__Z7man_fibj_35150_35433;
  wire [11:0] out_ui_lshift_expr_FU_16_0_16_73_i2_fu__Z7man_fibj_35150_35446;
  wire [11:0] out_ui_lshift_expr_FU_16_0_16_73_i3_fu__Z7man_fibj_35150_35513;
  wire [11:0] out_ui_lshift_expr_FU_16_0_16_73_i4_fu__Z7man_fibj_35150_35559;
  wire [11:0] out_ui_lshift_expr_FU_16_0_16_73_i5_fu__Z7man_fibj_35150_35577;
  wire [31:0] out_ui_lshift_expr_FU_32_0_32_74_i0_fu__Z7man_fibj_35150_35646;
  wire [31:0] out_ui_plus_expr_FU_32_0_32_75_i0_fu__Z7man_fibj_35150_35211;
  wire [31:0] out_ui_plus_expr_FU_32_0_32_75_i1_fu__Z7man_fibj_35150_35225;
  wire [31:0] out_ui_plus_expr_FU_32_0_32_76_i0_fu__Z7man_fibj_35150_35219;
  wire [31:0] out_ui_plus_expr_FU_32_0_32_76_i1_fu__Z7man_fibj_35150_35223;
  wire [31:0] out_ui_plus_expr_FU_32_0_32_77_i0_fu__Z7man_fibj_35150_35282;
  wire [30:0] out_ui_plus_expr_FU_32_0_32_78_i0_fu__Z7man_fibj_35150_35643;
  wire [31:0] out_ui_plus_expr_FU_32_32_32_79_i0_fu__Z7man_fibj_35150_35234;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i0_fu__Z7man_fibj_35150_35400;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i10_fu__Z7man_fibj_35150_35593;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i1_fu__Z7man_fibj_35150_35413;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i2_fu__Z7man_fibj_35150_35436;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i3_fu__Z7man_fibj_35150_35449;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i4_fu__Z7man_fibj_35150_35462;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i5_fu__Z7man_fibj_35150_35503;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i6_fu__Z7man_fibj_35150_35516;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i7_fu__Z7man_fibj_35150_35529;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i8_fu__Z7man_fibj_35150_35562;
  wire [11:0] out_ui_pointer_plus_expr_FU_16_16_16_80_i9_fu__Z7man_fibj_35150_35580;
  wire [30:0] out_ui_rshift_expr_FU_32_0_32_81_i0_fu__Z7man_fibj_35150_35638;
  wire [31:0] out_uu_conv_conn_obj_0_UUdata_converter_FU_uu_conv_4;
  wire [31:0] out_uu_conv_conn_obj_10_UUdata_converter_FU_uu_conv_5;
  wire [31:0] out_uu_conv_conn_obj_2_UUdata_converter_FU_uu_conv_6;
  wire [31:0] out_uu_conv_conn_obj_3_UUdata_converter_FU_uu_conv_7;
  wire [31:0] out_uu_conv_conn_obj_4_UUdata_converter_FU_uu_conv_8;
  wire [31:0] out_uu_conv_conn_obj_7_UUdata_converter_FU_uu_conv_9;
  wire [31:0] out_uu_conv_conn_obj_8_UUdata_converter_FU_uu_conv_10;
  
  IIdata_converter_FU #(.BITSIZE_in1(3),
    .BITSIZE_out1(3)) IIdata_converter_FU_ii_conv_0 (.out1(out_ii_conv_conn_obj_5_IIdata_converter_FU_ii_conv_0),
    .in1(out_conv_out_const_0_I_1_I_3));
  IUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) IUdata_converter_FU_iu_conv_1 (.out1(out_iu_conv_conn_obj_1_IUdata_converter_FU_iu_conv_1),
    .in1(out_const_1));
  IUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) IUdata_converter_FU_iu_conv_2 (.out1(out_iu_conv_conn_obj_6_IUdata_converter_FU_iu_conv_2),
    .in1(out_const_2));
  IUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) IUdata_converter_FU_iu_conv_3 (.out1(out_iu_conv_conn_obj_9_IUdata_converter_FU_iu_conv_3),
    .in1(out_const_3));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0 (.out1(out_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0),
    .sel(selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0),
    .in1(out_uu_conv_conn_obj_0_UUdata_converter_FU_uu_conv_4),
    .in2(out_uu_conv_conn_obj_10_UUdata_converter_FU_uu_conv_5));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1 (.out1(out_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1),
    .sel(selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1),
    .in1(out_uu_conv_conn_obj_7_UUdata_converter_FU_uu_conv_9),
    .in2(out_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0));
  MUX_GATE #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12)) MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0 (.out1(out_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0),
    .sel(selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0),
    .in1(out_reg_18_reg_18),
    .in2(out_ui_pointer_plus_expr_FU_16_16_16_80_i1_fu__Z7man_fibj_35150_35413));
  MUX_GATE #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12)) MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0 (.out1(out_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0),
    .sel(selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0),
    .in1(out_reg_20_reg_20),
    .in2(out_addr_expr_FU_5_i0_fu__Z7man_fibj_35150_35379));
  MUX_GATE #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12)) MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1 (.out1(out_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1),
    .sel(selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i4_fu__Z7man_fibj_35150_35462),
    .in2(out_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_39_gimple_return_FU_66_i0_0_0_0 (.out1(out_MUX_39_gimple_return_FU_66_i0_0_0_0),
    .sel(selector_MUX_39_gimple_return_FU_66_i0_0_0_0),
    .in1(out_reg_1_reg_1),
    .in2(out_conv_out_const_5_1_32));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_59_reg_0_0_0_0 (.out1(out_MUX_59_reg_0_0_0_0),
    .sel(selector_MUX_59_reg_0_0_0_0),
    .in1(out_reg_7_reg_7),
    .in2(out_ui_plus_expr_FU_32_0_32_75_i0_fu__Z7man_fibj_35150_35211));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_59_reg_0_0_0_1 (.out1(out_MUX_59_reg_0_0_0_1),
    .sel(selector_MUX_59_reg_0_0_0_1),
    .in1(out_uu_conv_conn_obj_2_UUdata_converter_FU_uu_conv_6),
    .in2(out_MUX_59_reg_0_0_0_0));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_60_reg_1_0_0_0 (.out1(out_MUX_60_reg_1_0_0_0),
    .sel(selector_MUX_60_reg_1_0_0_0),
    .in1(out_ui_plus_expr_FU_32_32_32_79_i0_fu__Z7man_fibj_35150_35234),
    .in2(out_uu_conv_conn_obj_3_UUdata_converter_FU_uu_conv_7));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_60_reg_1_0_0_1 (.out1(out_MUX_60_reg_1_0_0_1),
    .sel(selector_MUX_60_reg_1_0_0_1),
    .in1(out_uu_conv_conn_obj_4_UUdata_converter_FU_uu_conv_8),
    .in2(out_MUX_60_reg_1_0_0_0));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_71_reg_2_0_0_0 (.out1(out_MUX_71_reg_2_0_0_0),
    .sel(selector_MUX_71_reg_2_0_0_0),
    .in1(out_reg_9_reg_9),
    .in2(out_reg_22_reg_22));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_71_reg_2_0_0_1 (.out1(out_MUX_71_reg_2_0_0_1),
    .sel(selector_MUX_71_reg_2_0_0_1),
    .in1(out_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_array_35176_0),
    .in2(in_port_n));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_71_reg_2_0_1_0 (.out1(out_MUX_71_reg_2_0_1_0),
    .sel(selector_MUX_71_reg_2_0_1_0),
    .in1(out_MUX_71_reg_2_0_0_0),
    .in2(out_MUX_71_reg_2_0_0_1));
  MUX_GATE #(.BITSIZE_in1(3),
    .BITSIZE_in2(3),
    .BITSIZE_out1(3)) MUX_79_reg_3_0_0_0 (.out1(out_MUX_79_reg_3_0_0_0),
    .sel(selector_MUX_79_reg_3_0_0_0),
    .in1(out_conv_out_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_array_35193_0_32_3),
    .in2(out_ii_conv_conn_obj_5_IIdata_converter_FU_ii_conv_0));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0 (.out1(out_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0),
    .sel(selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0),
    .in1(out_iu_conv_conn_obj_1_IUdata_converter_FU_iu_conv_1),
    .in2(out_iu_conv_conn_obj_6_IUdata_converter_FU_iu_conv_2));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1 (.out1(out_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1),
    .sel(selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1),
    .in1(out_iu_conv_conn_obj_9_IUdata_converter_FU_iu_conv_3),
    .in2(out_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_84_reg_8_0_0_0 (.out1(out_MUX_84_reg_8_0_0_0),
    .sel(selector_MUX_84_reg_8_0_0_0),
    .in1(out_reg_21_reg_21),
    .in2(out_reg_0_reg_0));
  MUX_GATE #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) MUX_84_reg_8_0_0_1 (.out1(out_MUX_84_reg_8_0_0_1),
    .sel(selector_MUX_84_reg_8_0_0_1),
    .in1(out_ui_plus_expr_FU_32_0_32_76_i0_fu__Z7man_fibj_35150_35219),
    .in2(out_MUX_84_reg_8_0_0_0));
  MUX_GATE #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12)) MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0 (.out1(out_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0),
    .sel(selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0),
    .in1(out_reg_17_reg_17),
    .in2(out_ui_pointer_plus_expr_FU_16_16_16_80_i0_fu__Z7man_fibj_35150_35400));
  MUX_GATE #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12)) MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0 (.out1(out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0),
    .sel(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0),
    .in1(out_reg_25_reg_25),
    .in2(out_reg_23_reg_23));
  MUX_GATE #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12)) MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1 (.out1(out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1),
    .sel(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1),
    .in1(out_reg_19_reg_19),
    .in2(out_reg_10_reg_10));
  MUX_GATE #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12)) MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2 (.out1(out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2),
    .sel(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2),
    .in1(out_addr_expr_FU_6_i0_fu__Z7man_fibj_35150_35386),
    .in2(out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0));
  MUX_GATE #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12)) MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0 (.out1(out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0),
    .sel(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0),
    .in1(out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1),
    .in2(out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) UUdata_converter_FU_uu_conv_10 (.out1(out_uu_conv_conn_obj_8_UUdata_converter_FU_uu_conv_10),
    .in1(out_reg_1_reg_1));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) UUdata_converter_FU_uu_conv_4 (.out1(out_uu_conv_conn_obj_0_UUdata_converter_FU_uu_conv_4),
    .in1(in_port_n));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) UUdata_converter_FU_uu_conv_5 (.out1(out_uu_conv_conn_obj_10_UUdata_converter_FU_uu_conv_5),
    .in1(out_reg_9_reg_9));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) UUdata_converter_FU_uu_conv_6 (.out1(out_uu_conv_conn_obj_2_UUdata_converter_FU_uu_conv_6),
    .in1(out_conv_out_const_0_1_32));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) UUdata_converter_FU_uu_conv_7 (.out1(out_uu_conv_conn_obj_3_UUdata_converter_FU_uu_conv_7),
    .in1(out_conv_out_const_5_1_32));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) UUdata_converter_FU_uu_conv_8 (.out1(out_uu_conv_conn_obj_4_UUdata_converter_FU_uu_conv_8),
    .in1(out_conv_out_const_0_1_32));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) UUdata_converter_FU_uu_conv_9 (.out1(out_uu_conv_conn_obj_7_UUdata_converter_FU_uu_conv_9),
    .in1(out_reg_22_reg_22));
  ARRAY_1D_STD_BRAM_NN_SDS #(.BITSIZE_in1(32),
    .PORTSIZE_in1(2),
    .BITSIZE_in2r(12),
    .PORTSIZE_in2r(2),
    .BITSIZE_in2w(12),
    .PORTSIZE_in2w(2),
    .BITSIZE_in3r(6),
    .PORTSIZE_in3r(2),
    .BITSIZE_in3w(6),
    .PORTSIZE_in3w(2),
    .BITSIZE_in4r(1),
    .PORTSIZE_in4r(2),
    .BITSIZE_in4w(1),
    .PORTSIZE_in4w(2),
    .BITSIZE_sel_LOAD(1),
    .PORTSIZE_sel_LOAD(2),
    .BITSIZE_sel_STORE(1),
    .PORTSIZE_sel_STORE(2),
    .BITSIZE_S_oe_ram(1),
    .PORTSIZE_S_oe_ram(2),
    .BITSIZE_S_we_ram(1),
    .PORTSIZE_S_we_ram(2),
    .BITSIZE_out1(32),
    .PORTSIZE_out1(2),
    .BITSIZE_S_addr_ram(12),
    .PORTSIZE_S_addr_ram(2),
    .BITSIZE_S_Wdata_ram(32),
    .PORTSIZE_S_Wdata_ram(2),
    .BITSIZE_Sin_Rdata_ram(32),
    .PORTSIZE_Sin_Rdata_ram(2),
    .BITSIZE_Sout_Rdata_ram(32),
    .PORTSIZE_Sout_Rdata_ram(2),
    .BITSIZE_S_data_ram_size(6),
    .PORTSIZE_S_data_ram_size(2),
    .BITSIZE_Sin_DataRdy(1),
    .PORTSIZE_Sin_DataRdy(2),
    .BITSIZE_Sout_DataRdy(1),
    .PORTSIZE_Sout_DataRdy(2),
    .MEMORY_INIT_file("array_ref_35176.mem"),
    .n_elements(512),
    .data_size(32),
    .address_space_begin(MEM_var_35176_35150),
    .address_space_rangesize(2048),
    .BUS_PIPELINED(1),
    .PRIVATE_MEMORY(1),
    .READ_ONLY_MEMORY(0),
    .USE_SPARSE_MEMORY(1),
    .ALIGNMENT(32),
    .BITSIZE_proxy_in1(32),
    .PORTSIZE_proxy_in1(2),
    .BITSIZE_proxy_in2r(12),
    .PORTSIZE_proxy_in2r(2),
    .BITSIZE_proxy_in2w(12),
    .PORTSIZE_proxy_in2w(2),
    .BITSIZE_proxy_in3r(6),
    .PORTSIZE_proxy_in3r(2),
    .BITSIZE_proxy_in3w(6),
    .PORTSIZE_proxy_in3w(2),
    .BITSIZE_proxy_in4r(1),
    .PORTSIZE_proxy_in4r(2),
    .BITSIZE_proxy_in4w(1),
    .PORTSIZE_proxy_in4w(2),
    .BITSIZE_proxy_sel_LOAD(1),
    .PORTSIZE_proxy_sel_LOAD(2),
    .BITSIZE_proxy_sel_STORE(1),
    .PORTSIZE_proxy_sel_STORE(2),
    .BITSIZE_proxy_out1(32),
    .PORTSIZE_proxy_out1(2)) array_35176_0 (.out1({null_out_signal_array_35176_0_out1_1,
      out_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_array_35176_0}),
    .Sout_Rdata_ram({null_out_signal_array_35176_0_Sout_Rdata_ram_1,
      null_out_signal_array_35176_0_Sout_Rdata_ram_0}),
    .Sout_DataRdy({null_out_signal_array_35176_0_Sout_DataRdy_1,
      null_out_signal_array_35176_0_Sout_DataRdy_0}),
    .proxy_out1({null_out_signal_array_35176_0_proxy_out1_1,
      null_out_signal_array_35176_0_proxy_out1_0}),
    .clock(clock),
    .reset(reset),
    .in1({32'b00000000000000000000000000000000,
      out_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1}),
    .in2r({12'b000000000000,
      out_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0}),
    .in2w({12'b000000000000,
      out_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1}),
    .in3r({6'b000000,
      out_conv_out_const_4_7_6}),
    .in3w({6'b000000,
      out_conv_out_const_4_7_6}),
    .in4r({1'b0,
      out_const_5}),
    .in4w({1'b0,
      out_const_5}),
    .sel_LOAD({1'b0,
      fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD}),
    .sel_STORE({1'b0,
      fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE}),
    .S_oe_ram({1'b0,
      1'b0}),
    .S_we_ram({1'b0,
      1'b0}),
    .S_addr_ram({12'b000000000000,
      12'b000000000000}),
    .S_Wdata_ram({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .Sin_Rdata_ram({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .S_data_ram_size({6'b000000,
      6'b000000}),
    .Sin_DataRdy({1'b0,
      1'b0}),
    .proxy_in1({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .proxy_in2r({12'b000000000000,
      12'b000000000000}),
    .proxy_in2w({12'b000000000000,
      12'b000000000000}),
    .proxy_in3r({6'b000000,
      6'b000000}),
    .proxy_in3w({6'b000000,
      6'b000000}),
    .proxy_in4r({1'b0,
      1'b0}),
    .proxy_in4w({1'b0,
      1'b0}),
    .proxy_sel_LOAD({1'b0,
      1'b0}),
    .proxy_sel_STORE({1'b0,
      1'b0}));
  ARRAY_1D_STD_BRAM_NN_SDS #(.BITSIZE_in1(32),
    .PORTSIZE_in1(2),
    .BITSIZE_in2r(12),
    .PORTSIZE_in2r(2),
    .BITSIZE_in2w(12),
    .PORTSIZE_in2w(2),
    .BITSIZE_in3r(6),
    .PORTSIZE_in3r(2),
    .BITSIZE_in3w(6),
    .PORTSIZE_in3w(2),
    .BITSIZE_in4r(1),
    .PORTSIZE_in4r(2),
    .BITSIZE_in4w(1),
    .PORTSIZE_in4w(2),
    .BITSIZE_sel_LOAD(1),
    .PORTSIZE_sel_LOAD(2),
    .BITSIZE_sel_STORE(1),
    .PORTSIZE_sel_STORE(2),
    .BITSIZE_S_oe_ram(1),
    .PORTSIZE_S_oe_ram(2),
    .BITSIZE_S_we_ram(1),
    .PORTSIZE_S_we_ram(2),
    .BITSIZE_out1(32),
    .PORTSIZE_out1(2),
    .BITSIZE_S_addr_ram(12),
    .PORTSIZE_S_addr_ram(2),
    .BITSIZE_S_Wdata_ram(32),
    .PORTSIZE_S_Wdata_ram(2),
    .BITSIZE_Sin_Rdata_ram(32),
    .PORTSIZE_Sin_Rdata_ram(2),
    .BITSIZE_Sout_Rdata_ram(32),
    .PORTSIZE_Sout_Rdata_ram(2),
    .BITSIZE_S_data_ram_size(6),
    .PORTSIZE_S_data_ram_size(2),
    .BITSIZE_Sin_DataRdy(1),
    .PORTSIZE_Sin_DataRdy(2),
    .BITSIZE_Sout_DataRdy(1),
    .PORTSIZE_Sout_DataRdy(2),
    .MEMORY_INIT_file("array_ref_35193.mem"),
    .n_elements(512),
    .data_size(32),
    .address_space_begin(MEM_var_35193_35150),
    .address_space_rangesize(2048),
    .BUS_PIPELINED(1),
    .PRIVATE_MEMORY(1),
    .READ_ONLY_MEMORY(0),
    .USE_SPARSE_MEMORY(1),
    .ALIGNMENT(32),
    .BITSIZE_proxy_in1(32),
    .PORTSIZE_proxy_in1(2),
    .BITSIZE_proxy_in2r(12),
    .PORTSIZE_proxy_in2r(2),
    .BITSIZE_proxy_in2w(12),
    .PORTSIZE_proxy_in2w(2),
    .BITSIZE_proxy_in3r(6),
    .PORTSIZE_proxy_in3r(2),
    .BITSIZE_proxy_in3w(6),
    .PORTSIZE_proxy_in3w(2),
    .BITSIZE_proxy_in4r(1),
    .PORTSIZE_proxy_in4r(2),
    .BITSIZE_proxy_in4w(1),
    .PORTSIZE_proxy_in4w(2),
    .BITSIZE_proxy_sel_LOAD(1),
    .PORTSIZE_proxy_sel_LOAD(2),
    .BITSIZE_proxy_sel_STORE(1),
    .PORTSIZE_proxy_sel_STORE(2),
    .BITSIZE_proxy_out1(32),
    .PORTSIZE_proxy_out1(2)) array_35193_0 (.out1({null_out_signal_array_35193_0_out1_1,
      out_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_array_35193_0}),
    .Sout_Rdata_ram({null_out_signal_array_35193_0_Sout_Rdata_ram_1,
      null_out_signal_array_35193_0_Sout_Rdata_ram_0}),
    .Sout_DataRdy({null_out_signal_array_35193_0_Sout_DataRdy_1,
      null_out_signal_array_35193_0_Sout_DataRdy_0}),
    .proxy_out1({null_out_signal_array_35193_0_proxy_out1_1,
      null_out_signal_array_35193_0_proxy_out1_0}),
    .clock(clock),
    .reset(reset),
    .in1({32'b00000000000000000000000000000000,
      out_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1}),
    .in2r({12'b000000000000,
      out_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0}),
    .in2w({12'b000000000000,
      out_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0}),
    .in3r({6'b000000,
      out_conv_out_const_4_7_6}),
    .in3w({6'b000000,
      out_conv_out_const_4_7_6}),
    .in4r({1'b0,
      out_const_5}),
    .in4w({1'b0,
      out_const_5}),
    .sel_LOAD({1'b0,
      fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD}),
    .sel_STORE({1'b0,
      fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE}),
    .S_oe_ram({1'b0,
      1'b0}),
    .S_we_ram({1'b0,
      1'b0}),
    .S_addr_ram({12'b000000000000,
      12'b000000000000}),
    .S_Wdata_ram({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .Sin_Rdata_ram({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .S_data_ram_size({6'b000000,
      6'b000000}),
    .Sin_DataRdy({1'b0,
      1'b0}),
    .proxy_in1({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .proxy_in2r({12'b000000000000,
      12'b000000000000}),
    .proxy_in2w({12'b000000000000,
      12'b000000000000}),
    .proxy_in3r({6'b000000,
      6'b000000}),
    .proxy_in3w({6'b000000,
      6'b000000}),
    .proxy_in4r({1'b0,
      1'b0}),
    .proxy_in4w({1'b0,
      1'b0}),
    .proxy_sel_LOAD({1'b0,
      1'b0}),
    .proxy_sel_STORE({1'b0,
      1'b0}));
  ARRAY_1D_STD_BRAM_NN_SDS #(.BITSIZE_in1(32),
    .PORTSIZE_in1(2),
    .BITSIZE_in2r(12),
    .PORTSIZE_in2r(2),
    .BITSIZE_in2w(12),
    .PORTSIZE_in2w(2),
    .BITSIZE_in3r(6),
    .PORTSIZE_in3r(2),
    .BITSIZE_in3w(6),
    .PORTSIZE_in3w(2),
    .BITSIZE_in4r(1),
    .PORTSIZE_in4r(2),
    .BITSIZE_in4w(1),
    .PORTSIZE_in4w(2),
    .BITSIZE_sel_LOAD(1),
    .PORTSIZE_sel_LOAD(2),
    .BITSIZE_sel_STORE(1),
    .PORTSIZE_sel_STORE(2),
    .BITSIZE_S_oe_ram(1),
    .PORTSIZE_S_oe_ram(2),
    .BITSIZE_S_we_ram(1),
    .PORTSIZE_S_we_ram(2),
    .BITSIZE_out1(32),
    .PORTSIZE_out1(2),
    .BITSIZE_S_addr_ram(12),
    .PORTSIZE_S_addr_ram(2),
    .BITSIZE_S_Wdata_ram(32),
    .PORTSIZE_S_Wdata_ram(2),
    .BITSIZE_Sin_Rdata_ram(32),
    .PORTSIZE_Sin_Rdata_ram(2),
    .BITSIZE_Sout_Rdata_ram(32),
    .PORTSIZE_Sout_Rdata_ram(2),
    .BITSIZE_S_data_ram_size(6),
    .PORTSIZE_S_data_ram_size(2),
    .BITSIZE_Sin_DataRdy(1),
    .PORTSIZE_Sin_DataRdy(2),
    .BITSIZE_Sout_DataRdy(1),
    .PORTSIZE_Sout_DataRdy(2),
    .MEMORY_INIT_file("array_ref_35245.mem"),
    .n_elements(512),
    .data_size(32),
    .address_space_begin(MEM_var_35245_35150),
    .address_space_rangesize(2048),
    .BUS_PIPELINED(1),
    .PRIVATE_MEMORY(1),
    .READ_ONLY_MEMORY(0),
    .USE_SPARSE_MEMORY(1),
    .ALIGNMENT(32),
    .BITSIZE_proxy_in1(32),
    .PORTSIZE_proxy_in1(2),
    .BITSIZE_proxy_in2r(12),
    .PORTSIZE_proxy_in2r(2),
    .BITSIZE_proxy_in2w(12),
    .PORTSIZE_proxy_in2w(2),
    .BITSIZE_proxy_in3r(6),
    .PORTSIZE_proxy_in3r(2),
    .BITSIZE_proxy_in3w(6),
    .PORTSIZE_proxy_in3w(2),
    .BITSIZE_proxy_in4r(1),
    .PORTSIZE_proxy_in4r(2),
    .BITSIZE_proxy_in4w(1),
    .PORTSIZE_proxy_in4w(2),
    .BITSIZE_proxy_sel_LOAD(1),
    .PORTSIZE_proxy_sel_LOAD(2),
    .BITSIZE_proxy_sel_STORE(1),
    .PORTSIZE_proxy_sel_STORE(2),
    .BITSIZE_proxy_out1(32),
    .PORTSIZE_proxy_out1(2)) array_35245_0 (.out1({null_out_signal_array_35245_0_out1_1,
      out_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_array_35245_0}),
    .Sout_Rdata_ram({null_out_signal_array_35245_0_Sout_Rdata_ram_1,
      null_out_signal_array_35245_0_Sout_Rdata_ram_0}),
    .Sout_DataRdy({null_out_signal_array_35245_0_Sout_DataRdy_1,
      null_out_signal_array_35245_0_Sout_DataRdy_0}),
    .proxy_out1({null_out_signal_array_35245_0_proxy_out1_1,
      null_out_signal_array_35245_0_proxy_out1_0}),
    .clock(clock),
    .reset(reset),
    .in1({32'b00000000000000000000000000000000,
      out_uu_conv_conn_obj_8_UUdata_converter_FU_uu_conv_10}),
    .in2r({12'b000000000000,
      out_reg_12_reg_12}),
    .in2w({12'b000000000000,
      out_reg_12_reg_12}),
    .in3r({6'b000000,
      out_conv_out_const_4_7_6}),
    .in3w({6'b000000,
      out_conv_out_const_4_7_6}),
    .in4r({1'b0,
      out_const_5}),
    .in4w({1'b0,
      out_const_5}),
    .sel_LOAD({1'b0,
      fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD}),
    .sel_STORE({1'b0,
      fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE}),
    .S_oe_ram({1'b0,
      1'b0}),
    .S_we_ram({1'b0,
      1'b0}),
    .S_addr_ram({12'b000000000000,
      12'b000000000000}),
    .S_Wdata_ram({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .Sin_Rdata_ram({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .S_data_ram_size({6'b000000,
      6'b000000}),
    .Sin_DataRdy({1'b0,
      1'b0}),
    .proxy_in1({32'b00000000000000000000000000000000,
      32'b00000000000000000000000000000000}),
    .proxy_in2r({12'b000000000000,
      12'b000000000000}),
    .proxy_in2w({12'b000000000000,
      12'b000000000000}),
    .proxy_in3r({6'b000000,
      6'b000000}),
    .proxy_in3w({6'b000000,
      6'b000000}),
    .proxy_in4r({1'b0,
      1'b0}),
    .proxy_in4w({1'b0,
      1'b0}),
    .proxy_sel_LOAD({1'b0,
      1'b0}),
    .proxy_sel_STORE({1'b0,
      1'b0}));
  constant_value #(.BITSIZE_out1(1),
    .value(1'b0)) const_0 (.out1(out_const_0));
  constant_value #(.BITSIZE_out1(32),
    .value(32'b00000000000000000000000000000000)) const_1 (.out1(out_const_1));
  constant_value #(.BITSIZE_out1(12),
    .value(MEM_var_35176_35150)) const_10 (.out1(out_const_10));
  constant_value #(.BITSIZE_out1(12),
    .value(MEM_var_35193_35150)) const_11 (.out1(out_const_11));
  constant_value #(.BITSIZE_out1(12),
    .value(MEM_var_35245_35150)) const_12 (.out1(out_const_12));
  constant_value #(.BITSIZE_out1(32),
    .value(32'b00000000000000000000000000000001)) const_2 (.out1(out_const_2));
  constant_value #(.BITSIZE_out1(32),
    .value(32'b00000000000000000000000000000010)) const_3 (.out1(out_const_3));
  constant_value #(.BITSIZE_out1(7),
    .value(7'b0100000)) const_4 (.out1(out_const_4));
  constant_value #(.BITSIZE_out1(1),
    .value(1'b1)) const_5 (.out1(out_const_5));
  constant_value #(.BITSIZE_out1(2),
    .value(2'b10)) const_6 (.out1(out_const_6));
  constant_value #(.BITSIZE_out1(3),
    .value(3'b100)) const_7 (.out1(out_const_7));
  constant_value #(.BITSIZE_out1(31),
    .value(31'b1111111111111111111111111111111)) const_8 (.out1(out_const_8));
  constant_value #(.BITSIZE_out1(32),
    .value(32'b11111111111111111111111111111111)) const_9 (.out1(out_const_9));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(3)) conv_out_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_array_35193_0_32_3 (.out1(out_conv_out_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_array_35193_0_32_3),
    .in1(out_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_array_35193_0));
  UUdata_converter_FU #(.BITSIZE_in1(1),
    .BITSIZE_out1(32)) conv_out_const_0_1_32 (.out1(out_conv_out_const_0_1_32),
    .in1(out_const_0));
  IIdata_converter_FU #(.BITSIZE_in1(1),
    .BITSIZE_out1(3)) conv_out_const_0_I_1_I_3 (.out1(out_conv_out_const_0_I_1_I_3),
    .in1(out_const_0));
  UUdata_converter_FU #(.BITSIZE_in1(12),
    .BITSIZE_out1(32)) conv_out_const_10_12_32 (.out1(out_conv_out_const_10_12_32),
    .in1(out_const_10));
  UUdata_converter_FU #(.BITSIZE_in1(12),
    .BITSIZE_out1(32)) conv_out_const_11_12_32 (.out1(out_conv_out_const_11_12_32),
    .in1(out_const_11));
  UUdata_converter_FU #(.BITSIZE_in1(12),
    .BITSIZE_out1(32)) conv_out_const_12_12_32 (.out1(out_conv_out_const_12_12_32),
    .in1(out_const_12));
  UUdata_converter_FU #(.BITSIZE_in1(7),
    .BITSIZE_out1(6)) conv_out_const_4_7_6 (.out1(out_conv_out_const_4_7_6),
    .in1(out_const_4));
  UUdata_converter_FU #(.BITSIZE_in1(1),
    .BITSIZE_out1(32)) conv_out_const_5_1_32 (.out1(out_conv_out_const_5_1_32),
    .in1(out_const_5));
  ui_plus_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) fu__Z7man_fibj_35150_35211 (.out1(out_ui_plus_expr_FU_32_0_32_75_i0_fu__Z7man_fibj_35150_35211),
    .in1(out_reg_8_reg_8),
    .in2(out_const_9));
  ui_plus_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(1),
    .BITSIZE_out1(32)) fu__Z7man_fibj_35150_35219 (.out1(out_ui_plus_expr_FU_32_0_32_76_i0_fu__Z7man_fibj_35150_35219),
    .in1(out_reg_0_reg_0),
    .in2(out_const_5));
  ui_plus_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(1),
    .BITSIZE_out1(32)) fu__Z7man_fibj_35150_35223 (.out1(out_ui_plus_expr_FU_32_0_32_76_i1_fu__Z7man_fibj_35150_35223),
    .in1(out_reg_8_reg_8),
    .in2(out_const_5));
  ui_plus_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) fu__Z7man_fibj_35150_35225 (.out1(out_ui_plus_expr_FU_32_0_32_75_i1_fu__Z7man_fibj_35150_35225),
    .in1(out_reg_0_reg_0),
    .in2(out_const_9));
  ui_plus_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) fu__Z7man_fibj_35150_35234 (.out1(out_ui_plus_expr_FU_32_32_32_79_i0_fu__Z7man_fibj_35150_35234),
    .in1(out_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_array_35245_0),
    .in2(out_reg_1_reg_1));
  ui_bit_ior_concat_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(1),
    .BITSIZE_in3(1),
    .BITSIZE_out1(32),
    .OFFSET_PARAMETER(1)) fu__Z7man_fibj_35150_35273 (.out1(out_ui_bit_ior_concat_expr_FU_70_i0_fu__Z7man_fibj_35150_35273),
    .in1(out_ui_lshift_expr_FU_32_0_32_74_i0_fu__Z7man_fibj_35150_35646),
    .in2(out_ui_bit_and_expr_FU_1_0_1_69_i0_fu__Z7man_fibj_35150_35649),
    .in3(out_const_5));
  ui_plus_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(32),
    .BITSIZE_out1(32)) fu__Z7man_fibj_35150_35282 (.out1(out_ui_plus_expr_FU_32_0_32_77_i0_fu__Z7man_fibj_35150_35282),
    .in1(out_reg_2_reg_2),
    .in2(out_const_9));
  read_cond_FU #(.BITSIZE_in1(1)) fu__Z7man_fibj_35150_35305 (.out1(out_read_cond_FU_39_i0_fu__Z7man_fibj_35150_35305),
    .in1(out_lut_expr_FU_33_i0_fu__Z7man_fibj_35150_35608));
  read_cond_FU #(.BITSIZE_in1(1)) fu__Z7man_fibj_35150_35308 (.out1(out_read_cond_FU_63_i0_fu__Z7man_fibj_35150_35308),
    .in1(out_ui_le_expr_FU_32_0_32_72_i0_fu__Z7man_fibj_35150_35610));
  read_cond_FU #(.BITSIZE_in1(1)) fu__Z7man_fibj_35150_35311 (.out1(out_read_cond_FU_65_i0_fu__Z7man_fibj_35150_35311),
    .in1(out_ui_eq_expr_FU_32_0_32_71_i0_fu__Z7man_fibj_35150_35612));
  read_cond_FU #(.BITSIZE_in1(1)) fu__Z7man_fibj_35150_35317 (.out1(out_read_cond_FU_68_i0_fu__Z7man_fibj_35150_35317),
    .in1(out_reg_15_reg_15));
  addr_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(12)) fu__Z7man_fibj_35150_35379 (.out1(out_addr_expr_FU_5_i0_fu__Z7man_fibj_35150_35379),
    .in1(out_conv_out_const_10_12_32));
  addr_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(12)) fu__Z7man_fibj_35150_35386 (.out1(out_addr_expr_FU_6_i0_fu__Z7man_fibj_35150_35386),
    .in1(out_conv_out_const_11_12_32));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(10)) fu__Z7man_fibj_35150_35394 (.out1(out_UUdata_converter_FU_64_i0_fu__Z7man_fibj_35150_35394),
    .in1(out_ui_plus_expr_FU_32_0_32_75_i0_fu__Z7man_fibj_35150_35211));
  ui_lshift_expr_FU #(.BITSIZE_in1(10),
    .BITSIZE_in2(2),
    .BITSIZE_out1(12),
    .PRECISION(32)) fu__Z7man_fibj_35150_35397 (.out1(out_ui_lshift_expr_FU_16_0_16_73_i0_fu__Z7man_fibj_35150_35397),
    .in1(out_UUdata_converter_FU_64_i0_fu__Z7man_fibj_35150_35394),
    .in2(out_const_6));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35400 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i0_fu__Z7man_fibj_35150_35400),
    .in1(out_reg_5_reg_5),
    .in2(out_reg_26_reg_26));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35413 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i1_fu__Z7man_fibj_35150_35413),
    .in1(out_reg_4_reg_4),
    .in2(out_reg_26_reg_26));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(10)) fu__Z7man_fibj_35150_35430 (.out1(out_UUdata_converter_FU_61_i0_fu__Z7man_fibj_35150_35430),
    .in1(out_reg_8_reg_8));
  ui_lshift_expr_FU #(.BITSIZE_in1(10),
    .BITSIZE_in2(2),
    .BITSIZE_out1(12),
    .PRECISION(32)) fu__Z7man_fibj_35150_35433 (.out1(out_ui_lshift_expr_FU_16_0_16_73_i1_fu__Z7man_fibj_35150_35433),
    .in1(out_UUdata_converter_FU_61_i0_fu__Z7man_fibj_35150_35430),
    .in2(out_const_6));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35436 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i2_fu__Z7man_fibj_35150_35436),
    .in1(out_reg_5_reg_5),
    .in2(out_ui_lshift_expr_FU_16_0_16_73_i1_fu__Z7man_fibj_35150_35433));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(10)) fu__Z7man_fibj_35150_35443 (.out1(out_UUdata_converter_FU_62_i0_fu__Z7man_fibj_35150_35443),
    .in1(out_ui_plus_expr_FU_32_0_32_76_i1_fu__Z7man_fibj_35150_35223));
  ui_lshift_expr_FU #(.BITSIZE_in1(10),
    .BITSIZE_in2(2),
    .BITSIZE_out1(12),
    .PRECISION(32)) fu__Z7man_fibj_35150_35446 (.out1(out_ui_lshift_expr_FU_16_0_16_73_i2_fu__Z7man_fibj_35150_35446),
    .in1(out_UUdata_converter_FU_62_i0_fu__Z7man_fibj_35150_35443),
    .in2(out_const_6));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35449 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i3_fu__Z7man_fibj_35150_35449),
    .in1(out_reg_5_reg_5),
    .in2(out_reg_24_reg_24));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35462 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i4_fu__Z7man_fibj_35150_35462),
    .in1(out_reg_4_reg_4),
    .in2(out_reg_24_reg_24));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35503 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i5_fu__Z7man_fibj_35150_35503),
    .in1(out_reg_5_reg_5),
    .in2(out_ui_lshift_expr_FU_16_0_16_73_i4_fu__Z7man_fibj_35150_35559));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(10)) fu__Z7man_fibj_35150_35510 (.out1(out_UUdata_converter_FU_37_i0_fu__Z7man_fibj_35150_35510),
    .in1(out_ui_plus_expr_FU_32_0_32_76_i0_fu__Z7man_fibj_35150_35219));
  ui_lshift_expr_FU #(.BITSIZE_in1(10),
    .BITSIZE_in2(2),
    .BITSIZE_out1(12),
    .PRECISION(32)) fu__Z7man_fibj_35150_35513 (.out1(out_ui_lshift_expr_FU_16_0_16_73_i3_fu__Z7man_fibj_35150_35513),
    .in1(out_UUdata_converter_FU_37_i0_fu__Z7man_fibj_35150_35510),
    .in2(out_const_6));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35516 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i6_fu__Z7man_fibj_35150_35516),
    .in1(out_reg_5_reg_5),
    .in2(out_reg_11_reg_11));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35529 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i7_fu__Z7man_fibj_35150_35529),
    .in1(out_reg_4_reg_4),
    .in2(out_reg_11_reg_11));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(10)) fu__Z7man_fibj_35150_35556 (.out1(out_UUdata_converter_FU_35_i0_fu__Z7man_fibj_35150_35556),
    .in1(out_reg_0_reg_0));
  ui_lshift_expr_FU #(.BITSIZE_in1(10),
    .BITSIZE_in2(2),
    .BITSIZE_out1(12),
    .PRECISION(32)) fu__Z7man_fibj_35150_35559 (.out1(out_ui_lshift_expr_FU_16_0_16_73_i4_fu__Z7man_fibj_35150_35559),
    .in1(out_UUdata_converter_FU_35_i0_fu__Z7man_fibj_35150_35556),
    .in2(out_const_6));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35562 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i8_fu__Z7man_fibj_35150_35562),
    .in1(out_reg_6_reg_6),
    .in2(out_ui_lshift_expr_FU_16_0_16_73_i4_fu__Z7man_fibj_35150_35559));
  addr_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(12)) fu__Z7man_fibj_35150_35566 (.out1(out_addr_expr_FU_7_i0_fu__Z7man_fibj_35150_35566),
    .in1(out_conv_out_const_12_12_32));
  UUdata_converter_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(10)) fu__Z7man_fibj_35150_35574 (.out1(out_UUdata_converter_FU_36_i0_fu__Z7man_fibj_35150_35574),
    .in1(out_ui_plus_expr_FU_32_0_32_75_i1_fu__Z7man_fibj_35150_35225));
  ui_lshift_expr_FU #(.BITSIZE_in1(10),
    .BITSIZE_in2(2),
    .BITSIZE_out1(12),
    .PRECISION(32)) fu__Z7man_fibj_35150_35577 (.out1(out_ui_lshift_expr_FU_16_0_16_73_i5_fu__Z7man_fibj_35150_35577),
    .in1(out_UUdata_converter_FU_36_i0_fu__Z7man_fibj_35150_35574),
    .in2(out_const_6));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35580 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i9_fu__Z7man_fibj_35150_35580),
    .in1(out_reg_5_reg_5),
    .in2(out_reg_13_reg_13));
  ui_pointer_plus_expr_FU #(.BITSIZE_in1(12),
    .BITSIZE_in2(12),
    .BITSIZE_out1(12),
    .LSB_PARAMETER(2)) fu__Z7man_fibj_35150_35593 (.out1(out_ui_pointer_plus_expr_FU_16_16_16_80_i10_fu__Z7man_fibj_35150_35593),
    .in1(out_reg_4_reg_4),
    .in2(out_reg_13_reg_13));
  lut_expr_FU #(.BITSIZE_in1(1),
    .BITSIZE_out1(1)) fu__Z7man_fibj_35150_35608 (.out1(out_lut_expr_FU_33_i0_fu__Z7man_fibj_35150_35608),
    .in1(out_const_5),
    .in2(out_extract_bit_expr_FU_31_i0_fu__Z7man_fibj_35150_35730),
    .in3(out_extract_bit_expr_FU_32_i0_fu__Z7man_fibj_35150_35733),
    .in4(1'b0),
    .in5(1'b0),
    .in6(1'b0),
    .in7(1'b0),
    .in8(1'b0),
    .in9(1'b0));
  ui_le_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(2),
    .BITSIZE_out1(1)) fu__Z7man_fibj_35150_35610 (.out1(out_ui_le_expr_FU_32_0_32_72_i0_fu__Z7man_fibj_35150_35610),
    .in1(out_reg_2_reg_2),
    .in2(out_const_6));
  ui_eq_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(1),
    .BITSIZE_out1(1)) fu__Z7man_fibj_35150_35612 (.out1(out_ui_eq_expr_FU_32_0_32_71_i0_fu__Z7man_fibj_35150_35612),
    .in1(out_reg_8_reg_8),
    .in2(out_const_0));
  lut_expr_FU #(.BITSIZE_in1(2),
    .BITSIZE_out1(1)) fu__Z7man_fibj_35150_35614 (.out1(out_lut_expr_FU_34_i0_fu__Z7man_fibj_35150_35614),
    .in1(out_const_6),
    .in2(out_extract_bit_expr_FU_31_i0_fu__Z7man_fibj_35150_35730),
    .in3(out_extract_bit_expr_FU_32_i0_fu__Z7man_fibj_35150_35733),
    .in4(1'b0),
    .in5(1'b0),
    .in6(1'b0),
    .in7(1'b0),
    .in8(1'b0),
    .in9(1'b0));
  ui_eq_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(1),
    .BITSIZE_out1(1)) fu__Z7man_fibj_35150_35618 (.out1(out_ui_eq_expr_FU_32_0_32_71_i1_fu__Z7man_fibj_35150_35618),
    .in1(out_reg_0_reg_0),
    .in2(out_const_0));
  ui_rshift_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(1),
    .BITSIZE_out1(31),
    .PRECISION(32)) fu__Z7man_fibj_35150_35638 (.out1(out_ui_rshift_expr_FU_32_0_32_81_i0_fu__Z7man_fibj_35150_35638),
    .in1(out_reg_2_reg_2),
    .in2(out_const_5));
  ui_plus_expr_FU #(.BITSIZE_in1(31),
    .BITSIZE_in2(31),
    .BITSIZE_out1(31)) fu__Z7man_fibj_35150_35643 (.out1(out_ui_plus_expr_FU_32_0_32_78_i0_fu__Z7man_fibj_35150_35643),
    .in1(out_ui_rshift_expr_FU_32_0_32_81_i0_fu__Z7man_fibj_35150_35638),
    .in2(out_const_8));
  ui_lshift_expr_FU #(.BITSIZE_in1(31),
    .BITSIZE_in2(1),
    .BITSIZE_out1(32),
    .PRECISION(32)) fu__Z7man_fibj_35150_35646 (.out1(out_ui_lshift_expr_FU_32_0_32_74_i0_fu__Z7man_fibj_35150_35646),
    .in1(out_ui_plus_expr_FU_32_0_32_78_i0_fu__Z7man_fibj_35150_35643),
    .in2(out_const_5));
  ui_bit_and_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_in2(1),
    .BITSIZE_out1(1)) fu__Z7man_fibj_35150_35649 (.out1(out_ui_bit_and_expr_FU_1_0_1_69_i0_fu__Z7man_fibj_35150_35649),
    .in1(out_reg_2_reg_2),
    .in2(out_const_5));
  multi_read_cond_FU #(.BITSIZE_in1(1),
    .PORTSIZE_in1(2),
    .BITSIZE_out1(2)) fu__Z7man_fibj_35150_35714 (.out1(out_multi_read_cond_FU_67_i0_fu__Z7man_fibj_35150_35714),
    .in1({out_reg_16_reg_16,
      out_reg_14_reg_14}));
  lut_expr_FU #(.BITSIZE_in1(3),
    .BITSIZE_out1(1)) fu__Z7man_fibj_35150_35720 (.out1(out_lut_expr_FU_38_i0_fu__Z7man_fibj_35150_35720),
    .in1(out_const_7),
    .in2(out_extract_bit_expr_FU_31_i0_fu__Z7man_fibj_35150_35730),
    .in3(out_extract_bit_expr_FU_32_i0_fu__Z7man_fibj_35150_35733),
    .in4(1'b0),
    .in5(1'b0),
    .in6(1'b0),
    .in7(1'b0),
    .in8(1'b0),
    .in9(1'b0));
  extract_bit_expr_FU #(.BITSIZE_in1(3),
    .BITSIZE_in2(1)) fu__Z7man_fibj_35150_35730 (.out1(out_extract_bit_expr_FU_31_i0_fu__Z7man_fibj_35150_35730),
    .in1(out_reg_3_reg_3),
    .in2(out_const_0));
  extract_bit_expr_FU #(.BITSIZE_in1(3),
    .BITSIZE_in2(1)) fu__Z7man_fibj_35150_35733 (.out1(out_extract_bit_expr_FU_32_i0_fu__Z7man_fibj_35150_35733),
    .in1(out_reg_3_reg_3),
    .in2(out_const_5));
  register_SE #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) reg_0 (.out1(out_reg_0_reg_0),
    .clock(clock),
    .reset(reset),
    .in1(out_MUX_59_reg_0_0_0_1),
    .wenable(wrenable_reg_0));
  register_SE #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) reg_1 (.out1(out_reg_1_reg_1),
    .clock(clock),
    .reset(reset),
    .in1(out_MUX_60_reg_1_0_0_1),
    .wenable(wrenable_reg_1));
  register_SE #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_10 (.out1(out_reg_10_reg_10),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i5_fu__Z7man_fibj_35150_35503),
    .wenable(wrenable_reg_10));
  register_STD #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_11 (.out1(out_reg_11_reg_11),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_lshift_expr_FU_16_0_16_73_i3_fu__Z7man_fibj_35150_35513),
    .wenable(wrenable_reg_11));
  register_SE #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_12 (.out1(out_reg_12_reg_12),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i8_fu__Z7man_fibj_35150_35562),
    .wenable(wrenable_reg_12));
  register_STD #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_13 (.out1(out_reg_13_reg_13),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_lshift_expr_FU_16_0_16_73_i5_fu__Z7man_fibj_35150_35577),
    .wenable(wrenable_reg_13));
  register_STD #(.BITSIZE_in1(1),
    .BITSIZE_out1(1)) reg_14 (.out1(out_reg_14_reg_14),
    .clock(clock),
    .reset(reset),
    .in1(out_lut_expr_FU_34_i0_fu__Z7man_fibj_35150_35614),
    .wenable(wrenable_reg_14));
  register_SE #(.BITSIZE_in1(1),
    .BITSIZE_out1(1)) reg_15 (.out1(out_reg_15_reg_15),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_eq_expr_FU_32_0_32_71_i1_fu__Z7man_fibj_35150_35618),
    .wenable(wrenable_reg_15));
  register_STD #(.BITSIZE_in1(1),
    .BITSIZE_out1(1)) reg_16 (.out1(out_reg_16_reg_16),
    .clock(clock),
    .reset(reset),
    .in1(out_lut_expr_FU_38_i0_fu__Z7man_fibj_35150_35720),
    .wenable(wrenable_reg_16));
  register_SE #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_17 (.out1(out_reg_17_reg_17),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i9_fu__Z7man_fibj_35150_35580),
    .wenable(wrenable_reg_17));
  register_SE #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_18 (.out1(out_reg_18_reg_18),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i10_fu__Z7man_fibj_35150_35593),
    .wenable(wrenable_reg_18));
  register_SE #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_19 (.out1(out_reg_19_reg_19),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i6_fu__Z7man_fibj_35150_35516),
    .wenable(wrenable_reg_19));
  register_SE #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) reg_2 (.out1(out_reg_2_reg_2),
    .clock(clock),
    .reset(reset),
    .in1(out_MUX_71_reg_2_0_1_0),
    .wenable(wrenable_reg_2));
  register_STD #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_20 (.out1(out_reg_20_reg_20),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i7_fu__Z7man_fibj_35150_35529),
    .wenable(wrenable_reg_20));
  register_SE #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) reg_21 (.out1(out_reg_21_reg_21),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_plus_expr_FU_32_0_32_76_i1_fu__Z7man_fibj_35150_35223),
    .wenable(wrenable_reg_21));
  register_SE #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) reg_22 (.out1(out_reg_22_reg_22),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_plus_expr_FU_32_0_32_77_i0_fu__Z7man_fibj_35150_35282),
    .wenable(wrenable_reg_22));
  register_STD #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_23 (.out1(out_reg_23_reg_23),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i2_fu__Z7man_fibj_35150_35436),
    .wenable(wrenable_reg_23));
  register_STD #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_24 (.out1(out_reg_24_reg_24),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_lshift_expr_FU_16_0_16_73_i2_fu__Z7man_fibj_35150_35446),
    .wenable(wrenable_reg_24));
  register_STD #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_25 (.out1(out_reg_25_reg_25),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_pointer_plus_expr_FU_16_16_16_80_i3_fu__Z7man_fibj_35150_35449),
    .wenable(wrenable_reg_25));
  register_STD #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_26 (.out1(out_reg_26_reg_26),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_lshift_expr_FU_16_0_16_73_i0_fu__Z7man_fibj_35150_35397),
    .wenable(wrenable_reg_26));
  register_SE #(.BITSIZE_in1(3),
    .BITSIZE_out1(3)) reg_3 (.out1(out_reg_3_reg_3),
    .clock(clock),
    .reset(reset),
    .in1(out_MUX_79_reg_3_0_0_0),
    .wenable(wrenable_reg_3));
  register_SE #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_4 (.out1(out_reg_4_reg_4),
    .clock(clock),
    .reset(reset),
    .in1(out_addr_expr_FU_5_i0_fu__Z7man_fibj_35150_35379),
    .wenable(wrenable_reg_4));
  register_SE #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_5 (.out1(out_reg_5_reg_5),
    .clock(clock),
    .reset(reset),
    .in1(out_addr_expr_FU_6_i0_fu__Z7man_fibj_35150_35386),
    .wenable(wrenable_reg_5));
  register_SE #(.BITSIZE_in1(12),
    .BITSIZE_out1(12)) reg_6 (.out1(out_reg_6_reg_6),
    .clock(clock),
    .reset(reset),
    .in1(out_addr_expr_FU_7_i0_fu__Z7man_fibj_35150_35566),
    .wenable(wrenable_reg_6));
  register_SE #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) reg_7 (.out1(out_reg_7_reg_7),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_plus_expr_FU_32_0_32_75_i1_fu__Z7man_fibj_35150_35225),
    .wenable(wrenable_reg_7));
  register_SE #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) reg_8 (.out1(out_reg_8_reg_8),
    .clock(clock),
    .reset(reset),
    .in1(out_MUX_84_reg_8_0_0_1),
    .wenable(wrenable_reg_8));
  register_SE #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) reg_9 (.out1(out_reg_9_reg_9),
    .clock(clock),
    .reset(reset),
    .in1(out_ui_bit_ior_concat_expr_FU_70_i0_fu__Z7man_fibj_35150_35273),
    .wenable(wrenable_reg_9));
  // io-signal post fix
  assign return_port = out_MUX_39_gimple_return_FU_66_i0_0_0_0;
  assign OUT_CONDITION__Z7man_fibj_35150_35305 = out_read_cond_FU_39_i0_fu__Z7man_fibj_35150_35305;
  assign OUT_CONDITION__Z7man_fibj_35150_35308 = out_read_cond_FU_63_i0_fu__Z7man_fibj_35150_35308;
  assign OUT_CONDITION__Z7man_fibj_35150_35311 = out_read_cond_FU_65_i0_fu__Z7man_fibj_35150_35311;
  assign OUT_CONDITION__Z7man_fibj_35150_35317 = out_read_cond_FU_68_i0_fu__Z7man_fibj_35150_35317;
  assign OUT_MULTIIF__Z7man_fibj_35150_35714 = out_multi_read_cond_FU_67_i0_fu__Z7man_fibj_35150_35714;

endmodule

// FSM based controller description for _Z7man_fibj
// This component has been derived from the input source code and so it does not fall under the copyright of PandA framework, but it follows the input source code copyright, and may be aggregated with components of the BAMBU/PANDA IP LIBRARY.
// Author(s): Component automatically generated by bambu
// License: THIS COMPONENT IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
`timescale 1ns / 1ps
module controller__Z7man_fibj(done_port,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD,
  fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE,
  selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0,
  selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1,
  selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0,
  selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0,
  selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1,
  selector_MUX_39_gimple_return_FU_66_i0_0_0_0,
  selector_MUX_59_reg_0_0_0_0,
  selector_MUX_59_reg_0_0_0_1,
  selector_MUX_60_reg_1_0_0_0,
  selector_MUX_60_reg_1_0_0_1,
  selector_MUX_71_reg_2_0_0_0,
  selector_MUX_71_reg_2_0_0_1,
  selector_MUX_71_reg_2_0_1_0,
  selector_MUX_79_reg_3_0_0_0,
  selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0,
  selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1,
  selector_MUX_84_reg_8_0_0_0,
  selector_MUX_84_reg_8_0_0_1,
  selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0,
  selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0,
  selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1,
  selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2,
  selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0,
  wrenable_reg_0,
  wrenable_reg_1,
  wrenable_reg_10,
  wrenable_reg_11,
  wrenable_reg_12,
  wrenable_reg_13,
  wrenable_reg_14,
  wrenable_reg_15,
  wrenable_reg_16,
  wrenable_reg_17,
  wrenable_reg_18,
  wrenable_reg_19,
  wrenable_reg_2,
  wrenable_reg_20,
  wrenable_reg_21,
  wrenable_reg_22,
  wrenable_reg_23,
  wrenable_reg_24,
  wrenable_reg_25,
  wrenable_reg_26,
  wrenable_reg_3,
  wrenable_reg_4,
  wrenable_reg_5,
  wrenable_reg_6,
  wrenable_reg_7,
  wrenable_reg_8,
  wrenable_reg_9,
  OUT_CONDITION__Z7man_fibj_35150_35305,
  OUT_CONDITION__Z7man_fibj_35150_35308,
  OUT_CONDITION__Z7man_fibj_35150_35311,
  OUT_CONDITION__Z7man_fibj_35150_35317,
  OUT_MULTIIF__Z7man_fibj_35150_35714,
  clock,
  reset,
  start_port);
  // IN
  input OUT_CONDITION__Z7man_fibj_35150_35305;
  input OUT_CONDITION__Z7man_fibj_35150_35308;
  input OUT_CONDITION__Z7man_fibj_35150_35311;
  input OUT_CONDITION__Z7man_fibj_35150_35317;
  input [1:0] OUT_MULTIIF__Z7man_fibj_35150_35714;
  input clock;
  input reset;
  input start_port;
  // OUT
  output done_port;
  output fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD;
  output fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE;
  output fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD;
  output fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE;
  output fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD;
  output fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE;
  output selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0;
  output selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1;
  output selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0;
  output selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0;
  output selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1;
  output selector_MUX_39_gimple_return_FU_66_i0_0_0_0;
  output selector_MUX_59_reg_0_0_0_0;
  output selector_MUX_59_reg_0_0_0_1;
  output selector_MUX_60_reg_1_0_0_0;
  output selector_MUX_60_reg_1_0_0_1;
  output selector_MUX_71_reg_2_0_0_0;
  output selector_MUX_71_reg_2_0_0_1;
  output selector_MUX_71_reg_2_0_1_0;
  output selector_MUX_79_reg_3_0_0_0;
  output selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0;
  output selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1;
  output selector_MUX_84_reg_8_0_0_0;
  output selector_MUX_84_reg_8_0_0_1;
  output selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0;
  output selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0;
  output selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1;
  output selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2;
  output selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0;
  output wrenable_reg_0;
  output wrenable_reg_1;
  output wrenable_reg_10;
  output wrenable_reg_11;
  output wrenable_reg_12;
  output wrenable_reg_13;
  output wrenable_reg_14;
  output wrenable_reg_15;
  output wrenable_reg_16;
  output wrenable_reg_17;
  output wrenable_reg_18;
  output wrenable_reg_19;
  output wrenable_reg_2;
  output wrenable_reg_20;
  output wrenable_reg_21;
  output wrenable_reg_22;
  output wrenable_reg_23;
  output wrenable_reg_24;
  output wrenable_reg_25;
  output wrenable_reg_26;
  output wrenable_reg_3;
  output wrenable_reg_4;
  output wrenable_reg_5;
  output wrenable_reg_6;
  output wrenable_reg_7;
  output wrenable_reg_8;
  output wrenable_reg_9;
  parameter [16:0] S_0 = 17'b00000000000000001,
    S_1 = 17'b00000000000000010,
    S_8 = 17'b00000000100000000,
    S_11 = 17'b00000100000000000,
    S_12 = 17'b00001000000000000,
    S_16 = 17'b10000000000000000,
    S_13 = 17'b00010000000000000,
    S_14 = 17'b00100000000000000,
    S_9 = 17'b00000001000000000,
    S_10 = 17'b00000010000000000,
    S_2 = 17'b00000000000000100,
    S_6 = 17'b00000000001000000,
    S_7 = 17'b00000000010000000,
    S_3 = 17'b00000000000001000,
    S_15 = 17'b01000000000000000,
    S_4 = 17'b00000000000010000,
    S_5 = 17'b00000000000100000;
  reg [16:0] _present_state=S_0, _next_state;
  reg done_port;
  reg fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD;
  reg fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE;
  reg fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD;
  reg fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE;
  reg fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD;
  reg fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE;
  reg selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0;
  reg selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1;
  reg selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0;
  reg selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0;
  reg selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1;
  reg selector_MUX_39_gimple_return_FU_66_i0_0_0_0;
  reg selector_MUX_59_reg_0_0_0_0;
  reg selector_MUX_59_reg_0_0_0_1;
  reg selector_MUX_60_reg_1_0_0_0;
  reg selector_MUX_60_reg_1_0_0_1;
  reg selector_MUX_71_reg_2_0_0_0;
  reg selector_MUX_71_reg_2_0_0_1;
  reg selector_MUX_71_reg_2_0_1_0;
  reg selector_MUX_79_reg_3_0_0_0;
  reg selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0;
  reg selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1;
  reg selector_MUX_84_reg_8_0_0_0;
  reg selector_MUX_84_reg_8_0_0_1;
  reg selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0;
  reg selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0;
  reg selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1;
  reg selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2;
  reg selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0;
  reg wrenable_reg_0;
  reg wrenable_reg_1;
  reg wrenable_reg_10;
  reg wrenable_reg_11;
  reg wrenable_reg_12;
  reg wrenable_reg_13;
  reg wrenable_reg_14;
  reg wrenable_reg_15;
  reg wrenable_reg_16;
  reg wrenable_reg_17;
  reg wrenable_reg_18;
  reg wrenable_reg_19;
  reg wrenable_reg_2;
  reg wrenable_reg_20;
  reg wrenable_reg_21;
  reg wrenable_reg_22;
  reg wrenable_reg_23;
  reg wrenable_reg_24;
  reg wrenable_reg_25;
  reg wrenable_reg_26;
  reg wrenable_reg_3;
  reg wrenable_reg_4;
  reg wrenable_reg_5;
  reg wrenable_reg_6;
  reg wrenable_reg_7;
  reg wrenable_reg_8;
  reg wrenable_reg_9;
  
  always @(posedge clock)
    if (reset == 1'b0) _present_state <= S_0;
    else _present_state <= _next_state;
  
  always @(*)
  begin
    done_port = 1'b0;
    fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD = 1'b0;
    fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE = 1'b0;
    fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD = 1'b0;
    fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE = 1'b0;
    fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD = 1'b0;
    fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE = 1'b0;
    selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0 = 1'b0;
    selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1 = 1'b0;
    selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0 = 1'b0;
    selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0 = 1'b0;
    selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1 = 1'b0;
    selector_MUX_39_gimple_return_FU_66_i0_0_0_0 = 1'b0;
    selector_MUX_59_reg_0_0_0_0 = 1'b0;
    selector_MUX_59_reg_0_0_0_1 = 1'b0;
    selector_MUX_60_reg_1_0_0_0 = 1'b0;
    selector_MUX_60_reg_1_0_0_1 = 1'b0;
    selector_MUX_71_reg_2_0_0_0 = 1'b0;
    selector_MUX_71_reg_2_0_0_1 = 1'b0;
    selector_MUX_71_reg_2_0_1_0 = 1'b0;
    selector_MUX_79_reg_3_0_0_0 = 1'b0;
    selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0 = 1'b0;
    selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1 = 1'b0;
    selector_MUX_84_reg_8_0_0_0 = 1'b0;
    selector_MUX_84_reg_8_0_0_1 = 1'b0;
    selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0 = 1'b0;
    selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0 = 1'b0;
    selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1 = 1'b0;
    selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2 = 1'b0;
    selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0 = 1'b0;
    wrenable_reg_0 = 1'b0;
    wrenable_reg_1 = 1'b0;
    wrenable_reg_10 = 1'b0;
    wrenable_reg_11 = 1'b0;
    wrenable_reg_12 = 1'b0;
    wrenable_reg_13 = 1'b0;
    wrenable_reg_14 = 1'b0;
    wrenable_reg_15 = 1'b0;
    wrenable_reg_16 = 1'b0;
    wrenable_reg_17 = 1'b0;
    wrenable_reg_18 = 1'b0;
    wrenable_reg_19 = 1'b0;
    wrenable_reg_2 = 1'b0;
    wrenable_reg_20 = 1'b0;
    wrenable_reg_21 = 1'b0;
    wrenable_reg_22 = 1'b0;
    wrenable_reg_23 = 1'b0;
    wrenable_reg_24 = 1'b0;
    wrenable_reg_25 = 1'b0;
    wrenable_reg_26 = 1'b0;
    wrenable_reg_3 = 1'b0;
    wrenable_reg_4 = 1'b0;
    wrenable_reg_5 = 1'b0;
    wrenable_reg_6 = 1'b0;
    wrenable_reg_7 = 1'b0;
    wrenable_reg_8 = 1'b0;
    wrenable_reg_9 = 1'b0;
    case (_present_state)
      S_0 :
        if(start_port == 1'b1)
        begin
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE = 1'b1;
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE = 1'b1;
          selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0 = 1'b1;
          selector_MUX_59_reg_0_0_0_1 = 1'b1;
          selector_MUX_60_reg_1_0_0_1 = 1'b1;
          selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0 = 1'b1;
          selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2 = 1'b1;
          wrenable_reg_0 = 1'b1;
          wrenable_reg_1 = 1'b1;
          wrenable_reg_2 = 1'b1;
          wrenable_reg_3 = 1'b1;
          wrenable_reg_4 = 1'b1;
          wrenable_reg_5 = 1'b1;
          wrenable_reg_6 = 1'b1;
          _next_state = S_1;
        end
        else
        begin
          _next_state = S_0;
        end
      S_1 :
        begin
          selector_MUX_84_reg_8_0_0_1 = 1'b1;
          wrenable_reg_10 = 1'b1;
          wrenable_reg_11 = 1'b1;
          wrenable_reg_12 = 1'b1;
          wrenable_reg_13 = 1'b1;
          wrenable_reg_14 = 1'b1;
          wrenable_reg_15 = 1'b1;
          wrenable_reg_16 = 1'b1;
          wrenable_reg_7 = 1'b1;
          wrenable_reg_8 = 1'b1;
          wrenable_reg_9 = 1'b1;
          if (OUT_CONDITION__Z7man_fibj_35150_35305 == 1'b0)
            begin
              _next_state = S_8;
            end
          else
            begin
              _next_state = S_2;
              selector_MUX_84_reg_8_0_0_1 = 1'b0;
              wrenable_reg_10 = 1'b0;
              wrenable_reg_11 = 1'b0;
              wrenable_reg_12 = 1'b0;
              wrenable_reg_13 = 1'b0;
              wrenable_reg_14 = 1'b0;
              wrenable_reg_15 = 1'b0;
              wrenable_reg_16 = 1'b0;
              wrenable_reg_7 = 1'b0;
              wrenable_reg_9 = 1'b0;
            end
        end
      S_8 :
        begin
          wrenable_reg_17 = 1'b1;
          wrenable_reg_18 = 1'b1;
          wrenable_reg_19 = 1'b1;
          wrenable_reg_20 = 1'b1;
          casez (OUT_MULTIIF__Z7man_fibj_35150_35714)
            2'b?1 :
              begin
                _next_state = S_9;
                wrenable_reg_17 = 1'b0;
                wrenable_reg_18 = 1'b0;
              end
            2'b10 :
              begin
                _next_state = S_11;
                wrenable_reg_19 = 1'b0;
                wrenable_reg_20 = 1'b0;
              end
            default:
              begin
                _next_state = S_1;
                wrenable_reg_17 = 1'b0;
                wrenable_reg_18 = 1'b0;
                wrenable_reg_19 = 1'b0;
                wrenable_reg_20 = 1'b0;
              end
          endcase
        end
      S_11 :
        begin
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD = 1'b1;
          _next_state = S_12;
        end
      S_12 :
        begin
          selector_MUX_60_reg_1_0_0_0 = 1'b1;
          wrenable_reg_1 = 1'b1;
          if (OUT_CONDITION__Z7man_fibj_35150_35317 == 1'b0)
            begin
              _next_state = S_13;
            end
          else
            begin
              _next_state = S_16;
              done_port = 1'b1;
            end
        end
      S_16 :
        begin
          selector_MUX_39_gimple_return_FU_66_i0_0_0_0 = 1'b1;
          _next_state = S_0;
        end
      S_13 :
        begin
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD = 1'b1;
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD = 1'b1;
          selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0 = 1'b1;
          selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0 = 1'b1;
          _next_state = S_14;
        end
      S_14 :
        begin
          selector_MUX_59_reg_0_0_0_0 = 1'b1;
          selector_MUX_71_reg_2_0_0_1 = 1'b1;
          selector_MUX_79_reg_3_0_0_0 = 1'b1;
          wrenable_reg_0 = 1'b1;
          wrenable_reg_2 = 1'b1;
          wrenable_reg_3 = 1'b1;
          _next_state = S_1;
        end
      S_9 :
        begin
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE = 1'b1;
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE = 1'b1;
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE = 1'b1;
          selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0 = 1'b1;
          selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1 = 1'b1;
          selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0 = 1'b1;
          _next_state = S_10;
        end
      S_10 :
        begin
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE = 1'b1;
          selector_MUX_71_reg_2_0_0_0 = 1'b1;
          selector_MUX_71_reg_2_0_1_0 = 1'b1;
          selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0 = 1'b1;
          selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1 = 1'b1;
          selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0 = 1'b1;
          wrenable_reg_2 = 1'b1;
          _next_state = S_2;
        end
      S_2 :
        begin
          wrenable_reg_21 = 1'b1;
          wrenable_reg_22 = 1'b1;
          wrenable_reg_23 = 1'b1;
          wrenable_reg_24 = 1'b1;
          if (OUT_CONDITION__Z7man_fibj_35150_35308 == 1'b1)
            begin
              _next_state = S_3;
              wrenable_reg_21 = 1'b0;
              wrenable_reg_22 = 1'b0;
              wrenable_reg_23 = 1'b0;
              wrenable_reg_24 = 1'b0;
            end
          else
            begin
              _next_state = S_6;
            end
        end
      S_6 :
        begin
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE = 1'b1;
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE = 1'b1;
          selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1 = 1'b1;
          selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1 = 1'b1;
          wrenable_reg_25 = 1'b1;
          _next_state = S_7;
        end
      S_7 :
        begin
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE = 1'b1;
          selector_MUX_71_reg_2_0_1_0 = 1'b1;
          selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0 = 1'b1;
          selector_MUX_84_reg_8_0_0_0 = 1'b1;
          selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0 = 1'b1;
          wrenable_reg_2 = 1'b1;
          wrenable_reg_8 = 1'b1;
          _next_state = S_2;
        end
      S_3 :
        begin
          wrenable_reg_0 = 1'b1;
          wrenable_reg_26 = 1'b1;
          if (OUT_CONDITION__Z7man_fibj_35150_35311 == 1'b0)
            begin
              _next_state = S_4;
            end
          else
            begin
              _next_state = S_15;
              done_port = 1'b1;
              wrenable_reg_0 = 1'b0;
              wrenable_reg_26 = 1'b0;
            end
        end
      S_15 :
        begin
          _next_state = S_0;
        end
      S_4 :
        begin
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD = 1'b1;
          fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD = 1'b1;
          _next_state = S_5;
        end
      S_5 :
        begin
          selector_MUX_71_reg_2_0_0_1 = 1'b1;
          selector_MUX_79_reg_3_0_0_0 = 1'b1;
          wrenable_reg_1 = 1'b1;
          wrenable_reg_2 = 1'b1;
          wrenable_reg_3 = 1'b1;
          _next_state = S_1;
        end
      default :
        begin
          _next_state = S_0;
        end
    endcase
  end
endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Marco Lattuada <marco.lattuada@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module flipflop_AR(clock,
  reset,
  in1,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input clock;
  input reset;
  input in1;
  // OUT
  output out1;
  
  reg reg_out1 =0;
  assign out1 = reg_out1;
  always @(posedge clock or negedge reset)
    if (reset == 1'b0)
      reg_out1 <= {BITSIZE_out1{1'b0}};
    else
      reg_out1 <= in1;
endmodule

// Top component for _Z7man_fibj
// This component has been derived from the input source code and so it does not fall under the copyright of PandA framework, but it follows the input source code copyright, and may be aggregated with components of the BAMBU/PANDA IP LIBRARY.
// Author(s): Component automatically generated by bambu
// License: THIS COMPONENT IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
`timescale 1ns / 1ps
module __Z7man_fibj(clock,
  reset,
  start_port,
  done_port,
  n,
  return_port);
  // IN
  input clock;
  input reset;
  input start_port;
  input [31:0] n;
  // OUT
  output done_port;
  output [31:0] return_port;
  // Component and signal declarations
  wire OUT_CONDITION__Z7man_fibj_35150_35305;
  wire OUT_CONDITION__Z7man_fibj_35150_35308;
  wire OUT_CONDITION__Z7man_fibj_35150_35311;
  wire OUT_CONDITION__Z7man_fibj_35150_35317;
  wire [1:0] OUT_MULTIIF__Z7man_fibj_35150_35714;
  wire done_delayed_REG_signal_in;
  wire done_delayed_REG_signal_out;
  wire fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD;
  wire fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE;
  wire fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD;
  wire fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE;
  wire fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD;
  wire fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE;
  wire selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0;
  wire selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1;
  wire selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0;
  wire selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0;
  wire selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1;
  wire selector_MUX_39_gimple_return_FU_66_i0_0_0_0;
  wire selector_MUX_59_reg_0_0_0_0;
  wire selector_MUX_59_reg_0_0_0_1;
  wire selector_MUX_60_reg_1_0_0_0;
  wire selector_MUX_60_reg_1_0_0_1;
  wire selector_MUX_71_reg_2_0_0_0;
  wire selector_MUX_71_reg_2_0_0_1;
  wire selector_MUX_71_reg_2_0_1_0;
  wire selector_MUX_79_reg_3_0_0_0;
  wire selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0;
  wire selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1;
  wire selector_MUX_84_reg_8_0_0_0;
  wire selector_MUX_84_reg_8_0_0_1;
  wire selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0;
  wire selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0;
  wire selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1;
  wire selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2;
  wire selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0;
  wire wrenable_reg_0;
  wire wrenable_reg_1;
  wire wrenable_reg_10;
  wire wrenable_reg_11;
  wire wrenable_reg_12;
  wire wrenable_reg_13;
  wire wrenable_reg_14;
  wire wrenable_reg_15;
  wire wrenable_reg_16;
  wire wrenable_reg_17;
  wire wrenable_reg_18;
  wire wrenable_reg_19;
  wire wrenable_reg_2;
  wire wrenable_reg_20;
  wire wrenable_reg_21;
  wire wrenable_reg_22;
  wire wrenable_reg_23;
  wire wrenable_reg_24;
  wire wrenable_reg_25;
  wire wrenable_reg_26;
  wire wrenable_reg_3;
  wire wrenable_reg_4;
  wire wrenable_reg_5;
  wire wrenable_reg_6;
  wire wrenable_reg_7;
  wire wrenable_reg_8;
  wire wrenable_reg_9;
  
  controller__Z7man_fibj Controller_i (.done_port(done_delayed_REG_signal_in),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE),
    .selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0(selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0),
    .selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1(selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1),
    .selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0(selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0),
    .selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0(selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0),
    .selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1(selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1),
    .selector_MUX_39_gimple_return_FU_66_i0_0_0_0(selector_MUX_39_gimple_return_FU_66_i0_0_0_0),
    .selector_MUX_59_reg_0_0_0_0(selector_MUX_59_reg_0_0_0_0),
    .selector_MUX_59_reg_0_0_0_1(selector_MUX_59_reg_0_0_0_1),
    .selector_MUX_60_reg_1_0_0_0(selector_MUX_60_reg_1_0_0_0),
    .selector_MUX_60_reg_1_0_0_1(selector_MUX_60_reg_1_0_0_1),
    .selector_MUX_71_reg_2_0_0_0(selector_MUX_71_reg_2_0_0_0),
    .selector_MUX_71_reg_2_0_0_1(selector_MUX_71_reg_2_0_0_1),
    .selector_MUX_71_reg_2_0_1_0(selector_MUX_71_reg_2_0_1_0),
    .selector_MUX_79_reg_3_0_0_0(selector_MUX_79_reg_3_0_0_0),
    .selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0(selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0),
    .selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1(selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1),
    .selector_MUX_84_reg_8_0_0_0(selector_MUX_84_reg_8_0_0_0),
    .selector_MUX_84_reg_8_0_0_1(selector_MUX_84_reg_8_0_0_1),
    .selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0(selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0),
    .selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0),
    .selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1),
    .selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2),
    .selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0),
    .wrenable_reg_0(wrenable_reg_0),
    .wrenable_reg_1(wrenable_reg_1),
    .wrenable_reg_10(wrenable_reg_10),
    .wrenable_reg_11(wrenable_reg_11),
    .wrenable_reg_12(wrenable_reg_12),
    .wrenable_reg_13(wrenable_reg_13),
    .wrenable_reg_14(wrenable_reg_14),
    .wrenable_reg_15(wrenable_reg_15),
    .wrenable_reg_16(wrenable_reg_16),
    .wrenable_reg_17(wrenable_reg_17),
    .wrenable_reg_18(wrenable_reg_18),
    .wrenable_reg_19(wrenable_reg_19),
    .wrenable_reg_2(wrenable_reg_2),
    .wrenable_reg_20(wrenable_reg_20),
    .wrenable_reg_21(wrenable_reg_21),
    .wrenable_reg_22(wrenable_reg_22),
    .wrenable_reg_23(wrenable_reg_23),
    .wrenable_reg_24(wrenable_reg_24),
    .wrenable_reg_25(wrenable_reg_25),
    .wrenable_reg_26(wrenable_reg_26),
    .wrenable_reg_3(wrenable_reg_3),
    .wrenable_reg_4(wrenable_reg_4),
    .wrenable_reg_5(wrenable_reg_5),
    .wrenable_reg_6(wrenable_reg_6),
    .wrenable_reg_7(wrenable_reg_7),
    .wrenable_reg_8(wrenable_reg_8),
    .wrenable_reg_9(wrenable_reg_9),
    .OUT_CONDITION__Z7man_fibj_35150_35305(OUT_CONDITION__Z7man_fibj_35150_35305),
    .OUT_CONDITION__Z7man_fibj_35150_35308(OUT_CONDITION__Z7man_fibj_35150_35308),
    .OUT_CONDITION__Z7man_fibj_35150_35311(OUT_CONDITION__Z7man_fibj_35150_35311),
    .OUT_CONDITION__Z7man_fibj_35150_35317(OUT_CONDITION__Z7man_fibj_35150_35317),
    .OUT_MULTIIF__Z7man_fibj_35150_35714(OUT_MULTIIF__Z7man_fibj_35150_35714),
    .clock(clock),
    .reset(reset),
    .start_port(start_port));
  datapath__Z7man_fibj #(.MEM_var_35176_35150(2048),
    .MEM_var_35193_35150(2048),
    .MEM_var_35245_35150(2048)) Datapath_i (.return_port(return_port),
    .OUT_CONDITION__Z7man_fibj_35150_35305(OUT_CONDITION__Z7man_fibj_35150_35305),
    .OUT_CONDITION__Z7man_fibj_35150_35308(OUT_CONDITION__Z7man_fibj_35150_35308),
    .OUT_CONDITION__Z7man_fibj_35150_35311(OUT_CONDITION__Z7man_fibj_35150_35311),
    .OUT_CONDITION__Z7man_fibj_35150_35317(OUT_CONDITION__Z7man_fibj_35150_35317),
    .OUT_MULTIIF__Z7man_fibj_35150_35714(OUT_MULTIIF__Z7man_fibj_35150_35714),
    .clock(clock),
    .reset(reset),
    .in_port_n(n),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_LOAD),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_STORE),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_LOAD),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_STORE),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_LOAD),
    .fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE(fuselector_ARRAY_1D_STD_BRAM_NN_SDS_2_i0_STORE),
    .selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0(selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_0),
    .selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1(selector_MUX_0_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_0_0_1),
    .selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0(selector_MUX_1_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_1_0_0),
    .selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0(selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_0),
    .selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1(selector_MUX_2_ARRAY_1D_STD_BRAM_NN_SDS_0_i0_2_0_1),
    .selector_MUX_39_gimple_return_FU_66_i0_0_0_0(selector_MUX_39_gimple_return_FU_66_i0_0_0_0),
    .selector_MUX_59_reg_0_0_0_0(selector_MUX_59_reg_0_0_0_0),
    .selector_MUX_59_reg_0_0_0_1(selector_MUX_59_reg_0_0_0_1),
    .selector_MUX_60_reg_1_0_0_0(selector_MUX_60_reg_1_0_0_0),
    .selector_MUX_60_reg_1_0_0_1(selector_MUX_60_reg_1_0_0_1),
    .selector_MUX_71_reg_2_0_0_0(selector_MUX_71_reg_2_0_0_0),
    .selector_MUX_71_reg_2_0_0_1(selector_MUX_71_reg_2_0_0_1),
    .selector_MUX_71_reg_2_0_1_0(selector_MUX_71_reg_2_0_1_0),
    .selector_MUX_79_reg_3_0_0_0(selector_MUX_79_reg_3_0_0_0),
    .selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0(selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_0),
    .selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1(selector_MUX_7_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_0_0_1),
    .selector_MUX_84_reg_8_0_0_0(selector_MUX_84_reg_8_0_0_0),
    .selector_MUX_84_reg_8_0_0_1(selector_MUX_84_reg_8_0_0_1),
    .selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0(selector_MUX_8_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_1_0_0),
    .selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_0),
    .selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_1),
    .selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_0_2),
    .selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0(selector_MUX_9_ARRAY_1D_STD_BRAM_NN_SDS_1_i0_2_1_0),
    .wrenable_reg_0(wrenable_reg_0),
    .wrenable_reg_1(wrenable_reg_1),
    .wrenable_reg_10(wrenable_reg_10),
    .wrenable_reg_11(wrenable_reg_11),
    .wrenable_reg_12(wrenable_reg_12),
    .wrenable_reg_13(wrenable_reg_13),
    .wrenable_reg_14(wrenable_reg_14),
    .wrenable_reg_15(wrenable_reg_15),
    .wrenable_reg_16(wrenable_reg_16),
    .wrenable_reg_17(wrenable_reg_17),
    .wrenable_reg_18(wrenable_reg_18),
    .wrenable_reg_19(wrenable_reg_19),
    .wrenable_reg_2(wrenable_reg_2),
    .wrenable_reg_20(wrenable_reg_20),
    .wrenable_reg_21(wrenable_reg_21),
    .wrenable_reg_22(wrenable_reg_22),
    .wrenable_reg_23(wrenable_reg_23),
    .wrenable_reg_24(wrenable_reg_24),
    .wrenable_reg_25(wrenable_reg_25),
    .wrenable_reg_26(wrenable_reg_26),
    .wrenable_reg_3(wrenable_reg_3),
    .wrenable_reg_4(wrenable_reg_4),
    .wrenable_reg_5(wrenable_reg_5),
    .wrenable_reg_6(wrenable_reg_6),
    .wrenable_reg_7(wrenable_reg_7),
    .wrenable_reg_8(wrenable_reg_8),
    .wrenable_reg_9(wrenable_reg_9));
  flipflop_AR #(.BITSIZE_in1(1),
    .BITSIZE_out1(1)) done_delayed_REG (.out1(done_delayed_REG_signal_out),
    .clock(clock),
    .reset(reset),
    .in1(done_delayed_REG_signal_in));
  // io-signal post fix
  assign done_port = done_delayed_REG_signal_out;

endmodule

// This component is part of the BAMBU/PANDA IP LIBRARY
// Copyright (C) 2004-2024 Politecnico di Milano
// Author(s): Fabrizio Ferrandi <fabrizio.ferrandi@polimi.it>
// License: PANDA_LGPLv3
`timescale 1ns / 1ps
module ui_view_convert_expr_FU(in1,
  out1);
  parameter BITSIZE_in1=1,
    BITSIZE_out1=1;
  // IN
  input [BITSIZE_in1-1:0] in1;
  // OUT
  output [BITSIZE_out1-1:0] out1;
  assign out1 = in1;
endmodule

// Minimal interface for function: _Z7man_fibj
// This component has been derived from the input source code and so it does not fall under the copyright of PandA framework, but it follows the input source code copyright, and may be aggregated with components of the BAMBU/PANDA IP LIBRARY.
// Author(s): Component automatically generated by bambu
// License: THIS COMPONENT IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
`timescale 1ns / 1ps
module _Z7man_fibj(clock,
  reset,
  start_port,
  n,
  done_port,
  return_port);
  // IN
  input clock;
  input reset;
  input start_port;
  input [31:0] n;
  // OUT
  output done_port;
  output [31:0] return_port;
  // Component and signal declarations
  wire [31:0] out_return_port_ui_view_convert_expr_FU;
  
  __Z7man_fibj __Z7man_fibj_i0 (.done_port(done_port),
    .return_port(out_return_port_ui_view_convert_expr_FU),
    .clock(clock),
    .reset(reset),
    .start_port(start_port),
    .n(n));
  ui_view_convert_expr_FU #(.BITSIZE_in1(32),
    .BITSIZE_out1(32)) return_port_ui_view_convert_expr_FU (.out1(return_port),
    .in1(out_return_port_ui_view_convert_expr_FU));

endmodule


