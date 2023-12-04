const std = @import("std");

fn parseMatrix(reader: anytype, allocator: std.mem.Allocator) ![][]const u8 {
    var matrix = std.ArrayList([]const u8).init(allocator);
    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line_list = std.ArrayList(u8).init(allocator);
        try line_list.appendSlice(line);
        try matrix.append(try line_list.toOwnedSlice());
    }

    return matrix.toOwnedSlice();
}

const NumLoc = struct {
    num: u32,
    end: usize,
};

fn partOfNum(slice: []const u8, index: usize) ?NumLoc {
    var num: u32 = undefined;
    var true_end: usize = undefined;

    if (slice[index] < '0' or slice[index] > '9') {
        return null;
    }

    var begin: usize = index;
    var end: usize = index + 1;
    if (end > slice.len) {
        end = slice.len;
    }

    var true_begin = begin;
    while (begin >= 0) : (begin -= 1) {
        //std.debug.print("begin: {d}\n", .{begin});
        num = (std.fmt.parseUnsigned(u32, slice[begin..end], 10)) catch break;
        true_begin = begin;
        if (begin == 0) {
            break;
        }
    }

    begin = true_begin;
    true_end = index;
    while (end <= slice.len) : (end += 1) {
        num = (std.fmt.parseUnsigned(u32, slice[begin..end], 10)) catch break;
        true_end = end - 1;
    }

    return NumLoc{ .num = num, .end = true_end };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const matrix = try parseMatrix(std.io.getStdIn().reader(), allocator);
    var sum: u32 = 0;

    for (matrix, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c == '*') {
                var nums: [2]?u32 = .{ null, null };

                var start_row = i;
                var start_col = j;

                if (start_row > 0) {
                    start_row -= 1;
                }

                if (start_col > 0) {
                    start_col -= 1;
                }

                var too_many = false;
                var row: usize = start_row;
                while (row <= i + 1 and row < matrix.len) : (row += 1) {
                    var col: usize = start_col;
                    while (col <= j + 1 and col < line.len) : (col += 1) {
                        if (row == i and col == j) {
                            continue;
                        }
                        if (partOfNum(matrix[row], col)) |number| {
                            if (nums[0] == null) {
                                nums[0] = number.num;
                                col = number.end;
                            } else if (nums[1] == null) {
                                nums[1] = number.num;
                                col = number.end;
                            } else {
                                too_many = true;
                                break;
                            }
                        } else {
                            //std.debug.print("not a number\n", .{});
                        }
                    }

                    if (too_many) {
                        break;
                    }
                }

                if (!too_many and nums[0] != null and nums[1] != null) {
                    sum += nums[0].? * nums[1].?;
                }
            }
        }
    }

    try std.io.getStdOut().writer().print("Sum: {}\n", .{sum});
}
