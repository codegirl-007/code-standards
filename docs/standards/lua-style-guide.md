# Lua Coding Style Guide

## General Principles

- Write clear, readable code
- Prefer explicit over implicit
- Use meaningful variable and function names
- Keep functions small and focused

## Naming Conventions

- **Variables**: Use snake_case for local variables (`local my_variable`)
- **Functions**: Use snake_case for function names (`function calculate_total()`)
- **Constants**: Use UPPER_SNAKE_CASE for constants (`local MAX_RETRY = 3`)
- **Modules**: Use lowercase for module names
- **Private functions**: Prefix with underscore (`local function _private_helper()`)

## Code Organization

- One module per file
- Return a table from modules
- Group related functions together
- Put requires at the top of the file

## Best Practices

- Always use `local` for variables unless global is required
- Avoid side effects in functions when possible
- Use early returns to reduce nesting
- Add comments for complex logic
- Check for nil values before use

## Error Handling

- Validate function parameters
- Return error values when appropriate (e.g., `return nil, "error message"`)
- Use `pcall` for operations that might fail
- Provide helpful error messages

## Performance

- Avoid creating unnecessary tables in loops
- Cache frequently accessed values
- Use table.concat for string building instead of concatenation
- Profile before optimizing

