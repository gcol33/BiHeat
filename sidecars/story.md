# Story: BiHeat

## Claim
Draws two matrices of the same shape in one ggplot2 heatmap by splitting each cell along a diagonal, one matrix per triangle, each with its own colour gradient.

## Audience
R users comparing two matrices over the same rows and columns (observed and predicted, mean and variance, correlation and significance); familiar with ggplot2.

## Relation
- to: none (neighbours: corrplot's `corrplot.mixed()`, ComplexHeatmap's custom `cell_fun`)

## Arcs

### A1 Two matrices in one heatmap
- question: how do I show two matrices so cells can be compared directly?
- answer: `biheat(upper, lower)` splits each cell along a diagonal
- payoff: one figure, comparison per cell
- evidence: tests/testthat, vignettes/biheat.Rmd
- home: vignettes/biheat.Rmd (Getting started with BiHeat)
- also: README Usage

### A2 Pairing, aligning and summarising
- question: what if row and column names differ, and how close are the matrices?
- answer: `breed()` aligns on shared names and reports correlation, RMSE, MAE and NA counts; `incubate()` and the verbs adjust rendering
- home: vignettes/biheat.Rmd
- also: README "Pairing, styling and drawing in steps"

### A3 Separate or shared scales
- question: are the two colour scales comparable?
- answer: `scale = "separate"` (default) or `"shared"`
- home: vignettes/biheat.Rmd (Separate and shared colour scales)
- also: README "Separate or shared colour scales"

### A4 Split cells inside a ggplot
- question: can I use it as a layer with facets and other geoms?
- answer: `geom_biheat()` on `comes_out()` data; the fill scale stays free
- home: vignettes/geom-biheat.Rmd (Split cells inside a ggplot)
- also: README "Split cells inside a ggplot"

## Non-goals
- Clustering, dendrograms and annotation tracks.

## Documents
- DESCRIPTION: claim
- README / landing: claim, first plot, one section per arc, routing
- Getting started with BiHeat: tutorial
- Styling and layout: palettes, scales, legend and layout options
- Split cells inside a ggplot: the layer
- help pages: reference
