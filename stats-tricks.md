# Stats tricks for validating models

## Validating likelihoods

For a density $p$ on data $x$ (this could be a scalar, vector, or a tree) parameterised by the vector $\theta$, the expected value of the score function $U(\theta,x)=\frac{\partial}{\partial\theta}\log p(x;\theta)$ is 0:

$$
E(U(\theta,x)) = \int U(\theta,x)p(x;\theta)dx = 0
$$ {#eq:scorefunction}

(this is the expected value over the data $x$ at the true parameters $\theta$)

Also, the covariance of the score function is equal to the negative Hessian of the log-likelihood:

$$
\textrm{Var}(U(\theta, x))=-E\left(\frac{\partial^2}{\partial\theta^2}\log p(x;\theta)\right)
$$

Or equivalently:

$$
E\left(U(\theta, x)U(\theta, x)^T + \frac{\partial^2}{\partial\theta^2}\log p(x;\theta)\right)=0 
$${#eq:variancestatistic}

[Proofs of these results are relatively straightforward](https://en.wikipedia.org/wiki/Score_(statistics)). The proofs depend on [some regularity conditions to interchange integration and differentiation](https://en.wikipedia.org/wiki/Leibniz_integral_rule); roughly speaking, the parameters must not change the support of the data. This means they don't hold for some parameters of interest in phylogenetics e.g. the origin time in a birth-death tree prior.

These properties can be used in conjunction with a direct simulator as a necessary but not sufficient check that the likelihood is implemented correctly. The score function (+@eq:scorefunction) and Hessian (+@eq:variancestatistic} statistics can be calculated on samples from the simulator and a hypothesis test used to check that their mean is 0. In the multivariate case a potentially useful test is the likelihood ratio test for a multivariate normal with zero mean ([implemented here](https://github.com/christiaanjs/beast-validation/blob/master/src/beast/validation/tests/MultivariateNormalZeroMeanTest.java)). If there are non-identifiable parameters there may be issues with performing this test as colinearity will lead to a singular sample covariance matrix.

In practice it is appropriate to compute the score function by calculating derivatives using finite differences ([implemented here](https://github.com/christiaanjs/beast-validation/blob/master/src/beast/validation/statistics/NumericalScoreFunctionStatistics.java)).

## Comparing multivariate distributions 
