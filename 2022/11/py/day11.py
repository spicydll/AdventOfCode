# define a list to store the monkeys
monkeys = []

# parse the input
while True:
    try:
        # read in the name, items, operation, test, and destinations
        input()
        items = list(map(int, input().split(':')[1].split(",")))
        op_string = input().strip().split(": ")[1]
        op_parts = op_string.split(" ")
        op_type = op_parts[3]
        op_value = op_parts[4]
        test_string = input().strip().split(": ")[1]
        test_parts = test_string.split(" ")
        test_value = int(test_parts[2])

        # create the operation and test lambda functions
        if op_type == "+":
            if op_value == "old":
                operation = lambda x: x + x
            else:
                operation = lambda x: x + int(op_value)
        elif op_type == "*":
            if op_value == "old":
                operation = lambda x: x * x
            else:
                operation = lambda x: x * int(op_value)

        truedest = int(input().split(" ")[-1])
        falsedest = int(input().split(" ")[-1])

        test = lambda x: [truedest, x] if x % test_value == 0 else [falsedest, x]

        # create the dictionary for the monkey
        monkey = {
            "items": items,
            "operation": operation,
            "test": test,
            "destination": [],
            "count": 0
        }

        # add the monkey to the list
        monkeys.append(monkey)
        input()
    except EOFError:
        break

# simulate the process for 20 rounds
for _ in range(20):
    # apply the operation to each item for each monkey
    for monkey in monkeys:
        monkey["count"] += len(monkey["items"])
        monkey["items"] = [monkey["operation"](x) for x in monkey["items"]]
        monkey["items"] = [x / 3 for x in monkey["items"]]
        monkey["destination"] = [monkey["test"](x) for x in monkey["items"]]
        monkey["items"] = []
        for dest in monkey["destination"]:
            monkeys[dest[0]]["items"].append(dest[1])
        monkey["destination"] = []        

# sort the monkeys by the number of items they tested
monkeys.sort(key=lambda x: x["count"], reverse=True)

# print out the top two monkeys and the number of items they tested
#print(f"{monkeys[0]['name']} tested {monkeys[0]['count']} items.")
#print(f"{monkeys[1]['name']} tested {monkeys[1]['count']} items.")

print(monkeys[0]['count'] * monkeys[1]['count'])