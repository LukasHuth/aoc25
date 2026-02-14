const std = @import("std");
pub fn part2(alloc: std.mem.Allocator) !void {
    _ = alloc;
    std.fs.File.stdout().writeAll("Hello, World!") catch return;
}
