
## ----libs----------------------------------------------------------------
library("DESeq2")
library("DESeq2paper")
makeSimScript <- system.file("script/makeSim.R", package="DESeq2paper", mustWork=TRUE)
source(makeSimScript)
data("meanDispPairs")


## ----nullData------------------------------------------------------------
set.seed(1)
n <- 20000

m <- 6
condition <- factor(rep(c("A","B"), each = m/2))
x <- model.matrix(~ condition)
beta <- rep(0, n)
mat <- makeSim(n,m,x,beta,meanDispPairs)$mat
dds1 <- DESeqDataSetFromMatrix(mat, DataFrame(condition), ~ condition)
dds1 <- dds1[rowSums(counts(dds1)) > 1,]
dds1 <- DESeq(dds1)
res1 <- results(dds1, independentFiltering=FALSE)

m <- 12
condition <- factor(rep(c("A","B"), each = m/2))
x <- model.matrix(~ condition)
beta <- rep(0, n)
mat <- makeSim(n,m,x,beta,meanDispPairs)$mat
dds2 <- DESeqDataSetFromMatrix(mat, DataFrame(condition), ~ condition)
dds2 <- dds2[rowSums(counts(dds2)) > 1,]
dds2 <- DESeq(dds2)
res2 <- results(dds2, independentFiltering=FALSE)




## ----defineFunc----------------------------------------------------------
plotMarginalPvalueDensity <- function(df, cuts) {
  qs <- cut(df$mean, c(0, cuts, max(df$mean) + 1))
  plot(0,0,type="n",xlim=c(0,1),ylim=c(0,2),
       xlab="p-value",ylab="density")
  abline(h=1)
  cols <- colorRampPalette(c("purple","blue"))(nlevels(qs))
  for (i in seq_along(levels(qs))) {
    h <- hist(df$pvalue[qs == levels(qs)[i]], breaks=0:16/16, plot=FALSE)
    points(h$mids, h$density, type="o", col=cols[i], pch=i)
  }
  legend("bottomright",legend=levels(qs),pch=seq_along(levels(qs)),
         title="bin by row mean",cex=.7,ncol=2,
         col=cols)
}



## ----marginalIndep, fig.width=9, fig.height=4, fig.align="center",fig.cap="Marginal null histogram of the test statistic, p-values, conditioning on the filter statistic, the row mean of normalized counts across all samples, used for independent filtering. A simulated dataset was constructed with (A) 6 samples or (B) 12 samples. In either case the samples were equally divided into 2 groups with no true difference between the means of the two groups. The means and dispersions of the Negative Binomial simulated data were drawn from the estimates from the Pickrell et al dataset, and the standard DESeq2 pipeline was run. The histogram of $p$-values was estimated at 16 equally spaced intervals spanning [0,1]. The marginal distributions of the test statistic were generally uniform while conditioning on various quantiles of filter statistic. The row mean bin with the smallest mean of normalized counts (mean count 0-10) was depleted of small p-values. The black line indicates the expected frequency for a uniform distribution."----
line <- 0.5
adj <- -.15
cex <- 1.5

par(mar=c(4.5,4.5,2,1),mfrow=c(1,2))
nq <- 7

df <- data.frame(mean=res1$baseMean, pvalue=res1$pvalue)
cuts <- c(10, round(quantile(df$mean[df$mean > 10], 1:(nq-1)/nq)))
plotMarginalPvalueDensity(df, cuts)
mtext("A",side=3,line=line,adj=adj,cex=cex)

df <- data.frame(mean=res2$baseMean, pvalue=res2$pvalue)
cuts <- c(10, round(quantile(df$mean[df$mean > 10], 1:(nq-1)/nq)))
plotMarginalPvalueDensity(df, cuts)
mtext("B",side=3,line=line,adj=adj,cex=cex)



## ----sessInfo, echo=FALSE, results="asis"--------------------------------
toLatex(sessionInfo())


