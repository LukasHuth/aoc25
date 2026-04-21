import * as fs from 'node:fs';
import * as process from "node:process";
if (process.argv.length > 2 && process.argv[2] === '2') {
    part2();
}
else {
    part1();
}
function read_file() {
    return fs.readFileSync("input.txt", 'utf-8');
}
function part1() {
    findBiggestSquare();
}
function findBiggestSquare() {
    const input = read_file();
    const coordinates = input.trim()
        .split('\n')
        .map(s => s.trim())
        .filter(s => !!s)
        .map(line => line.split(','))
        .map(([x, y]) => ({ x: Number(x), y: Number(y) }));
    const result = coordinates
        .flatMap((start, i) => coordinates.slice(i + 1)
        .map(end => ({ area: (Math.abs(end.x - start.x) + 1) * (Math.abs(end.y - start.y) + 1), start, end })))
        .sort((a, b) => b.area - a.area)[0].area;
    console.log(result);
}
function part2() {
    const input = read_file();
    const coordinates = input.trim()
        .split('\n')
        .map(s => s.trim())
        .filter(s => !!s)
        .map(line => line.split(','))
        .map(([x, y]) => ({ x: Number(x), y: Number(y) }));
    const result = coordinates
        .flatMap((start, i) => coordinates.slice(i + 1)
        .map(end => ({ area: (Math.abs(end.x - start.x) + 1) * (Math.abs(end.y - start.y) + 1), start, end })))
        .filter(rect => rect.start.x !== rect.end.x && rect.start.y !== rect.end.y)
        .filter(rect => is_valid(rect, coordinates))
        .map(rect => rect.area)
        .sort((a, b) => b - a)[0] ?? 0;
    console.log(result);
}
function is_on_segment(a, b, p) {
    if (a.x === b.x && p.x === a.x) {
        return Math.min(a.y, b.y) <= p.y && p.y <= Math.max(a.y, b.y);
    }
    if (a.y === b.y && p.y === a.y) {
        return Math.min(a.x, b.x) <= p.x && p.x <= Math.max(a.x, b.x);
    }
    return false;
}
function is_inside_polygon(vertices, point) {
    for (let i = 0; i < vertices.length; i++) {
        if (is_on_segment(vertices[i], vertices[(i + 1) % vertices.length], point))
            return true;
    }
    let crossings = 0;
    for (let i = 0; i < vertices.length; i++) {
        const a = vertices[i];
        const b = vertices[(i + 1) % vertices.length];
        if (a.x === b.x) {
            const y1 = Math.min(a.y, b.y);
            const y2 = Math.max(a.y, b.y);
            if (a.x > point.x && y1 <= point.y && point.y < y2)
                crossings++;
        }
    }
    return crossings % 2 === 1;
}
function is_valid(rect, vertices) {
    const corner_1 = { x: rect.start.x, y: rect.end.y };
    const corner_2 = { x: rect.end.x, y: rect.start.y };
    return is_inside_polygon(vertices, corner_1) && is_inside_polygon(vertices, corner_2);
}
