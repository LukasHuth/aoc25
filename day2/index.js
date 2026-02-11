import fs from 'node:fs';
function read_file() {
  return fs.readFileSync("input.txt", 'utf-8');
}
function part1() {
  validate(isInvalid);
}
function validate(validator) {
  const file = read_file();
  const ranges = file.split(",")
    .map(s => s.trim()).map(range => range.split("-").map(s => s.trim()).map(Number))
    .map(([start, end]) => makeRangeIterator(start, end));
  let result = 0;
  for(const range of ranges) {
    for(const i of range) {
      if(validator(i)) continue;
      result += i;
    }
  }
  console.log(result);
}
function isInvalid(number) {
  number = number.toString();
  if(number.length % 2 == 1 ) return true;
  const middle = number.length / 2;
  const start = number.slice(0, middle);
  const end = number.slice(middle);
  return start !== end;
}
function* makeRangeIterator(start = 0, end = Infinity, step = 1) {
  for (let i = start; i <= end; i += step) {
    yield i;
  }
}
function part2() {
  const validator = n => !/^(.+)\1+$/.test(n.toString());
  validate(validator);
}
import * as process from "node:process";
if(process.argv.length > 2 && process.argv[2] === '2') {
  part2();
} else {
  part1();
}
