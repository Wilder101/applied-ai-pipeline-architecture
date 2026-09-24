# 0002. Model cost and economics

**Status:** Accepted. Costs are as of the period this record covers and will
drift.

## Context

I wanted to know what a design actually costs to produce, so that model choice
and batch size could be decided on a number rather than on a feeling about
whether inference was expensive.

## The headline number is not the interesting one

Per image, vector generation ran about **$0.08**. The raster tier was about
**$0.04**. At that price a full design batch costs a few dollars.

So inference is not the binding cost. Human finishing is. Measured on real
work, each design took **20 to 40 minutes** of hand finishing before a reusable
template existed, and a target of **10 to 15 minutes** after. At any plausible
hourly rate, that dwarfs the generation call by two orders of magnitude.

**The cost question that matters is therefore what the model's output costs
downstream, not what the call costs.** A model that is twice the price and
halves the hand finishing is dramatically cheaper.

## What that reframing bought

Prompt changes aimed at reducing downstream work were measurable. Adding a
closed-contour instruction and flat-colour wording to the shared style string
produced this, across the same subject:

| | before | after |
|---|---|---|
| silhouette see-through | 0.1 to 24.1% | 0.0 to 0.1% |
| gradient definitions | 1 to 14 | 0 to 1 |
| semi-transparent edge pixels | 44,000 to 204,000 | 24,800 to 25,500 |
| distinct colours | 14,600 to 36,400 | 3,000 to 8,700 |
| opaque pixels near the three dominant inks | 86.1 to 98.4% | 98.7 to 99.1% |

Two caveats that belong with the table rather than in a footnote. Both prompt
changes went in together, so their separate effects are unknown. And this is
one subject at four variations, which is a sample size of four.

The failure mode the table describes is worth naming because it is the
dangerous kind. The model sometimes composed marks **on** a coloured field
rather than painting the field, so stripping the background turned that field
transparent. Two of the first four variations showed 17.5% and 24.1%
see-through where the other two showed 0.5% and 0.1%. **An inconsistent failure
is the worst kind at catalog scale**, because nothing flags it and the good
cases teach you the process works.

## How spend is bounded

By construction rather than by attention:

- Batch size is a configuration value, not a loop someone edits.
- Model inputs live in one table and are passed through verbatim, so a model
  change is visible in a diff before it is billed.
- Every generated file gets a metadata record written beside it containing the
  exact prompt, model and input dictionary that produced it.

## The cost of being wrong dominates the cost of inference

A configuration written against a previous model version's schema carried a
`size` value that is not in the current model's preset list, which is a hard
rejection, and a style parameter that does not exist on that model at all.
**Every image in the launch batch would have failed.** The cost was not the
wasted calls, which are pennies. It was that the error was invisible until run
time and would have been discovered in a batch.

The fix was to point the runbook at the live schema endpoint rather than at a
remembered enumeration.

## The cheapest reduction found was deleting the model from a step

In the second venture the model's last remaining job was paper texture and an
ornamental border. A seeded procedural generator replaced it.

That was not chosen on cost. It was chosen because a generated binary asset can
never be re-derived from configuration, which breaks a byte-identical rebuild.
Ongoing inference spend for that product line fell to zero as a side effect.

It is worth stating plainly: **the largest cost saving in this work came from
removing the model, and it was not a cost decision.**

## Corrections

The first version of this record was written from measurements taken ad hoc
during working sessions. Re-measured at print resolution with one consistent
method, five claims did not survive.

1. **"Roughly two-thirds of the design becomes holes."** Generalised from a
   single image, and measured with bounding-box coverage, which counts the
   empty space around an irregular subject as holes. The real figure on the
   silhouette metric was far lower.
2. **"It cannot be recovered mechanically."** True only for an exact flood
   fill. A colour-keyed mask recovers it, which is what [0007](0007-output-evaluation-and-acceptance.md)
   now describes.
3. **A quoted before-and-after pair** was measured on the weaker of two
   metrics, and compared the worst original against the best probe. Both ends
   were flattering.
4. **Colour counts** were taken on downscaled previews, where shrinking fine
   hatching invents blended colours that are not in the file.
5. **"Two colours"** for one output included the background rectangle, so the
   artwork was one colour.

The pattern in all five is the same: a number measured once, in passing, on
whatever artefact was to hand, then written down as though it were a
measurement. None of them were deliberate. That is the point. See
[0007](0007-output-evaluation-and-acceptance.md) for what replaced the habit.
