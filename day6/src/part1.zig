const std = @import("std");
pub fn part1() void {
    std.fs.File.stdout().writeAll("Hello, World!") catch return;
}
