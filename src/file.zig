const std = @import("std");
const markdown = @import("minimdzig");
const String = @import("zig_string").String;
const fs = std.fs;
const MasterConfig = @import("./config.zig").MasterConfig;
const indexHtml = @import("./front/index.zig");

pub fn createNewDir(dir_name: []const u8) !void {
    var home = fs.cwd();
    defer home.close();

    home.makeDir(dir_name) catch {
        std.log.info("{s} already exist.", .{dir_name});
        return;
    };
    var dir = try home.openDir(dir_name, .{});
    defer dir.close();

    const toml_file = try dir.createFile("xj.toml", .{});
    defer toml_file.close();
    const toml_content =
        \\blog_name = "StaticBlogName"
        \\github = "https://github_path"
        \\output = "dist"
        \\is_headline = false
        \\images_path = "content/images"
        \\[[templates]]
        \\name = "about"
        \\path = "content/template/about.md"
        \\[[templates]]
        \\name = "footer"
        \\path = "content/template/footer.md"
        \\[[menus]]
        \\name = "Home" 
        \\url = "/home"
        \\[[menus]]
        \\name = "About"
        \\url = "/about"
        \\[[issues]]
        \\title = "test"
        \\path = "content/issue-1"
    ;

    _ = try toml_file.write(toml_content);

    dir.makeDir("issue-1") catch {
        std.log.info("issue-1 already exist.", .{});
    };
    const sub_dir = try dir.openDir("issue-1", .{});

    const outfile = try sub_dir.createFile("1-first.md", .{});
    defer outfile.close();
    _ = try outfile.write("hello, world.");

    const outfile2 = try sub_dir.createFile("2-second.md", .{});
    defer outfile2.close();
    _ = try outfile2.write("hello, world 2.");
    const issue_toml = try sub_dir.createFile("xj.toml", .{});
    defer issue_toml.close();
    const issue_toml_content =
        \\[[articles]]
        \\file = "1-first.md"
        \\title = "first article"
        \\author = ""
        \\pub_date = "2023-02-17"
        \\[[articles]]
        \\file = "2-second.md"
        \\title = "second article"
        \\author = ""
        \\pub_date = "2023-02-18"
    ;
    _ = try issue_toml.write(issue_toml_content);

    try dir.makeDir("template");
    const temp_dir = try dir.openDir("template", .{});
    var temp_file = try temp_dir.createFile("about.md", .{});
    defer temp_file.close();
    try temp_file.writeAll("about file.");

    temp_file = try temp_dir.createFile("footer.md", .{});
    try temp_file.writeAll("footer file.");
}

pub fn createHtmlAndJsFile(cwd: std.fs.Dir, dir_path: []const u8, content: []const u8, file_name: []const u8) !void {
    var dir: std.fs.Dir = undefined;
    cwd.makeDir(dir_path) catch {
        // std.log.info("{s} already exist.", .{dir_path});
        dir = try cwd.openDir(dir_path, .{});
        defer dir.close();
        const html_file = try dir.createFile(file_name, .{});
        defer html_file.close();
        try html_file.writeAll(content);
        return;
    };
    dir = try cwd.openDir(dir_path, .{});
    defer dir.close();

    const html_file = try dir.createFile(file_name, .{});
    defer html_file.close();
    try html_file.writeAll(content);
}

