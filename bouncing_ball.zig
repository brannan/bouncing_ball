const std = @import("std");

const SCREEN_WIDTH: c_int = 800;
const SCREEN_HEIGHT: c_int = 600;
const PIXELS_PER_METER: f32 = 50.0;

const PLATFORM_WIDTH_M: f32 = 8.0;
const PLATFORM_HEIGHT_M: f32 = 0.5;

const BALL_RADIUS_M: f32 = 1.0;

const Color = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

const RAYWHITE = Color{ .r = 245, .g = 245, .b = 245, .a = 255 };
const DARKGRAY = Color{ .r = 80, .g = 80, .b = 80, .a = 255 };
const BLUE = Color{ .r = 0, .g = 121, .b = 241, .a = 255 };
const GREEN = Color{ .r = 0, .g = 228, .b = 48, .a = 255 };
const BLACK = Color{ .r = 0, .g = 0, .b = 0, .a = 255 };

extern fn InitWindow(width: c_int, height: c_int, title: [*:0]const u8) void;
extern fn WindowShouldClose() bool;
extern fn CloseWindow() void;
extern fn SetTargetFPS(fps: c_int) void;
extern fn BeginDrawing() void;
extern fn EndDrawing() void;
extern fn ClearBackground(color: Color) void;
extern fn DrawRectangle(posX: c_int, posY: c_int, width: c_int, height: c_int, color: Color) void;
extern fn DrawCircle(centerX: c_int, centerY: c_int, radius: f32, color: Color) void;
extern fn DrawText(text: [*:0]const u8, posX: c_int, posY: c_int, fontSize: c_int, color: Color) void;

const Vec2 = extern struct {
    x: f32,
    y: f32,
};

const Rot = extern struct {
    c: f32,
    s: f32,
};

const WorldId = extern struct {
    index1: u16,
    generation: u16,
};

const BodyId = extern struct {
    index1: i32,
    world0: u16,
    generation: u16,
};

const ShapeId = extern struct {
    index1: i32,
    world0: u16,
    generation: u16,
};

const BodyType = enum(c_int) {
    staticBody = 0,
    kinematicBody = 1,
    dynamicBody = 2,
};

const WorldDef = extern struct {
    gravity: Vec2,
    restitutionThreshold: f32,
    hitEventThreshold: f32,
    contactHertz: f32,
    contactDampingRatio: f32,
    maxContactPushSpeed: f32,
    maximumLinearSpeed: f32,
    frictionCallback: ?*const anyopaque,
    restitutionCallback: ?*const anyopaque,
    enableSleep: bool,
    enableContinuous: bool,
    workerCount: i32,
    enqueueTask: ?*const anyopaque,
    finishTask: ?*const anyopaque,
    userTaskContext: ?*anyopaque,
    userData: ?*anyopaque,
    internalValue: i32,
};

const BodyDef = extern struct {
    type: BodyType,
    position: Vec2,
    rotation: Rot,
    linearVelocity: Vec2,
    angularVelocity: f32,
    linearDamping: f32,
    angularDamping: f32,
    gravityScale: f32,
    sleepThreshold: f32,
    name: ?[*:0]const u8,
    userData: ?*anyopaque,
    enableSleep: bool,
    isAwake: bool,
    fixedRotation: bool,
    isBullet: bool,
    isEnabled: bool,
    allowFastRotation: bool,
    internalValue: i32,
};

const SurfaceMaterial = extern struct {
    friction: f32,
    restitution: f32,
    rollingResistance: f32,
    tangentSpeed: f32,
    userMaterialId: i32,
    customColor: u32,
};

const Filter = extern struct {
    categoryBits: u64,
    maskBits: u64,
    groupIndex: i32,
};

const ShapeDef = extern struct {
    userData: ?*anyopaque,
    material: SurfaceMaterial,
    density: f32,
    filter: Filter,
    isSensor: bool,
    enableSensorEvents: bool,
    enableContactEvents: bool,
    enableHitEvents: bool,
    enablePreSolveEvents: bool,
    invokeContactCreation: bool,
    updateBodyMass: bool,
    internalValue: i32,
};

const Circle = extern struct {
    center: Vec2,
    radius: f32,
};

const Polygon = extern struct {
    vertices: [8]Vec2,
    normals: [8]Vec2,
    centroid: Vec2,
    radius: f32,
    count: c_int,
};

