const std = @import("std");
// const GitRepoStep = @import("./zig-build-repos/GitRepoStep.zig");

const pkgs = struct {
    const prog = std.build.Pkg{
        .name = "progdoc",
        .source = .{ .path = "dep/progdoc/progdoc.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };

    const yazap = std.build.Pkg{
        .name = "yazap",
        .source = .{ .path = "dep/yazap/src/lib.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };

    const zigString = std.build.Pkg{
        .name = "zig_string",
        .source = .{ .path = "dep/zig-string/zig-string.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };

    const zigToml = std.build.Pkg{
        .name = "zig_toml",
        .source = .{ .path = "dep/zig-toml/src/main.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };
};

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    // const zig_progdoc = GitRepoStep.create(b, .{
    //     .url = "https://github.com/Chanyon/progdoc",
    //     .branch = "main",
    //     .sha = "a0c39f45d7a1dd0d4ca6b952d52e7d6a3d4b262f", //git rev-parse main -> sha
    // });
    // exe.step.dependOn(&zig_progdoc.step);
    // exe.addPackagePath("progdoc", try std.fs.path.join(b.allocator, &[_][]const u8 {
    // zig_progdoc.getPath(&exe.step), // getPath will ensure step dependencies are correct
    // "progdoc.zig",
    // }));

    const exe = b.addExecutable("xj", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.addPackage(pkgs.prog);
    exe.addPackage(pkgs.yazap);
    exe.addPackage(pkgs.zigString);
    exe.addPackage(pkgs.zigToml);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
