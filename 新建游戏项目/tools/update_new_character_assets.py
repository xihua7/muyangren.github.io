from pathlib import Path

from PIL import Image
from process_cutout_assets import crop_alpha, remove_background


BASE_DIR = Path(__file__).resolve().parents[1]
SOURCE_DIR = BASE_DIR / "素材"
CHARACTER_SOURCE_DIR = SOURCE_DIR / "角色"
OUT_DIR = SOURCE_DIR / "processed"
SHEEP_SHEET = "小羊.png"


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    return alpha.point(lambda value: 255 if value > 10 else 0).getbbox()


def union_bbox(paths: list[Path], padding: int) -> tuple[int, int, int, int]:
    left = top = 10**9
    right = bottom = -1
    for path in paths:
        bbox = alpha_bbox(Image.open(path))
        if bbox is None:
            raise ValueError(f"No visible pixels found in {path}")
        left = min(left, bbox[0])
        top = min(top, bbox[1])
        right = max(right, bbox[2])
        bottom = max(bottom, bbox[3])

    sample = Image.open(paths[0])
    return (
        max(0, left - padding),
        max(0, top - padding),
        min(sample.width, right + padding),
        min(sample.height, bottom + padding),
    )


def crop_scale_save(
    path: Path,
    bbox: tuple[int, int, int, int],
    out_name: str,
    target_height: int,
    resampling: Image.Resampling,
    clean_edges: bool,
) -> None:
    image = Image.open(path).convert("RGBA").crop(bbox)
    width = max(1, round(image.width * target_height / image.height))
    resized = image.resize((width, target_height), resampling)
    if clean_edges:
        resized = clean_pixel_edges(resized)
    resized.save(OUT_DIR / out_name)


def clean_pixel_edges(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    original = rgba.copy()
    original_pixels = original.load()

    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = original_pixels[x, y]
            if alpha == 0:
                continue

            touches_transparent = False
            for offset_y in range(-1, 2):
                for offset_x in range(-1, 2):
                    if offset_x == 0 and offset_y == 0:
                        continue
                    nx = x + offset_x
                    ny = y + offset_y
                    if nx < 0 or ny < 0 or nx >= width or ny >= height:
                        touches_transparent = True
                    elif original_pixels[nx, ny][3] < 32:
                        touches_transparent = True

            near_white = red > 205 and green > 205 and blue > 205
            low_contrast_gray = abs(red - green) < 18 and abs(green - blue) < 18 and red > 170

            if alpha < 180 or (touches_transparent and (near_white or low_contrast_gray)):
                pixels[x, y] = (0, 0, 0, 0)
                continue

            if 180 <= alpha < 255:
                pixels[x, y] = (red, green, blue, 255)

    return rgba


def source_path(name: str) -> Path:
    root_path = SOURCE_DIR / name
    if root_path.exists():
        return root_path
    return CHARACTER_SOURCE_DIR / name


def process_group(
    source_names: list[str],
    out_names: list[str],
    target_height: int,
    padding: int = 18,
    resampling: Image.Resampling = Image.Resampling.NEAREST,
    clean_edges: bool = True,
) -> None:
    paths = [source_path(name) for name in source_names]
    bbox = union_bbox(paths, padding)
    for path, out_name in zip(paths, out_names):
        crop_scale_save(path, bbox, out_name, target_height, resampling, clean_edges)


def process_sheep_sheet_cell(out_name: str, col: int, row: int, target_height: int) -> None:
    sheet = remove_background(source_path(SHEEP_SHEET), threshold=62, padding=0)
    cell_width = sheet.width / 5.0
    cell_height = sheet.height / 3.0
    rect = (
        round(col * cell_width),
        round(row * cell_height),
        round((col + 1) * cell_width),
        round((row + 1) * cell_height),
    )
    sprite = crop_alpha(sheet, rect, padding=8)
    width = max(1, round(sprite.width * target_height / sprite.height))
    sprite.resize((width, target_height), Image.Resampling.LANCZOS).save(OUT_DIR / out_name)


def main() -> None:
    OUT_DIR.mkdir(exist_ok=True)
    process_group(["牧羊人站立.png"], ["shepherd_stand.png"], 208, resampling=Image.Resampling.LANCZOS)
    process_group(["牧羊人休息.png"], ["shepherd_rest.png"], 176, resampling=Image.Resampling.LANCZOS)
    process_group(
        ["赶路1.png", "赶路2.png", "赶路3.png", "赶路4.png"],
        [
            "shepherd_travel_walk_0.png",
            "shepherd_travel_walk_1.png",
            "shepherd_travel_walk_2.png",
            "shepherd_travel_walk_3.png",
        ],
        208,
        resampling=Image.Resampling.LANCZOS,
    )
    process_group(
        ["睡觉1.png", "睡觉2.png", "睡觉3.png"],
        ["shepherd_sleep_0.png", "shepherd_sleep_1.png", "shepherd_sleep_2.png"],
        160,
        resampling=Image.Resampling.LANCZOS,
    )
    process_group(
        ["小羊睡觉1.png", "小羊睡觉2.png", "小羊睡觉3.png"],
        ["sheep_sleep_0.png", "sheep_sleep_1.png", "sheep_sleep_2.png"],
        136,
        padding=10,
        resampling=Image.Resampling.LANCZOS,
    )
    process_sheep_sheet_cell("sheep_graze_right.png", col=1, row=1, target_height=136)
    process_group(
        ["小羊走路1.png", "小羊走路2.png", "小羊走路3.png"],
        ["sheep_walk_0.png", "sheep_walk_1.png", "sheep_walk_2.png"],
        112,
        padding=14,
        resampling=Image.Resampling.LANCZOS,
    )
    process_group(
        ["小羊奔跑1.png", "小羊奔跑2.png", "小羊奔跑3.png", "小羊奔跑4.png", "小羊奔跑5.png"],
        ["sheep_run_0.png", "sheep_run_1.png", "sheep_run_2.png", "sheep_run_3.png", "sheep_run_4.png"],
        128,
        padding=14,
        resampling=Image.Resampling.LANCZOS,
    )

    # Keep legacy single-frame paths valid for any existing scene/import metadata.
    Image.open(OUT_DIR / "shepherd_sleep_0.png").save(OUT_DIR / "shepherd_sleep.png")
    Image.open(OUT_DIR / "sheep_sleep_0.png").save(OUT_DIR / "sheep_sleep.png")
    Image.open(OUT_DIR / "sheep_walk_0.png").save(OUT_DIR / "sheep_walk_right.png")
    Image.open(OUT_DIR / "sheep_run_0.png").save(OUT_DIR / "sheep_run_right.png")


if __name__ == "__main__":
    main()
