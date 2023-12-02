       identification division.
       program-id. reciept

       environment division.
       input-output section.
       file-control.
       select sysin assign to keyboard organization line sequential.

       data division.
           file section.
           fd sysin.
           01 input-line pic x(255).
           88 eof value high-values.

           working-storage section.
           01 item-cost pic 9(2)v9(2).
           01 tip-percent pic 9(3).
           01 tax-percent pic 9(3).
           01 tip pic 9(3)v9(2).
           01 tax pic 9(3)v9(2).
           01 total-cost pic 9(3)v9(2).

       procedure division.
           display "Item Cost: "
           accept item-cost from sysin
           display "Tip: %"
           accept tip-percent from sysin
           display "Tax: %"
           accept tax-percent from sysin

           compute tip= (item-cost * tip-percent / 100).
           compute tax= (item-cost * tax-percent / 100).
           compute total-cost= item-cost + tax + tip.

           display "Total cost: $" total-cost.
      
       stop run.