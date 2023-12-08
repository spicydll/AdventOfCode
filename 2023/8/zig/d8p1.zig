const std = @import("std");

const Directive = struct {
    name: []const u8,
    left: []const u8,
    right: []const u8,

    pub fn parseDirectives(reader: anytype, allocator: std.mem.Allocator) ![]Directive {
        var buf: [32]u8 = undefined;

        var dir_list = std.ArrayList(Directive).init(allocator);
        defer dir_list.deinit();
        while (true) {
            const line = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse break;

            var splitter = std.mem.split(u8, line, " = ");
            const name_part = splitter.next() orelse return error.ParseError;
            const child_part = splitter.next() orelse return error.ParseError;

            var directive: Directive = undefined;
            directive.name = try allocator.dupe(u8, name_part);

            var child_splitter = std.mem.split(u8, child_part, ", ");
            const left_part = child_splitter.next() orelse return error.ParseError;
            const right_part = child_splitter.next() orelse return error.ParseError;

            directive.left = try allocator.dupe(u8, left_part[1..]);
            directive.right = try allocator.dupe(u8, right_part[0..(right_part.len - 1)]);

            try dir_list.append(directive);
        }
        var sorted_dirs = try dir_list.toOwnedSlice();
        sorted_dirs[0] = sorted_dirs[0];
        std.mem.sort(Directive, sorted_dirs, {}, Directive.lessThan);

        return sorted_dirs;
    }

    pub fn lessThan(context: void, a: Directive, b: Directive) bool {
        _ = context;
        for (a.name, b.name) |a_name, b_name| {
            if (a_name == b_name) {
                continue;
            }

            return a_name < b_name;
        }

        return false;
    }
};

fn countSteps(directives: []const Directive, directions: []const u8) u32 {
    var steps: u32 = 1;

    var cur_directive: Directive = directives[0];
    std.debug.print("Starting directive: {s}\n", .{cur_directive.name});

    while (!std.mem.eql(u8, cur_directive.name, "ZZZ")) {
        for (directions) |direction| {
            defer steps += 1;
            var new_directive: []const u8 = undefined;
            if (direction == 'L') {
                new_directive = cur_directive.left;
            } else {
                new_directive = cur_directive.right;
            }

            if (std.mem.eql(u8, new_directive, "ZZZ")) {
                return steps;
            }

            for (directives) |directive| {
                if (std.mem.eql(u8, directive.name, new_directive)) {
                    cur_directive = directive;
                    break;
                }
            }
        }
    }

    unreachable;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    var buf: [4096]u8 = undefined;
    const directions = try stdin.reader().readUntilDelimiter(&buf, '\n');
    try stdin.reader().skipUntilDelimiterOrEof('\n');
    const sorted_dirs = try Directive.parseDirectives(stdin.reader(), allocator);

    const steps = countSteps(sorted_dirs, directions);

    try stdout.writer().print("Steps: {d}\n", .{steps});
}
