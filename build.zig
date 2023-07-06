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
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    //zap
    // const zap = b.dependency("zap", .{
    //     .target = target,
    //     .optimize = optimize,
    // });
    // exe.addModule("zap", zap.module("zap"));
    // exe.linkLibrary(zap.artifact("facil.io"));

    //yazap
    exe.addAnonymousModule("yazap", .{
        .source_file = .{ .path = "dep/yazap/src/lib.zig" },
    });
    //zig-toml
    exe.addAnonymousModule("zig-toml", .{ .source_file = .{ .path = "dep/zig-toml/src/main.zig" } });
    //zig-string
    exe.addAnonymousModule("zig-string", .{ .source_file = .{ .path = "dep/zig-string/zig-string.zig" } });
    //md-zig
    exe.addAnonymousModule("minimd-zig", .{ .source_file = .{ .path = "dep/minimd-zig/src/lib.zig" } });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
