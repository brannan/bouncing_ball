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

    world_id := createWorld()
    defer b2.DestroyWorld(world_id)
    platform_id := createPlatform(world_id)
    body_ids := createBodies(world_id)
    time_step: f32 = 1.0 / 60.0
    sub_steps: i32 = 4

    for !rl.WindowShouldClose() {
        b2.World_Step(world_id, time_step, sub_steps)

        ball_pos := b2.Body_GetPosition(body_ids[0])
        second_ball_pos := b2.Body_GetPosition(body_ids[1])
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        drawPlatform(platform_id)
        drawBalls(body_ids, ball_pos, second_ball_pos)
        rl.DrawText("Box2D + Raylib falling ball", 20, 20, 20, rl.BLACK)
        rl.EndDrawing()
    }
}

createWorld :: proc() -> b2.WorldId {
    world_def := b2.DefaultWorldDef()
    world_def.gravity = b2.Vec2{0, -10}
    return b2.CreateWorld(world_def)
}

createPlatform :: proc(world_id: b2.WorldId) -> b2.BodyId {
    platform_def := b2.DefaultBodyDef()
    platform_def.position = {0, 1.0}
    platform_id := b2.CreateBody(world_id, platform_def)

    platform_shape_def := b2.DefaultShapeDef()
    platform_shape_def.material.restitution = 0.75
    platform_shape_def.friction = 0.3
    platform_box := b2.MakeBox(PLATFORM_WIDTH_M * 0.5, PLATFORM_HEIGHT_M * 0.5)
    _ = b2.CreatePolygonShape(platform_id, platform_shape_def, platform_box)

    return platform_id
}

createBodies :: proc(world_id: b2.WorldId) -> []b2.BodyId {
    body_ids := make([]b2.BodyId, 2)

    body_def := b2.DefaultBodyDef()
    body_def.type = .dynamicBody
    body_def.position = {-1, 10}
    body_ids[0] = b2.CreateBody(world_id, body_def)

    shape_def := b2.DefaultShapeDef()
    shape_def.material.restitution = 0.8
    circle := b2.Circle{{0, 0}, BALL_RADIUS_M}
    _ = b2.CreateCircleShape(body_ids[0], shape_def, circle)

    // If they're all balls, we need an addBall function that accepts a 
    // position, restitution, and radius. 
    second_body_def := b2.DefaultBodyDef()
    second_body_def.type = .dynamicBody
    second_body_def.position = {1, 10}
    body_ids[1] = b2.CreateBody(world_id, second_body_def)

    second_shape_def := b2.DefaultShapeDef()
    second_shape_def.material.restitution = 0.2
    _ = b2.CreateCircleShape(body_ids[1], second_shape_def, circle)

    return body_ids
}

drawPlatform :: proc(platform_id: b2.BodyId) {
    platform_pos := b2.Body_GetPosition(platform_id)
    platform_width_px := c.int(PLATFORM_WIDTH_M * PIXELS_PER_METER)
    platform_height_px := c.int(PLATFORM_HEIGHT_M * PIXELS_PER_METER)

    rl.DrawRectangle(
        c.int(SCREEN_WIDTH / 2) + c.int(platform_pos.x * PIXELS_PER_METER) - platform_width_px / 2,
        c.int(SCREEN_HEIGHT) - c.int(platform_pos.y * PIXELS_PER_METER) - platform_height_px / 2,
        platform_width_px,
        platform_height_px,
        rl.DARKGRAY
    )
}

drawBalls :: proc(body_ids: []b2.BodyId, ball_pos: b2.Vec2, second_ball_pos: b2.Vec2) {
    ball_radius := BALL_RADIUS_M * PIXELS_PER_METER

    for i in 0..<len(body_ids) {
        body_pos := b2.Body_GetPosition(body_ids[i])
        ball_x := c.int(SCREEN_WIDTH / 2) + c.int(body_pos.x * PIXELS_PER_METER)
        ball_y := c.int(SCREEN_HEIGHT) - c.int(body_pos.y * PIXELS_PER_METER)

        if i == 0 {
            rl.DrawCircle(ball_x, ball_y, f32(ball_radius), rl.BLUE)
        } else if i == 1 {
            rl.DrawCircle(ball_x, ball_y, f32(ball_radius), rl.GREEN)
        }
    }
}

