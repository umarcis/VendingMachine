`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2023 01:19:27 AM
// Design Name: 
// Module Name: vending_machine
// Project Name: Vending Machine 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vending_machine (
  input wire clk,
  input wire reset,
  input wire [3:0] coin_insert,
  input wire [1:0] product_selection,
  input wire cancel_request,
  output reg product_dispensed,
  output reg change_dispensed,
  output reg [3:0] refund_amount
 
);

  // Internal registers
  reg [2:0] state;
  reg [3:0] coin_count;
  reg [3:0] total_coin_count;
  reg [3:0] product_price;

  // Constants for product prices
  parameter PRICE_A = 5;
  parameter PRICE_B = 10;
  parameter PRICE_C = 15;

  // State enumeration
  parameter [2:0] IDLE = 3'b000;
  parameter [2:0] WAIT_FOR_AMOUNT = 3'b001;
  parameter [2:0] DISPENSE_PRODUCT = 3'b010;
  parameter [2:0] DISPENSE_CHANGE = 3'b011;
  parameter [2:0] RETURN_AMOUNT = 3'b100;
  parameter [2:0] REFUND_AMOUNT = 3'b101;


  always @(posedge clk or posedge reset) begin
    
    if (reset) begin
      state <= IDLE;
      coin_count <= 0;
      total_coin_count <= 0;
      product_price <= 0;
      product_dispensed <= 0;
      change_dispensed <= 0;
      refund_amount <= 0;
    end
    else begin
      case (state)
        IDLE:
          begin
            if (product_selection != 2'b00) begin
              case (product_selection)
                2'b01: product_price <= PRICE_A;
                2'b10: product_price <= PRICE_B;
                2'b11: product_price <= PRICE_C;
                default: product_price <= 4'd15;
              endcase
              product_dispensed <= 0;
              change_dispensed <= 0;
              refund_amount <= 0;
              state <= WAIT_FOR_AMOUNT;
            end
            else if (cancel_request) begin
              state <= REFUND_AMOUNT;
            end
          end

        WAIT_FOR_AMOUNT:
          begin
            if (coin_insert != 0) begin
              coin_count <= coin_count + coin_insert;
              total_coin_count <= total_coin_count + coin_insert;

              if (coin_insert >= product_price) begin
                if (coin_insert > product_price)
                  state <= DISPENSE_CHANGE;
                else
                  state <= DISPENSE_PRODUCT;
              end
              else
                state <= WAIT_FOR_AMOUNT;
            end
            else if (cancel_request) begin
              state <= RETURN_AMOUNT;
            end
            
            else 
                state <= WAIT_FOR_AMOUNT;
                
          end

        DISPENSE_PRODUCT:
          begin
            product_dispensed <= 1;
            refund_amount <= coin_insert - product_price;
            #40;
            state <= IDLE;
          end


        DISPENSE_CHANGE:
          begin
            product_dispensed <= 1;
            change_dispensed <= 1;
            refund_amount <= coin_insert - product_price;
            #40;
            state <= IDLE;
          end

        RETURN_AMOUNT:
          begin
            refund_amount <= coin_insert;
            #40;
            state <= IDLE;
          end

        REFUND_AMOUNT:
          begin
            refund_amount <= total_coin_count;
            coin_count <= 0;
            #40;
            state <= IDLE;
          end
      endcase
    end
  end

endmodule

               
