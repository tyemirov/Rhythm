# Flow Artwork

The application icon uses Katsushika Hokusai's *The Great Wave off Kanagawa*, circa 1830–32.
The Metropolitan Museum of Art identifies this image as public domain.
The Met Open Access policy permits use under CC0.

- Collection record: https://www.metmuseum.org/art/collection/search/45434
- Open Access policy: https://www.metmuseum.org/hubs/open-access
- Source image: https://images.metmuseum.org/CRDImages/as/original/DP130155.jpg
- Object number: JP1847
- Source file: `great-wave.jpg`
- SHA-256: `cbb9988f2f18b9180a1cc0cf5dbb0e3bbf8f2e85d17930cf6ca9ab36fac36303`

`scripts/generate-icons.swift` creates the application icons from this source image.
It also creates the `GreatWave` images at `1x` and `2x` for the header and History.
These images keep the colors of the source image.
The timeline marker uses the system 🌊 emoji.
The menu bar uses the Apple `water.waves` system symbol.
An active Wave shows that symbol inside a filled circle.
Pause shows pause bars.

Run `make icons` from the repository root to generate these assets again.
