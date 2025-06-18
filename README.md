# PARIST-Trial Workflow • Severe-Malaria AKI Project
<!-- Badges -->
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15689409.svg)](https://doi.org/10.5281/zenodo.15689409)
[![GitHub release](https://img.shields.io/github/v/release/gpaasi/paracetamol-for-AKI-PARIST-trial-work-flow?include_prereleases&sort=semver)](https://github.com/gpaasi/paracetamol-for-AKI-PARIST-trial-work-flow/releases)
[![Code style: styler](https://img.shields.io/badge/code%20style-styler-blueviolet.svg)](https://github.com/r-lib/styler)
[![Made with R](https://img.shields.io/badge/Made%20with-R-1f425f.svg)](https://www.r-project.org/)


End-to-end, reproducible code + text for the manuscript  
**“Paracetamol for Renal Recovery in Severe Malaria (PARIST Trial)”**

---

## 📑 Table of contents
1. [Project scope](#project-scope)  
2. [Folder structure](#folder-structure)  
3. [Quick-start](#quick-start)  
4. [Re-running the full pipeline](#pipeline)  
5. [Continuous integration](#ci)  
6. [Authorship & contributions](#contributions)  
7. [Data governance](#data-governance)  
8. [License & citation](#license--citation)  
9. [Contact](#contact)

---

## Project scope
This repository is the **single source of truth** for:

* De-identified analysis datasets  
* R scripts and R Markdown notebooks  
* Auto-generated figures & tables  
* The manuscript in markdown/LaTeX (rendered to PDF & HTML)  
* GitHub Actions CI to guarantee that analyses and rendering are repeatable

> **Why a public workflow?**  
> Releasing code and de-identified data (+ exact package versions via `renv`) fulfils FAIR-data principles, improves transparency, and accelerates follow-up research.

---

## Folder structure
```

parist-trial-workflow/
├── analysis/          # R scripts & notebooks
│   ├── 01\_data-cleaning.R
│   ├── 02\_descriptive.Rmd
│   ├── 03\_RMST\_analysis.R        <- primary analysis
│   └── utils/plot\_theme.R
├── data/
│   ├── raw/            # 🔒 not in git (see .gitignore)
│   └── derived/        # de-identified CSVs shared openly
├── manuscript/
│   ├── PARIST\_manuscript.Rmd
│   ├── references.bib
│   └── journal-template.tex
├── figures/            # auto-generated PNG/PDF/SVG
├── docs/               # rendered manuscript (CI artifact / GitHub Pages)
├── archive/            # original Word files & approvals
├── .github/workflows/ci.yml
├── renv.lock           # pinned R package versions
├── LICENSE  |  CITATION.cff
└── README.md           # you are here

````

---

## Quick-start
### Clone and recreate the R environment
```bash
git clone https://github.com/<ORG>/parist-trial-workflow.git
cd parist-trial-workflow

# one-liner to restore exact packages
R -q -e "install.packages('renv'); renv::restore()"
````

### Run the primary analysis

```bash
Rscript analysis/03_RMST_analysis.R
```

### Render the manuscript locally

```bash
R -q -e "rmarkdown::render('manuscript/PARIST_manuscript.Rmd',
                           output_dir = 'docs')"
open docs/PARIST_manuscript.pdf
```

---

<a name="pipeline"></a>

## Re-running the full pipeline

| Stage                             | Script / tool         | Output                                                             |
| --------------------------------- | --------------------- | ------------------------------------------------------------------ |
| 1  Import & clean                 | `01_data-cleaning.R`  | `data/derived/parist_analysis_set.csv`                             |
| 2  Descriptive stats              | `02_descriptive.Rmd`  | `figures/Table1.png`                                               |
| 3  Primary RMST + adjusted models | `03_RMST_analysis.R`  | `figures/Fig2_RMST_curve.pdf`, `analysis/results/rmst_summary.csv` |

The **CI workflow** executes exactly these steps on every push / PR to guarantee reproducibility.

---

<a name="ci"></a>

## Continuous integration

`.github/workflows/ci.yml`:

1. Checks out the repo.
2. Restores the `renv` cache.
3. Runs analysis scripts; fails if any exit non-zero.
4. Renders the manuscript to PDF.
5. Uploads artifacts & (optionally) deploys `docs/` to GitHub Pages.

Status badge at the top of this README shows the latest build.

---

<a name="contributions"></a>

## Authorship & contributions

We adopt the **CRediT** taxonomy.
Example (edit as needed):

| Author | Contribution(s)                                          |
| ------ | -------------------------------------------------------- |
| A.B.   | Conceptualization, Methodology, Writing – original draft |
| C.D.   | Formal analysis, Software, Visualization                 |
| E.F.   | Investigation, Data curation                             |
| G.H.   | Supervision, Funding acquisition                         |

➡️ **How to contribute:**

1. Create a feature branch: `git checkout -b feat/<slug>`
2. Commit with Conventional Commit prefix (`feat:`, `fix:`, `docs:`…)
3. Open a Pull Request; CI must be green & 2 reviews obtained.
4. Squash-merge to `main`.

---

<a name="data-governance"></a>

## Data governance

| Data tier             | Location                    | Policy                            |
| --------------------- | --------------------------- | --------------------------------- |
| Raw identifiable      | Institution file-share only | Never pushed to GitHub            |
| Derived de-identified | `data/derived/`             | Commit OK; shared under CC-BY 4.0 |
| Post-acceptance       | Zenodo / Mendeley Data      | DOI back-linked here              |

Corresponding author stores the encryption key for raw ↔︎ derived mapping.

---

<a name="license--citation"></a>

## License & citation

* **Code:** MIT License – see `LICENSE`.
* **Text & figures:** Creative Commons CC-BY 4.0.

A ready-made `CITATION.cff` lets GitHub generate a citation snippet.
When citing, please use the DOI badge at the top of this README once minted.

---

<a name="contact"></a>

## Contact

*Corresponding author:*
**Dr Paasi George** – [georgepaasi8@gmail.com)

For issues or feature requests open a GitHub Issue or start a Discussion.

---

**Happy analysing – and thanks for advancing open, reproducible clinical science!**

```

> **How to use**  
> 1. Copy the text above into `README.md`.  
> 2. Replace placeholders (`<ORG>`, `<Your Name>`, DOIs, e-mails).  
> 3. Commit and push – the badges will render automatically once the repo is online and CI is enabled.
```
