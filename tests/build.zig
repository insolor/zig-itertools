const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const test_module = b.addModule("zig_itertools_test", .{
        .root_source_file = b.path("tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    const integration_tests = b.addTest(.{ .root_module = test_module });

    const zig_itertools = b.dependency("zig_itertools", .{});
    integration_tests.root_module.addImport("zig_itertools", zig_itertools.module("zig_itertools"));

    const run_lib_unit_tests = b.addRunArtifact(integration_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}