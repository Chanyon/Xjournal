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
    // std.log.info("{s}", .{req.url.path});
    const sub_path = try std.fmt.allocPrint(std.heap.page_allocator, "dist{s}", .{req.url.path});
    defer std.heap.page_allocator.free(sub_path);

    var file = std.fs.cwd().openFile(sub_path, .{}) catch {
        res.body = "Not Found";
        return;
    };
    defer file.close();

    res.body = try file.readToEndAlloc(req.arena, 100000);
}
