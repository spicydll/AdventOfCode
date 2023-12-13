const std = @import("std");

const Particle = enum {
    ash,
    rock,

    pub fn fromChar(c: u8) !Particle {
        return switch (c) {
            '.' => Particle.ash,
            '#' => Particle.rock,
            else => error.NotAParticle,
        };
    }
};

const Pattern = struct {
    particles: []const []const Particle,

    pub fn parsePatterns(reader: anytype, allocator: std.mem.Allocator) ![]const Pattern {
        var patterns_list = std.ArrayList(Pattern).init(allocator);
        defer patterns_list.deinit();

        while (true) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();

            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;

            var rows_list = std.ArrayList([]const Particle).init(allocator);
            defer rows_list.deinit();
            while (true) {
                const line = try line_list.toOwnedSlice();
                if (line.len == 0) {
                    break;
                }
                var row_list = std.ArrayList(Particle).init(allocator);
                defer row_list.deinit();

                for (line) |c| {
                    const particle = try Particle.fromChar(c);
                    try row_list.append(particle);
                }
                const row = try row_list.toOwnedSlice();
                try rows_list.append(row);

                reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            }

            const rows = try rows_list.toOwnedSlice();
            const pattern: Pattern = .{ .particles = rows };
            try patterns_list.append(pattern);
        }

        return try patterns_list.toOwnedSlice();
    }

    fn checkRowMirrored(self: Pattern, row_after: usize) bool {
        for (self.particles[row_after..], 1..) |row, i| {
            if (i >= row_after + 1) {
                break;
            }
            if (!std.mem.eql(Particle, row, self.particles[row_after - i])) {
                return false;
            }
        }
        return true;
    }

    fn checkColMirred(self: Pattern, col_after: usize) bool {
        for (1..col_after + 1) |i| {
            const right_i = col_after + i - 1;
            const left_i = col_after - i;
            if (right_i >= self.particles[0].len) {
                break;
            }
            for (self.particles) |row| {
                if (row[right_i] != row[left_i]) {
                    return false;
                }
            }
            //std.debug.print("Cols {d} and {d} are equal", .{ col_after - right_i, right_i });
        }

        return true;
    }

    pub fn getSummary(self: Pattern) u64 {
        for (1..self.particles.len) |row_i| {
            if (self.checkRowMirrored(row_i)) {
                return @as(u64, @intCast(row_i)) * 100;
            }
        }

        for (1..self.particles[0].len) |col_i| {
            if (self.checkColMirred(col_i)) {
                return @as(u64, @intCast(col_i));
            }
        }
        return 0;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    const patterns = try Pattern.parsePatterns(stdin.reader(), allocator);
    //std.debug.print("patterns: {d}\n", .{patterns.len});
    var sum: u64 = 0;
    for (patterns) |pattern| {
        sum += pattern.getSummary();
    }

    try std.io.getStdOut().writer().print("Summary: {d}\n", .{sum});
}
