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
  // console.log(coordinates);
  const lines = coordinates.flatMap((i, index) => coordinates.slice(index + 1).filter(j => j !== i).filter(j => j.x === i.x || j.y === i.y).map(j => ({ start: i, end: j })));
  // console.log(lines);
  const result = coordinates
    .flatMap((start, i) =>
      coordinates.slice(i + 1)
        .map(end => ({ area: (Math.abs(end.x - start.x) + 1) * (Math.abs(end.y - start.y) + 1), start, end })))
    .filter(rect => is_valid(rect, lines))
    .map(rect => rect.area)
    .sort((a, b) => b - a)[0];
  console.log(result);
}
type Coordinate = { x: number, y: number };
type Rect = { area: number, start: Coordinate, end: Coordinate };
type Line = { start: Coordinate, end: Coordinate };
function is_valid(rect: Rect, lines: Line[]): boolean {
  if (rect.start.x === rect.end.x || rect.start.y === rect.end.y) return true;
  const corner_1: Coordinate = { x: rect.end.x, y: rect.start.y };
  const corner_2: Coordinate = { x: rect.start.x, y: rect.end.y };
  const corner_check = check.bind(undefined, lines);
  return [corner_1, corner_2].every(corner_check);
}
function contains(line: Line, point: Coordinate) {
  return (line.start.x === line.end.x && line.start.x === point.x && ((line.start.y >= point.y && point.y >= line.end.y) || (line.start.y <= point.y && point.y <= line.end.y))) ||
    (line.start.y === line.end.y && line.start.y === point.y && ((line.start.x >= point.x && point.x >= line.end.x) || (line.start.x <= point.x && point.x <= line.end.x)))
}
function check(lines: Line[], point: Coordinate): boolean {
  if (lines.some(line => contains(line, point))) return true;
  return check_vertical_bounds(lines, point) && check_horizontal_bounds(lines, point);
}
function check_vertical_bounds(lines: Line[], point: Coordinate): boolean {
  const horizontal_lines = lines.filter(is_horizontal);
  const vertical_lines = lines.filter(is_vertical);
  const crosses_horizontal = (line: Line) => Math.min(line.start.y, line.end.y) <= point.y && point.y <= Math.max(line.start.y, line.end.y);
  const has_upper_bound = () => vertical_lines
    .filter(line => line.start.y === point.y)
    .some(line => line.start.x <= point.x || line.end.x <= point.x) ||
    horizontal_lines
      .filter(line => line.start.x <= point.x)
      .some(crosses_horizontal);
  const has_lower_bound = () => vertical_lines
    .filter(line => line.start.y === point.y)
    .some(line => line.start.x >= point.x || line.end.x >= point.x) ||
    horizontal_lines
      .filter(line => line.start.x >= point.x)
      .some(crosses_horizontal);
  return has_upper_bound() && has_lower_bound();
}
function check_horizontal_bounds(lines: Line[], point: Coordinate): boolean {
  const horizontal_lines = lines.filter(is_horizontal);
  const vertical_lines = lines.filter(is_vertical);
  const crosses_vertical = (line: Line) => Math.min(line.start.x, line.end.x) <= point.x && point.x <= Math.max(line.start.x, line.end.x);
  const has_upper_bound = () => horizontal_lines
    .filter(line => line.start.x === point.x)
    .some(line => line.start.y >= point.y || line.end.y >= point.y) ||
    vertical_lines
      .filter(line => line.start.y >= point.y)
      .some(crosses_vertical);
  const has_lower_bound = () => horizontal_lines
    .filter(line => line.start.x === point.x)
    .some(line => line.start.y <= point.y || line.end.y <= point.y) ||
    vertical_lines
      .filter(line => line.start.y <= point.y)
      .some(crosses_vertical);
  return has_upper_bound() && has_lower_bound();
}

function is_vertical(line: Line): boolean {
  return line.start.y === line.end.y;
}
function is_horizontal(line: Line): boolean {
  return line.start.x === line.end.x;
}
