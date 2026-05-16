const rl = @cImport({
    @cInclude("raylib.h");
});

const b2 = @cImport({
    @cInclude("box2d/box2d.h");
});

const SCREEN_WIDTH: c_int = 800;
const SCREEN_HEIGHT: c_int = 600;
const PIXELS_PER_METER: f32 = 50.0;

const PLATFORM_WIDTH_M: f32 = 8.0;
const PLATFORM_HEIGHT_M: f32 = 0.5;

const BALL_RADIUS_M: f32 = 1.0;

pub fn main() void {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Bouncing Ball");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    const world_id = createWorld();
    defer b2.b2DestroyWorld(world_id);

    const platform_id = createPlatform(world_id);
    const body_ids = createBodies(world_id);

    const time_step: f32 = 1.0 / 60.0;
    const sub_steps: c_int = 4;

    while (!rl.WindowShouldClose()) {
        b2.b2World_Step(world_id, time_step, sub_steps);

        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);
        drawPlatform(platform_id);
        drawBalls(&body_ids);
        rl.DrawText("Box2D + Raylib falling ball", 20, 20, 20, rl.BLACK);
        rl.EndDrawing();
    }
}

fn createWorld() b2.b2WorldId {
    var world_def = b2.b2DefaultWorldDef();
    world_def.gravity = b2.b2Vec2{ .x = 0, .y = -10 };
    return b2.b2CreateWorld(&world_def);
}

fn createPlatform(world_id: b2.b2WorldId) b2.b2BodyId {
    var platform_def = b2.b2DefaultBodyDef();
    platform_def.position = b2.b2Vec2{ .x = 0, .y = 1.0 };
    const platform_id = b2.b2CreateBody(world_id, &platform_def);

    var platform_shape_def = b2.b2DefaultShapeDef();
    platform_shape_def.material.restitution = 0.75;
    platform_shape_def.material.friction = 0.75;
    const platform_box = b2.b2MakeBox(PLATFORM_WIDTH_M * 0.5, PLATFORM_HEIGHT_M * 0.5);
    _ = b2.b2CreatePolygonShape(platform_id, &platform_shape_def, &platform_box);

    return platform_id;
}

fn createBodies(world_id: b2.b2WorldId) [2]b2.b2BodyId {
    var body_ids: [2]b2.b2BodyId = undefined;

    var body_def = b2.b2DefaultBodyDef();
    body_def.type = b2.b2_dynamicBody;
    body_def.position = b2.b2Vec2{ .x = -1, .y = 10 };
    body_ids[0] = b2.b2CreateBody(world_id, &body_def);

    var shape_def = b2.b2DefaultShapeDef();
    shape_def.material.restitution = 0.8;
    const circle = b2.b2Circle{
        .center = b2.b2Vec2{ .x = 0, .y = 0 },
        .radius = BALL_RADIUS_M,
    };
    _ = b2.b2CreateCircleShape(body_ids[0], &shape_def, &circle);

    var second_body_def = b2.b2DefaultBodyDef();
    second_body_def.type = b2.b2_dynamicBody;
    second_body_def.position = b2.b2Vec2{ .x = 1, .y = 10 };
    body_ids[1] = b2.b2CreateBody(world_id, &second_body_def);

    var second_shape_def = b2.b2DefaultShapeDef();
    second_shape_def.material.restitution = 0.2;
    _ = b2.b2CreateCircleShape(body_ids[1], &second_shape_def, &circle);

    return body_ids;
}

fn drawPlatform(platform_id: b2.b2BodyId) void {
    const platform_pos = b2.b2Body_GetPosition(platform_id);
    const platform_width_px: c_int = @intFromFloat(PLATFORM_WIDTH_M * PIXELS_PER_METER);
    const platform_height_px: c_int = @intFromFloat(PLATFORM_HEIGHT_M * PIXELS_PER_METER);

    rl.DrawRectangle(
        SCREEN_WIDTH / 2 + metersToPixels(platform_pos.x) - @divTrunc(platform_width_px, 2),
        SCREEN_HEIGHT - metersToPixels(platform_pos.y) - @divTrunc(platform_height_px, 2),
        platform_width_px,
        platform_height_px,
        rl.DARKGRAY,
    );
}

fn drawBalls(body_ids: []const b2.b2BodyId) void {
    const ball_radius = BALL_RADIUS_M * PIXELS_PER_METER;

    for (body_ids, 0..) |body_id, i| {
        const body_pos = b2.b2Body_GetPosition(body_id);
        const ball_x = SCREEN_WIDTH / 2 + metersToPixels(body_pos.x);
        const ball_y = SCREEN_HEIGHT - metersToPixels(body_pos.y);

        if (i == 0) {
            rl.DrawCircle(ball_x, ball_y, ball_radius, rl.BLUE);
        } else if (i == 1) {
            rl.DrawCircle(ball_x, ball_y, ball_radius, rl.GREEN);
        }
    }
}

fn metersToPixels(meters: f32) c_int {
    return @intFromFloat(meters * PIXELS_PER_METER);
}
