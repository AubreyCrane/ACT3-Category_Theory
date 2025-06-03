# This code is to answer excercises in chapter one in the book: Seven Sketches in Compositionality: "https://arxiv.org/abs/1803.05316"
#
# This code generates and visualizes a Hasse diagram for a given partially ordered set (poset).
# 
# The code is structured to compute partitions of sets, build the Hasse diagram, and visualize it using Plots.jl and GraphPlot.jl.
# 
# How to run:
#   - Execute the script in a Julia environment (e.g., using `julia scriptname.jl` or in a Julia REPL).
#
# How to look at the graphs:
#   - The Hasse diagram will be displayed in a graphical window if using a plotting package that supports GUI output (e.g., GraphPlot.jl, Plots.jl, or similar).
#   - If running in a Jupyter notebook, the graph will be shown inline.
#   - I had to look through the julia workspace to find the main figure (fig), and other two graphs (p2 and p4) that are generated.
#
# Where to change the inputs:
#   - To build bigger versions of the Hasse diagram, modify the definition of the poset elements and their ordering relation.
#   - Specifically, look for the section where the poset elements (e.g., a set, list, or array) and the partial order relation are defined.
#   - Increase the size or complexity of the poset in that section to generate larger diagrams.
#
# This code is part of the Catlab.jl package, which provides tools for categorical programming in Julia.
# And if anyone is somehow reading this, sorry for the poor quality of code
# The code is meant to be read through, as I incuded comments that explains the mathematics involved!

#######################################################################################

using Catlab
using Catlab.CategoricalAlgebra
using Catlab.WiringDiagrams
using Combinatorics
using Plots
using Graphs
using GraphPlot
using CairoMakie

# Helper function to check partition refinement (B ≤ A if B refines A, i.e., B is finer)
# Mathematically: B ≤ A if every block of A is a union of blocks of B
# Conceptually: Finer partitions (more blocks) are higher in the Hasse diagram
function refines(partition1, partition2)
    for block2 in partition2
        found = false
        block2_set = Set(block2)
        for block1 in partition1
            if block1 ⊆ block2_set
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
# where an arrow from system A to system B means A ≤ B. Such diagrams are known  as Hasse diagrams.
println("-------------------------------------------------------------------------------") #to seperate terminal outputs

set2 = [:dot, :star]
partitions2 = collect(partitions(set2))
println("Partitions of {•, ∗}:")
for (i, p) in enumerate(partitions2)
    println("Partition $i: $p")
end

# Compute Hasse diagram edges (B ≤ A if B refines A, direct cover)
edges2 = []
for i in 1:length(partitions2)
    for j in 1:length(partitions2)
        if i != j && refines(partitions2[j], partitions2[i])
            push!(edges2, (i, j))
        end
    end
end
println("Hasse diagram edges for {•, ∗}: $edges2")

# ASCII Hasse diagram because the visual one is ugly and upside down
println("\nHasse Diagram for {•, ∗}:")
println("  [[•],[∗]]  (P2)")
println("     ↑")
println("  [[•,∗]]  (P1)")

# Graphical Hasse diagram using Plots.jl and GraphPlot with custom layout
g2 = Graphs.Graph(2)
for (i, j) in edges2
    Graphs.add_edge!(g2, i, j)
end
labels2 = [replace(string(partitions2[i]), ":" => "") for i in 1:length(partitions2)]
node_pos2 = Dict{Int,Tuple{Float64,Float64}}()
for i in 1:length(partitions2)
    num_blocks = length(partitions2[i])
    y = num_blocks - 1
    x = i * 0.5
    node_pos2[i] = (x, y)
end
xs2 = [node_pos2[i][1] for i in 1:length(partitions2)]
ys2 = [node_pos2[i][2] for i in 1:length(partitions2)]
p2 = gplot(g2, xs2, ys2, nodelabel=labels2, arrowlengthfrac=0.05)
# Save to script directory
output_dir = @__DIR__
using Compose
# Ensure output directory exists, if not just look in the Julia Workspace
if !isdir(output_dir)
    mkpath(output_dir)
