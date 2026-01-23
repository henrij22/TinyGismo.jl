using Documenter, TinyGismo

const liveserver = "liveserver" in ARGS
const is_ci = haskey(ENV, "GITHUB_ACTIONS")

if liveserver
    using Revise
    Revise.revise()
end

makedocs(;
    format = Documenter.HTML(;
        canonical = "https://github.com/henrij22/TinyGismo.jl/stable",
        collapselevel = 1
    ),
    repo = Documenter.Remotes.GitHub("henrij22", "TinyGismo.jl"),
    modules = [TinyGismo],
    sitename = "TinyGismo documentation",
    warnonly = true, checkdocs = :none,
    pages = [
        "index.md",
        "API Reference" => [
            "Reference overview" => "01_api_reference/00_index.md",
            "01_api_reference/01_knotvector.md",
            "01_api_reference/02_basis.md",
            "01_api_reference/03_geometries.md",
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
