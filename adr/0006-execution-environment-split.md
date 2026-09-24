# 0006. Execution environment split

**Status:** Accepted. Extended by the interpreter-pinning finding at the foot.

## Context

I work across two agent execution contexts with different capabilities. I
wanted the split decided by what each can actually do, established by a
reproduced failure, rather than by preference.

## The failure that decided it

One context has browser automation but an allowlisted network. A script calling
a generation API there failed on name resolution.

That is worth reading carefully: the script had already loaded its credentials
correctly and reached the outbound call before failing. So the failure was
environmental, not a bug in the script, the credentials, or the dependencies.
Three things it looked like and was not.

Browser-driven work in that same context succeeded without difficulty:
research, comparisons, live marketplace validation, and navigating vendor
dashboards.

## Decision

**Sandboxed context:** research, validation, anything fundamentally driven
through a browser interface.

**Local context with a real shell and unrestricted network:** anything making
live API calls. Generation batches, fulfilment integration, rasterisation,
pipeline debugging.

**The split is bidirectional, which is the part that gets missed.** The local
context has no browser. A task that is fundamentally a browser task should go
back rather than be re-scripted from scratch against an undocumented interface.
I have wasted time on that direction too.

The written record exists partly to make the handoff work. A decision record
directory and a workspace context file mean the second context arrives with the
history rather than asking me to re-explain it.

## Native library architecture matching

This cost real time and is worth recording precisely, because the failure mode
is silent.

A rasterisation library needs a native C library through a foreign function
interface (FFI) binding. The Python wheel installed for the system interpreter's
architecture. The machine's only package manager was an older one for the other
architecture, left over from a previous setup. So the native library and the
binding that loads it were built for different architectures, and the loader
cannot bridge that.

Running the interpreter under the translation layer to match **also failed**,
because the FFI backend was itself already compiled for the native architecture
only. The mismatch relocated rather than resolved. Fixing it that way would
have meant reinstalling every native dependency under translation.

**The fix:** install a second, native package manager alongside the existing
one rather than replacing it, and set an explicit library path variable at
invocation, because the binding does not search the new prefix by default.

**The consequence that outlives the fix:** two package managers now coexist, so
which one is on the path matters permanently, and every future native
dependency needs an architecture check rather than an assumption. The failure
is a silent import-time error, not a clear message.

**The dependency-shape lesson that followed.** That native library is imported
lazily, inside the single function that needs it, so modules that do not need
it do not inherit its native dependency. One venture's entire pipeline
therefore runs with no native library at all. Where an awkward dependency
cannot be removed, it can at least be contained.

## The repository owns its interpreter

The system interpreter moved a minor version. The old framework build went with
it. A project that had been working for months stopped running entirely,
failing on a missing module that had been installed the whole time.

Every project now has its own virtual environment with a pinned requirements
file, and every command runs through it explicitly rather than through whatever
interpreter the shell resolves.

## What pinning exposed, which is the real finding

Pinning did not make builds reproducible. It made the limits of reproducibility
visible.

**Reproducibility holds within an environment, not across library versions.**
The same committed configuration, rebuilt under a newer interpreter and newer
numeric libraries, differed from the earlier build in **527 pixels out of
40,073,236**, with a mean difference of **0.0002**. Visually identical.
Different hash. The drift originated in one library's filtering routine, which
two independent stages of the pipeline both happen to run through.

So each build's manifest now records the interpreter and library versions that
produced **that** file, and "reproducible" is defined as same configuration
plus same environment.

That is the ordinary meaning of the word. But it had never been stated, and the
gate asserted a byte-identical rebuild without qualifying it. A future rebuild
that failed to match its original would have looked like corruption rather than
like a library upgrade.
