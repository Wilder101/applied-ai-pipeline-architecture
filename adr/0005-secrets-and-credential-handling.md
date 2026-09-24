# 0005. Secrets and credential handling

**Status:** Accepted. Scoped to local development. Extended once for cloud
identity.

## Context

Several projects in one workspace, each calling paid external services. I
needed one answer to where credentials live, before the answer became several
answers by accident.

## Decision: one file at the workspace root, loaded by upward walk

A single environment file at the top of the workspace, loaded at the head of
every script by a loader called **with no path argument**, so that it walks
upward from wherever the script sits and finds the same file regardless of
nesting depth.

One file for the whole workspace. Not one per project, and not a shell profile
export.

**Why not the shell profile.** Exporting a project's credentials in a shell
profile puts them into every terminal session on the machine, including every
session that has nothing to do with the project. Scope is the entire point of
the exercise. A credential that is present everywhere is a credential you have
stopped reasoning about.

**Consequences.** The file is ignored by version control and is never
committed. Every script touching an external service calls the loader before
reading the environment. New credentials go in the same file rather than
spawning new credential files, because two files become five.

**This is a local development pattern only.** Moving to continuous integration
or any deployed context means moving to that platform's secret manager. I am
writing that down rather than letting the pattern quietly get promoted into an
environment it was never designed for.

Filesystem-adjacent personal data gets identical treatment. A physical
recipient address lives only in an ignored file and never in a committed
configuration, for the same reason and with the same discipline.

## Extension: cloud identity, and the wrong turn on the way there

A cloud provider forbids an account's root identity from assuming a role. I
drew the wrong conclusion from that error, which was that a scoped identity
therefore requires a long-lived access key. I built that, then removed it.

**Root being unable to assume roles is an argument for not working as root. It
is not an argument for static keys.** The error message was telling me the
identity was wrong, and I heard it as telling me the mechanism was wrong.

What replaced it:

- A role holding the permissions.
- A user holding only the right to assume that role, and **no access key at
  all**.
- Short-term credentials that expire on their own, with role sessions capped at
  one hour.

No long-lived secret exists anywhere in that workflow.

## A choice that looks like worse hygiene and is not

For one asset handoff I rejected a time-limited signed URL in favour of a
scoped public object on exactly one key. Not the bucket, no listing permission,
one object.

The reasoning is timing, not laziness. The credential that signs such a URL
rotates automatically every fifteen minutes, while the consuming service
fetches asynchronously some time after accepting the job. **A URL that expires
mid-flight produces a failure that reads like an entirely different kind of
failure**, and debugging it means suspecting the consumer, the network and the
payload before suspecting the clock.

The asset had no sensitivity of its own. The trade bought away a race condition
at the cost of a publicly readable object that contains nothing worth reading.
Stated plainly so that a reader can disagree with it.

## Safety rails are claims, and an untested claim is not a rail

This belongs here rather than in [0007](0007-output-evaluation-and-acceptance.md)
because it is about credentials, but it is the same failure as the guard
described there.

A command had a safety model: sandbox by default, with two explicit flags
required to act for real. The model rested on a claim about which environment a
given credential addressed. That claim was inherited from earlier research,
written into a decision record **and** a runbook as settled fact, and never
tested.

It was wrong. Both credentials returned identical output, which is direct
evidence of a single environment. That evidence was available the whole time
and was read without being registered. Three separate status transitions were
each noticed and each explained away as simulated behaviour, rather than
treated as falsifying the premise.

**The safety model guarded nothing while advertising that it did. That is worse
than having no rails at all, because it licensed running the risky action for
practice.**

The rule that came out of it: **where a guarantee is expensive if false, test
the guarantee itself before building a safety model on top of it.** Not the
feature the guarantee protects. The guarantee.
