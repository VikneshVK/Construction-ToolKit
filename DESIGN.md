# DESIGN.md — BuildCalc Design System & Craft Specification

> **Product:** BuildCalc (Mobile Construction & Trade Calculator)  
> **Target Platforms:** iOS & Android (Flutter)  
> **Design Philosophy:** Industrial Precision · Rugged Jobsite Utility · Zero-Latency Clarity  
> **Taste Dials:** `DESIGN_VARIANCE: 4/10` | `MOTION_INTENSITY: 2/10` | `VISUAL_DENSITY: 6/10`  

---

## 1. Design Vision & Brand North Star

BuildCalc is not a generic mobile calculator, and it is not a phone emulation of a 1990s LCD physical calculator. It is a **modern jobsite instrument** designed for framers, concrete contractors, roofers, stair builders, and estimators working under harsh physical conditions: direct sunlight, dust, safety gloves, and spotty cell reception.

### Core Tenet: "One Look. Exact Answer. Jobsite Verified."
* **Every calculation screen makes three things obvious in under 2 seconds:**
  1. What is the exact physical answer?
  2. What is the verification/code-check status, when applicable?
  3. What is the next useful action, including material ordering when applicable?

---

## 2. Anti-Slop Guidelines (Preventing Generic AI UI)

AI-generated interfaces routinely suffer from generic, uninspired patterns ("AI-slop"). BuildCalc enforces strict design prohibitions:

### 🚫 Strictly Banned Patterns
* **NO AI-Purple Gradients or Pastel Glassmorphism:** Never use purple-to-cyan mesh gradients, blurry frosted glass cards, or translucent backdrops. They wash out completely in direct outdoor sunlight.
* **NO Cluttered Card-Inside-Card Nesting:** Never nest multiple levels of bordered cards. Group by spatial hierarchy, clear typographic weights, and high-contrast surface steps.
* **NO Microscopic Low-Contrast Text:** No 10–11px light-gray (`#666` / `#888`) labels on dark backgrounds. Normal text must meet at least 4.5:1 contrast against its immediate surface. Critical jobsite text should target 7:1 where practical.
* **NO Hardware Keypad Emulation:** Never force users to press 5 separate physical buttons (`[CONV] [INCH] [STORE] [RUN] [DIAG]`) to calculate a rafter. Use labeled, contextual input fields with instant calculation.
* **NO Decorative Charts Without Data:** Never render wavy abstract graphs or filler sparklines. Every diagram rendered is an exact, proportional 2D vector blueprint calculated from real geometry.
* **NO Modal / Dialog Spam:** Never pop up confirmation modals or blocking dialogs for valid inputs. All calculations, errors, and code warnings live **inline**.

---

## 2.1 AI Implementation Rules

When implementing BuildCalc UI, treat this DESIGN.md as the visual source of truth.

- Do not invent new colors. Use the defined design tokens.
- Do not invent new card, button, input, badge, or navigation styles when an existing component fits.
- Do not introduce gradients unless explicitly specified.
- Do not introduce glassmorphism, decorative blobs, or ornamental illustrations.
- Do not copy generic SaaS dashboards, consumer finance apps, or physical calculator interfaces.
- Reuse existing BuildCalc components before creating one-off widgets.
- Prefer composition of established components over duplicated feature-specific styling.
- If a new component is necessary, derive its styling from existing tokens and patterns.
- Never hardcode colors, spacing, radii, typography, or animation values inside feature screens when a design token exists.
- Preserve the visual hierarchy: Input → Calculation → Result → Verification → Action.
- When uncertain, choose clarity, measurement readability, and jobsite usability over decoration.


## 3. Visual Tokens & Aesthetic Foundations

