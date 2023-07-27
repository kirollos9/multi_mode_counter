class counter_class;
	rand logic rst,init;
	rand logic [1:0]cntr;
	rand logic [3:0]data;
	rand logic [3:0]other;
	constraint c {
	rst dist {0:=99,1:=1};
	init dist {0:=95,1:=5};
	cntr dist {0:=25,1:=25,2:=25,3:=25};
	other !=(4'b1111||4'b0000);
	data dist {4'b1111:=20,4'b0000:=20};		
	}
	
endclass



module test;
logic clk,rst,init;
logic[1:0]control;
logic [3:0]load_data;
logic winner,loser;
logic game_over;
logic [1:0]who;
logic [3:0] counter;
multi_mode_counter dut (clk,rst,control,init,load_data,winner,loser,game_over,who,counter);

covergroup cg @(posedge clk);
		a1:coverpoint control{
		bins one={3};
		bins two={2};
		bins three={1};
		bins zero={0};
		}
		a2:coverpoint init;
		a3:coverpoint rst;
		a4:coverpoint load_data{
		bins max={4'b1111};
		bins min={4'b0000};
		bins other=default;
		}

	endgroup

	cg cov=new();
	counter_class cl=new();

/********************************************************************************
 * clk declaration
 ********************************************************************************/
initial begin
	clk=0;
	forever
	#1clk=~clk;
end
initial begin
	//first we decalre the inputs
	control=0;
	init=0;
	load_data=5;
	rst=1;
	reset();
	init=1;
	testinit(load_data);
	init=0;
	#150;
	changecontrol(1);
	#150;
	changecontrol(2);
	#150;
	changecontrol(3);
	#150;
	changecontrol(0);
	for(int i=0;i<1000;i++)begin
		assert(cl.randomize());
		#10;
		changecontrol(cl.cntr);
		init=cl.init;
		load_data=cl.data;
		rst=cl.rst;
	end
	$stop;

end
/***************************************************************
 * reset task 
 ***************************************************************/
task reset();
	@(negedge clk);
	rst=1;
	@(negedge clk);
	rst=0;
endtask
/********************************************************************
 * task to change the control signal 
 *******************************************************************/
task changecontrol(input logic [1:0]cntr);
	@(negedge clk);
	control=cntr;
endtask
/*******************************************************************
 * task to test the init
 ******************************************************************/
 task testinit(input logic [3:0]data);
 	@(negedge clk);
 	if(data!=counter)$display("error in load_data it should be=%0d and the actual=%0d",data,dut.counter);
 	else
 		$display("test pass for the init ");
 endtask
 //this assertions check the counter when the reset is set
 //assertion_1:assert property(@(posedge clk) (rst&control[1])|->(counter==15));
 //assertion_2:assert property(@(posedge clk) (rst&~control[1])|->(counter==0));
 //assertion_3:assert property(@(posedge clk) (init&~rst&~game_over)|->##[0:1](counter==load_data));
endmodule