# Import necessary modules
using Catlab
using Catlab.CategoricalAlgebra
using Catlab.WiringDiagrams
using Catlab.Graphics
using Catlab.Graphics.Graphviz
using Combinatorics

# Helper function to check partition refinement (A ≤ B if A refines B)
# Mathematically: A ≤ B if every block of A is a subset of some block of B
# Conceptually: A finer partition (more blocks) refines a coarser one (fewer blocks)
function refines(partition1, partition2)
    for block1 in partition1
        found = false
        for block2 in partition2
            if all(x in block2 for x in block1)
                found = true
                break
            end
        end
        if !found
            return false
        end
    end
    return true
end

# Helper function to compute the join of two partitions
# Mathematically: A ∨ B is the coarsest partition refining both A and B
# Conceptually: Merges blocks connected through A or B
function partition_join(partition1, partition2, set_elements)
    edges = Set{Tuple{Any,Any}}()
    for partition in [partition1, partition2]
        for block in partition
            for i in block, j in block
                if i < j
                    push!(edges, (i, j))
                end
            end
        end
    end
    parent = Dict(i => i for i in set_elements)
    function find(x)
        if parent[x] != x
            parent[x] = find(parent[x])
        end
        parent[x]
    end
    function union(x, y)
        parent[find(x)] = find(y)
    end
    for (i, j) in edges
        union(i, j)
    end
    components = Dict()
    for x in set_elements
        root = find(x)
        if haskey(components, root)
            push!(components[root], x)
        else
            components[root] = [x]
        end
    end
    return collect(values(components))
end

# Task 1: Partitions of {•, ∗} and Hasse Diagram
# ---------------------------------------------
# Mathematically: Partitions form a lattice ordered by refinement
# Conceptually: Shows clustering possibilities and their hierarchy
# Expected Output: Partitions, edges, ASCII diagram, and PNG file (hasse_2.png)
set2 = [:bullet, :star]
partitions2 = collect(partitions(set2))
println("Partitions of {:bullet, :star}:")
for (i, p) in enumerate(partitions2)
    println("Partition $i: $p")
end
# Output: [[:bullet, :star]], [[:bullet], [:star]]

# Compute Hasse diagram edges (A ≤ B if A refines B, direct cover)
edges2 = []
for i in 1:length(partitions2)
    for j in 1:length(partitions2)
        if i != j && refines(partitions2[i], partitions2[j])
            push!(edges2, (i, j))
        end
    end
end
println("Hasse diagram edges for {•, ∗}: $edges2")
# Expected: [(1, 2)] ([[•, ∗]] ≤ [[•], [∗]])

# ASCII Hasse diagram
println("\nHasse Diagram for {:bullet, :star}:")
println("  [[:bullet],[:star]]  (P2)")
println("     ↑")
println("  [[:bullet,:star]]  (P1)")
# Represents: [[:bullet, :star]] (bottom, coarser) → [[:bullet], [:star]] (top, finer)

# Graphical Hasse diagram using Graphviz.Graph
nodes2 = [Graphviz.Node("P$i", Dict("label" => replace(string(partitions2[i]), ":" => ""))) for i in 1:length(partitions2)]
edges2_gv = [Graphviz.Edge(["P$i", "P$j"]) for (i, j) in edges2]
graph2 = Graphviz.Graph("hasse_2", true, "dot", Graphviz.Statement[nodes2; edges2_gv], Dict("rankdir" => "BT"))
run_graphviz("hasse_2.png", graph2, format="png")
println("Hasse diagram for {•, ∗} saved as hasse_2.png")

# Task 2: Partitions of {1, 2, 3, 4} and Hasse Diagram
# ---------------------------------------------------
# Mathematically: 15 partitions (Bell number B_4), ordered by refinement
# Conceptually: Models all ways to cluster 4 elements
# Expected Output: Partitions, edges, summarized ASCII diagram, and PNG file (hasse_4.png)
set4 = [1, 2, 3, 4]
partitions4 = collect(partitions(set4))
println("\nPartitions of {1, 2, 3, 4}:")
for (i, p) in enumerate(partitions4)
    println("Partition $i: $p")
end
# Output: 15 partitions, e.g., [[1,2,3,4]], ..., [[1],[2],[3],[4]]

# Compute Hasse diagram edges (direct covers)
edges4 = []
for i in 1:length(partitions4)
    for j in 1:length(partitions4)
        if i != j && refines(partitions4[i], partitions4[j])
            is_direct = true
            for k in 1:length(partitions4)
                if k != i && k != j && refines(partitions4[i], partitions4[k]) && refines(partitions4[k], partitions4[j])
                    is_direct = false
                    break
                end
            end
            if is_direct
                push!(edges4, (i, j))
            end
        end
    end
