`timescale 1ns / 1ps

module montgomery(
    input           clk,
    input           resetn,
    input           start,
    input  [1023:0] in_a,
    input  [1023:0] in_b,
    input  [1023:0] in_m,
    output reg [1023:0] result,  
    output reg      done
//    output reg [4:0] mont_state,
//    output reg [9:0 ]count_out
     );
     
 
    /*
    Student tasks:
    1. Instantiate an Adder
    2. Use the Adder to implement the Montgomery multiplier in hardware.
    3. Use tb_montgomery.v to simulate your design.
    */
    reg [1026:0]  in_b_reg;
    reg [1023:0] in_a_reg;
    reg [1026:0] in_m_reg, m2x_in_m_reg;
    reg [1027:0] C;
    reg [4:0] state;
    wire [1027:0] add_result;
    
 reg [9:0] count;
//reg [3:0] check;
//always@(*)
//begin
//   mont_state = {1'b0, check};
//   count_out = count;
//end





            parameter  INITIAL                = 5'b00000;
            parameter  PREPARE                = 5'b00001;
            parameter  WAIT_PREPARE           = 5'b00010;
            parameter  DUMMY_WAIT_PREPARE     = 5'b00011;
            parameter  STEP2                  = 5'b00100;
            
            parameter BEFORE_STEP3            = 5'b00101;
            
            parameter  STEP3                  = 5'b00110; //6
            parameter  WAIT_STEP3             = 5'b00111;
            parameter  DUMMY_STEP3            = 5'b01000; //8
            parameter  sub_STEP3              = 5'b01001; //9
            parameter  WAIT_sub_STEP3         = 5'b01010;
            parameter  DUMMY_WAIT_sub_STEP3   = 5'b01011;
            parameter  STEP4                  = 5'b01100; //12
            parameter  DUMMY_STEP4            = 5'b01101;
            parameter  BEFORE_WAIT_STEP5      = 5'b01110;
            parameter  WAIT_STEP5             = 5'b01111;
            parameter  DUMMY_WAIT_STEP5       = 5'b10000;
            parameter  BEFORE_WAIT_STEP7      = 5'b10001;
            parameter  WAIT_STEP7             = 5'b10010;
            parameter  DUMMY_WAIT_STEP7       = 5'b10011;
            parameter  DUMMY_DUMMY_STEP3      = 5'b10100;
            parameter  BEFORE_WAIT_STEP9      = 5'b10101;
            parameter  WAIT_STEP9             = 5'b10110;
            parameter  DUMMY_WAIT_STEP9       = 5'b10111;
            parameter DUMMY_STEP11            = 5'b11000; //24
            parameter  STEP11                 = 5'b11001; //25
            
            
            parameter  STEP13                 = 5'b11010; //26
            parameter  BEFORE_STEP14          = 5'b11011;
            parameter  STEP14                 = 5'b11100; //27
            parameter  WAIT_STEP14            = 5'b11101; //28
            parameter  DUMMY_WAIT_STEP14      = 5'b11110;
            parameter  DONE                   = 5'b11111;

   
   
//   always@(posedge clk)
//            begin
//                if (!resetn)
//                begin
//                    check <= 4'b0000;
//                end
//                else if (state == BEFORE_WAIT_STEP9)
//                begin
//                   check[0] <= 1'b1;
//                end
//                else if (state == BEFORE_WAIT_STEP7)
//                                begin
//                                   check[1] <= 1'b1;
//                                end
//                else if (state == BEFORE_WAIT_STEP5)
//                   begin
//                       check[2] <= 1'b1;
//                   end
//                else if (state == STEP13)
//                   begin
//                       check[3] <= 1'b1;
//                   end
//                else begin
//                   check <= check;
//                end
//            end
   
   
        
    always @ (posedge clk)
        begin
            if (!resetn) 
                begin
//                    in_a_reg <= 0;
                    in_b_reg <= 1027'b0;
                    in_m_reg <= 1027'b0;
                    m2x_in_m_reg <= 1027'b0;
                end
            else if (start) begin
//                in_a_reg <= {3'b0,in_a};
                in_b_reg <= {3'b000,in_b};
                in_m_reg <= {3'b000,in_m};
                m2x_in_m_reg <= in_m<< 1'b1;
            end

        end 
        
   
    always @ (posedge clk)
            begin
                if (!resetn) 
                    begin
                        in_a_reg <= 1024'b0;
                        
                    end
                else if (start) begin
                    in_a_reg <= in_a;
                    
                end
                else if (state == BEFORE_STEP3) begin
                     if (count == 10'b0) begin
                        in_a_reg <= in_a_reg;
                     end
                     else begin
                        in_a_reg <= in_a_reg >> 2'b10;
                     end
                end       
                else begin
                    in_a_reg <= in_a_reg;
                end
            end      
      
        
        
        
        

reg subtract, add_start;
reg [1026:0] a,b;

reg resetn_add;

mpadder dut
       (.in_a(a),
        .in_b(b),
        .subtract(subtract),
        .start(add_start),
        .result(add_result),
        .done(add_done),
        .clk(clk),
        .resetn(resetn_add)
        
        );


reg [1026:0] m3x_in_m_reg;

always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                m3x_in_m_reg <= 1027'b0;
            end
        else 
            begin
                if (state == WAIT_PREPARE && add_done) 
                    begin
                        m3x_in_m_reg <= add_result;
                    end
            end
    end


always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                C <= 1028'b0;
            end
        else if (state == WAIT_STEP3 && add_done)
            begin
                C <= add_result;
            end
        else if (state == WAIT_sub_STEP3 && add_done) 
            begin
                C <= add_result;
            end
        else if (state == WAIT_STEP5 && add_done)
            begin
                C <= add_result >> 2'b10;
            end
        else if (state == WAIT_STEP7 && add_done) 
            begin
                C <= add_result >> 2'b10;
            end
        else if (state == WAIT_STEP9 && add_done)
            begin
                C <= add_result >> 2'b10;
            end
        else if (state == WAIT_STEP14 && add_done && !add_result[1027]) 
            begin
                C <= add_result;
            end
        else if (state == STEP11)
            begin
                C <= C >> 2'b10;
            end
        else if (state == DONE)
            begin
               C <= 1028'b0; 
            end
    end



always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                result <= 1024'b0; 
            end
        else 
            begin
                if (state == DONE) 
                    begin
                        result <= C[1023:0];
                    end
            end
    end

always @ (posedge clk)
    begin
        if (!resetn) 
            begin
                done <= 1'b0;
            end
        else 
            begin
                if (state == DONE) 
                    begin
                        done <= 1'b1;
                    end
                else 
                    begin
                        done <= 1'b0;
                    end
            end
    end




reg [4:0] nextstate;

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



    
    always @ (*)
         begin
             if (!resetn) 
                 begin
                     nextstate = INITIAL;
                     resetn_add = 1'b0;
                 end
             else if (start)
                 begin
                     nextstate = PREPARE;
                     resetn_add = 1'b0;
                 end
             else if (state == PREPARE) 
                 begin
                     nextstate = WAIT_PREPARE;
                     resetn_add = 1'b1;
                 end
             else if (state == WAIT_PREPARE)
                 begin
                     if (add_done) 
                         begin
//                            nextstate = DUMMY_WAIT_PREPARE; 
                            nextstate = STEP2;
                            resetn_add = 1'b1;
                         end
                     else 
                         begin
                            nextstate = WAIT_PREPARE; 
                            resetn_add = 1'b1;
                         end
                 end
//             else if (state == DUMMY_WAIT_PREPARE) 
//                 begin
//                     nextstate = STEP2;
//                     resetn_add = 1'b0;
//                 end
             else if (state == STEP2) 
                 begin
                     resetn_add = 1'b0;
                     if (count == 10'b0111111111) 
                         begin
                             nextstate = BEFORE_STEP14;
                         end
                     else 
                         begin
                             nextstate = BEFORE_STEP3;
                             
                         end
                 end
             else if (state == BEFORE_STEP3)
                 begin
                    resetn_add = 1'b0;
                    nextstate = STEP3;
                 end
             else if (state == STEP3)
                 begin
                     if (in_a_reg[1:0] == 2'b00)
                     begin
                     nextstate = STEP4; 
                     resetn_add = 1'b1;
                     end
                     else begin
                     nextstate = WAIT_STEP3; 
                     resetn_add = 1'b1;
                     end
                 end
             else if (state == WAIT_STEP3) 
                 begin
                     if (add_done) 
                       begin
//                         nextstate = DUMMY_DUMMY_STEP3;
                         nextstate = DUMMY_STEP3;
                         resetn_add = 1'b0;
                       end
                     else 
                         begin
                             nextstate = WAIT_STEP3;
                             resetn_add = 1'b1;
                         end
                 end
//             else if (state == DUMMY_DUMMY_STEP3) 
//                                  begin
//                                      nextstate = DUMMY_STEP3;
//                                      resetn_add = 1'b0;
//                                  end
             else if (state == DUMMY_STEP3)
                 begin
                         resetn_add = 1'b0;
                             if (in_a_reg[1:0] == 2'b11) 
                         begin
                             nextstate = sub_STEP3;
                         end
                             else 
                         begin
                             nextstate = STEP4;
                         end
                 end
             else if (state == sub_STEP3)
                 begin
                     nextstate = WAIT_sub_STEP3;
                     resetn_add = 1'b1;
                 end
             else if (state == WAIT_sub_STEP3) 
                 begin
                     if (add_done) 
                         begin
//                             nextstate = DUMMY_STEP4;
                             nextstate = STEP4;
                             resetn_add = 1'b1;
                         end
                     else 
                         begin
                             nextstate = WAIT_sub_STEP3;
                             resetn_add = 1'b1;
                         end
                 end
//             else if (state == DUMMY_STEP4)
//                 begin
//                     resetn_add = 1'b0;
//                     nextstate = STEP4;
//                 end
             else if (state == STEP4)
                 begin
                     if (C[1:0] == 2'b01 && in_m_reg[1:0] == 2'b01) 
                         begin
                             nextstate = BEFORE_WAIT_STEP5;
                             resetn_add = 1'b0;
                         end
                     else if (C[1:0] == 2'b11 && in_m_reg[1:0] == 2'b11)
                         begin
                             nextstate = BEFORE_WAIT_STEP5;
                             resetn_add = 1'b0;
                         end
                     else if (C[1:0] == 2'b10 && in_m_reg[1:0] == 2'b01) 
                         begin
                             nextstate = BEFORE_WAIT_STEP7;
                             resetn_add = 1'b0;
                         end
                     else if (C[1:0] == 2'b10 && in_m_reg[1:0] == 2'b11)
                         begin
                             nextstate = BEFORE_WAIT_STEP7;
                             resetn_add = 1'b0;
                         end
                     else if (C[1:0] == 2'b11 && in_m_reg[1:0] == 2'b01) 
                         begin
                             nextstate = BEFORE_WAIT_STEP9;
                             resetn_add = 1'b0;
                         end
                     else if (C[1:0] == 2'b01 && in_m_reg[1:0] == 2'b11)
                         begin
                             nextstate = BEFORE_WAIT_STEP9;
                             resetn_add = 1'b0;
                         end
                     else begin
//                         nextstate = DUMMY_STEP11;
                         nextstate = STEP11;
                         resetn_add = 1'b1;
                     end
                 end
//             else if (state == DUMMY_STEP11)
//                 begin
//                     nextstate = STEP11;
//                     resetn_add = 1'b1;
//                 end
             else if (state == WAIT_STEP5)
                 begin
                     if (add_done) 
                         begin
//                             nextstate = DUMMY_WAIT_STEP5;
                             nextstate = STEP2;
                             resetn_add = 1'b0;
                         end
                     else 
                         begin
                             nextstate = WAIT_STEP5;
                             resetn_add = 1'b1;
                         end
                 end
//             else if (state == DUMMY_WAIT_STEP5)
//                 begin
//                     nextstate = STEP2;
//                     resetn_add = 1'b0;
//                 end
             else if (state == BEFORE_WAIT_STEP9)
                 begin
                     nextstate = WAIT_STEP9;
                     resetn_add = 1'b1;
                 end
             else if (state == BEFORE_WAIT_STEP5)
                 begin
                     nextstate = WAIT_STEP5;
                     resetn_add = 1'b1;
                 end
             else if (state == BEFORE_WAIT_STEP7)
                 begin
                     nextstate = WAIT_STEP7;
                     resetn_add = 1'b1;
                 end
             else if (state == WAIT_STEP7)
                 begin
                     if (add_done) 
                         begin
//                             nextstate = DUMMY_WAIT_STEP7;
                             nextstate = STEP2;
                             resetn_add = 1'b0;
                         end
                     else 
                         begin
                             nextstate = WAIT_STEP7;
                             resetn_add = 1'b1;
                         end
                 end
             
//             else if (state == DUMMY_WAIT_STEP7)
//                                  begin
//                                      nextstate = STEP2;
//                                      resetn_add = 1'b0;
//                                  end
             
             else if (state == WAIT_STEP9)
                 begin
                     if (add_done) 
                         begin
//                             nextstate = DUMMY_WAIT_STEP9;
                             nextstate = STEP2;
                             resetn_add = 1'b0;
                         end
                     else 
                         begin
                             nextstate = WAIT_STEP9;
                             resetn_add = 1'b1;
                         end
                 end
                 
//             else if (state == DUMMY_WAIT_STEP9)
//                                                   begin
//                                                       nextstate = STEP2;
//                                                       resetn_add = 1'b0;
//                                                   end
             
             else if (state == STEP11) 
                 begin
                     nextstate = STEP2;
                     resetn_add = 1'b1;
                 end
             else if (state ==BEFORE_STEP14)
                 begin
                    nextstate = STEP14;
                    resetn_add = 1'b0;
                 end
             else if (state == STEP14)
                 begin
                     nextstate = WAIT_STEP14;
                     resetn_add = 1'b1;
                 end
             else if (state == WAIT_STEP14) 
                 begin
                     if (add_done) 
                         begin
//                             if (!add_result[1027])
//                                begin
                                nextstate = DUMMY_WAIT_STEP14;
                                resetn_add = 1'b1;
//                                end
//                             else begin
//                                nextstate = DONE;
//                                resetn_add = 1;
//                             end
                         end
                     else 
                         begin
                             nextstate = WAIT_STEP14;
                             resetn_add = 1'b1;
                         end
                 end
                 
             else if (state == DUMMY_WAIT_STEP14)
                   begin
                          if (add_result[1027])
                             begin
                                nextstate = DONE;
                                resetn_add = 1'b0;
                             end
                          else begin
//                                nextstate = STEP13;
                                nextstate = BEFORE_STEP14;
                                resetn_add = 1'b0;
                          end
//                        nextstate = STEP13;
//                        resetn_add = 0;
                   end
                 
//             else if (state == STEP13)
//                 begin
//                     resetn_add = 1'b0;
//                     if (add_result[1027]) 
//                         begin
//                             nextstate = DONE;
//                         end
//                     else 
//                         begin
//                             nextstate = BEFORE_STEP14;
//                         end
//                 end
             else if (state == DONE) 
                 begin
                     nextstate = INITIAL;
                     resetn_add = 1'b1;
                 end
             else 
                 begin
                     nextstate = INITIAL;
                     resetn_add = 1'b1;
                 end
         end




   
    always @ (posedge clk)
        begin
            if (!resetn) 
                begin
                    count <= 10'b1111111111;
                end
            else if (state == STEP2)
                begin
                   if (count == 10'b0111111111) 
                       begin
                           count <= 10'b1111111111;
                       end
                   else 
                       begin
                           count <= count + 1'b1;
                       end
                end
        end




      always @ (*)
                   begin
                       case (state) 
                           INITIAL:
                               begin
                                   subtract = 1'b0;
                                   add_start = 1'b0;
                               end
                           PREPARE:
                               begin
                                   subtract = 1'b0;
                                   add_start = 1'b1;
                               end
                           WAIT_PREPARE:
                               begin
                                   subtract = 1'b0;
                                   add_start = 1'b0;
                               end
                           STEP3:
                               begin
                                  if (in_a_reg[1:0] == 2'b00)
                                  begin
                                  add_start = 1'b0;
                                  subtract = 1'b0;
                                  end
                                  else begin
                                  add_start = 1'b1;
                                  subtract = 1'b0;
                                  end 
                               end
                           WAIT_STEP3:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b0;
                               end
                           sub_STEP3:
                               begin
                                   add_start = 1'b1;
                                   subtract = 1'b0;
                               end
                            WAIT_sub_STEP3:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b0;
                               end
                            STEP4:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b0;
                               end
                            BEFORE_WAIT_STEP9:
                               begin
                                  add_start = 1'b1;
                                  subtract = 1'b0;
                               end
                            BEFORE_WAIT_STEP5:
                               begin
                                  add_start = 1'b1;
                                  subtract = 1'b0;
                               end
                            BEFORE_WAIT_STEP7:
                               begin
                                   add_start = 1'b1;
                                   subtract = 1'b0;
                               end
                            WAIT_STEP5:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b0;
                               end
                            WAIT_STEP7:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b0;
                               end
                            WAIT_STEP9:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b0;
                               end
                            BEFORE_STEP14:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b1;
                               end
                            STEP14:
                               begin
                                   add_start = 1'b1;
                                   subtract = 1'b1;
                               end
                            WAIT_STEP14:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b1;
                               end
                           default:
                               begin
                                   add_start = 1'b0;
                                   subtract = 1'b0;
                               end
                       endcase
                   end

       





       always @ (*)
                              begin
                                  case (state) 
                                      INITIAL:
                                          begin
                                              a = 1027'b0;
                                              b = 1027'b0;
                                          end
                                      PREPARE:
                                          begin
                                              a = in_m_reg;
                                              b = m2x_in_m_reg;
                                          end
                                       WAIT_PREPARE:
                                          begin
                                             a = in_m_reg;
                                             b = m2x_in_m_reg;
                                          end
                                      STEP3:
                                          begin
                                              a = C[1026:0];
                                              if (in_a_reg[1:0] == 2'b00) 
                                                  begin
                                                      b = 1027'b0;
                                                  end
                                              else if (in_a_reg[1:0] == 2'b01)
                                                  begin
                                                      b = in_b_reg;
                                                  end
                                              else if (in_a_reg[1:0] == 2'b10)
                                                  begin
                                                      b = in_b_reg << 1'b1;
                                                  end 
                                              else if (in_a_reg[1:0] == 2'b11)       
                                                  begin
                                                      b = in_b_reg;
                                                  end
                                              else 
                                                  begin
                                                      b = 1027'b0;
                                                  end
                                          end
                                       WAIT_STEP3:
                                           begin
                                              a = C[1026:0];
                                              if (in_a_reg[1:0] == 2'b00) 
                                                  begin
                                                      b = 1027'b0;
                                                  end
                                              else if (in_a_reg[1:0] == 2'b01)
                                                  begin
                                                      b = in_b_reg;
                                                  end
                                              else if (in_a_reg[1:0] == 2'b10)
                                                  begin
                                                      b = in_b_reg << 1'b1;
                                                  end 
                                              else if (in_a_reg[1:0] == 2'b11)       
                                                  begin
                                                      b = in_b_reg;
                                                  end
                                              else 
                                                  begin
                                                      b = 1027'b0;
                                                  end
                                           end
                                       sub_STEP3:
                                           begin
                                               a = C[1026:0];
                                               b = in_b_reg << 1'b1;
                                           end
                                       WAIT_sub_STEP3:
                                           begin
                                               a = C[1026:0];
                                               b = in_b_reg << 1'b1;
                                           end
//                                       STEP4:
//                                           begin
//                                               if (C[1:0] == 1 && in_m_reg[1:0] == 1) 
//                                           begin
//                                               a = C[1026:0];
//                                               b = m3x_in_m_reg;
//                                           end
                                           
//                                       else if (C[1:0] == 3 && in_m_reg[1:0] == 3)
//                                           begin
//                                               a = C[1026:0];
//                                               b = m3x_in_m_reg;
//                                           end
//                                       else if (C[1:0] == 2 && in_m_reg[1:0] == 1) 
//                                           begin
//                                               a = C[1026:0];
//                                               b = m2x_in_m_reg;
//                                           end
//                                       else if (C[1:0] == 2 && in_m_reg[1:0] == 3)
//                                           begin
//                                               a = C[1026:0];
//                                               b = m2x_in_m_reg;
//                                           end
//                                       else if (C[1:0] == 3 && in_m_reg[1:0] == 1) 
//                                           begin
//                                               a = C[1026:0];
//                                               b = in_m_reg;
//                                           end
//                                       else if (C[1:0] == 1 && in_m_reg[1:0] == 3)
//                                           begin
//                                               a = C[1026:0];
//                                               b = in_m_reg;
//                                           end
//                                       else 
//                                           begin
//                                               a = 0;
//                                               b = 0;
//                                           end
//                                           end
                                       BEFORE_WAIT_STEP9:
                                           begin
                                              a = C[1026:0];
                                              b = in_m_reg;
                                           end
                                       WAIT_STEP9:
                                           begin
                                              a = C[1026:0];
                                              b = in_m_reg;
                                           end
                                       BEFORE_WAIT_STEP5:
                                           begin
                                              a = C[1026:0];
                                              b = m3x_in_m_reg;
                                           end
                                       WAIT_STEP5:
                                           begin
                                              a = C[1026:0];
                                              b = m3x_in_m_reg;
                                           end
                                       BEFORE_WAIT_STEP7:
                                           begin
                                              a = C[1026:0];
                                              b = m2x_in_m_reg; 
                                           end
                                       WAIT_STEP7:
                                           begin
                                              a = C[1026:0];
                                              b = m2x_in_m_reg;
                                           end
                                       STEP14:
                                           begin
                                               a = C[1026:0];
                                               b = in_m_reg;
                                           end
                                       WAIT_STEP14:
                                           begin
                                               a = C[1026:0];
                                               b = in_m_reg;
                                           end
                                      default:
                                          begin
                                              a = 1027'b0;
                                              b = 1027'b0;
                                          end
                                  endcase
                              end











endmodule