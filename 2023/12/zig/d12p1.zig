const std = @import("std");

const SpringState = enum {
    operational,
    damaged,
    unknown,

    pub fn fromU8(c: u8) !SpringState {
        return switch (c) {
            '.' => SpringState.operational,
            '#' => SpringState.damaged,
            '?' => SpringState.unknown,
            else => error.InvalidSpring,
        };
    }
};

const SpringRow = struct {
    springs: []const SpringState,
    damaged: []const u64,

    pub fn parseSpringRows(reader: anytype, allocator: std.mem.Allocator) ![]const SpringRow {
        var spring_row_list = std.ArrayList(SpringRow).init(allocator);
        defer spring_row_list.deinit();

        while (true) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();
            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            const line = try line_list.toOwnedSlice();

            var splitter = std.mem.splitScalar(u8, line, ' ');
            const spring_part = splitter.next() orelse return error.ParseError;
            const damaged_part = splitter.next() orelse return error.ParseError;

            var spring_list = std.ArrayList(SpringState).init(allocator);
            defer spring_list.deinit();

            for (spring_part) |spring| {
                const spring_state = try SpringState.fromU8(spring);
                try spring_list.append(spring_state);
            }
            const springs = try spring_list.toOwnedSlice();

            var damaged_list = std.ArrayList(u64).init(allocator);
            var damage_splitter = std.mem.splitScalar(u8, damaged_part, ',');
            var damage_sum: u64 = 0;
            while (damage_splitter.next()) |damage| {
                const damage_num = try std.fmt.parseUnsigned(u64, damage, 10);
                damage_sum += damage_num;
                try damaged_list.append(damage_num);
            }
            const damaged = try damaged_list.toOwnedSlice();
            const spring_row: SpringRow = .{
                .springs = springs,
                .damaged = damaged,
            };

            try spring_row_list.append(spring_row);
        }

        return try spring_row_list.toOwnedSlice();
    }

    fn getNumDamaged(self: SpringRow) u64 {
        var num_damaged: u64 = 0;
        for (self.damaged) |num| {
            num_damaged += num;
        }
        return num_damaged;
    }

    fn countPossibilities(self: SpringRow, start_spring: usize, first_group: usize) u64 {
        const impossible: u64 = 0;
        const single_possibility: u64 = 1;
        if (start_spring >= self.springs.len) {
            if (first_group >= self.damaged.len) {
                return single_possibility;
            }
            return impossible;
        }

        const springs = self.springs[start_spring..];

        if (first_group >= self.damaged.len) {
            for (springs) |spring| {
                if (spring == SpringState.damaged) {
                    return impossible;
                }
            }
            return single_possibility;
        }

        if (start_spring > 0 and self.springs[start_spring - 1] == SpringState.damaged) {
            return impossible;
        }

        const groups = self.damaged[first_group..];

        if (@as(usize, @intCast(groups[0])) > springs.len) {
            return impossible;
        }

        if (springs[0] == SpringState.operational) {
            return self.countPossibilities(start_spring + 1, first_group);
        }
        var num_damaged: u64 = 1;
        var pure = true;
        for (springs[1..]) |spring| {
            if (spring == SpringState.operational) {
                break;
            }
            if (spring == SpringState.unknown) {
                pure = false;
            }
            num_damaged += 1;
        }

        if (num_damaged < groups[0]) {
            return impossible;
        }

        if (num_damaged == groups[0]) {
            // One possible spot for this group
            return self.countPossibilities(start_spring + @as(usize, @intCast(num_damaged)) + 1, first_group + 1);
        }

        if (pure) {
            // too big
            return impossible;
        }

        var total_possibilities = self.countPossibilities(start_spring + @as(usize, @intCast(groups[0])) + 1, first_group + 1);
        total_possibilities += self.countPossibilities(start_spring + 1, first_group);
        std.debug.print("Returning: {d}\n", .{total_possibilities});
        return total_possibilities;
    }

    pub fn checkPermutations(self: SpringRow) u64 {
        return self.countPossibilities(0, 0);
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    const spring_rows = try SpringRow.parseSpringRows(stdin.reader(), allocator);

    var sum: u64 = 0;
    for (spring_rows) |spring_row| {
        const perms = spring_row.checkPermutations();
        std.debug.print("{d}\n", .{perms});
        sum += perms;
    }

    try std.io.getStdOut().writer().print("Sum: {d}\n", .{sum});
}
