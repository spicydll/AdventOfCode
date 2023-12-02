       identification division.
       program-id. "calorie".
       author. u/madogson.
       
       environment division.
       input-output section.
       file-control.
           select SYSIN assign to KEYBOARD organization line sequential.

       data division.
       file section.
       fd SYSIN.
       01 ln pic x(255).
           88 EOF VALUE high-values.
           
       working-storage section.
       01  ws-current pic 9(18) value 0.
       01  ws-temp pic 9(18).
       01  ws-max1 pic 9(18) value 0.
       01  ws-max2 pic 9(18) value 0.
       01  ws-max3 pic 9(18) value 0.
       01  ws-total pic 9(18) value 0.
       
       procedure division.
           open input SYSIN
           perform until EOF
           read SYSIN        
               AT END SET EOF TO true
           end-read
           if not EOF and (ln not = SPACE and low-value)
               compute ws-current= ws-current + (function numval (ln))
           else
               if ws-current > ws-max1
                   move ws-max1 to ws-temp
                   move ws-current to ws-max1
                   move ws-temp to ws-current
               end-if
               if ws-current > ws-max2
                   move ws-max2 to ws-temp
                   move ws-current to ws-max2
                   move ws-temp to ws-current
               end-if
               if ws-current > ws-max3
                   move ws-current to ws-max3
               end-if
               move 0 to ws-current
           end-if
           end-perform.

           compute ws-total= ws-max1 + ws-max2 + ws-max3.

           display ws-total.
    
       stop run.