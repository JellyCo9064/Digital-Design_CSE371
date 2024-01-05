
def draw(x0, y0, x1, y1):
    is_steep = abs(y1 - y0) > abs(x1 - x0)
    if (is_steep):
        x0,y0 = (y0, x0)
        x1,y1 = (y1, x1)
    
    if (x0 > x1):
        x0,x1 = (x1, x0)
        y0,y1 = (y1, y0)

    delta_x = x1 - x0
    delta_y = abs(y1 - y0)
    error = int(-(delta_x / 2))

    print((delta_x, delta_y, error))

    y = y0

    y_step = 1
    if (y0 < y1):
        y_step = 1
    else:
        y_step = -1

    for x in range(x0, x1 + 1):
        if (is_steep):
            print((y, x))
        else:
            print((x, y))

        error += delta_y

        if (error >= 0):
            y += y_step
            error -= delta_x


if (__name__ == "__main__"):
    x0,y0,x1,y1 = map(int, input().split(" "))
    draw(x0, y0, x1, y1)