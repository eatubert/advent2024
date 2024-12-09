import sys

if len(sys.argv) < 2:
    file = sys.stdin
else:
    file = open(sys.argv[1], 'rt')

rules = set()
for line in file:
    line = line.rstrip()
    if not line:
        break
    rules.add(line)

updates = list()
for line in file:
    updates.append(line.rstrip())

total = 0
for update in updates:
    pages = update.split(',')
    ok = True
    for i in range(0, len(pages) - 1):
        for j in range(i + 1, len(pages)):
            rule = '|'.join([pages[i], pages[j]])
            ok = rule in rules
            if not ok:
                break
        if not ok:
            break

    if ok:
        total += int(pages[((len(pages) + 1) // 2)-1])

print(total)
