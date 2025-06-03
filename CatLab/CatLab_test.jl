# Ensure Catlab.jl is installed: `] add Catlab` in Julia REPL
# Import necessary modules explicitly to avoid missing macro errors
using Catlab
using Catlab.CategoricalAlgebra
using Catlab.WiringDiagrams
using Catlab.Graphics

# Part 1: Basic Categories
# ------------------------
# Mathematically: A category consists of objects and morphisms with composition and identities.
# Conceptually: Models entities and their transformations (e.g., sets and functions, or processes).
# Expected Output: A printed morphism showing composition result (f ∘ id_B = f).

# Define a free category with objects A, B and morphism f: A → B
# Using FreeCategory avoids reliance on @syntax, ensuring compatibility
A, B = Ob(FreeCategory, :A), Ob(FreeCategory, :B)
f = Hom(:f, A, B)

# Identity morphisms
id_A = id(A)
id_B = id(B)

# Compose f with id_B; should simplify to f due to identity law
comp = compose(f, id_B)
println("Composed morphism (f ∘ id_B): ", comp)
# Expected Output: Composed morphism (f ∘ id_B): f

# Part 2: Functors
# ----------------
# Mathematically: A functor maps objects and morphisms between categories, preserving structure.
# Conceptually: A "translation" between systems, like mapping one data model to another.
# Expected Output: Printed results of functor applications, showing F maps A to X, f to g, etc.

# Define objects and morphisms for a target category
X, Y = Ob(FreeCategory, :X), Ob(FreeCategory, :Y)
g = Hom(:g, X, Y)

# Define a functor F: C → D mapping A → X, B → Y, f → g
function F(expr)
    if expr == A
        return X
    elseif expr == B
        return Y
    elseif expr == f
        return g
    elseif expr == id_A
        return id(X)
    elseif expr == id_B
        return id(Y)
    else
        error("Expression not mapped by functor F")
    end
end

# Verify functor properties
println("F(id_A): ", F(id_A))  # Expected: id(:X)
println("F(f): ", F(f))       # Expected: g
println("compose(F(f), F(id_B)): ", compose(F(f), F(id_B)))  # Expected: g

# Part 3: Monoidal Categories and Wiring Diagrams
# -----------------------------------------------
# Mathematically: Monoidal categories allow tensor products (⊗) for combining objects/morphisms.
# Conceptually: Models parallel systems (e.g., concurrent processes or circuits).
# Expected Output: Printed tensor product and braiding; wiring diagram visualization (if Graphviz is set up).

# Define objects P, Q in a symmetric monoidal category
P, Q = Ob(FreeSymmetricMonoidalCategory, :P), Ob(FreeSymmetricMonoidalCategory, :Q)

# Tensor product P ⊗ Q
PQ = otimes(P, Q)

# Define morphisms
m = Hom(:m, PQ, P)  # Like a projection
n = Hom(:n, Q, Q)   # Transformation on Q
p = Hom(:p, P, P)
q = Hom(:q, Q, Q)

# Tensor morphisms: p ⊗ q
p_tensor_q = otimes(p, q)
println("Tensor of p and q: ", p_tensor_q)
# Expected Output: Tensor of p and q: p ⊗ q

# Braiding σ_{P,Q}: P ⊗ Q → Q ⊗ P
sigma_PQ = braid(P, Q)
println("Braiding σ_{P,Q}: ", sigma_PQ)
# Expected Output: Braiding σ_{P,Q}: σ_{P,Q}


# Everything below this is allll screwed up, but it should be fine???? need to better understand part three as well.


# Wiring diagram: Represents f: P → Q graphically
d = WiringDiagram([], [:P], [:Q])
box = add_box!(d, Box(:f, [:P], [:Q]))
add_wires!(d, [(input_id(d), 1) => (box, 1), (box, 1) => (output_id(d), 1)])
# To visualize (requires Graphviz and Catlab.Graphics):
# println("Run `to_graphviz(d, orientation=LeftToRight)` in a Jupyter notebook for visualization")
# Expected Output (if visualized): A simple diagram with a box labeled 'f' from input P to output Q

# Note: If running in a terminal, visualization requires a graphical environment (e.g., Jupyter)