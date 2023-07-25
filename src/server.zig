// server
const std = @import("std");
const httpz = @import("httpz");

pub fn createServe(al: std.mem.Allocator, dir_path: []const u8, port: []const u8) !void {
    _ = dir_path;
    const p = try std.fmt.parseInt(u16, port, 10);
    var server = try httpz.Server().init(al, .{
        .address = "127.0.0.1",
        .port = p,
    });

    server.notFound(staticFile);
    var router = server.router();
    router.get("/", index);

    try server.listen();
}

fn index(req: *httpz.Request, res: *httpz.Response) !void {
    var index_file = try std.fs.cwd().openFile("dist/index.html", .{});
    defer index_file.close();
    res.body = try index_file.readToEndAlloc(req.arena, 100000);
}

fn staticFile(req: *httpz.Request, res: *httpz.Response) !void {
    res.header("Content-Type", "text/html");
    const path = req.url.path;
    var buf: std.ArrayList(u8) = std.ArrayList(u8).init(req.arena);
    defer buf.deinit();
    const result = try httpz.Url.unescape(req.arena, buf.items, path);
    // std.log.debug("{s}", .{result.value});

    const sub_path = try std.fmt.allocPrintZ(req.arena, "dist{s}", .{result.value});
    defer req.arena.free(sub_path);

    var file = std.fs.cwd().openFile(sub_path, .{}) catch {
        res.body = "Not Found";
        return;
    };
    defer file.close();

    res.body = try file.readToEndAlloc(req.arena, 1000000);
}
