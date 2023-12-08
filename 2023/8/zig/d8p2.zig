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

fn GCD(a: u128, b: u128) u128 {
    if (b == 0) {
        return a;
    }
    return GCD(b, a % b);
}

fn LCM(numbers: []const u128) u128 {
    if (numbers.len == 2) {
        return (numbers[0] * numbers[1]) / GCD(numbers[0], numbers[1]);
    }

    var params: [2]u128 = undefined;
    params[0] = numbers[0];
    params[1] = LCM(numbers[1..]);
    return LCM(&params);
}

fn countSteps(directives: []const Directive, directions: []const u8, allocator: std.mem.Allocator) !u128 {
    var path_list = std.ArrayList(u128).init(allocator);

    for (directives) |dir| {
        if (dir.name[dir.name.len - 1] == 'A') {
            var dir_steps: u128 = 0;
            var cur_dir = dir;
            var done = false;

            while (!done) {
                for (directions) |direction| {
                    defer dir_steps += 1;
                    if (direction == 'L') {
                        cur_dir = cur_dir.left_ptr.*;
                    } else {
                        cur_dir = cur_dir.right_ptr.*;
                    }

                    if (cur_dir.name[cur_dir.name.len - 1] == 'Z') {
                        done = true;
                        break;
                    }
                }
            }

            std.debug.print("Number: {d}\n", .{dir_steps});

            try path_list.append(dir_steps);
        }
    }

    const path_lens = try path_list.toOwnedSlice();

    return LCM(path_lens);
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
