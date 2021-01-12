#' Simple Metropolis-Hastings MCMC
#'
#' @inheritParams mcmcensemble::MCMCEnsemble
#' @param inits numeric vector with the initial values for the parameters to
#'   estimate
#' @param theta.cov covariance matrix of the parameters to estimate.
#'
#' @inherit mcmcensemble::MCMCEnsemble return
#'
#' @importFrom mvtnorm rmvnorm
#' @importFrom stats runif
#'
#' @export
simpleMH <- function(f, inits, theta.cov, max.iter, ...) {

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

    return(list(samples = coda::as.mcmc(theta_samples), log.p = log_p))

  }
