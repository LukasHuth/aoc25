const std = @import("std");
const day6 = @import("day6");

pub fn main() !void {
    var args = std.process.args();
    defer args.deinit();
    _ = args.skip();
    const day = args.next() orelse "";
    if(std.mem.eql(u8, day[0..], "2")) {
        try day6.part2(std.heap.page_allocator);
    } else {
        try day6.part1(std.heap.page_allocator, false);
    }
}
