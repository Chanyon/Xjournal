pub const MasterConfig = struct {
    blog_name: []const u8,
    github: []const u8,
    menus: []const Menu,
    issues: []const Issue,
    template: *Template,
};

const Menu = struct {
    name: []const u8,
    url: []const u8,
};

const Issue = struct {
    title: []const u8,
    path: []const u8,
};

const Template = struct {
    about: []const u8,
    footer: []const u8,
};

pub const ArticleConfig = struct {
    articles: []const Article,
};

const Article = struct {
    file: []const u8,
    title: []const u8,
    author: []const u8,
    pub_date: []const u8,
};
