const std = @import("std");

const Sequence = struct {
    nums: []const i64,

    pub fn parseSequences(reader: anytype, allocator: std.mem.Allocator) ![]const Sequence {
        var seqs_list = std.ArrayList(Sequence).init(allocator);
        defer seqs_list.deinit();

        var line_list = std.ArrayList(u8).init(allocator);
        defer line_list.deinit();
        while (true) {
            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            const line = try line_list.toOwnedSlice();
            var splitter = std.mem.splitSequence(u8, line, " ");

            var seq_list = std.ArrayList(i64).init(allocator);
            defer seq_list.deinit();
            while (splitter.next()) |part| {
                const num = try std.fmt.parseInt(i64, part, 10);
                try seq_list.append(num);
            }
            const seq = try seq_list.toOwnedSlice();
            const sequence: Sequence = .{ .nums = seq };
            try seqs_list.append(sequence);
        }

        return try seqs_list.toOwnedSlice();
    }

    pub fn getNextNumber(self: Sequence, allocator: std.mem.Allocator) !i64 {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const arena_allocator = arena.allocator();

        var num_list = std.ArrayList(i64).init(arena_allocator);
        defer num_list.deinit();
        var all_zeros = true;
        for (self.nums[0 .. self.nums.len - 1], self.nums[1..self.nums.len]) |num0, num1| {
            const new_num: i64 = num1 - num0;
            if (all_zeros and new_num != 0) {
                all_zeros = false;
            }
            try num_list.append(new_num);
        }

        if (all_zeros) {
            return self.lastNumber();
        }

        const seq = try num_list.toOwnedSlice();
        const sequence: Sequence = .{ .nums = seq };

        const sub_next_num = try sequence.getNextNumber(allocator);
        const last_num = self.lastNumber();
        const next_num = last_num + sub_next_num;
        return next_num;
    }

    pub fn lastNumber(self: Sequence) i64 {
        return self.nums[self.nums.len - 1];
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    const seq_list = try Sequence.parseSequences(stdin.reader(), allocator);

    var sum: i64 = 0;
    for (seq_list) |seq| {
        sum += try seq.getNextNumber(allocator);
    }

    try std.io.getStdOut().writer().print("Sum: {d}\n", .{sum});
}
