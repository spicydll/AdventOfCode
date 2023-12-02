const std = @import("std");

const Pull = struct {
    red: u32,
    green: u32,
    blue: u32
};

const Game = struct {
    pullList: []Pull,
    id: u32,

    pub fn init(allocator: std.mem.Allocator) Game {
        var pullList = std.ArrayList(Pull).init(allocator);

        return Game {
            .id = undefined,
            .pullList = pullList,
        };
    }

    pub fn deinit(self: Game) void {
        self.pullList.deinit();
    }

    pub fn parseGame(reader: anytype, allocator: std.mem.Allocator) !Game {
        var game = Game.init(allocator);
        var buffer: [32]u8 = undefined;
        const input = try reader.readUntilDelimiterOrEof()
    }
};

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;

    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

fn parseGame(reader: anytype) !Game {

}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();


    while (true) {
        const input = (try nextLine(stdin.reader(), &buffer)) orelse break;
    }
}
