# Azazel Brand & Logo Banner Design System

**Version:** 1.0  
**Status:** Normative  
**Applies to:** Azazel umbrella repository and all Azazel-series product repositories  
**Reference implementation:** Azazel-Knowledge banner design direction

This document defines the visual system for Azazel product logos and GitHub README banners. It is intended for human designers, maintainers, and AI-assisted image generation workflows.

The goal is not to make every banner look identical. The goal is to make every banner unmistakably Azazel while allowing each product to express its own mission, operational role, and technical boundaries.

---

## 1. Brand foundation

### 1.1 What Azazel represents

Azazel is a tactical cybersecurity ecosystem designed for constrained, temporary, offline, unstable, or high-risk environments. Its visual identity must communicate:

- deterministic behavior
- local-first operation
- bounded authority
- operator visibility
- tactical utility
- evidence and auditability
- resilience under constraint
- the Cyber Scapegoat concept

Azazel artwork must not resemble a generic hacker product, fantasy game faction, autonomous AI defender, or centralized command-and-control platform.

### 1.2 The Cyber Scapegoat symbol

The forward-facing horned goat is the primary family mark. It represents the scapegoat surface that receives pressure, creates time, exposes attacker behavior, and protects the operator's decision cycle.

The goat identifies the family. Product-specific diagrams explain the product.

### 1.3 Family unity and product autonomy

Every product must share the same brand grammar while retaining visual independence.

The banners should communicate the following relationship:

> One family. Distinct operational roles. Explicit authority boundaries.

No banner may imply that one product centrally commands all other Azazel products unless the implementation and documentation explicitly establish that relationship.

---

## 2. Mandatory visual invariants

These rules are non-negotiable unless an approved brand revision changes this specification.

### 2.1 Goat invariants

The goat must:

- face forward
- be recognizably horned
- retain approximate bilateral symmetry
- include a strong vertical facial axis
- contain circuit, trace, node, or machine-readable structure
- remain identifiable when the banner is reduced to approximately 800 pixels wide
- preserve the serious, tactical character of the series

The goat must not:

- become a realistic livestock photograph
- become cute, comic, mascot-like, or anthropomorphic
- lose its horns
- be reduced to an unrecognizable wireframe
- be hidden behind dense interface decoration
- be used as a central command hub when the product is not one
- contain occult symbols that overpower the cybersecurity meaning

### 2.2 Product identity invariants

Every banner must visibly include:

1. AZ designation, such as `AZ-04`
2. formal repository or product name
3. one-line role statement
4. product codename where ratified
5. one concise primary message
6. one product-specific semantic visual
7. no more than four capability labels
8. no more than three operational characteristics in the footer

### 2.3 Semantic integrity

Every major visual element must have a defensible connection to the product README, architecture, or design records.

Decorative elements are allowed only when they remain subordinate to the meaning. A viewer must not infer capabilities that the product does not implement.

Examples of prohibited implication:

- Fabric shown as a central message broker when it is a shared contract package
- Knowledge shown as an enforcement engine when it only advises
- Edge shown as autonomous AI defense when deterministic arbitration retains authority
- Gadget shown as a VPN or general-purpose router when it is not one

---

## 3. Canvas, composition, and hierarchy

### 3.1 Recommended canvas

Use a wide cinematic ratio suitable for GitHub README display.

Preferred production sizes:

- 2048 × 768 pixels
- 1920 × 720 pixels
- 1600 × 600 pixels

Acceptable aspect ratio range: **2.5:1 to 2.9:1**.

Avoid square, portrait, or extremely shallow banners.

### 3.2 Safe area

Keep all essential text and the recognizable goat silhouette at least:

- 4% from the left and right edges
- 6% from the top and bottom edges

Do not place critical text in the outer 8% of the canvas because mobile cropping, markdown rendering, or social previews may obscure it.

### 3.3 Information hierarchy

At normal README scale, the eye must encounter information in this order:

1. product name
2. goat or product mark
3. primary product message
4. role statement
5. product-specific flow or capability group
6. footer characteristics

If the viewer notices a background map, graph, node mesh, or decorative HUD before the product name, the hierarchy is wrong.

### 3.4 Common composition grammar

The exact placement may vary by product, but the following zones should exist:

