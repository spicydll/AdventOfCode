sum = 0

while True:
    try:
        lines = []
        lines.append(input())
        lines.append(input())
        lines.append(input())

        for c in lines[0]:
            if c in lines[1] and c in lines[2]:
                priority = ord(c) - ord("a") + 1
                if priority <= 0:
                    priority = ord(c) - ord("A") + 27
                sum += priority
                break

    except EOFError:
        break

print("Sum:", sum)