% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotGMPhyloMorphoSpace.r
\name{plotGMPhyloMorphoSpace}
\alias{plotGMPhyloMorphoSpace}
\title{Plot phylogenetic tree and specimens in tangent space}
\usage{
plotGMPhyloMorphoSpace(phy, A, tip.labels = TRUE, node.labels = TRUE,
  ancStates = TRUE, xaxis = 1, yaxis = 2, zaxis = NULL,
  plot.param = list(), shadow = FALSE)
}
\arguments{
\item{phy}{A phylogenetic tree of {class phylo} - see \code{\link[ape]{read.tree}} in library ape}

\item{A}{A matrix (n x [p x k]) or 3D array (p x k x n) containing Procrustes shape variables for a set of specimens}

\item{tip.labels}{A logical value indicating whether taxa labels (tips) should be included}

\item{node.labels}{A logical value indicating whether node labels (ancestors) should be included}

\item{ancStates}{Either a logical value indicating whether ancestral state values should be returned, or a matrix of ancestral states (i.e. calculated with \code{\link[phytools]{fastAnc}} or \code{\link[ape]{ace}})}

\item{xaxis}{A numeric value indicating which PC axis should be displayed as the X-axis (default = PC1)}

\item{yaxis}{A numeric value indicating which PC axis should be displayed as the Y-axis (default = PC2)}

\item{zaxis}{Optional, a numeric value indicating which PC axis should be displayed as the Z-axis (e.g. PC3) or if zaxis="time", 
internal nodes are plotted along the Z-axis relative to time}

\item{plot.param}{A list of plotting parameters for the tips (t.bg, t.pch, t.cex), nodes (n.bg, n.pch, n.cex), 
branches (l.col, lwd), taxa labels (txt.cex, txt.adj, txt.col) and node labels (n.txt.cex, n.txt.adj, n.txt.col)}

\item{shadow}{A logical value indicating whether a 2D phylomorphospace should be plotted at the base when zaxis="time"}
}
\value{
Function returns estimated ancestral states if {ancStates=TRUE}
}
\description{
Function plots a phylogenetic tree and a set of Procrustes shape variables in tangent space
}
\details{
The function creates a plot of the principal dimensions of tangent space for a set of Procrustes shape variables. 
Default is a plot of PC axis 1 and 2. The phylogenetic tree for these specimens is superimposed in this plot revealing how shape 
  evolves (e.g., Rohlf 2002; Klingenberg and Gidaszewski 2010). The plot also displays the ancestral 
  states for each node of the phylogenetic tree (analogous to from \code{\link[phytools]{fastAnc}} from phytools), whose values can optionally be returned. 
  If a tree with branch lengths scaled by time is used, with the option zaxis = "time", the function plots a 3D phylomorphospace, with internal nodes positioned along the Z-axis scaled 
  to time (a.k.a. Chronophylomorphospace, Sakamoto & Ruta 2012).
}
\examples{
data(plethspecies) 
Y.gpa<-gpagen(plethspecies$land)    #GPA-alignment    

plotGMPhyloMorphoSpace(plethspecies$phy,Y.gpa$coords)
plotGMPhyloMorphoSpace(plethspecies$phy,Y.gpa$coords, 
                 plot.param=list(t.bg="blue",txt.col="red",n.cex=1))
#NOTE: 3D plot also available: plotGMPhyloMorphoSpace(plethspecies$phy,Y.gpa$coords, zaxis= "time",
#                 plot.param=list(n.cex=2, n.bg="blue"), shadow=TRUE)
}
\references{
Klingenberg, C. P., and N. A. Gidaszewski. 2010. Testing and quantifying phylogenetic 
  signals and homoplasy in morphometric data. Syst. Biol. 59:245-261.

Rohlf, F. J. 2002. Geometric morphometrics and phylogeny. Pp.175-193 in N. Macleod, and
  P. Forey, eds. Morphology, shape, and phylogeny. Taylor & Francis, London.

Sakamoto, M. and Ruta, M. 2012. Convergence and Divergence in the Evolution of Cat
Skulls: Temporal and Spatial Patterns of Morphological Diversity. PLoSONE 7(7): e39752.
}
\seealso{
\code{\link[ape]{vcv.phylo}}, \code{\link[ape]{ace}} (used in some internal computations)

\code{\link[rgl]{rgl-package}} (used in 3D plotting)
}
\author{
Dean Adams & Emma Sherratt
}
\keyword{visualization}
