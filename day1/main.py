def read_input() -> str:
    with open('input.txt') as file:
        return file.readlines()
    return ""


def part_2():
    result = 50
    amount = 0
    for line in read_input():
        line = line.strip()
        if not line or line == "":
            continue
        value = int(line[1:])
        if line[0] == "L":
            for _ in range(value):
                result -= 1
                if result == 0:
                    amount += 1
                if result < 0:
                    result += 100
        elif line[0] == "R":
            for _ in range(value):
                result += 1
                if result == 100:
                    amount += 1
                    result = 0
                if result > 100:
                    result -= 100
    print(amount)


def part_1():
    result = 50
    amount = 0
    for line in read_input():
        line = line.strip()
        if not line or line == "":
            continue
        value = int(line[1:])
        if line[0] == "L":
            result -= value
        elif line[0] == "R":
            result += value
        result += 100
        result %= 100
        if result == 0:
            amount += 1
    print(amount)


def main():
    import sys
    part = 2 if len(sys.argv) >= 2 and sys.argv[1] == "2" else 1
    if part == 1:
        part_1()
    elif part == 2:
        part_2()
    else:
        exit(1)


if __name__ == "__main__":
    main()
