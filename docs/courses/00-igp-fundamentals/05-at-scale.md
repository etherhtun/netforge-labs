# 5 · IGPs at Hyper-Scale

Everything you've learned so far is true for enterprise networks, service providers, and data centers of normal size. But if your goal is a network engineering role at a hyper-scaler (Google, AWS, Meta), the rules change. 

When you operate tens of thousands of routers, traditional link-state protocols begin to break down. Here is how FAANG networks think about IGPs, and why they often redesign them out of existence.

---

## The limits of link-state

Link-state protocols (OSPF and IS-IS) scale well, but they don't scale infinitely. They are fundamentally bottlenecked by three things:

### 1. Flooding overhead (The Blast Radius)
In a link-state area, every router must have an identical copy of the database. When a link flaps, an LSA/LSP is generated and flooded to *every* router in that area. 
If you have a 1,000-switch Clos fabric (spine-leaf), a single link flap creates a shockwave of updates. In a hyper-scale data center, link flaps happen every minute. If you run a single OSPF area across a massive fabric, your routers will spend all their CPU processing flooded updates rather than forwarding packets.

### 2. SPF computation time
Dijkstra's algorithm is $O(E \log V)$ where $V$ is vertices (routers) and $E$ is edges (links). In a densely connected Clos topology with hundreds of spines and thousands of leaves, the number of edges is astronomical. Running a full SPF computation on that graph takes significant CPU time and memory.

### 3. Distributed state is hard to reason about
Link-state routing is fully distributed: every router makes its own decisions independently based on its local copy of the database. If there is a bug in the SPF implementation on one vendor's switch, or if an LSP gets corrupted in transit, routers will compute different paths. This creates micro-loops that are notoriously difficult to troubleshoot at scale because the network is acting on a lie.

---

## The FAANG solutions

When you hit the limits of link-state, you have two choices: change the topology, or change the protocol. Hyper-scalers do both.

### Replacing the IGP with BGP (The Jupiter Approach)

In 2012, Google published a paper on **Jupiter**, their data center fabric architecture. One of the most famous takeaways was that **they didn't use an IGP at all.**

Instead of OSPF or IS-IS, Jupiter uses **eBGP as the underlay** everywhere (from Top-of-Rack to Spine). 

Why eBGP?
- **Distance-vector acts as a firewall for failures:** BGP only sends updates to its direct peers, and it only advertises its *best* path. It doesn't flood the entire topology. This severely limits the blast radius of a flapping link.
- **No shared database:** Routers don't need to know the entire topology; they only need to know the next hop.
- **Traffic Engineering:** BGP's policy engine (route maps, AS-path prepending, communities) is infinitely more flexible than OSPF's metric manipulation.

This design (RFC 7938: Use of BGP for Routing in Large-Scale Data Centers) became the blueprint for modern data centers. If you are asked in a FAANG interview how to route a 50,000-server data center, the expected answer is eBGP, not OSPF.

### Centralized Control (SDN and B4)

Google's global WAN, **B4**, carries more traffic than the public internet. But unlike a traditional ISP backbone running massive IS-IS areas, B4 uses Software-Defined Networking (SDN).

In an SDN architecture, the "brain" (control plane) is separated from the "muscle" (data plane). 
1. The routers still run a lightweight IGP (like IS-IS or OSPF) to discover their direct neighbors and provide basic reachability.
2. A **centralized controller** ingests this topology graph.
3. The controller, having a global view of all traffic demands and link capacities, computes the optimal paths for every flow.
4. It programs the forwarding tables of the routers directly (using OpenFlow, P4, or segment routing).

In this model, the IGP isn't making routing decisions; it's just a telemetry mechanism to discover the physical graph.

### Segment Routing (SR-MPLS / SRv6)

Even when hyper-scalers use IGPs, they use them differently. **Segment Routing** allows a source node to dictate the path a packet takes through the network by stacking labels (or IPv6 headers) onto the packet itself.

Instead of running complex RSVP-TE protocols to build tunnels, hyper-scalers just add SR extensions to IS-IS. IS-IS distributes the node labels, and the centralized controller tells the ingress router which stack of labels to push. The core network becomes completely stateless—it just forwards based on the top label.

This is why **IS-IS** is overwhelmingly preferred over OSPF in modern hyper-scale WANs: its TLV structure made it trivial to add Segment Routing extensions.

---

## The takeaway for interviews

If you are interviewing for a network engineering role at a tech giant, you must demonstrate that you understand **scale**. 

- Never propose a single OSPF area for a network with thousands of routers. 
- Be ready to discuss the trade-offs between distributed protocols (OSPF/IS-IS) and distance-vector protocols (BGP) regarding blast radius and convergence.
- Understand that in modern architectures, the IGP's job is often just to get you to the BGP next-hop or the SDN controller, not to route the user's traffic.
