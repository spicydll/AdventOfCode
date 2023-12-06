const std = @import("std");

const Race = struct {
    time: i64,
    distance: i64,

    pub fn checkWin(self: Race, hold_time: i64) bool {
        const time_left: i64 = self.time - hold_time;
        if (time_left <= 0) {
            return false;
        }

        const dist_traveled: i64 = time_left * hold_time;

        return self.distance < dist_traveled;
    }
};

pub fn main() !void {
    const race: Race = .{ .time = 46689866, .distance = 358105418071080 };

    var wins: u64 = 0;

    var hold_time: i64 = 1;
    while (hold_time < race.time) : (hold_time += 1) {
        if (race.checkWin(hold_time)) {
            wins += 1;
        }
    }

    try std.io.getStdOut().writer().print("Wins: {}\n", .{wins});
}
