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
  const input: string = read_file();
  const coordinates: { x: number, y: number }[] = input.trim()
    .split('\n')
    .map(s => s.trim())
    .filter(s => !!s)
    .map(line => line.split(','))
    .map(([x, y]) => ({ x: Number(x), y: Number(y) }));
  const tiles = new Set<string>();
  coordinates.forEach((start, index) => {
    const end = coordinates[(index + 1) % coordinates.length];
    if (start.x === end.x) {
      const [minY, maxY] = [Math.min(start.y, end.y), Math.max(start.y, end.y)];
      for (let y = minY; y <= maxY; y++) {
        tiles.add(coord_key({ x: start.x, y }));
      }
      return;
    }
    const [minX, maxX] = [Math.min(start.x, end.x), Math.max(start.x, end.x)];
    for (let x = minX; x <= maxX; x++) {
      tiles.add(coord_key({ x, y: start.y }));
    }
  });
  const result = coordinates
    .flatMap((start, i) =>
      coordinates.slice(i + 1)
        .map(end => ({ area: (Math.abs(end.x - start.x) + 1) * (Math.abs(end.y - start.y) + 1), start, end })))
    .filter(rect => rect.start.x !== rect.end.x && rect.start.y !== rect.end.y)
    .filter(rect => is_valid(rect, tiles))
    .map(rect => rect.area)
    .sort((a, b) => b - a)[0] ?? 0;
  console.log(result);
}
type Coordinate = { x: number, y: number };
type Rect = { area: number, start: Coordinate, end: Coordinate };
function coord_key(coord: Coordinate): string {
  return `${coord.x},${coord.y}`;
}
function is_valid(rect: Rect, tiles: Set<string>): boolean {
  const corner1 = { x: rect.start.x, y: rect.end.y };
  const corner2 = { x: rect.end.x, y: rect.start.y };
  return tiles.has(coord_key(corner1)) && tiles.has(coord_key(corner2));
}
