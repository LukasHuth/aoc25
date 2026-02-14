const std = @import("std");
const utils = @import("utils.zig");
pub fn part1(alloc: std.mem.Allocator, comptime debug: bool) !void {
    const file = try utils.readFile(alloc);
    defer alloc.free(file);
    const lines = try utils.splitIntoLines(file, alloc);
    defer alloc.free(lines);
    var number_data: [][][]const u8 = try alloc.alloc([][]const u8, lines.len);
    // var number_data = try std.ArrayList(std.ArrayList([]const u8)).initCapacity(alloc, lines.len - 1);
    defer cleanup_number_data(number_data, alloc);
    for (lines, 0..) |line, i| {
        const line_data = try utils.splitLine(line, alloc);
        number_data[i] = line_data;
    }
    const operations = number_data[number_data.len - 1];
    const numbers = try alloc.alloc([]u64, number_data.len - 1);
    defer cleanup_numbers(u64, numbers, alloc);
    for (number_data[0..number_data.len-1], 0..) |data, i| {
        numbers[i] = try utils.convertStringsToNumbers(data, alloc, u64);
    }
    var results = try alloc.alloc(u64, operations.len);
    defer alloc.free(results);
    for (operations, 0..) |operation, i| {
        switch (operation[0]) {
            '+' => {
                results[i] = 0;
                for (numbers) |numbers_data| {
                    results[i] += numbers_data[i];
                }
            },
            '*' => {
                results[i] = 1;
                for (numbers) |numbers_data| {
                    results[i] *= numbers_data[i];
                }
            },
            else => std.debug.panic("This should not be reachable", .{}),
        }
    }
    if(!debug) {
        var sum: u64 = 0;
        for (results) |number| {
            sum += number;
        }
        const msg = try std.fmt.allocPrint(alloc, "{}\n", .{ sum });
        defer alloc.free(msg);
        std.fs.File.stdout().writeAll(msg) catch return;
    }
}
fn cleanup_numbers(comptime t: type, numbers: [][]t, alloc: std.mem.Allocator) void {
    for (numbers) |data| {
        alloc.free(data);
    }
    alloc.free(numbers);
}
fn cleanup_number_data(number_data: [][][]const u8, alloc: std.mem.Allocator) void {
    for (number_data) |data| {
        alloc.free(data);
    }
    alloc.free(number_data);
}
test "test allocation" {
    try part1(std.testing.allocator, true);
}
