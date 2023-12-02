       identification division.
       program-id. "day2pt2".
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
               
               if ws-opp = 'A'
      *            Rock vs Scissors
                   if ws-you = 'X'
                       compute ws-score = ws-score + 3
                   end-if
      *            Rock vs Rock
                   if ws-you = 'Y'
                       compute ws-score = ws-score + 3 + 1              
                   end-if
      *            Rock vs Paper
                   if ws-you = 'Z'
                       compute ws-score = ws-score + 6 + 2              
                   end-if
               end-if
               if ws-opp = 'B'
      *            Paper vs Rock
                   if ws-you = 'X'
                       compute ws-score = ws-score + 1
                   end-if
      *            Paper vs Paper
                   if ws-you = 'Y'
                       compute ws-score = ws-score + 3 + 2
                   end-if
      *            Paper vs Scissors
                   if ws-you = 'Z'
                       compute ws-score = ws-score + 6 + 3
                   end-if
               end-if
               if ws-opp = 'C'
      *            Scissors vs Paper
                   if ws-you = 'X'
                       compute ws-score = ws-score + 2
                   end-if
      *            Scissors vs Scissors
                   if ws-you = 'Y'
                       compute ws-score = ws-score + 3 + 3
                   end-if
      *            Scissors vs Rock
                   if ws-you = 'Z'
                       compute ws-score = ws-score + 6 + 1
                   end-if
               end-if               
           end-if
           end-perform.

           display ws-score.
    
       stop run.