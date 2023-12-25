const std = @import("std");

const GraphNode = struct {
    name: []u8,
    connections: []*GraphNode,
};

const Graph = struct {
    nodes: []GraphNode,
    allocator: std.mem.Allocator,

    pub fn parseGraph(allocator: std.mem.Allocator, reader: std.io.AnyReader) !Graph {
        var graph_node_list = std.ArrayList(GraphNode).init(allocator);
        defer graph_node_list.deinit();
        var sub_nodes = std.ArrayList([]const u8).init(allocator);
        defer sub_nodes.deinit();

        while (true) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();

            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            const line = try line_list.toOwnedSlice();

            var graph_node: GraphNode = undefined;

            var splitter = std.mem.splitSequence(u8, line, ": ");
            const name = splitter.next() orelse break;
            graph_node.name = name;

            const sub_part = splitter.next() orelse return error.ParseError;
            var sub_splitter = std.mem.splitScalar(u8, sub_part, ' ');

            var sub_nodes_list = std.ArrayList(u8).init(allocator);
            defer sub_nodes_list.deinit();
            while (sub_splitter.next()) |part| {
                try sub_nodes_list.append(part);
            }

            const sub_node_array = try sub_nodes_list.toOwnedSlice();
            try sub_nodes.append(sub_node_array);
        }
    }
};

pub fn main() !void {}