```
+---------------------------------------------------------------------------------+
|                                 COLOR SYSTEM                                    |
+---------------------------------------------------------------------------------+
| Base Canvas:      #0F1115 (Deep Matte Void)                                     |
| Card Surface:     #181C22 (Steel Charcoal)                                      |
| Input / Elevated: #222831 (Gunmetal Gray)                                       |
| Border / Divider: #303844 (Subtle Tooling Edge)                                 |
| Primary CTA:      #D4AF37 (Safety Gold / Construction Hardhat)                  |
| Primary Text:     #F5F7FA (Crisp Chalk White)                                   |
| Secondary Text:   #9CA3AF (High-Legibility Neutral)                             |
+---------------------------------------------------------------------------------+
```

### 3.1 Color Palette

| Token Name | Hex Code | Role & Usage |
| :--- | :--- | :--- |
| `bg-canvas` | `#0F1115` | Main application background optimized for high-contrast jobsite readability |
| `bg-surface` | `#181C22` | Cards, workflow containers, result cards |
| `bg-elevated` | `#222831` | Input fields, active toggles, dropdown triggers |
| `border-subtle` | `#303844` | 1px clean separators and field outlines |
| `brand-gold` | `#D4AF37` | Primary action button, calculate CTA, active tabs |
| `brand-gold-hover`| `#E5B824` | Pressed state for primary CTA |
| `text-primary` | `#F5F7FA` | Primary numbers, headers, critical dimension readouts |
| `text-secondary`| `#9CA3AF` | Dimension units (`ft`, `in`, `yd³`), field helper text |
| `text-muted` | `#6B7280` | Timestamps, secondary calculation formulas |

#### Category Accent Accents:
* **Materials (Concrete/Lumber/Masonry):** `#FF7849` *(Safety Orange)*
* **Roofing (Pitch/Rafters/Bevels):** `#38BDF8` *(Sky Blueprint Blue)*
* **Stairs (Solver/Code Sentinel):** `#A855F7` *(Precision Violet)*
* **Measurements (Fractions/Conversions):** `#10B981` *(Machinist Emerald)*

#### Semantic Status Tokens:
* **Compliance Pass (`status-success`):** `#22C55E` — Used when stair rise/run satisfies IRC code limits.
* **Code Warning (`status-warning`):** `#F59E0B` — Used when dimensions exceed recommended variance or slope limits.
* **Physical Error (`status-error`):** `#EF4444` — Invalid geometry (e.g., Rise $\le$ 0, negative run).

---

### 3.2 Typography & Numeric Hierarchy

Measurements and numbers are the core product. We use **Inter** for UI copy and clean tabular figures for measurements:

```
Hero Result:     32pt Bold     (e.g., 13.04 yd³)  -> #F5F7FA
Secondary Metric: 18pt SemiBold (e.g., 9.97 m³ / 351.8 ft³) -> #9CA3AF
Section Header:  16pt Bold     (e.g., Stair Solver, Rafter Cut) -> #F5F7FA
Field Labels:    13pt Medium   (e.g., Total Rise, Lumber Width) -> #9CA3AF
Dimension Units: 13pt SemiBold (e.g., ft, in, mm, yd³) -> #D4AF37
Badge / Status:  12pt Bold     (e.g., WITHIN IRC CODE) -> Semantic Tint
```

* **Tabular Figures:** Always apply `FontFeature.tabularFigures()` so numbers do not jump or jitter during live recalculation.
* **Fractions Display:** Fractions are rendered in clean inline stacked or solidus format (e.g., `7 9/16"`), never ugly raw floating decimals (`7.5625"`).

---

### 3.2.1 Accessibility

BuildCalc must support accessible use in real jobsite conditions:

- Support Android TalkBack and iOS VoiceOver.
- Respect system font scaling and large-text settings.
- Never truncate critical measurements or calculation results.
- Never communicate status through color alone; pair color with text, iconography, or shape.
- All interactive controls and icons must have meaningful semantic labels.
- Maintain a minimum 48dp touch target for interactive controls.
- Test critical screens with grayscale/high-contrast conditions.
- Prefer strong contrast for primary numbers and safety/code states.
- Support reduced-motion preferences; non-essential motion must be removable.

### 3.2.2 Display Modes

Primary theme:
- Dark industrial theme defined by the tokens in this document.

