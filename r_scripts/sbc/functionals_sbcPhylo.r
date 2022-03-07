functional_1 <- function(tree) sum(tree$edge.length)
functional_2 <- function(tree) max(tree$edge.length)
functional_2b <- function(tree) diff(range(tree$edge.length))
functional_3 <- function(tree,
                         tip = "t4"){
  ## returns length external branch leading to 'tip'
  pos <- match("t4", tree$tip.label)
  return(
    tree$edge.length[which(tree$edge[, 2] == pos)]
  )
}
functional_4 <- function(tree){
  object <- list(tree, reference.tree)
  class(object) <- "multiPhylo"
  as.numeric(distory::dist.multiPhylo(object, method = "edgeset"))
}
functional_5 <- function(tree){
  object <- list(tree, reference.tree)
  as.numeric(distory::dist.multiPhylo(object, method = "geodesic"))
}
functional_6 <- function(tree){
  object <- list(tree, reference.tree)
  as.numeric(
    TreeDist::KendallColijn(tree1 = tree, tree2 = reference.tree)
  )
}