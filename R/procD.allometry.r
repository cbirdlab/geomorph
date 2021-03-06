#' Procrustes ANOVA/regression, specifically for shape-size covariation (allometry)
#'
#' Function performs Procrustes ANOVA with permutation procedures to facilitate visualization of size-shape patterns (allometry);
#' i.e., patterns of shape covariation with size for a set of Procrustes shape variables.  Results for plotting allometric
#' patterns based on several approaches in the literature are available.
#'
#' The function quantifies the relative amount of shape variation attributable to covariation with organism size (allometry)
#' plus (potentially) another grouping factor in a linear model, so as to provide initial visualizations of patterns of shape allometry. 
#' Data input is specified by formulae (e.g., Y ~ X), where 'Y' specifies the response variables (Procrustes shape variables), 
#' and 'X' contains A SINGLE independent continuous variable representing size. The response matrix 'Y' can be 
#' either in the form of a two-dimensional data matrix of dimension (n x [p x k]), or a 3D array (p x n x k).  It is assumed that  
#' -if the data are based on landmark coordinates - the landmarks have previously been aligned using Generalized Procrustes Analysis (GPA) 
#'   [e.g., with \code{\link{gpagen}}].  Additionally, one has the option of providing a second formula where groups are specified
#'   in the form of ~ group. If groups are provided a "homogeneity of slopes" test will be performed. 
#'   
#'   It is assumed that the order of the specimens in the shape matrix matches the order of values in the independent variables.  
#'   Linear model fits (using the  \code{\link{lm}} function) can also be input in place of formulae.  
#'   Arguments for \code{\link{lm}} can also be passed on via this function.  For further information about ANOVA in geomorph, resampling
#'   procedures used, and output, see \code{\link{procD.lm}} or \code{\link{advanced.procD.lm}}.
#'   If greater flexibility is required for variable order, \code{\link{advanced.procD.lm}} should be used.
#'   
#'   It is strongly recommended that \code{\link{geomorph.data.frame}} is used to create and input a data frame.  This will reduce 
#'   problems caused by conflicts between the global and function environments.  In the absence of a specified data frame,
#'    \code{\link{procD.allometry}} will attempt to coerce input data into a data frame, but success is not guaranteed.
#'
#'   The generic functions, \code{\link{print}}, \code{\link{summary}}, and \code{\link{plot}} all work with \code{\link{procD.allometry}}.
#'   The generic function, \code{\link{plot}}, produces plots of allometric curves, using one of  three methods input (see below).
#'   If diagnostic plots on model residuals are desired, \code{\link{procD.lm}} should be used with the resulting model formula.  
#'   This, along with the data frame resulting from analysis with \code{\link{procD.allometry}} can be used directly in \code{\link{procD.lm}},
#'   which might be useful for extracting ANOVA components (as \code{\link{procD.allometry}} 
#'   is far more basic than \code{\link{procD.lm}}, in terms of output).  
#'   
#'   \subsection{A note on allometric models}{ 
#'   This function is intended to be used for the graphical visualization of simple allometric patterns. The method is appropriate for
#'   models such as shape~log(size) and shape~log(size) + groups.  Three plotting options, the common allometric coefficient (CAC), 
#'   regression scores (RegScore), and predicted lines (PredLine) are implemented as originally described in the literature. NOTE however
#'   that for more complex models with additional parameters, one may instead wish to use the plotting capabilities that accompany 
#'   \code{\link{procD.lm}} (see below for more details).
#'   }
#'   
#'   \subsection{Notes for experienced or advanced users}{ 
#'   Experienced or advanced users will probably prefer using
#'   \code{\link{procD.lm}} with a combination of \code{\link{plot.procD.lm}}, \code{\link{shape.predictor}}, and \code{\link{plotRefToTarget}}
#'   for publication-quality analyses and graphics.  As stated above, use of procD.allometry is for visualizing simple allometric models 
#'   that do not contain additional covariates. Thus, procD.allometry may be thought of as a wrapper function for \code{\link{procD.lm}},
#'   but only for a restricted set of models and using a philosophy for model selection based on the outcome of a homogeneity of slopes 
#'   test.  This is not necessary if one wishes to define a model, irrespective of this outcome, or if more complex models are of interest.
#'   In these circumstances  \code{\link{procD.lm}} offers much greater flexibility, and provides more statistically general approaches to
#'   visualizing patterns.  Thus, 
#'   \code{procD.allometry} might be thought of as an exploratory tool,
#'   if one is unsure how to model allometry for multiple groups.  One should not necessarily
#'   accept the \code{procD.allometry} result as "truth" and other models can be explored with \code{\link{procD.lm}}.  
#'   Examples for more flexible approaches to modeling allometry using \code{\link{procD.lm}} are provided below.
#' }
#' 
#' 
#'  \subsection{Notes for geomorph 3.0.5 and subsequent versions}{ 
#'  Previous versions of \code{procD.allometry} had an argument, f3, for providing additional covariates.  Complex
#'  models can now be analyzed with \code{\link{procD.lm}}, which has similar plotting capabilities as \code{procD.allometry}.
#'  Examples are provided below.  This argument is no longer used, and \code{procD.allometry} is restricted to simpler models,
#'  deferring instead to \code{\link{procD.lm}} for complex models.
#' }
#'   
#'  \subsection{Notes for geomorph 3.0.4 and subsequent versions}{ 
#'  Compared to previous versions of geomorph, users might notice differences in effect sizes.  Previous versions used z-scores 
#'  calculated with expected values of statistics from null hypotheses (sensu Collyer et al. 2015); however Adams and Collyer 
#'  (2016) showed that expected values for some statistics can vary with sample size and variable number, and recommended finding 
#'  the expected value, empirically, as the mean from the set of random outcomes.  Geomorph 3.0.4 and subsequent versions now 
#'  center z-scores on their empirically estimated expected values and where appropriate, log-transform values to assure statistics 
#'  are normally distributed.  This can result in negative effect sizes, when statistics are smaller than expected compared to the 
#'  average random outcome.  For ANOVA-based functions, the option to choose among different statistics to measure effect size 
#'  is now a function argument.
#' }

