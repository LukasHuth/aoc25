"use strict";
var __values = (this && this.__values) || function(o) {
    var s = typeof Symbol === "function" && Symbol.iterator, m = s && o[s], i = 0;
    if (m) return m.call(o);
    if (o && typeof o.length === "number") return {
        next: function () {
            if (o && i >= o.length) o = void 0;
            return { value: o && o[i++], done: !o };
        }
    };
    throw new TypeError(s ? "Object is not iterable." : "Symbol.iterator is not defined.");
};
var __read = (this && this.__read) || function (o, n) {
    var m = typeof Symbol === "function" && o[Symbol.iterator];
    if (!m) return o;
    var i = m.call(o), r, ar = [], e;
    try {
        while ((n === void 0 || n-- > 0) && !(r = i.next()).done) ar.push(r.value);
    }
    catch (error) { e = { error: error }; }
    finally {
        try {
            if (r && !r.done && (m = i["return"])) m.call(i);
        }
        finally { if (e) throw e.error; }
    }
    return ar;
};
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
Object.defineProperty(exports, "__esModule", { value: true });
var node_console_1 = require("node:console");
var fs = require("node:fs");
var process = require("node:process");
;
var Polygon = /** @class */ (function () {
    function Polygon(coordinates) {
        var e_1, _a;
        this.tiles = new Set();
        this.edges = new Set();
        var lastCoord = coordinates[coordinates.length - 1];
        try {
            for (var coordinates_1 = __values(coordinates), coordinates_1_1 = coordinates_1.next(); !coordinates_1_1.done; coordinates_1_1 = coordinates_1.next()) {
                var coord = coordinates_1_1.value;
                if (coord.x == lastCoord.x) {
                    // horizontal
                    var start = Math.min(coord.y, lastCoord.y);
                    var end = Math.max(coord.y, lastCoord.y);
                    for (var y = start; y <= end; y++) {
                        this.edges.add({ x: coord.x, y: y });
                    }
                }
                else {
                    // vertical
                    var start = Math.min(coord.x, lastCoord.x);
                    var end = Math.max(coord.x, lastCoord.x);
                    for (var x = start; x <= end; x++) {
                        this.edges.add({ x: x, y: coord.y });
                    }
                }
                lastCoord = coord;
            }
        }
        catch (e_1_1) { e_1 = { error: e_1_1 }; }
        finally {
            try {
                if (coordinates_1_1 && !coordinates_1_1.done && (_a = coordinates_1.return)) _a.call(coordinates_1);
            }
            finally { if (e_1) throw e_1.error; }
        }
    }
    Polygon.prototype.isPointInside = function (point) {
        return __spreadArray([], __read(this.edges), false).filter(function (_a) {
            var x = _a.x, y = _a.y;
            return y === point.y && x >= point.x;
        }).length % 2 === 1;
    };
    return Polygon;
}());
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
    var input = read_file();
    var coordinates = input.trim()
        .split('\n')
        .map(function (s) { return s.trim(); })
        .filter(function (s) { return !!s; })
        .map(function (line) { return line.split(','); })
        .map(function (_a) {
        var _b = __read(_a, 2), x = _b[0], y = _b[1];
        return ({ x: Number(x), y: Number(y) });
    });
    var result = coordinates
        .flatMap(function (start, i) {
        return coordinates.slice(i + 1)
            .map(function (end) { return ({ area: (Math.abs(end.x - start.x) + 1) * (Math.abs(end.y - start.y) + 1), start: start, end: end }); });
    })
        .sort(function (a, b) { return b.area - a.area; })[0].area;
    console.log(result);
}
function part2() {
    var e_2, _a, e_3, _b;
    var input = read_file();
    var coordinates = input.trim()
        .split('\n')
        .map(function (s) { return s.trim(); })
        .filter(function (s) { return !!s; })
        .map(function (line) { return line.split(','); })
        .map(function (_a) {
        var _b = __read(_a, 2), x = _b[0], y = _b[1];
        return ({ x: Number(x), y: Number(y) });
    });
    var poly = new Polygon(coordinates);
    try {
        for (var coordinates_2 = __values(coordinates), coordinates_2_1 = coordinates_2.next(); !coordinates_2_1.done; coordinates_2_1 = coordinates_2.next()) {
            var coord = coordinates_2_1.value;
            (0, node_console_1.assert)(poly.isPointInside(coord), "{ x: ".concat(coord.x, ", y: ").concat(coord.y, " }"));
        }
    }
    catch (e_2_1) { e_2 = { error: e_2_1 }; }
    finally {
        try {
            if (coordinates_2_1 && !coordinates_2_1.done && (_a = coordinates_2.return)) _a.call(coordinates_2);
        }
        finally { if (e_2) throw e_2.error; }
    }
    var min_x = Infinity;
    var min_y = Infinity;
    var max_x = -Infinity;
    var max_y = -Infinity;
    try {
        for (var coordinates_3 = __values(coordinates), coordinates_3_1 = coordinates_3.next(); !coordinates_3_1.done; coordinates_3_1 = coordinates_3.next()) {
            var coord = coordinates_3_1.value;
            if (coord.x < min_x)
                min_x = coord.x;
            if (coord.y < min_y)
                min_y = coord.y;
            if (coord.x > max_x)
                max_x = coord.x;
            if (coord.y > max_y)
                max_y = coord.y;
        }
    }
    catch (e_3_1) { e_3 = { error: e_3_1 }; }
    finally {
        try {
            if (coordinates_3_1 && !coordinates_3_1.done && (_b = coordinates_3.return)) _b.call(coordinates_3);
        }
        finally { if (e_3) throw e_3.error; }
    }
    console.log(min_x, min_y, max_x, max_y);
    var rects = coordinates
        .flatMap(function (start, i) {
        return coordinates.slice(i + 1)
            .map(function (end) { return ({ start: start, end: end }); });
    });
    console.log();
}