pub fn md2Html(home: std.fs.Dir, config: *MasterConfig, open_dir: []const u8, file_name: []const u8, title: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const al = arena.allocator();

    const dir = home.openDir(open_dir, .{}) catch {
        std.debug.print("open dir fail\n", .{});
        return;
    };
    //读取文件
    const md_file = dir.readFileAlloc(al, file_name, 1024 * 1024) catch {
        std.log.info("file not found\n", .{});
        return;
    };

    //解析生成html
    var parse = try markdown.parser(al, md_file);
    defer parse.deinit();
    //create dir and file
    // content/issue-1
    var dir_name = std.mem.split(u8, open_dir, "/");
    var dir_name_it = dir_name.next().?;
    dir_name_it = dir_name.next().?;

    // example.pd / .md
    var html_file_name = std.mem.split(u8, file_name, ".");
    const html_file_name_it = html_file_name.first();
    const html = try std.fmt.allocPrint(al, "{s}.html", .{html_file_name_it});
    //open dir
    home.makeDir(config.*.output) catch {};
    var dist_dir = try home.openDir(config.*.output, .{});
    defer dist_dir.close();

    dist_dir.makeDir(dir_name_it) catch {};
    const sub_dir = try dist_dir.openDir(dir_name_it, .{});

    const html_file = try sub_dir.createFile(html, .{});
    defer html_file.close();
    // try html_file.writeAll(html_segment_str);
    try html_file.writeAll(indexHtml.main_article_start);
    {
        const title_segment = try std.fmt.allocPrint(al, "<div class=\"article_title\"><h4 style=\"text-align: center\">{s}</h4></div></div>", .{title});
        try html_file.writeAll(title_segment);
    }
    {
        if (config.*.is_headline) {
            try html_file.writeAll("<ul>");
            for (parse.title_nav.items) |item| {
                try html_file.writeAll(item);
            }
            try html_file.writeAll("</ul>");
        }
    }
    const str = try std.mem.join(al, "", parse.out.items);
    const res = str[0..str.len];
    try html_file.writeAll(res);
    try html_file.writeAll(indexHtml.main_article_end);
}

pub fn genTemplateHtml(al: std.mem.Allocator, home: std.fs.Dir, path: []const u8) !?markdown.Parser {
    const md_file = home.readFileAlloc(al, path, 1024 * 1024) catch {
        std.log.info("file not found: {s}\n", .{path});
        return null;
    };

    const parse = try markdown.parser(al, md_file);
    return parse;
}

pub fn copyDirFile(home: std.fs.Dir, src_dir: []const u8, dest_dir: []const u8, sub_dir_name: []const u8) !void {
    var des_dir = try home.openDir(dest_dir, .{});
    defer des_dir.close();

    des_dir.makeDir("images") catch {};
    var images_dir = try des_dir.openDir(sub_dir_name, .{});
    defer images_dir.close();

    var dir = try home.openDir(src_dir, .{ .iterate = true });
    defer dir.close();

    var dir_iter = dir.iterate();
    while (try dir_iter.next()) |entry| {
        if (entry.kind == .file) {
            try dir.copyFile(entry.name, images_dir, entry.name, .{});
        }
    }
}

pub fn spiltTwoStep(str: []const u8, delimiter: []const u8) []const u8 {
    // content/issue-1
    var dir_name = std.mem.split(u8, str, delimiter);
    var dir_name_it = dir_name.next().?;
    dir_name_it = dir_name.next().?;
    return dir_name_it;
}

pub fn splitFisrt(str: []const u8, delimiter: []const u8) []const u8 {
    var html_file_name = std.mem.split(u8, str, delimiter);
    const html_file_name_it = html_file_name.first();
    return html_file_name_it;
}

pub fn getFilename(al: std.mem.Allocator, cwd: std.fs.Dir, path: []const u8) !?[]const u8 {
    var dir = cwd.openDir(path, .{ .iterate = true }) catch |err| {
        const msg = switch (err) {
            error.NotDir => "not a directory",
            error.FileNotFound => "doesn't exist",
            error.AccessDenied => "access denied",
            else => {
                std.debug.print("** BANG: {s} {any}\n", .{ path, err });
                @panic("unexpected error trying to open a directory");
            },
        };
        std.debug.print("* {s}: '{s}'\n", .{ msg, path });
        return null;
    };
    defer dir.close();

    var dirit = dir.iterate();

    while (try dirit.next()) |entry| {
        // check for zero-length files and unopenable files
        if (entry.kind == .file) {
            const f = dir.openFile(entry.name, .{}) catch {
                return null;
            };
            defer f.close();

            if ((try f.stat()).size == 0) {
                return null;
            }
        }
        if (std.mem.endsWith(u8, entry.name, ".toml")) {
            const str = try std.fmt.allocPrint(al, "{s}", .{entry.name});
            return str;
        }
    }
    return null;
}
