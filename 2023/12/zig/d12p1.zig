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
    operational: []u64,

    pub fn parseSpringRows(reader: std.io.AnyReader, allocator: std.mem.Allocator) ![]const SpringRow {
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

            var damaged_list = std.ArrayList(u32).init(allocator);
            var damage_splitter = std.mem.splitScalar(u8, damaged_part, ',');
            var damage_sum: u64 = 0;
            while (damage_splitter.next()) |damage| {
                const damage_num = try std.fmt.parseUnsigned(u64, damage, 10);
                damage_sum += damage_num;
                try damaged_list.append(damage_num);
            }
            const damaged = try damaged_list.toOwnedSlice();
            var operational: []u64 = try allocator.alloc(u64, damaged.len + 1);
            for (operational, 0..) |_, i| {
                operational[i] = 1;
            }
            operational[0] = 0;
            operational[operational.len - 1] = @as(u64, @intCast(springs.len - (operational.len - 2))) - damage_sum;

            const spring_row: SpringRow = .{
                .springs = springs,
                .damaged = damaged,
                .operational = operational,
            };

            try spring_row_list.append(spring_row);
        }

        return try spring_row_list.toOwnedSlice();
    }

    fn checkCurrentPermutation(self: SpringRow) bool {
        var spring_i: usize = 0;
        for (self.operational, 0..) |operational, i| {
            const operational_size: usize = @as(usize, @intCast(operational));

            const spring_i_start = spring_i;
            while ((spring_i - spring_i_start) < operational_size) : (spring_i += 1) {
                const valid = switch (self.springs[spring_i]) {
                    SpringState.operational => true,
                    SpringState.unknown => true,
                    SpringState.damaged => false,
                };

                if (!valid) {
                    return false;
                }
            }

            if (i < self.damaged.len) {
                const damage_size: usize = @as(usize, @intCast(self.damaged[i]));
                const spring_i_next = spring_i;
                while ((spring_i - spring_i_next) < damage_size) : (spring_i += 1) {
                    const valid = switch (self.springs[spring_i]) {
                        SpringState.operational => false,
                        SpringState.unknown => true,
                        SpringState.damaged => true,
                    };

                    if (!valid) {
                        return false;
                    }
                }
            }
        }

        return true;
    }

    fn inflate(self: *SpringRow, part: usize) !void {
        const take_from: usize = switch (part) {
            0 => self.operational.len - 1,
            else => part - 1,
        };

        const before_take = self.operational[take_from] - 1;

        if (before_take == 1) {
            if (take_from != 0 and take_from != self.operational.len - 1) {
                return error.CannotInflate;
            }
        } else if (before_take == 0) {
            return error.CannotInflate;
        }

        self.operational[take_from] -= 1;
        self.operational[part] += 1;
    }

    fn permuteToSum(sum: u64, num: usize, min: u64, allocator: std.mem.Allocator) std.ArrayList([]const u64) {
        _ = allocator;
        _ = min;
        _ = num;
        _ = sum;
        
    }

    pub fn checkPermutations(self: *SpringRow) u64 {
        var num_permutations: u64 = 0;

        for (self.operational, 0..) |_, i| {
            while (true) {
                if (self.checkCurrentPermutation()) {
                    num_permutations += 1;
                }
                self.inflate(i) catch break;
            }
        }
    }
};

pub fn main() !void {}
