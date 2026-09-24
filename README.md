# Applied AI Pipeline Architecture

A written record of how one person runs generative artificial intelligence (AI)
in production: the decisions, the reasoning, the costs, the guardrails, and the
things that turned out to be wrong.

Three small commercial ventures share a workspace, a credential pattern, a
post-processing core, and this habit of writing decisions down. They are three
different answers to one question: **how much of this should a model draw?**

## What this is

Eight architecture decision records and a description of the pipeline they
govern. Each record states what was decided, what it was decided against, and
what it cost. Several record a decision that was later corrected, with the
measurement that corrected it.

The through-line, if you want the conclusion before the evidence:

> The useful boundary is not "generative or not." It is whether the artefact's
> correctness is **checkable**. Where output is judged, a model is the right
> tool and the gate is human. Where output makes verifiable claims about the
> world, a model is the wrong tool at any quality level, and the gate has to be
> mechanical against a real source.

In one of these ventures, no generative model renders the output any more.
That was not an ideological choice. It was the result of every corrective round
reducing the model's role, because every failure was a model failure.

Worth separating, because the two get conflated: that is a statement about what
draws the artwork. **All three ventures were built with AI assistance
throughout**, and that has not changed in any of them. Which tool renders a
file and which tool writes the software that renders it are different
questions, and only the first one has an interesting answer here.

## What this is not

- **Not a product repository.** No pipeline source code ships here.
- **Not a portfolio.** No generated images, no print files.
- **Not runnable.** There is nothing to clone and execute.
- **Not a tutorial.** It is a record of specific decisions with specific
  numbers, not general advice.

The ventures are unnamed on purpose, and so are their markets, their channels
and their products. What is publishable is the practice. What is not is the
business.

## Where to start

| If you want | Read |
|---|---|
| The pipeline end to end, both generations | [ARCHITECTURE.md](ARCHITECTURE.md) |
| The single best record here | [0007, output evaluation and acceptance](adr/0007-output-evaluation-and-acceptance.md) |
| How vendor and model choices got made | [0001](adr/0001-generation-provider-and-model-selection.md), [0002](adr/0002-model-cost-and-economics.md) |
| The governance side | [0003](adr/0003-content-and-ip-risk-policy.md), [0004](adr/0004-source-data-provenance.md), [0005](adr/0005-secrets-and-credential-handling.md) |
| What reuse actually transferred | [0008](adr/0008-pipeline-reuse-across-ventures.md) |

## A note on the corrections

Several records carry an amendment or a corrections section retracting
something stated earlier. [0002](adr/0002-model-cost-and-economics.md) retracts
five separate numeric claims and explains what was wrong with each measurement.

Those sections are deliberate and they are not padding. In every case the
original claim had already been written down as settled fact, and in at least
one case it was inherited into a second project on that basis. A number is not
true because someone wrote it down, including when that someone was me.

## Numbering

Record numbering restarts at 0001 here. It does not correspond to the
numbering in the source workspace, and is not meant to.

## Sanitisation

This repository is a one-way extraction. Nothing here flows back to the source,
and the source is not published.

Credentials, personal details, market research, brand names, channel strategy,
fulfilment vendors, product specifics and all generated assets are excluded by
design. `tools/check-public-safe.sh` is the guard that verifies it, and it runs
as a pre-push hook. It scans for credential shapes, high-entropy strings,
excluded terms and domains, personal identifiers by pattern, and any file
byte-identical to one in the source workspace.

It deliberately does not use `grep`. The `grep` on the machine this was built
on is a wrapper that honours `.gitignore`, which means a `grep`-based guard
reports clean on exactly the files most worth catching, because those are the
ones that get ignored.

## Licence

MIT. See [LICENSE](LICENSE).