#' \subsection{Notes for geomorph 3.0 and making allometry plots}{ 
#' Former versions of geomorph had a "plotAllometry" function that performed ANOVA and produced
#' plots of allometry curves.  In geomorph 3.0, the \code{\link{plot}} function is used with 
#' \code{\link{procD.allometry}} objects to produce such plots.  The following arguments can be used in 
#' \code{\link{plot}} to achieve desired results.
#' \itemize{
#' \item{method = ("CAC, "RegScore, "PredLine").  Choose the desired plot method.}
#' \item{warpgrids: default = TRUE.  Logical value to indicate whether warpgrids should be plotted.} 
#' (Only works with 3D array data)
#' \item{label: can be logical to label points (1:n) - e.g., label = TRUE - or a vector indicating
#' text to use as labels.}
#' \item{mesh: A mesh3d object to be warped to represent shape deformation of the minimum and maximum size 
#' if {warpgrids=TRUE} (see \code{\link{warpRefMesh}}).}
#' }
#' Use ?\code{\link{plot.procD.allometry}} to understand the arguments used.  The following are brief 
#' descriptions of the different plotting methods using \code{\link{plot}}, with references.
#'\itemize{
#' \item {If "method=CAC" (the default) the function calculates the 
#'   common allometric component of the shape data, which is an estimate of the average allometric trend 
#'   for group-mean centered data (Mitteroecker et al. 2004). The function also calculates the residual shape component (RSC) for 
#'   the data.}
#'   \item {If "method=RegScore" the function calculates shape scores 
#'   from the regression of shape on size, and plots these versus size (Drake and Klingenberg 2008). 
#'   For a single group, these shape scores are mathematically identical to the CAC (Adams et al. 2013).}
#'   \item {If "method=PredLine" the function calculates predicted values from a regression of shape on size, and 
#'   plots the first principal component of the predicted values versus size as a stylized graphic of the 
#'   allometric trend (Adams and Nistri 2010). }
#'   }
#'   }
#'   
#' @param f1 A formula for the relationship of shape and size; e.g., Y ~ X.
#' @param f2 An optional right-hand formula for the inclusion of groups; e.g., ~ groups.
#' @param logsz A logical argument to indicate if the variable for size should be log-transformed.
#' @param iter Number of iterations for significance testing
#' @param seed An optional argument for setting the seed for random permutations of the resampling procedure.  
#' If left NULL (the default), the exact same P-values will be found for repeated runs of the analysis (with the same number of iterations).
#' If seed = "random", a random seed will be used, and P-values will vary.  One can also specify an integer for specific seed values,
#' which might be of interest for advanced users.
#' @param alpha The significance level for the homogeneity of slopes test
#' @param RRPP A logical value indicating whether residual randomization should be used for significance testing
#' @param data A data frame for the function environment, see \code{\link{geomorph.data.frame}} 
#' @param effect.type One of "F", "SS", or "cohen", to choose from which random distribution to estimate effect size.
#' (The default is "F").
#' @param print.progress A logical value to indicate whether a progress bar should be printed to the screen.  
#' This is helpful for long-running analyses.
#' @param ... Arguments passed on to procD.fit (typically associated with the lm function,
#' such as weights or offset).  The function procD.fit can also currently
#' handle either type I, type II, or type III sums of squares and cross-products (SSCP) calculations.  Choice of SSCP type can be made with the argument,
#' SS.type; i.e., SS.type = "I" or SS.type = "III".  Only advanced users should consider using these additional arguments, as such arguments
#' are experimental in nature. 
#' @keywords analysis
#' @export
#' @author Michael Collyer
#' @return An object of class "procD.allometry" is a list containing the following:
#' \item{HOS.test}{ANOVA for a homogeneity of slopes test (if groups are provided).}
#' \item{aov.table}{An analysis of variance table, based on inputs and the homogeneity of slopes test.}
#' \item{alpha}{The significance level criterion for the homogeneity of slopes test.}
#' \item{perm.method}{A value indicating whether "RRPP" or randomization of "raw" vales was used.}
#' \item{permutations}{The number of random permutations used in the resampling procedure.}
#' \item{data}{The data frame for the model.}
#' \item{random.SS}{A matrix or vector of random SS found via the resampling procedure used.}
#' \item{random.F}{A matrix or vector of random F values found via the resampling procedure used.}
#' \item{random.cohenf}{A matrix or vector of random Cohen's f-squared values
#'  found via the resampling procedure used.}
#' \item{call}{The matched call.}
#' \item{formula}{The resulting formula, which can be used in follow-up analyses.  Irrespective of input, shape = Y
#' in the formula, and the variable used for size is called "size".}
#' \item{CAC}{The 
#'   common allometric component of the shape data, which is an estimate of the average allometric trend 
#'   within groups (Mitteroecker et al. 2004). The function also calculates the residual shape component (RSC) for 
#'   the data.}
#' \item{RSC}{The residual shape component (associated with CAC approach)}
#' \item{Reg.proj}{The projected regression scores on the regression of shape on size. 
#'   For a single group, these shape scores are mathematically identical to the CAC (Adams et al. 2013).}
#' \item{pred.val}{Principal component scores (first PC) of predicted values.}
#' \item{ref}{the reference configuration (if input coordinates are in a 3D array).}
#' \item{gps}{A vector of group names.}
#' \item{size}{A vector of size scores.}
#' \item{logsz}{A logical value to indicate if size values were log=transformed for analysis.}
#' \item{A}{Procrustes (aligned) residuals.}
#' \item{Ahat}{Predicted Procrustes residuals(matching array or matrix, as input).}
#' \item{Ahat.at.min}{Predicted Procrustes residuals, specifically at minimum size.}
#' \item{Ahat.at.max}{Predicted Procrustes residuals, specifically at maximum size.}
#' \item{p}{landmark number}
#' \item{k}{landmark dimensions}
#' 
#' @references Adams, D.C., F.J. Rohlf, and D.E. Slice. 2013. A field comes of age: geometric morphometrics 
#'   in the 21st century. Hystrix. 24:7-14. 
#' @references Adams, D. C., and A. Nistri. 2010. Ontogenetic convergence and evolution of foot morphology 
#'   in European cave salamanders (Family: Plethodontidae). BMC Evol. Biol. 10:1-10.
#' @references Drake, A. G., and C. P. Klingenberg. 2008. The pace of morphological change: Historical 
#'   transformation of skull shape in St Bernard dogs. Proc. R. Soc. B. 275:71-76.
#' @references Mitteroecker, P., P. Gunz, M. Bernhard, K. Schaefer, and F. L. Bookstein. 2004. 
#'   Comparison of cranial ontogenetic trajectories among great apes and humans. J. Hum. Evol. 46:679-698.
#' @references Collyer, M.L., D.J. Sekora, and D.C. Adams. 2015. A method for analysis of phenotypic change for phenotypes described 
#' by high-dimensional data. Heredity. 115:357-365.
#' @references Adams, D.C. and M.L. Collyer. 2016.  On the comparison of the strength of morphological integration across morphometric 
#' datasets. Evolution. 70:2623-2631.
#' @seealso \code{\link{procD.lm}} and \code{\link{advanced.procD.lm}} within geomorph;
#' \code{\link[stats]{lm}} for more on linear model fits
#' @examples
#' # Simple allometry
#' data(plethodon) 
#' Y.gpa <- gpagen(plethodon$land, print.progress = FALSE)    #GPA-alignment  
#' 
#' gdf <- geomorph.data.frame(Y.gpa, site = plethodon$site, 
#' species = plethodon$species) 
#' plethAllometry <- procD.allometry(coords~Csize, f2 = NULL, f3=NULL, 
#' logsz = TRUE, data=gdf, iter=149, print.progress = FALSE)
#' summary(plethAllometry)
#' plot(plethAllometry, method = "PredLine")
#' plot(plethAllometry, method = "RegScore")
#' 
#' ## Obtaining size-adjusted residuals (and allometry-free shapes)
#' plethAnova <- procD.lm(plethAllometry$formula,
#'      data = plethAllometry$data, iter = 99, RRPP=TRUE, print.progress = FALSE) 
#' summary(plethAnova) # same ANOVA Table
#' shape.resid <- arrayspecs(plethAnova$residuals,
#'    p=dim(Y.gpa$coords)[1], k=dim(Y.gpa$coords)[2]) # allometry-adjusted residuals
#' adj.shape <- shape.resid + array(Y.gpa$consensus, dim(shape.resid)) # allometry-free shapes
#' plotTangentSpace(adj.shape) # PCA of allometry-free shape
#' 
#' # Group Allometries
#' plethAllometry <- procD.allometry(coords~Csize, ~species * site, 
#' logsz = TRUE, data=gdf, iter=99, RRPP=TRUE, print.progress = FALSE)
#' summary(plethAllometry)
#' plot(plethAllometry, method = "PredLine")
#' 
#' # Using procD.lm to call procD.allometry (in case more results are desired)
#' plethANOVA <- procD.lm(plethAllometry$formula, 
#' data = plethAllometry$data, iter = 149, RRPP=TRUE, print.progress = FALSE)
#' summary(plethANOVA) # Same ANOVA
#' 
#' # procD.allometry is a wrapper function for procD.lm.  The same analyses
#' # can be performed with procD.lm, and better graphics options
#' # are available. More complex models can be considered.
#'   
#' # Here are some examples using procD.lm, instead, offering greater flexibility.
#' 
#' data(larvalMorph)
#' Y.gpa <- gpagen(larvalMorph$tailcoords, curves = larvalMorph$tail.sliders, print.progress = FALSE)
#' gdf <- geomorph.data.frame(Y.gpa, Treatment = larvalMorph$treatment, 
#' Family = larvalMorph$family)
#' 
#' # procD.allometry approach
#' tailAllometry <- procD.allometry(coords ~ Csize, ~ Treatment,
#' logsz = TRUE, alpha = 0.05, data = gdf, iter = 149, print.progress = FALSE)
#' summary(tailAllometry) # HOS test suggests parallel allometries, but not unambiguous
#' plot(tailAllometry, method = "PredLine")
#' 
#' # procD.lm approach, including interaction
#' tailAllometry2 <- procD.lm(coords ~ log(Csize) * Treatment, data = gdf, iter = 149, 
#'      print.progress = FALSE)
#' plot(tailAllometry2, type = "regression", 
#' predictor = log(gdf$Csize), 
#' reg.type = "PredLine", 
#' pch = 21, 
#' bg = as.numeric(gdf$Treatment), 
#' xlab = "log(CS)") # greater flexibility
#' 
#' # including nested family effects, but still plotting by treatment
#' tailAllometry3 <- procD.lm(coords ~ log(Csize) * Treatment + 
#' Treatment/Family, data = gdf, iter = 149, print.progress = FALSE)
#' tailAllometry3 <- nested.update(tailAllometry3, ~ Treatment/Family)
#' summary(tailAllometry3)
#' plot(tailAllometry3, type = "regression", 
#' predictor = log(gdf$Csize), 
#' reg.type = "PredLine", 
#' pch = 21, 
#' bg = as.numeric(gdf$Treatment), 
#' xlab = "log(CS)")
#' 
procD.allometry<- function(f1, f2 = NULL, logsz = TRUE,
                           iter = 999, seed=NULL, alpha = 0.05, RRPP = TRUE, 
                           effect.type = c("F", "SS", "cohen"),
                           print.progress = TRUE, data=NULL, ...){
  if(!is.null(data)) data <- droplevels(data)
  pfit <- procD.fit(f1, data=data, pca=FALSE, ...)
  if(!is.null(data)) Ain <- eval(f1[[2]], data) else {
    Ain <- try(eval(f1[[2]]), silent = TRUE)
    if(!is.matrix(Ain) || !is.array(Ain)) Ain <- NULL 
  }
  dat <- pfit$data
  Y <- pfit$Y
  if(!is.vector(eval(f1[[3]], envir = dat))) stop("Only a single covariate for size is permitted") 
  datnm <- names(dat)
  nmmatch <- match(datnm, c("Y", "(weights)","(offset)"))
  names(dat)[is.na(nmmatch)] <- "size"
  if(!is.null(seed) && seed=="random") seed = sample(1:iter, 1)
  size <- dat$size
  if(any(size <= 0)) stop("Size values cannot be negative")
  if(logsz) form1 <- Y ~ log(size) else 
    form1 <- Y ~ size
  
  if(!is.null(f2)) {
    
    if(!is.null(data)) {
      data.types <- lapply(data, class)
      keep = sapply(data.types, function(x) x != "array" & x != "phylo" & x != "dist")
      dat2 <- as.data.frame(data[keep])
      if(length(f2) > 2)   f2 <- f2[-2]
      dat.g <- model.frame(f2, data=dat2) 
    } else dat2 <- NULL
    
    dat <- data.frame(dat, dat.g)
    g.Terms <- terms(dat.g)
    if(any(attr(g.Terms, "dataClasses") == "numeric")) stop("groups formula (f2) must contain only factors")
    if(ncol(dat.g) > 1) gps <- factor(apply(dat.g, 1,function(x) paste(x, collapse=":"))) else 
      gps <- as.factor(unlist(dat.g))
    form2 <- update(form1, ~. + gps)
    form4 <- form2
    form5 <- update(form1, ~.  * gps)
    if(!logsz) formfull <-as.formula(c("~",paste(unique(
      c(c("size", attr(g.Terms, "term.labels"), paste("size", attr(g.Terms, "term.labels"), sep=":")))),
      collapse="+"))) else
        formfull <-as.formula(c("~",paste(unique(
          c(c("log(size)", attr(g.Terms, "term.labels"), paste("log(size)", attr(g.Terms, "term.labels"), sep=":")))),
          collapse="+")))
  } else {
    
    dat2 <- NULL
    dat.g <- NULL
    g.Terms <- NULL
    gps <- NULL
    form2 <- form1
    formfull <- form1
  }

# HOS Test
  if(!is.null(f2)){
    form4 <- update(form4, Y ~.)
    form5 <- update(form5, Y ~.)
    datHOS <- data.frame(dat, size=size, gps=gps)
    cat("\nHomogeneity of Slopes Test\n")
    HOS <- advanced.procD.lm(form4, form5, data=datHOS, iter=iter, seed=seed, 
                             print.progress = print.progress)$anova.table
    rownames(HOS) = c("Common Allometry", "Group Allometries","Total")
    hos.pval <- HOS$P[2]
    if(hos.pval > alpha){ 
      if(logsz) rhs.formfull <- paste(c("log(size)", attr(g.Terms, "term.labels")),  collapse="+") else
        rhs.formfull <- paste(c("size", attr(g.Terms, "term.labels")),  collapse="+")
      formfull <- as.formula(c("Y ~", rhs.formfull))
    } 
  } else HOS <- NULL
  
  # ANOVA
  formfull <- update(formfull, Y~.)
  fitf <- procD.fit(formfull, data=dat, pca=FALSE, ...)
  cat("\nAllometry Model\n")
  effect.type <- match.arg(effect.type)
  anovafull <- procD.lm(formfull, data=dat, iter=iter, seed=seed, RRPP=RRPP,
                        effect.type=effect.type, 
                        print.progress = print.progress)
  if(RRPP) perm.method = "RRPP" else perm.method = "raw"
  
  # Plot set-up
  k <- length(fitf$Xfs)
  yhat <- fitf$wFitted.full[[k]]
  X <- as.matrix(fitf$wX)
  X[,2] <- 0 # remove slope
  if(!is.null(f2)){
    xp <- NCOL(model.matrix(~gps, data = )) + 1 # + 1 for slope
    X <- X[,1:xp] # remove potential interaction parametrs
  }
  B <- as.matrix(fitf$wCoefficients.full[[k]])
  Q <- qr(X)
  U <- (qr.Q(qr(X)))[, 1:Q$rank]
  y.cent <- fastLM(U, Y)$residuals
  if(logsz) sz <- log(size) else sz = size
  a <- (t(y.cent)%*%sz)%*%(1/(t(sz)%*%sz)); a <- a%*%(1/sqrt(t(a)%*%a))
  CAC <- y.cent%*%a  
  resid <- y.cent%*%(diag(dim(y.cent)[2]) - a%*%t(a))
  RSC <- prcomp(resid)$x
  Reg.proj <- Y%*%B[2,]%*%sqrt(solve(t(B[2,])%*%B[2,])) 
  pred.val <- prcomp(yhat)$x[,1] 
  
  if(length(dim(Ain)) == 3){
    Adim <- dim(Ain)
    Ahat <- arrayspecs(yhat, Adim[[1]], Adim[[2]])
    Ahat.at.min <- Ahat[,,which.min(sz)]
    Ahat.at.max <- Ahat[,,which.max(sz)]
    A <- arrayspecs(Y, Adim[[1]], Adim[[2]])
    ref<-mshape(A)
    p=Adim[[1]] ; k= Adim[[2]]
  } else {
    
    Ahat <- yhat ; A <- Y
    Ahat.at.min <- Ahat[which.min(sz),]
    Ahat.at.max <- Ahat[which.max(sz),]
    ref<-apply(A, 2, mean)
    p= NULL ; k=NULL
  }
  
  if(is.null(f2)) gps <- NULL
  out <- list(HOS.test = HOS, aov.table = anovafull$aov.table, call = match.call(),
              alpha = alpha, perm.method = perm.method, permutations=iter+1,
              formula = formfull, data=dat, effect.type = effect.type,
              random.SS = anovafull$random.SS, random.F = anovafull$random.F,
              random.cohenf = anovafull$random.cohenf,
              CAC = CAC, RSC = RSC, Reg.proj = Reg.proj,
              pred.val = pred.val,
              ref = ref, gps = gps, size = size, logsz = logsz, 
              A = A, Ahat = Ahat, 
              Ahat.at.min = Ahat.at.min, Ahat.at.max = Ahat.at.max,
              p = p, k = k)
  class(out) <- "procD.allometry"
  out
}