pub const MasterConfig = struct {
  blog_name: []const u8,
  github: []const u8,
  menus: []const Menu,
  issues: []const Issue,
};

const Menu = struct {
  name: []const u8,
  url: []const u8,
};

const Issue = struct {
  title: []const u8,
  path: []const u8,
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