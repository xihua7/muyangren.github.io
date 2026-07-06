from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path.cwd()
SOURCE_DIR = ROOT / "\u7d20\u6750"
OUT_DIR = SOURCE_DIR / "processed"

SHEEP_SHEET = "\u5c0f\u7f8a.png"
SHEPHERD_SOURCES = {
    "stand": "\u7267\u7f8a\u4eba\u7ad9\u7acb.png",
    "travel": "\u7267\u7f8a\u4eba\u8d76\u8def.png",
    "rest": "\u7267\u7f8a\u4eba\u4f11\u606f.png",
    "sleep": "\u7267\u7f8a\u4eba\u7761\u89c9.png",
}

SHEEP_CELLS = [
    ("sheep_run_right.png", 4, 0),
    ("sheep_graze_right.png", 1, 1),
    ("sheep_sleep.png", 0, 2),
    ("sheep_walk_right.png", 1, 2),
]

TRAVEL_LIMB_REGIONS = {
    "front_arm": (1, 22, 14, 31),
    "front_leg": (8, 31, 15, 49),
    "rear_leg": (17, 34, 25, 50),
}

TRAVEL_FRAME_SHIFTS = [
    {},
    {"front_arm": (1, 0), "front_leg": (-2, 0), "rear_leg": (1, -1)},
    {},
    {"front_arm": (-1, 0), "front_leg": (1, -1), "rear_leg": (-2, 0)},
]


def color_distance(a, b):
    return sum((int(a[i]) - int(b[i])) ** 2 for i in range(3)) ** 0.5


