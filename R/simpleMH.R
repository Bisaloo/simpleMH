#' Simple Metropolis-Hastings MCMC
#'
#' @inheritParams mcmcensemble::MCMCEnsemble
#' @param inits numeric vector with the initial values for the parameters to
#'   estimate
#' @param theta.cov covariance matrix of the parameters to estimate.
#' @param coda logical. Should the samples be returned as [coda::mcmc]
#'   object? (defaults to `FALSE`)
#'
#' @return
#' * if `coda = FALSE` a list with:
#'   - *samples*: A two dimensional array of samples with dimensions
#'      `generation` x `parameter`
#'   - *log.p*: A numeric vector with the log density evaluate at each
#'      generation.
#' * if `coda = TRUE` a list with:
#'   - *samples*: A object of class [coda::mcmc] containing all samples.
#'   - *log.p*: A numeric vector with the log density evaluate at each
#'      generation.
#'
#' @examples
#' p.log <- function(x) {
#' B <- 0.03
#' return(-x[1]^2/200 - 1/2*(x[2]+B*x[1]^2-100*B)^2)
#' }
#'
#' simpleMH(p.log, inits=c(0, 0), theta.cov = diag(2), max.iter=3000)
#'
#' @importFrom mvtnorm rmvnorm
#' @importFrom stats runif
#'
#' @export
simpleMH <- function(f, inits, theta.cov, max.iter, coda = FALSE, ...) {

    theta_samples <- matrix(NA_real_, nrow = max.iter, ncol = length(inits))
    log_p <- rep_len(NA_real_, max.iter)

    theta_now <- inits

    p_theta <- f(theta_now, ...)

    p_samples <- rep(0, max.iter)

    p_theta_now <- p_theta

    log_p[1] <- p_theta_now
    theta_samples[1, ] <- theta_now

    for (m in 2:max.iter) {

      theta_new <- rmvnorm(n = 1, mean = theta_now, sigma = theta.cov)
      names(theta_new) <- names(inits)

      p_theta <- f(theta_new, ...)

      p_theta_new <- p_theta

      p_samples[m] <- p_theta_new

      a <- exp(p_theta_new - p_theta_now)
      z <- runif(1)

      if (isTRUE(z < a)) {
        theta_now <- theta_new
        p_theta_now <- p_theta_new
      }

      theta_samples[m, ] <- theta_now
      log_p[m] <- p_theta_now

    }

    if (is.null(names(inits))) {
      colnames(theta_samples) <- paste0("para_", seq_along(inits))
    } else {
      colnames(theta_samples) <- names(inits)
    }

    res <- list(samples = theta_samples, log.p = log_p)

    if (coda) {
      if (!requireNamespace("coda", quietly = TRUE)) {
        stop(
          "Package 'coda' needed for to create coda objects. ",
          "Please install it or use `coda = TRUE`.",
          call. = FALSE
        )
      }

      res$samples <- coda::as.mcmc(res$samples)
    }

    return(res)

}
