head = (0, 0)
tail = (0, 0)
tposlist = [tail]

move = {
    "R": (1, 0),
    "L": (-1, 0),
    "U": (0, 1),
    "D": (0, -1)
}

while True:
    try:
        line = input()
        parts = line.split(" ")

        for i in range(int(parts[1])):
            # move head
            head = tuple(x + y for x, y in zip(head, move[parts[0]]))
            
            # check tail
            checkx = head[0] - tail[0]
            checky = head[1] - tail[1]
            if abs(checkx) > 1 or abs(checky) > 1:
                if checkx != 0 and checky != 0:
                    if checkx < 0 and checky < 0:
                        tail = (tail[0] - 1, tail[1] - 1)
                    elif checkx < 0:
                        tail = (tail[0] - 1, tail[1] + 1)
                    elif checky < 0:
                        tail = (tail[0] + 1, tail[1] - 1)
                    else:
                        tail = (tail[0] + 1, tail[1] + 1)
                else:
                    if checkx == 0:
                        if checky < 0:
                            tail = (tail[0], tail[1] - 1)
                        else:
                            tail = (tail[0], tail[1] + 1)
                    else:
                        if checkx < 0:
                            tail = (tail[0] - 1, tail[1])
                        else:
                            tail = (tail[0] + 1, tail[1])

            if tail not in tposlist:
                tposlist.append(tail)         

    except EOFError:
        break

print("Positions:", len(tposlist))