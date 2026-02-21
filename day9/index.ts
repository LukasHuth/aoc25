import * as fs from 'node:fs';
import * as process from "node:process";


if (process.argv.length > 2 && process.argv[2] === '2') {
  part2();
} else {
  part1();
}

function read_file(): string {
  return fs.readFileSync("input.txt", 'utf-8');
}
function part1(): void {
  findBiggestSquare();
}
function findBiggestSquare(): void {
  const input: string = read_file();
  const coordinates: { x: number, y: number }[] = input.trim()
    .split('\n')
    .map(s => s.trim())
    .filter(s => !!s)
    .map(line => line.split(','))
    .map(([x, y]) => ({ x: Number(x), y: Number(y) }));
  const result = coordinates
    .flatMap((start, i) =>
      coordinates.slice(i + 1)
        .map(end => ({ area: (Math.abs(end.x - start.x) + 1) * (Math.abs(end.y - start.y) + 1), start, end })))
    .sort((a, b) => b.area - a.area)[0].area;
  console.log(result);
}
function part2() {
  console.log();
}