const std = @import("std");

const Pull = struct {
    red: u32,
    green: u32,
    blue: u32
};

const Game = struct {
    pullList: []Pull,
    id: u32,

    pub fn init(allocator: anytype) Game {
        return Game {
            
        }
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
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();


    while (true) {
        const input = (try nextLine(stdin.reader(), &buffer)) orelse break;
    }
}