end
println("Hasse diagram edges for {1, 2, 3, 4}: $edges4")

# Summarized ASCII Hasse diagram
println("\nHasse Diagram for {1, 2, 3, 4} (summarized):")
println("Top: [[1],[2],[3],[4]] (P15, finest)")
println("  ↑ ... (multiple paths)")
println("Middle: e.g., [[1,2],[3,4]] (P7), [[1,3],[2,4]] (P9)")
println("  ↑ ... (multiple paths)")
println("Bottom: [[1,2,3,4]] (P1, coarsest)")
println("Note: Full diagram has ", length(edges4), " edges across 5 levels")

# Graphical Hasse diagram using Graphviz.Graph
nodes4 = [Graphviz.Node("P$i", Dict("label" => string(partitions4[i]))) for i in 1:length(partitions4)]
edges4_gv = [Graphviz.Edge(["P$i", "P$j"]) for (i, j) in edges4]
graph4 = Graphviz.Graph("hasse_4", true, "dot", Graphviz.Statement[nodes4; edges4_gv], Dict("rankdir" => "BT"))
run_graphviz("hasse_4.png", graph4, format="png")
println("Hasse diagram for {1, 2, 3, 4} saved as hasse_4.png")

# Tasks 3-6: Analysis of Partitions A and B
# ----------------------------------------
# Choose A = [[1,2],[3,4]], B = [[1,3],[2,4]]
A = partitions4[findfirst(p -> p == [[1,2],[3,4]], partitions4)]
B = partitions4[findfirst(p -> p == [[1,3],[2,4]], partitions4)]
println("\nChosen partitions:")
println("A: $A")
println("B: $B")

# Task 3: Compute A ∨ B
# Mathematically: Coarsest partition refining both A and B
# Conceptually: Merges clusters based on connections
join_AB = partition_join(A, B, set4)
println("A ∨ B: $join_AB")
# Expected: [[1,2,3,4]]

# Task 4: Verify A ≤ (A ∨ B) and B ≤ (A ∨ B)
# Mathematically: A ≤ C if A refines C
# Conceptually: Join is coarser than both inputs
a_leq_join = refines(A, join_AB)
b_leq_join = refines(B, join_AB)
println("A ≤ (A ∨ B): $a_leq_join")
println("B ≤ (A ∨ B): $b_leq_join")
# Expected: true, true

# Task 5: Find all C where A ≤ C and B ≤ C
# Mathematically: Partitions coarser than both A and B
# Conceptually: Compatible clusterings
candidates_C = [p for p in partitions4 if refines(A, p) && refines(B, p)]
println("Partitions C where A ≤ C and B ≤ C: $candidates_C")
# Expected: Includes [[1,2,3,4]]

# Task 6: Verify (A ∨ B) ≤ C for each C
# Mathematically: A ∨ B is the least element ≥ A and B
# Conceptually: Minimal solution combining A and B
all_join_leq_C = all(refines(join_AB, c) for c in candidates_C)
println("(A ∨ B) ≤ C for all C: $all_join_leq_C")
# Expected: true

# Task 7: Boolean Lattice {true, false}
# ------------------------------------
# Mathematically: Order false ≤ true; join is logical OR
# Conceptually: Models implication
boolean_pairs = [(true, false), (false, true), (true, true), (false, false)]
println("\nBoolean lattice joins:")
for (a, b) in boolean_pairs
    join = a || b
    println("$a ∨ $b = $join")
end
# Expected: true, true, true, false

# Task 8: Generative Effects and Φ
# -------------------------------
# Mathematically: Φ maps partitions to {true, false} based on connectivity
# Conceptually: Tests functor properties and emergent behavior
function Phi(partition, dot=:bullet, star=:star)
    for block in partition
        if :bullet in block && :star in block
            return true
        end
    end
    return false
end

# Test generative effect for A = [[:bullet],[:star]], B = [[:bullet],[:star]]
A2 = [[:bullet], [:star]]
B2 = [[:bullet], [:star]]
join_A2_B2 = partition_join(A2, B2, set2)
phi_A = Phi(A2)
phi_B = Phi(B2)
phi_join = Phi(join_A2_B2)
phi_A_vee_phi_B = phi_A || phi_B
inequality_holds = phi_A_vee_phi_B <= phi_join
println("\nGenerative effect test:")
println("Φ(A) = $phi_A, Φ(B) = $phi_B, Φ(A ∨ B) = $phi_join")
println("Φ(A) ∨ Φ(B) ≤ Φ(A ∨ B): $inequality_holds")
# Expected: Φ(A) = false, Φ(B) = false, Φ(A ∨ B) = true, inequality = true
