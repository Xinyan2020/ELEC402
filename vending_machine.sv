//Name: Xinyan Qi 
//Student Number: 57890253
module vending_machine(input logic clk, input logic rst, input logic start, input logic [1:0]sel,
			input logic en_one, input logic en_two, input logic en_five,
			output logic productA, output logic productB, output logic productC,
			output logic error, output logic en_change, output logic done);

enum{WAIT,SEL,IDENTIFY,RECEIVE,SUM,CHECK,CAL_CHANGE,OUTPUT_CHANGE,OUTPUT_PRODUCT,DONE}state;

parameter priceA = 2;
parameter priceB = 5;
parameter priceC = 7;

logic [4:0]wait_cnt;
logic [3:0]total_count;
logic [2:0]count_one,count_two,count_five;
logic [2:0]change;
logic buyA,buyB,buyC;

always @(posedge clk) begin
	if(rst == 0)begin
		state <=WAIT;
		{count_one,count_two,count_five} <= 6'b000000;
		{productA,productB,productC} <= 3'b000;	
		{buyA,buyB,buyC} <= 0;
		total_count <= 0;
		wait_cnt <= 0;	
		change <= 0;
		en_change <= 0;
		done <= 0;					
		error <= 0;		
	end
	else begin
		case(state)
			WAIT: begin
				{count_one,count_two,count_five} <= 6'b000000;
				{productA,productB,productC} <= 3'b000;	
				{buyA,buyB,buyC} <= 0;
				total_count <= 0;
				wait_cnt <= 0;	
				change <= 0;
				done <= 0;					
				error <= 0;	
				en_change <= 0;
				if(start == 1'b1)
					state <= SEL;
				else
					state <= WAIT;
			end

			SEL: begin
				state <= IDENTIFY;
				case(sel)
					2'b01: buyA <= 1'b1;
					2'b10: buyB <= 1'b1;
					2'b11: buyC <= 1'b1;
					default: {buyA,buyB,buyC} <= 3'b000;
				endcase
			end

			IDENTIFY: begin
				if(en_one == 1'b1 || en_two == 1'b1 || en_five == 1'b1)
					state <= RECEIVE;
				else begin
					wait_cnt <= wait_cnt + 1'b1;
					if(wait_cnt == 30) begin
						state <= CAL_CHANGE;
						error <= 1;
					end
					else
						state=IDENTIFY;
				end						
			end

			RECEIVE: begin
					state <= SUM;
					if(en_one == 1'b1)
						count_one <= count_one + 1'b1;
					if(en_two == 1'b1)
						count_two <= count_two + 1'b1;
					if(en_five == 1'b1)
						count_five <= count_five + 1'b1;
			end

			SUM: begin
				state <= CHECK;
				total_count <= count_one + 2*count_two + 5*count_five;
			end

			CHECK:begin
				if(buyA == 1'b1) begin
					if(total_count < priceA) 
						state <= IDENTIFY;
					else state <= CAL_CHANGE;
				end
				if(buyB == 1'b1) begin
					if(total_count < priceB) 
						state <= IDENTIFY;
					else state <= CAL_CHANGE;
				end
				if(buyC == 1'b1) begin
					if(total_count < priceC)
						state <= IDENTIFY;
					else state <= CAL_CHANGE;
				end
			end

			CAL_CHANGE: begin
				state <= OUTPUT_CHANGE;
				if(wait_cnt < 30)begin
					case({buyA,buyB,buyC})
						3'b100: change <= (total_count - priceA);
						3'b010: change <= (total_count - priceB);
						3'b001: change <= (total_count - priceC);
					default: change <= 3'b000;
					endcase
				end
				else 
					change <= total_count;
			end

			OUTPUT_CHANGE:begin
				if(change > 0 )begin
					state <= OUTPUT_CHANGE;
					change <= change - 1'b1;
				end
				else begin
					if(wait_cnt < 30)
						state <= OUTPUT_PRODUCT;
					else
						state <= DONE;
				end
			end

			OUTPUT_PRODUCT: begin
				state <= DONE;
				case({buyA,buyB,buyC})
					3'b100: productA = 1;
					3'b010: productB = 1;
					3'b001: productC = 1;
					default: {productA,productB,productC} = 3'b000;
				endcase
			end

			DONE: begin
				state <= WAIT;
				done <= 1;
			end

		endcase
	end
end



always@(*) begin
	case(state)
		OUTPUT_CHANGE: begin
			if(change > 0) en_change = 1;
			else en_change = 0;
		end
	endcase
end

endmodule

					
						
					
					
				
				
					
					
