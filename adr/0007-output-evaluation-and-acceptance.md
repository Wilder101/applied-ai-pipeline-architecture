# 0007. Output evaluation and acceptance

**Status:** Accepted. The longest record here, and the one I would keep if I
could keep only one.

## The thesis

**Automated gates verify that a file is well-formed and reproducible. Nothing
they check asserts that it is right.**

Every gate passed on files that were visibly broken. Byte-identical rebuild:
passed. Correct resolution: passed. Colour profile embedded: passed. Module
self-tests: green. On files with a route line broken at every data-segment
junction, terrain rendered as visible stair-steps, a label naming a local
secondary school on a wilderness print, and in one case an output file three
minutes **older** than the fix it was supposed to contain.

The consequence is economic rather than philosophical. **Per-item human quality
control at native resolution is a real, recurring, unbudgeted cost per
product**, not a setup task that goes away once the engine is good enough. Any
plan that assumes it disappears is wrong about its own margins.

## The mechanical half

Cheap, continuous, exits non-zero. These are worth automating precisely because
they are the things a human reviewer will not reliably notice.

- Byte-identical rebuild from committed configuration.
- Resolution tagged and colour profile embedded **on the finished composite**,
  not merely on intermediates. An earlier version tagged intermediates
  correctly and saved finals bare, which an audit caught and no human would
  have.
- Bleed and safe area present.
- Required legal lines present.
- **Output file newer than the last configuration or code change.** This check
  exists because it has already failed once.
- No orphan files.

An audit subcommand runs all of these. On its first run it found two
six-week-old preview files that had survived every intervening fix while
looking entirely legitimate.

## The human half runs at native resolution, never on a preview

A preview is not a faithful proxy, and I had assumed it was.

Font-size floors and integer rounding change the ratio of label size to
available space. A quarter-scale render showed **10 pointer lines and 1 dropped
label** where the full-size files had **14 and 0**. A docstring in the code
asserted that previews were representative. It was wrong, and it had been wrong
in writing for some time.

## Self-tests that are capable of failing

A test that cannot fail is documentation with a green tick.

**The inverted relief bug.** The first terrain render looked entirely
convincing. Real mountains, real detail, genuinely persuasive at a glance. It
was wrong. Every peak was a crater. The relief was fully inverted, which is a
known easy-to-ship mistake in that class of code and is genuinely hard to spot
by eye on unfamiliar terrain. **That is exactly what made it dangerous:** it
did not look like a bug, it looked like a place.

It was not caught by inspection. It was caught by rendering a synthetic cone
with a known answer. The fix moved to a formulation with no sign ambiguity, and
the cone check is now a permanent self-test. The bugged image was kept
deliberately as a documented artefact rather than deleted.

**A second invariant.** A point projected by the layout code must land on the
same pixel the terrain sampler would read. Asserting that keeps two independent
code paths from drifting apart silently, which is the failure they would
otherwise have.

## Independent-source validation beats internal consistency

A pipeline can be perfectly self-consistent and uniformly wrong. Internal
checks cannot detect that. External ones can.

Rendered elevations were compared against **34 independently surveyed points**.
Median error **5.5 metres**, maximum **36 metres**, with the best cases inside
a metre in both directions. The worst cases were at sharp summits, where a
smoothing step reading slightly low is expected behaviour rather than a defect.

The property that makes this a good test rather than a comforting one: **a
single-tile indexing error would have produced roughly 1.8 kilometres of
error and failed unmistakably.** So one cheap check validates tile indexing,
value decoding, projection mathematics and sampling as mutually consistent. A
test that can only pass tells you nothing.

## Acceptance expressed as a number against the substrate

"Good enough to print" is not a judgement here. It is arithmetic against the
physical thing being made.

Colour space was taken from the fulfilment provider's own documentation rather
than inferred, which resolved a genuine contradiction between two of their own
pages. Standard RGB for large-format paper, and a full print-industry colour
conversion pipeline deliberately **not** built, because their documentation did
not ask for one.

Resolution is stated as a maximum rather than a floor. Bleed is computed:
4 millimetres per side is 47 pixels at 300 dots per inch, so an 18 by 24 inch
sheet ships as 5,494 by 7,294. Then measured against the existing composition,
where the margin between paper edge and keyline was already 459 pixels, about
ten times the requirement. Nothing had to move. **Measuring before changing
anything is what turned a feared layout rework into a no-op.**

For a fabric substrate the equivalent test is the alpha channel, because
partial transparency prints as a visible halo. The rule: **if more than 2% of
the artwork's border is still opaque, the file fails.** One assertion catches
leftover background, an unidentifiable background, and artwork running off the
canvas, which are three different defects with one symptom.

## A guard that passes for the reason it exists to catch

This is the worst class of failure in the whole record.

Every file from the generation model opened with a full-canvas opaque
rectangle. The opacity audit therefore measured every file as 100% opaque and
reported hard, clean edges. **It was reporting on files whose edges it had
never examined**, while the background it failed to notice would have printed
as a solid block across the garment.

The audit was not auditing. It returned the right answer for the wrong reason,
which is indistinguishable from working until something downstream is ruined.

The replacement identifies the background from what is actually visible at the
four canvas corners, **refuses the file outright if the corners disagree**, and
composites a mask in the original stacking order rather than deleting shapes,
so that a subject-coloured layer hidden beneath the background cannot leak
through when the background is removed.

Compare the credential version of this same failure in
[0005](0005-secrets-and-credential-handling.md). Same shape, different layer.

## Rejecting a whole batch is a normal outcome

The first batch of eight was rejected for production and kept in place as a
documented case study rather than deleted.

The reason it was worth keeping is that the failure was structural rather than
random. **Text density predicted which designs failed**, not model variance.
Designs carrying only a short title rendered cleanly; designs dense with
labels were illegible. That is a property you can design around. "The model was
inconsistent" is not.

## Why the human half is not removable

A colour ramp built for one landform was applied to another. On the resulting
sheet, the lowest point rendered **brighter** than the rim thousands of feet
above it. The tone curve was V-shaped, so nothing in the image indicated which
way was down. Correlation between elevation and rendered brightness measured
**0.136**. The replacement measured **0.999**. Both properties are now asserted
in a self-test so that neither can be quietly "fixed" into the other.

Two conclusions, and the second is the one that matters:

**A palette is not decoration. It is an encoding.** A ramp makes a claim about
which way is up, and that claim can be false for a given landform.

**It survived every gate and a full art-direction review, because the image
looked handsome either way.** It took someone who knew the actual landform to
see it. No mechanical check I can describe would have caught it, and I am not
going to pretend otherwise.
