# Bouncing Ball Example

This is a simple example demonstrating the use of Box2D and Raylib to create a bouncing ball simulation in Odin.

## Dependencies
- Box2D (vendor:box2d)
- Raylib (vendor:raylib)

## Running the Program
1. Ensure you have the necessary dependencies installed.
2. Build and run the program using your preferred Odin build system.

```sh
odin build main.odin
./main
```

## Description
The program initializes a window using Raylib and sets up a physics world using Box2D. Two balls with different restitution coefficients are created, and they bounce off a platform at the bottom of the screen. The simulation runs at 60 frames per second.

## Files
- `main.odin`: Main source file containing the bouncing ball simulation.