- **Identity zone:** AZ designation, product name, role statement, codename
- **Brand zone:** goat mark
- **Mission zone:** primary message and product-specific semantic flow
- **Boundary zone:** statement of authority or operational constraint where necessary
- **Characteristics zone:** short footer with operational properties

Knowledge may use a left-emblem/right-information arrangement. Fabric may use a distributed woven-contract arrangement. Edge may use an operational decision flow. Gadget may use a compact field-device composition. The zones must remain recognizable even when their positions change.

---

## 4. Typography system

### 4.1 General rules

- Use no more than three typeface families in one banner.
- The title must remain readable at 25% of the original image width.
- Avoid distressed, fractured, pseudo-runic, or overly cinematic fonts for functional text.
- Letter spacing may be increased for small uppercase labels, but not enough to fragment words.
- Avoid thin strokes below approximately 2 pixels at final export size.

### 4.2 Series metadata

Use a restrained industrial or technical sans-serif for:

- AZ designation
- capability labels
- footer characteristics
- small interface annotations

These labels should feel standardized across the family.

### 4.3 Product title differentiation

The product title may vary to express role, but must remain technically credible.

#### Azazel-Edge

Use a disciplined military or operational sans-serif. The title should communicate reliability, readiness, and decision support rather than aggression.

#### Azazel-Gadget

Use a modern, compact sans-serif with high legibility. It should communicate portability and field usability, not consumer playfulness.

#### Azazel-Knowledge

Use a restrained, authoritative serif or hybrid serif. The intention is an intelligence archive, evidence ledger, or technical reference—not a fantasy grimoire cover.

#### Azazel-Fabric

Use a precise industrial, architectural, or standards-oriented sans-serif. Favor stable proportions, clear geometry, and excellent readability. Avoid the same serif treatment used by Knowledge and avoid exaggerated science-fiction display fonts.

### 4.4 Text density

A banner is not a README replacement.

Maximum recommended visible text:

- title: one line
- role statement: one line
- codename: one short line
- primary message: three short clauses or fewer
- capability labels: four or fewer
- footer characteristics: three or fewer

Micro-text may exist as texture but must not carry necessary meaning.

---

## 5. Color system

### 5.1 Shared foundation

All product banners use a dark neutral foundation.

Recommended base range:

- near black: `#050608` to `#0B0D12`
- graphite: `#151820` to `#242833`
- primary text: `#E8E9EC` to `#F5F6F8`
- secondary text: `#8D929C` to `#B6BBC5`

Pure black and pure white may be used sparingly.

### 5.2 Accent ratio

Product accent colors should occupy approximately **8% to 18%** of the image. Excessive glow or full-screen color washes reduce hierarchy and make the design resemble entertainment media rather than a trustworthy security system.

### 5.3 Product color families

The following colors are directional palettes, not single mandatory values.

#### Azazel-Edge — operational steel / command blue

Suggested range:

- `#2F6FAE`
- `#428BC4`
- `#6FA9D4`

Meaning: deterministic operations, decision support, reliability, controlled action.

#### Azazel-Gadget — field cyan / guarded teal

Suggested range:

- `#0D8FA5`
- `#27B6C5`
- `#6FD5D8`

Meaning: portable protection, field visibility, connectivity, rapid deployment.

#### Azazel-Knowledge — deep crimson / evidence red

Suggested range:

- `#7A151A`
- `#A82228`
- `#D0474D`

Meaning: threat evidence, adversary behavior, warning, accumulated intelligence.

Red must not dominate the full canvas. It should mark threat, evidence, state change, and key identity elements.

#### Azazel-Fabric — indigo / protocol violet

Suggested range:

- `#4A3A86`
- `#6E58B8`
- `#9A86DD`

Meaning: shared contracts, interoperability, schema continuity, cross-product structure.

Violet must be presented as a precise systems color, not magical energy. Pair it with graphite, silver, and restrained luminance.

### 5.4 Accessibility

- Maintain sufficient luminance contrast between text and background.
- Do not encode capability meaning by color alone.
- Ensure important text remains readable in grayscale.
- Avoid red/green-only contrasts.

---

## 6. Product-specific design language

### 6.1 Azazel-Knowledge

#### Core meaning

Knowledge observes, accumulates, correlates, detects repeatable behavioral patterns, and returns advisory context. It never commands enforcement.

#### Primary message

Preferred:

