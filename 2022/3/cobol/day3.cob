       identification division.
       program-id. "day3".
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
       01 ws-index pic 9(18) value 1.
       01 ws-str-len pic 9(18).
       01 ws-priority-total pic 9(18) value 0.
       
       procedure division.
           open input SYSIN
           perform until EOF
           read SYSIN        
               AT END SET EOF TO true
           end-read
           if not EOF
               compute ws-str-len= length of ln / 2
               perform varying ws-index from 1 by 1 
               until ws-index > ws-str-len
               display ln(ws-index:1)
               end-perform
           end-if
           end-perform.
    
       stop run.
