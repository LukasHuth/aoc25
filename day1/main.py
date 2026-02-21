def read_input() -> str:
    with open('input.txt') as file:
        return file.readlines()
    return ""

def main():
    result = 0
    amount = 0
    for line in read_input():
        direction = -1 if line[0] == "L" else 1
        value = int(line[1:-1])
        result += direction * value
        result += 100
        result %= 100
        if result == 0:
            amount += 1
        # print(f"{line[:-1]} {result} {amount}")
    print(amount)

if __name__ == "__main__":
    main()
