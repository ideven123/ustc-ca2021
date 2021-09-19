
module mem #(                   // 
    parameter  ADDR_LEN  = 11   // 
) (
    input  clk, rst,
    input  [ADDR_LEN-1:0] addr, // memory address
    output reg [31:0] rd_data,  // data read out
    input  wr_req,
    input  [31:0] wr_data       // data write in
);
localparam MEM_SIZE = 1<<ADDR_LEN;
reg [31:0] ram_cell [MEM_SIZE];

always @ (posedge clk or posedge rst)
    if(rst)
        rd_data <= 0;
    else
        rd_data <= ram_cell[addr];

always @ (posedge clk)
    if(wr_req) 
        ram_cell[addr] <= wr_data;

reg [31:0] see_ram[256];
always@(*)
    for(integer j =0 ; j < 256 ; j++ )
         see_ram[j] = ram_cell[j] ;

initial begin
    // dst matrix C
    ram_cell[       0] = 32'h0;  // 32'h3ecbb207;
    ram_cell[       1] = 32'h0;  // 32'h2c8be212;
    ram_cell[       2] = 32'h0;  // 32'h1353ed3a;
    ram_cell[       3] = 32'h0;  // 32'hcb69b2c6;
    ram_cell[       4] = 32'h0;  // 32'hf029c361;
    ram_cell[       5] = 32'h0;  // 32'h13a8c8cc;
    ram_cell[       6] = 32'h0;  // 32'h8533336f;
    ram_cell[       7] = 32'h0;  // 32'hd2ea201a;
    ram_cell[       8] = 32'h0;  // 32'hbbbaae9b;
    ram_cell[       9] = 32'h0;  // 32'h53ba24f9;
    ram_cell[      10] = 32'h0;  // 32'h04918c40;
    ram_cell[      11] = 32'h0;  // 32'h0a06c1e3;
    ram_cell[      12] = 32'h0;  // 32'hab57b44c;
    ram_cell[      13] = 32'h0;  // 32'he170628e;
    ram_cell[      14] = 32'h0;  // 32'h523e001e;
    ram_cell[      15] = 32'h0;  // 32'hbc9000ab;
    ram_cell[      16] = 32'h0;  // 32'h75e0ea01;
    ram_cell[      17] = 32'h0;  // 32'h31fc20e3;
    ram_cell[      18] = 32'h0;  // 32'he21f764f;
    ram_cell[      19] = 32'h0;  // 32'h92713aff;
    ram_cell[      20] = 32'h0;  // 32'hddc80c42;
    ram_cell[      21] = 32'h0;  // 32'hb15ce336;
    ram_cell[      22] = 32'h0;  // 32'hff1cac94;
    ram_cell[      23] = 32'h0;  // 32'hdc8e95bf;
    ram_cell[      24] = 32'h0;  // 32'h495029a0;
    ram_cell[      25] = 32'h0;  // 32'h3e439687;
    ram_cell[      26] = 32'h0;  // 32'h85f6c471;
    ram_cell[      27] = 32'h0;  // 32'hcb152249;
    ram_cell[      28] = 32'h0;  // 32'h5e05ad5a;
    ram_cell[      29] = 32'h0;  // 32'h946e0ea1;
    ram_cell[      30] = 32'h0;  // 32'h9f814d45;
    ram_cell[      31] = 32'h0;  // 32'hccff0b42;
    ram_cell[      32] = 32'h0;  // 32'hd43a998d;
    ram_cell[      33] = 32'h0;  // 32'hdeddb1fc;
    ram_cell[      34] = 32'h0;  // 32'haeeb1577;
    ram_cell[      35] = 32'h0;  // 32'h6593f2d6;
    ram_cell[      36] = 32'h0;  // 32'h4bc68e07;
    ram_cell[      37] = 32'h0;  // 32'hc895a141;
    ram_cell[      38] = 32'h0;  // 32'h772d8624;
    ram_cell[      39] = 32'h0;  // 32'h5aaa4315;
    ram_cell[      40] = 32'h0;  // 32'hf0b57cb7;
    ram_cell[      41] = 32'h0;  // 32'h739142b9;
    ram_cell[      42] = 32'h0;  // 32'hb8075c36;
    ram_cell[      43] = 32'h0;  // 32'hac590de9;
    ram_cell[      44] = 32'h0;  // 32'h0b410a02;
    ram_cell[      45] = 32'h0;  // 32'ha0af762a;
    ram_cell[      46] = 32'h0;  // 32'hadb661fc;
    ram_cell[      47] = 32'h0;  // 32'h6dca0a87;
    ram_cell[      48] = 32'h0;  // 32'hab99bc0d;
    ram_cell[      49] = 32'h0;  // 32'h00ad5857;
    ram_cell[      50] = 32'h0;  // 32'h46815e62;
    ram_cell[      51] = 32'h0;  // 32'h1731e0cc;
    ram_cell[      52] = 32'h0;  // 32'h9b3f5f72;
    ram_cell[      53] = 32'h0;  // 32'h2e3516f5;
    ram_cell[      54] = 32'h0;  // 32'h4fdbeccc;
    ram_cell[      55] = 32'h0;  // 32'h54df452c;
    ram_cell[      56] = 32'h0;  // 32'h92c3c1d6;
    ram_cell[      57] = 32'h0;  // 32'h9f8b64b8;
    ram_cell[      58] = 32'h0;  // 32'h8c5dcb94;
    ram_cell[      59] = 32'h0;  // 32'he64f7900;
    ram_cell[      60] = 32'h0;  // 32'hbe177d26;
    ram_cell[      61] = 32'h0;  // 32'hfd704283;
    ram_cell[      62] = 32'h0;  // 32'hdb6ec950;
    ram_cell[      63] = 32'h0;  // 32'h639e98cc;
    // src matrix A
    ram_cell[      64] = 32'h639f8ccf;
    ram_cell[      65] = 32'h069d1095;
    ram_cell[      66] = 32'h31fc3cbc;
    ram_cell[      67] = 32'h81d4cccc;
    ram_cell[      68] = 32'hf9b08e72;
    ram_cell[      69] = 32'h0e1234d8;
    ram_cell[      70] = 32'hb8264902;
    ram_cell[      71] = 32'h98e93573;
    ram_cell[      72] = 32'h204a33f7;
    ram_cell[      73] = 32'h82ffda55;
    ram_cell[      74] = 32'he5f33616;
    ram_cell[      75] = 32'hffd3e6d6;
    ram_cell[      76] = 32'h828664a3;
    ram_cell[      77] = 32'h7bc99849;
    ram_cell[      78] = 32'hc3e3531f;
    ram_cell[      79] = 32'hc09dd1cc;
    ram_cell[      80] = 32'h84a5167c;
    ram_cell[      81] = 32'hb8f81931;
    ram_cell[      82] = 32'h6c87f076;
    ram_cell[      83] = 32'hc85bc768;
    ram_cell[      84] = 32'h6cbf120e;
    ram_cell[      85] = 32'h38b6b2ea;
    ram_cell[      86] = 32'hb3ecf0e8;
    ram_cell[      87] = 32'h3cae1549;
    ram_cell[      88] = 32'h2e5451db;
    ram_cell[      89] = 32'h8640489d;
    ram_cell[      90] = 32'h51f33862;
    ram_cell[      91] = 32'hc4c6cf3c;
    ram_cell[      92] = 32'h96d37381;
    ram_cell[      93] = 32'h9d599c00;
    ram_cell[      94] = 32'h8be21f74;
    ram_cell[      95] = 32'hc29055de;
    ram_cell[      96] = 32'h8c28d459;
    ram_cell[      97] = 32'hc943fcec;
    ram_cell[      98] = 32'h01694490;
    ram_cell[      99] = 32'h9cf9aa49;
    ram_cell[     100] = 32'h257016d8;
    ram_cell[     101] = 32'h48ea1fc2;
    ram_cell[     102] = 32'hcf8f53d9;
    ram_cell[     103] = 32'h73b3bc17;
    ram_cell[     104] = 32'h2a892739;
    ram_cell[     105] = 32'hd0dcc909;
    ram_cell[     106] = 32'h0f65ed36;
    ram_cell[     107] = 32'habf86a88;
    ram_cell[     108] = 32'ha22fe317;
    ram_cell[     109] = 32'hbd6c7e59;
    ram_cell[     110] = 32'h6c674ffb;
    ram_cell[     111] = 32'hb999ab08;
    ram_cell[     112] = 32'h8b3bbedf;
    ram_cell[     113] = 32'hf3354e12;
    ram_cell[     114] = 32'h4a907edb;
    ram_cell[     115] = 32'hbf8f3972;
    ram_cell[     116] = 32'h1660fc22;
    ram_cell[     117] = 32'he103c74f;
    ram_cell[     118] = 32'h173cc7d9;
    ram_cell[     119] = 32'h77d32a5e;
    ram_cell[     120] = 32'h9ef522f3;
    ram_cell[     121] = 32'h4df0c7ce;
    ram_cell[     122] = 32'hb349dd22;
    ram_cell[     123] = 32'hc37589e6;
    ram_cell[     124] = 32'hc013e4d6;
    ram_cell[     125] = 32'he1772bcd;
    ram_cell[     126] = 32'hc5f06b43;
    ram_cell[     127] = 32'he7f20b25;
    // src matrix B
    ram_cell[     128] = 32'ha635ef9c;
    ram_cell[     129] = 32'h8527656f;
    ram_cell[     130] = 32'h25eb75a7;
    ram_cell[     131] = 32'h73d8336f;
    ram_cell[     132] = 32'ha14d8981;
    ram_cell[     133] = 32'he25f8ed0;
    ram_cell[     134] = 32'h6c7280d5;
    ram_cell[     135] = 32'ha19ccf01;
    ram_cell[     136] = 32'he1791a3e;
    ram_cell[     137] = 32'h39ec281a;
    ram_cell[     138] = 32'hcf1bf90f;
    ram_cell[     139] = 32'hf8edb9a8;
    ram_cell[     140] = 32'hf664a4bb;
    ram_cell[     141] = 32'hcde3a8e2;
    ram_cell[     142] = 32'h370dfdfa;
    ram_cell[     143] = 32'hbae1e903;
    ram_cell[     144] = 32'h8538ce16;
    ram_cell[     145] = 32'h0733c8b8;
    ram_cell[     146] = 32'h5a9f0a5e;
    ram_cell[     147] = 32'hc231baa1;
    ram_cell[     148] = 32'h748a3d33;
    ram_cell[     149] = 32'h0c03f628;
    ram_cell[     150] = 32'h09119562;
    ram_cell[     151] = 32'h3f91bfe2;
    ram_cell[     152] = 32'h4e19ec7d;
    ram_cell[     153] = 32'h0dcb50eb;
    ram_cell[     154] = 32'hb8600998;
    ram_cell[     155] = 32'hba564514;
    ram_cell[     156] = 32'h3dedeff6;
    ram_cell[     157] = 32'he0003928;
    ram_cell[     158] = 32'h612c91f6;
    ram_cell[     159] = 32'h5db1d014;
    ram_cell[     160] = 32'h70f82526;
    ram_cell[     161] = 32'hd9c90a26;
    ram_cell[     162] = 32'h4e2cbeb5;
    ram_cell[     163] = 32'h18772778;
    ram_cell[     164] = 32'h5879440c;
    ram_cell[     165] = 32'h0417abe7;
    ram_cell[     166] = 32'h5ad49086;
    ram_cell[     167] = 32'hcb384e4a;
    ram_cell[     168] = 32'hc38ad6b4;
    ram_cell[     169] = 32'hff48b901;
    ram_cell[     170] = 32'h6390acdd;
    ram_cell[     171] = 32'haeae4b82;
    ram_cell[     172] = 32'h269b001f;
    ram_cell[     173] = 32'h1cb5d4f8;
    ram_cell[     174] = 32'hcd6d2424;
    ram_cell[     175] = 32'h927e3d13;
    ram_cell[     176] = 32'hdf6ab25b;
    ram_cell[     177] = 32'hf78859c5;
    ram_cell[     178] = 32'h13428604;
    ram_cell[     179] = 32'habaf0b88;
    ram_cell[     180] = 32'hbb501f21;
    ram_cell[     181] = 32'hdf26548b;
    ram_cell[     182] = 32'h2e075c3f;
    ram_cell[     183] = 32'he221d748;
    ram_cell[     184] = 32'h5196e45f;
    ram_cell[     185] = 32'hb68ed999;
    ram_cell[     186] = 32'h05b3dd02;
    ram_cell[     187] = 32'h7c7c5563;
    ram_cell[     188] = 32'he69de6cb;
    ram_cell[     189] = 32'hafd5a0a8;
    ram_cell[     190] = 32'h926e63b2;
    ram_cell[     191] = 32'h75599caa;
end

endmodule

