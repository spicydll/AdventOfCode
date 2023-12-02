numsections = 0

while True:
    try:
        line = input()
        parts = line.split(",")
        elf1 = parts[0].split("-")
        elf2 = parts[1].split("-")

        if (int(elf1[0]) >= int(elf2[0]) and int(elf1[1]) <= int(elf2[1])) \
            or (int(elf2[0]) >= int(elf1[0]) and int(elf2[1]) <= int(elf1[1])):
            numsections += 1

    except EOFError:
        break

print("Sections:", numsections)