cycle = 0
cyclesbeenmattered = [20, 60, 100, 140, 180, 220]
regx = 1
sumbeenmattered = 0

while True:
    try:
        line = input()
        parts = line.split(" ")

        if parts[0] == "noop":
            cycle += 1          
            if cycle in cyclesbeenmattered:
                sumbeenmattered += cycle * regx
                
        elif parts[0] == "addx":
            cycle += 1
            if cycle in cyclesbeenmattered:
                sumbeenmattered += cycle * regx
            cycle += 1
            if cycle in cyclesbeenmattered:
                sumbeenmattered += cycle * regx
            regx += int(parts[1])
            
    except EOFError:
        break

print("Sum:", sumbeenmattered)