const std = @import("std");
pub fn splitIntoLines(str: []u8, alloc: std.mem.Allocator) !std.ArrayList([]const u8) {
    var array = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var it = std.mem.splitScalar(u8, str, '\n');
    while(it.next()) |next| {
        const value = std.mem.trim(u8, next, " \t\n\r");
        if(value.len == 0) continue;
        try array.append(alloc, value);
    }
    return array;
}
test "test line splitting" {
    const alloc = std.testing.allocator;
    const expected = [_][]const u8 { "a", "b" };
    const inputstring = try std.fmt.allocPrint(alloc, "a\n \n b", .{});
    defer alloc.free(inputstring);
    var actual = try splitIntoLines(inputstring, alloc);
    defer actual.deinit(alloc);
    try std.testing.expectEqual(expected.len, actual.items.len);
    for (0..2) |i| {
        try std.testing.expectEqualSlices(u8, expected[i], actual.items[i]);
    }
}

pub fn splitLine(str: []u8, alloc: std.mem.Allocator) !std.ArrayList([]const u8) {
    var array = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var it = std.mem.splitScalar(u8, str, ' ');
    while(it.next()) |next| {
        const value = std.mem.trim(u8, next, " \t\n\r");
        if(value.len == 0) continue;
        try array.append(alloc, value);
    }
    return array;
}
test "test line splitting 2" {
    const alloc = std.testing.allocator;
    const expected = [_][]const u8 { "a", "b" };
    const inputstring = try std.fmt.allocPrint(alloc, "   a    b     ", .{});
    defer alloc.free(inputstring);
    var actual = try splitLine(inputstring, alloc);
    defer actual.deinit(alloc);
    try std.testing.expectEqual(expected.len, actual.items.len);
    for (0..2) |i| {
        try std.testing.expectEqualSlices(u8, expected[i], actual.items[i]);
    }
}

pub fn convertStringsToNumbers(strs: [][]u8, alloc: std.mem.Allocator) !std.ArrayList(u32) {
    var out = try std.ArrayList(u32).initCapacity(alloc, strs.len);
    for (strs) |str| {
        try out.append(alloc, try std.fmt.parseInt(u32, str, 10));
    }
    return out;
}
test "strings to numbers" {
    const alloc = std.testing.allocator;
    const expected = [_]u32 { 123, 69 };
    var input = try std.ArrayList([]u8).initCapacity(alloc, 2);
    defer input.deinit(alloc);
    const input0 = try std.fmt.allocPrint(alloc, "123", .{});
    defer alloc.free(input0);
    const input1 = try std.fmt.allocPrint(alloc, "69", .{});
    defer alloc.free(input1);
    try input.append(alloc, input0);
    try input.append(alloc, input1);
    var actual = try convertStringsToNumbers(input.items, alloc);
    defer actual.deinit(alloc);
    try std.testing.expectEqualSlices(u32, expected[0..], actual.items);
}

pub fn readFile(alloc: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    return file.readToEndAlloc(alloc, 1_000_000);
}
test "test file reading" {
    const expected = @embedFile("test.txt");
    const actual = try readFile(std.testing.allocator);
    defer std.testing.allocator.free(actual);
    try std.testing.expectEqualSlices(u8, expected, actual);
}

