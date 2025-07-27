const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_itertools = b.addModule("zig_itertools", .{
        .root_source_file = b.path("src/zig_itertools.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_module = b.addModule("zig_itertools_test", .{
        .root_source_file = b.path("tests/tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_tests = b.addTest(.{ .root_module = test_module });

    lib_tests.root_module.addImport("zig_itertools", zig_itertools);

    const run_unit_tests = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}