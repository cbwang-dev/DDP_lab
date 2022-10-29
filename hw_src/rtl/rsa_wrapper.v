`timescale 1ns / 1ps



module rsa_wrapper
(
    // The clock and active low reset
    input           clk,
    input           resetn,
    
    input  [  31:0] arm_to_fpga_cmd,
    input           arm_to_fpga_cmd_valid,
    output          fpga_to_arm_done,
    input           fpga_to_arm_done_read,

    input           arm_to_fpga_data_valid,
    output          arm_to_fpga_data_ready,
    input  [1023:0] arm_to_fpga_data,
    
    output          fpga_to_arm_data_valid,
    input           fpga_to_arm_data_ready,
    output [1023:0] fpga_to_arm_data,
    
    output [   3:0] leds

    );

    ////////////// - State Machine 

    /// - State Machine Parameters

    localparam STATE_BITS           = 5;    
    localparam STATE_WAIT_FOR_CMD   = 5'd0;  
    localparam STATE_READ_CMD       = 5'd1;  
    //localparam           = 5'd2;
    //localparam STATE_READM          = 4'h3;
    //localparam           = 5'd4;
    localparam STATE_COMPUTE_3B     = 5'd6;
    localparam STATE_COMPUTE_WAIT   = 5'd8;
    //localparam       = 5'd9;
    //localparam          = 5'd10; //a
    localparam STATE_WRITE_DATA     = 5'd11; //b
    localparam STATE_ASSERT_DONE    = 5'd12; //c
    localparam STATE_READ_integer_x = 5'd13; //d
    localparam STATE_READ_modulus_m = 5'd14; //e
    localparam STATE_RESET_MONT     = 5'd15; //f
    localparam STATE_READ_R2_mod_m  = 5'd16;
    localparam STATE_READ_R_mod_m   = 5'd17;
    localparam STATE_READ_e         = 5'd18;
    localparam STATE_READ_e_width   = 5'd20;
    //localparam       = 5'd21;
    

    reg [STATE_BITS-1:0] r_state;
    reg [STATE_BITS-1:0] next_state;
    

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
   

   
    
    
    
   
    

    
    reg            start_mont;
    wire            mont_done;
    
    wire [1023:0]   result;
    
    
    //input multiplexer
    wire [1023:0]   data_in;
   
    assign data_in = arm_to_fpga_data;

     
    //register cmd
    reg  [31:0]     cmd_Q;
    always @(posedge clk) begin
        if(resetn == 1'b0)                   cmd_Q <= 32'b0;
        else if(arm_to_fpga_cmd_valid)       cmd_Q <= arm_to_fpga_cmd;
        
    end

    /// - State Transition

    always @(*)
    begin
        if (resetn==1'b0)
            next_state <= STATE_WAIT_FOR_CMD;
        else                
                            
        begin
            case (r_state)
            
                STATE_WAIT_FOR_CMD:
                    next_state <= (arm_to_fpga_cmd_valid) ? STATE_READ_CMD : r_state;
                
                STATE_READ_CMD:
                    begin
                        case (cmd_Q[3:0])
                            CMD_READ_integer_x:
                                next_state <= STATE_READ_integer_x;
                            CMD_READ_modulus_m:
                                next_state <= STATE_READ_modulus_m;
                            CMD_READ_R2_mod_m:
                                next_state <= STATE_READ_R2_mod_m;
                            CMD_READ_R_mod_m:
                                next_state <= STATE_READ_R_mod_m;
                            CMD_READ_e_width:
                                next_state <= STATE_READ_e_width;
                            CMD_READ_e:
                                next_state <= STATE_READ_e;
                            CMD_WRITE: 
                                next_state <= STATE_WRITE_DATA;
                            
                            default:
                                next_state <= STATE_RESET_MONT;
                        endcase
                    end
                    
                STATE_RESET_MONT:
                    begin
                        case (cmd_Q[3:0])
                            CMD_COMPUTE_3B:
                               next_state <= STATE_COMPUTE_3B;
                            
                            default:
                                next_state <= STATE_RESET_MONT;
                        endcase
                    end
                
                STATE_READ_integer_x:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;
                STATE_READ_modulus_m:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;
                STATE_READ_R2_mod_m:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;
                STATE_READ_R_mod_m:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;
                STATE_READ_e_width:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;
                STATE_READ_e:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;

                
                                
                STATE_COMPUTE_3B: 
                    next_state <= STATE_COMPUTE_WAIT;
                    
               
                    
                STATE_COMPUTE_WAIT:
                    next_state <= (mont_done) ? STATE_ASSERT_DONE : r_state;
                    
                   
               

                STATE_WRITE_DATA:
                    next_state <= (fpga_to_arm_data_ready) ? STATE_ASSERT_DONE : r_state;
                    
             

                STATE_ASSERT_DONE:  
                    next_state <= (fpga_to_arm_done_read) ? STATE_WAIT_FOR_CMD : r_state;
                    


                default:
                    next_state <= STATE_WAIT_FOR_CMD;

            endcase
        end
    end

    /// - Synchronous State Update

    always @(posedge(clk))
        if (resetn==1'b0)
            r_state <= STATE_WAIT_FOR_CMD;
        else
            r_state <= next_state;   

    ////////////// - Computation

    
    reg  [1023:0] reg_integer_x, reg_modulus_m, reg_R2_mod_m, reg_R_mod_m, reg_e_width, reg_e;
 
    
    //assign accel_din = reg_X_Q;

    always @(posedge(clk))
        if (resetn==1'b0)
        begin
            reg_integer_x  <= 1024'b0;
            reg_modulus_m  <= 1024'b0;
            reg_R2_mod_m   <= 1024'b0;
            reg_R_mod_m    <= 1024'b0;
            reg_e_width    <= 1024'b0;
            reg_e          <= 1024'b0;

        end
        else
        begin
            case (r_state)
                STATE_READ_integer_x: begin
                    if (arm_to_fpga_data_valid) reg_integer_x <= data_in;
                    else                        reg_integer_x <= reg_integer_x; 
                end
                STATE_READ_modulus_m: begin
                    if (arm_to_fpga_data_valid) reg_modulus_m <= data_in;
                    else                        reg_modulus_m <= reg_modulus_m; 
                end
                STATE_READ_R2_mod_m: begin
                    if (arm_to_fpga_data_valid) reg_R2_mod_m <= data_in;
                    else                        reg_R2_mod_m <= reg_R2_mod_m; 
                end
                STATE_READ_R_mod_m: begin
                    if (arm_to_fpga_data_valid) reg_R_mod_m <= data_in;
                    else                        reg_R_mod_m <= reg_R_mod_m; 
                end
                STATE_READ_e_width: begin
                    if (arm_to_fpga_data_valid) reg_e_width <= data_in;
                    else                        reg_e_width <= reg_e_width; 
                end
                STATE_READ_e: begin
                    if (arm_to_fpga_data_valid) reg_e <= data_in;
                    else                        reg_e <= reg_e; 
                end

            
                
            
               
                default: begin
                    reg_integer_x <= reg_integer_x;
                    reg_modulus_m <= reg_modulus_m;
                    reg_R2_mod_m <= reg_R2_mod_m;
                    reg_R_mod_m <= reg_R_mod_m;
                    reg_e_width <= reg_e_width;
                    reg_e <= reg_e;
                end
                
            endcase
        end
    
    reg reset_mont;
    //reg           in_b_sel;
        
    always @(*) begin
        case (r_state)
          
            
            STATE_COMPUTE_3B: begin
                                            
                                            start_mont  <= 1'b1;
                                            
                                            reset_mont  <= 1'b0;
            end
            
            
            
            STATE_COMPUTE_WAIT: begin
                                           
                                            start_mont  <= 1'b0;
                                            
                                            reset_mont  <= 1'b0;
            end
            
        

            STATE_RESET_MONT: begin
                                            
                                            start_mont  <= 1'b0;
                                           
                                            reset_mont  <= 1'b1;
            end            
 
           
                                              
            default: begin
                                           
                                            start_mont  <= 1'b0;
                                            
                                            reset_mont  <= 1'b0;
            end
        endcase
    end
    
    wire [9:0] count_out_reg;
    wire [4:0] expo_state;
    wire [1023:0] integer_x_reg_out;
    
    assign fpga_to_arm_data       = result;

    ////////////// - Valid signals for notifying that the computation is done

    /// - Port handshake

    reg r_fpga_to_arm_data_valid;
    reg r_arm_to_fpga_data_ready;

    always @(posedge(clk)) begin
        r_fpga_to_arm_data_valid = (r_state==STATE_WRITE_DATA);
        r_arm_to_fpga_data_ready = (r_state==STATE_READ_integer_x||STATE_READ_modulus_m||STATE_READ_R2_mod_m||STATE_READ_R_mod_m||STATE_READ_e||STATE_READ_e_width );
    end
    
    assign fpga_to_arm_data_valid = r_fpga_to_arm_data_valid;
    assign arm_to_fpga_data_ready = r_arm_to_fpga_data_ready;
    
    /// - Done signal
    
    reg r_fpga_to_arm_done;

    always @(posedge(clk))
    begin        
        r_fpga_to_arm_done <= (r_state==STATE_ASSERT_DONE);
    end

    assign fpga_to_arm_done = r_fpga_to_arm_done;
    
    ////////////// - Debugging signals
    
    
//    reg LED1;
    
//    always@(posedge clk)
//    begin
//       if(!resetn)
//         LED1<=0;
//       else if(r_state==STATE_COMPUTE_3B && start_mont  == 1'b1)
//         begin
//            LED1 <= 1;
//         end
//       else begin
//            LED1 <= LED1;
//       end
//    end
    
//    reg LED2;
//    always@(posedge clk)
//     begin
//        if(!resetn)
//          LED2<=0;
//        else if(mont_done)
//          begin
//             LED2 <= 1;
//          end
//        else begin
//             LED2 <= LED2;
//        end
//     end   
    
    
    // The four LEDs on the board are used as debug signals.
    // Here they are used to check the state transition.
    assign leds             = expo_state[3:0];
    //assign leds             = {1'b0,r_state};
    
    // multiplexer in b
   
    
  
    //montgomery module:
   

    montgomery_Exponential exponential(
        .clk         (clk),
        .resetn      (~(reset_mont | ~resetn)),
        .start       (start_mont),
        .integer_x   (reg_integer_x),
        .R2_mod_m    (reg_R2_mod_m),
        .R_mod_m     (reg_R_mod_m),
        .modulus_m   (reg_modulus_m),
        .e           (reg_e),
        .e_width     (reg_e_width[11:0]),
        .result      (result),
        .done        (mont_done)
//        .expo_state  (expo_state),
//        .count_out_reg(count_out_reg),
//        .integer_x_reg_out(integer_x_reg_out)
    );
endmodule
