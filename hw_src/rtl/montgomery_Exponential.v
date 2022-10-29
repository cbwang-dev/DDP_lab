`timescale 1ns / 1ps

module montgomery_Exponential(
    input           clk,
    input           resetn,
    input           start,
    input  [1023:0] integer_x,
    input  [1023:0] R2_mod_m,
    input  [1023:0] R_mod_m,
    input  [1023:0] modulus_m,
    input  [1023:0]   e,
    input  [11:0] e_width,
    output reg [1023:0] result,
    output reg [4:0]expo_state,  
    output reg          done
//    output reg [9:0] count_out_reg,
//    output reg [1023:0] integer_x_reg_out
     );



reg [1023:0]   integer_x_reg, x_tilt_reg;
reg [1023:0]   R2_mod_m_reg;
reg [1023:0]   modulus_m_reg;
reg [1023:0]         e_reg;


//always@(*)
//begin
//    integer_x_reg_out = integer_x_reg;
//end





reg [11:0] count;
reg start_expo;
reg [1023:0]   in_a;
reg [1023:0]   in_b;
reg [1023:0]   A_reg;
wire [1023:0]  result_expo;

reg [3:0] nextstate, state;
wire [4:0] mont_state;

//wire [9:0 ]count_out;


//always@(*)
// begin
//    expo_state = mont_state;
//    count_out_reg = count_out;    
// end
 
 
        parameter  INITIAL          = 4'b0000;
        
        parameter  STEP1            = 4'b0001;
        parameter  WAIT_STEP1       = 4'b0010; //2
        
        parameter  STEP2            = 4'b0011; //3
        parameter  WAIT_STEP2_1     = 4'b0100; //4
        parameter  JUDGE_2_2        = 4'b0101;
        parameter  STEP2_2          = 4'b0110;
        parameter  WAIT_STEP2_2     = 4'b0111; //7
        parameter  DONE_STEP2_2     = 4'b1000;
        parameter  WAIT_STEP3       = 4'b1001;
        




montgomery montgomery_block(
    .clk(clk),
    .resetn(resetn),
    .start(start_expo),
    .in_a(in_a),
    .in_b(in_b),
    .in_m(modulus_m_reg),
    .result(result_expo),  
    .done(done_expo)
//    .mont_state(mont_state),
//    .count_out(count_out)
    
     );


always @ (*)
    begin
        if (!resetn)
           begin
               result = 1024'b0;
           end
        else
           begin
               result = A_reg;
           end
    end



always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                integer_x_reg <= 1024'b0;
                R2_mod_m_reg <= 1024'b0;
                modulus_m_reg <= 1024'b0;
                e_reg <= 1024'b0;
                
            end
        else 
            begin
                
                integer_x_reg <= integer_x;
                R2_mod_m_reg <= R2_mod_m;
                modulus_m_reg <= modulus_m;
                e_reg <= e;
                
            end
            
    end


    always @ (posedge clk)
           begin
               if (!resetn) 
                   begin
                       state <= INITIAL;
                   end
               else 
                   begin
                       state <= nextstate;
                   end
           end


always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                x_tilt_reg <= 0;
            end
        else 
            begin
                if (state == WAIT_STEP1 && done_expo) 
                    begin
                        x_tilt_reg <= result_expo;
                    end
            end
    end



always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                A_reg <= 1024'b0;
            end
        else if (start)
            begin
                A_reg <= R_mod_m; 
            end
        else if (state == WAIT_STEP2_1 && done_expo) 
            begin
                A_reg <= result_expo;
            end
        else if (state == WAIT_STEP2_2 && done_expo)
            begin
                A_reg <= result_expo;
            end
        else if (state == WAIT_STEP3 && done_expo) 
            begin
                A_reg <= result_expo;
            end
        else begin
                A_reg <= A_reg;
        end
    end



always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                done <= 1'b0;
            end
        else if (state == WAIT_STEP3 && done_expo)
            begin
                done <= 1'b1;
            end
        else
            begin
                done <= 1'b0;
            end
    end


always @ (*)
    begin
        if (!resetn) 
            begin
                nextstate = INITIAL;
            end
        else if (start)
            begin
                nextstate = STEP1;
            end
        
        else if (state == STEP1) 
            begin
                nextstate = WAIT_STEP1;
            end
        else if (state == WAIT_STEP1)
            begin
                if (done_expo) 
                    begin
                        nextstate = STEP2;
                    end
                else 
                    begin
                        nextstate = WAIT_STEP1;
                    end
            end
       
        else if (state == STEP2) 
            begin
                if (count == 12'b000000000000) 
                    begin
                        nextstate = WAIT_STEP3;
                    end
                else 
                    begin
                       nextstate = WAIT_STEP2_1; 
                    end
            end
        else if (state == WAIT_STEP2_1)
            begin
                if (done_expo) 
                    begin
                        nextstate = JUDGE_2_2;
                    end
                else 
                    begin
                        nextstate = WAIT_STEP2_1;
                    end
            end
        else if (state == JUDGE_2_2)
            begin
                if (e_reg[count]) 
                    begin
                       nextstate = STEP2_2; 
                    end
                else 
                    begin
                       nextstate = STEP2;
                    end
            end
        else if (state == STEP2_2)
            begin
               nextstate = WAIT_STEP2_2; 
            end
        else if (state == WAIT_STEP2_2) 
            begin
                if (done_expo) 
                    begin
                        nextstate = DONE_STEP2_2;
                    end
                else 
                    begin
                        nextstate = WAIT_STEP2_2;
                    end
            end
        else if (state == DONE_STEP2_2)
            begin
               nextstate = STEP2;
            end
        else if (state == WAIT_STEP3)
            begin
                if (done_expo) 
                    begin
                        nextstate = INITIAL;
                    end
                else 
                    begin
                        nextstate = WAIT_STEP3;
                    end
            end
         else 
            begin
                nextstate = INITIAL;
            end
    end



always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                count <= 12'b000000000000;
            end
        else if (start)
            begin
                count <= e_width;
            end
        else if (state == STEP2) 
            begin
                count <= count - 12'b000000000001;
            end
        else if (count == 12'b000000000000 && state == STEP2)
            begin
                count <= 12'b00000000000;
            end
    end


    always @ (*)
        begin
            case (state) 
                INITIAL:
                    begin
                        in_a = 1024'b0;
                        in_b = 1024'b0;
                        start_expo = 1'b0;
                    end
                STEP1:
                    begin
                        in_a = integer_x_reg;
                        in_b = R2_mod_m_reg;
                        start_expo = 1'b1;
                    end
                WAIT_STEP1:
                    begin
                        in_a = 1024'b0;
                        in_b = 1024'b0;
                        start_expo = 1'b0;
                    end
                STEP2:
                    begin
                        if (count == 12'b0) 
                            begin
                               in_a = A_reg;
                               in_b = 1024'b1;
                               start_expo = 1'b1; 
                            end
                        else 
                            begin
                               in_a = A_reg;
                               in_b = A_reg; 
                               start_expo = 1'b1;
                            end
                    end
                STEP2_2:
                    begin
                       in_a = A_reg;
                       in_b = x_tilt_reg;
                       start_expo = 1'b1; 
                    end
                WAIT_STEP2_2:
                    begin
                        in_a = 1024'b0;
                        in_b = 1024'b0;
                        start_expo = 1'b0;
                    end
                WAIT_STEP3:
                    begin
                        in_a = 1024'b0;
                        in_b = 1024'b0;
                        start_expo = 1'b0;
                    end
                default:
                    begin
                        in_b = 1024'b0;
                        in_a = 1024'b0;
                        start_expo = 1'b0;
                    end
            endcase
        end


endmodule
