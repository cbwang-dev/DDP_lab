`timescale 1ns / 1ps


`define NUM_OF_CORES 2


`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

 module tb_rsa_wrapper();
    
    reg           clk;
    reg           resetn;
    reg  [  31:0] arm_to_fpga_cmd;
    reg           arm_to_fpga_cmd_valid;
    wire          fpga_to_arm_done;
    reg           fpga_to_arm_done_read;

    reg           arm_to_fpga_data_valid;
    wire          arm_to_fpga_data_ready;
    reg  [1023:0] arm_to_fpga_data;

    wire          fpga_to_arm_data_valid;
    reg           fpga_to_arm_data_ready;
    wire [1023:0] fpga_to_arm_data;

    wire [   3:0] leds;

    reg  [1023:0] integer_x;
    reg  [1023:0] R2_mod_m;
    reg  [1023:0] R_mod_m ; 
    reg  [1023:0] modulus_m;
    reg  [1023:0] output_data, expected_output, e;
    reg  [11:0] e_width;
    
    reg  [1023:0] result;
        
    rsa_wrapper rsa_wrapper(
        .clk                    (clk                    ),
        .resetn                 (resetn                 ),

        .arm_to_fpga_cmd        (arm_to_fpga_cmd        ),
        .arm_to_fpga_cmd_valid  (arm_to_fpga_cmd_valid  ),
        .fpga_to_arm_done       (fpga_to_arm_done       ),
        .fpga_to_arm_done_read  (fpga_to_arm_done_read  ),

        .arm_to_fpga_data_valid (arm_to_fpga_data_valid ),
        .arm_to_fpga_data_ready (arm_to_fpga_data_ready ), 
        .arm_to_fpga_data       (arm_to_fpga_data       ),

        .fpga_to_arm_data_valid (fpga_to_arm_data_valid ),
        .fpga_to_arm_data_ready (fpga_to_arm_data_ready ),
        .fpga_to_arm_data       (fpga_to_arm_data       ),

        .leds                   (leds                   )
        );
        
    // Generate a clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end
    
    // Reset
    initial begin
        resetn = 0;
        #`RESET_TIME resetn = 1;
    end
    
    // Initialise the values to zero
    initial begin
        arm_to_fpga_cmd         = 0;
        arm_to_fpga_cmd_valid   = 0;
        fpga_to_arm_done_read   = 0;
        arm_to_fpga_data_valid  = 0;
        arm_to_fpga_data        = 0;
        fpga_to_arm_data_ready  = 0;
    end

    task send_cmd_to_hw;
    input [31:0] command;
    begin
        // Assert the command and valid
        arm_to_fpga_cmd <= command;
        arm_to_fpga_cmd_valid <= 1'b1;
        #`CLK_PERIOD;
        // Desassert the valid signal after one cycle
        arm_to_fpga_cmd_valid <= 1'b0;
        #`CLK_PERIOD;
    end
    endtask

    task send_data_to_hw;
    input [1023:0] data;
    begin
        // Assert data and valid
        arm_to_fpga_data <= data;
        arm_to_fpga_data_valid <= 1'b1;
        #`CLK_PERIOD;
        // Wait till accelerator is ready to read it
        wait(arm_to_fpga_data_ready == 1'b1);
        // It is read, do not continue asserting valid
        arm_to_fpga_data_valid <= 1'b0;   
        #`CLK_PERIOD;
    end
    endtask

    task read_data_from_hw;
    output [1023:0] odata;
    begin
        // Assert ready signal
        fpga_to_arm_data_ready <= 1'b1;
        #`CLK_PERIOD;
        // Wait for valid signal
        wait(fpga_to_arm_data_valid == 1'b1);
        // If valid read the output data
        odata = fpga_to_arm_data;
        // Co not continue asserting ready
        fpga_to_arm_data_ready <= 1'b0;
        #`CLK_PERIOD;
    end
    endtask

    task waitdone;
    begin
        // Wait for accelerator's done
        wait(fpga_to_arm_done == 1'b1);
        // Signal that is is read
        fpga_to_arm_done_read <= 1'b1;
        #`CLK_PERIOD;
        // Desassert the signal after one cycle
        fpga_to_arm_done_read <= 1'b0;
        #`CLK_PERIOD;
    end 
    endtask

    localparam CMD_NOP              = 4'h0;
    localparam CMD_READX            = 4'h1;
    //localparam             = 4'h2;
    localparam CMD_WRITE            = 4'h3;
    localparam CMD_COMPUTE_3B       = 4'h4; 
    localparam CMD_READ_integer_x   = 4'h5;  
    localparam CMD_READ_modulus_m   = 4'h6;  
    localparam CMD_READ_R2_mod_m    = 4'h8;
    localparam CMD_READ_R_mod_m     = 4'h9;
    localparam CMD_READ_e_width     = 4'ha;
    localparam CMD_READ_e           = 4'hc;
    
    
    initial begin

        #`RESET_TIME
        
        // Your task: 
        // Design a testbench to test your accelerator using the tasks defined above: send_cmd_to_hw, send_data_to_hw, read_data_from_hw, waitdone
//        input_data2 <= 1024'h1;
//        input_data3 <= 1024'h1;
        
//        integer_x       <= 1024'h862fa937679614504c17e17017e3d25daeaaad8ff014b65d578bdfd238b730f56d946ad91a48509e38bf200e2023320fb06ad45debb3c50144e6386247570275f89f227816f1160aa00280a9167e7e0673c7e0db6c768c1b681eae622d418aa653f14f21c1e05fbf64f3fc842e31d42b3f2539a6db40f7fec1033ab0de232183;   
//        R2_mod_m        <= 1024'hf1e77e980dbc8a6264750b1f37bbc8aa6a4183cf2586b097c617f7f5afca96bfec6adb6624d3b0b72b7c421c52a01f5841114657e9fedd01c117b39e72d00173278c1edc465d1791ec9df95e9a9aba0bdd8700a8051a4b298ac942381e1c76cda1025336f7b0959fe1e6ce5d4f1e3055566d7e0bcf7ac3f45cc23aa0452d1de;
//        R_mod_m         <= 1024'h15337f10e99e597737cf69e64cdba972757752e056fe92679c028ff536a6fa69fd53426a76cb3da10be5d92fa5635f2fae88284d4df54620ec123402e90c96c07d0d03e916ffbb533994b4368b63fdc5b33ffbc325287222dc94cd443bc9faca633b2ad649ff957cda60ea44ae3538ef1c270b3d1102cb621f687894168a3951;
//        modulus_m       <= 1024'heacc80ef1661a688c8309619b324568d8a88ad1fa9016d9863fd700ac959059602acbd958934c25ef41a26d05a9ca0d05177d7b2b20ab9df13edcbfd16f3693f82f2fc16e90044acc66b4bc9749c023a4cc0043cdad78ddd236b32bbc43605359cc4d529b6006a83259f15bb51cac710e3d8f4c2eefd349de097876be975c6af;
//        e               <= 1024'hea;
//        e_width         <= 11'h8;
        output_data     <= 1024'b0;
        expected_output <= 1024'h3ea8b8df4fb9ed9234ee4bda484c6908d8b355fd8dfcf7905865b38fc442ddf13d993c8a97284627f56ccc535adf3b657df234a6e32e59ba235dbd18db326e4305971292606c84b23414588ae5b2fa59cce7fa189b07d9183316dd78c1a55635d64eb5a6e7002ae5cc7884945538b11d372752aec1ba3db355164fcc8226e6ba;


//        integer_x       <= 1024'ha4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82c;   
        R2_mod_m        <= 1024'h19c078b09a181b02dcf1592451ac77f9a3ba3b1967682bde96400a0522cc3a52e711b9fae8c0209d606cf14101ec28801b1c5d4d7a74f3e06e808f6ecb42e32a6bc7cba715e0200a9030d0193a418455b46573be9574e69940f0646fc3c0b48be374f68184c1e82dda847ae853e370e11f895c2232c59d5dad57db82cc8baa5e;
        R_mod_m         <= 1024'h75a8990eea07c9cb0b40aac4a0df89c9af6dce82f3affc732e30fe3440e7602d785eb18d8e9c5a165c795dfda8c371beacf89c445add703a3dcf85eb96431e9ae866a32ba4b4893baf86a3dec75c89785f29e3cf41c98ae3ef41da8c36d235933e7c6a16184bf48b8f5f67df38090ad6eb9d829f3ad9b3524db35d0d12c786df;
        modulus_m       <= 1024'h8a5766f115f83634f4bf553b5f2076365092317d0c50038cd1cf01cbbf189fd287a14e727163a5e9a386a202573c8e41530763bba5228fc5c2307a1469bce16517995cd45b4b76c450795c2138a37687a0d61c30be36751c10be2573c92dca6cc18395e9e7b40b7470a09820c7f6f52914627d60c5264cadb24ca2f2ed387921;
//        e               <= 1024'hca25;
//        e_width         <= 12'h10;
        
        integer_x       <= 1024'h10fe0d6a368b6a39f552a3a614300aeae409cbc15ba4077a8b5c5837a79ff1453a2dbcbb2a30cde8464e459e2ede511df5cf24cb0f24e90769a9d5ddaf484d1e6aa19bd41c6bf9bf134e881692da38b7f146f52f2df2764aab4a6937489d074663fc5bed13478b2004e6e75a11e3625a45a298967d4b78029d2717983187f777;
        e               <= 1024'h1dda58bc552c63ee689beb3cb7dc7752c105f4e99fa4c50a9ea1257d5d2e139e26e27cfe94b246f5e7f7f49663525fcf2e5a1ed11e7d6b130ed09dbc23cc532fc5513ddc214edb31d4996f46dca580013c412921b5decbb84732e5cd2976a49c03b571fd18e375ff395ce271a56b7fc1f1081ed3f8f13350a545d17c56454b29;
        e_width         <= 12'h3fd;

// encryption exponent
//uint32_t e[32]       = {0000ca25};
//uint32_t e_len[32]       = {00000010};

// decryption exponent, reduced to p and q
//uint32_t d[32]       =
//uint32_t d_len[32]       =  {000003ff};

// the message
     

// R mod N, and R^2 mod N, (R = 2^1024)










        #`CLK_PERIOD;

        ///////////////////// START EXAMPLE  /////////////////////
        
        //// --- Send the read command and transfer input data to FPGA

        $display("Test for input %h", integer_x);
        
        $display("Sending read command");
        send_cmd_to_hw(CMD_READ_integer_x);
        send_data_to_hw(integer_x);
        waitdone();
        
          $display("Sending read command");
        send_cmd_to_hw(CMD_READ_modulus_m);
        send_data_to_hw(modulus_m);
        waitdone();
        
        $display("Sending read command");
        send_cmd_to_hw(CMD_READ_R2_mod_m);
        send_data_to_hw(R2_mod_m);
        waitdone();
        
        $display("Sending read command");
        send_cmd_to_hw(CMD_READ_R_mod_m);
        send_data_to_hw(R_mod_m);
        waitdone();
        
        $display("Sending read command");
        send_cmd_to_hw(CMD_READ_e_width);
        send_data_to_hw(e_width);
        waitdone();
        
        $display("Sending read command");
        send_cmd_to_hw(CMD_READ_e);
        send_data_to_hw(e);
        waitdone();
        

        $display("Sending compute command 3");
        send_cmd_to_hw(CMD_COMPUTE_3B);
        waitdone();  
  
        
     
        




	    //// --- Send write command and transfer output data from FPGA
        
        $display("Sending write command");
        send_cmd_to_hw(CMD_WRITE);
        read_data_from_hw(output_data);
        waitdone();


        //// --- Print the array contents

        $display("Output is      %h", output_data);
                  
        ///////////////////// END EXAMPLE  /////////////////////  
        
        $finish;
    end
endmodule