> UNDERSTAND. CORRELATE. ADVISE.

Boundary statement:

> ADVISORY ONLY — NEVER COMMANDS

#### Required semantic flow

The preferred visual narrative is:

> Observe → Friction → Reaction → Pattern → Advisory

This is more distinctive and accurate than generic world maps, skulls, malware icons, or anonymous threat graphs.

#### Goat treatment

The goat should appear observant and intelligent rather than enraged or dominant. Keep the recognizable circuit face and crimson identity. Reduce excessive eye glow and targeting reticles.

#### Avoid

- generic global threat-map composition as the main idea
- magical book imagery without technical evidence content
- implying attribution certainty
- depicting Knowledge as an enforcement or command node

### 6.2 Azazel-Fabric

#### Core meaning

Fabric provides shared schemas, state representations, audit formats, exchange contracts, and thin interoperability helpers. Product-local authority remains with each product.

#### Primary message

Preferred:

> SHARED CONTRACTS. LOCAL AUTHORITY.

#### Required semantic model

Show independent products using the same contract structure. Do not show Fabric as a central server, command hub, or runtime orchestrator unless that architecture is actually introduced.

Preferred visual approaches:

- woven parallel contract lines across independent product boundaries
- repeated matching schema symbols within each product node
- a recognizable goat outline formed by shared contract traces
- four peer contract domains: Schema, State, Audit, Exchange

#### Goat treatment

The goat must remain recognizable, but it may be integrated into the fabric of shared lines. Preserve the outer silhouette and horn shape; abstract the interior using schema paths and node geometry.

#### Avoid

- central-bus architecture
- command-center imagery
- magical violet energy
- medieval or serif title typography identical to Knowledge
- statements suggesting distributed state synchronization unless implemented

### 6.3 Azazel-Edge

#### Core meaning

Edge evaluates local NOC and SOC evidence, resolves bounded actions through deterministic arbitration, and preserves operator-visible explanations and audit traces.

#### Primary message

Preferred:

> OBSERVE. DECIDE. ACT.

Alternative where action boundaries are emphasized:

> EVIDENCE. ARBITRATION. EXPLANATION.

#### Required semantic flow

> Evidence → NOC/SOC Evaluation → Action Arbiter → Bounded Action → Explanation

#### Goat treatment

The goat may appear alert and operational, but not autonomous or omnipotent. The surrounding system should emphasize bounded actions and visible reasoning.

#### Avoid

- autonomous AI-warrior imagery
- uncontrolled offensive actions
- generic SOC dashboard overload
- suggesting total prevention

### 6.4 Azazel-Gadget

#### Core meaning

Gadget moves the endpoint's first-contact surface to a portable defensive gateway and provides explicit, operator-visible modes for untrusted networks.

#### Primary message

Preferred:

> MOVE THE FIRST-CONTACT SURFACE.

Alternative:

> PORTABLE. EXPLICIT. DEFENSIVE.

#### Required semantic flow

> Untrusted Network → Gadget Boundary → Protected Endpoint

Mode representation may include Portal, Shield, and Scapegoat only when the banner remains readable.

#### Goat treatment

The goat should remain compact and field-oriented. Favor a shielded, embedded, or device-integrated mark rather than a large command emblem.

#### Avoid

- VPN imagery
- generic Wi-Fi router advertising
- consumer electronics styling
- implying invisible or complete protection

---

## 7. Iconography and diagrams

### 7.1 Icon style

Icons should use one consistent family:

- outline or limited-fill
- consistent stroke weight
- restrained corner radius
- no mixed 3D and flat styles
- no stock hacker silhouettes

### 7.2 Capability count

Display no more than four capabilities. Recommended product groupings:

- Knowledge: Evidence, Correlation, Behavioral CTI, Advisory
- Fabric: Schema, State, Audit, Exchange
- Edge: Evidence, Evaluation, Arbitration, Explanation
- Gadget: Boundary, Modes, Deception, Visibility

### 7.3 Diagrams

A banner diagram must express only one principal relationship. If a diagram requires a legend, paragraph, or multiple reading passes, it belongs in the README, not the banner.

---

## 8. GitHub README requirements

### 8.1 Reduction test

Every proposed banner must be inspected at:

- 100% size
- approximately 1200 pixels wide
- approximately 800 pixels wide
- mobile-width preview

