module twotrafficlights(
      input  logic clk,
      input  logic rst,
      output logic [2:0] lightsA, 
      output logic [2:0] lightsB
    );
  logic [2:0] state;
  always_ff @( posedge clk or posedge rst ) begin
    if (rst)
        state <= 3'd0;
      else 
        state <= state + 1;
  end
  
  logic flip;
  logic [2:0] a;
  logic [2:0] b;

  always_comb begin
    flip = state[2];
    a = 3'b001;
    b = {state[0] && !state[1], !state[0], !(state[0] ^ state[1])};
    {lightsA, lightsB} = flip ? {b, a} : {a, b};
  end

endmodule
