using Documenter, DocumenterCodeBlocks, TinyGismo

const liveserver = "liveserver" in ARGS
const is_ci = haskey(ENV, "GITHUB_ACTIONS")

if liveserver
    using Revise
    Revise.revise()
end

DocMeta.setdocmeta!(TinyGismo, :DocTestSetup, :(using TinyGismo); recursive = true)

makedocs(;
    format = Documenter.HTML(;
        canonical = "https://github.com/henrij22/TinyGismo.jl/stable",
        collapselevel = 1
    ),
    repo = Documenter.Remotes.GitHub("henrij22", "TinyGismo.jl"),
    plugins = [CodeBlocks()],
    modules = [TinyGismo],
    sitename = "TinyGismo documentation",
    warnonly = true, checkdocs = :none,
    pages = [
        "Home" => "index.md",
        "Examples" => [
            "Examples overview" => "02_examples/00_index.md",
            "02_examples/01_geometries.md",
            "02_examples/02_tensor_bsplines.md",
            "02_examples/03_refinement.md",
            "02_examples/04_evaluation.md",
        ],
        "API Reference" => [
            "Reference overview" => "01_api_reference/00_index.md",
            "01_api_reference/01_knotvector.md",
            "01_api_reference/02_basis.md",
            "01_api_reference/03_geometries.md",
            "01_api_reference/04_factories.md",
            "01_api_reference/05_utilities.md",
            "01_api_reference/06_io.md",
        ],
    ]
)

if !liveserver
    deploydocs(;
        repo = "github.com/henrij22/TinyGismo.jl.git",
        push_preview = true,
        versions = [
            "stable" => "v^",
            "dev" => "dev",
        ]
    )
end
