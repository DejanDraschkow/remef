% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/partial.R
\name{partial}
\alias{partial}
\title{Calculate partial effects}
\usage{
partial(model, fix = NULL, ran = NULL, grouping = FALSE,
  keep.intercept = TRUE, inverse = FALSE, keep = FALSE)
}
\arguments{
\item{model}{a model object.}

\item{fix}{either a character vector of coefficient labels
(fixed effects) or a corresponding numeric index vector.}

\item{ran}{a named list of integer vectors representing
random effects.}

\item{grouping}{logical. Should terms associated with the ones
in \code{fix} also be selected? The functionality of this
parameter depends on the value of \code{keep}.
The details are given under 'Details'.}

\item{keep.intercept}{logical. Should the intercept be kept
(default) or be removed?}

\item{inverse}{logical. If \code{TRUE}, the inverse of the link
function is applied (after the effects are removed).}

\item{keep}{logical. Should the specified effects be removed
  (default) or be kept?}
}
\value{
\code{partial} returns a numeric vector. The length equals
  the number of observations in the model.
}
\description{
\code{partial} is used to calculate partial effects of a (generalized)
 linear mixed-effects model fitted by a function of the \code{lme4}
 package.
}
\details{
\code{model} is an object returned by a model fitting
  function of the \pkg{lme4} package.
  The function works with both linear mixed-effects models
  (returned by the function \code{lmer}) and generalized linear
  mixed-effects models (\code{glmer}).

  The model formula for a (generalised) linear mixed-effects model
  can be written as

  \deqn{y = X \beta + Z b + \epsilon}{
        y = X * beta + Z * b + epsilon}

  where \eqn{y} is the vector including the response values,
  \eqn{X} is the (fixed-effects) design matrix, \eqn{\beta}{beta}
  is the vector of population coefficients (fixed effecs),
  \eqn{Z} is the random-effects design matrix, \eqn{b} is
  a vector of random effects, and \eqn{\epsilon}{epsilon} is a
  vector of random error terms (residuals).

  The response vector can be represented as a sum of fixed effects,
  random effects, and residuals. In order to construct partial effects,
  the function \code{partial} either "removes" effects (if
  \code{keep = FALSE}, see also \code{\link{remef}}) or "keeps"
  effects (if \code{keep = TRUE}, see also \code{\link{keepef}}).
  In both cases, the function does keep the residuals. Hence,
  the function does not return fitted values.

  The function removes a subset of fixed and random effects from
  the response variable. If all effects are removed, only the residuals
  remain.

  The valid \emph{character} strings for the parameter \code{fix}
  correspond to the names of the coeffcients in the model summary output.
  Note that the name of a coefficient is not necessarily identical to the
  name of a predictor variable (e.g., factor variables). Furthermore,
  a single variable in a model formula can result in multiple
  model coefficients (e.g., polynomial contrasts). The names of a model
  fit can be extracted with the function \code{effect_labels}.
  The character string passed to \code{fix} must not include the
  intercept (\code{"(Intercept)"}). Use the parameter
  \code{keep.intercept} instead.

  If \code{fix} is a \emph{numeric} index vector, the indices correspond
  to the order of coefficients in the model. For a fitted model object,
  the \code{effect_labels} returns the names of the coefficients in their
  order. Note that \code{fix} must not include the index of the
  intercept (usually \code{1}). Use the parameter \code{keep.intercept}
  instead.

  The parameter \code{ran} is used to specify random effects.
  The names of the list passed to \code{ran} correspond to the names
  of the random factors in the model summary.
  Alternatively, the string \code{"all"} can pe passed to \code{ran}
  which results in the selection of all random effects.

  If \code{grouping} is \code{FALSE}, only the specified fixed effects in
  \code{fix} are used.
  If \code{grouping} is \code{TRUE}, associated effects of lower
  \emph{or} higher order are used too. The actual behaviour of the
  function depends on the \code{keep} parameter: If \code{keep = FALSE}
  (effects are "removed"), \code{grouping} specifies whether effects of
  higher order should be selected and removed as well. Otherwise, if
  \code{keep = TRUE} (effects are "kept"), \code{grouping} specifies
  whether effects of lower order should be selected and kept as well.
  For example,
  if a model fit has the terms \code{A}, \code{B}, \code{C},
  \code{A:B}, \code{A:C}, \code{B:C}, and \code{A:B:C}, terms of
  higher order relative to \code{A} are \code{A:B}, \code{A:C},
  and \code{A:B:C}. Terms of lower order relative to \code{A:B} are
  \code{A} and \code{B}.

  The parameter \code{inverse} is only important for \emph{generalised}
  linear mixed-effects models (in contrast to linear mixed-effects
  models). In the former type of statistical models, a link function
  is specified to transform the response variable.
  If \code{partial} is used with such a type of model, the resulting
  values will be in the metric of the variable \emph{after} after the
  transformation. For example, if the response is binary and a model with
  the binomial distribution using the logit link funtion is fit,
  the function \code{partial} will return
  logits unless \code{inverse = TRUE} in which case logits will be
  transformed to proportions after the removal of effects.
}
\examples{
library(lme4)

fm1 <- lmer(Reaction ~ 1 + Days + (1 + Days | Subject), sleepstudy)
summary(fm1)

# remove fixed effect of 'Days'
p1_1 <- partial(fm1, fix = "Days")

# remove fixed effect of 'Days' and the intercept
p1_2 <- partial(fm1, fix = "Days", keep.intercept = FALSE)

# remove random slope of 'Days' (random factor: 'Subject')
p1_3 <- partial(fm1, ran = list(Subject = "Days"))

# remove fixed effect of 'Days' and both random effects
p1_4 <- partial(fm1, fix = "Days", ran = list(Subject = c("(Intercept)", "Days")))
# equivalent command with numeric indices
p1_5 <- partial(fm1, fix = 2, ran = list(Subject = c(1, 2)))

# keep the fixed effect of 'Days' (and the intercept), remove all other effects
p1_6 <- partial(fm1, fix = "Days", keep = FALSE)

# remove all effects
p1_7 <- partial(fm1, fix = 2, ran = "all", keep.intercept = FALSE)
p1_8 <- partial(fm1, keep = TRUE, keep.intercept = FALSE)  # equivalent command
all.equal(unname(residuals(fm1)), p1_7)


fm2 <- glmer(r2 ~ 1 + btype + Anger + (1 + Anger || item) + (1 | id), VerbAgg, family = binomial)
summary(fm2)

# remove fixed effects of 'btype'
# (since 'btype' is a three-level factor, two coefficients are estimated, 'btypescold' and 'btypeshout')
p2_1 <- partial(fm2, fix = c("btypescold", "btypeshout"))
# extract coefficient names related to 'btype'
term2coef(fm2, "btype")

#' # since `fm2` is a binomial GLMM, the partial effects are logits,
# the parameter `inverse` can be used to return probablities instead
p2_1_prob <- partial(fm2, fix = c("btypescold", "btypeshout"), inverse = TRUE)

# remove all random effects
# (Note that the order of random effects for the random factor 'item' is:
# 'Anger', '(Intercept)'; see `summary(fm2)`)
p2_2 <- partial(fm2, ran = list(item = c(1, 2), id = 1))
p2_3 <- partial(fm2, ran = "all")  # equivalent command


fm3 <- lmer(angle ~ 1 + recipe * temperature + (1 | recipe:replicate), cake)
summary(fm3)

# remove the random intercept
p3_1 <- partial(fm3, ran = list("recipe:replicate" = 1))

# remove fixed effect of 'recipeB' and all higher-order terms (interactions)
p3_2 <- partial(fm3, fix = "recipeB", grouping = TRUE)
# these are the higher-order terms of 'recipeB'
asef(fm3, "recipeB", order = "higher")

# keep fixed effect 'recipeB:temperature^4' and the lower-order ones (and the intercept)
p3_3 <- keepef(fm3, fix = "recipeB:temperature^4", grouping = TRUE)
# these are the lower-order terms of 'recipeB:temperature^4'
asef(fm3, "recipeB:temperature^4", order = "lower")

# remove all polynomials of 'temperature'
p3_4 <- partial(fm3, fix = term2coef(fm3, "temperature"))
}
\seealso{
\code{\link{remef}} for a wrapper with \code{keep = FALSE}
  and \code{\link{keepef}} for a wrapper with \code{keep = TRUE}.
}

