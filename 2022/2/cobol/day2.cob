       identification division.
       program-id. "day2".
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
       01 ws-opp pic a(1).
       01 ws-you pic a(1).
       01 ws-score pic 9(18).
       
       procedure division.
           open input SYSIN
           perform until EOF
           read SYSIN        
               AT END SET EOF TO true
           end-read
           if not EOF
               unstring ln
               delimited by space
               into ws-opp
                    ws-you
               
               evaluate ws-you
                when "X"
                   compute ws-score = ws-score + 1
                   evaluate ws-opp
                    when "A"
                       compute ws-score = ws-score + 3
                    when "C"
                       compute ws-score = ws-score + 6
                   end-evaluate
               when "Y"
                   compute ws-score = ws-score + 2
                   evaluate ws-opp
                    when "A"
                       compute ws-score = ws-score + 6
                    when "B"
                       compute ws-score = ws-score + 3
                   end-evaluate
               when "Z"
                   compute ws-score = ws-score + 3
                   evaluate ws-opp
                    when "B"
                       compute ws-score = ws-score + 6
                    when "C"
                       compute ws-score = ws-score + 3
                   end-evaluate
           end-if
           end-perform.

           display ws-score.
    
       stop run.