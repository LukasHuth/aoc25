//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
pub const part1 = @import("part1.zig").part1;
pub const part2 = @import("part2.zig").part2;

test {
    _ = @import("part1.zig");
    _ = @import("part2.zig");
    _ = @import("utils.zig");
}
