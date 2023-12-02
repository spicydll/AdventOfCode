       identification division.
       program-id. "calorie".
       author. Mason Schmidgall.
       
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
       01  ws-max pic 9(18) value 0.
       
       procedure division.
           open input SYSIN
           perform until EOF
           read SYSIN        
               AT END SET EOF TO true
           end-read
           if ln not = SPACE and low-value
               compute ws-current= ws-current + (function numval (ln))
           else
               if ws-current > ws-max
                   move ws-current to ws-max
               end-if
               move 0 to ws-current
           end-if
           end-perform.

           display ws-max.
    
       stop run.