const std = @import("std");
pub fn part2() void {
    std.fs.File.stdout().writeAll("Hello, World!") catch return;
}
