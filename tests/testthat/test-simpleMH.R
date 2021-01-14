p.log <- function(x) {
  B <- 0.03
  return(-x[1]^2/200 - 1/2*(x[2]+B*x[1]^2-100*B)^2)
}

test_that("MH", {

  res1 <- simpleMH(p.log, inits=c(a=0, b=0), theta.cov = diag(2), max.iter=3000)

  expect_type(res1, "list")
  expect_length(res1, 2)
  expect_named(res1, c("samples", "log.p"))

  expect_identical(dim(res1$samples), c(3000L, 2L))
  expect_identical(nrow(res1$samples), length(res1$log.p))

  expect_identical(colnames(res1$samples), c("a", "b"))

  res2 <- simpleMH(p.log, inits=c(0, 0), theta.cov = diag(2), max.iter=3000)

  expect_identical(colnames(res2$samples), c("para_1", "para_2"))

  res3 <- simpleMH(p.log, inits=c(a=0, b=0), theta.cov = diag(2), max.iter=3000,
                   coda = TRUE)

  expect_s3_class(res3$samples, "mcmc")

})

test_that("errors", {

  mockery::stub(simpleMH, "requireNamespace", FALSE)

  expect_error(
    simpleMH(p.log, inits=c(a=0, b=0), theta.cov = diag(2), max.iter=3000,
             coda = TRUE),
    "coda"
  )

})

test_that("named arguments", {

  set.seed(20200111)
  res1 <- simpleMH(p.log, inits=c(a=0, b=0), theta.cov = diag(2), max.iter=3000)

  p.log.named <- function(x) {
    B <- 0.03
    return(-x["a"]^2/200 - 1/2*(x["b"]+B*x["a"]^2-100*B)^2)
  }

  set.seed(20200111)
  res2 <- simpleMH(p.log.named, inits=c(a=0, b=0), theta.cov = diag(2),
                   max.iter=3000)

  expect_identical(res1, res2)

})
