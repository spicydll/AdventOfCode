stackagram = []
line = input()

while not line[1].isnumeric():
    stackagram.append(line)
    line = input()

stacks = [[]]
for i, c in enumerate(line):
    if c.isnumeric():
        stack = []
        for cargo in reversed(stackagram):
            if cargo[i].isalpha():
                stack.append(cargo[i])
        stacks.append(stack)

input()

while True:
    try:
        line = input()
        parts = line.split(" ")
        
        number = int(parts[1])
        fromstack = int(parts[3])
        tostack = int(parts[5])

        temp = []
        for i in range(number):
            temp.append(stacks[fromstack].pop())

        for i in range(number):
            stacks[tostack].append(temp.pop())

    except EOFError:
        break

print(stacks)

for stack in stacks:
    if len(stack) > 0:
            print(stack[-1], end="")
print()