Optional theme:
- Light high-contrast theme using the same semantic token system.

Rules:
- Calculation layouts must remain structurally consistent between themes.
- Theme changes must never alter calculation behavior.
- Do not automatically change theme during an active calculation.
- Validate both themes under direct sunlight and low-light conditions.


### 3.3 Radii, Borders & Shadows

* **Corner Radii:**
  * Inputs & Buttons: `8dp` *(Crisp, machined, professional tool radius)*
  * Cards & Containers: `12dp`
  * Badges & Chips: `6dp`
* **Borders:** `1dp` solid border (`#303844`) on all cards and fields to maintain sharp edge definition in high-glare environments.
* **Shadows:** No soft fuzzy shadows. Use a subtle 1–2dp downward surface separation (`#000000` at 25% opacity) only when a layer overlays another.

---

## 4. Jobsite Ergonomics & Touch Guidelines

1. **Glove-Friendly Touch Targets:**  
   * Minimum tap target for all clickable elements: **$48 \times 48\text{ dp}$**.
   * Primary `Calculate` button height: **$54\text{ dp}$** minimum with full-width tap area.
2. **Dedicated Fraction & Dimensional Input Bar:**  
   Instead of forcing the user to switch back and forth between OS keyboards to type fractions (`/`, `"`), provide a contextual quick-fraction strip above the numeric keyboard:
   ```
   [ 1/16 ]  [ 1/8 ]  [ 3/16 ]  [ 1/4 ]  [ 3/8 ]  [ 1/2 ]  [ 5/8 ]  [ 3/4 ]  [ 7/8 ]
   ```
3. **Instant Local Auto-Save (Zero Data Loss):**  
   Every keystroke is saved immediately to local state. If the app is minimized, the phone screen turns off, or a call interrupts work on-site, returning restores the exact input values and results instantly.

---

## 5. Component Inventory & Layout Patterns

```
+---------------------------------------------------------------------------------+
|                        SCREEN COMPONENT HIERARCHY                               |
+---------------------------------------------------------------------------------+
|  1. Top Navigation Bar (Back, Workflow Title, Saved History Icon)               |
|  2. Category Sub-Tabs (e.g., [Slab] [Footing] [Column] [Wall])                  |
|  3. Dynamic 2D Geometric Blueprint Canvas (Interactive proportional visualizer) |
|  4. Dimension Input Fields (Feet, Inches, Fraction pickers with unit badge)     |
|  5. Reusable Waste Slider Component (0% - 20% spillage buffer)                  |
|  6. Primary "Calculate" Action Button (#D4AF37 Gold)                            |
|  7. Result Hero Block (Primary answer, secondary unit readouts, code sentinel)  |
|  8. Action Bar (Save to Log, Copy to Clipboard, Share Specs)                    |
+---------------------------------------------------------------------------------+
```

### 5.1 Dynamic 2D Blueprint Canvas (`CustomPainter`)
* Render clean, high-contrast line drawings for:
  * **Stair Profiles:** Proportional steps with riser height and tread depth dimension markers.
  * **Rafter Cut Profiles:** Right-triangle showing plumb cut angle, bird's mouth seat cut, and long-point overhang.
  * **Concrete Slabs & Footings:** Isometric wireframe block with Length $\times$ Width $\times$ Depth annotations.

### 5.2 Reusable Waste & Spillage Slider
* **Range:** $0\%$ to $20\%$ (Default: $10\%$).
* **Visual Presentation:** Displays the exact additional buffer volume alongside the base structural volume:
  $$\text{Total Order} = \text{Base Volume} \times \left(1 + \frac{\text{Waste \%}}{100}\right)$$

### 5.3 IRC Code Sentinel Banner
* **Pass State:** Green badge + *"Pass — Within selected IRC limits"* with the applicable rule shown.
* **Violation State:** Amber badge + *"Warning — Exceeds selected IRC limit"* with the applicable rule shown.

---

## 6. Motion & Micro-Interactions (`MOTION_INTENSITY: 2/10`)

