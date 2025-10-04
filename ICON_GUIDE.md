# Icon and Logo Guide

## Current Status

The add-on currently uses placeholder icons copied from the Open WebUI add-on. You should replace these with MCPO-specific branding.

## Files to Replace

- `mcpo/icon.png` - Square icon, 96x96px or larger
- `mcpo/logo.png` - Wide logo, any size (commonly 256x64px or similar)

## Design Suggestions

### Concept Ideas

MCPO bridges MCP (Model Context Protocol) to OpenAPI, so the icon should represent:

1. **Bridge/Connection Theme**
   - Two connected nodes
   - Arrow going from MCP → OpenAPI
   - Plug/socket connection

2. **Protocol Translation Theme**
   - Gears/cogs (transformation)
   - Translator symbol
   - Pipeline/flow diagram

3. **Proxy Theme**
   - Relay/repeater
   - Router symbol
   - Middleman concept

4. **Simple Text-Based**
   - "MCPO" text in modern font
   - "MCP→API" with arrow
   - Monogram style

### Color Scheme

Consider colors that represent:
- **Tech/Modern**: Blues, purples, teals
- **Reliability**: Grays, navy
- **Energy**: Oranges, bright blues
- **Home Assistant**: Match HA's blue theme

### Design Tools

#### Free Online Tools
1. **Canva** (canva.com) - Easy drag-and-drop
2. **Figma** (figma.com) - Professional design tool
3. **Photopea** (photopea.com) - Photoshop alternative
4. **GIMP** (gimp.org) - Open source image editor

#### Icon Libraries
1. **Font Awesome** (fontawesome.com) - Free icons
2. **Heroicons** (heroicons.com) - Clean, modern icons
3. **Material Icons** (fonts.google.com/icons) - Google's icon set
4. **Lucide** (lucide.dev) - Beautiful icon library

#### AI Tools
1. **Microsoft Designer** - Generate icons with AI
2. **Canva AI** - AI-powered design
3. **DALL-E** - Generate custom artwork

## Quick Solutions

### Option 1: Simple Text Icon

Create a simple PNG with:
- Background color (e.g., #3B82F6 blue)
- White text "MCPO"
- Clean sans-serif font

```
+------------------+
|                  |
|      MCPO        |
|                  |
+------------------+
```

### Option 2: Use Existing MCP Logo

The MCP specification has logos:
- Visit: https://modelcontextprotocol.io/
- Download their logo
- Add "→API" or similar text
- Ensure licensing allows derivative works

### Option 3: Commission Design

If you want professional branding:
- **Fiverr** - $5-50 for simple icon design
- **99designs** - Logo contests
- **Upwork** - Hire a designer

### Option 4: Use Free Icon + Customize

1. Find a suitable icon (e.g., connection/plug icon)
2. Download in PNG format
3. Overlay "MCPO" text
4. Export in required sizes

## Technical Requirements

### Icon (mcpo/icon.png)
- **Format**: PNG with transparency
- **Size**: 96x96px minimum (256x256px recommended)
- **Usage**: Shows in Home Assistant add-on list
- **Design**: Should be recognizable at small size

### Logo (mcpo/logo.png)
- **Format**: PNG with transparency
- **Size**: Flexible (256x64px common)
- **Usage**: Shows in add-on details page
- **Design**: Can be wider, more detailed

### Best Practices
- ✅ Use transparency (alpha channel)
- ✅ Keep design simple and recognizable
- ✅ Test at small sizes (64x64px)
- ✅ Use high contrast colors
- ✅ Avoid too much detail
- ❌ Don't use gradients (can look bad at small sizes)
- ❌ Don't use thin lines (won't be visible)

## Example Design Process

### Using Canva (Free)

1. **Create Icon:**
   - Go to canva.com
   - Create custom size: 256x256px
   - Add background color or shape
   - Add text "MCPO" or symbol
   - Download as PNG with transparent background

2. **Create Logo:**
   - Create custom size: 512x128px
   - Design wider version with text
   - Add tagline if desired ("MCP to OpenAPI Proxy")
   - Download as PNG

3. **Replace files:**
   ```bash
   mv ~/Downloads/icon.png mcpo/icon.png
   mv ~/Downloads/logo.png mcpo/logo.png
   git add mcpo/icon.png mcpo/logo.png
   git commit -m "feat: add MCPO-specific branding"
   git push
   ```

## Temporary Solution

Until you create custom icons, you can use a simple solid color with text:

### Generate with ImageMagick

```bash
# Install ImageMagick (if not already installed)
# macOS: brew install imagemagick

# Create icon (256x256)
convert -size 256x256 xc:'#3B82F6' \
  -gravity center \
  -pointsize 72 \
  -fill white \
  -annotate +0+0 'MCPO' \
  mcpo/icon.png

# Create logo (512x128)
convert -size 512x128 xc:'#3B82F6' \
  -gravity center \
  -pointsize 48 \
  -fill white \
  -annotate +0+0 'MCPO Proxy' \
  mcpo/logo.png
```

### Or Use Python (Pillow)

```python
from PIL import Image, ImageDraw, ImageFont

# Icon
img = Image.new('RGB', (256, 256), color='#3B82F6')
draw = ImageDraw.Draw(img)
# Use default font or load custom font
draw.text((128, 128), 'MCPO', fill='white', anchor='mm')
img.save('mcpo/icon.png')

# Logo
img = Image.new('RGB', (512, 128), color='#3B82F6')
draw = ImageDraw.Draw(img)
draw.text((256, 64), 'MCPO Proxy', fill='white', anchor='mm')
img.save('mcpo/logo.png')
```

## Inspiration Examples

### Similar Add-ons
Look at these for inspiration:
- **Node-RED** - Flow-based programming icon
- **InfluxDB** - Database proxy icon
- **Mosquitto** - Message broker icon
- **AppDaemon** - Automation proxy icon

### Design Principles
1. **Simple** - Recognizable at 48x48px
2. **Unique** - Distinct from other add-ons
3. **Relevant** - Represents MCPO's function
4. **Professional** - Clean and polished
5. **Scalable** - Works at all sizes

## Getting Help

If you need design assistance:

1. **Ask in Discord/Forums:**
   - Home Assistant Discord
   - Open WebUI Discord
   - Design communities

2. **Hire a Designer:**
   - Fiverr ($5-50)
   - Upwork (hourly or project)
   - 99designs (contest)

3. **Use AI:**
   - "Create a square icon for MCPO, a proxy server that translates Model Context Protocol to OpenAPI"
   - Generate multiple options
   - Select and refine best option

## Legal Considerations

- ✅ Create original design
- ✅ Use royalty-free icons with proper license
- ✅ Give attribution if required
- ❌ Don't copy/steal other projects' logos
- ❌ Don't use trademarked symbols without permission

## After Creating Icons

1. Replace the files
2. Test locally
3. Commit with clear message:
   ```bash
   git add mcpo/icon.png mcpo/logo.png
   git commit -m "feat: add MCPO-specific icon and logo"
   git push
   ```
4. Wait for release
5. Update add-on in Home Assistant
6. Verify icons appear correctly

## Need Help Now?

For immediate use, generate simple text-based icons using one of the methods above. You can always improve them later with:

```bash
git commit -m "feat: improve icon and logo design"
```

Every commit triggers a version update, so users will see the new icons after updating the add-on.

---

**Remember:** Good branding helps users recognize your add-on in the store and builds trust! Take time to create something you're proud of. 🎨