At 800 pixels wide, the following must remain legible:

- AZ designation
- product name
- role statement or primary message

The goat must remain recognizable.

### 8.2 File format

Preferred delivery:

- PNG for predictable GitHub rendering
- optimized RGB color profile
- no embedded fonts required for display
- descriptive filename, such as `Azazel-Knowledge_Banner.png`

SVG may be used only when it renders reliably on GitHub and does not depend on external fonts, scripts, or linked assets.

### 8.3 README placement

Place the banner near the top of the README, after the primary heading and codename where applicable.

Use a relative path:

```markdown
![Azazel-Knowledge Banner](images/Azazel-Knowledge_Banner.png)
```

The image path and filename capitalization must exactly match the repository file.

---

## 9. AI-assisted generation protocol

### 9.1 Required source material

Before generating a banner, the designer or AI must read:

- repository README
- architecture overview
- security boundary or non-goals
- product naming and codename record
- current series brand guidance

Generation based only on the repository name is prohibited.

### 9.2 Prompt structure

A production prompt should contain:

1. product role
2. authority boundary
3. goat invariants
4. semantic visual flow
5. product color family
6. title typography direction
7. GitHub banner aspect ratio
8. text whitelist
9. prohibited implications
10. reduction/readability requirement

### 9.3 Prompt template

```text
Create a wide GitHub README brand banner for [PRODUCT NAME], [AZ DESIGNATION],
within the Azazel cybersecurity series.

Product role:
[ONE-SENTENCE ROLE]

Authority boundary:
[WHAT IT DOES NOT COMMAND OR REPLACE]

Preserve the recognizable Azazel forward-facing horned goat: symmetrical horns,
strong vertical facial axis, circuit-derived facial structure, serious tactical
character, recognizable at 800px-wide display.

Use this product-specific semantic visual:
[FLOW OR ARCHITECTURE]

Primary color family:
[PALETTE]

Typography:
[PRODUCT-SPECIFIC DIRECTION]

Required visible text only:
- [AZ DESIGNATION]
- [PRODUCT NAME]
- [ROLE STATEMENT]
- [CODENAME]
- [PRIMARY MESSAGE]
- [UP TO FOUR CAPABILITIES]
- [UP TO THREE CHARACTERISTICS]

Do not create a generic cybersecurity dashboard. Do not imply capabilities,
authority, central control, AI autonomy, or network architecture that the README
does not claim. Avoid unreadable micro-text. Maintain strong readability at
GitHub README scale. Use a dark graphite foundation and restrained accent color.
```

### 9.4 Iteration discipline

Do not accept the first visually attractive result. Each candidate must pass the review process in Section 10. Revise the prompt based on identified semantic or visual defects rather than merely requesting “more polished” output.

---

## 10. Adversarial review process

Every banner must be reviewed through at least four independent perspectives. These may be separate human reviewers or explicitly separated review roles.

### 10.1 Brand reviewer

Questions:

- Is the goat immediately recognizable as Azazel?
- Does the product remain visually distinct from sibling products?
- Does the banner feel like part of one family rather than an unrelated artwork?
- Is the title typography appropriate to the product role?

### 10.2 Technical architecture reviewer

Questions:

- Does the image imply a capability or architecture not supported by the README?
- Does it preserve authority boundaries?
- Does it misrepresent advisory, deterministic, shared-contract, or portable behavior?
- Are product relationships technically accurate?

### 10.3 Communication reviewer

Questions:

- Can a new viewer understand the product within five seconds?
- Is there one clear primary message?
- Is the banner a brand artifact rather than an infographic?
- Is the text concise and correctly prioritized?

### 10.4 GitHub and accessibility reviewer

Questions:

- Is the title readable at 800 pixels wide?
- Does the goat remain recognizable on mobile?
- Does the contrast remain acceptable?
- Does the design survive grayscale?
- Are critical elements inside the safe area?

### 10.5 Red-team rejection conditions

Reject the design if any of the following is true:

- the product could be mistaken for a generic CTI, SIEM, VPN, router, AI defender, or message bus
- the goat is secondary, unrecognizable, or inconsistent with the series
- the artwork implies central control where none exists
- the title cannot be read at README scale
- the design needs explanatory prose to correct its first impression
- micro-text carries essential meaning
- more than one visual concept competes for dominance
- the main message emphasizes limitations more strongly than value
- the color treatment overwhelms hierarchy