extern fn b2DefaultWorldDef() WorldDef;
extern fn b2DefaultBodyDef() BodyDef;
extern fn b2DefaultShapeDef() ShapeDef;
extern fn b2MakeBox(halfWidth: f32, halfHeight: f32) Polygon;
extern fn b2CreateWorld(def: *const WorldDef) WorldId;
extern fn b2DestroyWorld(worldId: WorldId) void;
extern fn b2World_Step(worldId: WorldId, timeStep: f32, subStepCount: c_int) void;
extern fn b2CreateBody(worldId: WorldId, def: *const BodyDef) BodyId;
extern fn b2Body_GetPosition(bodyId: BodyId) Vec2;
extern fn b2CreateCircleShape(bodyId: BodyId, def: *const ShapeDef, circle: *const Circle) ShapeId;
extern fn b2CreatePolygonShape(bodyId: BodyId, def: *const ShapeDef, polygon: *const Polygon) ShapeId;

pub fn main() void {
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Bouncing Ball");
    defer CloseWindow();
    SetTargetFPS(60);

    const world_id = createWorld();
    defer b2DestroyWorld(world_id);

    const platform_id = createPlatform(world_id);
    const body_ids = createBodies(world_id);

    const time_step: f32 = 1.0 / 60.0;
    const sub_steps: c_int = 4;

    while (!WindowShouldClose()) {
        b2World_Step(world_id, time_step, sub_steps);

        BeginDrawing();
        ClearBackground(RAYWHITE);
        drawPlatform(platform_id);
        drawBalls(&body_ids);
        DrawText("Box2D + Raylib falling ball", 20, 20, 20, BLACK);
        EndDrawing();
    }
}

fn createWorld() WorldId {
    var world_def = b2DefaultWorldDef();
    world_def.gravity = Vec2{ .x = 0, .y = -10 };
    return b2CreateWorld(&world_def);
}

fn createPlatform(world_id: WorldId) BodyId {
    var platform_def = b2DefaultBodyDef();
    platform_def.position = Vec2{ .x = 0, .y = 1.0 };
    const platform_id = b2CreateBody(world_id, &platform_def);

    var platform_shape_def = b2DefaultShapeDef();
    platform_shape_def.material.restitution = 0.75;
    platform_shape_def.material.friction = 0.75;
    const platform_box = b2MakeBox(PLATFORM_WIDTH_M * 0.5, PLATFORM_HEIGHT_M * 0.5);
    _ = b2CreatePolygonShape(platform_id, &platform_shape_def, &platform_box);

    return platform_id;
}

fn createBodies(world_id: WorldId) [2]BodyId {
    var body_ids: [2]BodyId = undefined;

    var body_def = b2DefaultBodyDef();
    body_def.type = .dynamicBody;
    body_def.position = Vec2{ .x = -1, .y = 10 };
    body_ids[0] = b2CreateBody(world_id, &body_def);

    var shape_def = b2DefaultShapeDef();
    shape_def.material.restitution = 0.8;
    const circle = Circle{ .center = Vec2{ .x = 0, .y = 0 }, .radius = BALL_RADIUS_M };
    _ = b2CreateCircleShape(body_ids[0], &shape_def, &circle);

    var second_body_def = b2DefaultBodyDef();
    second_body_def.type = .dynamicBody;
    second_body_def.position = Vec2{ .x = 1, .y = 10 };
    body_ids[1] = b2CreateBody(world_id, &second_body_def);

    var second_shape_def = b2DefaultShapeDef();
    second_shape_def.material.restitution = 0.2;
    _ = b2CreateCircleShape(body_ids[1], &second_shape_def, &circle);

    return body_ids;
}

fn drawPlatform(platform_id: BodyId) void {
    const platform_pos = b2Body_GetPosition(platform_id);
    const platform_width_px: c_int = @intFromFloat(PLATFORM_WIDTH_M * PIXELS_PER_METER);
    const platform_height_px: c_int = @intFromFloat(PLATFORM_HEIGHT_M * PIXELS_PER_METER);

    DrawRectangle(
        SCREEN_WIDTH / 2 + metersToPixels(platform_pos.x) - @divTrunc(platform_width_px, 2),
        SCREEN_HEIGHT - metersToPixels(platform_pos.y) - @divTrunc(platform_height_px, 2),
        platform_width_px,
        platform_height_px,
        DARKGRAY,
    );
}

fn drawBalls(body_ids: []const BodyId) void {
    const ball_radius = BALL_RADIUS_M * PIXELS_PER_METER;

    for (body_ids, 0..) |body_id, i| {
        const body_pos = b2Body_GetPosition(body_id);
        const ball_x = SCREEN_WIDTH / 2 + metersToPixels(body_pos.x);
        const ball_y = SCREEN_HEIGHT - metersToPixels(body_pos.y);

        if (i == 0) {
            DrawCircle(ball_x, ball_y, ball_radius, BLUE);
        } else if (i == 1) {
            DrawCircle(ball_x, ball_y, ball_radius, GREEN);
        }
    }
}

fn metersToPixels(meters: f32) c_int {
    return @intFromFloat(meters * PIXELS_PER_METER);
}
