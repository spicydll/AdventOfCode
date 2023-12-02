data = input()
result = None
curcount = 0
for i, c in enumerate(data):
    repeat = False
    part = data[i:i+14]
    
    for c2 in part:
        if part.count(c2) > 1:
            repeat = True
            break

    if not repeat:
        print("message at:", i+14)
        break
    