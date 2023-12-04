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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const matrix = try parseMatrix(std.io.getStdIn().reader(), allocator);
    var sum: u32 = 0;

    for (matrix, 0..) |line, i| {
        // std.debug.print("DEBUG: {s} {d}\n", .{ line, i });
        var j: usize = 0;
        while (j < line.len) : (j += 1) {
            var cur_num: ?u32 = null;
            var end: usize = j;
            var num_end: usize = undefined;

            while (end < line.len) : (end += 1) {
                //std.debug.print("Debug: {s}\n", .{line[j..end]});
                const parse_num: u32 = std.fmt.parseUnsigned(u32, line[j .. end + 1], 10) catch break;
                cur_num = parse_num;
                num_end = end;
            }

            if (cur_num) |number| {
                defer j = num_end;
                //std.debug.print("number: {}\n", .{number});
                var start_row: usize = i;
                var start_col: usize = j;
                var symbol_found = false;

                if (start_row > 0) {
                    start_row -= 1;
                }
                if (start_col > 0) {
                    start_col -= 1;
                }

                for (start_row..(i + 2)) |row| {
                    if (row >= matrix.len) {
                        break;
                    }

                    for (start_col..(num_end + 2)) |col| {
                        if (col >= matrix[i].len) {
                            break;
                        }

                        //std.debug.print("Cur Symbol: {c}\n", .{matrix[row][col]});
                        symbol_found = switch (matrix[row][col]) {
                            '0'...'9' => false,
                            '.' => false,
                            else => true,
                        };

                        if (symbol_found) {
                            //std.debug.print("Symbol: {c}\n", .{matrix[row][col]});
                            //std.debug.print("Num: {}\n", .{number});

                            sum += number;
                            break;
                        }
                    }

                    if (symbol_found) {
                        break;
                    }
                }
            }
        }
    }

    try std.io.getStdOut().writer().print("Sum: {}\n", .{sum});
}
