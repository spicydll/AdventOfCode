const std = @import("std");

const Directive = struct {
    name: []const u8,
    left: []const u8,
    right: []const u8,
    left_ptr: *Directive,
    right_ptr: *Directive,

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

        for (sorted_dirs, 0..) |dir, i| {
            for (sorted_dirs, 0..) |dir2, j| {
                if (std.mem.eql(u8, dir.left, dir2.name)) {
                    sorted_dirs[i].left_ptr = &sorted_dirs[j];
                }
                if (std.mem.eql(u8, dir.right, dir2.name)) {
                    sorted_dirs[i].right_ptr = &sorted_dirs[j];
                }
            }
        }

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

fn checkDirectives(directives: []const Directive) bool {
    for (directives) |dir| {
        if (dir.name[dir.name.len - 1] != 'Z') {
            return false;
        }
    }

    return true;
}

fn countSteps(directives: []const Directive, directions: []const u8, allocator: std.mem.Allocator) !u128 {
    var steps: u128 = 1;
    var big_steps: u128 = 1;

    var cur_directives = std.ArrayList(Directive).init(allocator);

    for (directives) |dir| {
        if (dir.name[dir.name.len - 1] == 'Z') {
            try cur_directives.append(dir);
        }
    }

    var cur_dirs = try cur_directives.toOwnedSlice();

    var finished = false;
    while (!finished) {
        if (big_steps >= 1000000) {
            std.debug.print("steps: {d}\r", .{steps});
            big_steps = 0;
        }
        for (directions) |direction| {
            defer steps += 1;
            defer big_steps += 1;
            finished = true;
            for (cur_dirs, 0..) |dir, i| {
                var new_directive: *Directive = undefined;
                if (direction == 'L') {
                    new_directive = dir.left_ptr;
                } else {
                    new_directive = dir.right_ptr;
                }

                if (finished and new_directive.name[new_directive.name.len - 1] != 'Z') {
                    finished = false;
                }

                cur_dirs[i] = new_directive.*;
            }

            if (finished) {
                return steps;
            }
        }
    }

    return steps;
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

    const steps = try countSteps(sorted_dirs, directions, allocator);

    try stdout.writer().print("Steps: {d}\n", .{steps});
}
