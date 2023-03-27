const std = @import("std");
const prog = @import("progdoc");
const fs = std.fs;

pub fn createNewDir(dir_name: []const u8) !void {
    var home = fs.cwd();

    home.makeDir(dir_name) catch {
        std.log.info("{s} already exist.", .{dir_name});
    };
    const dir = try home.openDir(dir_name, .{});
    const toml_file = try dir.createFile("xj.toml", .{});
    defer toml_file.close();
    const toml_content =
        \\blog_name = "StaticBlogName"
        \\github_path = "https://github_path"
        \\[[menus]]
        \\name = "About" 
        \\url = "/about"
        \\[[menus]]
        \\name = "Blog"
        \\url = "/blog"
        \\[[issue]]
        \\title = "js相关"
        \\path = "content/issue-1"
    ;

    _ = try toml_file.write(toml_content);

    dir.makeDir("issue-1") catch {
        std.log.info("issue-1 already exist.", .{});
    };
    const sub_dir = try dir.openDir("issue-1", .{});

    const outfile = try sub_dir.createFile("1-first.pd", .{});
    defer outfile.close();
    _ = try outfile.write("hello, world.");

    const outfile2 = try sub_dir.createFile("2-second.pd", .{});
    defer outfile2.close();
    _ = try outfile2.write("hello, world 2.");
    const issue_toml = try sub_dir.createFile("xj.toml", .{});
    defer issue_toml.close();
    const issue_toml_content =
        \\[[article]]
        \\file = "1-first.pd"
        \\title = "first article"
        \\author = ""
        \\pub_date = "2023-02-17"
        \\[[article]]
        \\file = "2-first.pd"
        \\title = "second article"
        \\author = ""
        \\pub_date = "2023-02-18"
    ;
    _ = try issue_toml.write(issue_toml_content);
}

// fn processFilename(al: std.mem.Allocator, cwd: std.fs.Dir, path:[]const u8) !void {
//     // equivalent of ts readdirAndStat
//     // get the dirent of each entry in this directory
//     // but we need to add more info: file sizes and errors. only the former will be used in matching

//     var dir = cwd.openIterableDir(path, .{}) catch |err| {
//         var msg: ?[]const u8 = switch (err) {
//             error.NotDir => "not a directory",
//             error.FileNotFound => "doesn't exist",
//             error.AccessDenied => "access denied",
//             else => {
//                 std.debug.print("** BANG: {s} {any}\n", .{path, err});
//                 @panic("unexpected error trying to open a directory");
//             },
//         };
//         std.debug.print("* {s}: '{s}'\n", .{msg.?, path});
//         return;
//     };
//     defer dir.close();

//     var dirit = dir.iterate();

//     var dirent_list = std.ArrayList([]const u8).init(al);

//     while (try dirit.next()) |entry| {
//         // check for zero-length files and unopenable files
//         var kindSymbol: ?u8 = null;
//         if (entry.kind == .File) blk: {
//             const f: std.fs.File = dir.dir.openFile(entry.name, .{}) catch {
//                 kindSymbol = '!';
//                 break :blk;
//             };
//             defer f.close();

//             if ((try f.stat()).size == 0) {
//                 kindSymbol = '0';
//             } else {
//                 kindSymbol = ' ';
//             }
//         } else {
//             kindSymbol = switch (entry.kind) {
//                 .Directory => '/',
//                 .SymLink => '~',
//                 else => '?',
//             };
//         }

//         const str = try std.fmt.allocPrint(al, "{c} {s}", .{kindSymbol.?, entry.name});
//         try dirent_list.append(str);
//     }

//     std.sort.sort([]const u8, dirent_list.items, {}, myLessThan);

//     for (dirent_list.items) |dirent| {
//         std.debug.print("{s}\n", .{dirent});
//     }

//     for (dirent_list.items) |dirent| {
//         al.free(dirent);
//     }
//     dirent_list.deinit();
// }
