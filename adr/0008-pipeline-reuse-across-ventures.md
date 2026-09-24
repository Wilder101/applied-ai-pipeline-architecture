# 0008. Pipeline reuse across ventures

**Status:** Accepted, with a correction written back into the original record
rather than filed separately.

## Context

Having built a generation and print pipeline for one venture, I decided not to
rebuild it for a second. The decision was written as a whole-pipeline carry
forward: same generation approach, same secrets pattern, same environment
split, same rasterisation, same local environment fix. The stated consequence
was that no new technical work was needed and only the prompts would change.

**That was half true.** Which half is the interesting part, and is why this
record is worth publishing at all.

## The half that carried

**Post-processing is genuinely content-agnostic.** Rasterise, tag resolution,
embed a colour profile, verify against the print specification. That moved
across all three domains with zero issues and is the only thing lifted
directly. It was lifted twice.

The third venture lifted two specific behaviours by name rather than by
gesture:

- Tag resolution **and** embed the colour profile on the **final** file, not
  only on intermediates. The first venture tagged intermediates and saved
  finals bare. An audit caught it.
- Zero the colour profile's timestamp field, so that an unchanged design
  rebuilds byte-identically instead of differing only by the moment it was
  built.

Both are small. Both are the kind of thing you only know because it already
went wrong once.

## The half that did not

**Generation did not carry.**

A bare text prompt was entirely adequate for one short Latin binomial per
image. It fails structurally for content requiring many correctly spelled,
correctly placed proper nouns and real-world-accurate geometry.

The evidence was unambiguous: a long-distance trail routed through the wrong
state, and place names that do not exist anywhere, rendered confidently in
correct-looking typography.

**This is not a prompt-wording problem.** The mismatch is between what
text-to-image generation can guarantee, which is nothing at all for spelling
and geography, and what the content requires, which is exactness. No amount of
prompt engineering closes that gap, because the gap is categorical.

So the reusable unit is smaller than "the pipeline." It is the post-processing
core. The correction went back into the original decision record rather than
into a new one, because leaving the original standing and adding a rebuttal
elsewhere means the wrong version is what a future reader finds first.

**The rule that fell out:** never ask a generative model to render place names,
route names, or numbers. Overlay real text programmatically from real data, as
a separate step.

That rule then had to be applied to the decoration as well, which I had not
anticipated. A model-drawn scale bar with nonsensical tick numbers survived a
review round, because the pipeline's own founding rule had never been applied
to the background artwork. A rule you apply to the content and not to the
frame is a rule you have only half adopted.

## An honest audit of all three codebases

Performed before deciding which one to copy, which in hindsight is the only
order that makes sense.

**The first venture was a set of spikes rather than a pipeline.** Eleven
exploratory scripts of about 42 lines each, one prompt per file, with the
post-processing step reused by copying it alongside each one.

That is the right shape for exploration, where the whole point is to try
eleven variations quickly and throw most of them away, and it did its job. It
is the wrong shape to build a catalog on, for one specific reason: a single
bug would need fixing in eleven places. The question was never whether that
code was good. It was whether it was the thing to extend.

**The second venture had the pattern worth following.** Per-item configuration
separate from code. One shared module owning the print-specification work. A
pinned requirements file with its own virtual environment.

**The third followed the second explicitly**, and named the one genuinely new
behaviour it added, deliberately **not** pushing it into the shared module
because it is substrate-specific. Paper has no transparency problem. Fabric
does. Generalising that into the shared module would have added a concept to
two projects that do not have the problem.

## Documented state drifts optimistic

This is the reuse hazard nobody writes down.

An audit of the mature project found that **no checked-in script called the
current layout code.** The four outputs being treated as the current best had
no reproducible source, and carried neither a resolution tag nor a colour
profile, while the post-processing module had been doing both correctly the
whole time.

The highest-value work existed only as output files and prose: a route-relation
fetch, a simplification from **258,088 raw points across 980 ways down to a
150-point spine**, and a landmark verification step that had already caught two
real bugs, where an exact name match inside a correct bounding box returned the
wrong real place. Two curated landmarks had resolved to the wrong state and the
wrong country respectively.

And the same bounding-box, projection and distance helpers had been
duplicated across four separate exploratory directories without ever being
factored out.

**An ADR describing a mitigation is not the same as the mitigation existing.**
One documented configuration override was never actually implemented in the
configuration it described. The document was the only place it was true.

## Consolidation, and what it was worth

One module now owns the coordinate system, used identically by the elevation
sampler and by the vector projection. Alignment between them becomes
structural rather than approximate: they cannot disagree, because there is only
one of them.

Replacing an equirectangular approximation with a true projection matching the
tile source removed a latent error measured at **0.1, 1.0 and 2.8 pixels** on
small extents, and **78.6 pixels across 16.5 degrees of latitude**.

That bug predated the feature that motivated the fix and was entirely
independent of it. It would not have been found by testing the new feature. It
was found because consolidating two implementations into one forces you to
decide which was correct.
