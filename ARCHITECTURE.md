# Architecture

Three small commercial ventures, run by one person out of one workspace. They
share one credential file, one post-processing core, and one habit of writing
decisions down. One is paused, one is mature, one is unlaunched.

They are three different answers to the same question: **how much of this
should a model draw?**

One answers "all of the artwork." One answers "none of it." The third is still
the first answer, and that is correct for what it makes.

**Stated up front, because a reader could reasonably assume otherwise: in the
mature product line, no generative model renders the output.** Terrain is drawn
programmatically from real public elevation data, and even the paper texture is
procedural.

That is a claim about what draws the artwork. It is not a claim about how the
software was built. **All three ventures were engineered with AI assistance
throughout**: the code, the decision records, and the reviews of both.
[0006](adr/0006-execution-environment-split.md) is about exactly that, and it
is why this is applied AI rather than generative AI. The two questions get
conflated constantly, including by me in an earlier version of this page.

---

## 1. The invariant core

What survived both architectures unchanged:

- **Credential loading** by upward directory walk from a single workspace-root
  file. [0005](adr/0005-secrets-and-credential-handling.md)
- **The post-processing module**: rasterise, tag resolution, embed a colour
  profile, verify against the print specification. The only thing ever lifted
  between ventures without modification. [0008](adr/0008-pipeline-reuse-across-ventures.md)
- **The print contract**: 300 dots per inch, standard RGB, profile embedded on
  the finished composite rather than on intermediates.
- **A manifest per build**, recording what produced the file.
- **A decision record per decision**, including the ones that turned out wrong.

Everything below sits on this spine.

---

## 2. Generation one: the model draws the artwork

```
config  ->  generate  ->  post-process  ->  mechanical gate  ->  hand finish  ->  human gate
```

**Prompt construction.** A shared base style string plus a per-item subject
line, living in code and configuration rather than in a chat window. A prompt
that exists only in someone's history is not reproducible.

**Generation call** through an aggregator, with model inputs passed verbatim
from a single configuration table, so changing model is a configuration diff.
[0001](adr/0001-generation-provider-and-model-selection.md)

**The returned file is kept exactly as the model produced it**, with a metadata
record written beside it holding the exact prompt, model and inputs. The
original is never edited in place.

**Post-processing.** Identify and mask the background, fit to the print aspect
without stretching, harden partial transparency, tag resolution and colour
profile. [0007](adr/0007-output-evaluation-and-acceptance.md)

**Hand finishing**, deliberately. Type is set by hand and colour is reduced by
hand. Partly for print quality, and partly because purely machine-generated
artwork sits on uncertain copyright ground in the United States.
[0002](adr/0002-model-cost-and-economics.md), [0003](adr/0003-content-and-ip-risk-policy.md)

**This is still the live architecture of the third venture, and it is the right
one for it.** Where the model's output *is* the artwork, and the artwork is
judged rather than checked, a model is the correct tool.

---

## 3. The hinge

Three findings, in the order they arrived.

**Text density predicted failure.** Designs with a short title rendered
cleanly. Designs dense with labels were illegible. Map content is structurally
text-dense, so this was not a tuning problem.

**Feeding real data and overlaying real text programmatically fixed that** and
reduced the model's job to honest decoration.

**Once the decoration was honest, the remaining problem became visible.** The
route was being drawn over terrain that had no relationship to the actual
place. The single most important visual element of the product had never come
from real data at all, and nobody had noticed while the labels were still
wrong.

One line carries the whole section: **every corrective round reduced the
model's role, because every failure was a model failure.**

---

## 4. Generation two: the model draws nothing, but still writes the code

```
config -> fetch vector data -> fetch elevation -> shared projection
       -> layout -> terrain render -> procedural paper -> supersample
       -> tag + verify -> manifest -> audit -> human QC
```

**A per-item configuration file** holds coordinates or a route identifier,
extent, titles, output size, palette and any style overrides. Adding a product
is a configuration file, not code.

**Vector data** is fetched from a crowd-sourced open database, with **query
results verified rather than trusted**. An exact name match inside a correct
bounding box can still return the wrong real place, and has.
[0004](adr/0004-source-data-provenance.md)

**Elevation tiles** come from a public federal composite and are decoded from
their encoded form.

**One shared coordinate module** gives the elevation sampler and the vector
projection the same transform. They cannot drift apart, because there is only
one of them. [0008](adr/0008-pipeline-reuse-across-ventures.md)

**Layout measures its own furniture first**, then calls back for terrain at
exactly the window it will draw. Legend columns pack by measuring rendered text
width rather than by dividing the space evenly. Labels sit inline beside their
point with collision checks. The scale bar is computed from the projection's
real metres per pixel rather than drawn.

**Procedural paper texture**, deterministically seeded, so it can be re-derived
from configuration. A generated binary asset could not be.
[0002](adr/0002-model-cost-and-economics.md)

**The whole plate is supersampled and downsampled**, with type drawn at final
size so it stays crisp. Bleed is extended before texture is applied, so the
trim line carries no seam.

**The manifest** records configuration hash, environment and library versions,
extent, zoom, smoothing parameters, seeds, attribution, and which labels were
selected versus actually drawn.

**No generative model renders any part of this output.** The pipeline that
produces it was written with AI assistance, like everything else here.

---

## 5. The acceptance gate

Two halves, and the second is not removable.

**Mechanical**: byte-identical rebuild, resolution and profile on the finished
file, bleed and safe area, required legal lines, output newer than its inputs,
no orphans. Cheap, continuous, exits non-zero.

**Human, at native resolution, never on a preview.** Every mechanical gate has
passed on visibly broken output. Previews are not faithful proxies, which was
measured rather than assumed.

Both are in [0007](adr/0007-output-evaluation-and-acceptance.md), which is the
one to read if you only read one.

---

## 6. The reusable conclusion

The boundary is not "generative or not."

**It is whether the artefact's correctness is checkable.**

Where the output is **judged** (an illustration, a mood, a composition), a
model is the right tool and the gate is a human looking at it.

Where the output makes **verifiable claims about the world** (a place name, an
elevation, a distance on a scale bar), a model is the wrong tool at any quality
level, and the gate has to be mechanical against a real source.

The three ventures sit at three points on that line simultaneously. That is not
a history lesson. It is a current description of the workspace, and it is why
both architectures are documented here rather than only the newer one.

---

## Decision records

| | |
|---|---|
| [0001](adr/0001-generation-provider-and-model-selection.md) | Generation provider and model selection |
| [0002](adr/0002-model-cost-and-economics.md) | Model cost and economics |
| [0003](adr/0003-content-and-ip-risk-policy.md) | Content and intellectual property risk policy |
| [0004](adr/0004-source-data-provenance.md) | Source data provenance |
| [0005](adr/0005-secrets-and-credential-handling.md) | Secrets and credential handling |
| [0006](adr/0006-execution-environment-split.md) | Execution environment split |
| [0007](adr/0007-output-evaluation-and-acceptance.md) | Output evaluation and acceptance |
| [0008](adr/0008-pipeline-reuse-across-ventures.md) | Pipeline reuse across ventures |
