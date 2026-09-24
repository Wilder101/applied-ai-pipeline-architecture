# 0004. Source data provenance

**Status:** Accepted. Supersedes an earlier workflow decision that was never
built.

## Context

One venture renders its output from real-world source data rather than
generating it. That introduces a question the subject-matter policy in
[0003](0003-content-and-ip-risk-policy.md) is structurally unable to answer:
what am I permitted to do with the data itself?

## Decision: verify per source, never by category

Three tiers, in descending order of how much I trust them without checking:

**National government works that are public domain from creation.** The
strongest and least ambiguous category. No expiry, no renewal, no per-item
research.

**Works that are public domain by age.** Genuinely free, but the threshold
**advances every single year**. It is a moving target. Anything relying on it
must be re-confirmed rather than remembered, and a note in a file from two
years ago is not a confirmation.

**Works from other jurisdictions or from sub-national bodies.** These may have
no parity at all with the first tier. One national mapping agency's data
arrived under a permissive open licence granted through Crown copyright. That
behaves similarly in practice but is a legally different mechanism from an
absence of copyright, and conflating the two is how you end up relying on a
permission that can be varied.

**Public domain status on an underlying work does not extend to marks layered
on it.** A historical survey sheet may be entirely free while the current
agency seal or a modern association logo printed on it is not. Reproduce the
cartography, not the current branding.

## The finding that mattered most: open is not public domain

The sources that actually ship were not the ones originally researched, and
they do not share a legal status. The product is built from two halves:

- **The elevation half** is a federal public domain composite. It owes nothing.
- **The vector map half** is a crowd-sourced database published under the Open
  Database License (ODbL), which is copyleft. **Attribution is required
  regardless of commercial intent, and regardless of how public the underlying
  facts feel.**

Coordinates of a road are facts. The database of them is licensed. Those are
different objects and I had been treating them as one.

## Narrowing an unanswerable question into an answerable one

The open question under a copyleft data licence is whether a rendered raster
print counts as a "produced work", which owes attribution only, or a
"derivative database", which owes share-alike and would be effectively
impossible for a static print.

I did not resolve it, and I did not need to. **Attribution is owed either way.**
So the unresolved half gates nothing, and the resolved half is actionable
immediately. Recording which part of a question actually blocks work is worth
more than resolving the whole question.

## Verified absent, not assumed present

Before treating this as a live problem I checked whether an attribution string
already existed anywhere: in the configuration files, in the layout module, or
rendered on any output sheet.

**Zero, across six finished sheets.**

It was promoted from a footnote to a hard pre-sale blocker at that point, not
when I first suspected it. There is a difference between believing a thing is
probably missing and confirming it is missing, and the second one is cheap.

## Applied rather than left pending

The credit line went in immediately rather than waiting for a decision, on an
asymmetry argument. Proofing without it would have meant paying to proof a file
that cannot legally be sold in the form proofed. One configuration line
reverses it if I later disagree with myself. The asymmetric cost decides it.

Every build records the credit line it used in its manifest, so any shipped
file can be traced to the attribution it actually carries rather than to the
attribution the code currently emits.

## Deferred, and recorded as deferred

A per-source checklist covering origin, publication date, government versus
private origin, and any current trademark overlay was never established. Each
source has been verified individually and informally.

I am writing that down as not yet done rather than describing the informal
process as though it were the checklist. An undocumented habit is not a
control, and the failure mode is that a future source gets waved through
because the previous four were fine.
