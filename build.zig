const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const itertools = b.addModule("itertools", .{
        .root_source_file = b.path("src/itertools.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_tests = b.addTest(.{
        .root_source_file = b.path("src/itertools.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_tests.root_module.addImport("itertools", itertools);

    const run_unit_tests = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
