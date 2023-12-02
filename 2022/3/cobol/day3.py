sum = 0

while True:
    try:
        line = input()
        for c in line[0:int(len(line) / 2)]:
            if c in line[int(len(line) / 2):]:
                priority = ord(c) - ord("a") + 1
                if priority <= 0:
                    priority = ord(c) - ord("A") + 27
                sum += priority
                break

    except EOFError:
        break

print("Sum:", sum)