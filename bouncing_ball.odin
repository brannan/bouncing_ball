package main

import b2 "vendor:box2d"
import "core:c"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600
PIXELS_PER_METER :: 50.0

PLATFORM_WIDTH_M :: 8.0
PLATFORM_HEIGHT_M :: 0.5

BALL_RADIUS_M :: 1.0

main :: proc() {
    rl.InitWindow(c.int(SCREEN_WIDTH), c.int(SCREEN_HEIGHT), "Bouncing Ball")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // 1. Create a world with gravity
    world_def := b2.DefaultWorldDef()
    world_def.gravity = b2.Vec2{0, -10}
    world_id := b2.CreateWorld(world_def)
    defer b2.DestroyWorld(world_id)

    // 2. Create a static platform to bounce on
    platform_def := b2.DefaultBodyDef()
    platform_def.position = {0, 1.0} // Bodies are just points
    platform_id := b2.CreateBody(world_id, platform_def)

    platform_shape_def := b2.DefaultShapeDef()
    platform_shape_def.material.restitution = 0.75
    platform_box := b2.MakeBox(PLATFORM_WIDTH_M * 0.5, PLATFORM_HEIGHT_M * 0.5)
    _ = b2.CreatePolygonShape(platform_id, platform_shape_def, platform_box)

    // 3. Create a dynamic body (a falling ball)
    body_def := b2.DefaultBodyDef()
    body_def.type = .dynamicBody
    body_def.position = {-1, 10}
    body_id := b2.CreateBody(world_id, body_def)

    // 4. Attach a circle shape
    shape_def := b2.DefaultShapeDef()
    shape_def.material.restitution = 0.8
    circle := b2.Circle{{0, 0}, BALL_RADIUS_M} // will use for two balls
    _ = b2.CreateCircleShape(body_id, shape_def, circle)

    // 4.1 Create a definition for a second ball
    second_body_def := b2.DefaultBodyDef()
    second_body_def.type = .dynamicBody
    second_body_def.position = {1, 10}
    second_body_id := b2.CreateBody(world_id, second_body_def)

    // 4.2 Attach a circle shape to the second ball
    second_shape_def := b2.DefaultShapeDef()
    second_shape_def.material.restitution = 0.2 // should bounce differently
    _ = b2.CreateCircleShape(second_body_id, second_shape_def, circle)

    // 5. Simulate and render until window close
    time_step: f32 = 1.0 / 60.0
    sub_steps: i32 = 4

    for !rl.WindowShouldClose() {
        b2.World_Step(world_id, time_step, sub_steps)

        ball_pos := b2.Body_GetPosition(body_id)
        second_ball_pos := b2.Body_GetPosition(second_body_id)
        platform_pos := b2.Body_GetPosition(platform_id)

        ball_x := c.int(SCREEN_WIDTH / 2) + c.int(ball_pos.x * PIXELS_PER_METER)
        ball_y := c.int(SCREEN_HEIGHT) - c.int(ball_pos.y * PIXELS_PER_METER)
        ball_radius := circle.radius * PIXELS_PER_METER

        second_ball_x := c.int(SCREEN_WIDTH / 2) + c.int(second_ball_pos.x * PIXELS_PER_METER)
        second_ball_y := c.int(SCREEN_HEIGHT) - c.int(second_ball_pos.y * PIXELS_PER_METER)

        platform_width_px := c.int(PLATFORM_WIDTH_M * PIXELS_PER_METER)
        platform_height_px := c.int(PLATFORM_HEIGHT_M * PIXELS_PER_METER)
        platform_x := c.int(SCREEN_WIDTH / 2) + c.int(platform_pos.x * PIXELS_PER_METER) - platform_width_px / 2
        platform_y := c.int(SCREEN_HEIGHT) - c.int(platform_pos.y * PIXELS_PER_METER) - platform_height_px / 2

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawRectangle(platform_x, platform_y, platform_width_px, platform_height_px, rl.DARKGRAY)
        rl.DrawCircle(ball_x, ball_y, ball_radius, rl.BLUE)
        rl.DrawCircle(second_ball_x, second_ball_y, ball_radius, rl.GREEN)

        rl.DrawText("Box2D + Raylib falling ball", 20, 20, 20, rl.BLACK)
        rl.EndDrawing()
    }
}