### 10.6 Review scorecard

Score each category from 0 to 5:

| Category | Minimum passing score |
|---|---:|
| Azazel family recognition | 5 |
| Product-role accuracy | 5 |
| Authority-boundary accuracy | 5 |
| Five-second comprehension | 4 |
| README-scale readability | 4 |
| Product differentiation | 4 |
| Visual restraint | 4 |
| Accessibility | 4 |

A candidate fails if any mandatory accuracy category scores below 5, regardless of total score.

---

## 11. Approval workflow

1. Read the repository documentation.
2. Produce a textual design brief.
3. Validate the brief against product boundaries.
4. Generate two or more distinct candidates.
5. Run the adversarial review process.
6. Record all defects, including semantic defects.
7. Revise the strongest candidate.
8. Repeat review until no mandatory rejection condition remains.
9. Test reduced-size rendering.
10. Place the approved image in the product repository.
11. Update README using an exact relative path.
12. Verify the rendered README after commit.

A design is not approved merely because it is attractive. Approval requires semantic correctness, brand consistency, and practical readability.

---

## 12. Anti-pattern catalogue

### 12.1 Generic cyber dashboard

Symptoms:

- world map
- random red nodes
- skull or hooded attacker
- meaningless hexagons
- dense graphs without product-specific meaning

Correction: replace generic motifs with the product's actual decision, evidence, contract, or boundary flow.

### 12.2 Central-hub misrepresentation

Symptoms:

- one product shown as a central controller
- all sibling products connected as subordinate nodes
- arrows implying commands or orchestration

Correction: show shared structures, advisory flow, or peer relationships accurately.

### 12.3 Infographic overload

Symptoms:

- paragraphs inside the banner
- more than four capabilities
- multiple independent diagrams
- labels that vanish at README scale

Correction: retain one visual thesis and move detail into the README.

### 12.4 Entertainment styling

Symptoms:

- excessive neon glow
- magical energy
- fantasy runes
- game-title typography
- dramatic effects that reduce trust

Correction: emphasize industrial precision, restrained contrast, and evidence-driven meaning.

### 12.5 Identical sibling banners

Symptoms:

- only title and color change
- identical goat size and placement
- identical typography across incompatible product roles

Correction: preserve family invariants while changing composition, title style, and semantic flow to fit each product.

---

## 13. Reference standard: Azazel-Knowledge

Azazel-Knowledge establishes the current family baseline in the following areas:

- immediately recognizable circuit-derived goat
- clear AZ designation and product title
- product-specific message hierarchy
- semantic flow tied to the README
- explicit but subordinate authority boundary
- concise footer characteristics
- dark foundation with restrained product color

It is not a pixel-level template. Future banners must inherit its discipline, not duplicate its exact composition.

The correct relationship is:

> Same design language, different operational story.

---

## 14. Governance and change control

Changes to this design system should be reviewed like architecture changes because visual misrepresentation can create incorrect expectations about product behavior.

A proposed revision should state:

- problem being solved
- affected products
- compatibility with existing banners
- migration impact
- examples of compliant and non-compliant use

Major changes to goat invariants, product palettes, title hierarchy, or authority-boundary representation require a version increment.

---

## 15. Final acceptance checklist

Before merging a banner, confirm all items:

- [ ] README and architecture documents were reviewed.
- [ ] AZ designation is correct.
- [ ] Formal product name is correct.
- [ ] Codename is ratified and spelled correctly.
- [ ] Goat is recognizable at 800px width.
- [ ] Product role is understandable within five seconds.
- [ ] Primary message is affirmative and concise.
- [ ] Authority boundary is accurate and subordinate.
- [ ] No unsupported capability is implied.
- [ ] No central-control relationship is falsely implied.
- [ ] Product accent color is restrained.
- [ ] Product title font differs appropriately from sibling products.
- [ ] Critical text is inside the safe area.
- [ ] No essential micro-text exists.
- [ ] Grayscale and contrast checks pass.
- [ ] File format renders correctly on GitHub.
- [ ] README image path is exact and verified after commit.
- [ ] All adversarial review categories meet the minimum score.

Only after every applicable item passes may the banner be treated as an approved Azazel-series asset.
