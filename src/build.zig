const std = @import("std");
const toml = @import("zig-toml");
const String = @import("string").String;
const configs = @import("./config.zig");
const idxHtml = @import("./front/index.zig");
const idxJs = @import("./front/index-js.zig");
const getFilename = @import("./file.zig").getFilename;
const createFile = @import("./file.zig").createHtmlAndJsFile;
const genHtml = @import("./file.zig").md2Html;
const template2Html = @import("./file.zig").genTemplateHtml;
const splitTwoStep = @import("./file.zig").spiltTwoStep;
const splitFirst = @import("./file.zig").splitFisrt;
const Parser = @import("minimdzig").Parser;
const copyDirFile = @import("./file.zig").copyDirFile;

pub fn build() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var myString = String.init(allocator);
    defer myString.deinit();
    try myString.concat(idxHtml.html_start);

    var jsString = String.init(allocator);
    defer jsString.deinit();
    try jsString.concat(idxJs.script_start);

    var parser = toml.Parser(configs.MasterConfig).init(allocator);
    defer parser.deinit();

    var home = std.fs.cwd();
    defer home.close();

    //TODO: free allocator of master_config
    var master_config = try parser.parseFile("./content/xj.toml");

    const title: []const u8 = try std.fmt.allocPrint(allocator, "\n<title>{s}</title>\n", .{master_config.value.blog_name});
    try myString.concat(title);
    try myString.concat(idxHtml.head_end);
    try myString.concat(idxHtml.header_start);

    const blog_name: []const u8 = try std.fmt.allocPrint(allocator, "<div> {s} </div><div><ul>", .{master_config.value.blog_name});
    try myString.concat(blog_name);

    for (master_config.value.menus) |menu| {
        //* link herf
        const nav_link: []const u8 = try std.fmt.allocPrint(allocator, "<li><a data-href=\"{s}\">{s}</a></li>", .{ menu.url, menu.name });
        try myString.concat(nav_link);
        const menu_url_val = try std.fmt.allocPrint(allocator, "\n\"{s}\":\".{s}.html\",\n", .{ menu.url, menu.url });
        try jsString.concat(menu_url_val);
    }
    try myString.concat(idxHtml.header_end);

    var parser2 = toml.Parser(configs.ArticleConfig).init(allocator);
    defer parser2.deinit();

    var article_config: toml.Parsed(configs.ArticleConfig) = undefined;

    try myString.concat(idxHtml.main_start);
    for (master_config.value.issues) |item| {
        // !delete ?
        const toml_file = try getFilename(allocator, home, item.path);
        if (toml_file) |file| {
            const path: []const u8 = try std.fmt.allocPrint(allocator, "./{s}/{s}", .{ item.path, file });
            article_config = try parser2.parseFile(path);
            // section tag
            const section_start = "<section>";
            try myString.concat(section_start);

            const h3: []const u8 = try std.fmt.allocPrint(allocator, "<h5>{s}</h5> <ul>", .{item.title});

            try myString.concat(h3);
            //* article link
            const dir_path = splitTwoStep(item.path, "/");
            for (article_config.value.articles) |link| {
                const file_name = splitFirst(link.file, ".");
                const li_link: []const u8 = try std.fmt.allocPrint(allocator, "<li><a data-href=\"/{s}/{s}\">{s}</a><p class=\"pub-date\">{s}</p></li>", .{ dir_path, file_name, link.title, link.pub_date });
                try myString.concat(li_link);

                const obj_key_val = try std.fmt.allocPrint(allocator, "\n\"/{s}/{s}\":\"./{s}/{s}.html\",\n", .{ dir_path, file_name, dir_path, file_name });
                try jsString.concat(obj_key_val);

                std.debug.print("{s} {s} => {s}.html\n", .{ item.path, link.file, file_name });
                // 遍历生成html file
                try genHtml(home, &master_config.value, item.path, link.file, link.title);
            }

            const section_end = "</ul></section>";
            try myString.concat(section_end);
        } else {
            std.log.info("toml file content is null or doesn't exist", .{});
            return;
        }
    }

    try myString.concat(idxHtml.main_end);
    try myString.concat(idxHtml.footer_start);

    var c_html: ?Parser = undefined;
    for (master_config.value.templates) |temp| {
        c_html = try template2Html(allocator, home, temp.path);
        const str = try std.mem.join(allocator, "", c_html.?.out.items);
        const res = str[0..str.len];
        if (std.mem.eql(u8, "footer", temp.name)) {
            const footer_end: []const u8 = try std.fmt.allocPrint(allocator, "{s}</footer> </div>", .{res});
            try myString.concat(footer_end);
        } else {
            const file_name = try std.fmt.allocPrint(allocator, "{s}.html", .{temp.name});
            try createFile(home, master_config.value.output, res, file_name);
        }
    }
    defer c_html.?.deinit();

    try jsString.concat("};\n");
    try jsString.concat(idxJs.script_end);
    try myString.concat(jsString.str());
    try myString.concat(idxHtml.html_end);

    // create index.html
    try createFile(home, master_config.value.output, myString.str(), "index.html");
    //copy `images dir` file
    if (master_config.value.images_path) |path| {
        try copyDirFile(home, path, master_config.value.output, "images");
    }
}
