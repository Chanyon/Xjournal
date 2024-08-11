const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "xj",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    //http.zig
    const http = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("httpz", http.module("httpz"));

    //md-zig
    const minimd = b.dependency("minimd", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("minimdzig", minimd.module("minimd"));

    //yazap
    const yazap = b.dependency("yazap", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("yazap", yazap.module("yazap"));

    //zig-toml
    const toml = b.dependency("zig_toml", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zig-toml", toml.module("zig-toml"));

    //zig-string
    const string = b.dependency("string", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("string", string.module("string"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
