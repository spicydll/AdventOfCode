knotlist = []
for i in range(10):
    knotlist.append((0, 0))
tposlist = [knotlist[9]]

move = {
    "R": (1, 0),
    "L": (-1, 0),
    "U": (0, 1),
    "D": (0, -1)
}

def domove(movechar, knot):
    return tuple(x + y for x, y in zip(knot, move[movechar]))

def dosim(headknot, tailknot):
    checkx = headknot[0] - tailknot[0]
    checky = headknot[1] - tailknot[1]
    if abs(checkx) > 1 or abs(checky) > 1:
        if checkx != 0 and checky != 0:
            if checkx < 0 and checky < 0:
                tailknot = domove("L", tailknot)
                tailknot = domove("D", tailknot)
            elif checkx < 0:
                tailknot = domove("L", tailknot)
                tailknot = domove("U", tailknot)
            elif checky < 0:
                tailknot = domove("R", tailknot)
                tailknot = domove("D", tailknot)
            else:
                tailknot = domove("R", tailknot)
                tailknot = domove("U", tailknot)
        else:
            if checkx == 0:
                if checky < 0:
                    tailknot = domove("D", tailknot)
                else:
                    tailknot = domove("U", tailknot)
            else:
                if checkx < 0:
                    tailknot = domove("L", tailknot)
                else:
                    tailknot = domove("R", tailknot)
    return tailknot

while True:
    try:
        line = input()
        parts = line.split(" ")

        for i in range(int(parts[1])):
            # move head
            knotlist[0] = domove(parts[0], knotlist[0])
            
            for j, knot in enumerate(knotlist[1:]):
                knotlist[j + 1] = dosim(knotlist[j], knot)
            
            if knotlist[9] not in tposlist:
                tposlist.append(knotlist[9])         

    except EOFError:
        break

print("Positions:", len(tposlist))