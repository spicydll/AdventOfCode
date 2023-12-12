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

const SpringMask = struct {
    mask: []SpringState,

    pub fn init(spring_row: SpringRow, allocator: std.mem.Allocator) !SpringMask {
        var mask_list = std.ArrayList(SpringState).init(allocator);
        defer mask_list.deinit();
        for (spring_row.springs) |spring| {
            if (spring == SpringState.unknown) {
                try mask_list.append(SpringState.operational);
            }
        }
        const mask = mask_list.toOwnedSlice();
        return .{ .mask = mask };
    }

    pub fn next(self: SpringMask) ?SpringMask {
        _ = self;
        
    }
};

const SpringRow = struct {
    springs: []const SpringState,
    damaged: []const u64,

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
            while (damage_splitter.next()) |damage| {
                const damage_num = try std.fmt.parseUnsigned(u64, damage, 10);
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

    pub fn checkPermutations(self: SpringRow) u64 {
        _ = self;
        
    }
};

pub fn main() !void {}
