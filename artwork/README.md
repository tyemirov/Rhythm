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

`scripts/generate-icons.swift` creates the application icon sizes from this source image.
It also creates the wave crest PDF for the menu bar and application views.
The crest is a simplified drawing of the Great Wave shape.
The asset catalog keeps the PDF as a template image.

Run `make icons` from the repository root to generate these assets again.