end
draw(SVG(joinpath(output_dir, "hasse_2_plots.svg"), 6inch, 4inch), p2)
println("Graphical Hasse diagram for {•, ∗} saved as hasse_2_plots.svg")

# Task 2: Partitions of {1, 2, 3, 4} and Hasse Diagram
# ---------------------------------------------------
set4 = [1, 2, 3, 4] # Set of elements to partition, (ignore error if you only want to see the graph)
partitions4 = collect(partitions(set4))
println("\nPartitions of {1, 2, 3, 4}:")
for (i, p) in enumerate(partitions4)
    println("Partition $i: $p")
end

# Compute Hasse diagram edges (direct covers)
edges4 = []
for i in 1:length(partitions4)
    for j in 1:length(partitions4)
        if i != j && refines(partitions4[j], partitions4[i])
            is_direct = true
            for k in 1:length(partitions4)
                if k != i && k != j && refines(partitions4[j], partitions4[k]) && refines(partitions4[k], partitions4[i])
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

# Summarized ASCII Hasse diagram (Redundant if visuaul diagram is used)
println("\nHasse Diagram for {1, 2, 3, 4} (summarized):")
println("Top: [[1],[2],[3],[4]] (P15, finest)")
println("  ↑ ... (multiple paths)")
println("Middle: e.g., [[1,2],[3,4]] (P7), [[1,3],[2,4]] (P9)")
println("  ↑ ... (multiple paths)")
println("Bottom: [[1,2,3,4]] (P1, coarsest)")
println("Note: Full diagram has ", length(edges4), " edges across 5 levels")

# Graphical Hasse diagram using Plots.jl and GraphPlot with custom layout (located in workspace as "fig")
g4 = Graphs.Graph(length(partitions4))
for (i, j) in edges4
    Graphs.add_edge!(g4, i, j)
end
labels4 = [replace(string(partitions4[i]), ":" => "") for i in 1:length(partitions4)] # Full partition labels
node_pos4 = Dict{Int,Tuple{Float64,Float64}}()
levels = Dict{Int,Vector{Int}}()
for i in 1:length(partitions4)
    num_blocks = length(partitions4[i])
    if haskey(levels, num_blocks)
        push!(levels[num_blocks], i)
    else
        levels[num_blocks] = [i]
    end
end
for num_blocks in keys(levels)
    node_ids = levels[num_blocks]
    for (idx, i) in enumerate(node_ids)
        y = (num_blocks - 1) * 1.5
        x = (idx - (length(node_ids) + 1) / 2) * 1.5
        node_pos4[i] = (x, y)
    end
end
xs4 = [node_pos4[i][1] for i in 1:length(partitions4)]
ys4 = [node_pos4[i][2] for i in 1:length(partitions4)]
p4 = gplot(g4, xs4, ys4, nodelabel=labels4, arrowlengthfrac=0.05)
# Save to script directory
draw(SVG(joinpath(output_dir, "hasse_4_plots.svg"), 12inch, 8inch), p4)
println("Graphical Hasse diagram for {1, 2, 3, 4} saved as hasse_4_plots.svg")

# Improved Hasse diagram using CairoMakie with full partition labels
fig = Figure(size=(900, 600))
ax = Axis(fig[1, 1], title="Partition Lattice Hasse Diagram for {1, 2, 3, 4}")
for (i, j) in edges4
    x1, y1 = node_pos4[i]
    x2, y2 = node_pos4[j]
    lines!(ax, [x1, x2], [y1, y2], color=:gray, linewidth=1)
end
for i in 1:length(partitions4)
    x, y = node_pos4[i]
    CairoMakie.scatter!(ax, [x], [y], color=:blue, markersize=16)
    # Use full partition label with rotation for readability
    label = replace(string(partitions4[i]), ":" => "")
    text!(ax, label, position=(x, y + 0.2), align=(:center, :bottom), fontsize=12, rotation=45)
end
hidedecorations!(ax)
autolimits!(ax)
# Save to script directory
save(joinpath(output_dir, "hasse_4_makie.png"), fig)
println("Improved Hasse diagram for {1, 2, 3, 4} saved as hasse_4_makie.png")


