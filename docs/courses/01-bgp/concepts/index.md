# BGP concepts

Short primers on the parts of BGP that labs alone don't teach well — the state
machine, the attributes, the best-path algorithm, and the policy tooling that makes
BGP a policy protocol rather than a routing one.

Read these before [Lab 01](../lab-01-ebgp-ibgp.md), alongside it, or as revision.
Output shown is captured from the running lab fabric.

---

<div class="grid cards" markdown>

-   **[1 · How BGP works](01-how-bgp-works.md)**

    ---

    The finite state machine, the four message types, and the timers. Why BGP is
    deliberately slow, and what each state failure actually tells you.

-   **[2 · Path attributes](02-attributes.md)**

    ---

    Well-known, discretionary, optional transitive — what the categories mean and
    why they exist. Then each attribute you'll actually manipulate.

-   **[3 · Best-path selection](03-path-selection.md)**

    ---

    The eleven-step algorithm, in order, with the reason for each step. The single
    most-asked BGP interview topic.

-   **[4 · Policy and filtering](04-policy.md)**

    ---

    Prefix lists, route maps, communities — and the operational safety controls
    (max-prefix, GTSM, BFD) that keep a peering from taking you down.

-   **[5 · Scaling iBGP](05-scaling.md)**

    ---

    Route reflectors and confederations: why the full mesh doesn't scale, and the
    loop-prevention that replaces it.

-   **[Interview questions](interview-questions.md)**

    ---

    Self-test bank across the whole phase.

</div>

---

## The one-paragraph summary

BGP doesn't find the shortest path — it finds the path **you said you wanted**.
Every route carries a set of attributes; your policy sets and reads them; a fixed
algorithm compares them in a fixed order and picks a winner. Understand the
attributes and the order they're compared in, and BGP stops being mysterious.
