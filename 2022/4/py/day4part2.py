numsections = 0

while True:
    try:
        line = input()
        parts = line.split(",")
        elf1 = parts[0].split("-")
        elf2 = parts[1].split("-")

        for i in range(int(elf1[0]), int(elf1[1]) + 1):
            if i >= int(elf2[0]) and i <= int(elf2[1]):
                numsections += 1
                break

    except EOFError:
        break

print("Sections:", numsections)