* **Speed:** All transitions must complete in **$120\text{--}180\text{ ms}$**.
* **Curve:** `Curves.easeOutCubic` for snappy, mechanical responsiveness.
* **Haptics:** Light haptic feedback (`HapticFeedback.selectionClick()`) when adjusting the waste slider, toggling unit units, or hitting Calculate.
* **No Long Animations:** Never make the user wait for a loading spinner or an animated number roll on deterministic calculations. Results render synchronously upon button tap.

---

## 6.1 Calculation Interaction Model

BuildCalc uses a deliberate balance between live feedback and explicit calculation:

- Simple calculators may show live preview results while the user edits inputs.
- Constraint-heavy calculators such as stairs may require an explicit Calculate action before presenting the final solution and verification state.
- The Calculate action must never introduce a loading state for deterministic local mathematics.
- Input validation should happen as early as possible without interrupting valid data entry.
- Errors and warnings appear inline and explain how the user can correct the input.
- A final result must clearly distinguish raw/base values from adjusted/order values.

## 6.2 Responsive Layout

BuildCalc must support small phones, standard phones, large phones, and tablets without assuming a fixed screen width.

- Calculation screens remain fully usable in portrait orientation.
- Landscape may use enhanced split layouts for blueprint + inputs or blueprint + results where space allows.
- Always respect SafeArea and system display insets.
- Respect system text scaling without breaking critical calculation layouts.
- Blueprint canvases must resize proportionally rather than clipping geometry.

## 6.3 Design System Implementation

All visual styling must be centralized and reusable. Feature screens must not become collections of one-off styles.

Recommended primitives/components:

- `AppColors`
- `AppTypography`
- `AppSpacing`
- `AppRadii`
- `AppMotion`
- `BuildCalcButton`
- `BuildCalcInput`
- `BuildCalcResult`
- `BuildCalcSection`
- `BuildCalcBadge`
- `BuildCalcBlueprint`
- `BuildCalcWasteSlider`
- `BuildCalcCodeCheck`
- `BuildCalcUnitSelector`

Use semantic tokens rather than raw values in feature code wherever practical.

## 6.4 Code Check Presentation

BuildCalc must not present itself as a legal authority or certify construction compliance. Code checks are informational calculations against an explicitly selected code profile and edition.

Use language such as:
- `Pass — Within selected IRC limits`
- `Warning — Exceeds selected IRC limit`
- `Reference — IRC 2024, selected stair rule`

Always show the relevant rule/limit when a code check is presented. Jurisdiction-specific profiles must remain explicit rather than implied.


## 7. Verification & Design QA Checklist

Before shipping any calculator module in BuildCalc, verify:
### Visual
* [ ] Can every number and label be read in direct sunlight at arm's length?
* [ ] Does the screen use only approved BuildCalc design tokens?
* [ ] Are there no generic AI UI patterns, unnecessary cards, gradients, or decorative elements?

### Jobsite
* [ ] Are all touch targets $\ge 48\text{ dp}$ with ample finger padding?
* [ ] Is the primary result visible without unnecessary scrolling?
* [ ] Can the core workflow be operated one-handed where practical?

### Accessibility
* [ ] Are TalkBack and VoiceOver semantics meaningful?
* [ ] Does the layout survive large system text settings?
* [ ] Is status understandable without color alone?
* [ ] Does the screen remain usable in grayscale/high-contrast conditions?

### Calculation UX
* [ ] Are all fractions displayed in simplified construction format (e.g. $7\frac{9}{16}"$ instead of $7.5625"$)?
* [ ] Are raw/base values clearly separated from waste-adjusted/order values?
* [ ] Are units explicit at every critical measurement/result?
* [ ] Do invalid inputs explain how to correct them?

### Reliability
* [ ] Does the calculator function 100% offline with airplane mode enabled?
* [ ] Does closing and re-opening the app restore the user's in-progress measurements without loss?
* [ ] Are deterministic calculations rendered without unnecessary loading states?
