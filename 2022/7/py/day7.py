def sizeDir(dir):
    if len(dir["dirs"]) == 0:
        return dir["filesizes"]
    else:
        dirsize = dir["filesizes"]
        for curdir in dir["dirs"]:
            dirsize += sizeDir(curdir)

        return dirsize

def statDirs(dir):
    sizecount = sizeDir(dir)
    if sizecount > 100000:
        sizecount = 0

    if len(dir["dirs"]) != 0:
        for curdir in dir["dirs"]:
            sizecount += statDirs(curdir)

    return sizecount
        
tree = {
    "parent": None,
    "filesizes": 0,
    "dirs": []
}
dir = tree

while True:
    try:
        line = input()

        if line.startswith("$ cd"):
            if line == "$ cd ..":
                dir = dir["parent"]
            elif line == "$ cd /":
                dir = tree
            else:
                for curdir in dir["dirs"]:
                    if curdir["name"] == line[5:]:
                        dir = curdir
                        break
        elif line.startswith("$ ls"):
            pass
        else:
            parts = line.split(" ")
            if parts[0] == "dir":
                exists = False
                for curdir in dir["dirs"]:
                    if curdir["name"] == parts[1]:
                        exists = True
                        break
                if not exists:
                    newdir = {
                        "name": parts[1],
                        "parent": dir,
                        "filesizes": 0,
                        "dirs": []
                    }
                    dir["dirs"].append(newdir)
            else:
                dir["filesizes"] += int(parts[0])

    except EOFError:
        break

print("Size of dirs:", statDirs(tree))