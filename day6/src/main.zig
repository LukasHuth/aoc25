const std = @import("std");
const day6 = @import("day6");

pub fn main() !void {
    var args = std.process.args();
    defer args.deinit();
    _ = args.skip();
    const day = args.next() orelse "";
    if(std.mem.eql(u8, day[0..], "2")) {
        day6.part2();
    } else {
        day6.part1();
    }
}
