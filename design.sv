/*************************************************************************
 * name:Kirollos Gerges Sobhy 
 * id:1805147
 * ***********************************************************************/
module multi_mode_counter(clk,rst,control,init,load_data,winner,loser,game_over,who,counter);
// parameter to control the width of the counter
parameter W=4; 
/***************************************************************************
 * inputs
 * *************************************************************************/
input clk,rst,init;
input[1:0]control;
input [W-1:0]load_data;
/************************************************************************************
 * outputs
 ************************************************************************************/
output reg winner,loser;
output game_over;
output reg [1:0]who;
output reg [W-1:0]counter;
/*************************************************************************************************
 * internal registers and wires
 *************************************************************************************************/
reg [3:0]winner_counter,loser_counter;//winner and loser counters
wire clr;//clr signal to clear all the counter after the game over is set
assign game_over=((winner_counter==15)||(loser_counter==15))?1:0;//game over output logic
assign clr=(game_over)?1:0;//clr is set when logic is high
/****************************************************************************
 * counter sequencial logic
 ***************************************************************************/
always @(posedge clk or posedge rst)begin
	if(rst)begin
		if(!control[1])
			counter<=0;
		else
			counter<={W{1'b1}};
	end
	else if(clr)begin
		counter<=0;
	end
	else if(init) begin
		counter<=load_data;
	end
	else begin
		case(control)
			2'b01:counter<=counter+2;
			2'b10:counter<=counter-1;
			2'b11:counter<=counter-2;
			default:counter<=counter+1;
		endcase 
	end
	
end
/****************************************************************************************
 * winner and loser and their counters logic
 *****************************************************************************************/
always @(posedge clk or posedge rst)begin
	if(rst)begin
		winner<=0;
		loser<=0;
		winner_counter<=0;
		loser_counter<=0;
	end
	else if(clr)begin
		winner<=0;
		loser<=0;
		winner_counter<=0;
		loser_counter<=0;
	end
	else if(counter==0)begin
		loser<=1;
		winner<=0;
		loser_counter<=loser_counter+1;		
	end
	else if(counter=={W{1'b1}})begin
		winner<=1;
		loser<=0;
		winner_counter<=winner_counter+1;
	end
	else begin
		winner<=0;
		loser<=0;
	end

end
/**************************************
 * who output logic 
 **************************************/
always @(*)begin
	if(winner_counter==15)
		who=2'b10;
	else if(loser_counter==15)
		who=2'b01;
	else
		who=2'b00;
end
endmodule

