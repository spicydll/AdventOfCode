       identification division.
       program-id. "day8".
       author. u/madogson.
       
       environment division.

       data division.
       
       working-storage section.
       01 ws-array-data.
           05 dim-row occurs 0 to 9 times depending on ws-num-row.
               10 dim-col occurs 0 to 9 times depending on ws-num-col.
                   15 digit pic 9.
       
       01 ws-num-row pic 9(9).
       01 ws-num-col pic 9(9).
       01 ws-line pic 9(1024).
       01 ws-i pic 9(18)

       
       procedure division.
           accept ws-line.
           move function length(ws-line) to ws-num-col.
           move num
           perform until EOF
               accept ws-line
               perform varying ws-i from 1 by 1
                   until ws-i > ws-num-row
           
    
       stop run.
