# 0001. Generation provider and model selection

**Status:** Accepted. Amended once, by measurement, in the section at the foot.

## Context

I needed to generate illustrative artwork for a print product line, in volume,
at a quality that survives being printed large. Three ventures eventually ran
on this decision, so I wanted the choice to be about properties I could state
rather than about which output I liked best on the day.

## Requirements that actually decided it

Four, in the order they eliminated candidates.

**Programmatic access.** An application programming interface (API) or a
command line, not a graphical interface with a human in the loop per image. A
catalog is built in batches.

**Commercial use rights**, in the provider's own terms, in writing.

**An illustrative aesthetic** rather than a photographic one. Photorealism was
irrelevant to every venture here.

**Print resolution, eventually.** Not necessarily from the model, but the path
to it had to exist.

The strongest candidate aesthetically was excluded on the first requirement.
It has no official public API, and the unofficial wrappers that exist violate
its terms of service and carry a real risk of account termination. That is a
governance exclusion rather than a quality judgement, and it held across all
three ventures. I would rather ship a slightly weaker image from a vendor whose
terms I can point at.

## Decision

**Call models through an aggregator rather than each vendor's own API.** One
consistent interface across many models means swapping a model is a
configuration change, not an integration project. That bet paid off later: model
inputs live in one table in a configuration file and are passed through
verbatim, so changing model is a diff in a config file.

**Choose the model on an output format property, not on taste.** The one I
settled on emits native vector output, which at the time was unusual. That
matters for a specific reason: with vector output, the point at which
anti-aliasing is introduced becomes mine to choose rather than the model's.
Measured on real output, files came back with 724 to 1,304 genuine paths and no
embedded raster image.

Each rejection has a property attached rather than an impression:

- A model optimised for rendering text was irrelevant, because all type in
  these products is set by hand. Later that turned into a hard rule for a
  different reason, recorded in [0007](0007-output-evaluation-and-acceptance.md).
- Photorealism models were irrelevant to an illustrative line.
- One vendor trains only on licensed stock and offers indemnification against
  intellectual property (IP) claims. That is the cleanest legal footing
  available in this market, and I deliberately kept it on the shelf as a
  conservative fallback. See [0003](0003-content-and-ip-risk-policy.md).

## Resolution as a selection criterion

The raster tiers available were roughly 1,024 pixels and roughly 2,048 pixels
on the long edge. Neither reaches print. At 300 dots per inch (DPI), 2,048
pixels covers about 6.8 inches. A 24 by 36 inch sheet at the 150 DPI floor
needs 3,600 by 5,400. So either an upscaling step was real engineering work, or
the output had to be resolution-independent. That is most of why vector won.

Vector sidesteps pixel count. It does not sidestep detail density, which turned
out to be the real ceiling. That is in [0007](0007-output-evaluation-and-acceptance.md).

## Amendment: one claim here was wrong

The original version of this record asserted that vector output "sidesteps the
semi-transparent edge problem." It does not. It makes the problem solvable,
which is a different claim.

A correctly backgroundless vector file, rasterised to 4,500 by 5,400, still
carried **204,212 semi-transparent pixels**. The model contributes
preconditions. The fix is a post-processing step, and it had to be written.

I am leaving the original claim visible rather than editing it out, because the
gap between "sidesteps" and "makes solvable" is exactly the kind of thing that
gets inherited into a second project as settled fact. It was.

## Consequences

- Model choice is reversible at configuration level, and has been exercised.
- The aggregator is a dependency and a single point of failure. Accepted
  knowingly: the alternative is one integration per vendor.
- Resolution strategy is decided by output format, not by the model tier, which
  removed an entire class of upscaling work.
