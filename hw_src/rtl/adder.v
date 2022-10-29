

//----------------------------------------------------------------------------------------------------------------------------------

module mpadder(
    input  wire          clk,
    input  wire          resetn,
    input  wire          
    start,
    input  wire          subtract,
    input  wire [1026:0] in_a,
    input  wire [1026:0] in_b,
    output reg  [1027:0] result,
    output wire          done    
    );

reg [2:0] cycle;


    
    reg [1026:0] in_a_reg;
    reg [1027:0] in_b_reg;
    reg done_reg, done_reg_2;
    reg cin_reg;
    

    assign done = done_reg_2;

    always @ (posedge clk)
        begin
            if (!resetn) 
                begin
                    in_a_reg <= 0;
                    in_b_reg <= 0;
                    cin_reg <= 0;
                end
            else if (start && !subtract) begin
                in_a_reg <= in_a;
                in_b_reg <= {1'b0,in_b};
                cin_reg <= 0;
            end
            else if (start && subtract) begin
                in_a_reg <= in_a;
                in_b_reg <= {1'b1, ~in_b};
                cin_reg <= 1;
            end

        end

wire [1027:0] result_wire;
assign result_wire = in_b_reg + in_a_reg + cin_reg; 

always @ (negedge done_reg)
    begin
//        if (!resetn) 
//            begin
//                result <= 0;
//            end
//        else if (cycle == 2)
//            begin
                result <= result_wire;
//            end
//        else begin
//                result <= result;
//        end
    end

        always @ (posedge clk)
        begin
            if (!resetn) 
                begin
                    cycle <= 0;
                end
            else if (start)
                begin
                    cycle <= 1;
                end
            else begin
                cycle <= cycle + 1;
            end
        end

        always @ (*)
            begin
               if (!resetn) begin
                    done_reg = 0;
                end 
                else if (cycle == 2) begin
                    done_reg = 1;
                end
                else begin
                    done_reg = 0;
                end
            end


always@(posedge clk)
begin
   if(!resetn) begin
      done_reg_2 = 0;
   end
   else if (done_reg == 1) begin
      done_reg_2 = 1;
   end
   else begin
      done_reg_2 = 0;
   end
end



endmodule