def background_color(image):
    width, height = image.size
    samples = []
    for x in range(width):
        samples.append(image.getpixel((x, 0))[:3])
        samples.append(image.getpixel((x, height - 1))[:3])
    for y in range(height):
        samples.append(image.getpixel((0, y))[:3])
        samples.append(image.getpixel((width - 1, y))[:3])

    samples.sort(key=lambda c: c[0] + c[1] + c[2])
    mid = samples[len(samples) // 4 : len(samples) * 3 // 4]
    return tuple(sum(c[i] for c in mid) // len(mid) for i in range(3))


def flood_background(image, threshold):
    width, height = image.size
    bg = background_color(image)
    pixels = image.load()
    transparent = bytearray(width * height)
    queue = deque()

    def is_bg(x, y):
        r, g, b = pixels[x, y][:3]
        bright = (int(r) + int(g) + int(b)) / 3.0
        chroma = max(r, g, b) - min(r, g, b)
        return color_distance((r, g, b), bg) <= threshold or (bright > 218 and chroma < 20)

    def push(x, y):
        index = y * width + x
        if transparent[index] or not is_bg(x, y):
            return
        transparent[index] = 1
        queue.append((x, y))

    for x in range(width):
        push(x, 0)
        push(x, height - 1)
    for y in range(height):
        push(0, y)
        push(width - 1, y)

    while queue:
        x, y = queue.popleft()
        if x > 0:
            push(x - 1, y)
        if x < width - 1:
            push(x + 1, y)
        if y > 0:
            push(x, y - 1)
        if y < height - 1:
            push(x, y + 1)

    return transparent


def remove_background(path, threshold=58, padding=6):
    source = Image.open(path).convert("RGBA")
    width, height = source.size
    transparent = flood_background(source, threshold)
    pixels = source.load()

    for y in range(height):
        for x in range(width):
            if transparent[y * width + x]:
                r, g, b, _a = pixels[x, y]
                pixels[x, y] = (r, g, b, 0)

    bbox = source.getbbox()
    if bbox is None:
        raise RuntimeError(f"No subject found in {path}")

    left, top, right, bottom = bbox
    left = max(left - padding, 0)
    top = max(top - padding, 0)
    right = min(right + padding, width)
    bottom = min(bottom + padding, height)
    return source.crop((left, top, right, bottom))


def crop_alpha(image, rect, padding):
    left, top, right, bottom = rect
    cell = image.crop((left, top, right, bottom))
    bbox = cell.getbbox()
    if bbox is None:
        raise RuntimeError(f"Empty sheep cell {rect}")

    bx0, by0, bx1, by1 = bbox
    bx0 = max(bx0 - padding, 0)
    by0 = max(by0 - padding, 0)
    bx1 = min(bx1 + padding, cell.width)
    by1 = min(by1 + padding, cell.height)
    return cell.crop((bx0, by0, bx1, by1))


def resize_by_scale(image, scale):
    width = max(1, round(image.width * scale))
    height = max(1, round(image.height * scale))
    return image.resize((width, height), Image.Resampling.NEAREST)


def make_sprite(image, target_height):
    scale = target_height / image.height
    width = max(1, round(image.width * scale))
    return image.resize((width, target_height), Image.Resampling.NEAREST)


def make_alpha_mask(image, rect):
    left, top, right, bottom = rect
    mask = Image.new("L", image.size, 0)
    source_pixels = image.load()
    mask_pixels = mask.load()
    for y in range(top, bottom):
        for x in range(left, right):
            if source_pixels[x, y][3] > 0:
                mask_pixels[x, y] = 255
    return mask


def make_shifted_travel_frame(base, masks, shifts):
    if not shifts:
        return base.copy()

    frame = base.copy()
    frame_pixels = frame.load()
    for name in shifts:
        mask_pixels = masks[name].load()
        for y in range(base.height):
            for x in range(base.width):
                if mask_pixels[x, y]:
                    frame_pixels[x, y] = (0, 0, 0, 0)

    for name, offset in shifts.items():
        dx, dy = offset
        part = Image.new("RGBA", base.size, (0, 0, 0, 0))
        part.paste(base, (dx, dy), masks[name])
        frame.alpha_composite(part)

    return frame


def save_travel_animation_frames(travel_sprite):
    masks = {
        name: make_alpha_mask(travel_sprite, rect)
        for name, rect in TRAVEL_LIMB_REGIONS.items()
    }
    for index, shifts in enumerate(TRAVEL_FRAME_SHIFTS):
        frame = make_shifted_travel_frame(travel_sprite, masks, shifts)
        out_name = f"shepherd_travel_walk_{index}.png"
        frame.save(OUT_DIR / out_name)
        print(f"{out_name} {frame.size}")


def process_sheep_sheet():
    sheet = remove_background(SOURCE_DIR / SHEEP_SHEET, threshold=62, padding=0)

    cell_width = sheet.width / 5.0
    cell_height = sheet.height / 3.0
    base_rect = (
        round(0 * cell_width),
        round(0 * cell_height),
        round(1 * cell_width),
        round(1 * cell_height),
    )
    base_cell = crop_alpha(sheet, base_rect, padding=8)
    scale = 34.0 / base_cell.height

    for filename, col, row in SHEEP_CELLS:
        rect = (
            round(col * cell_width),
            round(row * cell_height),
            round((col + 1) * cell_width),
            round((row + 1) * cell_height),
        )
        sprite = resize_by_scale(crop_alpha(sheet, rect, padding=8), scale)
        sprite.save(OUT_DIR / filename)
        print(f"{filename} {sprite.size}")


def process_shepherd():
    cutouts = {
        state: remove_background(SOURCE_DIR / filename, threshold=60, padding=6)
        for state, filename in SHEPHERD_SOURCES.items()
    }
    scale = 52.0 / cutouts["stand"].height

    for state, cutout in cutouts.items():
        sprite = resize_by_scale(cutout, scale)
        out_name = f"shepherd_{state}.png"
        sprite.save(OUT_DIR / out_name)
        print(f"{out_name} {sprite.size}")
        if state == "travel":
            save_travel_animation_frames(sprite)

    cutouts["stand"].save(OUT_DIR / "shepherd_cutout_full.png")
    resize_by_scale(cutouts["stand"], scale).save(OUT_DIR / "shepherd_sprite.png")


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    process_sheep_sheet()
    process_shepherd()


if __name__ == "__main__":
    main()
