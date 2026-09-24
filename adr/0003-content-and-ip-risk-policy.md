# 0003. Content and intellectual property risk policy

**Status:** Accepted. Binding on all three ventures. Amended twice.

## Context

This policy did not come from general caution. It came from reading one real
shop in the same market carefully enough to see two separable legal exposures,
neither of which its operator appeared to have separated.

**Exposure one, trademark and false endorsement.** The shop organised whole
collections around protected names, with the name in every product title. The
pattern implies sponsorship. That is what nominative fair use tests for, and
organising a commercial collection around a mark is close to the worst version
of the fact pattern. Courts have found implied sponsorship in cases involving
book cover art and collectible cards on reasoning that applies here directly.

**Exposure two, straightforward copyright infringement.** One product marketed
as "inspired" was, by the seller's own product description and their own
frequently asked questions page, a reproduction of an existing poster. Their
FAQ described sourcing from existing published cover art and posters as general
practice.

The second is the one worth dwelling on, because the shop told on itself in its
own marketing copy. Whatever risk assessment produced that text, it was not one
that started from what the law prohibits.

## Decision

Three hard constraints, not guidelines.

1. **No band, musician, film, television, or celebrity names or quotes** as
   themes, listing titles, or collection categories.
2. **No reproducing, closely tracing, or lightly modifying** any existing
   copyrighted image. All artwork is freshly generated, per
   [0001](0001-generation-provider-and-model-selection.md).
3. **No mimicking or naming a living or estate-managed artist's distinctive
   style** as a marketing hook. Two adjacencies that came up during early
   research were excluded on this basis.

**Disclaimer language was considered and rejected.** Phrases of the "inspired
by" and "not authorised by" family provide no meaningful protection under the
case law reviewed, and their presence arguably evidences awareness. They are
not a mitigation and I will not treat them as one.

**Escalation rule.** If a promising idea brushes this policy, the next step is
to consult an intellectual property attorney. It is never to find a wording
that gets around it. This is written down because the temptation is real and
predictable, and a rule you invent under commercial pressure is not a rule.

The accepted cost: several high-converting product categories are permanently
out of scope regardless of how well they would sell.

## Amendment one: this policy has a structural blind spot

This policy governs **subjects**. What a design may depict.

It says nothing about the licence obligations of **the data a design is
rendered from**. After one venture pivoted to rendering from real source data,
that became the entire substance of its output, and nothing in this document
would have caught it.

Those obligations are attribution requirements rather than restrictions on
subject matter, so they do not contradict anything here. But they are equally
capable of blocking a sale, and **a subject-level policy is structurally blind
to a source-level obligation.** That is why
[0004](0004-source-data-provenance.md) exists as a separate record rather than
a section in this one.

## Amendment two: descriptive use, audited rather than asserted

A later question was whether protected place names could appear in listings at
all. The answer is yes, subject to conditions, and the conditions were checked
one at a time rather than assumed:

- **The name identifies the depicted subject and nothing more.** It appears as
  location, in a subtitle. It is not the collection name and not the hook.
- **Zero endorsement language anywhere that renders.** Audited across every
  configuration file and every module, not spot-checked.
- **No official emblem can appear.** This one is met structurally rather than
  by policy: the pipeline composites no raster assets at all, so there is
  nothing for an emblem to arrive through. A structural guarantee is worth more
  than a rule, because it cannot be forgotten. Note also that certain agency
  emblems are protected by federal statute independently of trademark law, so
  "we have no trademark problem" is not the whole question.
- **No trade dress proximity.** The visual language of these products
  resembles neither the official cartographic template of the relevant agency
  nor the period poster style associated with it.

The piece that was missing was a non-affiliation statement. There is now one,
as a credit line on every sheet, stating that the work is independently
produced and not affiliated with, authorised by, or endorsed by any
land-management agency. It is deliberately generic rather than naming a
specific agency, because the catalog spans several jurisdictions and legal text
that varies per item is legal text that will eventually be wrong on one of them.

One thing remains outside the repository and is recorded here as outstanding:
the same statement belongs in the listing copy, because confusion at the point
of sale is what trademark law actually concerns itself with, and nothing in the
rendering pipeline can put it there.

## A note on automated flags

A keyword research tool flags terms it believes may be trademarked. Those flags
are a prompt to check that specific term. They are neither an automatic
rejection nor safely ignorable. One flagged term turned out to be a
false-positive collision with a same-named consumer brand in an unrelated
category.
