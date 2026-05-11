package main

import b2 "vendor:box2d"
import "core:c"
import rl "vendor:raylib"

main :: proc() {
    screen_width: c.int = 800
    screen_height: c.int = 600
    pixels_per_meter: f32 = 50.0

    rl.InitWindow(screen_width, screen_height, "Falling Ball")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // 1. Create a world with gravity
    world_def := b2.DefaultWorldDef()
    world_def.gravity = b2.Vec2{0, -10}
    world_id := b2.CreateWorld(world_def)
    defer b2.DestroyWorld(world_id)

    // 2. Create a static platform to bounce on
    platform_def := b2.DefaultBodyDef()
    platform_def.position = {0, 4.5}
    platform_id := b2.CreateBody(world_id, platform_def)

    platform_shape_def := b2.DefaultShapeDef()
    platform_shape_def.material.restitution = 0.8
    platform_box := b2.MakeBox(4.0, 0.25)
    _ = b2.CreatePolygonShape(platform_id, platform_shape_def, platform_box)

    // 3. Create a dynamic body (a falling ball)
    body_def := b2.DefaultBodyDef()
    body_def.type = .dynamicBody
    body_def.position = {0, 10}
    body_id := b2.CreateBody(world_id, body_def)

    // 4. Attach a circle shape
    shape_def := b2.DefaultShapeDef()
    shape_def.material.restitution = 0.8
    circle := b2.Circle{{0, 0}, 1.0}
    _ = b2.CreateCircleShape(body_id, shape_def, circle)

    // 5. Simulate and render until window close
    time_step: f32 = 1.0 / 60.0
    sub_steps: i32 = 4

    for !rl.WindowShouldClose() {
        b2.World_Step(world_id, time_step, sub_steps)

        ball_pos := b2.Body_GetPosition(body_id)
        platform_pos := b2.Body_GetPosition(platform_id)

        ball_x := c.int(screen_width / 2) + c.int(ball_pos.x * pixels_per_meter)
        ball_y := c.int(screen_height) - c.int(ball_pos.y * pixels_per_meter)
        ball_radius := circle.radius * pixels_per_meter

        platform_width_px := c.int(8.0 * pixels_per_meter)
        platform_height_px := c.int(0.5 * pixels_per_meter)
        platform_x := c.int(screen_width / 2) + c.int(platform_pos.x * pixels_per_meter) - platform_width_px / 2
        platform_y := c.int(screen_height) - c.int(platform_pos.y * pixels_per_meter) - platform_height_px / 2

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawRectangle(platform_x, platform_y, platform_width_px, platform_height_px, rl.DARKGRAY)
        rl.DrawCircle(ball_x, ball_y, ball_radius, rl.BLUE)
        rl.DrawText("Box2D + Raylib falling ball", 20, 20, 20, rl.BLACK)
        rl.EndDrawing()
    }
}
