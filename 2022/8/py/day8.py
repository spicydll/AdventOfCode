fromup = []
fromdown = []
vis = []

linenum = 0
while True:
    try:
        line = input()
        horizontal = []
        
        for i, numchar in enumerate(line):
            isvis = False
            num = int(numchar)
            horizontal.append(num)

            # up to down
            if linenum == 0:
                fromdown.append([num])
                isvis = True
                fromup.append(num)
            elif num > fromup[i]:
                fromup[i] = num
                isvis = True

            if linenum != 0:
                fromdown[i].append(num)

            # left to right
            if i == 0 or num > large:
                isvis = True
                large = num

            if isvis:
                vis.append((linenum, i))

        # right to left
        for i, num in enumerate(reversed(horizontal)):
            ind = len(horizontal) - i - 1

            if i == 0 or num > large:
                large = num
                coord = (linenum, ind)
                if coord not in vis:
                    vis.append(coord)
        linenum += 1     
    except EOFError:
        break

# bottom up
for i, col in enumerate(fromdown):
    for j, num in enumerate(reversed(col)):
        ind = len(col) - j - 1

        if j == 0 or num > large:
            large = num
            coord = (ind, i)
            if coord not in vis:
                vis.append(coord)

print("Visible Trees:", len(vis))