#######################################################################################
# This code is to answer additional excercises specific to the book: Seven Sketches in Compositionality: "https://arxiv.org/abs/1803.05316"

# Tasks 3-6: Analysis of Partitions A and B
# ----------------------------------------
A = partitions4[findfirst(p -> p == [[1, 2], [3, 4]], partitions4)]
B = partitions4[findfirst(p -> p == [[1, 3], [2, 4]], partitions4)]
println("\nChosen partitions from diagram: {1, 2, 3, 4}")
println("A: $A")
println("B: $B")

# Task 3: Compute A ∨ B (the join of A and B)
# the joined system A ∨ B is the smallest system that is bigger than both A and B. That is, A ≤ (A ∨ B) and B ≤ (A ∨ B),
join_AB = partition_join(A, B, set4)
println("A ∨ B: $join_AB")

# Task 4: Verify A ≤ (A ∨ B) and B ≤ (A ∨ B) as stated just above

a_leq_join = refines(join_AB, A)
b_leq_join = refines(join_AB, B)
println("A ≤ (A ∨ B): $a_leq_join")
println("B ≤ (A ∨ B): $b_leq_join")

# Task 5: Find all C where A ≤ C and B ≤ C.
# for any C, if A ≤ C and B ≤ C then (A ∨ B) ≤ C.
candidates_C = [p for p in partitions4 if refines(p, A) && refines(p, B)]
println("Partitions C where A ≤ C and B ≤ C: $candidates_C")

# Task 6: Verify (A ∨ B) ≤ C for each C
all_join_leq_C = all(refines(c, join_AB) for c in candidates_C)
println("(A ∨ B) ≤ C for all C: $all_join_leq_C")

# Task 7: Boolean Lattice {true, false}
boolean_pairs = [(true, false), (false, true), (true, true), (false, false)]
println("\nBoolean lattice joins:")
for (a, b) in boolean_pairs
    join = a || b
    println("$a ∨ $b = $join")
end

# Task 8: Generative Effects and Φ
# the map Φ preserves some structure but not others: it preserves order but not join
# If True (which in this case it will be) It means there WILL be genertaive effects
function Phi(partition, dot=:dot, star=:star)
    for block in partition
        if dot in block && star in block
            return true
        end
    end
    return false
end
A2 = [[[:dot]], [[:star]]]
B2 = [[[:dot]], [[:star]]]
join_A2_B2 = partition_join(A2, B2, set2)
phi_A = Phi(A2)
phi_B = Phi(B2)
phi_join = Phi(join_A2_B2)
phi_A_vee_phi_B = phi_A || phi_B
inequality_holds = phi_A_vee_phi_B <= phi_join
println("\nGenerative effect test for A and B:")
println("Φ(A) = $phi_A, Φ(B) = $phi_B, Φ(A ∨ B) = $phi_join")
println("Φ(A) ∨ Φ(B) ≤ Φ(A ∨ B): $inequality_holds")

# NOT explicitly an excercise in the book, this is to test the generative effect of Φ in {1, 2, 3, 4}
# -------------------------------------------------
# Task 9: Generative Effects and Φ for {1, 2, 3, 4}

# Define a map Φ₄: partitions of {1,2,3,4} → Bool
# For this example, let Φ₄(P) = true if 1 and 4 are in the same block of partition P, else false.
function Phi4(partition)
    for block in partition
        if 1 in block && 4 in block
            return true
        end
    end
    return false
end

# Compute Φ₄ for A, B, and their join
phi4_A = Phi4(A)
phi4_B = Phi4(B)
phi4_join = Phi4(join_AB)
phi4_A_vee_B = phi4_A || phi4_B
inequality_holds_4 = phi4_A_vee_B <= phi4_join

println("\nGenerative effect test for {1,2,3,4}:")
println("Φ₄(A) = $phi4_A, Φ₄(B) = $phi4_B, Φ₄(A ∨ B) = $phi4_join")
println("Φ₄(A) ∨ Φ₄(B) ≤ Φ₄(A ∨ B): $inequality_holds_4")
# This demonstrates that Φ₄, like Φ, preserves order but not necessarily join.
