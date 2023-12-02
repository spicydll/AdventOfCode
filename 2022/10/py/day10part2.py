cycle = 0
regx = 1
crt = ""

def docrt(c, x, s):
    if abs((c - 1) - x) <= 1:
        s += "#"
    else:
        s += "."
    if len(s) == 40:
        print(s)
        s = ""
        c = 0
    return s, c

while True:
    try:
        line = input()
        parts = line.split(" ")

        if parts[0] == "noop":
            cycle += 1
            crt, cycle = docrt(cycle, regx, crt)

        elif parts[0] == "addx":
            cycle += 1
            crt, cycle = docrt(cycle, regx, crt)
            cycle += 1
            crt, cycle = docrt(cycle, regx, crt)
            regx += int(parts[1])
    except EOFError:
        break