normal = []
rotated = []

first = True
while True:
    try:
        line = input()
        normalline = []
        
        for i, numchar in enumerate(line):
            num = int(numchar)
            normalline.append(num)

            if first:
                rotated.append([num])
            else:
                rotated[i].append(num)
        
        normal.append(normalline)
        first = False

    except EOFError:
        break

maxscore = 0
for rowi, row in enumerate(normal):
    for coli, num in enumerate(row):
        # Forward
        if coli + 1 >= len(row):
            continue
        else:
            dist = 0
            for compnum in row[coli + 1:len(row)]:
                dist += 1
                if compnum >= num:
                    break
           
            score = dist

        # Backward
        if coli == 0:
            continue
        else:
            dist = 0
            for compnum in reversed(row[0:coli]):
                dist += 1
                if compnum >= num:
                    break
            
            score *= dist

        # Down
        if rowi + 1 >= len(rotated[coli]):
            continue
        else:
            dist = 0
            for compnum in rotated[coli][rowi + 1:len(rotated[coli])]:
                dist += 1
                if compnum >= num:
                    break

            score *= dist
        
        # Up
        if rowi == 0:
            continue
        else:
            dist = 0
            for compnum in reversed(rotated[coli][0:rowi]):
                dist += 1
                if compnum >= num:
                    break

            score *= dist
        
        if score > maxscore:
            maxscore = score

print("Highest scenic score possible:", maxscore)